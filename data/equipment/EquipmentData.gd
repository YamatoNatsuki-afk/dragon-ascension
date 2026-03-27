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
