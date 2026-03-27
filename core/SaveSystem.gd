# res://core/SaveSystem.gd  ← Autoload
#
# CAMBIOS RESPECTO AL ORIGINAL (sin modificar ninguna firma de función):
#   1. save_character() ahora llama FlagSystem.serialize() y guarda el
#      resultado en data.saved_flags antes de pasar a ResourceSaver.
#      Esto garantiza que todos los flags activos viajan dentro del .tres.
#
#   2. load_character() ahora llama FlagSystem.deserialize(data.saved_flags)
#      justo después de cargar, restaurando el estado exacto del FlagSystem
#      al momento del último save.
#
#   3. Logs estructurados en save y load para verificar qué datos se mueven.
#      Controlados por enable_save_log (default true).
#
# REGLA DE TYPE HINTS:
#   Los autoloads no pueden usar tipos de clases custom en sus firmas
#   porque se cargan antes que esas clases. Se omite el tipo y se
#   documenta con un comentario inline.
#
extends Node

const SAVE_DIR  := "user://saves/"
const EXTENSION := ".tres"

@export var enable_save_log: bool = true

# ─────────────────────────────────────────────────────────────────────────────
# INICIALIZACIÓN
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

# ─────────────────────────────────────────────────────────────────────────────
# GUARDAR
# ─────────────────────────────────────────────────────────────────────────────

## Guarda el CharacterData en disco incluyendo el estado actual de FlagSystem.
## Slot 0 = partida única actual.
func save_character(data, slot: int = 0) -> bool:  # data: CharacterData
	var path := _get_path(slot)

	# ── 1. Serializar FlagSystem dentro del CharacterData ─────────────────
	# Los flags viven en memoria (FlagSystem._flags). Para que sobrevivan
	# al cierre del juego necesitan viajar dentro del .tres.
	# saved_flags es el puente: SaveSystem escribe aquí, ResourceSaver
	# lo persiste, load_character lo lee y restaura FlagSystem.
	#
	# Usamos duplicate() en el CharacterData para no modificar el Resource
	# que está activo en runtime — mismo patrón que el código original.
	var snapshot = data.duplicate(true)  # CharacterData
	snapshot.saved_flags = FlagSystem.serialize()

	# ── 2. Guardar en disco ───────────────────────────────────────────────
	var result := ResourceSaver.save(snapshot, path)

	if result != OK:
		push_error("SaveSystem: error al guardar en '%s' (código %d)." % [path, result])
		return false

	if enable_save_log:
		_log_save(data, snapshot.saved_flags, path)

	return true

# ─────────────────────────────────────────────────────────────────────────────
# CARGAR
# ─────────────────────────────────────────────────────────────────────────────

## Carga un CharacterData y restaura FlagSystem a su estado guardado.
## Devuelve null si el slot no existe.
func load_character(slot: int = 0):  # → CharacterData
	var path := _get_path(slot)

	if not FileAccess.file_exists(path):
		return null

	# CACHE_MODE_IGNORE: evita que Godot devuelva una versión cacheada en memoria.
	# Sin esto, si save y load ocurren en la misma sesión, podríamos recibir
	# el Resource original en lugar del que está en disco.
	var data = ResourceLoader.load(  # CharacterData
		path, "", ResourceLoader.CACHE_MODE_IGNORE
	)

	if data == null:
		push_error("SaveSystem: no se pudo cargar '%s'. ¿Archivo corrupto?" % path)
		return null

	# ── Restaurar FlagSystem desde saved_flags ────────────────────────────
	# saved_flags puede estar vacío en saves antiguos (antes de este cambio).
	# deserialize() maneja ese caso: si el dict está vacío, FlagSystem queda
	# en estado limpio — comportamiento correcto para saves legacy.
	FlagSystem.deserialize(data.saved_flags)

	if enable_save_log:
		_log_load(data, path)

	return data

# ─────────────────────────────────────────────────────────────────────────────
# UTILIDADES PÚBLICAS
# ─────────────────────────────────────────────────────────────────────────────

func slot_exists(slot: int = 0) -> bool:
	return FileAccess.file_exists(_get_path(slot))

func _get_path(slot: int) -> String:
	return SAVE_DIR + "character_%02d" % slot + EXTENSION

# ─────────────────────────────────────────────────────────────────────────────
# LOGGING
#
# Separado de la lógica de save/load para no mezclar responsabilidades.
# Ningún método de log retorna datos ni modifica estado.
# ─────────────────────────────────────────────────────────────────────────────

func _log_save(data, flags_snapshot: Dictionary, path: String) -> void:  # data: CharacterData
	var flags_data: Dictionary = flags_snapshot.get("flags",   {})
	var history_data: Array    = flags_snapshot.get("history", [])
	var flag_count: int        = flags_data.size()
	var history_count: int     = history_data.size()

	print("")
	print("┌── SaveSystem: GUARDANDO ────────────────────────────")
	print("│  Ruta       : %s" % path)
	print("│  Personaje  : %s  [%s]  día %d" % [
		data.character_name, str(data.race_id), data.current_day
	])
	print("│  XP         : %.1f" % data.experience)
	print("│")

	print("│  STATS GUARDADOS:")
	for stat_id: StringName in data.base_stats.keys():
		print("│    %-14s %6.1f" % [str(stat_id), data.base_stats[stat_id]])
	print("│")

	if flag_count == 0:
		print("│  FLAGS: (ninguno — FlagSystem en estado limpio)")
	else:
		print("│  FLAGS GUARDADOS: %d flag(s)" % flag_count)
		for flag_id: StringName in flags_data.keys():
			var val: Variant = flags_data[flag_id]
			print("│    %-35s = %s" % [str(flag_id), str(val)])

	print("│  Historial de flags: %d entradas" % history_count)
	print("└─────────────────────────────────────────────────────")
	print("")

func _log_load(data, path: String) -> void:  # data: CharacterData
	var flags_data: Dictionary = data.saved_flags.get("flags",   {})
	var history_data: Array    = data.saved_flags.get("history", [])
	var flag_count: int        = flags_data.size()
	var history_count: int     = history_data.size()
	var is_legacy: bool        = data.saved_flags.is_empty()

	print("")
	print("┌── SaveSystem: CARGANDO ─────────────────────────────")
	print("│  Ruta       : %s" % path)
	print("│  Personaje  : %s  [%s]  día %d" % [
		data.character_name, str(data.race_id), data.current_day
	])
	print("│  XP         : %.1f" % data.experience)
	print("│")

	print("│  STATS CARGADOS:")
	for stat_id: StringName in data.base_stats.keys():
		print("│    %-14s %6.1f" % [str(stat_id), data.base_stats[stat_id]])
	print("│")

	if is_legacy:
		print("│  FLAGS: ⚠  Save legacy detectado (sin saved_flags).")
		print("│         FlagSystem iniciado en estado limpio.")
		print("│         Esto es normal para saves creados antes del fix.")
	elif flag_count == 0:
		print("│  FLAGS: (ninguno guardado — FlagSystem restaurado en estado limpio)")
	else:
		print("│  FLAGS RESTAURADOS: %d flag(s)" % flag_count)
		for flag_id: StringName in flags_data.keys():
			var val: Variant = flags_data[flag_id]
			print("│    %-35s = %s" % [str(flag_id), str(val)])

	print("│  Historial de flags restaurado: %d entradas" % history_count)

	# Verificación post-deserialización
	var live_flags := FlagSystem.get_all()
	if live_flags.size() == flag_count:
		print("│  ✓ Verificación: FlagSystem tiene %d flag(s) — coincide con el save." \
			% live_flags.size())
	else:
		push_warning(
			"SaveSystem: discrepancia en flags tras deserialización.\n" +
			"  Guardados: %d  ·  Live: %d\n" % [flag_count, live_flags.size()] +
			"  Revisa FlagSystem.deserialize()."
		)
		print("│  ⚠  DISCREPANCIA: %d guardados vs %d en FlagSystem." % [
			flag_count, live_flags.size()
		])

	print("└─────────────────────────────────────────────────────")
	print("")
