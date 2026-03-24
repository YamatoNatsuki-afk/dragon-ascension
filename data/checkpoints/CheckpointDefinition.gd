# data/checkpoints/CheckpointDefinition.gd
# Resource configurable en el editor. Define QUÉ pasa en un checkpoint.
# No contiene lógica — eso lo hace CheckpointSystem.
class_name CheckpointDefinition
extends Resource

@export var id: StringName
@export var trigger_day: int         # Día exacto en que se evalúa
@export var display_name: String     # "El Primer Mes"

# Texto narrativo por resultado — claves para localización futura
@export var narrative_exceptional: String = ""
@export var narrative_high: String        = ""
@export var narrative_normal: String      = ""
@export var narrative_low: String         = ""

# Recompensas por rendimiento alto/excepcional (aplicadas vía EventBus)
@export var reward_high_stat: StringName  = &""
@export var reward_high_amount: float     = 0.0

# Penalización por rendimiento bajo
@export var penalty_low_stat: StringName  = &""
@export var penalty_low_amount: float     = 0.0

# Si true, el checkpoint bloquea el avance hasta que el jugador
# alcance un score mínimo. Para Fase 1 déjalo en false.
@export var is_blocking: bool = false
@export var min_score_to_pass: float = 0.0
