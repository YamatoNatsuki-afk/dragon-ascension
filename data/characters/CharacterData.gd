# res://data/characters/CharacterData.gd
# Snapshot completo y serializable del personaje.
# Compone los Resources de estado. Nunca contiene lógica de juego.
#
# SUB-RESOURCES:
#   appearance    — colores, escala, aura (visual puro)
#   build         — pesos de prioridad de entrenamiento (intención del jugador)
#   equipment     — ítems equipados por slot (bonos de stats en combate)
#   skill_loadout — 4 habilidades activas equipadas (usadas en combate)
#
class_name CharacterData
extends Resource

@export var character_name: String = "Unnamed"
@export var race_id: StringName    = &"human"

# Stats base ANTES de aplicar multiplicadores de raza.
# CharacterFactory se encarga de aplicarlos al crear el personaje.
# DayManager es el único sistema que escribe aquí — nadie más.
@export var base_stats: Dictionary = {
	&"health_max": 100.0,
	&"ki_max":     50.0,
	&"strength":   10.0,
	&"speed":      10.0,
	&"defense":    10.0,
}

# ── Sub-resources ──────────────────────────────────────────────────────────────

## Apariencia visual. No afecta gameplay.
@export var appearance: AppearanceData

## Pesos de prioridad de entrenamiento e intención de build.
@export var build: BuildData

## [C1] Ítems equipados por slot. Bonos aplicados como modificadores
## persistentes por StatsComponent al entrar en combate (C2).
## null = ningún ítem equipado todavía.
@export var equipment: Resource  # EquipmentData

## [C1] Habilidades activas equipadas (máximo 4, una por tipo).
## El sistema de combate (Fase D) las lee para ejecutarlas.
## null = sin habilidades equipadas todavía.
@export var skill_loadout: Resource  # SkillLoadout

# ── Progresión ─────────────────────────────────────────────────────────────────

@export var current_day: int  = 1
@export var experience: float = 0.0

# ── Flags persistentes ────────────────────────────────────────────────────────
# Almacén de serialización de FlagSystem.
# SaveSystem escribe aquí antes de guardar → ResourceSaver lo persiste en el .tres.
# SaveSystem lee aquí al cargar → FlagSystem.deserialize() restaura el estado.
#
# NUNCA modificar este campo directamente desde lógica de juego.
# Solo SaveSystem lo toca — todos los demás usan FlagSystem.set_flag() / has().
@export var saved_flags: Dictionary = {}

# ─────────────────────────────────────────────────────────────────────────────
# HELPERS DE ACCESO SEGURO
#
# Garantizan que equipment y skill_loadout nunca sean null al leerlos.
# CharacterFactory los inicializa al crear el personaje, pero saves
# antiguos o personajes creados a mano pueden no tenerlos.
# ─────────────────────────────────────────────────────────────────────────────

## Retorna el EquipmentData del personaje.
## Si no existe, lo crea vacío — lazy init para compatibilidad con saves anteriores.
func get_equipment():  # → EquipmentData
	if equipment == null:
		equipment = load("res://data/equipment/EquipmentData.gd").new()
	return equipment

## Retorna el SkillLoadout del personaje.
## Si no existe, lo crea vacío — lazy init para compatibilidad con saves viejos.
func get_skill_loadout():  # → SkillLoadout
	if skill_loadout == null:
		skill_loadout = load("res://data/skills/SkillLoadout.gd").new()
	return skill_loadout
