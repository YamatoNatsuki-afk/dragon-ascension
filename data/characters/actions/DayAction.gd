# data/actions/base/DayAction.gd
# Resource base. Cada tipo de acción hereda de aquí.
# Dos contratos que toda acción debe cumplir:
#   1. is_available(ctx) → ¿puede el jugador elegir esta acción hoy?
#   2. execute(ctx)      → produce un DayActionResult, nada más.
class_name DayAction
extends Resource

@export var id: StringName          # &"train_strength", &"ki_meditation"
@export var display_name: String    # "Entrenamiento de fuerza"
@export var description: String
@export var action_type: StringName = &"generic"  # &"training", &"event", &"combat"

# Día mínimo requerido para que esta acción esté disponible.
# Permite desbloquear acciones con el progreso.
@export var unlock_day: int = 1

## ¿Puede el jugador elegir esta acción dado el contexto actual?
## Override en subclases para condiciones más complejas.
func is_available(ctx: DayContext) -> bool:
	return ctx.day_number >= unlock_day

## Ejecuta la acción y devuelve su resultado.
## NUNCA modifica CharacterData directamente — todo va al Result.
func execute(_ctx: DayContext) -> DayActionResult:
	push_error("DayAction '%s': execute() no implementado." % id)
	return DayActionResult.new()
