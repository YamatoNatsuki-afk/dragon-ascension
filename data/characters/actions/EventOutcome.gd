# data/actions/base/EventOutcome.gd
# Resource inline — se define dentro del .tres del EventAction.
# No necesita su propio archivo en disco.
class_name EventOutcome
extends Resource

@export var narrative_key: String = ""      # "event.rival.defeated"
@export var weight: float         = 1.0     # Peso relativo de probabilidad
@export var stat_changes: Dictionary = {}   # stat_id → delta (puede ser negativo)
@export var xp_gained: float      = 0.0
@export var extra_data: Dictionary = {}     # Para efectos especiales futuros
