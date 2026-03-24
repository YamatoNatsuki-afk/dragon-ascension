# res://data/actions/base/DayAction.gd
# Resource base para todas las acciones del día.
# ARCHIVO CANÓNICO — el único con class_name DayAction.
# Eliminar: res://data/characters/actions/DayAction.gd
class_name DayAction
extends Resource

@export var id: StringName
@export var display_name: String
@export var description: String
@export var action_type: StringName = &"generic"
@export var unlock_day: int = 1
@export var requires_unlock_flag: StringName = &""

# Peso BASE de selección. ActionSelector lo multiplica por afinidad de build.
# 0.0 = nunca elegido automáticamente (pero visible en lista manual).
@export var selection_weight: float = 1.0

## ¿Puede el jugador elegir esta acción en el contexto actual?
## Override en subclases para condiciones más complejas.
func is_available(ctx: DayContext) -> bool:
	return ctx.day_number >= unlock_day

## Ejecuta la acción y devuelve su resultado.
## NUNCA modifica CharacterData directamente — toda mutación va en el Result.
func execute(_ctx: DayContext) -> DayActionResult:
	push_error("DayAction '%s': execute() no implementado." % id)
	return DayActionResult.new()
