# res://data/checkpoints/CheckpointDefinition.gd
# Resource que define un checkpoint: qué día se activa y qué outcomes produce.
# UN SOLO class_name por archivo — CheckpointOutcome está en su propio archivo.
class_name CheckpointDefinition
extends Resource

@export var id: StringName
@export var trigger_day: int
@export var display_name: String

# Array de CheckpointOutcome. CheckpointSystem elige el de min_grade más alto que aplique.
# Configúralos como sub-recursos en el Inspector del editor.
@export var outcomes: Array[CheckpointOutcome] = []

# Si true, el run no puede continuar hasta alcanzar min_score_to_pass.
# Mantener en false durante el prototipo.
@export var is_blocking: bool        = false
@export var min_score_to_pass: float = 0.0

## Devuelve el outcome apropiado para el grade recibido.
## Elige el de min_grade más alto que sea <= al grade del jugador.
## Si ninguno aplica (array vacío), devuelve null — CheckpointSystem maneja el fallback.
func get_outcome_for_grade(grade: PerformanceEvaluator.Grade) -> CheckpointOutcome:
	var best: CheckpointOutcome = null
	for outcome: CheckpointOutcome in outcomes:
		if outcome.min_grade <= int(grade):
			if best == null or outcome.min_grade > best.min_grade:
				best = outcome
	return best
