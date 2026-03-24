# res://data/consequences/ModifyStatConsequence.gd
# Modifica un stat base del personaje (positivo o negativo).
class_name ModifyStatConsequence
extends CheckpointConsequence

@export var stat_id: StringName = &""
@export var delta: float        = 0.0
@export var min_value: float    = 1.0  # Evita que el stat llegue a 0

func apply(data: CharacterData) -> Dictionary:
	assert(stat_id != &"", "ModifyStatConsequence: stat_id no puede estar vacío.")
	assert(delta != 0.0,   "ModifyStatConsequence: delta es 0, no tiene efecto.")
	var current: float = data.base_stats.get(stat_id, 0.0)
	var new_val: float = maxf(min_value, current + delta)
	data.base_stats[stat_id] = new_val
	EventBus.player_stats_changed.emit(stat_id, new_val)
	return { stat_id: delta }

func describe() -> String:
	var sign := "+" if delta >= 0.0 else ""
	return "%s%s a '%s'" % [sign, delta, stat_id]
