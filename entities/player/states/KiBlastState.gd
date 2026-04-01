# res://entities/player/states/KiBlastState.gd
#
# Estado de ataque Ki a distancia.
# El jugador lanza un proyectil de energía que viaja hacia el enemigo más cercano.
#
# FLUJO:
#   1. enter() → verificar Ki suficiente → gastar Ki → lanzar proyectil → timer
#   2. update() → esperar duración de animación → volver a IdleState
#
# COSTO:
#   CombatFormulas.get_ki_blast_cost() = 15% del Ki máximo (mínimo 5).
#   Si no hay Ki suficiente, cancela y vuelve a Idle sin penalización.
#
# PROYECTIL:
#   ColorRect naranja/dorado que hace tween hacia el enemigo.
#   Al llegar aplica daño calculado por CombatFormulas.get_ki_damage().
#   En el futuro: reemplazar por KiBlast.tscn con shader y partículas.
#
# COOLDOWN:
#   Compartido con AttackState via _last_ki_attack_time.
#   Base 1.2s reducido por intel_combate (igual que ataque físico).
#
class_name KiBlastState
extends PlayerState

const BASE_DURATION:    float = 0.5   # segundos que dura el estado
const BASE_COOLDOWN:    float = 1.2   # cooldown base del Ki blast
const BLAST_RANGE:      float = 500.0 # rango máximo de detección del enemigo
const PROJECTILE_SPEED: float = 0.35  # segundos que tarda el proyectil en llegar

var _last_ki_attack_time: float = -999.0
var _timer: float = 0.0

# ─────────────────────────────────────────────────────────────────────────────
# ESTADO
# ─────────────────────────────────────────────────────────────────────────────

func enter(_previous_state: PlayerState = null) -> void:
	player.velocity = Vector2.ZERO
	_timer = BASE_DURATION

	# Verificar cooldown
	var now := Time.get_ticks_msec() / 1000.0
	if now - _last_ki_attack_time < _get_cooldown():
		player.state_machine.change_state(&"IdleState")
		return

	# Verificar Ki suficiente
	var cost := CombatFormulas.get_ki_blast_cost(player.ki.get_max_ki())
	if not player.ki.spend(cost):
		# Sin Ki — efecto visual de fallo y volver a Idle
		_spawn_no_ki_text()
		player.state_machine.change_state(&"IdleState")
		return

	_last_ki_attack_time = now

	# Buscar enemigo y lanzar proyectil
	var enemy := _find_closest_enemy()
	if enemy != null:
		_launch_projectile(enemy)
	else:
		# Sin enemigo en rango — Ki gastado pero sin daño (jugador ve el blast)
		_spawn_blast_effect(player.global_position + Vector2(80, 0))

func exit() -> void:
	_timer = 0.0

func update(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		player.state_machine.change_state(&"IdleState")

func physics_update(_delta: float) -> void:
	player.velocity = Vector2.ZERO

# ─────────────────────────────────────────────────────────────────────────────
# LÓGICA DE ATAQUE
# ─────────────────────────────────────────────────────────────────────────────

func _get_cooldown() -> float:
	var ic: float = player.stats.get_stat(&"intel_combate")
	return BASE_COOLDOWN * (1.0 - ic / (ic + 150.0))

func _find_closest_enemy() -> Enemy:
	var parent := player.get_parent()
	if parent == null:
		return null
	var closest: Enemy  = null
	var closest_dist: float = BLAST_RANGE
	for child in parent.get_children():
		if child is Enemy:
			var d := player.global_position.distance_to(child.global_position)
			if d < closest_dist:
				closest_dist = d
				closest      = child as Enemy
	return closest

func _launch_projectile(enemy: Enemy) -> void:
	var start_pos := player.global_position
	var end_pos   := enemy.global_position

	# Crear proyectil visual
	var blast := ColorRect.new()
	blast.color    = Color(1.0, 0.85, 0.1, 1.0)   # dorado Ki
	blast.size     = Vector2(20.0, 20.0)
	blast.position = start_pos + Vector2(-10.0, -10.0)
	player.get_parent().add_child(blast)

	# Animar viaje hacia el enemigo
	var tween := blast.create_tween()
	tween.set_parallel(true)
	tween.tween_property(blast, "position",
		end_pos + Vector2(-10.0, -10.0), PROJECTILE_SPEED)
	tween.tween_property(blast, "modulate:a", 0.0, PROJECTILE_SPEED)

	# Aplicar daño al llegar
	var ki_dmg := CombatFormulas.get_ki_damage(
		player.stats.get_stat(&"poder_ki"),
		player.stats.get_stat(&"ki")
	)
	tween.set_parallel(false)
	tween.tween_callback(func() -> void:
		if is_instance_valid(enemy) and not enemy.is_dead():
			enemy.take_damage(ki_dmg)
			_spawn_impact_effect(end_pos)
			print("[KiBlastState] Ki Blast! Daño: %.1f | HP Enemy: %.1f" % [
				ki_dmg, enemy.current_health
			])
		blast.queue_free()
	)

func _spawn_impact_effect(pos: Vector2) -> void:
	var ring := ColorRect.new()
	ring.color    = Color(1.0, 0.6, 0.0, 0.8)
	ring.size     = Vector2(48.0, 48.0)
	ring.position = pos + Vector2(-24.0, -24.0)
	player.get_parent().add_child(ring)

	var tween := ring.create_tween()
	tween.set_parallel(true)
	tween.tween_property(ring, "scale", Vector2(2.5, 2.5), 0.3)
	tween.tween_property(ring, "modulate:a", 0.0, 0.3)
	tween.tween_callback(ring.queue_free)

func _spawn_blast_effect(pos: Vector2) -> void:
	var orb := ColorRect.new()
	orb.color    = Color(0.3, 0.8, 1.0, 0.9)
	orb.size     = Vector2(16.0, 16.0)
	orb.position = pos + Vector2(-8.0, -8.0)
	player.get_parent().add_child(orb)

	var tween := orb.create_tween()
	tween.set_parallel(true)
	tween.tween_property(orb, "position:x", pos.x + 120.0, 0.4)
	tween.tween_property(orb, "modulate:a", 0.0, 0.4)
	tween.tween_callback(orb.queue_free)

func _spawn_no_ki_text() -> void:
	var label := Label.new()
	label.text     = "¡SIN KI!"
	label.position = player.global_position + Vector2(-30.0, -50.0)
	label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.1))
	label.add_theme_font_size_override("font_size", 14)
	player.get_parent().add_child(label)

	var tween := label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 30.0, 0.5)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(label.queue_free)
