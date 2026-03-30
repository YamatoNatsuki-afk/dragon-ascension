# res://core/TransformationRegistry.gd  ← Autoload
#
# Carga y provee todas las TransformationDefinition.
# Los .tres viven en res://data/transformations/definitions/.
# Si no hay .tres, crea las definiciones canónicas por código (fallback).

class_name TransformationRegistry
extends Node

const DEFINITIONS_PATH := "res://data/transformations/definitions/"

var _definitions: Dictionary = {}   # StringName → TransformationDefinition

# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	_load_from_disk()
	if _definitions.is_empty():
		_build_canonical_definitions()
	print("[TransformationRegistry] %d transformación(es) cargadas: %s" % [
		_definitions.size(),
		"  ·  ".join(_definitions.keys().map(func(k): return str(k)))
	])

func _load_from_disk() -> void:
	var dir := DirAccess.open(DEFINITIONS_PATH)
	if dir == null:
		return
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if entry.ends_with(".tres"):
			var def: TransformationDefinition = load(DEFINITIONS_PATH + entry)
			if def and def.id != &"":
				_definitions[def.id] = def
		entry = dir.get_next()
	dir.list_dir_end()

# ─────────────────────────────────────────────────────────────────────────────
# DEFINICIONES CANÓNICAS (fallback si no hay .tres)
# ─────────────────────────────────────────────────────────────────────────────

func _build_canonical_definitions() -> void:
	_definitions[&"transform_kaioken"]   = _def_kaioken()
	_definitions[&"transform_kaioken_x3"] = _def_kaioken_x3()
	_definitions[&"transform_kaioken_x4"] = _def_kaioken_x4()
	_definitions[&"transform_oozaru"]    = _def_oozaru()
	_definitions[&"transform_ssj1"]      = _def_ssj1()
	_definitions[&"transform_giant"]     = _def_giant_form()

func _make_def(id_: StringName, name_: String, desc: String,
		color: Color, races: Array) -> TransformationDefinition:
	var d := TransformationDefinition.new()
	d.id           = id_
	d.display_name = name_
	d.description  = desc
	d.aura_color   = color
	for r in races:
		d.allowed_races.append(r)
	d.unlock_flag  = id_
	return d

func _def_kaioken() -> TransformationDefinition:
	var d := _make_def(
		&"transform_kaioken", "Kaio-ken",
		"El Kaio-ken multiplica el poder del guerrero al límite de su cuerpo.\n×2 en todos los stats. El cuerpo lo paga después.",
		Color(0.95, 0.20, 0.10), []   # disponible para todos
	)
	# Multiplicadores oficiales: ×2 en todo
	d.stat_multipliers = {
		&"fuerza": 2.0, &"velocidad": 2.0, &"ki": 2.0,
		&"vitalidad": 2.0, &"resistencia": 2.0,
		&"poder_ki": 2.0, &"inteligencia": 2.0, &"intel_combate": 2.0,
	}
	d.hp_drain_per_sec         = 0.10   # 10% HP por segundo
	d.ki_drain_per_sec         = 2.0
	d.post_combat_stat         = &"resistencia"
	d.post_combat_delta        = -1.5
	d.mastery_min_drain_ratio  = 0.40   # maestría al 100% → drenaje 40% del original
	d.mastery_primary_stat     = &"vitalidad"
	d.mastery_secondary_stat   = &"resistencia"
	return d

func _def_kaioken_x3() -> TransformationDefinition:
	var d := _make_def(
		&"transform_kaioken_x3", "Kaio-ken ×3",
		"Triplica el poder del guerrero. El riesgo de muerte es real.",
		Color(1.00, 0.10, 0.05), []
	)
	d.stat_multipliers = {
		&"fuerza": 3.0, &"velocidad": 3.0, &"ki": 3.0,
		&"vitalidad": 3.0, &"resistencia": 3.0,
		&"poder_ki": 3.0, &"inteligencia": 3.0, &"intel_combate": 3.0,
	}
	d.hp_drain_per_sec         = 0.25   # 25% HP por segundo
	d.ki_drain_per_sec         = 5.0
	d.post_combat_stat         = &"vitalidad"
	d.post_combat_delta        = -3.0
	d.mastery_min_drain_ratio  = 0.45
	d.mastery_primary_stat     = &"vitalidad"
	d.mastery_secondary_stat   = &"resistencia"
	return d

func _def_kaioken_x4() -> TransformationDefinition:
	var d := _make_def(
		&"transform_kaioken_x4", "Kaio-ken ×4",
		"El límite absoluto del Kaio-ken. El cuerpo puede no sobrevivir.",
		Color(1.00, 0.02, 0.02), []
	)
	d.stat_multipliers = {
		&"fuerza": 4.0, &"velocidad": 4.0, &"ki": 4.0,
		&"vitalidad": 4.0, &"resistencia": 4.0,
		&"poder_ki": 4.0, &"inteligencia": 4.0, &"intel_combate": 4.0,
	}
	d.hp_drain_per_sec         = 0.50   # 50% HP por segundo
	d.ki_drain_per_sec         = 10.0
	d.post_combat_stat         = &"vitalidad"
	d.post_combat_delta        = -6.0
	d.mastery_min_drain_ratio  = 0.50
	d.mastery_primary_stat     = &"vitalidad"
	d.mastery_secondary_stat   = &"resistencia"
	return d

func _def_oozaru() -> TransformationDefinition:
	var d := _make_def(
		&"transform_oozaru", "Gran Simio (Oozaru)",
		"La transformación primordial Saiyan. Poder brutal, pero la mente se pierde.",
		Color(0.20, 0.55, 0.10), [&"saiyan"]
	)
	d.stat_multipliers = {
		&"fuerza": 10.0,
		&"resistencia": 10.0,
		&"vitalidad": 5.0,
		&"velocidad": 0.8,
		&"ki": 1.0,
		&"poder_ki": 0.5,
		&"inteligencia": 0.2,
		&"intel_combate": 0.1,   # pierde casi todo el control
	}
	d.combat_control_mult      = 0.1
	d.hp_drain_per_sec         = 0.0   # sin drenaje — es una forma sostenible
	d.ki_drain_per_sec         = 0.0
	d.mastery_min_drain_ratio  = 1.0
	d.mastery_primary_stat     = &"intel_combate"  # maestría = recuperar control
	d.mastery_secondary_stat   = &"inteligencia"
	# Con maestría al 100%: intel_combate vuelve a ×1.0 (control recuperado)
	d.heavy_training_mastery_threshold = 0.50
	return d

func _def_ssj1() -> TransformationDefinition:
	var d := _make_def(
		&"transform_ssj1", "Super Saiyan",
		"El legendario Super Saiyan. ×8 en todos los stats. El Ki se consume constantemente.",
		Color(1.00, 0.95, 0.20), [&"saiyan"]
	)
	d.stat_multipliers = {
		&"fuerza": 8.0, &"velocidad": 8.0, &"ki": 8.0,
		&"vitalidad": 8.0, &"resistencia": 8.0,
		&"poder_ki": 8.0, &"inteligencia": 8.0, &"intel_combate": 8.0,
	}
	d.hp_drain_per_sec         = 0.0
	d.ki_drain_per_sec         = 5.0   # Ki se consume por el mantenimiento
	d.post_combat_stat         = &""   # sin penalización post-combate
	d.mastery_min_drain_ratio  = 0.25  # maestría al 100% → drenaje 25%
	d.mastery_primary_stat     = &"ki"
	d.mastery_secondary_stat   = &"poder_ki"
	return d

func _def_giant_form() -> TransformationDefinition:
	var d := _make_def(
		&"transform_giant", "Forma Gigante",
		"El Namekiano expande su cuerpo. Fuerza colosal, pero lento como una montaña.",
		Color(0.40, 0.85, 0.30), [&"namekian"]
	)
	d.stat_multipliers = {
		&"fuerza": 5.0,
		&"resistencia": 3.0,
		&"vitalidad": 2.0,
		&"velocidad": 0.5,    # muy lento
		&"ki": 1.0,
		&"poder_ki": 1.0,
		&"inteligencia": 1.0,
		&"intel_combate": 0.7,  # difícil esquivar
	}
	d.combat_control_mult      = 0.7
	d.hp_drain_per_sec         = 0.0
	d.ki_drain_per_sec         = 3.0
	d.mastery_min_drain_ratio  = 0.30
	d.mastery_primary_stat     = &"vitalidad"
	d.mastery_secondary_stat   = &"resistencia"
	return d

# ─────────────────────────────────────────────────────────────────────────────
# API
# ─────────────────────────────────────────────────────────────────────────────

func get_definition(transform_id: StringName) -> TransformationDefinition:
	return _definitions.get(transform_id, null)

func get_all() -> Array:
	return _definitions.values()

func get_for_race(race_id: StringName) -> Array:
	var result: Array = []
	for def: TransformationDefinition in _definitions.values():
		if def.is_available_for_race(race_id):
			result.append(def)
	return result
