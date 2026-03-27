# res://data/consequences/UnlockActionConsequence.gd
# Desbloquea una acción que requería un flag específico para estar disponible.
# ActionRegistry.get_available() la incluirá a partir del siguiente día.
class_name UnlockActionConsequence
extends CheckpointConsequence

@export var action_id: StringName = &""

func apply(_data) -> Dictionary:  # _data: CharacterData
	assert(action_id != &"", "UnlockActionConsequence: action_id no puede estar vacío.")
	FlagSystem.set_flag(_unlock_flag(action_id), true)
	EventBus.action_unlocked.emit(action_id)
	return { "action_unlocked": action_id }

func describe() -> String:
	return "Desbloquea acción '%s'" % action_id

## Convención de nombre de flag: "unlocked:{action_id}"
## ActionRegistry y esta clase comparten la misma convención.
static func _unlock_flag(id: StringName) -> StringName:
	return ("unlocked:" + str(id)) as StringName

## Utilidad que ActionRegistry usa para comprobar si una acción está desbloqueada.
static func is_unlocked(action_id: StringName) -> bool:
	return FlagSystem.has(_unlock_flag(action_id))
