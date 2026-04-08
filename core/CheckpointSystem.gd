# res://core/CheckpointSystem.gd  ← Autoload
# Lee CharacterData desde GameStateProvider — sin acoplamiento directo a DayManager.
# Escucha day_ended, evalúa el checkpoint del día si existe, aplica consecuencias
# y emite checkpoint_reached para que UI y ProgressTracker reaccionen.
extends Node

const CHECKPOINTS_PATH := "res://data/checkpoints/definitions/"

var _checkpoints: Dictionary      = {}
var _current_build_id: StringName = &""
var _evaluated_days: Array[int]   = []

@export var enable_checkpoint_log: bool = true

# ─────────────────────────────────────────────────────────────────────────────
# ARRANQUE
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	_load_checkpoints()
	call_deferred("_connect_signals")

func _connect_signals() -> void:
	EventBus.day_ended.connect(_on_day_ended)

# ─────────────────────────────────────────────────────────────────────────────
# CARGA DE CHECKPOINTS
# ─────────────────────────────────────────────────────────────────────────────

func _load_checkpoints() -> void:
	var dir := DirAccess.open(CHECKPOINTS_PATH)

	if dir == null:
		push_warning(
			"[CheckpointSystem] ⚠  Carpeta no encontrada: '%s'\n" % CHECKPOINTS_PATH +
			"  → Los checkpoints de días (25, 50, 75, 100) NO se activarán.\n" +
			"  → Crea la carpeta y añade archivos .tres de CheckpointDefinition."
		)
		return

	dir.list_dir_begin()
	var entry := dir.get_next()
	var skipped: int = 0

	while entry != "":
		if entry.ends_with(".tres"):
			var cp: CheckpointDefinition = load(CHECKPOINTS_PATH + entry)
			if cp and cp.trigger_day > 0:
				if _checkpoints.has(cp.trigger_day):
					push_warning(
						"[CheckpointSystem] ⚠  Checkpoint duplicado en día %d.\n" % cp.trigger_day +
						"  '%s' reemplaza al anterior. Revisa tus .tres." % entry
					)
				_checkpoints[cp.trigger_day] = cp
			else:
				push_warning(
					"[CheckpointSystem] ⚠  Archivo ignorado: '%s'\n" % entry +
					"  Razón: trigger_day = 0 o recurso null."
				)
				skipped += 1
		entry = dir.get_next()
	dir.list_dir_end()

	if _checkpoints.is_empty():
		push_warning(
			"[CheckpointSystem] ⚠  Ningún checkpoint válido cargado desde '%s'." % CHECKPOINTS_PATH
		)
	else:
		var days_str: Array[String] = []
		var sorted_days := _checkpoints.keys()
		sorted_days.sort()
		for d: int in sorted_days:
			var cp: CheckpointDefinition = _checkpoints[d]
			days_str.append("día %d (%s)" % [d, cp.display_name if cp.display_name != "" else cp.id])
		print("[CheckpointSystem] %d checkpoint(s) cargados: %s" % [
			_checkpoints.size(),
			"  ·  ".join(days_str)
		])
		if skipped > 0:
			print("[CheckpointSystem] %d archivo(s) ignorados por datos inválidos." % skipped)

# ─────────────────────────────────────────────────────────────────────────────
# LOOP DIARIO
# ─────────────────────────────────────────────────────────────────────────────

func _on_day_ended(day_number: int, _action_result) -> void:  # _action_result: DayActionResult
	var data = GameStateProvider.get_character_data()  # CharacterData
	if data == null:
		return

	_check_build_identity_change(data)

	if not _checkpoints.has(day_number):
		return

	if _evaluated_days.has(day_number):
		if enable_checkpoint_log:
			push_warning(
				"[CheckpointSystem] ⚠  Checkpoint del día %d ya fue evaluado." % day_number
			)
		return

	_evaluated_days.append(day_number)

	var checkpoint: CheckpointDefinition = _checkpoints[day_number]
	var result := _evaluate(checkpoint, data)
	_apply_outcome(result, data)

	if enable_checkpoint_log:
		_log_checkpoint(result, data)

	EventBus.checkpoint_reached.emit(result)

# ─────────────────────────────────────────────────────────────────────────────
# EVALUACIÓN
# ─────────────────────────────────────────────────────────────────────────────

func _evaluate(checkpoint: CheckpointDefinition, data) -> CheckpointResult:  # data: CharacterData
	var result               := CheckpointResult.new()
	result.checkpoint         = checkpoint
	result.grade              = PerformanceEvaluator.grade(data)
	result.power_score        = PerformanceEvaluator.compute_power_score(data)
	result.expected_score     = PerformanceEvaluator.expected_score(data.current_day)
	result.performance_ratio  = PerformanceEvaluator.performance_ratio(data)
	result.build_identity     = BuildAnalyzer.get_build_identity(data)
	result.all_build_scores   = BuildAnalyzer.get_all_scores(data)
	if result.build_identity != null:
		result.build_fit_score = BuildAnalyzer.get_fit_score(data, result.build_identity.id)
	var outcome               := checkpoint.get_outcome_for_grade(result.grade)
	result.active_outcome     = outcome
	result.narrative_text     = outcome.narrative if outcome and outcome.narrative != "" \
		else _fallback_narrative(result.grade)
	return result

func _apply_outcome(result: CheckpointResult, data) -> void:  # data: CharacterData
	if result.active_outcome == null:
		return
	for consequence: CheckpointConsequence in result.active_outcome.consequences:
		var delta := consequence.apply(data)
		for key in delta.keys():
			result.stat_delta[key] = delta[key]
	SaveSystem.save_character(data)
	FlagSystem.set_flag(&"last_checkpoint_day", data.current_day)

# ─────────────────────────────────────────────────────────────────────────────
# BUILD IDENTITY TRACKING
# ─────────────────────────────────────────────────────────────────────────────

func _check_build_identity_change(data) -> void:  # data: CharacterData
	var profile := BuildAnalyzer.get_build_identity(data)
	if profile == null:
		return
	if profile.id != _current_build_id:
		var prev: StringName  = _current_build_id
		_current_build_id     = profile.id
		if prev != &"":
			FlagSystem.set_flag(&"build_identity", _current_build_id)
			EventBus.build_identity_changed.emit(prev, profile)

# ─────────────────────────────────────────────────────────────────────────────
# NARRATIVA FALLBACK
# ─────────────────────────────────────────────────────────────────────────────

func _fallback_narrative(grade: PerformanceEvaluator.Grade) -> String:
	match grade:
		PerformanceEvaluator.Grade.EXCEPTIONAL: return "Rendimiento excepcional."
		PerformanceEvaluator.Grade.HIGH:        return "Buen progreso."
		PerformanceEvaluator.Grade.NORMAL:      return "Progreso estable."
		PerformanceEvaluator.Grade.LOW:         return "El progreso es lento."
	return ""

# ─────────────────────────────────────────────────────────────────────────────
# LOGGING ESTRUCTURADO DE CHECKPOINT
# ─────────────────────────────────────────────────────────────────────────────

func _log_checkpoint(result: CheckpointResult, data) -> void:  # data: CharacterData
	_log_cp_header(result)
	_log_cp_evaluation(result)
	_log_cp_outcome(result)
	_log_cp_consequences(result, data)
	_log_cp_build(result)
	_log_cp_flags()
	_log_cp_footer(result)

func _log_cp_header(result: CheckpointResult) -> void:
	var cp   := result.checkpoint
	var name := cp.display_name if cp.display_name != "" else str(cp.id)
	print("")
	print("╔══════════════════════════════════════════════════════╗")
	print("║  CHECKPOINT  ·  %-36s║" % name)
	print("║  Día de activación: %-32d║" % cp.trigger_day)
	if cp.is_blocking:
		print("║  ⚠  CHECKPOINT BLOQUEANTE — score mínimo: %-11.1f║" % cp.min_score_to_pass)
	print("╠══════════════════════════════════════════════════════╣")

func _log_cp_evaluation(result: CheckpointResult) -> void:
	var grade_label := PerformanceEvaluator.grade_label(result.grade)
	var ratio_pct   := result.performance_ratio * 100.0
	var ratio_marker: String
	if result.performance_ratio >= 1.10:
		ratio_marker = "▲ por encima de la curva"
	elif result.performance_ratio >= 0.90:
		ratio_marker = "─ en la curva"
	else:
		ratio_marker = "▼ por debajo de la curva"
	print("║  EVALUACIÓN                                          ║")
	print("║    Grade      : %-36s║" % grade_label)
	print("║    Power score: %-6.1f  (esperado: %-6.1f)%-9s║" % [
		result.power_score, result.expected_score, ""
	])
	print("║    Ratio      : %-5.0f%%  %s%-17s║" % [ratio_pct, ratio_marker, ""])
	print("╠══════════════════════════════════════════════════════╣")

func _log_cp_outcome(result: CheckpointResult) -> void:
	print("║  OUTCOME                                             ║")
	if result.active_outcome == null:
		push_warning(
			"[CheckpointSystem] ⚠  Checkpoint '%s' (día %d) no tiene outcomes configurados." % [
				result.checkpoint.id, result.checkpoint.trigger_day
			]
		)
		print("║    ⚠  Sin outcome configurado — no se aplican consecuencias. ║")
		print("╠══════════════════════════════════════════════════════╣")
		return
	var outcome    := result.active_outcome
	var grade_name := _grade_name(outcome.min_grade)
	print("║    Grade mínimo   : %-32s║" % grade_name)
	print("║    Consecuencias  : %-32d║" % outcome.consequences.size())
	if outcome.narrative != "":
		var lines := _wrap_text(outcome.narrative, 48)
		for line: String in lines:
			print("║    \"%s\"%-*s║" % [line, maxi(0, 46 - line.length()), ""])
	else:
		print("║    (sin texto narrativo configurado)                 ║")
	print("╠══════════════════════════════════════════════════════╣")

func _log_cp_consequences(result: CheckpointResult, data) -> void:  # data: CharacterData
	print("║  CONSECUENCIAS APLICADAS                             ║")
	if result.active_outcome == null or result.active_outcome.consequences.is_empty():
		print("║    (ninguna)                                         ║")
		print("╠══════════════════════════════════════════════════════╣")
		return
	for consequence: CheckpointConsequence in result.active_outcome.consequences:
		var desc := consequence.describe()
		print("║    • %-48s║" % desc)
	var stat_changes: Dictionary = {}
	for key: Variant in result.stat_delta.keys():
		var val: Variant = result.stat_delta[key]
		if typeof(val) == TYPE_FLOAT or typeof(val) == TYPE_INT:
			stat_changes[key] = float(val)
	if stat_changes.is_empty():
		print("║    Cambios de stats: ninguno                         ║")
	else:
		print("║    Cambios de stats:                                 ║")
		for stat_id: Variant in stat_changes.keys():
			var delta: float  = stat_changes[stat_id]
			var after: float  = data.base_stats.get(stat_id, 0.0)
			var before: float = after - delta
			var sign: String  = "+" if delta >= 0.0 else ""
			var arrow: String = "▲" if delta > 0.0 else ("▼" if delta < 0.0 else "─")
			print("║      %-12s %6.1f → %6.1f  %s%s%.2f%-8s║" % [
				str(stat_id), before, after, sign, arrow, delta, ""
			])
	print("╠══════════════════════════════════════════════════════╣")

func _log_cp_build(result: CheckpointResult) -> void:
	print("║  BUILD                                               ║")
	if result.build_identity == null:
		print("║    Sin build identificado.                           ║")
		print("╠══════════════════════════════════════════════════════╣")
		return
	print("║    Identidad  : %-36s║" % result.build_identity.display_name)
	print("║    Fit score  : %-5.0f%%%-36s║" % [result.build_fit_score * 100.0, ""])
	var shown: int = 0
	for entry: Dictionary in result.all_build_scores:
		if shown >= 3:
			break
		var profile: BuildProfile = entry.profile
		var score: float          = entry.score
		var bar   := _cp_mini_bar(score, 1.0, 10)
		print("║      %-12s %s %-3.0f%%%-13s║" % [profile.display_name, bar, score * 100.0, ""])
		shown += 1
	print("╠══════════════════════════════════════════════════════╣")

func _log_cp_flags() -> void:
	var all_flags := FlagSystem.get_all()
	print("║  FLAGS ACTIVOS                                       ║")
	if all_flags.is_empty():
		print("║    (ninguno)                                         ║")
	else:
		for flag_id: StringName in all_flags.keys():
			var val: Variant     = all_flags[flag_id]
			var flag_str: String = "%s = %s" % [str(flag_id), str(val)]
			if flag_str.length() > 50:
				flag_str = flag_str.substr(0, 47) + "..."
			print("║    %-50s║" % flag_str)
	print("╠══════════════════════════════════════════════════════╣")

func _log_cp_footer(result: CheckpointResult) -> void:
	print("║  \"%s\"" % result.narrative_text)
	print("╚══════════════════════════════════════════════════════╝")
	print("")

# ─────────────────────────────────────────────────────────────────────────────
# HELPERS DE LOG
# ─────────────────────────────────────────────────────────────────────────────

func _grade_name(min_grade_int: int) -> String:
	match min_grade_int:
		0: return "LOW (cualquier grade)"
		1: return "NORMAL o superior"
		2: return "HIGH o superior"
		3: return "EXCEPTIONAL"
	return "Desconocido (%d)" % min_grade_int

func _cp_mini_bar(value: float, max_v: float, width: int) -> String:
	if max_v <= 0.0:
		return "[" + "░".repeat(width) + "]"
	var filled := clampi(int((value / max_v) * width), 0, width)
	return "[" + "█".repeat(filled) + "░".repeat(width - filled) + "]"

func _wrap_text(text: String, max_len: int) -> Array[String]:
	var lines: Array[String] = []
	var words := text.split(" ")
	var current: String = ""
	for word: String in words:
		if current.length() + word.length() + 1 <= max_len:
			current = (current + " " + word).strip_edges()
		else:
			if current != "":
				lines.append(current)
			current = word
	if current != "":
		lines.append(current)
	return lines
