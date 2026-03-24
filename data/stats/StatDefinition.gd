# data/stats/StatDefinition.gd
# Define QUÉ es un stat: su nombre, valor base, mínimo y máximo.
# No contiene lógica de cálculo — solo datos.
class_name StatDefinition
extends Resource

@export var id: StringName          # Identificador único: &"strength", &"ki_max"
@export var display_name: String    # Nombre visible en UI: "Fuerza"
@export var base_value: float = 10.0
@export var min_value: float = 0.0
@export var max_value: float = 9999.0
@export var description: String = ""
