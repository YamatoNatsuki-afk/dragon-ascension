# data/characters/BuildData.gd
# Preferencias de build del jugador. NO cambia stats directamente.
# Es información para otros sistemas (IA de entrenamiento, sugerencias UI).
# Un sistema de builds rígido (clase guerrero/mago) limita al jugador.
# Uno flexible con pesos permite builds híbridos naturalmente.
class_name BuildData
extends Resource

# Pesos de prioridad de stats (0.0 a 1.0). El jugador los ajusta en la creación.
# El DayManager los usa para sugerir actividades de entrenamiento relevantes.
@export var stat_priority_weights: Dictionary = {
	&"strength": 0.5,
	&"ki_max":   0.5,
	&"speed":    0.5,
	&"defense":  0.5,
}

# Estilo de combate preferido — para futuras sugerencias de habilidades
@export var combat_style: StringName = &"balanced"  # &"striker", &"ki_user", &"tank"
