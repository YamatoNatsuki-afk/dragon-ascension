# res://data/characters/training/TrainingAction.gd
#
# Acción de entrenamiento. Sube uno o más stats por día.
#
# SCALING POR STAT (Fase B):
#   Si scale_stat_id está definido, el gain se multiplica según el nivel actual
#   de ese stat. Esto premia especializarse: cuanto más alto tenés el stat
#   primario, más eficiente es entrenarlo — pero con diminishing returns.
#
#   Fórmula:
#     scale_mult = 1.0 + clamp(stat_actual / scale_threshold, 0.0, scale_max_bonus)
#
#   Ejemplo con scale_threshold=100, scale_max_bonus=0.5:
#     stat=  0 → ×1.00  (sin bonus)
#     stat= 50 → ×1.25  (+25%)
#     stat=100 → ×1.50  (+50% — máximo)
#     stat=200 → ×1.50  (capped)
#
#   Para el stat secundario el scaling NO aplica — solo al primario.
#   Esto evita que los secundarios se disparen en late game.
#
# ENERGY COST (Fase B):
#   Si el personaje no tiene suficiente energía, la acción falla
#   con un resultado de descanso forzado (sin cambios de stats).
#   DayContext debe exponer ctx.energy_available para activar esto.
#   Si no lo expone, el cost se ignora silenciosamente (backward compat).

class_name TrainingAction
extends DayAction

## Stats que mejora este entrenamiento. El primero es el stat principal.
@export var target_stats: Array[StringName] = []

## Ganancia base antes de modificadores.
@export var base_gain: float = 1.5

## Coste de energía diario. 1 = normal. 2 = agotador (Roshi, Kaio).
@export var energy_cost: int = 1

## Stat que escala el gain. Normalmente el primer stat de target_stats.
## Si está vacío, no se aplica scaling por stat.
@export var scale_stat_id: StringName = &""

## Valor de stat en el que se alcanza el bonus máximo.
## Por encima de este valor el bonus está capped.
@export var scale_threshold: float = 100.0

## Bonus máximo aplicable como multiplicador adicional (0.5 = +50%).
@export var scale_max_bonus: float = 0.5

## Si es true, DayScreen muestra TrainingMinigame antes de ejecutar la acción.
## El resultado del minijuego se propaga via DayManager.pending_training_multiplier.
## Poner en false para entrenamientos automáticos (debugging, NPC-driven, etc).
@export var has_minigame: bool = true

# ─────────────────────────────────────────────────────────────────────────────

func execute(ctx: DayContext) -> DayActionResult:
	var result    := DayActionResult.new()
	var day_scale := DifficultyScaler.reward_multiplier(ctx.day_number)
	var variance  := DifficultyScaler.variance_factor(ctx.day_number)

	result.action_type = &"training"

	# Leer multiplicador del minijuego (seteado por DayScreen antes de llamar execute)
	# Si DayManager no tiene el campo (versión vieja), usa 1.0 como fallback.
	var mini_mult: float = 1.0
	if DayManager.get("pending_training_multiplier") != null:
		mini_mult = DayManager.pending_training_multiplier
		DayManager.pending_training_multiplier = 1.0  # resetear inmediatamente

	# Energy check — silencioso si DayContext no lo expone (backward compat)
	if ctx.get("energy_available") != null:
		if ctx.energy_available < energy_cost:
			result.success       = false
			result.narrative_key = "training.%s.exhausted" % id
			result.xp_gained     = 0.5  # XP mínimo — el intento cuenta
			return result

	# Calcular scaling por stat primario (si aplica)
	var scale_mult := _get_scale_multiplier(ctx)

	# Distribuir el gain entre stats primario y secundarios
	for i: int in target_stats.size():
		var stat_id: StringName = target_stats[i]
		var weight: float = ctx.character_data.build.stat_priority_weights.get(stat_id, 0.5)

		var gain_raw: float
		if i == 0:
			# Stat primario: recibe scaling + multiplicador del minijuego
			gain_raw = base_gain * day_scale * (0.5 + weight) * scale_mult * mini_mult
		else:
			# Stats secundarios: gain reducido, sin scaling por stat ni mini_mult
			gain_raw = base_gain * day_scale * (0.5 + weight) * 0.4

		var gain_final := DifficultyScaler.apply_variance(gain_raw, variance, ctx.rng)
		gain_final      = snappedf(gain_final, 0.1)
		result.stat_changes[stat_id] = gain_final

	# XP proporcional a la ganancia total
	var total_gain: float = 0.0
	for val: float in result.stat_changes.values():
		total_gain += val
	result.xp_gained     = total_gain * 10.0 * DifficultyScaler.reward_multiplier(ctx.day_number)

	result.success       = true
	result.narrative_key = "training.%s.success" % id
	return result

# ─────────────────────────────────────────────────────────────────────────────

## Calcula el multiplicador de escala basado en el stat primario.
func _get_scale_multiplier(ctx: DayContext) -> float:
	if scale_stat_id == &"" or scale_threshold <= 0.0:
		return 1.0

	var stat_val: float = ctx.character_data.base_stats.get(scale_stat_id, 0.0)
	var ratio: float    = clampf(stat_val / scale_threshold, 0.0, 1.0)
	return 1.0 + ratio * scale_max_bonus
