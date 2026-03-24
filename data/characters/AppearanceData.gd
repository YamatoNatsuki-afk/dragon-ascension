# data/characters/AppearanceData.gd
# Datos visuales PUROS. No afectan gameplay.
# Separado de CharacterData para que cambios de arte no toquen stats.
class_name AppearanceData
extends Resource

# Colores del personaje
@export var primary_color: Color   = Color(0.2, 0.2, 0.2)   # Pelo/traje principal
@export var secondary_color: Color = Color(0.8, 0.7, 0.6)   # Piel / acento
@export var eye_color: Color       = Color(0.1, 0.4, 0.9)

# Escala del personaje (1.0 = base). Permite razas más altas/bajas.
@export var body_scale: float = 1.0

# Preparado para Fase 4 (transformaciones y auras)
@export var aura_color: Color      = Color(0.2, 0.6, 1.0)
@export var aura_intensity: float  = 0.0   # 0 = sin aura, 1 = aura máxima
