# res://entities/player/states/AttackState.gd
class_name AttackState
extends PlayerState

const BASE_ATTACK_RANGE:    float = 64.0
const BASE_ATTACK_DURATION: float = 0.4
const BASE_ATTACK_COOLDOWN: float = 0.7

var _last_attack_time: float = -999.0

func _get_cooldown() -> float:
	var ic: float = player.stats.get_stat(&"intel_combate")
	return BASE_ATTACK_COOLDOWN * (1.0 - ic / (ic + 150.0))

func enter(_previous_state: PlayerState = null) -> void:
	var now     := Time.get_ticks_msec() / 1000.0
	if now - _last_attack_time < _get_cooldown():
		player.state_machine.change_state(&"IdleState")
		return
	_last_attack_time = now
	_try_hit_enemy()

func exit() -> void:
	pass

func update(delta: float) -> void:
	var elapsed := Time.get_ticks_msec() / 1000.0 - _last_attack_time
	if elapsed >= BASE_ATTACK_DURATION:
		player.state_machine.change_state(&"IdleState")

func physics_update(_delta: float) -> void:
	player.velocity = Vector2.ZERO

func _try_hit_enemy() -> void:
	var attack_power: float = player.stats.get_stat(&"fuerza") * 2.0
	var enemy: Enemy        = _find_closest_enemy()
	if enemy == null:
		return
	if player.global_position.distance_to(enemy.global_position) <= BASE_ATTACK_RANGE:
		enemy.take_damage(attack_power)
		_spawn_hit_effect(enemy.global_position)
		print("[AttackState] Hit! Dano: %.1f | HP Enemy: %.1f" % [attack_power, enemy.current_health])

func _find_closest_enemy() -> Enemy:
	var parent := player.get_parent()
	if parent == null:
		return null
	for child in parent.get_children():
		if child is Enemy:
			return child as Enemy
	return null

func _spawn_hit_effect(pos: Vector2) -> void:
	var hit      := ColorRect.new()
	hit.color     = Color(1.0, 0.55, 0.0, 0.9)
	hit.size      = Vector2(28, 28)
	hit.position  = pos + Vector2(-14, -14)
	player.get_parent().add_child(hit)
	var tween := hit.create_tween()
	tween.tween_property(hit, "modulate:a", 0.0, 0.25)
	tween.tween_callback(hit.queue_free)
