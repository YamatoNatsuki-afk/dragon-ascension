# res://data/consequences/SetFlagConsequence.gd
# Establece un flag en FlagSystem. Otros sistemas reaccionan a ese flag.
class_name SetFlagConsequence
extends CheckpointConsequence

@export var flag_id: StringName       = &""
@export var flag_value: bool          = true
## Valor alternativo String para flags no-booleanos ("elite", "arc_2", etc.)
@export var flag_value_string: String = ""

func apply(_data) -> Dictionary:  # _data: CharacterData
	assert(flag_id != &"", "SetFlagConsequence: flag_id no puede estar vacío.")
	var value: Variant = flag_value_string if flag_value_string != "" else flag_value
	FlagSystem.set_flag(flag_id, value)
	return { "flag_set": flag_id }

func describe() -> String:
	var val: String = flag_value_string if flag_value_string != "" else str(flag_value)
	return "Flag '%s' = %s" % [flag_id, val]
