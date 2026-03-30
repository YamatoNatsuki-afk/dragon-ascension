# res://core/DayActionResult.gd
#
# Resultado de ejecutar una DayAction.
# DayManager lo consume en _resolve() para aplicar cambios al CharacterData.
#
# flags_to_set (agregado en Fase C3):
#   Array de flags que DayManager seteará en saved_flags al resolver.
#   Usado principalmente por NpcEncounterAction para desbloquear maestros/eventos.

class_name DayActionResult
extends Resource

## Tipo de acción que generó este resultado.
@export var action_type: StringName = &"generic"

## Si la acción tuvo éxito o falló (afecta XP mínima, narrativa, etc).
@export var success: bool = true

## Clave narrativa para el texto de resultado (formato: "categoria.id.outcome").
@export var narrative_key: StringName = &""

## Cambios de stats a aplicar. Clave = stat_id, valor = delta (puede ser negativo).
@export var stat_changes: Dictionary = {}

## XP ganada por esta acción.
@export var xp_gained: float = 0.0

## Datos adicionales arbitrarios para uso interno de acciones específicas.
## EventAction lo usa para propagar datos del outcome al sistema de UI.
@export var extra_data: Dictionary = {}

## Flags que DayManager seteará en CharacterData.saved_flags al resolver.
## También se propagan a FlagSystem si está disponible.
@export var flags_to_set: Array[StringName] = []
