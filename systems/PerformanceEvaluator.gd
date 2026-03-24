# systems/PerformanceEvaluator.gd
# Clase estática pura. Calcula el rendimiento del personaje en un día dado.
#
# El "power score" es RELATIVO al build — no es suma bruta de stats.
# Un striker se mide principalmente por fuerza + velocidad.
# Un ki-focused por ki_max + (algo de defensa).
# Esto evita que comparar un tanque con un striker sea injusto.
class_name PerformanceEvaluator
extends RefCounted

enum Grade { LOW, NORMAL, HIGH, EXCEPTIONAL }

# Curva de progreso esperado por día: base_power_per_day × día_actual.
# Estos valores asumen que el jugador elige acciones de forma razonable.
# Ajustar si el balance de TrainingAction cambia.
const EXPECTED_POWER_PER_DAY := 1.8
const EXCEPTIONAL_THRESHOLD  := 1.30   # 30% por encima = excepcional
const HIGH_THRESHOLD          := 1.10   # 10% por encima = alto
const LOW_THRESHOLD           := 0.75   # 25% por debajo = bajo

# ─────────────────────────────────────────────
# API pública
# ─────────────────────────────────────────────

## Calcula el power score del personaje ponderado por su build.
## Rango típico: 0 – 300+ (no hay cap, escala con el juego).
static func compute_power_score(data: CharacterData) -> float:
	var weights := data.build.stat_priority_weights
	var score: float = 0.0

	for stat_id: StringName in data.base_stats.keys():
		var val: float      = data.base_stats[stat_id]
		var priority: float = weights.get(stat_id, 0.5)
		# Stats prioritarios contribuyen más al score.
		# Fórmula: stat_value × (0.5 + priority)
		# priority=1.0 → factor 1.5×, priority=0.0 → factor 0.5×
		score += val * (0.5 + priority)

	return score

## Clasifica el rendimiento comparando el score actual con la expectativa.
static func grade(data: CharacterData) -> Grade:
	var actual   := compute_power_score(data)
	var expected := _expected_score(data.current_day)
	var ratio    := actual / max(1.0, expected)

	if ratio >= EXCEPTIONAL_THRESHOLD: return Grade.EXCEPTIONAL
	if ratio >= HIGH_THRESHOLD:        return Grade.HIGH
	if ratio >= LOW_THRESHOLD:         return Grade.NORMAL
	return Grade.LOW

## Devuelve el ratio actual/esperado como float.
## Útil para gráficas y para que CheckpointSystem evalúe la distancia.
static func performance_ratio(data: CharacterData) -> float:
	var actual   := compute_power_score(data)
	var expected := _expected_score(data.current_day)
	return actual / max(1.0, expected)

## Nombre legible del grade para logging y UI.
static func grade_label(g: Grade) -> String:
	match g:
		Grade.EXCEPTIONAL: return "EXCEPCIONAL"
		Grade.HIGH:        return "ALTO"
		Grade.NORMAL:      return "NORMAL"
		Grade.LOW:         return "BAJO"
	return "DESCONOCIDO"

## Descripción del grade con contexto narrativo.
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
# Curva de expectativa
# ─────────────────────────────────────────────

## Score esperado para un día dado.
## Usa la misma curva logarítmica que DifficultyScaler.reward_multiplier
## para que la expectativa escale igual que las recompensas reales.
static func _expected_score(day: int) -> float:
	# Acumulado desde día 1 hasta día N de: EXPECTED_POWER_PER_DAY × reward_mult(d)
	# Aproximado con integral: base × (N × log(N) - N + 1) × factor
	var n := float(max(1, day))
	return EXPECTED_POWER_PER_DAY * (n * log(n) - n + 1.0) * 1.2
