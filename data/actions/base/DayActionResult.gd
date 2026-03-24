# res://data/actions/base/DayActionResult.gd
# Resultado tipado de una acción. DayManager lo lee — nunca el estado interno.
# Immutable por convención: se llena en execute() y no se modifica después.
# ARCHIVO CANÓNICO — eliminar: res://data/characters/actions/DayActionResult.gd
class_name DayActionResult
extends RefCounted

var success: bool             = true
var narrative_key: String     = ""   # Clave para UI/loc. Ej: "training.strength.success"
var action_type: StringName   = &""  # &"training", &"event", &"combat" — para filtros de UI

# Cambios de stats producidos. stat_id → delta aplicado.
# StatsComponent los aplica al escuchar EventBus.day_action_resolved.
var stat_changes: Dictionary  = {}

var xp_gained: float          = 0.0

# Datos extra para efectos especiales futuros (transformaciones, objetos, etc.)
var extra_data: Dictionary    = {}
