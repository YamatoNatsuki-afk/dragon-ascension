# core/StatRegistry.gd
# Autoload. Fuente única de verdad para los límites y valores base de cada stat.
#
# RESPONSABILIDADES:
#   - Cargar StatDefinitions desde data/stats/definitions/*.tres al iniciar
#   - Exponer clamping centralizado via clamp_stat()
#   - Exponer valores base via get_base_value() para CharacterFactory y resets
#
# REGLA DE ORO:
#   Todo el código del juego que necesite min/max de un stat llama a
#   StatRegistry.clamp_stat() — nunca hardcodea límites ni usa maxf/minf propios.
#
# ORDEN EN project.godot:
#   StatRegistry debe cargarse ANTES de DayManager y ActionRegistry,
#   porque _resolve() y consecuencias lo usan durante la inicialización.
#
extends Node

const DEFS_PATH := "res://data/stats/definitions/"

# stat_id → StatDefinition
var _defs: Dictionary = {}

# ─────────────────────────────────────────────────────────────────────────────
# INICIALIZACIÓN
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	_load_definitions()
	if _defs.is_empty():
		push_error("StatRegistry: no se encontraron StatDefinitions en '%s'. " % DEFS_PATH +
			"Crea al menos un .tres en esa carpeta.")
	else:
		print("[StatRegistry] %d stats cargados: %s" % [
			_defs.size(),
			", ".join(_defs.keys().map(func(k): return str(k)))
		])

func _load_definitions() -> void:
	var dir := DirAccess.open(DEFS_PATH)
	if dir == null:
		push_error("StatRegistry: carpeta '%s' no encontrada. " % DEFS_PATH +
			"¿Existe res://data/stats/definitions/?")
		return

	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if entry.ends_with(".tres"):
			var path := DEFS_PATH + entry
			var def: StatDefinition = load(path)
			if def == null:
				push_warning("StatRegistry: no se pudo cargar '%s'." % path)
			elif def.id == &"":
				push_warning("StatRegistry: '%s' tiene id vacío — ignorado." % path)
			elif _defs.has(def.id):
				push_warning("StatRegistry: id duplicado '%s' en '%s' — ignorado." % [
					str(def.id), path
				])
			else:
				_defs[def.id] = def
		entry = dir.get_next()
	dir.list_dir_end()

# ─────────────────────────────────────────────────────────────────────────────
# API PÚBLICA
# ─────────────────────────────────────────────────────────────────────────────

## Devuelve la StatDefinition completa para un stat.
## Retorna null si el stat no está registrado.
func get_definition(stat_id: StringName) -> StatDefinition:
	return _defs.get(stat_id, null)

## Clampea un valor dentro del rango [min_value, max_value] definido para el stat.
##
## Si el stat no tiene definición registrada, aplica un fallback seguro
## y emite un warning — esto indica un stat desconocido que hay que registrar.
##
## Es el ÚNICO lugar del juego donde se aplican límites de stats.
## DayManager._resolve(), ModifyStatConsequence y el sistema de combate
## deben usar esta función — nunca clampear por su cuenta.
func clamp_stat(stat_id: StringName, value: float) -> float:
	var def: StatDefinition = _defs.get(stat_id, null)
	if def == null:
		push_warning("StatRegistry.clamp_stat: stat '%s' sin definición. " % str(stat_id) +
			"Usando fallback [0.1, 99999.0]. Registra el stat en data/stats/definitions/.")
		return clampf(value, 0.1, 99999.0)
	return clampf(value, def.min_value, def.max_value)

## Valor base definido para un stat (el que tiene un personaje recién creado
## antes de aplicar multiplicadores de raza).
##
## Usar en CharacterFactory al construir base_stats,
## y en cualquier sistema de reset de personaje.
func get_base_value(stat_id: StringName) -> float:
	var def: StatDefinition = _defs.get(stat_id, null)
	if def == null:
		push_warning("StatRegistry.get_base_value: stat '%s' sin definición." % str(stat_id))
		return 0.0
	return def.base_value

## Devuelve todos los stat_ids registrados.
## Útil para validar CharacterData y para construir UIs de stats dinámicamente.
func get_all_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for key: Variant in _defs.keys():
		ids.append(key as StringName)
	return ids

## Devuelve true si el stat_id está registrado.
## Usar para validar datos de entrada antes de operar sobre stats.
func has_stat(stat_id: StringName) -> bool:
	return _defs.has(stat_id)
