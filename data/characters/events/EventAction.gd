# data/actions/events/EventAction.gd
class_name EventAction
extends DayAction

@export var outcomes: Array[EventOutcome] = []

func execute(ctx: DayContext) -> DayActionResult:
	var result   := DayActionResult.new()
	var outcome  := _pick_weighted_outcome(ctx)

	if outcome == null:
		push_error("EventAction '%s': sin outcomes definidos." % id)
		result.success = false
		return result

	# Escalar el resultado por dificultad del día
	var scale := DifficultyScaler.challenge_multiplier(ctx.day_number)

	result.narrative_key = outcome.narrative_key
	result.xp_gained     = outcome.xp_gained * scale
	result.extra_data    = outcome.extra_data.duplicate()
	result.success       = true

	# Los stat_changes del outcome se escalan (tanto positivos como negativos)
	for stat_id: StringName in outcome.stat_changes.keys():
		result.stat_changes[stat_id] = outcome.stat_changes[stat_id] * scale

	return result

## Selección ponderada: suma los pesos, elige un umbral aleatorio.
func _pick_weighted_outcome(ctx: DayContext) -> EventOutcome:
	if outcomes.is_empty():
		return null

	# Calcular peso total con loop explícito (evita Variant de reduce)
	var total_weight: float = 0.0
	for outcome: EventOutcome in outcomes:
		total_weight += outcome.weight

	var roll: float        = ctx.rng.randf_range(0.0, total_weight)
	var accumulated: float = 0.0

	for outcome: EventOutcome in outcomes:
		accumulated += outcome.weight
		if roll <= accumulated:
			return outcome

	return outcomes.back()
