# res://data/consequences/ModifySelectionWeightConsequence.gd
# Modifica el peso de selección de una acción por N días.
# ActionSelector lee estos modificadores desde FlagSystem vía get_active_multiplier().
class_name ModifySelectionWeightConsequence
extends CheckpointConsequence

@export var action_id: StringName    = &""
@export var weight_multiplier: float = 2.0  # 2.0 = doble probable, 0.5 = mitad
@export var duration_days: int       = 5

func apply(data) -> Dictionary:  # data: CharacterData
	assert(action_id != &"",        "ModifySelectionWeightConsequence: action_id vacío.")
	assert(weight_multiplier > 0.0, "ModifySelectionWeightConsequence: multiplicador debe ser > 0.")
	var expiry_day: int = data.current_day + duration_days
	var key := ("weight_mod:%s" % action_id) as StringName
	FlagSystem.set_flag(key, "%s:%d" % [weight_multiplier, expiry_day])
	return { "weight_modified": action_id, "multiplier": weight_multiplier }

func describe() -> String:
	return "Peso x%.1f para '%s' por %d días" % [weight_multiplier, action_id, duration_days]

## Obtiene el multiplicador activo para una acción en el día dado.
## Devuelve 1.0 si no hay modificador activo o expiró.
static func get_active_multiplier(action_id: StringName, current_day: int) -> float:
	var key   := ("weight_mod:%s" % action_id) as StringName
	var raw   := str(FlagSystem.get_value(key, ""))
	if raw == "":
		return 1.0
	var parts := raw.split(":")
	if parts.size() < 2:
		return 1.0
	var expiry := int(parts[1])
	return float(parts[0]) if current_day <= expiry else 1.0
