# data/actions/training/TrainingAction.gd
class_name TrainingAction
extends DayAction

# Qué stats mejora este entrenamiento (definido en el .tres del editor)
@export var target_stats: Array[StringName] = []

# Ganancia base antes de modificadores. El diseñador ajusta esto por acción.
@export var base_gain: float = 1.5

# Coste de energía (para futuros sistemas de stamina/recursos diarios)
@export var energy_cost: int = 1

func execute(ctx: DayContext) -> DayActionResult:
	var result    := DayActionResult.new()
	var day_scale := DifficultyScaler.reward_multiplier(ctx.day_number)
	var variance  := DifficultyScaler.variance_factor(ctx.day_number)

	result.action_type = &"training"

	for stat_id: StringName in target_stats:
		var weight: float = ctx.character_data.build.stat_priority_weights.get(stat_id, 0.5)
		var gain_raw      := base_gain * day_scale * (0.5 + weight)
		var gain_final    := DifficultyScaler.apply_variance(gain_raw, variance, ctx.rng)
		gain_final         = snappedf(gain_final, 0.1)
		result.stat_changes[stat_id] = gain_final

	# XP proporcional a la ganancia total — loop tipado, sin reduce()
	var total_gain: float = 0.0
	for val: float in result.stat_changes.values():
		total_gain += val
	result.xp_gained     = total_gain * 10.0 * DifficultyScaler.reward_multiplier(ctx.day_number)

	result.success       = true
	result.narrative_key = "training.%s.success" % id
	return result
