# res://scenes/combat_arena/CombatCamera.gd
#
# Cámara espectadora para la arena de combate.
# Se añade como hijo de CombatArena vía código.
#
# MODOS (ciclar con TAB):
#   FOLLOW_PLAYER  – sigue suavemente al jugador
#   FOLLOW_ENEMY   – sigue suavemente al enemigo
#   FOLLOW_BOTH    – encuadra a ambos, zoom dinámico
#   FREE           – panning libre con IJKL, zoom con rueda del ratón
#
# CONTROLES:
#   TAB           : ciclar modo
#   IJKL          : panear en modo Libre
#   Rueda ratón   : zoom in/out (todos los modos)
#   R             : resetear zoom y centrar en el jugador
#
class_name CombatCamera
extends Camera2D

signal mode_changed(mode_name: String)

enum Mode { FOLLOW_PLAYER, FOLLOW_ENEMY, FOLLOW_BOTH, FREE }

const BASE_ZOOM    := Vector2(1.0, 1.0)
const MIN_ZOOM     := Vector2(0.30, 0.30)
const MAX_ZOOM     := Vector2(2.5,  2.5)
const ZOOM_STEP    := 0.12          # factor por tick de rueda
const PAN_SPEED    := 320.0         # px/s en modo libre (a zoom 1.0)
const LERP_SPEED   := 7.0           # velocidad de suavizado de posición
const ZOOM_LERP    := 5.0           # velocidad de suavizado de zoom

const MODE_NAMES: Array[String] = ["Jugador", "Enemigo", "Ambos", "Libre"]

var _player: Node2D = null
var _enemy:  Node2D = null
var _mode:   int    = Mode.FOLLOW_PLAYER
var _target_zoom: Vector2 = BASE_ZOOM

# ─────────────────────────────────────────────────────────────────────────────
# INICIALIZACIÓN
# ─────────────────────────────────────────────────────────────────────────────

func setup(player: Node2D, enemy: Node2D) -> void:
	_player = player
	_enemy  = enemy
	# Snap inmediato al jugador al inicio
	if is_instance_valid(_player):
		global_position = _player.global_position

func _ready() -> void:
	zoom                       = BASE_ZOOM
	_target_zoom               = BASE_ZOOM
	position_smoothing_enabled = false   # manejamos el lerp manualmente
	make_current()

# ─────────────────────────────────────────────────────────────────────────────
# PROCESO
# ─────────────────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	_update_position(delta)
	zoom = zoom.lerp(_target_zoom, ZOOM_LERP * delta)

func _update_position(delta: float) -> void:
	match _mode:
		Mode.FOLLOW_PLAYER:
			if is_instance_valid(_player):
				global_position = global_position.lerp(
					_player.global_position, LERP_SPEED * delta
				)
		Mode.FOLLOW_ENEMY:
			if is_instance_valid(_enemy):
				global_position = global_position.lerp(
					_enemy.global_position, LERP_SPEED * delta
				)
		Mode.FOLLOW_BOTH:
			_update_follow_both(delta)
		Mode.FREE:
			_update_free_pan(delta)

func _update_follow_both(delta: float) -> void:
	if not is_instance_valid(_player) or not is_instance_valid(_enemy):
		return
	var center: Vector2 = (_player.global_position + _enemy.global_position) * 0.5
	global_position = global_position.lerp(center, LERP_SPEED * delta)

	# Zoom dinámico: cuanto más separados los combatientes, más se aleja la cámara
	var dist: float = _player.global_position.distance_to(_enemy.global_position)
	var z: float = clampf(480.0 / maxf(dist + 150.0, 1.0), MIN_ZOOM.x, 1.15)
	_target_zoom = Vector2(z, z)

func _update_free_pan(delta: float) -> void:
	var dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_I): dir.y -= 1.0
	if Input.is_key_pressed(KEY_K): dir.y += 1.0
	if Input.is_key_pressed(KEY_J): dir.x -= 1.0
	if Input.is_key_pressed(KEY_L): dir.x += 1.0
	if dir != Vector2.ZERO:
		# Ajustar velocidad de paneo por el nivel de zoom actual
		global_position += dir.normalized() * (PAN_SPEED / zoom.x) * delta

# ─────────────────────────────────────────────────────────────────────────────
# INPUT
# ─────────────────────────────────────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	# Ciclar modo de cámara
	if event.is_action_pressed("camera_cycle"):
		_cycle_mode()
		get_viewport().set_input_as_handled()
		return

	# Resetear cámara al jugador
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		_reset_camera()
		get_viewport().set_input_as_handled()
		return

	# Zoom con rueda del ratón
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				_target_zoom = (_target_zoom * (1.0 + ZOOM_STEP)).clamp(MIN_ZOOM, MAX_ZOOM)
				get_viewport().set_input_as_handled()
			MOUSE_BUTTON_WHEEL_DOWN:
				_target_zoom = (_target_zoom * (1.0 - ZOOM_STEP)).clamp(MIN_ZOOM, MAX_ZOOM)
				get_viewport().set_input_as_handled()

# ─────────────────────────────────────────────────────────────────────────────
# LÓGICA DE MODOS
# ─────────────────────────────────────────────────────────────────────────────

func _cycle_mode() -> void:
	_mode = (_mode + 1) % 4

	# Al salir de FOLLOW_BOTH o FREE, restaurar zoom base
	if _mode == Mode.FOLLOW_PLAYER or _mode == Mode.FOLLOW_ENEMY:
		_target_zoom = BASE_ZOOM

	mode_changed.emit(MODE_NAMES[_mode])
	print("[CombatCamera] Modo: %s" % MODE_NAMES[_mode])

func _reset_camera() -> void:
	_mode        = Mode.FOLLOW_PLAYER
	_target_zoom = BASE_ZOOM
	mode_changed.emit(MODE_NAMES[_mode])

func get_mode_name() -> String:
	return MODE_NAMES[_mode]
