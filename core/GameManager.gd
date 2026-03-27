# res://core/GameManager.gd
# Autoload principal. Responsabilidad: arrancar la partida y conectar sistemas.
# No contiene lógica de gameplay — solo orquestación de inicio.
#
# FIX CRÍTICO DE VISIBILIDAD:
#   set_anchors_preset() DEBE llamarse DESPUÉS de add_child().
extends Node

@export var use_debug_loop: bool = false
@export var debug_auto_days: int = 10

const DAY_SCREEN_PATH         := "res://scenes/day_screen/DayScreen.tscn"
const CHARACTER_CREATION_PATH := "res://scenes/character_creation/CharacterCreationScreen.tscn"

func _ready() -> void:
	call_deferred("_initialize")

func _initialize() -> void:
	if SaveSystem.slot_exists(0):
		var loaded = SaveSystem.load_character(0)  # CharacterData
		if loaded != null:
			print("[GameManager] Partida cargada — Día %d." % loaded.current_day)
			_launch_with_character(loaded)
			return

	print("[GameManager] Sin save. Iniciando pantalla de creación.")
	_start_character_creation()

# ── Pantalla de creación ──────────────────────────────────────────────────────

func _start_character_creation() -> void:
	if not ResourceLoader.exists(CHARACTER_CREATION_PATH):
		push_error("GameManager: CharacterCreationScreen no encontrada en '%s'." % CHARACTER_CREATION_PATH)
		_launch_with_character(_create_debug_character())
		return

	var screen = load(CHARACTER_CREATION_PATH).instantiate()  # CharacterCreationScreen
	screen.name = "CharacterCreationScreen"
	get_tree().root.add_child(screen)
	screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen.character_confirmed.connect(_on_character_confirmed, CONNECT_ONE_SHOT)

func _on_character_confirmed(data) -> void:  # data: CharacterData
	var screen := get_tree().root.get_node_or_null("CharacterCreationScreen")
	if screen:
		screen.queue_free()
	_launch_with_character(data)

# ── Punto único de arranque del loop ─────────────────────────────────────────

func _launch_with_character(data) -> void:  # data: CharacterData
	if data == null:
		push_error("GameManager._launch_with_character: data es null.")
		return
	DayManager.initialize(data)
	if use_debug_loop:
		_start_debug_loop(data)
	else:
		_start_day_screen()

# ── DayScreen ─────────────────────────────────────────────────────────────────

func _start_day_screen() -> void:
	if not ResourceLoader.exists(DAY_SCREEN_PATH):
		push_error("GameManager: DayScreen no encontrada en '%s'." % DAY_SCREEN_PATH)
		_start_debug_loop(GameStateProvider.get_character_data())
		return

	var screen: Node = load(DAY_SCREEN_PATH).instantiate()
	screen.name = "DayScreen"
	get_tree().root.add_child(screen)

	await get_tree().process_frame

	var data = GameStateProvider.get_character_data()  # CharacterData
	if data != null and data.current_day > 100:
		EventBus.game_completed.emit(data)
		return

	DayManager.start_day()

# ── Combate ───────────────────────────────────────────────────────────────────

func start_combat(difficulty: float = 1.0) -> void:
	CombatManager.start_combat(difficulty)

# ── Debug loop ────────────────────────────────────────────────────────────────

func _start_debug_loop(data) -> void:  # data: CharacterData
	var loop      := DebugDayLoop.new()
	loop.auto_days = debug_auto_days
	loop.name      = "DebugDayLoop"
	add_child(loop)
	loop.begin(data)

# ── Personaje de debug ────────────────────────────────────────────────────────

func _create_debug_character():  # → CharacterData
	var appearance        := AppearanceData.new()
	appearance.body_scale  = 1.0
	appearance.aura_color  = Color(1.0, 0.8, 0.0)

	var build := BuildData.new()
	build.stat_priority_weights[&"strength"] = 1.0
	build.stat_priority_weights[&"ki_max"]   = 0.4
	build.stat_priority_weights[&"speed"]    = 0.7
	build.stat_priority_weights[&"defense"]  = 0.3
	build.combat_style                       = &"striker"

	return CharacterFactory.create("Kakarot", &"saiyan", appearance, build)
