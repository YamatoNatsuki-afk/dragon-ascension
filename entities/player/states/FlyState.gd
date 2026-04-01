# res://entities/player/states/FlyState.gd
#
# Estado de vuelo libre. WASD mueve al jugador en X e Y sin gravedad.
# Toggle con Space: presionar activa, presionar de nuevo aterriza.
#
# MOVIMIENTO:
#   Usa velocity + move_and_slide() igual que MoveState.
#   Limita la velocidad cerca de los bordes de la arena con clamp_velocity().
#
# DESDE ESTE ESTADO se puede atacar, lanzar Ki y cargar Ki sin aterrizar.
#
class_name FlyState
extends PlayerState

const GROUND_Y:  float = 560.0
const CEILING_Y: float = 80.0
const LEFT_X:    float = 32.0
const RIGHT_X:   float = 1120.0

var _shadow: ColorRect = null

# ─────────────────────────────────────────────────────────────────────────────
# CICLO DE ESTADO
# ─────────────────────────────────────────────────────────────────────────────

func enter(_previous_state: PlayerState = null) -> void:
	_spawn_shadow()

func exit() -> void:
	_destroy_shadow()

func physics_update(_delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var speed     := CombatFormulas.get_move_speed(player.stats.get_stat(&"velocidad"))

	player.velocity = input_dir * speed

	# Frenar contra los bordes de la arena para no salir
	var pos := player.global_position
	if (pos.x <= LEFT_X and player.velocity.x < 0.0) or \
	   (pos.x >= RIGHT_X and player.velocity.x > 0.0):
		player.velocity.x = 0.0
	if (pos.y <= CEILING_Y and player.velocity.y < 0.0) or \
	   (pos.y >= GROUND_Y and player.velocity.y > 0.0):
		player.velocity.y = 0.0

	_update_shadow()

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("fly"):
		player.state_machine.change_state(&"IdleState")
	elif event.is_action_pressed("attack"):
		player.state_machine.change_state(&"AttackState")
	elif event.is_action_pressed("ki_blast"):
		player.state_machine.change_state(&"KiBlastState")
	elif event.is_action_pressed("ki_charge"):
		player.state_machine.change_state(&"KiChargeState")
	elif event.is_action_pressed("transform"):
		player.state_machine.change_state(&"TransformState")

# ─────────────────────────────────────────────────────────────────────────────
# SOMBRA PROYECTADA
# ─────────────────────────────────────────────────────────────────────────────

func _spawn_shadow() -> void:
	_shadow = ColorRect.new()
	_shadow.color = Color(0.0, 0.0, 0.0, 0.3)
	_shadow.size = Vector2(28.0, 10.0)
	_shadow.position = Vector2(-14.0, 20.0)
	player.add_child(_shadow)

func _destroy_shadow() -> void:
	if is_instance_valid(_shadow):
		_shadow.queue_free()
	_shadow = null

func _update_shadow() -> void:
	if not is_instance_valid(_shadow):
		return
	# La sombra se achica cuanto mas alto vuele el jugador
	var height_ratio := 1.0 - clampf(
		(GROUND_Y - player.global_position.y) / (GROUND_Y - CEILING_Y),
		0.0, 1.0
	)
	_shadow.scale = Vector2(height_ratio + 0.3, height_ratio * 0.5 + 0.2)
