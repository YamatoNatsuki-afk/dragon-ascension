# core/CharacterFactory.gd
# Responsabilidad única: construir un CharacterData válido y completo.
# No sabe de UI, no sabe de Player — solo compone Resources.
class_name CharacterFactory
extends RefCounted

## Crea un CharacterData completo desde las selecciones del jugador.
## Todos los parámetros tienen defaults para facilitar testing y prototipos.
static func create(
	p_name: String,
	p_race_id: StringName,
	p_appearance: AppearanceData = null,
	p_build: BuildData = null
) -> CharacterData:

	var race: RaceDefinition = RaceRegistry.get_race(p_race_id)
	if race == null:
		push_error("CharacterFactory: raza '%s' no existe." % p_race_id)
		return null

	var data := CharacterData.new()
	data.character_name = p_name
	data.race_id        = p_race_id

	# Aplicar multiplicadores de raza sobre los stats base
	_apply_race_multipliers(data, race)

	# Usar los sub-resources proporcionados o crear defaults
	data.appearance = p_appearance if p_appearance else _default_appearance(race)
	data.build      = p_build      if p_build      else BuildData.new()

	return data

## Aplica los multiplicadores de raza a cada stat base del personaje.
## Separado para que sea testeable de forma independiente.
static func _apply_race_multipliers(data: CharacterData, race: RaceDefinition) -> void:
	for stat_id: StringName in data.base_stats.keys():
		var multiplier: float = race.stat_multipliers.get(stat_id, 1.0)
		data.base_stats[stat_id] *= multiplier

## Crea una AppearanceData con el color de aura por defecto de la raza.
static func _default_appearance(race: RaceDefinition) -> AppearanceData:
	var appearance := AppearanceData.new()
	appearance.aura_color = race.default_aura_color
	return appearance
