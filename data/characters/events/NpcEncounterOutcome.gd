# res://data/characters/events/NpcEncounterOutcome.gd
#
# Outcome de un evento de encuentro con NPC.
# Extiende el concepto de EventOutcome con flags_to_set.
#
# La diferencia clave vs EventOutcome estándar:
#   - Puede setear flags en saved_flags del CharacterData
#   - Tiene un campo description para mostrar en la UI antes de elegir
#   - El npc_id identifica qué NPC se "conoce" al ocurrir este outcome

class_name NpcEncounterOutcome
extends Resource

@export var narrative_key: StringName = &""

## Descripción corta para mostrar en la UI del overlay de resultado.
@export var description: String = ""

## Peso para la selección aleatoria. Mayor = más probable.
@export var weight: float = 1.0

## Stats que cambian si ocurre este outcome.
@export var stat_changes: Dictionary = {}

## XP ganada si ocurre este outcome.
@export var xp_gained: float = 0.0

## Flags que se setean a true si ocurre este outcome.
## Se aplican sobre CharacterData.saved_flags.
@export var flags_to_set: Array[StringName] = []
