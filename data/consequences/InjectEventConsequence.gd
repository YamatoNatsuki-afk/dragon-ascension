# res://data/consequences/InjectEventConsequence.gd
# Inyecta un EventAction en el pool de acciones disponibles por N días.
# ActionRegistry._inject_active_events() lo incluye automáticamente.
class_name InjectEventConsequence
extends CheckpointConsequence

@export var event_action_id: StringName = &""
@export var duration_days: int          = 3

func apply(data) -> Dictionary:  # data: CharacterData
	assert(event_action_id != &"", "InjectEventConsequence: event_action_id vacío.")
	var expiry_day: int = data.current_day + duration_days
	var key := ("injected_event:" + str(event_action_id)) as StringName
	FlagSystem.set_flag(key, expiry_day)
	return { "event_injected": event_action_id, "expires_day": expiry_day }

func describe() -> String:
	return "Inyecta evento '%s' por %d días" % [event_action_id, duration_days]

## Comprueba si un evento inyectado sigue activo para el día dado.
## ActionRegistry llama esto en _inject_active_events().
static func is_event_active(event_id: StringName, current_day: int) -> bool:
	var key    := ("injected_event:" + str(event_id)) as StringName
	var expiry: Variant = FlagSystem.get_value(key, 0)
	return current_day <= int(expiry)
