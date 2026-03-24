# res://systems/CheckpointResult.gd
# RefCounted efímero — se crea al evaluar un checkpoint y se distribuye por EventBus.
# Contiene todo lo que consumidores (UI, DebugDayLoop, ProgressTracker) necesitan.
#
# CAMBIOS respecto a versión anterior:
#   + active_outcome añadido (CheckpointSystem lo asignaba pero el campo no existía)
#   - resolve_narrative() ELIMINADO — referenciaba propiedades que no existen en
#     CheckpointDefinition. La narrativa la resuelve CheckpointSystem directamente
#     desde active_outcome.narrative y lo asigna a narrative_text.
class_name CheckpointResult
extends RefCounted

var checkpoint: CheckpointDefinition
var active_outcome: CheckpointOutcome    # Outcome que se aplicó (puede ser null)
var grade: PerformanceEvaluator.Grade
var power_score: float
var expected_score: float
var performance_ratio: float             # actual / esperado (1.0 = exactamente en curva)
var build_identity: BuildProfile         # Arquetipo dominante en este checkpoint
var build_fit_score: float               # Qué tan bien encaja con ese perfil (0–1)
var narrative_text: String               # Texto listo para mostrar en UI
var stat_delta: Dictionary               # stat_id → delta aplicado por las consecuencias
var all_build_scores: Array              # Array[Dictionary{profile, score}] ordenado desc
