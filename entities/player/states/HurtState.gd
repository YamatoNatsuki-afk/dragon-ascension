# entities/player/states/HurtState.gd
# Estado de daño recibido — stun breve, sin movimiento.
# Futuro: lanzar animación de hurt, knockback direccional.
class_name HurtState
extends PlayerState

const HURT_DURATION: float = 0.4

var _timer: float = 0.0

func enter(_previous_state: PlayerState = null) -> void:
	_timer = HURT_DURATION
	player.velocity = Vector2.ZERO

func exit() -> void:
	_timer = 0.0

func update(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		player.state_machine.change_state(&"IdleState")

func physics_update(_delta: float) -> void:
	player.velocity = Vector2.ZERO
