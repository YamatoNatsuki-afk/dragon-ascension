# res://data/characters/actions/snake_road/SnakeRoadAction.gd
#
# Acción especial del Camino de la Serpiente.
# Es la única acción multi-día del juego — dura hasta completar 1.000.000 km.
#
# FLUJO:
#   1. execute() calcula los km base del día según poder_total.
#   2. Emite signal minigame_requested con los parámetros.
#   3. DayScreen/GameManager muestra SnakeRoadMinigame.
#   4. Cuando el minijuego termina, llama resolve_with_multiplier().
#   5. resolve_with_multiplier() aplica los km, sube stats y retorna el resultado.
#
# FÓRMULA km/día base:
#   Basada en los datos canónicos del manga (Goku 334 poder → 172 días).
#   dias_base = 172 × (334 / poder_total) ^ 0.85
#   km_base   = 1_000_000 / dias_base
#
# CONDICIONES de desbloqueo (en el .tres):
#   IS_DEAD = true (morir es requisito narrativo — Fase D)
#   velocidad >= 40 (no te caés del camino)
#
# Cuando se completan los 1.000.000 km:
#   - Flag snake_road_completed = true
#   - Desbloquea train_kaio
#   - Bonus de stats según performance promedio

class_name SnakeRoadAction
extends DayAction

## Emitida cuando el día requiere el minijuego.
## DayScreen debe conectarse a esta señal y mostrar SnakeRoadMinigame.
signal minigame_requested(base_km: float, current_km: float)

const TARGET_KM:     float = 1_000_000.0
const STAT_KEY_KM:   String = "snake_road_km"

# Stats que se ganan por día de recorrido
const STATS_PER_DAY: Dictionary = {
	&"velocidad":     0.3,
	&"intel_combate": 0.2,
	&"vitalidad":     0.1,
}

# ── Campos del .tres ──────────────────────────────────────────────────────
@export var velocity_requirement: float = 40.0

# ─────────────────────────────────────────────────────────────────────────────

## Sobrescribe is_available — agrega check de velocidad mínima.
func is_available(ctx: DayContext) -> bool:
	if not super.is_available(ctx):
		return false
	# Check velocidad mínima — si no la tenés, te caés del camino
	var vel: float = ctx.character_data.base_stats.get(&"velocidad", 0.0)
	if vel < velocity_requirement:
		return false
	# No mostrar si ya completaste el camino
	var progress: Dictionary = ctx.character_data.get("active_event_progress") \
		if ctx.character_data.get("active_event_progress") != null else {}
	var km: float = progress.get(STAT_KEY_KM, 0.0)
	return km < TARGET_KM

## execute() calcula los km base y dispara la señal del minijuego.
## DayScreen llama resolve_with_multiplier() con el resultado.
func execute(ctx: DayContext) -> DayActionResult:
	var poder: float
	if ctx.character_data.has_method("get_poder_total"):
		poder = ctx.character_data.get_poder_total()
	else:
		poder = 200.0
	poder = maxf(poder, 50.0)

	# Fórmula basada en datos canónicos
	var dias_base: float = 172.0 * pow(334.0 / poder, 0.85)
	var km_base:   float = TARGET_KM / dias_base

	# Leer km acumulados
	var progress: Dictionary = ctx.character_data.get("active_event_progress") \
		if ctx.character_data.get("active_event_progress") != null else {}
	var current_km: float = progress.get(STAT_KEY_KM, 0.0)

	# Emitir señal — DayScreen muestra el minijuego
	minigame_requested.emit(km_base, current_km)

	# Retornar resultado provisional — se sobreescribe en resolve_with_multiplier()
	var result := DayActionResult.new()
	result.action_type   = &"training"
	result.success       = true
	result.narrative_key = "snake_road.running"
	return result

## Llamado por DayScreen cuando el minijuego termina.
## Aplica los km, sube stats y detecta si se completó el camino.
func resolve_with_multiplier(ctx: DayContext, multiplier: float,
		km_base: float) -> DayActionResult:

	var result := DayActionResult.new()
	result.action_type = &"training"
	result.success     = true

	var km_gained := km_base * multiplier

	# Leer/actualizar progreso
	var progress: Dictionary = ctx.character_data.get("active_event_progress") \
		if ctx.character_data.get("active_event_progress") != null else {}
	var prev_km: float = progress.get(STAT_KEY_KM, 0.0)
	var new_km:  float = minf(prev_km + km_gained, TARGET_KM)
	progress[STAT_KEY_KM] = new_km

	if ctx.character_data.get("active_event_progress") != null:
		ctx.character_data.active_event_progress = progress

	# Stats diarios (escalan con multiplier)
	var day_scale := DifficultyScaler.reward_multiplier(ctx.day_number)
	for stat_id: StringName in STATS_PER_DAY.keys():
		var gain: float = STATS_PER_DAY[stat_id] * multiplier * day_scale
		gain = snappedf(gain, 0.1)
		result.stat_changes[stat_id] = gain

	result.xp_gained = km_gained * 0.05 * day_scale

	if new_km >= TARGET_KM:
		result.narrative_key = &"snake_road.completed"
		_apply_completion_bonus(ctx, result, multiplier)
	else:
		var pct_bucket: int = int(new_km / TARGET_KM * 100.0) / 10 * 10
		result.narrative_key = ("snake_road.progress_%d" % pct_bucket) as StringName

	return result

func _apply_completion_bonus(ctx: DayContext, result: DayActionResult,
		avg_multiplier: float) -> void:
	# Bonus de llegada — escala con qué tan bien corriste
	var bonus_mult := avg_multiplier  # 0.5 mal → 2.0 perfecto

	var bonuses := {
		&"velocidad":     5.0 * bonus_mult,
		&"intel_combate": 3.0 * bonus_mult,
		&"vitalidad":     2.0 * bonus_mult,
	}
	for stat_id: StringName in bonuses:
		var current: float = result.stat_changes.get(stat_id, 0.0)
		result.stat_changes[stat_id] = snappedf(current + bonuses[stat_id], 0.1)

	# Setear flag
	if ctx.character_data.get("saved_flags") != null:
		ctx.character_data.saved_flags[&"snake_road_completed"] = true

	result.xp_gained += 500.0 * bonus_mult
	result.narrative_key = "snake_road.completed"
