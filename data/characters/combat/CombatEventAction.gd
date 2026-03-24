# data/actions/combat/CombatEventAction.gd
# STUB — Fase 4 implementará el combate real.
# Por ahora simula el resultado en base a stats vs dificultad del día.
class_name CombatEventAction
extends DayAction

# Dificultad relativa de este encuentro (1.0 = equilibrado con el día actual)
@export var difficulty_factor: float = 1.0

func execute(ctx: DayContext) -> DayActionResult:
	var result      := DayActionResult.new()
	var player_power := _estimate_player_power(ctx)
	var enemy_power  := 10.0 * DifficultyScaler.challenge_multiplier(ctx.day_number) * difficulty_factor

	result.success  = player_power >= enemy_power

	if result.success:
		result.narrative_key = "combat.victory"
		result.xp_gained     = enemy_power * 5.0
		# Victoria: pequeña ganancia de stats
		result.stat_changes[&"strength"] = DifficultyScaler.apply_variance(0.5, 0.3, ctx.rng)
	else:
		result.narrative_key = "combat.defeat"
		result.xp_gained     = enemy_power * 1.0  # Algo de XP incluso al perder
		# Derrota: pequeña penalización de HP max (temporal, recuperable)
		result.stat_changes[&"health_max"] = -DifficultyScaler.apply_variance(2.0, 0.2, ctx.rng)

	return result

## Estima el poder del jugador como suma ponderada de sus stats.
## Fase 4 reemplazará esto con combate real.
func _estimate_player_power(ctx: DayContext) -> float:
	var data := ctx.character_data
	return (
		data.base_stats.get(&"strength", 0.0) * 1.5 +
		data.base_stats.get(&"ki_max",   0.0) * 1.0 +
		data.base_stats.get(&"defense",  0.0) * 0.8
	)
