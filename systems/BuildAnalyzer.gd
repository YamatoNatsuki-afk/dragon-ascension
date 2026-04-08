# res://systems/BuildAnalyzer.gd
#
# Clase estática pura. Sin estado persistente entre frames, sin nodo, sin señales.
# Analiza CharacterData y determina la identidad del build actual.
#
# DISEÑO DEL SCORE:
#   score = (intention_score + execution_score) * 0.5
#
#   intention_score → qué stats priorizó el jugador (stat_priority_weights)
#   execution_score → qué stats son dominantes en sus base_stats reales
#
#   Combinar ambos permite detectar tensiones interesantes:
#   "Querías ser Striker pero has entrenado Ki — ¿cambio de identidad?"
#
# PERFILES:
#   Cargados desde res://data/analysis/profiles/*.tres si existen.
#   Fallback a perfiles hardcodeados si la carpeta está vacía o no existe.
#   Los .tres tienen prioridad — son la fuente canónica en producción.

class_name BuildAnalyzer
extends RefCounted

const PROFILES_PATH := "res://data/analysis/profiles/"

# Cache estático — se carga una vez por sesión, se reutiliza siempre.
static var _profiles: Array[BuildProfile] = []
static var _profiles_loaded: bool = false

# ─────────────────────────────────────────────────────────────────────────────
# API pública
# ─────────────────────────────────────────────────────────────────────────────

## Devuelve el BuildProfile que mejor encaja con el personaje actual.
static func get_build_identity(data) -> BuildProfile:  # data: CharacterData
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
static func get_fit_score(data, profile_id: StringName) -> float:  # data: CharacterData
	_ensure_profiles_loaded()
	for profile: BuildProfile in _profiles:
		if profile.id == profile_id:
			return _compute_fit_score(data, profile)
	return 0.0

## Devuelve todos los perfiles con sus scores, ordenados de mayor a menor.
static func get_all_scores(data) -> Array[Dictionary]:  # data: CharacterData
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
static func has_identity_changed(prev_id: StringName, data) -> bool:  # data: CharacterData
	var current := get_build_identity(data)
	return current != null and current.id != prev_id

## Fuerza la recarga de perfiles desde disco.
## Útil durante desarrollo si se modifican los .tres sin reiniciar.
static func reload_profiles() -> void:
	_profiles_loaded = false
	_profiles.clear()
	_ensure_profiles_loaded()

# ─────────────────────────────────────────────────────────────────────────────
# Cálculo del score de ajuste
# ─────────────────────────────────────────────────────────────────────────────

static func _compute_fit_score(data, profile: BuildProfile) -> float:
	# Balanced es el perfil residual: gana cuando nadie más gana claramente.
	# Su score base es 0.35 — suficiente para ganar si los demás tienen 0,
	# pero vencible fácilmente por cualquier perfil con intención real.
	if profile.required_high_stats.is_empty():
		return 0.35

	var intention_score := _score_intention(data, profile)
	var execution_score := _score_execution(data, profile)
	return (intention_score + execution_score) * 0.5

static func _score_intention(data, profile: BuildProfile) -> float:
	if data.build == null:
		return 0.0

	var weights: Dictionary = data.build.stat_priority_weights
	var score: float = 0.0
	var checks: int  = 0

	for stat_id: StringName in profile.required_high_stats:
		var w: float = weights.get(stat_id, 0.0)
		score += clampf(w / profile.threshold_high, 0.0, 1.0)
		checks += 1

	for stat_id: StringName in profile.penalized_stats:
		var w: float = weights.get(stat_id, 0.0)
		score += clampf(1.0 - (w / profile.threshold_high), 0.0, 1.0)
		checks += 1

	return score / float(maxi(1, checks))

static func _score_execution(data, profile: BuildProfile) -> float:
	var total: float = 0.0
	for val: float in data.base_stats.values():
		total += val
	if total <= 0.0:
		return 0.0

	var score: float = 0.0
	var checks: int  = 0

	for stat_id: StringName in profile.required_high_stats:
		var val: float        = data.base_stats.get(stat_id, 0.0)
		var proportion: float = val / total
		score += clampf(proportion / 0.20, 0.0, 1.0)
		checks += 1

	for stat_id: StringName in profile.penalized_stats:
		var val: float        = data.base_stats.get(stat_id, 0.0)
		var proportion: float = val / total
		score += clampf(1.0 - (proportion / 0.20), 0.0, 1.0)
		checks += 1

	return score / float(maxi(1, checks))

# ─────────────────────────────────────────────────────────────────────────────
# Carga de perfiles
# ─────────────────────────────────────────────────────────────────────────────

static func _ensure_profiles_loaded() -> void:
	if _profiles_loaded:
		# FIX B3: En debug, invalidar el cache para reflejar cambios de .tres
		# sin necesitar reiniciar el editor o el juego.
		# En producción el cache es permanente para evitar lecturas de disco repetidas.
		if OS.is_debug_build():
			_profiles_loaded = false
			_profiles.clear()
		else:
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
		push_warning("BuildAnalyzer: sin perfiles en '%s'. Usando fallback por código." \
			% PROFILES_PATH)
		_load_fallback_profiles()

	_profiles_loaded = true

## Perfiles hardcodeados como fallback si no existen .tres en disco.
## MIGRACIÓN v2: IDs actualizados a los 8 stats canónicos.
## Estos deben coincidir exactamente con los .tres en data/analysis/profiles/.
static func _load_fallback_profiles() -> void:

	# ── Striker — físico agresivo ────────────────────────────────────────
	# Domina con fuerza + velocidad + instinto de combate.
	# No invierte en Ki ni Control de Ki.
	var striker                  := BuildProfile.new()
	striker.id                    = &"striker"
	striker.display_name          = "Striker"
	striker.description           = "Fuerza y velocidad. Golpea rápido, golpea fuerte."
	striker.required_high_stats   = [&"fuerza", &"velocidad", &"intel_combate"]
	striker.penalized_stats       = [&"ki", &"poder_ki"]
	striker.threshold_high        = 0.7
	striker.profile_color         = Color(0.9, 0.2, 0.1)
	_profiles.append(striker)

	# ── Ki User — maestro de energía ─────────────────────────────────────
	# Domina con ki + poder_ki. La velocidad apoya para disparar blast.
	# Fuerza y resistencia quedan relegadas.
	var ki_user                  := BuildProfile.new()
	ki_user.id                    = &"ki_user"
	ki_user.display_name          = "Ki User"
	ki_user.description           = "Ki y Control. El camino de las técnicas de energía."
	ki_user.required_high_stats   = [&"ki", &"poder_ki", &"velocidad"]
	ki_user.penalized_stats       = [&"fuerza", &"resistencia"]
	ki_user.threshold_high        = 0.7
	ki_user.profile_color         = Color(0.1, 0.5, 1.0)
	_profiles.append(ki_user)

	# ── Defensive — bastión inamovible ───────────────────────────────────
	# Domina con vitalidad + resistencia. No invierte en velocidad.
	# Antes llamado "tank" — renombrado para coincidir con BuildData.COMBAT_STYLES.
	var defensive                := BuildProfile.new()
	defensive.id                  = &"defensive"
	defensive.display_name        = "Defensive"
	defensive.description         = "Vitalidad y resistencia. Imposible de derribar."
	defensive.required_high_stats = [&"vitalidad", &"resistencia"]
	defensive.penalized_stats     = [&"velocidad"]
	defensive.threshold_high      = 0.7
	defensive.profile_color       = Color(0.4, 0.8, 0.3)
	_profiles.append(defensive)

	# ── Balanced — guerrero completo ─────────────────────────────────────
	# Sin required_high_stats — perfil residual.
	# Gana cuando ningún otro supera su score base de 0.35.
	var balanced                 := BuildProfile.new()
	balanced.id                   = &"balanced"
	balanced.display_name         = "Balanced"
	balanced.description          = "Sin especialización clara. Versátil pero sin pico dominante."
	balanced.required_high_stats  = []
	balanced.penalized_stats      = []
	balanced.threshold_high       = 0.5
	balanced.profile_color        = Color(0.7, 0.7, 0.7)
	_profiles.append(balanced)
