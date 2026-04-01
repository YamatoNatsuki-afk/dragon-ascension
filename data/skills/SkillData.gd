# res://data/skills/SkillData.gd
# Resource de solo datos. Define una habilidad de combate equipable.
# Un .tres por habilidad, en data/skills/
#
# DISEÑO:
#   SkillData define QUÉ ES la habilidad y sus parámetros.
#   La EJECUCIÓN real en combate (hitbox, animación, efectos) vive en
#   el sistema de combate (Fase D) — SkillData solo provee los números.
#   Esta separación permite iterar el balance sin tocar el código de combate.
#
class_name SkillData
extends Resource

## Tipos de habilidad — determinan el slot y el estilo de uso.
## Igual que Xenoverse: Strike (cuerpo a cuerpo), Ki Blast (proyectil),
## Support (buff/heal), Ultimate (habilidad especial de alto costo).
enum SkillType {
	STRIKE,     # Ataque físico mejorado — bajo costo de Ki, alto daño físico
	KI_BLAST,   # Proyectil de energía — costo medio de Ki, daño mágico
	SUPPORT,    # Buff/curación — no hace daño directamente
	ULTIMATE,   # Habilidad definitiva — alto costo, alto impacto
}

## Identificador único. Debe coincidir con el nombre del archivo .tres.
## Ejemplo: &"kamehameha", &"masenko", &"wild_sense"
@export var id: StringName = &""

## Nombre visible en la UI.
@export var display_name: String = ""

## Descripción de la habilidad para el tooltip.
@export_multiline var description: String = ""

## Tipo de habilidad — determina en qué slot puede equiparse y cómo la usa el combate.
@export var skill_type: SkillType = SkillType.STRIKE

# ─────────────────────────────────────────────────────────────────────────────
# PARÁMETROS DE COMBATE
# Estos valores los lee el sistema de combate en Fase D.
# El diseñador los ajusta en el inspector sin tocar código.
# ─────────────────────────────────────────────────────────────────────────────

## Costo de Ki para activar la habilidad.
## 0.0 = no consume Ki (ataques físicos básicos mejorados).
@export var ki_cost: float = 0.0

## Multiplicador de daño sobre el stat base correspondiente.
## Para STRIKE: multiplica sobre strength.
## Para KI_BLAST: multiplica sobre ki_max (como proxy de poder ki).
## Para SUPPORT: irrelevante (usar effect_value).
## Para ULTIMATE: multiplica sobre el mayor stat del personaje.
@export var damage_multiplier: float = 1.0

## Valor del efecto para habilidades SUPPORT.
## Ejemplo: heal = 30.0, defense_buff = 10.0.
## Ignorado por STRIKE / KI_BLAST / ULTIMATE.
@export var effect_value: float = 0.0

## Cooldown en segundos. 0.0 = sin cooldown.
@export var cooldown: float = 0.0

## Número de hits que componen la habilidad.
## El daño total se distribuye entre los hits.
@export var hit_count: int = 1

## Alcance de la habilidad. True = puede usarse a distancia.
@export var is_ranged: bool = false

# ─────────────────────────────────────────────────────────────────────────────
# EFECTOS ESPECIALES
# Propiedades opcionales para habilidades con efectos que van más allá
# del daño/buff estándar. El sistema de combate los lee y aplica en orden.
# ─────────────────────────────────────────────────────────────────────────────

## Nivel de negación de regeneración. Determina hasta qué tier de Regeneración
## o Inmortalidad puede negar esta habilidad.
## 0 = ninguna   1 = Baja-Baja   2 = Baja   3 = Baja-Alta
## 4 = Media-Baja 5 = Media       6 = Media-Alta
## 7 = Alta       8 = Alta-Alta   9 = Perfecta (solo Hakai)
@export_range(0, 9) var regen_negation_tier: int = 0

## Probabilidad de incapacitar (KO o aturdimiento prolongado) al objetivo
## mediante puntos de presión o técnicas de aturdimiento neurológico.
## 0.0 = sin efecto   1.0 = garantizado.
## El sistema compara contra resistencia_neurológica del objetivo.
@export_range(0.0, 1.0, 0.05) var pressure_point_chance: float = 0.0

## Duración del estado de incapacitación por puntos de presión (segundos).
## 0.0 = KO completo (termina el combate si el objetivo no tiene resistencia especial).
@export var pressure_point_duration: float = 0.0

## Estado de control que aplica esta habilidad al impactar.
## "" = ninguno. Valores posibles: "blind", "stagger", "freeze",
## "paralysis", "fear", "confuse", "silence_ki".
@export var applies_status: String = ""

## Duración del estado de control aplicado (segundos). 0.0 = instantáneo.
@export var status_duration: float = 0.0

## Tags de categoría de efecto para interacciones del sistema (resistencias,
## inmunidades, sinergias). Usar StringName para eficiencia.
## Ejemplos: &"light", &"vibration", &"ki_detection", &"fire", &"ice",
##           &"poison", &"gravity", &"piercing", &"mental", &"sound"
@export var effect_tags: Array[StringName] = []

## Si true, el daño de esta habilidad ignora escudos de Ki (barreras).
## Útil para golpes concentrados de Ki, ataques vibratorios internos, etc.
@export var bypasses_ki_shield: bool = false

## Si true, el daño de esta habilidad ignora la reducción de Resistencia física.
## Reservado para ataques que actúan a nivel molecular/atómico (Zero Absoluto,
## Gravedad extrema, vibraciones internas).
@export var bypasses_physical_resistance: bool = false

# ─────────────────────────────────────────────────────────────────────────────
# REQUISITOS DE DESBLOQUEO
# En Fase D estos se validan contra CharacterData antes de mostrar la habilidad.
# ─────────────────────────────────────────────────────────────────────────────

## Stat mínimo requerido para poder equipar la habilidad.
## {} = sin requisito.
## Ejemplo: { &"ki_max": 100.0 } — necesitás 100 de Ki para equipar Kamehameha.
@export var required_stats: Dictionary = {}

## Día mínimo del run para que la habilidad esté disponible.
## 0 = disponible desde el día 1.
@export var unlock_day: int = 0

# ─────────────────────────────────────────────────────────────────────────────
# VISUAL / UX
# ─────────────────────────────────────────────────────────────────────────────

## Identificador del icono para la UI (placeholder hasta tener assets).
@export var icon_id: StringName = &""

## Color representativo de la habilidad (para el marco del icono en la UI).
@export var skill_color: Color = Color.WHITE

# ─────────────────────────────────────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────────────────────────────────────

## Retorna el nombre del tipo de habilidad como string legible.
func get_type_name() -> String:
	match skill_type:
		SkillType.STRIKE:   return "Combate"
		SkillType.KI_BLAST: return "Ki"
		SkillType.SUPPORT:  return "Soporte"
		SkillType.ULTIMATE: return "Definitiva"
	return ""

## Retorna true si esta habilidad tiene el tag especificado.
func has_tag(tag: StringName) -> bool:
	return tag in effect_tags

## Retorna true si la habilidad puede negar la regeneración del tier dado.
## Usar las constantes RegenTier.LOW_LOW .. RegenTier.PERFECT para claridad.
func negates_regen(target_regen_tier: int) -> bool:
	return regen_negation_tier >= target_regen_tier

## Retorna true si el personaje tiene los stats necesarios para equipar la habilidad.
func can_equip(data: CharacterData) -> bool:
	for stat_id: Variant in required_stats.keys():
		var required: float = required_stats[stat_id]
		var current: float  = data.base_stats.get(stat_id, 0.0)
		if current < required:
			return false
	if unlock_day > 0 and data.current_day < unlock_day:
		return false
	return true
