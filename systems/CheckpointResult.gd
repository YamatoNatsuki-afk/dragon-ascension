# systems/CheckpointResult.gd
# RefCounted — efímero, se crea al evaluar un checkpoint y se pasa por EventBus.
# Contiene todo lo que consumidores (DebugDayLoop, UI) necesitan para reaccionar.
class_name CheckpointResult
extends RefCounted

var checkpoint: CheckpointDefinition
var grade: PerformanceEvaluator.Grade
var power_score: float
var expected_score: float
var performance_ratio: float       # actual / esperado
var build_identity: BuildProfile   # Build dominante en el momento del checkpoint
var build_fit_score: float         # Qué tan bien encaja con ese perfil (0–1)
var narrative_text: String
var stat_delta: Dictionary         # stat_id → delta aplicado (recompensa o penalización)
var all_build_scores: Array        # Array[Dictionary] con todos los perfiles y sus scores

## Construye el texto narrativo desde el checkpoint + grade.
func resolve_narrative() -> String:
	match grade:
		PerformanceEvaluator.Grade.EXCEPTIONAL:
			return checkpoint.narrative_exceptional \
				if checkpoint.narrative_exceptional != "" \
				else "Rendimiento excepcional en el checkpoint."
		PerformanceEvaluator.Grade.HIGH:
			return checkpoint.narrative_high \
				if checkpoint.narrative_high != "" \
				else "Buen progreso. Sigue así."
		PerformanceEvaluator.Grade.NORMAL:
			return checkpoint.narrative_normal \
				if checkpoint.narrative_normal != "" \
				else "Progreso estable. El camino es largo."
		PerformanceEvaluator.Grade.LOW:
			return checkpoint.narrative_low \
				if checkpoint.narrative_low != "" \
				else "El progreso es inferior al esperado. Reconsidera tu entrenamiento."
	return ""
