# res://data/skills/SkillLoadout.gd
# Sub-resource de CharacterData. Registra las habilidades equipadas actualmente.
#
# DISEÑO — Por qué 4 slots fijos (igual que Xenoverse):
#   Limitar a 4 habilidades equipadas crea decisiones significativas.
#   El jugador puede desbloquear muchas habilidades, pero solo lleva 4
#   al combate — eso define el estilo de pelea en cada run.
#
# SLOTS:
#   0 — Strike   (ataque físico)
#   1 — Ki Blast (proyectil)
#   2 — Support  (buff/heal)
#   3 — Ultimate (definitiva)
#   Cada slot acepta solo habilidades de su tipo correspondiente.
#
class_name SkillLoadout
extends Resource

const SLOT_COUNT := 4

# Array de exactamente 4 elementos. null = slot vacío.
# Índice 0 = Strike, 1 = Ki Blast, 2 = Support, 3 = Ultimate.
# Se inicializa con nulls explícitos para que la serialización funcione.
@export var _slots: Array[SkillData] = [null, null, null, null]

# Mapa de tipo → índice de slot para validación rápida.
const TYPE_TO_SLOT: Dictionary = {
	SkillData.SkillType.STRIKE:   0,
	SkillData.SkillType.KI_BLAST: 1,
	SkillData.SkillType.SUPPORT:  2,
	SkillData.SkillType.ULTIMATE: 3,
}

# ─────────────────────────────────────────────────────────────────────────────
# API PÚBLICA
# ─────────────────────────────────────────────────────────────────────────────

## Equipa una habilidad en el slot correspondiente a su tipo.
## Si había otra habilidad en ese slot, la reemplaza y la retorna.
## Retorna null si el slot estaba vacío.
##
## Retorna ERR si la habilidad no cumple los requisitos del personaje.
## Usar can_equip() antes de llamar esto desde la UI para dar feedback claro.
func equip(skill: SkillData, data: CharacterData) -> SkillData:
	assert(skill != null, "SkillLoadout.equip: skill es null.")
	assert(skill.id != &"", "SkillLoadout.equip: skill sin id.")
	assert(data != null,  "SkillLoadout.equip: CharacterData es null.")

	if not skill.can_equip(data):
		push_warning("SkillLoadout.equip: '%s' no cumple requisitos para equipar '%s'." % [
			data.character_name, str(skill.id)
		])
		return null

	var slot_index := _slot_index_for(skill.skill_type)
	var previous: SkillData = _slots[slot_index]
	_slots[slot_index] = skill
	return previous

## Desequipa la habilidad del slot del tipo indicado.
## Retorna la habilidad que había, o null si estaba vacío.
func unequip(skill_type: SkillData.SkillType) -> SkillData:
	var slot_index := _slot_index_for(skill_type)
	var previous: SkillData = _slots[slot_index]
	_slots[slot_index] = null
	return previous

## Retorna la habilidad equipada para el tipo dado, o null si está vacío.
func get_skill(skill_type: SkillData.SkillType) -> SkillData:
	return _slots[_slot_index_for(skill_type)]

## Retorna la habilidad equipada en el índice de slot (0–3).
## Útil para iterar todos los slots en orden en la UI.
func get_skill_at(slot_index: int) -> SkillData:
	assert(slot_index >= 0 and slot_index < SLOT_COUNT,
		"SkillLoadout.get_skill_at: índice fuera de rango [0, %d]." % (SLOT_COUNT - 1))
	return _slots[slot_index]

## Retorna true si el slot del tipo dado está ocupado.
func has_skill(skill_type: SkillData.SkillType) -> bool:
	return _slots[_slot_index_for(skill_type)] != null

## Retorna todas las habilidades equipadas (sin nulls).
func get_all_equipped() -> Array[SkillData]:
	var result: Array[SkillData] = []
	for skill: SkillData in _slots:
		if skill != null:
			result.append(skill)
	return result

## Retorna cuántos slots están ocupados.
func equipped_count() -> int:
	var count := 0
	for skill: SkillData in _slots:
		if skill != null:
			count += 1
	return count

## Retorna true si ningún slot tiene habilidad equipada.
func is_empty() -> bool:
	for skill: SkillData in _slots:
		if skill != null:
			return false
	return true

## Nombre del slot por índice — para la UI.
static func slot_name(slot_index: int) -> String:
	match slot_index:
		0: return "Combate"
		1: return "Ki"
		2: return "Soporte"
		3: return "Definitiva"
	return ""

# ─────────────────────────────────────────────────────────────────────────────
# PRIVADO
# ─────────────────────────────────────────────────────────────────────────────

func _slot_index_for(skill_type: SkillData.SkillType) -> int:
	return TYPE_TO_SLOT.get(int(skill_type), 0)
