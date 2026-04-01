# res://data/equipment/EquipmentData.gd
#
# Resource del loadout de equipo del personaje.
# Almacena QUÉ EquipmentItem tiene equipado en cada slot.
#
# DISEÑO:
#   EquipmentItem define las propiedades de un ítem (inmutable).
#   EquipmentData es el inventario activo del personaje — un slot por tipo.
#   CharacterData incluye una referencia a este resource y SaveSystem lo persiste.
#
# USO:
#   var total := equipment.get_total_stat_bonus(&"fuerza")
#   StatsComponent aplica estos bonos como modificadores al inicializar.
#
class_name EquipmentData
extends Resource

# Un slot por tipo de equipo. null = slot vacío.
@export var top:       EquipmentItem = null
@export var bottom:    EquipmentItem = null
@export var gloves:    EquipmentItem = null
@export var boots:     EquipmentItem = null
@export var accessory: EquipmentItem = null

# ─────────────────────────────────────────────────────────────────────────────
# API DE SLOTS
# ─────────────────────────────────────────────────────────────────────────────

## Devuelve el ítem equipado en el slot dado. null si está vacío.
func get_item(slot: EquipmentItem.Slot) -> EquipmentItem:
	match slot:
		EquipmentItem.Slot.TOP:       return top
		EquipmentItem.Slot.BOTTOM:    return bottom
		EquipmentItem.Slot.GLOVES:    return gloves
		EquipmentItem.Slot.BOOTS:     return boots
		EquipmentItem.Slot.ACCESSORY: return accessory
	return null

## Equipa un ítem en su slot correspondiente.
## Reemplaza cualquier ítem previo en ese slot.
func equip(item: EquipmentItem) -> void:
	if item == null:
		return
	match item.slot:
		EquipmentItem.Slot.TOP:       top       = item
		EquipmentItem.Slot.BOTTOM:    bottom    = item
		EquipmentItem.Slot.GLOVES:    gloves    = item
		EquipmentItem.Slot.BOOTS:     boots     = item
		EquipmentItem.Slot.ACCESSORY: accessory = item

## Desequipa el slot dado. Lo deja en null.
func unequip(slot: EquipmentItem.Slot) -> void:
	match slot:
		EquipmentItem.Slot.TOP:       top       = null
		EquipmentItem.Slot.BOTTOM:    bottom    = null
		EquipmentItem.Slot.GLOVES:    gloves    = null
		EquipmentItem.Slot.BOOTS:     boots     = null
		EquipmentItem.Slot.ACCESSORY: accessory = null

# ─────────────────────────────────────────────────────────────────────────────
# BONOS TOTALES
# ─────────────────────────────────────────────────────────────────────────────

## Suma los bonos de todos los ítems equipados para un stat dado.
## StatsComponent llama esto en initialize_from_data() para aplicar
## los bonos de equipo como modificadores persistentes.
func get_total_stat_bonus(stat_id: StringName) -> float:
	var total: float = 0.0
	for item in get_all_equipped():
		total += item.stat_bonuses.get(stat_id, 0.0)
	return total

## Devuelve un diccionario con la suma de TODOS los bonos de equipo.
## Útil para la UI del vestidor (mostrar totales de una vez).
func get_all_bonuses() -> Dictionary:
	var result: Dictionary = {}
	for item in get_all_equipped():
		for stat_id: StringName in item.stat_bonuses.keys():
			result[stat_id] = result.get(stat_id, 0.0) + item.stat_bonuses[stat_id]
	return result

## Retorna un array con todos los ítems actualmente equipados (sin nulls).
func get_all_equipped() -> Array[EquipmentItem]:
	var equipped: Array[EquipmentItem] = []
	for item in [top, bottom, gloves, boots, accessory]:
		if item != null:
			equipped.append(item)
	return equipped

## True si todos los slots están vacíos.
func is_empty() -> bool:
	return get_all_equipped().is_empty()
