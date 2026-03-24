# res://systems/PerformanceEvaluator.gd
# Clase estática pura. Calcula el rendimiento del personaje en un día dado.
# Sin estado, sin nodo, sin señales — solo funciones de evaluación.
#
# El "power score" es RELATIVO al build: un striker se mide por fuerza + velocidad,
# un ki-user por ki_max. Comparar builds distintos es injusto en términos absolutos.
class_name PerformanceEvaluator
extends RefCounted

enum Grade { LOW, NORMAL, HIGH, EXCEPTIONAL }

# Curva de progreso esperado: asume que el jugador elige acciones razonables.
# Ajustar si el balance de TrainingAction cambia significativamente.
const EXPECTED_POWER_PER_DAY := 1.8
const EXCEPTIONAL_THRESHOLD  := 1.30   # 30% por encima = EXCEPTIONAL
const HIGH_THRESHOLD          := 1.10   # 10% por encima = HIGH
const LOW_THRESHOLD           := 0.75   # 25% por debajo = LOW

# ─────────────────────────────────────────────
# API pública
# ─────────────────────────────────────────────

## Power score ponderado por el build del personaje.
## Stats prioritarios contribuyen más. Rango típico: 0–300+
static func compute_power_score(data: CharacterData) -> float:
	var weights := data.build.stat_priority_weights
	var score: float = 0.0
	for stat_id: StringName in data.base_stats.keys():
		var val: float      = data.base_stats[stat_id]
		var priority: float = weights.get(stat_id, 0.5)
		# priority=1.0 → factor 1.5×,  priority=0.0 → factor 0.5×
		score += val * (0.5 + priority)
	return score

## Clasifica el rendimiento comparando score actual con la expectativa del día.
static func grade(data: CharacterData) -> Grade:
	var ratio := performance_ratio(data)
	if ratio >= EXCEPTIONAL_THRESHOLD: return Grade.EXCEPTIONAL
	if ratio >= HIGH_THRESHOLD:        return Grade.HIGH
	if ratio >= LOW_THRESHOLD:         return Grade.NORMAL
	return Grade.LOW

## Ratio actual/esperado como float (1.0 = exactamente en curva).
static func performance_ratio(data: CharacterData) -> float:
	var actual   := compute_power_score(data)
	var expected := expected_score(data.current_day)
	return actual / max(1.0, expected)

## Score esperado para un día dado — API PÚBLICA.
## Usar este método desde sistemas externos (CheckpointSystem, UI).
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

## Score acumulado esperado para el día N.
## Usa curva logarítmica para que la dificultad escale igual que las recompensas.
## PRIVADO — acceder vía expected_score() desde sistemas externos.
static func _expected_score(day: int) -> float:
	var n := float(max(1, day))
	return EXPECTED_POWER_PER_DAY * (n * log(n) - n + 1.0) * 1.2
