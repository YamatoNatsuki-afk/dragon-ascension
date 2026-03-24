# core/EventBus.gd
extends Node

# ── Player ───────────────────────────────────
signal player_stats_changed(stat_name: StringName, new_value: float)
signal player_health_changed(new_hp: float, max_hp: float)
signal player_ki_changed(new_ki: float, max_ki: float)
signal player_died()

# ── Day system ───────────────────────────────
signal day_started(day_number: int)
signal day_actions_ready(available_actions: Array)
signal day_action_resolved(action: DayAction, result: DayActionResult)
signal day_ended(day_number: int, result: DayActionResult)
signal game_completed(final_data: CharacterData)

# ── Meta-progreso ────────────────────────────
signal checkpoint_reached(result: CheckpointResult)
signal build_identity_changed(prev_id: StringName, new_profile: BuildProfile)
signal action_unlocked(action_id: StringName)

# ── XP / Progresión ──────────────────────────
signal xp_gained(amount: float, total: float)

# ── Combat (Fase 5) ───────────────────────────
signal enemy_died(enemy: Node)
signal damage_dealt(target: Node, amount: float, type: String)
