# core/SaveSystem.gd  ← Autoload
extends Node

const SAVE_DIR  := "user://saves/"
const EXTENSION := ".tres"

func _ready() -> void:
	# Crear el directorio si no existe (primera vez)
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

## Guarda el CharacterData en disco.
## Usa un nombre de slot para soporte multi-save futuro.
func save_character(data: CharacterData, slot: int = 0) -> bool:
	var path := _get_path(slot)

	# IMPORTANTE: guardamos una duplicación profunda para no modificar
	# el Resource que está siendo usado en runtime.
	var result := ResourceSaver.save(data.duplicate(true), path)

	if result != OK:
		push_error("SaveSystem: error al guardar en '%s' (código %d)." % [path, result])
		return false

	print("SaveSystem: personaje guardado en '%s'." % path)
	return true

## Carga un CharacterData desde disco.
## Devuelve null si el slot no existe — el llamador debe manejarlo.
func load_character(slot: int = 0) -> CharacterData:
	var path := _get_path(slot)

	if not FileAccess.file_exists(path):
		return null  # Slot vacío — comportamiento esperado, no un error

	var data: CharacterData = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)

	if data == null:
		push_error("SaveSystem: no se pudo cargar '%s'. Archivo corrupto?" % path)
		return null

	return data

## Comprueba si existe un save en un slot dado.
func slot_exists(slot: int = 0) -> bool:
	return FileAccess.file_exists(_get_path(slot))

func _get_path(slot: int) -> String:
	return SAVE_DIR + "character_%02d" % slot + EXTENSION
