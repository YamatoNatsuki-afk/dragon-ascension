# core/GameManager.gd
# Autoload principal. Responsabilidad: arrancar la partida y conectar sistemas.
# No contiene lógica de gameplay — solo orquestación de inicio.
extends Node

# Ajusta este flag para alternar entre debug loop y UI real
# cuando implementes la interfaz. El resto del código no cambia.
@export var use_debug_loop: bool = true

# Número de días a simular automáticamente (solo en modo debug)
@export var debug_auto_days: int = 10

func _ready() -> void:
	# Pequeño defer para asegurar que todos los autoloads están listos
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
		# Aquí irá: SceneManager.go_to("res://scenes/hud/HUD.tscn")
		pass

# --- Obtener personaje ---

func _get_or_create_character() -> CharacterData:
	# Si existe un save, cargarlo. Si no, crear uno de prueba.
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
	appearance.aura_color  = Color(1.0, 0.8, 0.0)  # Dorado — Saiyajin

	var build                                      := BuildData.new()
	build.stat_priority_weights[&"strength"]        = 1.0
	build.stat_priority_weights[&"ki_max"]          = 0.4
	build.stat_priority_weights[&"speed"]           = 0.7
	build.stat_priority_weights[&"defense"]         = 0.3
	build.combat_style                              = &"striker"

	return CharacterFactory.create("Kakarot", &"saiyan", appearance, build)

# --- Debug loop ---

func _start_debug_loop(data: CharacterData) -> void:
	var loop := DebugDayLoop.new()
	loop.auto_days   = debug_auto_days
	loop.name        = "DebugDayLoop"
	add_child(loop)
	loop.begin(data)
