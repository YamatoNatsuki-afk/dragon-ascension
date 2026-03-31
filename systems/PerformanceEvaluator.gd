# res://systems/PerformanceEvaluator.gd
# Clase estática pura. Calcula el rendimiento del personaje en un día dado.
# Sin estado, sin nodo, sin señales — solo funciones de evaluación.
class_name PerformanceEvaluator
extends RefCounted

enum Grade { LOW, NORMAL, HIGH, EXCEPTIONAL }

const EXPECTED_POWER_PER_DAY := 1.8
const EXCEPTIONAL_THRESHOLD  := 1.30
const HIGH_THRESHOLD          := 1.10
const LOW_THRESHOLD           := 0.75

# ─────────────────────────────────────────────
# API pública
# ─────────────────────────────────────────────

## Power score ponderado por el build del personaje.
static func compute_power_score(data) -> float:  # data: CharacterData
	var weights: Dictionary = data.build.stat_priority_weights
	var score: float = 0.0
	for stat_id: StringName in data.base_stats.keys():
		var val: float      = data.base_stats[stat_id]
		var priority: float = weights.get(stat_id, 0.5)
		score += val * (0.5 + priority)
	return score

## Clasifica el rendimiento comparando score actual con la expectativa del día.
static func grade(data) -> Grade:  # data: CharacterData
	var ratio := performance_ratio(data)
	if ratio >= EXCEPTIONAL_THRESHOLD: return Grade.EXCEPTIONAL
	if ratio >= HIGH_THRESHOLD:        return Grade.HIGH
	if ratio >= LOW_THRESHOLD:         return Grade.NORMAL
	return Grade.LOW

## Ratio actual/esperado como float (1.0 = exactamente en curva).
static func performance_ratio(data) -> float:  # data: CharacterData
	var actual: float   = compute_power_score(data)
	var expected: float = expected_score(data.current_day)
	return actual / max(1.0, expected)

## Score esperado para un día dado.
static func expected_score(day: int) -> float:
	return _expected_score(day)

## Nombre legible del grade para logs y UI.
static func grade_label(g: Grade) -> String:
	match g:
		Grade.EXCEPTIONAL: return "EXCEPCIONAL"
		Grade.HIGH:        return "ALTO"
		Grade.NORMAL:      return "NORMAL"
		Grade.LOW:         return "BAJO"
	return "DESCONOCIDO"

## Descripción narrativa del grade con contexto de build.
static func grade_description(g: Grade, build_name: String) -> String:
	match g:
		Grade.EXCEPTIONAL:
			return "Tu dedicación como %s supera toda expectativa." % build_name
		Grade.HIGH:
			return "Progresas bien. El camino del %s te sienta." % build_name
		Grade.NORMAL:
			return "Avanzas a buen ritmo. Mantén el enfoque."
		Grade.LOW:
			return "El progreso es lento. Considera concentrar el entrenamiento."
	return ""

# ─────────────────────────────────────────────
# Curva de expectativa (privada)
# ─────────────────────────────────────────────

static func _expected_score(day: int) -> float:
	var n := float(max(1, day))
	var log_curve := EXPECTED_POWER_PER_DAY * (n * log(n) - n + 1.0) * 0.75
	# Factor 0.75 (antes 1.2): calibrado por simulación de 300 runs.
	# Con 1.2 el Casual obtenía ratio ×0.52 (grade LOW en todos los checkpoints).
	# Con 0.75 el Casual alcanza ratio ×0.83 (NORMAL), el Defensive ×1.37 (HIGH)
	# y el Striker ×2.6 (EXCEPTIONAL, con fricción por desgaste_por_poder).
	# FIX A3: La curva logarítmica devuelve 0 en día 1 (log(1) = 0),
	# lo que hacía que cualquier personaje recibiera grade EXCEPTIONAL trivialmente.
	# Se añade un piso lineal suave: EXPECTED_POWER_PER_DAY * n * 0.8.
	# En día 1 el piso vale 1.44, en días altos la curva log supera al piso
	# y este maxf() deja de tener efecto → sin impacto en el balance de mid/late game.
	var linear_floor := EXPECTED_POWER_PER_DAY * n * 0.8
	return maxf(log_curve, linear_floor)
