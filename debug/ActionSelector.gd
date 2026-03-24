# debug/ActionSelector.gd
# RefCounted — lógica pura de selección, sin estado de UI ni de loop.
#
# Responsabilidad: dado un array de acciones y un contexto, elegir una
# según pesos ponderados por el BuildData del personaje.
#
# Separado de DebugDayLoop para que la UI real pueda mostrar los mismos
# pesos al jugador (ej: resaltar la acción "recomendada").
class_name ActionSelector
extends RefCounted

## Calcula el peso final de una acción para el personaje en este contexto.
## Peso final = selection_weight × afinidad_con_build
##
## La afinidad mide cuánto coincide la acción con las prioridades del build:
##  - TrainingAction: promedio de stat_priority_weights de sus target_stats
##  - EventAction / CombatEventAction: peso base sin modificar
##  - Acción sin stats objetivo: afinidad neutra (1.0)
static func compute_weight(action: DayAction, ctx: DayContext) -> float:
	var base      := action.selection_weight
	var affinity  := _build_affinity(action, ctx)
	var modifier  := ModifySelectionWeightConsequence.get_active_multiplier(
		action.id, ctx.day_number
	)
	return base * affinity * modifier

## Elige una acción de la lista usando selección ponderada.
## Devuelve null solo si la lista está vacía.
static func pick(actions: Array[DayAction], ctx: DayContext, \
		rng: RandomNumberGenerator) -> DayAction:
	if actions.is_empty():
		return null

	# Calcular peso total
	var total_weight: float = 0.0
	var weights: Array[float] = []
	for action: DayAction in actions:
		var w := compute_weight(action, ctx)
		weights.append(w)
		total_weight += w

	if total_weight <= 0.0:
		# Fallback: elige uniformemente si todos los pesos son cero
		return actions[rng.randi() % actions.size()]

	# Selección ponderada
	var roll: float = rng.randf_range(0.0, total_weight)
	var accumulated: float = 0.0
	for i: int in range(actions.size()):
		accumulated += weights[i]
		if roll <= accumulated:
			return actions[i]

	return actions.back()

## Devuelve la tabla de pesos para logging (acción → peso calculado).
## Útil para el debug loop y para que la UI muestre "acciones sugeridas".
static func compute_weight_table(actions: Array[DayAction], \
		ctx: DayContext) -> Dictionary:
	var table: Dictionary = {}
	for action: DayAction in actions:
		table[action.id] = compute_weight(action, ctx)
	return table

# ─────────────────────────────────────────────
# Lógica de afinidad con el build
# ─────────────────────────────────────────────

static func _build_affinity(action: DayAction, ctx: DayContext) -> float:
	if not action is TrainingAction:
		# Eventos y combates tienen afinidad neutra —
		# el riesgo/recompensa no depende del build, sino del día
		return 1.0

	var training := action as TrainingAction
	if training.target_stats.is_empty():
		return 1.0

	var weights_data := ctx.character_data.build.stat_priority_weights
	var total: float  = 0.0

	for stat_id: StringName in training.target_stats:
		# stat_priority_weights va de 0.0 a 1.0
		# Transformamos a rango 0.5–1.5 para que peso 0 no elimine la acción
		var priority: float = weights_data.get(stat_id, 0.5)
		total += 0.5 + priority

	return total / training.target_stats.size()
