# systems/BuildAnalyzer.gd
# Clase estática pura. Sin estado, sin nodo, sin señales.
# Analiza CharacterData y determina la identidad del build actual.
#
# Diseño intencional: el resultado combina stat_priority_weights (intención
# del jugador) con base_stats reales (ejecución del jugador). Un personaje
# puede QUERER ser striker pero haber entrenado Ki — esa tensión es información
# valiosa que el sistema reporta.
class_name BuildAnalyzer
extends RefCounted

const PROFILES_PATH := "res://data/analysis/profiles/"

# Cache de perfiles — se carga una vez, se reutiliza siempre.
# Estático para que persista entre llamadas sin necesitar un nodo.
static var _profiles: Array[BuildProfile] = []
static var _profiles_loaded: bool = false

# ─────────────────────────────────────────────
# API pública
# ─────────────────────────────────────────────

## Devuelve el BuildProfile que mejor encaja con el personaje actual.
## Combina intención (weights) y ejecución (stats reales) en un score único.
static func get_build_identity(data: CharacterData) -> BuildProfile:
	_ensure_profiles_loaded()

	var best_profile: BuildProfile = null
	var best_score: float          = -1.0

	for profile: BuildProfile in _profiles:
		var score := _compute_fit_score(data, profile)
		if score > best_score:
			best_score   = score
			best_profile = profile

	return best_profile

## Devuelve el score de ajuste (0.0–1.0) para un perfil específico.
## Útil para mostrar "qué tan cerca estás de ser un Striker puro".
static func get_fit_score(data: CharacterData, profile_id: StringName) -> float:
	_ensure_profiles_loaded()
	for profile: BuildProfile in _profiles:
		if profile.id == profile_id:
			return _compute_fit_score(data, profile)
	return 0.0

## Devuelve todos los perfiles con sus scores, ordenados de mayor a menor.
## Útil para mostrar afinidades múltiples en la UI.
static func get_all_scores(data: CharacterData) -> Array[Dictionary]:
	_ensure_profiles_loaded()
	var results: Array[Dictionary] = []
	for profile: BuildProfile in _profiles:
		results.append({
			"profile": profile,
			"score":   _compute_fit_score(data, profile)
		})
	results.sort_custom(func(a, b): return a.score > b.score)
	return results

## Detecta si el build actual es diferente al del día anterior.
## DayManager puede llamar esto para emitir build_identity_changed si cambió.
static func has_identity_changed(prev_id: StringName, data: CharacterData) -> bool:
	var current := get_build_identity(data)
	return current != null and current.id != prev_id

# ─────────────────────────────────────────────
# Cálculo del score de ajuste
# ─────────────────────────────────────────────

## Score de ajuste = promedio ponderado de:
##   50% intención  (stat_priority_weights del build)
##   50% ejecución  (distribución real de stats ganados)
##
## Esta ponderación 50/50 tiene una consecuencia jugable interesante:
## si el jugador ignora su build y entrena stats aleatorios, su identidad
## deriva hacia "balanced" aunque haya puesto sus weights en "striker".
## Eso crea tensión narrativa natural.
static func _compute_fit_score(data: CharacterData, profile: BuildProfile) -> float:
	if profile.required_high_stats.is_empty():
		return 0.5  # Perfil mal configurado — score neutro

	# ── Componente de intención (weights del BuildData) ──
	var intention_score := _score_intention(data, profile)

	# ── Componente de ejecución (distribución real de stats) ──
	var execution_score := _score_execution(data, profile)

	# Media ponderada: intención pesa igual que ejecución
	return (intention_score + execution_score) * 0.5

static func _score_intention(data: CharacterData, profile: BuildProfile) -> float:
	var weights := data.build.stat_priority_weights
	var score: float = 0.0
	var checks: int  = 0

	# Stats requeridos: penalizar si el weight es bajo
	for stat_id: StringName in profile.required_high_stats:
		var w: float = weights.get(stat_id, 0.0)
		score += clampf(w / profile.threshold_high, 0.0, 1.0)
		checks += 1

	# Stats penalizados: penalizar si el weight es alto
	for stat_id: StringName in profile.penalized_stats:
		var w: float = weights.get(stat_id, 0.0)
		# Si w está por debajo del umbral bajo, es positivo para este build
		score += clampf(1.0 - (w / profile.threshold_high), 0.0, 1.0)
		checks += 1

	return score / float(maxi(1, checks))

static func _score_execution(data: CharacterData, profile: BuildProfile) -> float:
	# Normalizar stats: convertir a proporciones relativas al total
	var total: float = 0.0
	for val: float in data.base_stats.values():
		total += val
	if total <= 0.0:
		return 0.0

	var score: float = 0.0
	var checks: int  = 0

	for stat_id: StringName in profile.required_high_stats:
		var val: float       = data.base_stats.get(stat_id, 0.0)
		var proportion: float = val / total
		# Un stat "dominante" debería ocupar al menos 20% del total
		score += clampf(proportion / 0.20, 0.0, 1.0)
		checks += 1

	for stat_id: StringName in profile.penalized_stats:
		var val: float        = data.base_stats.get(stat_id, 0.0)
		var proportion: float = val / total
		# Si el stat penalizado ocupa poco del total, es bueno para este build
		score += clampf(1.0 - (proportion / 0.20), 0.0, 1.0)
		checks += 1

	return score / float(maxi(1, checks))

# ─────────────────────────────────────────────
# Carga de perfiles
# ─────────────────────────────────────────────

static func _ensure_profiles_loaded() -> void:
	if _profiles_loaded:
		return
	_profiles.clear()

	var dir := DirAccess.open(PROFILES_PATH)
	if dir != null:
		dir.list_dir_begin()
		var entry := dir.get_next()
		while entry != "":
			if entry.ends_with(".tres"):
				var res := load(PROFILES_PATH + entry)
				if res is BuildProfile:
					_profiles.append(res)
			entry = dir.get_next()
		dir.list_dir_end()

	if _profiles.is_empty():
		push_warning("BuildAnalyzer: sin perfiles en disco. Usando perfiles por código.")
		_load_fallback_profiles()

	_profiles_loaded = true

## Perfiles base creados en código.
## Se activan cuando no hay .tres en data/analysis/profiles/.
## Añadir un .tres a esa carpeta lo reemplaza automáticamente en el siguiente arranque.
static func _load_fallback_profiles() -> void:
	# ── Striker ───────────────────────────────
	var striker          := BuildProfile.new()
	striker.id            = &"striker"
	striker.display_name  = "Striker"
	striker.description   = "Fuerza y velocidad. Golpea rápido, golpea fuerte."
	striker.required_high_stats = [&"strength", &"speed"]
	striker.penalized_stats     = [&"ki_max"]
	striker.threshold_high      = 0.7
	striker.profile_color       = Color(0.9, 0.2, 0.1)
	_profiles.append(striker)

	# ── Ki User ───────────────────────────────
	var ki_user          := BuildProfile.new()
	ki_user.id            = &"ki_user"
	ki_user.display_name  = "Ki User"
	ki_user.description   = "Ki y velocidad. El camino de las técnicas de energía."
	ki_user.required_high_stats = [&"ki_max", &"speed"]
	ki_user.penalized_stats     = [&"strength"]
	ki_user.threshold_high      = 0.7
	ki_user.profile_color       = Color(0.1, 0.5, 1.0)
	_profiles.append(ki_user)

	# ── Tank ──────────────────────────────────
	var tank             := BuildProfile.new()
	tank.id               = &"tank"
	tank.display_name     = "Tank"
	tank.description      = "Defensa y vida. Imposible de derribar."
	tank.required_high_stats = [&"defense", &"health_max"]
	tank.penalized_stats     = [&"speed"]
	tank.threshold_high      = 0.7
	tank.profile_color       = Color(0.4, 0.8, 0.3)
	_profiles.append(tank)

	# ── Balanced ──────────────────────────────
	var balanced          := BuildProfile.new()
	balanced.id            = &"balanced"
	balanced.display_name  = "Balanced"
	balanced.description   = "Sin especialización clara. Versátil pero sin pico dominante."
	balanced.required_high_stats = []   # Ninguno requerido — score neutro siempre
	balanced.penalized_stats     = []
	balanced.threshold_high      = 0.5
	balanced.profile_color       = Color(0.7, 0.7, 0.7)
	_profiles.append(balanced)
