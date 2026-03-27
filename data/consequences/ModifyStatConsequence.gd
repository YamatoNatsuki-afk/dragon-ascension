# data/consequences/ModifyStatConsequence.gd
# Consecuencia de checkpoint que modifica un stat base permanentemente.
#
# [B2 FIX] min_value eliminado como @export propio.
# StatRegistry.clamp_stat() es ahora la única fuente de límites —
# unifica el comportamiento con DayManager._resolve() y el sistema de combate.
# Si necesitás ajustar el mínimo de un stat, editá su .tres en
# data/stats/definitions/ — el cambio se propaga a todo el juego.
#
class_name ModifyStatConsequence
extends CheckpointConsequence

@export var stat_id: StringName = &""
@export var delta: float        = 0.0

func apply(data: CharacterData) -> Dictionary:
	assert(stat_id != &"",
		"ModifyStatConsequence: stat_id no puede estar vacío.")
	assert(delta != 0.0,
		"ModifyStatConsequence: delta es 0.0, la consecuencia no tiene efecto.")
	assert(StatRegistry.has_stat(stat_id),
		"ModifyStatConsequence: stat '%s' no está registrado en StatRegistry." % str(stat_id))

	var current: float = data.base_stats.get(stat_id, 0.0)

	# [B2 FIX] Reemplaza: maxf(min_value, current + delta)
	# StatRegistry aplica tanto el mínimo como el máximo del stat.
	var new_val: float = StatRegistry.clamp_stat(stat_id, current + delta)

	data.base_stats[stat_id] = new_val
	EventBus.player_stats_changed.emit(stat_id, new_val)

	return { stat_id: delta }
