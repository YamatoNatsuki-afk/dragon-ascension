# data/actions/base/DayActionResult.gd
# Resultado tipado de una acción. DayManager lee esto — nunca el estado interno.
# Immutable por convención: se llena en execute() y no se toca después.
class_name DayActionResult
extends RefCounted

var success: bool      = true
var narrative_key: String = ""    # Clave para UI/localización. Ej: "training.strength.success"

# Cambios de stats producidos. stat_id → delta aplicado.
# StatsComponent los aplica al escuchar el EventBus.
var stat_changes: Dictionary = {}

var xp_gained: float   = 0.0

# Datos extra para efectos especiales futuros (transformaciones, objetos, etc.)
var extra_data: Dictionary = {}
