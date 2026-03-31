# res://data/characters/actions/DayAction.gd
#
# Clase base de todas las acciones del loop de 100 días.
# No contiene lógica de gameplay — solo define la interfaz y los campos comunes.
#
# SISTEMA DE CONDICIONES:
#   El campo legacy `unlock_day` y `requires_unlock_flag` siguen funcionando.
#   El nuevo array `conditions` añade condiciones adicionales evaluadas con AND.
#   Esto permite migrar gradualmente sin romper los .tres existentes.
#
#   Ejemplo de acción con condición compuesta:
#     unlock_day = 25
#     conditions = [
#       FLAG_SET  "survived_raditz",
#       STAT_MIN  "velocidad" >= 30.0
#     ]
#   → se desbloquea en día 25+ Y tiene el flag Y tiene velocidad >= 30

class_name DayAction
extends Resource

@export var id:            StringName = &""
@export var display_name:  String     = ""
@export var action_type:   StringName = &"generic"

## Legacy — se preserva para compatibilidad con .tres existentes.
## Equivalente a agregar una condición DAY_MIN con este valor.
@export var unlock_day:            int        = 1

## FIX A4: Día en el que esta acción deja de estar disponible.
## 0 = nunca expira (comportamiento por defecto, compatible con .tres existentes).
## Permite crear "ventanas de oportunidad": acciones disponibles solo entre días X e Y.
## Ejemplo: expires_on_day = 60 hace que la acción desaparezca a partir del día 60.
@export var expires_on_day:        int        = 0

## Legacy — se preserva para compatibilidad con .tres existentes.
## Equivalente a agregar una condición FLAG_SET con este flag_id.
@export var requires_unlock_flag:  StringName = &""

## Peso base de aparición en el selector de acciones.
## El ActionSelector lo multiplica por modificadores de build y flags.
@export var selection_weight: float = 1.0

## Condiciones adicionales evaluadas con AND.
## Todas deben ser verdaderas para que la acción esté disponible.
## Se usan junto con unlock_day / requires_unlock_flag — no los reemplazan.
@export var conditions: Array[ActionCondition] = []

# ─────────────────────────────────────────────────────────────────────────────
# API pública
# ─────────────────────────────────────────────────────────────────────────────

## Retorna true si la acción está disponible en el contexto dado.
## Evalúa unlock_day, requires_unlock_flag Y todas las condiciones del array.
func is_available(ctx: DayContext) -> bool:
	# Check legacy unlock_day
	if ctx.day_number < unlock_day:
		return false

	# FIX A4: Check de expiración.
	# Si expires_on_day > 0 y el día actual ya lo alcanzó, la acción no está disponible.
	# El 0 por defecto garantiza compatibilidad total con .tres existentes que no definen este campo.
	if expires_on_day > 0 and ctx.day_number >= expires_on_day:
		return false

	# Check legacy requires_unlock_flag
	if requires_unlock_flag != &"":
		if not ctx.character_data.saved_flags.get(requires_unlock_flag, false):
			return false

	# Check condiciones adicionales (AND implícito)
	for cond: ActionCondition in conditions:
		if not cond.evaluate(ctx):
			return false

	return true

## Descripción corta para UI — override en subclases si hace falta.
func get_description() -> String:
	return display_name

## Ejecuta la acción y retorna el resultado.
## Debe ser sobreescrito por cada subclase.
func execute(_ctx: DayContext) -> DayActionResult:
	push_error("DayAction.execute() no implementado en '%s'" % id)
	return DayActionResult.new()
