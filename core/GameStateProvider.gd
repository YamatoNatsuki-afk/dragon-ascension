# res://core/GameStateProvider.gd
# Autoload. Fuente de verdad única del estado de la partida en curso.
# DayManager lo alimenta. Todos los demás lo consultan.
#
# Por qué un autoload separado y no una función en DayManager:
#   DayManager tiene responsabilidades de orquestación del loop.
#   Mezclarle la responsabilidad de "proveedor de estado" viola SRP.
#   Con GameStateProvider cualquier sistema puede leer el estado sin
#   necesidad de conocer la existencia de DayManager.
#
# REGLA DE TYPE HINTS:
#   Los autoloads no pueden usar tipos de clases custom en sus firmas
#   porque se cargan antes que esas clases. Se omite el tipo y se
#   documenta con un comentario inline.
#
extends Node

var _character_data = null  # CharacterData

signal character_data_changed(data)  # CharacterData

## Llamado por DayManager.initialize(). Nadie más debe llamarlo.
func set_character_data(data) -> void:  # data: CharacterData
	assert(data != null, "GameStateProvider: data no puede ser null.")
	_character_data = data
	character_data_changed.emit(data)

## Consulta segura — devuelve null si aún no hay partida activa.
func get_character_data():  # → CharacterData
	return _character_data

## Shortcut: obtener el valor actual de un stat sin boilerplate.
func get_stat(stat_id: StringName) -> float:
	if _character_data == null:
		return 0.0
	return _character_data.base_stats.get(stat_id, 0.0)

## Shortcut: día actual.
func current_day() -> int:
	if _character_data == null:
		return 0
	return _character_data.current_day

## Comprueba que hay una partida activa. Útil en asserts.
func is_active() -> bool:
	return _character_data != null
