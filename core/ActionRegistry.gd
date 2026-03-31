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
	_add_event_desgaste()

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
	# FIX A4: Expira en día 60 para evitar que en late game este evento
	# (selection_weight más alto = 2.5, penaliza -8 vitalidad) destruya
	# sistemáticamente builds defensivos en los días finales del run.
	# Narrativamente: el personaje aprende a gestionar la carga de entrenamiento.
	a.expires_on_day    = 60
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

func _add_event_desgaste() -> void:
	# ── Evento principal: Desgaste por Poder ─────────────────────────────────
	# Aparece solo cuando el jugador está muy por encima de la curva (ratio >= 2.0).
	# Usa DesgasteEventAction para inyectar automáticamente el seguimiento.
	var a                   := DesgasteEventAction.new()
	a.id                     = &"desgaste_por_poder"
	a.display_name           = "Desgaste por Poder"
	a.action_type            = &"event"
	a.unlock_day             = 15          # no aparece en los primeros días
	a.selection_weight       = 1.5         # moderado — no monopoliza el pool
	a.followup_event_id      = &"desgaste_seguimiento"
	a.followup_duration      = 2           # hoy + 2 días eco = 3 días totales

	# Condición: solo si performance_ratio >= 2.0
	# Con el factor 0.75, el Striker supera 2.0 de forma consistente en mid/late game.
	var cond_ratio           := ActionCondition.new()
	cond_ratio.type           = ActionCondition.Type.PERFORMANCE_RATIO_MIN
	cond_ratio.value_float    = 2.0
	a.conditions              = [cond_ratio]

	# Un solo outcome sin varianza — el desgaste siempre ocurre de la misma manera.
	# Los valores se escalan por EventAction con challenge_multiplier(day):
	#   Día 15: ×1.14  |  Día 50: ×1.49  |  Día 100: ×2.0
	# → en late game el golpe es más fuerte, lo que tiene sentido narrativo.
	var o1               := EventOutcome.new()
	o1.narrative_key      = &"event.desgaste.crash"
	o1.weight             = 1.0
	o1.stat_changes       = {
		&"velocidad":     -10.0,   # el cuerpo no puede sostener esa velocidad de crecimiento
		&"intel_combate": -6.0,    # el instinto se embota por el agotamiento extremo
		&"resistencia":   -5.0,    # la capacidad de aguantar daño cae
	}
	o1.xp_gained          = 5.0   # el dolor enseña — mínimo de XP
	a.outcomes             = [o1]
	_register(a)

	# ── Evento de seguimiento: Eco del Desgaste (días 2 y 3) ─────────────────
	# unlock_day = 9999 → nunca entra al pool de forma natural.
	# Solo aparece cuando DesgasteEventAction lo inyecta vía FlagSystem.
	# ActionRegistry._inject_active_events() lo detecta automáticamente.
	var b               := EventAction.new()
	b.id                 = &"desgaste_seguimiento"
	b.display_name       = "Recuperación del Desgaste"
	b.action_type        = &"event"
	b.unlock_day         = 9999   # barrera de seguridad: nunca disponible de forma natural
	b.selection_weight   = 2.0    # cuando está inyectado, tiene peso alto para que aparezca

	var o2               := EventOutcome.new()
	o2.narrative_key      = &"event.desgaste.recovery_partial"
	o2.weight             = 1.0
	o2.stat_changes       = {
		&"velocidad":   -3.0,   # el cuerpo aún no se recupera del todo
		&"resistencia": -2.0,
	}
	o2.xp_gained          = 3.0
	b.outcomes             = [o2]
	_register(b)

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
