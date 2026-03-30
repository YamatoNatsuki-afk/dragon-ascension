# res://data/transformations/TransformationState.gd
#
# Resource que guarda el estado de transformaciones de UN personaje.
# Se serializa dentro de CharacterData — SaveSystem lo persiste automáticamente.
#
# ESTADO POR TRANSFORMACIÓN:
#   unlocked_ids  → Array[StringName] de IDs desbloqueadas
#   mastery       → Dictionary[StringName, float] maestría 0.0–1.0 por transformación
#
# ESTADO DE COMBATE (no se persiste, solo durante combate):
#   active_transform_id → qué transformación está activa ahora mismo

class_name TransformationState
extends Resource

## IDs de transformaciones desbloqueadas.
@export var unlocked_ids: Array[StringName] = []

## Maestría por transformación. Clave = id, Valor = float 0.0–1.0.
## Una transformación puede estar desbloqueada con maestría 0.0.
@export var mastery: Dictionary = {}

## XP de maestría acumulada por transformación (pre-normalización).
## Se convierte a mastery 0.0–1.0 internamente.
@export var mastery_xp: Dictionary = {}

# Estado de combate — NO exportado, no se guarda
var active_transform_id: StringName = &""

# ─────────────────────────────────────────────────────────────────────────────
# API
# ─────────────────────────────────────────────────────────────────────────────

func is_unlocked(transform_id: StringName) -> bool:
	return transform_id in unlocked_ids

func unlock(transform_id: StringName) -> void:
	if not is_unlocked(transform_id):
		unlocked_ids.append(transform_id)
		if not mastery.has(transform_id):
			mastery[transform_id]    = 0.0
			mastery_xp[transform_id] = 0.0

func get_mastery(transform_id: StringName) -> float:
	return float(mastery.get(transform_id, 0.0))

## Añade XP de maestría. Retorna true si subió de tramo (25%, 50%, 75%, 100%).
## max_xp = XP necesaria para maestría completa (default: 500).
func add_mastery_xp(transform_id: StringName, xp: float, max_xp: float = 500.0) -> bool:
	if not is_unlocked(transform_id):
		return false

	var prev_mastery: float = get_mastery(transform_id)
	var current_xp: float  = float(mastery_xp.get(transform_id, 0.0))
	current_xp             = minf(current_xp + xp, max_xp)
	mastery_xp[transform_id] = current_xp

	var new_mastery: float = clampf(current_xp / max_xp, 0.0, 1.0)
	mastery[transform_id]  = new_mastery

	# Detectar si cruzamos un tramo importante (25/50/75/100)
	const THRESHOLDS: Array = [0.25, 0.50, 0.75, 1.00]
	for t: float in THRESHOLDS:
		if prev_mastery < t and new_mastery >= t:
			return true
	return false

func get_mastery_label(transform_id: StringName) -> String:
	var m := get_mastery(transform_id)
	if m >= 1.0:   return "MAESTRÍA COMPLETA"
	if m >= 0.75:  return "Avanzado (%.0f%%)" % (m * 100.0)
	if m >= 0.50:  return "Intermedio (%.0f%%)" % (m * 100.0)
	if m >= 0.25:  return "Básico (%.0f%%)" % (m * 100.0)
	return "Iniciando (%.0f%%)" % (m * 100.0)

func is_transform_active() -> bool:
	return active_transform_id != &""

func activate(transform_id: StringName) -> void:
	active_transform_id = transform_id

func deactivate() -> void:
	active_transform_id = &""
