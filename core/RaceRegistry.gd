# core/RaceRegistry.gd  ← Autoload
# Carga y expone todas las RaceDefinition desde la carpeta de datos.
# Añadir una raza nueva = crear un .tres en la carpeta. Nada más.
extends Node

# Mapa de id → RaceDefinition cargada
var _races: Dictionary = {}

const RACE_DATA_PATH := "res://data/races/definitions/"

func _ready() -> void:
	_load_all_races()

func _load_all_races() -> void:
	var dir := DirAccess.open(RACE_DATA_PATH)
	if dir == null:
		push_error("RaceRegistry: carpeta '%s' no encontrada." % RACE_DATA_PATH)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var path := RACE_DATA_PATH + file_name
			var race: RaceDefinition = load(path)
			if race and race.id != &"":
				_races[race.id] = race
			else:
				push_warning("RaceRegistry: archivo '%s' no tiene id válido." % path)
		file_name = dir.get_next()
	dir.list_dir_end()

## Devuelve la RaceDefinition o null si no existe.
func get_race(race_id: StringName) -> RaceDefinition:
	if not _races.has(race_id):
		push_error("RaceRegistry: raza '%s' no registrada." % race_id)
		return null
	return _races[race_id]

## Lista de ids disponibles — útil para poblar la UI de selección.
func get_all_race_ids() -> Array[StringName]:
	# Array.assign() hace el cast tipado de forma segura en Godot 4.
	var result: Array[StringName] = []
	result.assign(_races.keys())
	return result

## Lista completa de RaceDefinitions — útil para mostrar cards en la UI.
func get_all_races() -> Array[RaceDefinition]:
	# Dictionary.values() devuelve Array sin tipo.
	# Array.assign() es el cast tipado correcto en Godot 4 —
	# no lanza error si los elementos son del tipo correcto.
	var result: Array[RaceDefinition] = []
	result.assign(_races.values())
	return result
