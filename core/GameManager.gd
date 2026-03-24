# res://core/GameManager.gd
# Autoload principal. Responsabilidad: arrancar la partida y conectar sistemas.
# No contiene lógica de gameplay — solo orquestación de inicio.
extends Node

# false = usa la UI real (DayScreen)
# true  = usa el loop automático de debug (DebugDayLoop)
@export var use_debug_loop: bool = false

@export var debug_auto_days: int = 10

const DAY_SCREEN_PATH := "res://scenes/day_screen/DayScreen.tscn"

func _ready() -> void:
	call_deferred("_initialize")

func _initialize() -> void:
	var character := _get_or_create_character()
	if character == null:
		push_error("GameManager: no se pudo obtener CharacterData.")
		return

	DayManager.initialize(character)

	if use_debug_loop:
		_start_debug_loop(character)
	else:
		_start_day_screen()

# ── Obtener personaje ────────────────────────────────────────────────────────

func _get_or_create_character() -> CharacterData:
	if SaveSystem.slot_exists(0):
		var loaded := SaveSystem.load_character(0)
		if loaded:
			print("[GameManager] Partida cargada — Día %d." % loaded.current_day)
			return loaded
	print("[GameManager] No hay save. Creando personaje de prueba...")
	return _create_debug_character()

func _create_debug_character() -> CharacterData:
	var appearance        := AppearanceData.new()
	appearance.body_scale  = 1.0
	appearance.aura_color  = Color(1.0, 0.8, 0.0)

	var build                                      := BuildData.new()
	build.stat_priority_weights[&"strength"]        = 1.0
	build.stat_priority_weights[&"ki_max"]          = 0.4
	build.stat_priority_weights[&"speed"]           = 0.7
	build.stat_priority_weights[&"defense"]         = 0.3
	build.combat_style                              = &"striker"

	return CharacterFactory.create("Kakarot", &"saiyan", appearance, build)

# ── UI real ──────────────────────────────────────────────────────────────────

func _start_day_screen() -> void:
	if not ResourceLoader.exists(DAY_SCREEN_PATH):
		push_error("GameManager: no se encontró DayScreen en '%s'." % DAY_SCREEN_PATH)
		push_warning("GameManager: cambiando a debug loop como fallback.")
		_start_debug_loop(GameStateProvider.get_character_data())
		return

	var screen: Node = load(DAY_SCREEN_PATH).instantiate()
	screen.name = "DayScreen"
	add_child(screen)

	# Esperar un frame para que DayScreen conecte sus señales antes de empezar
	await get_tree().process_frame

	var data := GameStateProvider.get_character_data()
	if data != null and data.current_day > 100:
		# Partida ya completada — mostrar estado final sin iniciar el loop
		EventBus.game_completed.emit(data)
		return

	DayManager.start_day()

# ── Debug loop ────────────────────────────────────────────────────────────────

func _start_debug_loop(data: CharacterData) -> void:
	var loop      := DebugDayLoop.new()
	loop.auto_days = debug_auto_days
	loop.name      = "DebugDayLoop"
	add_child(loop)
	loop.begin(data)
