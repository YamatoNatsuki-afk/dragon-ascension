# res://core/DayManager.gd
# Autoload. Orquesta las fases del loop diario.
# No contiene lógica de gameplay ni referencias a nodos de escena.
extends Node

enum Phase { IDLE, DAY_START, AWAITING_ACTION, EXECUTING, RESOLVING, DAY_END }

var phase: Phase = Phase.IDLE
var current_day: int = 0

var _character_data  # CharacterData

@export var enable_debug_log: bool = true

var _stats_before: Dictionary = {}

# [B1 FIX] Contexto único por día — ver DayContext.gd
var _current_ctx: DayContext = null

# ─────────────────────────────────────────────────────────────────────────────
# INICIALIZACIÓN
# ─────────────────────────────────────────────────────────────────────────────

func initialize(data) -> void:  # data: CharacterData
	assert(data != null, "DayManager.initialize: CharacterData es null.")
	_character_data = data
	current_day     = data.current_day
	phase           = Phase.IDLE
	GameStateProvider.set_character_data(data)
	print("[DayManager] Inicializado. Personaje: %s | Día: %d" % [
		data.character_name, current_day
	])

# ─────────────────────────────────────────────────────────────────────────────
# LOOP PRINCIPAL
# ─────────────────────────────────────────────────────────────────────────────

func start_day() -> void:
	if phase != Phase.IDLE:
		push_error("DayManager.start_day: fase incorrecta '%s'. ¿Doble llamada?" \
			% Phase.keys()[phase])
		return

	phase       = Phase.DAY_START
	current_day = _character_data.current_day

	EventBus.day_started.emit(current_day)

	_current_ctx  = DayContext.create(_character_data)
	var available := ActionRegistry.get_available(_current_ctx)

	phase = Phase.AWAITING_ACTION
	EventBus.day_actions_ready.emit(available)

func execute_action(action) -> void:  # action: DayAction
	if phase != Phase.AWAITING_ACTION:
		push_error("DayManager.execute_action: fase incorrecta '%s'." \
			% Phase.keys()[phase])
		return
	if action == null:
		push_error("DayManager.execute_action: acción null.")
		return

	assert(_current_ctx != null,
		"DayManager.execute_action: _current_ctx es null. ¿Se llamó start_day()?")

	phase = Phase.EXECUTING

	var result = action.execute(_current_ctx)  # DayActionResult

	phase = Phase.RESOLVING
	_resolve(action, result)

# ─────────────────────────────────────────────────────────────────────────────
# SIMULACIÓN DE DEBUG
# ─────────────────────────────────────────────────────────────────────────────

func debug_run_simulation(days: int, seed: int = 0) -> void:
	if _character_data == null:
		push_error("DayManager.debug_run_simulation: CharacterData es null. " +
			"Llama a initialize() antes de simular.")
		return

	if phase != Phase.IDLE:
		push_error("DayManager.debug_run_simulation: DayManager no está en IDLE " +
			"(fase actual: '%s'). ¿Hay un run activo?" % Phase.keys()[phase])
		return

	if days <= 0:
		push_warning("DayManager.debug_run_simulation: days debe ser > 0.")
		return

	var rng := RandomNumberGenerator.new()
	if seed > 0:
		rng.seed = seed
		_sim_log_line("Semilla fija: %d" % seed)
	else:
		rng.randomize()

	var start_day_num: int = _character_data.current_day
	var end_day_num: int   = mini(start_day_num + days - 1, 100)
	_sim_log_header(start_day_num, end_day_num, days)

	var days_simulated: int = 0

	for _i: int in days:
		if _character_data.current_day > 100:
			_sim_log_line("Run completado en el día %d." % (_character_data.current_day - 1))
			break

		start_day()
		var raw_actions: Array = await EventBus.day_actions_ready

		var available: Array = []
		for item in raw_actions:
			if item is DayAction:
				available.append(item)

		if available.is_empty():
			push_error("DayManager.debug_run_simulation: " +
				"sin acciones disponibles en día %d." % _character_data.current_day)
			break

		var chosen = ActionSelector.pick(available, _current_ctx, rng)

		if chosen == null:
			push_error("DayManager.debug_run_simulation: ActionSelector devolvió null.")
			break

		if enable_debug_log:
			var weight_table := ActionSelector.compute_weight_table(available, _current_ctx)
			_sim_log_action_choice(chosen, weight_table, available)

		execute_action(chosen)
		await EventBus.day_ended

		days_simulated += 1

	_sim_log_footer(start_day_num, days_simulated)

# ─────────────────────────────────────────────────────────────────────────────
# HELPERS DE LOG DE SIMULACIÓN
# ─────────────────────────────────────────────────────────────────────────────

func _sim_log_header(from_day: int, to_day: int, requested: int) -> void:
	print("")
	print("╔══════════════════════════════════════════════════════╗")
	print("║  DEBUG SIMULATION                                    ║")
	print("║  Personaje : %-38s║" % _character_data.character_name)
	print("║  Raza      : %-38s║" % str(_character_data.race_id))
	print("║  Build     : %-38s║" % _character_data.build.combat_style)
	print("║  Días      : %d → %d  (solicitados: %d)" % [from_day, to_day, requested] \
		+ " ".repeat(maxi(0, 17 - str(from_day).length() - str(to_day).length())) + "║")
	print("╚══════════════════════════════════════════════════════╝")
	print("")

func _sim_log_action_choice(chosen, weight_table: Dictionary, all_actions: Array) -> void:
	if all_actions.size() <= 1:
		return
	print("  ┌ Selección de acción ──────────────────────────────")
	for action in all_actions:
		var w: float       = weight_table.get(action.id, 0.0)
		var marker: String = "→" if action == chosen else " "
		var bar: String    = _sim_weight_bar(w, _sim_max_weight(weight_table))
		print("  │ %s %-28s %s %.2f" % [marker, action.display_name, bar, w])
	print("  └────────────────────────────────────────────────────")

func _sim_log_footer(start_day: int, days_run: int) -> void:
	var end_day: int     = _character_data.current_day - 1
	var total_xp: float  = _character_data.experience
	var build_ident      = BuildAnalyzer.get_build_identity(_character_data)
	var build_name: String = build_ident.display_name if build_ident != null else "Desconocido"

	print("")
	print("╔══════════════════════════════════════════════════════╗")
	print("║  SIMULACIÓN COMPLETADA                               ║")
	print("║  Días simulados : %-34d║" % days_run)
	print("║  Rango          : %-3d → %-29d║" % [start_day, end_day])
	print("║  XP total       : %-34.1f║" % total_xp)
	print("║  Build final    : %-34s║" % build_name)
	print("║  STATS FINALES:                                      ║")
	for stat_id: StringName in _character_data.base_stats.keys():
		var val: float = _character_data.base_stats[stat_id]
		print("║    %-14s %6.1f%-22s║" % [str(stat_id), val, ""])
	print("╚══════════════════════════════════════════════════════╝")
	print("")

func _sim_log_line(msg: String) -> void:
	print("  [SIM] %s" % msg)

func _sim_weight_bar(weight: float, max_weight: float) -> String:
	if max_weight <= 0.0:
		return "[          ]"
	var filled := clampi(int((weight / max_weight) * 10.0), 0, 10)
	return "[" + "█".repeat(filled) + "░".repeat(10 - filled) + "]"

func _sim_max_weight(weight_table: Dictionary) -> float:
	var max_w: float = 0.0
	for w: Variant in weight_table.values():
		var wf: float = float(w)
		if wf > max_w:
			max_w = wf
	return max_w

# ─────────────────────────────────────────────────────────────────────────────
# RESOLUCIÓN INTERNA
# ─────────────────────────────────────────────────────────────────────────────

func _resolve(action, result) -> void:  # action: DayAction, result: DayActionResult
	if enable_debug_log:
		_stats_before = _character_data.base_stats.duplicate()

	for stat_id: StringName in result.stat_changes.keys():
		var delta: float   = result.stat_changes[stat_id]
		var current: float = _character_data.base_stats.get(stat_id, 0.0)
		_character_data.base_stats[stat_id] = StatRegistry.clamp_stat(stat_id, current + delta)

	_character_data.experience += result.xp_gained

	EventBus.day_action_resolved.emit(action, result)

	if enable_debug_log:
		_log_day(action, result)

	_end_day(result)

func _end_day(result) -> void:  # result: DayActionResult
	phase = Phase.DAY_END
	_current_ctx = null

	_character_data.current_day += 1
	current_day = _character_data.current_day

	SaveSystem.save_character(_character_data)

	EventBus.day_ended.emit(current_day - 1, result)

	if _character_data.current_day > 100:
		EventBus.game_completed.emit(_character_data)

	phase = Phase.IDLE

# ─────────────────────────────────────────────────────────────────────────────
# LOGGING ESTRUCTURADO
# ─────────────────────────────────────────────────────────────────────────────

func _log_day(action, result) -> void:
	var build_profile    = BuildAnalyzer.get_build_identity(_character_data)
	var build_name: String = build_profile.display_name if build_profile != null else "Desconocido"
	_log_header(_character_data.current_day)
	_log_action(action, result)
	_log_stats_comparison(result)
	_log_xp(result)
	_log_build(build_name)
	_log_flags()
	_log_footer()

func _log_header(day: int) -> void:
	print("")
	print("┌─────────────────────────────────────────────────────┐")
	print("│  DÍA %-3d  ·  %-38s│" % [
		day,
		_character_data.character_name + " [" + str(_character_data.race_id) + "]"
	])
	print("├─────────────────────────────────────────────────────┤")

func _log_action(action, result) -> void:
	var status := "✓" if result.success else "✗"
	print("│  Acción   : %s %s" % [status, action.display_name])
	print("│  Tipo     : %s" % str(action.action_type))
	if result.narrative_key != "":
		var readable: String = result.narrative_key.replace(".", "  ·  ").replace("_", " ")
		print("│  Narrativa: %s" % readable)
	print("│")

func _log_stats_comparison(_result) -> void:
	print("│  STATS")
	for stat_id: StringName in _character_data.base_stats.keys():
		var before: float = _stats_before.get(stat_id, 0.0)
		var after: float  = _character_data.base_stats.get(stat_id, 0.0)
		var delta: float  = after - before
		var change_str    := ""
		var arrow         := " "
		if abs(delta) >= 0.01:
			var sign: String = "+" if delta >= 0.0 else ""
			arrow            = "▲" if delta > 0.0 else "▼"
			change_str       = "  %s%s%.2f" % [sign, arrow, delta]
		print("│    %-12s %6.1f → %6.1f%s" % [str(stat_id), before, after, change_str])
	print("│")

func _log_xp(result) -> void:
	if result.xp_gained > 0.0:
		print("│  XP       : +%.1f  (total: %.1f)" % [
			result.xp_gained, _character_data.experience
		])
		print("│")

func _log_build(build_name: String) -> void:
	print("│  Build    : %s" % build_name)
	if _character_data.build != null:
		var weights: Dictionary = _character_data.build.stat_priority_weights
		var weight_parts: Array[String] = []
		for stat_id: StringName in weights.keys():
			var w: float = weights.get(stat_id, 0.0)
			if w >= 0.1:
				weight_parts.append("%s:%.0f%%" % [str(stat_id), w * 100.0])
		if not weight_parts.is_empty():
			print("│  Intención: %s" % "  ·  ".join(weight_parts))
	print("│")

func _log_flags() -> void:
	var all_flags := FlagSystem.get_all()
	if all_flags.is_empty():
		print("│  Flags    : (ninguno)")
		return
	var game_flags: Array[String] = []
	var meta_flags: Array[String] = []
	for flag_id: StringName in all_flags.keys():
		var val: Variant     = all_flags[flag_id]
		var flag_str: String = "%s = %s" % [str(flag_id), str(val)]
		var is_meta := (
			str(flag_id).begins_with("unlocked:") or
			str(flag_id).begins_with("last_checkpoint") or
			str(flag_id) == "build_identity"
		)
		if is_meta:
			meta_flags.append(flag_str)
		else:
			game_flags.append(flag_str)
	if not game_flags.is_empty():
		print("│  Flags    : [%s]" % "  ·  ".join(game_flags))
	if not meta_flags.is_empty():
		print("│  Meta     : [%s]" % "  ·  ".join(meta_flags))

func _log_footer() -> void:
	print("└─────────────────────────────────────────────────────┘")
