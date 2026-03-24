# res://data/checkpoints/CheckpointOutcome.gd
# Resource inline que vive como sub-resource dentro de un CheckpointDefinition.tres.
# Define qué pasa cuando el personaje alcanza un grade determinado en un checkpoint.
# UN SOLO class_name por archivo — CheckpointDefinition está en su propio archivo.
class_name CheckpointOutcome
extends Resource

# Grade mínimo para activar este outcome (valores del enum Grade de PerformanceEvaluator).
# CheckpointDefinition.get_outcome_for_grade() elige el de min_grade más alto que aplique.
#   LOW=0: siempre aplica como fallback
#   NORMAL=1, HIGH=2, EXCEPTIONAL=3: aplican si el personaje está en ese nivel o superior
@export_enum("LOW:0", "NORMAL:1", "HIGH:2", "EXCEPTIONAL:3")
var min_grade: int = 0

@export var narrative: String = ""

# Subclases de CheckpointConsequence — cada una en su propio archivo en data/consequences/
@export var consequences: Array[CheckpointConsequence] = []
