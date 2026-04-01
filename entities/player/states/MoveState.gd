# res://entities/player/states/MoveState.gd
# Estado de movimiento top-down. WASD mueve al Player.
#
# FIX v2: La fórmula original (velocidad * 30.0) era lineal y se rompía
# en tiers altos. A tier Elite (velocidad~120) daba 3,600 px/s.
# Ahora usa CombatFormulas.get_move_speed() con diminishing returns:
#   ~194 px/s (Civil) → ~372 px/s (Elite) → ~520 px/s (Legendario cap)
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

	var speed: float = CombatFormulas.get_move_speed(player.stats.get_stat(&"velocidad"))
	player.velocity  = input_dir * speed

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
