# data/races/RaceDefinition.gd
# Resource ESTÁTICO. Lo crea el diseñador en el editor.
# Nunca se modifica en runtime — es de solo lectura.
class_name RaceDefinition
extends Resource

@export var id: StringName                   # &"saiyan", &"human", etc.
@export var display_name: String             # "Saiyajin"
@export var description: String

# Multiplicadores sobre stats base. 1.0 = neutro, 1.2 = +20%, 0.8 = -20%
# Usar multiplicadores (no valores planos) garantiza que el balance
# escale correctamente cuando el jugador suba de nivel.
@export var stat_multipliers: Dictionary = {
	&"health_max": 1.0,
	&"ki_max":     1.0,
	&"strength":   1.0,
	&"speed":      1.0,
	&"defense":    1.0,
}

# Rasgos raciales: referencias a StringNames de habilidades futuras.
# No implementamos la lógica aquí — solo declaramos qué tiene la raza.
@export var racial_traits: Array[StringName] = []

# Modificador de XP: los humanos aprenden más rápido, los Saiyajin más lento
@export var xp_multiplier: float = 1.0

# Color de aura por defecto para esta raza (preparado para Fase 4)
@export var default_aura_color: Color = Color.WHITE
