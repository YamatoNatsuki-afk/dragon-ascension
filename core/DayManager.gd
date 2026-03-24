# core/DayManager.gd
# Autoload. Orquesta las fases del loop diario.
# No contiene lógica de gameplay ni referencias a nodos de escena.
extends Node

# Público para que sistemas externos (debug loop, UI) puedan verificar
# la fase actual antes de llamar a execute_action() o start_day().
enum Phase { IDLE, DAY_START, AWAITING_ACTION, EXECUTING, RESOLVING, DAY_END }

var phase: Phase = Phase.IDLE
var current_day: int = 0

var _character_data: CharacterData

# ─────────────────────────────────────────────
# Inicialización
# ─────────────────────────────────────────────

# En core/DayManager.gd — reemplazar initialize()
func initialize(data: CharacterData) -> void:
	assert(data != null, "DayManager.initialize: CharacterData es null.")
	_character_data = data
	current_day     = data.current_day
	phase           = Phase.IDLE
	# Alimentar el provider — a partir de aquí otros sistemas usan GameStateProvider
	GameStateProvider.set_character_data(data)
	print("[DayManager] Inicializado. Día actual: %d" % current_day)

# ─────────────────────────────────────────────
# Loop principal
# ─────────────────────────────────────────────

func start_day() -> void:
	if phase != Phase.IDLE:
		push_error("DayManager.start_day: fase incorrecta '%s'. ¿Doble llamada?" \
			% Phase.keys()[phase])
		return

	phase       = Phase.DAY_START
	current_day = _character_data.current_day

	EventBus.day_started.emit(current_day)

	# Construir contexto y obtener acciones disponibles
	var ctx        := DayContext.create(_character_data)
	var available  := ActionRegistry.get_available(ctx)

	phase = Phase.AWAITING_ACTION

	# Emitir como Array base — los receptores hacen cast a DayAction
	EventBus.day_actions_ready.emit(available)

func execute_action(action: DayAction) -> void:
	if phase != Phase.AWAITING_ACTION:
		push_error("DayManager.execute_action: fase incorrecta '%s'." \
			% Phase.keys()[phase])
		return
	if action == null:
		push_error("DayManager.execute_action: acción null.")
		return

	phase = Phase.EXECUTING

	var ctx    := DayContext.create(_character_data)
	var result := action.execute(ctx)

	phase = Phase.RESOLVING
	_resolve(action, result)

# ─────────────────────────────────────────────
# Resolución interna
# ─────────────────────────────────────────────

func _resolve(action: DayAction, result: DayActionResult) -> void:
	# Aplicar XP directamente en CharacterData
	_character_data.experience += result.xp_gained

	# StatsComponent escucha esta señal y aplica stat_changes
	EventBus.day_action_resolved.emit(action, result)

	_end_day(result)

func _end_day(result: DayActionResult) -> void:
	phase = Phase.DAY_END

	_character_data.current_day += 1
	current_day = _character_data.current_day

	# Guardado automático al cerrar el día
	SaveSystem.save_character(_character_data)

	EventBus.day_ended.emit(current_day - 1, result)

	if _character_data.current_day > 100:
		EventBus.game_completed.emit(_character_data)

	phase = Phase.IDLE
