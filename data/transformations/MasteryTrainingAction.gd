# res://data/transformations/MasteryTrainingAction.gd
#
# Acción de entrenamiento especializada para dominar una transformación.
# Aparece en DayScreen solo si la transformación está desbloqueada.
#
# DIFERENCIAS CON TrainingAction normal:
#   - Usa TransformationSystem.add_mastery() en lugar de subir stats directamente
#   - Los stats primario/secundario suben como efecto secundario del entrenamiento
#   - Con maestría ≥ 75% activa el "entrenamiento pesado" (×2 gains de stats)
#   - Requiere el flag de desbloqueo de la transformación como condición

class_name MasteryTrainingAction
extends DayAction

## ID de la transformación que entrena.
@export var transform_id: StringName = &""

## XP de maestría ganada por ejecución (antes de escalado).
@export var base_mastery_xp: float = 20.0

## Stats que suben como efecto secundario del entrenamiento.
## [0] = stat primario (gain completo), [1+] = stats secundarios (gain × 0.4)
@export var target_stats: Array[StringName] = []

## Ganancia base del stat primario.
@export var base_stat_gain: float = 1.5

## Mostrar en la UI como tipo "maestro" para que aparezca en la sección correcta.
var display_category: StringName = &"maestro"

# ─────────────────────────────────────────────────────────────────────────────

func is_available(ctx: DayContext) -> bool:
	# Solo disponible si la transformación está desbloqueada
	var ts = ctx.character_data.get("transformation_state")
	if ts == null:
		return false
	return ts.is_unlocked(transform_id)

func execute(ctx: DayContext) -> DayActionResult:
	var result    := DayActionResult.new()
	var day_scale := DifficultyScaler.reward_multiplier(ctx.day_number)
	result.action_type = &"training"

	# Verificar transformación desbloqueada
	var ts = ctx.character_data.get("transformation_state")
	if ts == null or not ts.is_unlocked(transform_id):
		result.success = false
		result.narrative_key = &"transform.not_unlocked"
		return result

	# Maestría actual — determina si hay entrenamiento pesado
	var current_mastery: float = ts.get_mastery(transform_id)
	var root: Node = (Engine.get_main_loop() as SceneTree).root
	var tr_node: Node = root.get_node_or_null("TransformationRegistry")
	var def = tr_node.get_definition(transform_id) if tr_node != null else null
	var heavy: bool = def != null and def.has_heavy_training(current_mastery)
	var heavy_mult: float = 2.0 if heavy else 1.0

	# Acceder a TransformationSystem por path
	var ts_node: Node = root.get_node_or_null("TransformationSystem")

	var mastery_xp := base_mastery_xp * day_scale * heavy_mult
	var crossed: bool = false
	if ts_node != null:
		crossed = ts_node.add_mastery(ctx.character_data, transform_id, mastery_xp)

	result.success        = true
	result.narrative_key  = StringName("transform.mastery.%s" % str(transform_id))
	result.xp_gained      = mastery_xp * 2.5   # XP de progresión también sube

	# Stats secundarios del entrenamiento
	for i: int in target_stats.size():
		var stat_id: StringName = target_stats[i]
		var weight: float = ctx.character_data.build.stat_priority_weights.get(stat_id, 0.5)
		var gain_raw: float
		if i == 0:
			gain_raw = base_stat_gain * day_scale * (0.5 + weight) * heavy_mult
		else:
			gain_raw = base_stat_gain * day_scale * (0.5 + weight) * 0.4 * heavy_mult
		var variance := DifficultyScaler.apply_variance(gain_raw, 0.15, ctx.rng) - gain_raw
		result.stat_changes[stat_id] = snappedf(gain_raw + variance, 0.1)

	# Si cruzó un umbral de maestría, agregar nota en extra_data
	if crossed and ts_node != null:
		var ts_state = ctx.character_data.get("transformation_state")
		if ts_state != null:
			var new_mastery: float = ts_state.get_mastery(transform_id)
			result.extra_data["mastery_milestone"] = new_mastery
			result.extra_data["mastery_label"]     = ts_state.get_mastery_label(transform_id)
		ts_node.check_unlock_conditions(ctx.character_data)

	return result

func get_display_category() -> StringName:
	return display_category
