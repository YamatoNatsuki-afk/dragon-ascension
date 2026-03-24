# data/actions/base/DayAction.gd
# Resource base para todas las acciones del día.
# Cada subclase implementa execute() y opcionalmente is_available().
class_name DayAction
extends Resource

@export var id: StringName
@export var display_name: String
@export var description: String
@export var action_type: StringName = &"generic"
@export var unlock_day: int = 1
@export var requires_unlock_flag: StringName = &""

# Peso BASE de selección. El ActionSelector lo usa como punto de partida
# antes de aplicar modificadores por build. Rango sugerido: 0.5 – 3.0.
# 0.0 = nunca se elige por el selector automático (pero sí aparece en lista).
@export var selection_weight: float = 1.0

func is_available(ctx: DayContext) -> bool:
	return ctx.day_number >= unlock_day

func execute(_ctx: DayContext) -> DayActionResult:
	push_error("DayAction '%s': execute() no implementado." % id)
	return DayActionResult.new()
