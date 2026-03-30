# res://data/npcs/NpcTrainingAction.gd
#
# Acción de entrenamiento especial que aparece cuando un NPC es aliado.
# Aparece en la sección "MAESTROS" del DayScreen.
#
# Diferencias con TrainingAction normal:
#   - Usa los multipliers del NpcSystem (más altos que el base)
#   - Avanza la relación con el NPC (hacia MAESTRO con ≥10 entrenamientos)
#   - Muestra una cita del NPC en el resultado
#   - Costo de energía más alto (requiere más esfuerzo)
#
# Se crea DINÁMICAMENTE por NpcSystem — no hay .tres en disco.

class_name NpcTrainingAction
extends DayAction

## ID del NPC que entrena con el personaje.
var npc_id: StringName = &""

## Categoría para el router de DayScreen.
var display_category: StringName = &"maestro"

# ─────────────────────────────────────────────────────────────────────────────

func _init(def: NpcDefinition) -> void:
	if def == null:
		return
	npc_id       = def.id
	id           = StringName("npc_train_%s" % str(def.id))
	display_name = "Entrenar con %s" % def.display_name
	action_type  = &"training"

func is_available(ctx: DayContext) -> bool:
	var npc_sys: Node = (Engine.get_main_loop() as SceneTree).root.get_node_or_null("NpcSystem")
	if npc_sys == null:
		return false
	var nrs = ctx.character_data.get("npc_relation_state")
	if nrs == null:
		return false
	return nrs.is_ally(npc_id)

func execute(ctx: DayContext) -> DayActionResult:
	var result := DayActionResult.new()
	result.action_type = &"training"

	var npc_sys: Node = (Engine.get_main_loop() as SceneTree).root.get_node_or_null("NpcSystem")
	if npc_sys == null:
		result.success = false
		return result

	var def: NpcDefinition = npc_sys.get_definition(npc_id)
	if def == null:
		result.success = false
		return result

	# Verificar relación
	var nrs = ctx.character_data.get("npc_relation_state")
	if nrs == null or not nrs.is_ally(npc_id):
		result.success = false
		return result

	var relation: int = nrs.get_relation(npc_id)
	var day_scale := DifficultyScaler.reward_multiplier(ctx.day_number)

	# Calcular ganancias con multipliers del aliado
	for i: int in def.training_target_stats.size():
		var stat_id: StringName = def.training_target_stats[i]
		var mult: float         = def.get_training_mult(stat_id, relation)
		var weight: float       = ctx.character_data.build.stat_priority_weights.get(stat_id, 0.5)
		var weight_factor: float = 0.7 + weight * 0.6   # rango 0.7–1.3 según build
		var gain_raw: float
		if i == 0:
			gain_raw = def.training_base_gain * day_scale * mult * weight_factor
		else:
			gain_raw = def.training_base_gain * day_scale * mult * weight_factor * 0.55
		var variance := DifficultyScaler.apply_variance(gain_raw, 0.12, ctx.rng) - gain_raw
		result.stat_changes[stat_id] = snappedf(gain_raw + variance, 0.1)

	# XP extra por entrenar con aliado
	result.xp_gained = def.training_base_gain * day_scale * 25.0 * (1.2 if relation == 4 else 1.0)
	result.success   = true

	# Registrar interacción y avanzar relación
	npc_sys.register_training(npc_id, ctx.character_data)

	# Cita del NPC como narrative_key personalizada
	var quote := def.get_random_quote()
	result.narrative_key = StringName("npc.train.%s" % str(npc_id))
	if not quote.is_empty():
		result.extra_data["npc_quote"] = quote
		result.extra_data["npc_name"]  = def.display_name
		result.extra_data["npc_color"] = def.color

	return result

func get_display_category() -> StringName:
	return display_category
