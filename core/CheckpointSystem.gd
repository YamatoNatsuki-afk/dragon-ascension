# res://core/CheckpointSystem.gd  ← Autoload
# Lee CharacterData desde GameStateProvider — sin acoplamiento directo a DayManager.
# Escucha day_ended, evalúa el checkpoint del día si existe, aplica consecuencias
# y emite checkpoint_reached para que UI y ProgressTracker reaccionen.
extends Node

const CHECKPOINTS_PATH := "res://data/checkpoints/definitions/"

var _checkpoints: Dictionary      = {}       # día → CheckpointDefinition
var _current_build_id: StringName = &""
var _evaluated_days: Array[int]   = []

func _ready() -> void:
	_load_checkpoints()
	EventBus.day_ended.connect(_on_day_ended)

# ─────────────────────────────────────────────
# Carga
# ─────────────────────────────────────────────

func _load_checkpoints() -> void:
	var dir := DirAccess.open(CHECKPOINTS_PATH)
	if dir == null:
		push_warning("CheckpointSystem: carpeta '%s' no encontrada." % CHECKPOINTS_PATH)
		return
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if entry.ends_with(".tres"):
			var cp: CheckpointDefinition = load(CHECKPOINTS_PATH + entry)
			if cp and cp.trigger_day > 0:
				_checkpoints[cp.trigger_day] = cp
		entry = dir.get_next()
	dir.list_dir_end()
	print("[CheckpointSystem] %d checkpoints cargados." % _checkpoints.size())

# ─────────────────────────────────────────────
# Loop
# ─────────────────────────────────────────────

func _on_day_ended(day_number: int, _action_result: DayActionResult) -> void:
	var data := GameStateProvider.get_character_data()
	if data == null:
		return
	_check_build_identity_change(data)
	if not _checkpoints.has(day_number) or _evaluated_days.has(day_number):
		return
	_evaluated_days.append(day_number)
	var checkpoint: CheckpointDefinition = _checkpoints[day_number]
	var result := _evaluate(checkpoint, data)
	_apply_outcome(result, data)
	EventBus.checkpoint_reached.emit(result)

# ─────────────────────────────────────────────
# Evaluación
# ─────────────────────────────────────────────

func _evaluate(checkpoint: CheckpointDefinition, data: CharacterData) -> CheckpointResult:
	var result               := CheckpointResult.new()
	result.checkpoint         = checkpoint
	result.grade              = PerformanceEvaluator.grade(data)
	result.power_score        = PerformanceEvaluator.compute_power_score(data)
	result.expected_score     = PerformanceEvaluator.expected_score(data.current_day)  # público
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

func _apply_outcome(result: CheckpointResult, data: CharacterData) -> void:
	if result.active_outcome == null:
		return
	for consequence: CheckpointConsequence in result.active_outcome.consequences:
		var delta := consequence.apply(data)
		for key in delta.keys():
			result.stat_delta[key] = delta[key]
	SaveSystem.save_character(data)
	FlagSystem.set_flag(&"last_checkpoint_day", data.current_day)

# ─────────────────────────────────────────────
# Build identity tracking
# ─────────────────────────────────────────────

func _check_build_identity_change(data: CharacterData) -> void:
	var profile := BuildAnalyzer.get_build_identity(data)
	if profile == null:
		return
	if profile.id != _current_build_id:
		var prev      := _current_build_id
		_current_build_id = profile.id
		if prev != &"":
			FlagSystem.set_flag(&"build_identity", _current_build_id)
			EventBus.build_identity_changed.emit(prev, profile)

# ─────────────────────────────────────────────
# Narrativa de fallback
# ─────────────────────────────────────────────

func _fallback_narrative(grade: PerformanceEvaluator.Grade) -> String:
	match grade:
		PerformanceEvaluator.Grade.EXCEPTIONAL: return "Rendimiento excepcional."
		PerformanceEvaluator.Grade.HIGH:        return "Buen progreso."
		PerformanceEvaluator.Grade.NORMAL:      return "Progreso estable."
		PerformanceEvaluator.Grade.LOW:         return "El progreso es lento."
	return ""
