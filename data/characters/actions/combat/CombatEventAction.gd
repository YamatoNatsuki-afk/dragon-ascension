# res://data/actions/combat/CombatEventAction.gd
#
# Acción de día que desencadena un combate en tiempo real.
#
# CONSECUENCIAS REALES:
#   Victoria → XP escalada + stat primario del build sube
#   Derrota  → flag is_dead = true + resistencia/vitalidad suben

class_name CombatEventAction
extends DayAction

@export var difficulty_factor: float = 1.0

func build_result(won: bool, ctx: DayContext) -> DayActionResult:
	var result      := DayActionResult.new()
	var day_scale   := DifficultyScaler.challenge_multiplier(ctx.day_number)
	var enemy_power := 10.0 * day_scale * difficulty_factor

	result.action_type = &"combat"
	result.success     = won

	if won:
		result.narrative_key = &"combat.victory"
		result.xp_gained     = enemy_power * 8.0
		var primary := _primary_combat_stat(ctx)
		var gain    := DifficultyScaler.apply_variance(0.8, 0.3, ctx.rng) * day_scale
		result.stat_changes[primary] = snappedf(gain, 0.1)
	else:
		result.narrative_key  = &"combat.defeat"
		result.xp_gained      = enemy_power * 2.0
		result.flags_to_set.append(&"is_dead")
		result.hp_ratio_at_end = 0.05  # heurística de simulación: derrota = near-death
		result.stat_changes[&"resistencia"] = snappedf(DifficultyScaler.apply_variance(1.2, 0.2, ctx.rng), 0.1)
		result.stat_changes[&"vitalidad"]   = snappedf(DifficultyScaler.apply_variance(0.8, 0.2, ctx.rng), 0.1)

	return result

func execute(ctx: DayContext) -> DayActionResult:
	var player_power := _estimate_player_power(ctx)
	var enemy_power  := 10.0 * DifficultyScaler.challenge_multiplier(ctx.day_number) * difficulty_factor
	return build_result(player_power >= enemy_power, ctx)

func _estimate_player_power(ctx: DayContext) -> float:
	var d = ctx.character_data
	return (
		d.base_stats.get(&"fuerza",        0.0) * 1.5 +
		d.base_stats.get(&"ki",            0.0) * 1.0 +
		d.base_stats.get(&"resistencia",   0.0) * 0.8 +
		d.base_stats.get(&"intel_combate", 0.0) * 0.6
	)

func _primary_combat_stat(ctx: DayContext) -> StringName:
	var style: StringName = ctx.character_data.build.combat_style \
		if ctx.character_data.build != null else &"balanced"
	match style:
		&"striker":   return &"fuerza"
		&"ki_user":   return &"poder_ki"
		&"defensive": return &"resistencia"
		_:            return &"intel_combate"
