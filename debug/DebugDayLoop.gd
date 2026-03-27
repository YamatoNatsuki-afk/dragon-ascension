# debug/DebugDayLoop.gd
# TEMPORAL — eliminar cuando se implemente la UI real.
#
# Simula lo que haría la UI: escucha EventBus, elige acciones, muestra resultados.
# Usa ActionSelector para selección ponderada por build.
# Usa ProgressTracker para milestones y resumen final.
class_name DebugDayLoop
extends Node

var auto_days: int       = 10
var milestone_every: int = 5

var _character_data                              # CharacterData
var _available_actions: Array[DayAction] = []
var _tracker: ProgressTracker
var _rng := RandomNumberGenerator.new()
var _days_run: int = 0
var _prev_day_trained_stats: Dictionary = {}

# ─────────────────────────────────────────────
# Arranque
# ─────────────────────────────────────────────

func begin(data) -> void:  # data: CharacterData
	_character_data = data
	_rng.randomize()
	_tracker = ProgressTracker.new()
	_tracker.milestone_every = milestone_every
	_tracker.initialize(data)
	_connect_signals()
	_print_header()
	_run_next_day()

func _connect_signals() -> void:
	EventBus.day_started.connect(_on_day_started)
	EventBus.day_actions_ready.connect(_on_day_actions_ready)
	EventBus.day_action_resolved.connect(_on_day_action_resolved)
	EventBus.day_ended.connect(_on_day_ended)
	EventBus.game_completed.connect(_on_game_completed)

# ─────────────────────────────────────────────
# Respuestas al EventBus
# ─────────────────────────────────────────────

func _on_day_started(day_number: int) -> void:
	_print_separator()
	print("  DÍA %d / 100" % day_number)
	_print_separator()
	_print_character_snapshot()

func _on_day_actions_ready(actions: Array) -> void:
	_available_actions.clear()
	for a in actions:
		if a is DayAction:
			_available_actions.append(a)

	_maybe_inject_fatigue_event()
	_print_action_list()

	await get_tree().process_frame
	_select_action()

func _on_day_action_resolved(action, result) -> void:  # action: DayAction, result: DayActionResult
	if action is TrainingAction:
		for stat_id: StringName in (action as TrainingAction).target_stats:
			_prev_day_trained_stats[stat_id] = true
	_print_result(action, result)

func _on_day_ended(day_number: int, _result) -> void:  # _result: DayActionResult
	_days_run += 1
	print("\n  Día %d completado.  XP total: %.1f\n" % [
		day_number, _character_data.experience
	])

	var limit_hit := auto_days > 0 and _days_run >= auto_days
	var game_over: bool = _character_data.current_day > 100

	if limit_hit or game_over:
		_tracker.print_final_report(_days_run)
		return

	await get_tree().create_timer(0.08).timeout
	_run_next_day()

func _on_game_completed(_final_data) -> void:  # _final_data: CharacterData
	print("\n  ¡100 DÍAS COMPLETADOS!")
	_tracker.print_final_report(100)

# ─────────────────────────────────────────────
# Selección ponderada por build
# ─────────────────────────────────────────────

func _select_action() -> void:
	if _available_actions.is_empty():
		push_error("DebugDayLoop: sin acciones disponibles.")
		return

	var ctx    := DayContext.create(_character_data)
	var chosen := ActionSelector.pick(_available_actions, ctx, _rng)
	var table  := ActionSelector.compute_weight_table(_available_actions, ctx)

	_print_selection_weights(table, chosen)
	DayManager.execute_action(chosen)

# ─────────────────────────────────────────────
# Fatiga
# ─────────────────────────────────────────────

func _maybe_inject_fatigue_event() -> void:
	if _prev_day_trained_stats.is_empty():
		return

	var fatigue_action := ActionRegistry.get_by_id(&"overtraining")
	if fatigue_action == null or _available_actions.has(fatigue_action):
		return

	for action: DayAction in _available_actions:
		if not action is TrainingAction:
			continue
		for stat_id: StringName in (action as TrainingAction).target_stats:
			if _prev_day_trained_stats.has(stat_id):
				_available_actions.append(fatigue_action)
				print("  [!] Fatiga acumulada — riesgo de sobreentrenamiento.")
				return

# ─────────────────────────────────────────────
# Loop control
# ─────────────────────────────────────────────

func _run_next_day() -> void:
	if DayManager.phase != DayManager.Phase.IDLE:
		push_warning("DebugDayLoop: DayManager no está en IDLE.")
		return
	DayManager.start_day()

# ─────────────────────────────────────────────
# Logging
# ─────────────────────────────────────────────

func _print_header() -> void:
	print("")
	print("╔══════════════════════════════════════════╗")
	print("║  DRAGON ASCENSION — DEBUG LOOP           ║")
	print("║  Personaje: %-30s║" % _character_data.character_name)
	print("║  Raza:      %-30s║" % str(_character_data.race_id))
	print("╚══════════════════════════════════════════╝")

func _print_separator() -> void:
	print("  ──────────────────────────────────────────")

func _print_character_snapshot() -> void:
	print("  STATS:")
	for stat_id: StringName in _character_data.base_stats.keys():
		var val: float      = _character_data.base_stats[stat_id]
		var bar             := _bar(val, 200.0, 14)
		var weights: Dictionary = _character_data.build.stat_priority_weights
		var priority: float = weights.get(stat_id, 0.5)
		var focus           := " ◆" if priority >= 0.8 else (" ·" if priority >= 0.4 else "  ")
		print("    %-12s %s %5.1f%s" % [stat_id, bar, val, focus])
	print("    %-12s XP: %.1f" % ["", _character_data.experience])
	print("  (◆ prioritario  · neutral  sin marca = bajo)")

func _print_action_list() -> void:
	print("\n  ACCIONES DISPONIBLES:")
	for i: int in range(_available_actions.size()):
		var a    := _available_actions[i]
		var risk := " ⚠" if _is_risky(a) else "  "
		print("    [%d]%s %-32s (%s)" % [i + 1, risk, a.display_name, a.action_type])

func _print_selection_weights(table: Dictionary, chosen) -> void:  # chosen: DayAction
	print("\n  SELECTOR (afinidad con build):")
	var ids := table.keys()
	ids.sort_custom(func(a, b): return table[a] > table[b])
	for action_id: StringName in ids:
		var w: float   = table[action_id]
		var marker     := "  ← elegida" if action_id == chosen.id else ""
		print("    %-32s %.2f%s" % [action_id, w, marker])

func _print_result(action, result) -> void:  # action: DayAction, result: DayActionResult
	print("\n  RESULTADO — %s%s:" % [
		action.display_name,
		"" if result.success else " (FALLO)"
	])
	if result.stat_changes.is_empty():
		print("    Sin cambios de stats.")
	else:
		for stat_id: StringName in result.stat_changes.keys():
			var delta: float = result.stat_changes[stat_id]
			var sign         := "+" if delta >= 0.0 else ""
			var arrow        := "▲" if delta > 0.0 else ("▼" if delta < 0.0 else "─")
			print("    %-12s %s%5.1f  %s" % [stat_id, sign, delta, arrow])
	print("    %-12s +%.1f XP" % ["", result.xp_gained])
	if result.narrative_key != "":
		print("    [%s]" % result.narrative_key)

# ─────────────────────────────────────────────
# Utilidades
# ─────────────────────────────────────────────

func _bar(value: float, max_v: float, width: int) -> String:
	var filled := clampi(int((value / max_v) * width), 0, width)
	return "[" + "█".repeat(filled) + "░".repeat(width - filled) + "]"

func _is_risky(action: DayAction) -> bool:
	if action is EventAction:
		for outcome: EventOutcome in (action as EventAction).outcomes:
			for val in outcome.stat_changes.values():
				if (val as float) < 0.0:
					return true
	return action is CombatEventAction

func _print_active_flags() -> void:
	var flags := FlagSystem.get_all()
	if flags.is_empty():
		return
	print("\n  FLAGS ACTIVOS:")
	for flag_id: StringName in flags.keys():
		print("    %-35s = %s" % [flag_id, str(flags[flag_id])])
