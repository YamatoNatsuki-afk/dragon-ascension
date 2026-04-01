# res://entities/player/states/IdleState.gd
class_name IdleState
extends PlayerState

func enter(_prev = null) -> void:
	# Aquí irá: player.animation_player.play("idle")
	pass

func physics_update(_delta: float) -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dir != Vector2.ZERO:
		player.state_machine.change_state(&"MoveState")

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		player.state_machine.change_state(&"AttackState")
	elif event.is_action_pressed("ki_blast"):
		player.state_machine.change_state(&"KiBlastState")
	elif event.is_action_pressed("ki_charge"):
		player.state_machine.change_state(&"KiChargeState")
	elif event.is_action_pressed("transform"):
		player.state_machine.change_state(&"TransformState")
	elif event.is_action_pressed("fly"):
		player.state_machine.change_state(&"FlyState")
