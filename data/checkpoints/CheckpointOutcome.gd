# data/checkpoints/CheckpointOutcome.gd
# Resource inline que vive dentro de un CheckpointDefinition.tres.
# Define qué pasa cuando el personaje alcanza un grade determinado.
class_name CheckpointOutcome
extends Resource

# Grade mínimo para activar este outcome.
# Si el personaje tiene ESTE grade o superior, se ejecutan las consecuencias.
# Permite tener outcomes solapados:
#   outcome_low:    min_grade = LOW   (siempre se evalúa)
#   outcome_normal: min_grade = NORMAL
#   outcome_high:   min_grade = HIGH
# CheckpointSystem busca el outcome de grade más alto que aplique.
@export_enum("LOW:0", "NORMAL:1", "HIGH:2", "EXCEPTIONAL:3")
var min_grade: int = 0

@export var narrative: String = ""

# Array de Resources que implementan CheckpointConsequence
@export var consequences: Array[CheckpointConsequence] = []


# ─────────────────────────────────────────────────────────────────────────────


# data/checkpoints/CheckpointDefinition.gd  (versión refactorizada)
# Reemplaza las propiedades sueltas (reward_high_stat, penalty_low_stat, etc.)
# con un array de CheckpointOutcome. Extensible sin tocar el schema.
class_name CheckpointDefinition
extends Resource

@export var id: StringName
@export var trigger_day: int
@export var display_name: String

# Array de outcomes. CheckpointSystem elige el de grade más alto que aplique.
# Configura estos como sub-recursos en el editor.
@export var outcomes: Array[CheckpointOutcome] = []

# Si true, el run no puede continuar hasta alcanzar min_score_to_pass.
# Para las primeras fases déjalo en false.
@export var is_blocking: bool         = false
@export var min_score_to_pass: float  = 0.0

## Devuelve el outcome apropiado para el grade dado.
## Elige el de min_grade más alto que sea <= el grade del jugador.
## Garantiza que siempre hay un outcome activo si hay al menos uno con LOW.
func get_outcome_for_grade(grade: PerformanceEvaluator.Grade) -> CheckpointOutcome:
	var best: CheckpointOutcome = null

	for outcome: CheckpointOutcome in outcomes:
		if outcome.min_grade <= int(grade):
			if best == null or outcome.min_grade > best.min_grade:
				best = outcome

	return best
