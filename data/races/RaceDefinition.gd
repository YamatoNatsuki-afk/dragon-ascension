# res://data/races/RaceDefinition.gd
#
# Resource ESTÁTICO. Lo crea el diseñador en el editor.
# Nunca se modifica en runtime — es de solo lectura.
#
# MIGRACIÓN v2: stat_multipliers actualizado a los 8 IDs canónicos.
# IDs eliminados: health_max, ki_max, strength, speed, defense.

class_name RaceDefinition
extends Resource

@export var id:           StringName = &""
@export var display_name: String     = ""
@export var description:  String     = ""

# ─────────────────────────────────────────────────────────
# Multiplicadores de stats
# ─────────────────────────────────────────────────────────
# 1.0 = neutro | 1.2 = +20% | 0.8 = -20%
#
# Usar multiplicadores (no valores planos) garantiza que el balance
# escale correctamente cuando el jugador suba de nivel.
#
# TODOS los 8 IDs deben estar presentes. Si falta alguno,
# CharacterFactory.gd aplica 1.0 por defecto y lanza un warning.

@export var stat_multipliers: Dictionary = {
	&"fuerza":        1.0,
	&"velocidad":     1.0,
	&"ki":            1.0,
	&"vitalidad":     1.0,
	&"resistencia":   1.0,
	&"poder_ki":      1.0,
	&"inteligencia":  1.0,
	&"intel_combate": 1.0,
}

# Rasgos raciales: StringNames de habilidades/pasivas futuras.
# La lógica NO vive aquí — solo declaramos qué tiene la raza.
@export var racial_traits: Array[StringName] = []

# Modificador de XP: afecta la velocidad de aprendizaje de la raza.
# Humanos aprenden más rápido (1.3), Saiyajin más lento (0.9).
@export var xp_multiplier: float = 1.0

# Color de aura por defecto (preparado para sistema visual Fase 4)
@export var default_aura_color: Color = Color.WHITE
