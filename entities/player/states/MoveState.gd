# res://entities/player/states/MoveState.gd
# Estado de movimiento top-down. WASD mueve al Player.
class_name MoveState
extends PlayerState

func enter(_previous_state: PlayerState = null) -> void:
	pass

func exit() -> void:
	player.velocity = Vector2.ZERO

func physics_update(_delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir == Vector2.ZERO:
		player.state_machine.change_state(&"IdleState")
		return

	# MIGRACIÓN v2: "speed" → "velocidad"
	# Fórmula: velocidad * 30 da ~150–300 px/s en rango normal de stats (5–10).
	# Ajustable desde el stat sin tocar código.
	var speed: float = player.stats.get_stat(&"velocidad") * 30.0
	player.velocity  = input_dir * speed

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		player.state_machine.change_state(&"AttackState")
