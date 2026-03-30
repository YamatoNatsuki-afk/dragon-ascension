# res://data/characters/CharacterData.gd
#
# Resource central del personaje. Solo datos — sin lógica de gameplay.
#
# CAMPOS:
#   base_stats   → los 8 stats canónicos.
#   appearance   → datos visuales.
#   build        → prioridades y estilo de combate.
#   saved_flags  → snapshot de FlagSystem. Solo SaveSystem lo toca.

class_name CharacterData
extends Resource

@export var character_name: String     = "Guerrero"
@export var race_id:        StringName = &"human"
@export var current_day:    int        = 1
@export var experience:     float      = 0.0

## Nivel calculado desde XP. Se actualiza en DayManager después de ganar XP.
## Fórmula: nivel = floor(sqrt(xp / 50)) → nivel 1 en 50 XP, nivel 10 en 5000 XP.
@export var level: int = 0

## Puntos de stat sin gastar. Se acumula 1 por nivel ganado.
## El jugador los asigna desde el panel de stats del DayScreen.
@export var stat_points_available: int = 0

## XP del nivel anterior — para calcular cuánto falta al siguiente.
@export var xp_at_last_level: float = 0.0

@export var base_stats: Dictionary = {
	&"fuerza":        0.0,
	&"velocidad":     0.0,
	&"ki":            0.0,
	&"vitalidad":     0.0,
	&"resistencia":   0.0,
	&"poder_ki":      0.0,
	&"inteligencia":  0.0,
	&"intel_combate": 0.0,
}

@export var appearance: AppearanceData = null
@export var build:      BuildData      = null

## Snapshot del FlagSystem. Gestionado exclusivamente por SaveSystem.
@export var saved_flags: Dictionary = {}

## IDs de acciones que el jugador ya vio al menos un día.
## Usado por DayScreen para mostrar el badge "NUEVO" en acciones recién desbloqueadas.
@export var seen_action_ids: Array[StringName] = []

## Progreso de eventos multi-día (Camino de la Serpiente, etc.)
## Formato: { "snake_road_km": float, ... }
@export var active_event_progress: Dictionary = {}

## Estado de transformaciones del personaje — desbloqueadas + maestría.
## TransformationSystem lo lee y escribe. SaveSystem lo persiste automáticamente.
@export var transformation_state: TransformationState = null

## Estado de relaciones con NPCs. NpcSystem lo lee y escribe.
@export var npc_relation_state: NpcRelationState = null

## Récords de minijuegos. Clave = minigame_id, Valor = score 0.0–100.0.
## Persistido automáticamente por SaveSystem.
@export var minigame_records: Dictionary = {}

## Umbrales de récord ya otorgados. Clave = "minigame_id_threshold", Valor = true.
## Evita dar el mismo bonus dos veces en el mismo run.
@export var minigame_milestones: Dictionary = {}

# ─────────────────────────────────────────────────────────────────────────────
# Definición de tiers
# ─────────────────────────────────────────────────────────────────────────────
#
# Multiplicadores de salto inspirados en VS Battles Wiki
# (Radio de Extremo Alto a Extremo Bajo), sin usar valores de energía.
# Cada tier es ~3× el anterior — progresión exponencial tipo Dragon Ball.
#
# Formato por entrada: [nombre, umbral_max, sub_label, color]
# umbral_max = -1 → tier final sin límite superior.

const TIER_TABLE: Array = [
	["Civil",          100.0,  "Humano Atlético",    Color(0.50, 0.49, 0.47)],
	["Guerrero",       300.0,  "Sobrehumano",        Color(0.28, 0.85, 0.44)],
	["Elite",          900.0,  "Nivel Muro",         Color(0.25, 0.60, 1.00)],
	["Superguerrero", 2500.0,  "Nivel Edificio",     Color(0.10, 0.90, 0.95)],
	["Legendario",    7500.0,  "Nivel Ciudad",       Color(1.00, 0.78, 0.10)],
	["Divino",       22000.0,  "Nivel Montaña",      Color(1.00, 0.50, 0.05)],
	["Supremo",      65000.0,  "Nivel Continental",  Color(0.90, 0.20, 0.10)],
	["Absoluto",        -1.0,  "Nivel Planetario",   Color(0.80, 0.40, 1.00)],
]

# ─────────────────────────────────────────────────────────────────────────────
# API de lectura
# ─────────────────────────────────────────────────────────────────────────────

func get_stat(stat_id: StringName) -> float:
	return base_stats.get(stat_id, 0.0)

## XP necesaria para alcanzar un nivel dado.
## Fórmula inversa: xp = nivel² × 50
static func xp_for_level(lvl: int) -> float:
	return float(lvl * lvl) * 50.0

## Nivel correspondiente a una cantidad de XP.
static func level_from_xp(xp: float) -> int:
	return int(sqrt(xp / 50.0))

## XP necesaria para el siguiente nivel desde el nivel actual.
func xp_to_next_level() -> float:
	return xp_for_level(level + 1) - experience

## Progreso 0.0–1.0 dentro del nivel actual.
func level_progress() -> float:
	var xp_start := xp_for_level(level)
	var xp_end   := xp_for_level(level + 1)
	var range_:   float = xp_end - xp_start
	if range_ <= 0.0:
		return 1.0
	return clampf((experience - xp_start) / range_, 0.0, 1.0)

## Poder total ponderado. Determina el tier del personaje.
func get_poder_total() -> float:
	return (
		base_stats.get(&"fuerza",        0.0) * 1.5 +
		base_stats.get(&"velocidad",     0.0) * 1.2 +
		base_stats.get(&"ki",            0.0) * 1.0 +
		base_stats.get(&"vitalidad",     0.0) * 0.8 +
		base_stats.get(&"resistencia",   0.0) * 0.6 +
		base_stats.get(&"poder_ki",      0.0) * 1.1 +
		base_stats.get(&"inteligencia",  0.0) * 0.4 +
		base_stats.get(&"intel_combate", 0.0) * 0.9
	)

## Nombre del tier actual. Usado por logs y sistemas externos.
func get_tier() -> String:
	var p := get_poder_total()
	for entry in TIER_TABLE:
		var max_val: float = entry[1]
		if max_val < 0.0 or p < max_val:
			return entry[0]
	return TIER_TABLE[-1][0]

## Datos completos del tier actual para la UI de DayScreen.
## Retorna: name, sub_label, color, poder, tier_min, tier_max, progress, is_max, index, total.
func get_tier_data() -> Dictionary:
	var p     := get_poder_total()
	var index := TIER_TABLE.size() - 1  # default: último tier

	for i in TIER_TABLE.size():
		var max_val: float = TIER_TABLE[i][1]
		if max_val < 0.0 or p < max_val:
			index = i
			break

	var entry:    Array = TIER_TABLE[index]
	var tier_min: float = TIER_TABLE[index - 1][1] if index > 0 else 0.0
	var tier_max: float = float(entry[1])
	var is_max:   bool  = tier_max < 0.0

	var progress: float = 1.0
	if not is_max and (tier_max - tier_min) > 0.0:
		progress = clampf((p - tier_min) / (tier_max - tier_min), 0.0, 1.0)

	return {
		"name":      entry[0],
		"sub_label": entry[2],
		"color":     entry[3],
		"poder":     p,
		"tier_min":  tier_min,
		"tier_max":  tier_max,
		"progress":  progress,
		"is_max":    is_max,
		"index":     index,
		"total":     TIER_TABLE.size(),
	}

func get_max_hp() -> float:
	return base_stats.get(&"vitalidad", 1.0) * 8.0

func can_craft(required_intel: float = 20.0) -> bool:
	return base_stats.get(&"inteligencia", 0.0) >= required_intel
