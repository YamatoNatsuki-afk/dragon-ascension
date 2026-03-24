# data/characters/CharacterData.gd
# Snapshot completo y serializable del personaje.
# Compone los tres Resources. Nunca contiene lógica de juego.
class_name CharacterData
extends Resource

@export var character_name: String = "Unnamed"
@export var race_id: StringName    = &"human"

# Stats base ANTES de aplicar multiplicadores de raza.
# CharacterFactory se encarga de aplicarlos al crear el personaje.
@export var base_stats: Dictionary = {
	&"health_max": 100.0,
	&"ki_max":     50.0,
	&"strength":   10.0,
	&"speed":      10.0,
	&"defense":    10.0,
}

# Sub-resources de apariencia y build (anidados, se guardan junto al personaje)
@export var appearance: AppearanceData
@export var build: BuildData

# Progresión — expande en Fase 3 (DayManager)
@export var current_day: int   = 1
@export var experience: float  = 0.0
