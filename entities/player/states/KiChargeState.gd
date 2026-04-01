# res://entities/player/states/KiChargeState.gd
#
# Estado de carga de Ki. El jugador se detiene y canaliza energia.
# Hold C para cargar Ki 5x mas rapido que la regen pasiva.
#
# FLUJO:
#   - enter()         : detener al jugador, crear aura visual
#   - physics_update(): cargar Ki mientras C este presionado
#   - Al soltar C     : volver a IdleState
#   - Al moverse      : cancelar carga y ir a MoveState
#   - Al atacar       : cancelar y ir a AttackState / KiBlastState
#
class_name KiChargeState
extends PlayerState

var _aura: ColorRect = null

# ─────────────────────────────────────────────────────────────────────────────
# CICLO DE ESTADO
# ─────────────────────────────────────────────────────────────────────────────

func enter(_previous_state: PlayerState = null) -> void:
	player.velocity = Vector2.ZERO
	_spawn_aura()

func exit() -> void:
	_destroy_aura()

func physics_update(delta: float) -> void:
	player.velocity = Vector2.ZERO

	# Cancelar si el jugador intenta moverse
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dir != Vector2.ZERO:
		player.state_machine.change_state(&"MoveState")
		return

	# Cancelar si suelta el boton de carga
	if not Input.is_action_pressed("ki_charge"):
		player.state_machine.change_state(&"IdleState")
		return

	# Cargar Ki activamente (5x regen pasiva)
	player.ki.charge_tick(delta)
	_update_aura_color()

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		player.state_machine.change_state(&"AttackState")
	elif event.is_action_pressed("ki_blast"):
		player.state_machine.change_state(&"KiBlastState")
	elif event.is_action_pressed("transform"):
		player.state_machine.change_state(&"TransformState")
	elif event.is_action_pressed("fly"):
		player.state_machine.change_state(&"FlyState")

# ─────────────────────────────────────────────────────────────────────────────
# VISUAL DEL AURA
# ─────────────────────────────────────────────────────────────────────────────

func _spawn_aura() -> void:
	_aura = ColorRect.new()
	_aura.size = Vector2(56.0, 72.0)
	_aura.position = Vector2(-28.0, -36.0)
	_aura.color = Color(0.3, 0.75, 1.0, 0.45)
	player.add_child(_aura)

	# Pulso de entrada
	var t := _aura.create_tween()
	t.tween_property(_aura, "modulate:a", 0.2, 0.35)
	t.tween_property(_aura, "modulate:a", 0.8, 0.35)

func _destroy_aura() -> void:
	if is_instance_valid(_aura):
		var t := _aura.create_tween()
		t.tween_property(_aura, "modulate:a", 0.0, 0.2)
		t.tween_callback(_aura.queue_free)
		_aura = null

func _update_aura_color() -> void:
	if not is_instance_valid(_aura):
		return
	var ratio: float = player.ki.get_fill_ratio()
	# Azul cuando vacio -> dorado cuando lleno
	_aura.color = Color(
		0.3 + ratio * 0.7,
		0.75 - ratio * 0.25,
		1.0 - ratio * 0.9,
		0.5
	)
