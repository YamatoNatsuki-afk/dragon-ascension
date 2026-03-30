# res://data/npcs/NpcRelationState.gd
#
# Resource que guarda el estado de relación con todos los NPCs.
# Se serializa dentro de CharacterData — SaveSystem lo persiste.
#
# relations: Dictionary[StringName, int]
#   clave = npc_id, valor = RelationState (0–4)
#
# interaction_counts: Dictionary[StringName, int]
#   cuántas veces se ha entrenado con cada NPC

class_name NpcRelationState
extends Resource

@export var relations: Dictionary = {}
@export var interaction_counts: Dictionary = {}

# ─────────────────────────────────────────────────────────────────────────────
# API
# ─────────────────────────────────────────────────────────────────────────────

func get_relation(npc_id: StringName) -> int:
	return int(relations.get(npc_id, 0))

func set_relation(npc_id: StringName, state: int) -> void:
	relations[npc_id] = clampi(state, 0, 4)

func advance_relation(npc_id: StringName) -> bool:
	var current: int = get_relation(npc_id)
	if current >= 4:
		return false
	relations[npc_id] = current + 1
	return true

func is_ally(npc_id: StringName) -> bool:
	return get_relation(npc_id) >= 3

func is_master(npc_id: StringName) -> bool:
	return get_relation(npc_id) >= 4

func register_interaction(npc_id: StringName) -> int:
	var count: int = int(interaction_counts.get(npc_id, 0)) + 1
	interaction_counts[npc_id] = count
	return count

func get_interaction_count(npc_id: StringName) -> int:
	return int(interaction_counts.get(npc_id, 0))

func get_relation_label(npc_id: StringName) -> String:
	match get_relation(npc_id):
		0: return "Desconocido"
		1: return "Conocido"
		2: return "Amistoso"
		3: return "Aliado"
		4: return "Maestro"
	return "?"
