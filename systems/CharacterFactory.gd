# res://systems/CharacterFactory.gd
#
# Responsabilidad única: construir instancias de CharacterData válidas.
# No contiene lógica de gameplay. No guarda estado. Solo fabrica.
#
# Métodos principales:
#   CharacterFactory.create(name, race_id, appearance, build)  ← entrada principal
#   CharacterFactory.create_player(name, race_id)              ← con defaults internos
#   CharacterFactory.create_enemy(day, difficulty)             ← enemigos escalados
#   CharacterFactory.from_save_dict(dict)                      ← deserialización

class_name CharacterFactory
extends RefCounted

# ─────────────────────────────────────────────────────────
# Rutas de recursos
# ─────────────────────────────────────────────────────────

const RACE_PATH := "res://data/races/"

# ─────────────────────────────────────────────────────────
# Stats base de referencia (día 1, sin raza aplicada)
# ─────────────────────────────────────────────────────────

## Valores "humano sin entrenamiento" — punto de partida neutro.
const DEFAULT_BASE_STATS := {
	&"fuerza":        5.0,
	&"velocidad":     5.0,
	&"ki":            3.0,
	&"vitalidad":     8.0,
	&"resistencia":   5.0,
	&"poder_ki":      3.0,
	&"inteligencia":  5.0,
	&"intel_combate": 4.0,
}

## Base para enemigos genéricos (escala externamente por día y dificultad).
const ENEMY_BASE_STATS := {
	&"fuerza":        4.0,
	&"velocidad":     4.0,
	&"ki":            2.0,
	&"vitalidad":     6.0,
	&"resistencia":   4.0,
	&"poder_ki":      2.0,
	&"inteligencia":  2.0,
	&"intel_combate": 3.0,
}

# ─────────────────────────────────────────────────────────
# API pública
# ─────────────────────────────────────────────────────────

## Punto de entrada principal.
## Crea un CharacterData completo con appearance y build proporcionados.
## Usado por CharacterCreationScreen y GameManager (modo debug).
static func create(
		character_name: String,
		race_id:        StringName,
		appearance:     AppearanceData,
		build:          BuildData
) -> CharacterData:

	var data              := CharacterData.new()
	data.character_name   = character_name
	data.race_id          = race_id
	data.current_day      = 1
	data.experience       = 0.0
	data.base_stats       = DEFAULT_BASE_STATS.duplicate()
	data.appearance       = appearance if appearance != null else AppearanceData.new()
	data.build            = build      if build      != null else _create_default_build()

	_apply_race_multipliers(data)

	return data


## Crea un CharacterData para el jugador con appearance y build por defecto.
## Útil para tests o flujos sin pantalla de creación.
static func create_player(
		character_name: String     = "Guerrero",
		race_id:        StringName = &"human"
) -> CharacterData:

	return create(character_name, race_id, AppearanceData.new(), _create_default_build())


## Crea un CharacterData para un enemigo genérico.
## day        → día actual del loop (escala lineal de stats).
## difficulty → multiplicador adicional (1.0 = normal, 1.5 = difícil).
static func create_enemy(
		day:        int   = 1,
		difficulty: float = 1.0
) -> CharacterData:

	var data              := CharacterData.new()
	data.character_name   = "Enemigo"
	data.race_id          = &"human"
	data.current_day      = day
	data.base_stats       = _scale_enemy_stats(day, difficulty)
	data.build            = _create_default_build()

	# Los enemigos no necesitan raza aplicada por ahora.
	# Cuando existan enemigos con raza (Saiyajins NPC, etc.) se extiende aquí.

	return data


## Deserializa un CharacterData desde un diccionario guardado (SaveSystem).
## Valida que tenga todos los stat IDs. Rellena los que falten con 0.
static func from_save_dict(dict: Dictionary) -> CharacterData:
	var data              := CharacterData.new()
	data.character_name   = dict.get("character_name", "Guerrero")
	data.race_id          = StringName(dict.get("race_id", "human"))
	data.current_day      = dict.get("current_day", 1)
	data.experience       = dict.get("experience", 0.0)
	data.base_stats       = _validate_stats(dict.get("base_stats", {}))
	data.build            = _create_default_build()

	# TODO: deserializar build y appearance desde dict cuando tengan serialización completa.

	_apply_race_multipliers(data)

	return data

# ─────────────────────────────────────────────────────────
# Métodos privados
# ─────────────────────────────────────────────────────────

## Carga el RaceDefinition .tres y aplica sus multiplicadores sobre base_stats.
## Si no existe el archivo, loga un warning y continúa sin modificar stats.
static func _apply_race_multipliers(data: CharacterData) -> void:
	var path := RACE_PATH + str(data.race_id) + ".tres"

	if not ResourceLoader.exists(path):
		push_warning("CharacterFactory: RaceDefinition no encontrado en '%s'. Stats sin modificar." % path)
		return

	var race: RaceDefinition = ResourceLoader.load(path)
	if race == null:
		push_error("CharacterFactory: No se pudo cargar RaceDefinition desde '%s'." % path)
		return

	for stat_id in data.base_stats:
		var multiplier: float = race.stat_multipliers.get(stat_id, 1.0)
		data.base_stats[stat_id] *= multiplier


## Escala los stats base de enemigos según el día y dificultad.
## Fórmula: base * (1 + día * 0.08) * dificultad
## Ajustable cuando haya balanceo formal.
static func _scale_enemy_stats(day: int, difficulty: float) -> Dictionary:
	var scaled        := {}
	var scale_factor  := (1.0 + day * 0.08) * difficulty

	for stat_id in ENEMY_BASE_STATS:
		scaled[stat_id] = ENEMY_BASE_STATS[stat_id] * scale_factor

	return scaled


## Crea un BuildData con defaults balanceados (pesos 0.5, estilo "balanced").
static func _create_default_build() -> BuildData:
	var build          := BuildData.new()
	build.build_name   = "Default"
	build.combat_style = &"balanced"
	return build


## Valida un dict de stats: asegura que tenga todos los IDs canónicos.
## Stats faltantes se rellenan desde DEFAULT_BASE_STATS.
## Stats desconocidos se ignoran con warning.
static func _validate_stats(raw: Dictionary) -> Dictionary:
	var valid := DEFAULT_BASE_STATS.duplicate()

	for stat_id in raw:
		if valid.has(stat_id):
			valid[stat_id] = float(raw[stat_id])
		else:
			push_warning("CharacterFactory._validate_stats: stat_id desconocido '%s' ignorado." % stat_id)

	return valid
