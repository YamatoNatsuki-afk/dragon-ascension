# res://core/ActionRegistry.gd  ← Autoload
# Carga DayActions desde disco (.tres). Si no encuentra ninguna, genera
# un set mínimo por código (fallback). El debug loop siempre funciona.
extends Node

const PATHS: Array[String] = [
	"res://data/characters/training/definitions/",
	"res://data/characters/events/definitions/",
	"res://data/characters/actions/combat/definitions/",
]

var _all_actions: Array[DayAction] = []
var _by_id: Dictionary = {}

# ─────────────────────────────────────────────
# Inicialización
# ─────────────────────────────────────────────

func _ready() -> void:
	_load_all_actions()
	if _all_actions.is_empty():
		push_warning("ActionRegistry: sin .tres en disco. Usando acciones por código.")
		_register_fallback_actions()
	print("[ActionRegistry] %d acciones cargadas." % _all_actions.size())

func _load_all_actions() -> void:
	_all_actions.clear()
	_by_id.clear()
	for folder: String in PATHS:
		_load_from_folder(folder)

func _load_from_folder(folder: String) -> void:
	var dir := DirAccess.open(folder)
	if dir == null:
		return
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if entry.ends_with(".tres"):
			var res := load(folder + entry)
			if res is DayAction:
				var action := res as DayAction
				if action.id == &"":
					push_warning("ActionRegistry: acción sin id en '%s'." % (folder + entry))
				elif _by_id.has(action.id):
					push_error("ActionRegistry: id duplicado '%s'." % action.id)
				else:
					_all_actions.append(action)
					_by_id[action.id] = action
		entry = dir.get_next()
	dir.list_dir_end()

# ─────────────────────────────────────────────
# Fallback — set mínimo creado en código
# ─────────────────────────────────────────────

func _register_fallback_actions() -> void:
	_add_training(&"train_strength",     "Entrenamiento de fuerza",    [&"fuerza"],                   2.0, 1)
	_add_training(&"train_speed",        "Entrenamiento de velocidad", [&"velocidad"],                2.0, 1)
	_add_training(&"train_ki",           "Meditación de ki",           [&"ki"],                       2.0, 1)
	_add_training(&"train_defense",      "Entrenamiento defensivo",    [&"resistencia"],              2.0, 1)
	_add_training(&"train_constitution", "Acondicionamiento físico",   [&"vitalidad"],                2.5, 1)
	_add_training(&"train_combat",       "Combate integral",           [&"fuerza", &"velocidad"],     1.2, 5)
	_add_training(&"train_ki_control",   "Control de ki avanzado",     [&"ki", &"poder_ki"],          1.2, 10)
	_add_event_rival()
	_add_event_overtraining()

func _add_training(p_id: StringName, p_name: String, p_stats: Array[StringName],
		p_gain: float, p_unlock: int) -> void:
	var a              := TrainingAction.new()
	a.id                = p_id
	a.display_name      = p_name
	a.action_type       = &"training"
	a.unlock_day        = p_unlock
	a.selection_weight  = 1.2 if p_stats.size() == 1 else 1.0
	a.target_stats      = p_stats
	a.base_gain         = p_gain
	a.energy_cost       = 1
	_register(a)

func _add_event_rival() -> void:
	var a              := EventAction.new()
	a.id                = &"rival_challenge"
	a.display_name      = "Desafío de un rival"
	a.action_type       = &"event"
	a.unlock_day        = 1
	a.selection_weight  = 1.2

	var o1 := EventOutcome.new()
	o1.narrative_key = "event.rival.victory"
	o1.weight = 2.0; o1.stat_changes = {&"fuerza": 1.0}; o1.xp_gained = 30.0

	var o2 := EventOutcome.new()
	o2.narrative_key = "event.rival.narrow_win"
	o2.weight = 3.0; o2.stat_changes = {&"fuerza": 0.5, &"vitalidad": -2.0}; o2.xp_gained = 20.0

	var o3 := EventOutcome.new()
	o3.narrative_key = "event.rival.defeat"
	o3.weight = 2.0; o3.stat_changes = {&"vitalidad": -5.0, &"resistencia": -0.5}; o3.xp_gained = 8.0

	a.outcomes = [o1, o2, o3]
	_register(a)

func _add_event_overtraining() -> void:
	var a              := EventAction.new()
	a.id                = &"overtraining"
	a.display_name      = "Sobreentrenamiento"
	a.action_type       = &"event"
	a.unlock_day        = 1
	a.selection_weight  = 2.5

	var o1 := EventOutcome.new()
	o1.narrative_key = "event.overtraining.injury"
	o1.weight = 3.0; o1.stat_changes = {&"vitalidad": -8.0, &"fuerza": -0.5}; o1.xp_gained = 0.0

	var o2 := EventOutcome.new()
	o2.narrative_key = "event.overtraining.rest_forced"
	o2.weight = 4.0; o2.stat_changes = {}; o2.xp_gained = 2.0

	var o3 := EventOutcome.new()
	o3.narrative_key = "event.overtraining.breakthrough"
	o3.weight = 1.0; o3.stat_changes = {&"vitalidad": 3.0}; o3.xp_gained = 15.0

	a.outcomes = [o1, o2, o3]
	_register(a)

func _register(action: DayAction) -> void:
	_all_actions.append(action)
	_by_id[action.id] = action

# ─────────────────────────────────────────────
# API pública
# ─────────────────────────────────────────────

## Retorna las acciones disponibles para el contexto dado.
## DayAction.is_available() ya evalúa unlock_day, requires_unlock_flag
## y el array conditions — no es necesario chequearlo aquí también.
func get_available(ctx: DayContext) -> Array[DayAction]:
	var result: Array[DayAction] = []
	for action: DayAction in _all_actions:
		if not action.is_available(ctx):
			continue
		result.append(action)
	_inject_active_events(result, ctx.day_number)
	return result

func get_by_id(action_id: StringName) -> DayAction:
	return _by_id.get(action_id, null)

func get_all() -> Array[DayAction]:
	return _all_actions.duplicate()

func _inject_active_events(pool: Array[DayAction], current_day: int) -> void:
	for action: DayAction in _all_actions:
		if pool.has(action):
			continue
		if InjectEventConsequence.is_event_active(action.id, current_day):
			pool.append(action)
