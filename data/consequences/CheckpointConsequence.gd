# res://data/consequences/CheckpointConsequence.gd
# Resource BASE abstracto. Cada subclase está en su PROPIO archivo.
# Godot 4 solo permite UN class_name por archivo — nunca apilar clases aquí.
#
# Contrato: apply(data) muta CharacterData y devuelve un dict de cambios
# para que CheckpointResult pueda reportarlos en el log/UI.
class_name CheckpointConsequence
extends Resource

@export var description: String = ""

## Aplica la consecuencia al personaje.
## Devuelve Dictionary { stat_id: delta } para logging en CheckpointResult.
func apply(data: CharacterData) -> Dictionary:
	push_error("CheckpointConsequence.apply(): no implementado en '%s'." % resource_path)
	return {}

## Descripción legible. Override en subclases para mensajes precisos.
func describe() -> String:
	return description if description != "" else "(consecuencia sin descripción)"
