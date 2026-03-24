# core/FlagSystem.gd  ← Autoload
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

# ── Señales ───────────────────────────────────
signal flag_set(flag_id: StringName, value: Variant)
signal flag_cleared(flag_id: StringName)

# ─────────────────────────────────────────────
# Escritura
# ─────────────────────────────────────────────

## Establece un flag. Emite flag_set.
## value puede ser bool, int, float o String.
func set_flag(flag_id: StringName, value: Variant = true) -> void:
	var prev := _flags.get(flag_id, null)
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

# ─────────────────────────────────────────────
# Lectura
# ─────────────────────────────────────────────

## Comprueba si un flag existe y es truthy.
func has(flag_id: StringName) -> bool:
	var val := _flags.get(flag_id, false)
	# bool false, int 0, float 0.0 y String "" = falsy
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

# ─────────────────────────────────────────────
# Serialización (para SaveSystem)
# ─────────────────────────────────────────────

## Exporta el estado para guardarlo en CharacterData o un archivo separado.
func serialize() -> Dictionary:
	return { "flags": _flags.duplicate(), "history": _history.duplicate() }

## Restaura el estado desde un Dictionary guardado.
func deserialize(data: Dictionary) -> void:
	_flags   = data.get("flags",   {})
	_history = data.get("history", [])
