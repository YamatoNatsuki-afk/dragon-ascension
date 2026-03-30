# res://core/MinigameRecordSystem.gd  ← Autoload
#
# Gestiona récords de minijuegos y otorga bonuses de stat permanentes
# al superar umbrales de score por primera vez.
#
# FLUJO:
#   Minijuego emite completed(multiplier: float)
#   DayScreen llama MinigameRecordSystem.save_score(id, score_0_100, char_data)
#   → Si score > record anterior:
#       Detecta umbrales cruzados (25 / 50 / 75 / 100)
#       Aplica bonus de stat en character_data.base_stats
#       Emite EventBus.minigame_record_broken(id, old, new, bonuses)
#
# RECORDS guardados en CharacterData.minigame_records: Dictionary
#   { "directional_strike": 67.0, "dodge": 42.0, ... }
#
# UMBRALES: 25 / 50 / 75 / 100 — cada uno se otorga UNA SOLA VEZ por run.
# Los bonuses ya otorgados se trackean en CharacterData.minigame_milestones: Dictionary
#   { "directional_strike_25": true, "ki_channel_50": true, ... }

extends Node

# ─────────────────────────────────────────────────────────────────────────────
# DEFINICIÓN DE BONUSES
# ─────────────────────────────────────────────────────────────────────────────
#
# Formato: minigame_id → Array de [threshold_pct, { stat_id: bonus_delta }]
# Los thresholds deben estar en orden ascendente.

const RECORD_BONUSES: Dictionary = {
	"directional_strike": [
		[25, { &"fuerza": 0.5 }],
		[50, { &"fuerza": 1.0 }],
		[75, { &"fuerza": 2.0 }],
		[100, { &"fuerza": 3.0 }],
	],
	"apple": [
		[25, { &"resistencia": 0.5 }],
		[50, { &"resistencia": 1.0 }],
		[75, { &"resistencia": 2.0 }],
		[100, { &"resistencia": 3.0 }],
	],
	"dodge": [
		[25, { &"velocidad": 0.5 }],
		[50, { &"velocidad": 1.0 }],
		[75, { &"velocidad": 2.0 }],
		[100, { &"velocidad": 3.0 }],
	],
	"ki_channel": [
		[25, { &"ki": 0.3, &"poder_ki": 0.3 }],
		[50, { &"ki": 0.6, &"poder_ki": 0.6 }],
		[75, { &"ki": 1.2, &"poder_ki": 1.2 }],
		[100, { &"ki": 2.0, &"poder_ki": 2.0 }],
	],
	"sequence": [
		[25, { &"intel_combate": 0.4, &"inteligencia": 0.4 }],
		[50, { &"intel_combate": 0.8, &"inteligencia": 0.8 }],
		[75, { &"intel_combate": 1.5, &"inteligencia": 1.5 }],
		[100, { &"intel_combate": 2.5, &"inteligencia": 2.5 }],
	],
	"training_sync": [
		[25, { &"vitalidad": 0.5 }],
		[50, { &"vitalidad": 1.0 }],
		[75, { &"vitalidad": 2.0 }],
		[100, { &"vitalidad": 3.0 }],
	],
	"snake_road": [
		[25, { &"velocidad": 0.5, &"intel_combate": 0.5 }],
		[50, { &"velocidad": 1.0, &"intel_combate": 1.0 }],
		[75, { &"velocidad": 2.0, &"intel_combate": 2.0 }],
		[100, { &"velocidad": 4.0, &"intel_combate": 4.0 }],
	],
}

# Nombres visibles para la UI
const MINIGAME_NAMES: Dictionary = {
	"directional_strike": "Golpe Direccional",
	"apple":              "Manzanas",
	"dodge":              "Reflejos",
	"ki_channel":         "Canal de Ki",
	"sequence":           "Lectura de Combate",
	"training_sync":      "Sincronía",
	"snake_road":         "Camino de la Serpiente",
}

# ─────────────────────────────────────────────────────────────────────────────
# API PRINCIPAL
# ─────────────────────────────────────────────────────────────────────────────

## Guarda el score de un minijuego y aplica bonuses si corresponde.
## score_pct: 0.0–100.0
## Retorna un Array de { stat_id, delta, threshold } con los bonuses aplicados.
func save_score(minigame_id: String, score_pct: float, character_data) -> Array:
	if character_data == null:
		return []

	_ensure_fields(character_data)

	var records:    Dictionary = character_data.minigame_records
	var milestones: Dictionary = character_data.minigame_milestones

	var old_score: float = float(records.get(minigame_id, 0.0))
	var new_score: float = clampf(score_pct, 0.0, 100.0)

	# Siempre guardar si es mejor
	if new_score <= old_score:
		return []

	records[minigame_id] = new_score

	# Verificar qué umbrales se cruzan por primera vez
	var applied_bonuses: Array = []
	var thresholds: Array = RECORD_BONUSES.get(minigame_id, [])

	for entry: Array in thresholds:
		var threshold: int     = entry[0]
		var stat_map: Dictionary = entry[1]
		var milestone_key: String = "%s_%d" % [minigame_id, threshold]

		# Solo aplicar si:
		# 1. El nuevo score supera el umbral
		# 2. El umbral no fue otorgado antes
		if new_score >= float(threshold) and not milestones.get(milestone_key, false):
			milestones[milestone_key] = true

			# Aplicar bonus a cada stat
			for stat_id: StringName in stat_map.keys():
				var delta: float = float(stat_map[stat_id])
				var current: float = character_data.base_stats.get(stat_id, 0.0)
				character_data.base_stats[stat_id] = snappedf(current + delta, 0.1)
				applied_bonuses.append({
					"stat_id":   stat_id,
					"delta":     delta,
					"threshold": threshold,
				})

			print("[MinigameRecordSystem] ★ RÉCORD: %s ≥%d%% → bonuses: %s" % [
				MINIGAME_NAMES.get(minigame_id, minigame_id),
				threshold,
				str(stat_map)
			])

	if not applied_bonuses.is_empty():
		var bus := get_node_or_null("/root/EventBus")
		if bus != null and bus.has_signal("minigame_record_broken"):
			bus.minigame_record_broken.emit(minigame_id, old_score, new_score, applied_bonuses)

	return applied_bonuses

## Retorna el récord actual de un minijuego (0.0 si nunca jugado).
func get_record(minigame_id: String, character_data) -> float:
	if character_data == null:
		return 0.0
	_ensure_fields(character_data)
	return float(character_data.minigame_records.get(minigame_id, 0.0))

## Retorna todos los récords como Array[Dictionary] para la UI.
## Cada entrada: { id, name, score, next_threshold, next_bonus }
func get_all_records(character_data) -> Array:
	if character_data == null:
		return []
	_ensure_fields(character_data)
	var result: Array = []
	for minigame_id: String in RECORD_BONUSES.keys():
		var score: float = float(character_data.minigame_records.get(minigame_id, 0.0))
		var next_t: int  = _next_threshold(minigame_id, score, character_data)
		var next_b       = _next_bonus_map(minigame_id, next_t)
		result.append({
			"id":             minigame_id,
			"name":           MINIGAME_NAMES.get(minigame_id, minigame_id),
			"score":          score,
			"next_threshold": next_t,
			"next_bonus":     next_b,
		})
	return result

# ─────────────────────────────────────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────────────────────────────────────

func _ensure_fields(data) -> void:
	if data.get("minigame_records") == null:
		data.minigame_records = {}
	if data.get("minigame_milestones") == null:
		data.minigame_milestones = {}

func _next_threshold(minigame_id: String, current_score: float, data) -> int:
	var milestones: Dictionary = data.minigame_milestones if data.get("minigame_milestones") != null else {}
	var thresholds: Array = RECORD_BONUSES.get(minigame_id, [])
	for entry: Array in thresholds:
		var t: int = entry[0]
		var key: String = "%s_%d" % [minigame_id, t]
		if not milestones.get(key, false):
			return t
	return -1  # todos los umbrales obtenidos

func _next_bonus_map(minigame_id: String, threshold: int) -> Dictionary:
	if threshold < 0:
		return {}
	var thresholds: Array = RECORD_BONUSES.get(minigame_id, [])
	for entry: Array in thresholds:
		if entry[0] == threshold:
			return entry[1]
	return {}
