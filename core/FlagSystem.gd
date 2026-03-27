# res://core/FlagSystem.gd  ← Autoload
# Almacén de flags persistentes para la partida actual.
# Funciona como una pizarra (blackboard): cualquier sistema puede escribir,
# cualquier sistema puede leer, nadie necesita conocer a nadie.
#
# Los flags son StringNames con un valor asociado (bool, int, float o String).
# Esto permite tanto flags binarios ("elite_path_unlocked") como
# contadores ("times_defeated") y estados ("current_arc").
extends Node

# Almacén interno. StringName → Variant (bool / int / float / String)
var _flags: Dictionary = {}

# Historial para debugging y narrativa emergente
var _history: Array[Dictionary] = []

# ── Señales (sin cambios) ─────────────────────────────────────────────────────
signal flag_set(flag_id: StringName, value: Variant)
signal flag_cleared(flag_id: StringName)

# ─────────────────────────────────────────────────────────────────────────────
# ESCRITURA  ← sin cambios en firmas
# ─────────────────────────────────────────────────────────────────────────────

## Establece un flag. Emite flag_set.
func set_flag(flag_id: StringName, value: Variant = true) -> void:
	var prev: Variant = _flags.get(flag_id, null)
	_flags[flag_id] = value
	_history.append({
		"flag":  flag_id,
		"value": value,
		"prev":  prev,
		"day":   GameStateProvider.current_day()
	})
	flag_set.emit(flag_id, value)

## Incrementa un contador. Si no existe, lo crea en 0 y luego suma.
func increment(flag_id: StringName, amount: int = 1) -> void:
	var current: int = _flags.get(flag_id, 0)
	set_flag(flag_id, current + amount)

## Elimina un flag. Emite flag_cleared.
func clear_flag(flag_id: StringName) -> void:
	if _flags.has(flag_id):
		_flags.erase(flag_id)
		flag_cleared.emit(flag_id)

## Elimina todos los flags — llamar al empezar una nueva partida.
func reset() -> void:
	_flags.clear()
	_history.clear()

# ─────────────────────────────────────────────────────────────────────────────
# LECTURA  ← sin cambios en firmas
# ─────────────────────────────────────────────────────────────────────────────

## Comprueba si un flag existe y es truthy.
func has(flag_id: StringName) -> bool:
	var val: Variant = _flags.get(flag_id, false)
	match typeof(val):
		TYPE_BOOL:   return val
		TYPE_INT:    return val != 0
		TYPE_FLOAT:  return val != 0.0
		TYPE_STRING: return val != ""
	return false

## Obtiene el valor raw de un flag. Devuelve default si no existe.
func get_value(flag_id: StringName, default: Variant = null) -> Variant:
	return _flags.get(flag_id, default)

## Devuelve todos los flags activos. Útil para serialización y debug.
func get_all() -> Dictionary:
	return _flags.duplicate()

## Devuelve el historial de cambios para narrativa emergente y debug.
func get_history() -> Array[Dictionary]:
	return _history.duplicate()

# ─────────────────────────────────────────────────────────────────────────────
# SERIALIZACIÓN
#
# serialize() y deserialize() son la interfaz con SaveSystem.
# SOLO SaveSystem las llama — ningún otro sistema debe tocarlas.
#
# Formato del dict serializado:
#   {
#     "flags":   { StringName: Variant, ... },
#     "history": [ { "flag", "value", "prev", "day" }, ... ]
#   }
#
# Por qué guardamos el historial:
#   ProgressTracker y CheckpointSystem lo usan para narrativa emergente.
#   Sin él, al recargar el juego esos sistemas empezarían sin contexto.
# ─────────────────────────────────────────────────────────────────────────────

## Exporta el estado completo para que SaveSystem lo guarde en CharacterData.saved_flags.
## Llama a esto ANTES de ResourceSaver.save().
func serialize() -> Dictionary:
	# duplicate() es crítico: sin él, el dict que devolvemos apunta al mismo
	# objeto que _flags. Si alguien modifica un flag después del serialize(),
	# el snapshot guardado también cambiaría — lo que daría datos incorrectos.
	return {
		"flags":   _flags.duplicate(true),
		"history": _history.duplicate(true),
	}

## Restaura el estado desde el dict guardado en CharacterData.saved_flags.
## SaveSystem la llama justo después de ResourceLoader.load().
## Si data está vacío (save legacy), FlagSystem queda en estado limpio — correcto.
func deserialize(data: Dictionary) -> void:
	# Reset explícito antes de restaurar para garantizar estado limpio.
	# Sin esto, si había flags en memoria de una partida anterior, se mezclarían.
	_flags.clear()
	_history.clear()

	# get() con fallback vacío garantiza compatibilidad con saves legacy
	# que no tengan el campo saved_flags (CharacterData anterior al fix).
	# Dictionary.get() devuelve Variant → OK para Dictionary.
	# Array[Dictionary] no acepta Array sin tipo → usar assign() para cast tipado seguro.
	_flags = data.get("flags", {})

	var raw_history: Array = data.get("history", [])
	_history.assign(raw_history)

	# Validación de tipos: aseguramos que lo que cargamos tiene la forma esperada.
	# Si el .tres fue corrompido o modificado a mano, fallamos rápido con mensaje claro.
	if not (_flags is Dictionary):
		push_error(
			"FlagSystem.deserialize: 'flags' no es un Dictionary.\n" +
			"  Tipo recibido: %s\n" % type_string(typeof(_flags)) +
			"  FlagSystem se reinicia en estado limpio."
		)
		_flags = {}

	if not (_history is Array):
		push_error(
			"FlagSystem.deserialize: 'history' no es un Array.\n" +
			"  Tipo recibido: %s\n" % type_string(typeof(_history)) +
			"  Historial se reinicia vacío."
		)
		_history = []
