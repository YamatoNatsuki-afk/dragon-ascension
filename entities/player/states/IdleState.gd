# entities/player/states/IdleState.gd
class_name IdleState
extends PlayerState

func enter(_prev = null) -> void:
	# Aquí irá: player.animation_player.play("idle")
	pass

func physics_update(_delta: float) -> void:
	# Si hay movimiento, ir a MoveState
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dir != Vector2.ZERO:
		player.state_machine.change_state(&"MoveState")

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		player.state_machine.change_state(&"AttackState")
