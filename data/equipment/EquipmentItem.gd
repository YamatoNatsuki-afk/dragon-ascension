# res://data/equipment/EquipmentItem.gd
# Resource de solo datos. Define un ítem de equipo equipable por el personaje.
# Un .tres por ítem, organizados en data/equipment/items/
#
# DISEÑO:
#   Los ítems son inmutables — nunca se modifican en runtime.
#   EquipmentData guarda CUÁL está equipado; EquipmentItem solo dice QUÉ ES.
#   Esto permite compartir la misma referencia entre múltiples personajes
#   sin riesgo de contaminación de datos.
#
class_name EquipmentItem
extends Resource

## Slots de equipamiento disponibles.
## Cada personaje puede tener un ítem por slot.
enum Slot {
	TOP,        # Parte superior del cuerpo (ropa/armadura)
	BOTTOM,     # Parte inferior (pantalones/falda)
	GLOVES,     # Manos
	BOOTS,      # Pies
	ACCESSORY,  # Accesorio libre (cinto, capa, protector)
}

## Identificador único. Debe coincidir con el nombre del archivo .tres.
## Ejemplo: &"gi_orange_top", &"saiyan_armor_top"
@export var id: StringName = &""

## Nombre visible en la UI del vestidor.
@export var display_name: String = ""

## Descripción de lore/flavor para el tooltip.
@export_multiline var description: String = ""

## Slot al que pertenece este ítem. Determina dónde puede equiparse.
@export var slot: Slot = Slot.TOP

## Rareza del ítem — afecta presentación visual en la UI.
## No cambia la mecánica, solo el display.
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }
@export var rarity: Rarity = Rarity.COMMON

## Bonos de stat que este ítem otorga cuando está equipado.
## Se aplican como modificadores persistentes en StatsComponent.
## Formato: { &"strength": 5.0, &"defense": 3.0 }
## Valores positivos son buffs, negativos son penalizaciones (ítems con trade-off).
@export var stat_bonuses: Dictionary = {}

## Color que este ítem aplica sobre la apariencia del personaje.
## Color.TRANSPARENT = sin override (usa el color base del personaje).
## En Fase 4 esto alimenta el shader del sprite.
@export var color_override: Color = Color.TRANSPARENT

## Identificador del sprite/icono para la UI (placeholder hasta tener assets).
@export var icon_id: StringName = &""

# ─────────────────────────────────────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────────────────────────────────────

## Retorna el color asociado a la rareza para la UI.
## Sin lógica de gameplay — solo presentación.
func get_rarity_color() -> Color:
	match rarity:
		Rarity.COMMON:    return Color(0.75, 0.75, 0.75)  # Gris
		Rarity.UNCOMMON:  return Color(0.30, 0.85, 0.30)  # Verde
		Rarity.RARE:      return Color(0.20, 0.55, 1.00)  # Azul
		Rarity.EPIC:      return Color(0.70, 0.20, 0.95)  # Morado
		Rarity.LEGENDARY: return Color(1.00, 0.78, 0.10)  # Dorado DB
	return Color.WHITE

## Retorna el nombre de la rareza como string legible.
func get_rarity_name() -> String:
	match rarity:
		Rarity.COMMON:    return "Común"
		Rarity.UNCOMMON:  return "Poco común"
		Rarity.RARE:      return "Raro"
		Rarity.EPIC:      return "Épico"
		Rarity.LEGENDARY: return "Legendario"
	return ""

## Retorna el nombre del slot como string legible.
static func slot_name(s: Slot) -> String:
	match s:
		Slot.TOP:       return "Torso"
		Slot.BOTTOM:    return "Piernas"
		Slot.GLOVES:    return "Manos"
		Slot.BOOTS:     return "Pies"
		Slot.ACCESSORY: return "Accesorio"
	return ""

## Retorna true si este ítem otorga algún bono en el stat dado.
func has_bonus_for(stat_id: StringName) -> bool:
	return stat_bonuses.has(stat_id) and stat_bonuses[stat_id] != 0.0
