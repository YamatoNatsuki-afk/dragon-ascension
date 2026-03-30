# res://data/npcs/NpcDefinition.gd
#
# Resource que define UN NPC aliado.
# No contiene estado — solo la definición estática.
# El estado de relación vive en NpcRelationState dentro de CharacterData.
#
# ESTADOS DE RELACIÓN (int):
#   0 = UNKNOWN   — no se conoce todavía
#   1 = KNOWN     — se conoció, sin vínculo
#   2 = FRIENDLY  — tiene trato, puede aparecer en eventos
#   3 = ALLY      — aliado activo: acción especial disponible + bonuses
#   4 = MASTER    — nivel máximo: bonuses aumentados + diálogo especial
#
# BONUSES DE ENTRENAMIENTO:
#   training_stat_mults → Dictionary[StringName, float]
#   Multiplica las ganancias de esos stats cuando se entrena con este NPC.
#
# BONUSES DE COMBATE:
#   combat_dodge_bonus   → float adicional a la chance de esquiva (0.0–1.0)
#   combat_damage_mult   → multiplicador de daño adicional
#   combat_counter_chance→ chance de contraataque (0.0–1.0)
#   combat_ki_recovery   → ki recuperado por turno durante combate

class_name NpcDefinition
extends Resource

enum RelationState { UNKNOWN = 0, KNOWN = 1, FRIENDLY = 2, ALLY = 3, MASTER = 4 }

## ID único del NPC. Convención: "npc_krilin", "npc_roshi", etc.
@export var id: StringName = &""

## Nombre visible.
@export var display_name: String = ""

## Descripción corta del NPC.
@export var description: String = ""

## Color del NPC en la UI.
@export var color: Color = Color(0.92, 0.90, 0.86)

## Icono / emoji representativo.
@export var icon: String = "◆"

# ─────────────────────────────────────────────────────────────────────────────
# CONDICIONES DE DESBLOQUEO
# ─────────────────────────────────────────────────────────────────────────────

## Flag requerida para que este NPC aparezca (estado KNOWN).
## Si está vacía, se usa el día mínimo como única condición.
@export var required_flag: StringName = &""

## Día mínimo para que el NPC esté disponible.
@export var min_day: int = 1

## Stat mínimo requerido para pasar a ALLY.
## Par [stat_id, min_value]. Vacío = sin requisito de stat.
@export var ally_stat_requirement: Array = []   # [StringName, float]

## Flag que se setea cuando el NPC se vuelve aliado.
@export var ally_flag: StringName = &""

# ─────────────────────────────────────────────────────────────────────────────
# BONUSES DE ENTRENAMIENTO (activos cuando es ALLY o MASTER)
# ─────────────────────────────────────────────────────────────────────────────

## Multiplicadores de ganancia por stat al entrenar con este NPC.
## Ejemplo: { &"velocidad": 1.20, &"vitalidad": 1.15 }
@export var training_stat_mults: Dictionary = {}

## Stats que entrena en su acción especial (primario = [0]).
@export var training_target_stats: Array[StringName] = []

## Ganancia base de su acción especial.
@export var training_base_gain: float = 3.0

## Frases del NPC al entrenar (se elige una aleatoria).
@export var training_quotes: Array[String] = []

## Con estado MASTER, los multipliers se amplifican por este factor.
@export var master_bonus_multiplier: float = 1.30

# ─────────────────────────────────────────────────────────────────────────────
# BONUSES DE COMBATE (activos cuando es ALLY o MASTER)
# ─────────────────────────────────────────────────────────────────────────────

## Bonus adicional a la chance de esquiva del jugador (0.0–0.30).
@export var combat_dodge_bonus: float = 0.0

## Multiplicador adicional de daño del jugador (1.0 = sin bonus).
@export var combat_damage_mult: float = 1.0

## Chance por turno de contraatacar después de recibir daño (0.0–0.50).
@export var combat_counter_chance: float = 0.0

## Ki recuperado por segundo durante el combate.
@export var combat_ki_recovery: float = 0.0

## Descripción del bonus de combate para mostrar en UI.
@export var combat_bonus_desc: String = ""

# ─────────────────────────────────────────────────────────────────────────────
# API
# ─────────────────────────────────────────────────────────────────────────────

## Retorna el multiplicador de entrenamiento para un stat dado.
## Aplica el bonus de maestría si el estado es MASTER.
func get_training_mult(stat_id: StringName, relation: int) -> float:
	var base: float = float(training_stat_mults.get(stat_id, 1.0))
	if relation == RelationState.MASTER:
		return 1.0 + (base - 1.0) * master_bonus_multiplier
	return base

## Retorna true si este NPC cumple las condiciones para aparecer en el día dado.
func is_available(day: int, flags: Dictionary) -> bool:
	if day < min_day:
		return false
	if required_flag != &"" and not flags.get(required_flag, false):
		return false
	return true

## Retorna true si cumple las condiciones para volverse ALLY.
func can_become_ally(stats: Dictionary, flags: Dictionary) -> bool:
	if ally_stat_requirement.size() >= 2:
		var stat_id: StringName = ally_stat_requirement[0]
		var min_val: float      = float(ally_stat_requirement[1])
		if stats.get(stat_id, 0.0) < min_val:
			return false
	return true

## Retorna una cita aleatoria del NPC al entrenar.
func get_random_quote() -> String:
	if training_quotes.is_empty():
		return ""
	return training_quotes[randi() % training_quotes.size()]
