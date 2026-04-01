# res://entities/Enemy/Enemy.gd
# v2: Soporte para EnemyData — arquetipos, tres comportamientos, Ki Blast enemigo.
#
# COMPORTAMIENTOS (definidos en EnemyData.Behavior):
#   MELEE  — persigue al jugador hasta atacar cuerpo a cuerpo
#   RANGED — mantiene distancia preferida y dispara Ki Blasts
#   HYBRID — ataca en melé cuando está cerca Y dispara Ki Blasts ocasionalmente
#
# El tipo se elige automáticamente por día si no se pasa uno externo.
#
class_name Enemy
extends CharacterBody2D

var max_health:      float = 100.0
var current_health:  float = 100.0
var attack_power:    float = 15.0
var move_speed:      float = 80.0
var attack_range:    float = 48.0
var attack_cooldown: float = 1.2
var resistencia:     float = 10.0

var enemy_data: EnemyData = null

var _player: CharacterBody2D = null
var _attack_timer:   float   = 0.0
var _ki_blast_timer: float   = 0.0
var _is_dead:        bool    = false

signal died
## Emitida cuando el player esquiva — CombatArena la escucha para el efecto visual.
signal attack_dodged(player_position: Vector2)
## Emitida tras recibir daño (post-mitigación). CombatArena la usa para estadísticas.
signal damage_received(amount: float)

# ─────────────────────────────────────────────────────────────────────────────
# SETUP
# ─────────────────────────────────────────────────────────────────────────────

## Configura el enemigo para un combate.
## Si no se pasa enemy_data, se selecciona el arquetipo adecuado para el día.
func setup(difficulty: float, player_ref: CharacterBody2D, day: int = 1,
		data: EnemyData = null) -> void:
	_player    = player_ref
	enemy_data = data if data != null else EnemyData.get_for_day(day, difficulty)

	# Curva de escalado base
	var base_hp:  float = (50.0 + day * 7.0) * difficulty
	var base_atk: float = (8.0  + day * 0.4) * difficulty
	var base_spd: float = (60.0 + day * 0.3) + (difficulty * 15.0)
	var base_res: float = (5.0  + day * 0.5)

	# Aplicar multiplicadores del arquetipo
	max_health     = base_hp  * enemy_data.hp_mult
	current_health = max_health
	attack_power   = base_atk * enemy_data.attack_mult
	move_speed     = base_spd * enemy_data.speed_mult
	resistencia    = base_res * enemy_data.resistencia_mult
	attack_range   = enemy_data.preferred_range

	if enemy_data.cooldown_override > 0.0:
		attack_cooldown = enemy_data.cooldown_override

	# Sincronizar color del placeholder con el arquetipo
	_update_placeholder_color()

	print("[Enemy] '%s' configurado → HP:%.0f  ATK:%.1f  SPD:%.0f  RES:%.0f  Comportamiento:%s" % [
		enemy_data.display_name,
		max_health, attack_power, move_speed, resistencia,
		["MELEE","RANGED","HYBRID"][enemy_data.behavior]
	])

func _update_placeholder_color() -> void:
	if enemy_data == null:
		return
	for child in get_children():
		if child is ColorRect:
			child.color = enemy_data.color
			break

# ─────────────────────────────────────────────────────────────────────────────
# LOOP DE FÍSICA
# ─────────────────────────────────────────────────────────────────────────────

func _physics_process(delta: float) -> void:
	if _is_dead or _player == null:
		return

	_attack_timer   -= delta
	_ki_blast_timer -= delta

	var behavior: int = EnemyData.Behavior.MELEE
	if enemy_data != null:
		behavior = enemy_data.behavior

	match behavior:
		EnemyData.Behavior.MELEE:
			_update_melee()
		EnemyData.Behavior.RANGED:
			_update_ranged()
		EnemyData.Behavior.HYBRID:
			_update_hybrid()

	move_and_slide()

# ─────────────────────────────────────────────────────────────────────────────
# COMPORTAMIENTOS
# ─────────────────────────────────────────────────────────────────────────────

func _update_melee() -> void:
	var dist: float = global_position.distance_to(_player.global_position)
	if dist <= attack_range and _attack_timer <= 0.0:
		_try_melee_attack()
	else:
		_move_toward_player()

func _update_ranged() -> void:
	var dist: float      = global_position.distance_to(_player.global_position)
	var pref: float      = enemy_data.preferred_range if enemy_data else attack_range
	var ki_cd: float     = enemy_data.ki_blast_cooldown if enemy_data else 2.5

	# Gestionar distancia
	if dist < pref * 0.65:
		# Demasiado cerca — retroceder
		velocity = (_player.global_position - global_position).normalized() * (-move_speed)
	elif dist > pref * 1.5:
		# Demasiado lejos — acercarse
		_move_toward_player()
	else:
		velocity = Vector2.ZERO

	# Disparar Ki Blast cuando se puede
	if _ki_blast_timer <= 0.0:
		_try_ki_blast()
		_ki_blast_timer = ki_cd

func _update_hybrid() -> void:
	var dist: float  = global_position.distance_to(_player.global_position)
	var ki_cd: float = enemy_data.ki_blast_cooldown if enemy_data else 3.0

	# Melé cuando está cerca
	if dist <= attack_range and _attack_timer <= 0.0:
		_try_melee_attack()
	else:
		_move_toward_player()

	# Ki Blast ocasional fuera del rango de contacto
	if _ki_blast_timer <= 0.0 and dist > attack_range * 0.6:
		_try_ki_blast()
		_ki_blast_timer = ki_cd

func _move_toward_player() -> void:
	velocity = (_player.global_position - global_position).normalized() * move_speed

# ─────────────────────────────────────────────────────────────────────────────
# ATAQUE MELEE
# ─────────────────────────────────────────────────────────────────────────────

func _try_melee_attack() -> void:
	_attack_timer = attack_cooldown
	velocity      = Vector2.ZERO

	var dodge_chance := _get_player_dodge_chance()
	if dodge_chance > 0.0 and randf() < dodge_chance:
		attack_dodged.emit(_player.global_position)
		print("[Enemy] Ataque melé esquivado (chance %.0f%%)" % (dodge_chance * 100.0))
		return

	_deal_damage_to_player(attack_power)
	print("[Enemy] Daño melé: %.1f" % attack_power)

# ─────────────────────────────────────────────────────────────────────────────
# KI BLAST (ataque a distancia del enemigo)
# ─────────────────────────────────────────────────────────────────────────────

func _try_ki_blast() -> void:
	if _player == null or _is_dead:
		return
	var ki_mult: float = enemy_data.ki_blast_mult if enemy_data else 0.7
	var damage: float  = attack_power * ki_mult
	_launch_ki_projectile(damage)

func _launch_ki_projectile(damage: float) -> void:
	var parent := get_parent()
	if parent == null:
		return

	# Proyectil visual: ColorRect que vuela hacia el player
	var proj         := ColorRect.new()
	proj.color        = Color(0.55, 0.25, 1.0, 0.90)
	proj.size         = Vector2(14, 14)
	proj.position     = global_position + Vector2(-7, -30)   # centro del enemigo
	parent.add_child(proj)

	var target: Vector2 = _player.global_position + Vector2(-7, -24)   # centro del player
	var travel: float   = global_position.distance_to(_player.global_position)
	var duration: float = clampf(travel / 480.0, 0.25, 0.70)

	var tween := proj.create_tween()
	tween.tween_property(proj, "position", target, duration)
	tween.tween_callback(func() -> void:
		if is_instance_valid(proj):
			proj.queue_free()
		_ki_blast_hit(damage)
	)

func _ki_blast_hit(damage: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	# Ki Blast puede esquivarse, pero con 60% de probabilidad respecto al melé
	var dodge_chance: float = _get_player_dodge_chance() * 0.6
	if dodge_chance > 0.0 and randf() < dodge_chance:
		attack_dodged.emit(_player.global_position)
		return
	_deal_damage_to_player(damage)
	print("[Enemy] Ki Blast impacta: %.1f" % damage)

# ─────────────────────────────────────────────────────────────────────────────
# ESQUIVE DEL PLAYER
# ─────────────────────────────────────────────────────────────────────────────

## Calcula la probabilidad de esquive basada en los stats del player.
func _get_player_dodge_chance() -> float:
	var stats_component = _player.get("stats")
	if stats_component == null:
		return 0.0

	var velocidad: float     = stats_component.get_stat(&"velocidad")
	var intel_combate: float = stats_component.get_stat(&"intel_combate")

	# Velocidad → hasta 50% de esquive con diminishing returns
	var dodge_vel: float = (velocidad / (velocidad + 100.0)) * 0.50
	# Intel_combate → hasta 30% adicional
	var dodge_ic: float  = (intel_combate / (intel_combate + 50.0)) * 0.30

	return minf(dodge_vel + dodge_ic, 0.75)

func _deal_damage_to_player(amount: float) -> void:
	if _player.has_method("take_damage"):
		_player.take_damage(amount)
	else:
		var health_comp = _player.get("health")
		if health_comp != null and health_comp.has_method("take_damage"):
			health_comp.take_damage(amount)

# ─────────────────────────────────────────────────────────────────────────────
# RECIBIR DAÑO
# ─────────────────────────────────────────────────────────────────────────────

func take_damage(amount: float) -> void:
	if _is_dead:
		return
	var mitigation: float = resistencia / (resistencia + 100.0)
	var final_dmg: float  = amount * (1.0 - mitigation)
	current_health        = maxf(0.0, current_health - final_dmg)
	damage_received.emit(final_dmg)
	if current_health <= 0.0:
		_die()

func _die() -> void:
	if _is_dead:
		return
	_is_dead  = true
	velocity   = Vector2.ZERO
	died.emit()

func get_health_percent() -> float:
	return current_health / max_health if max_health > 0.0 else 0.0

## Consulta pública del estado de muerte. KiBlastState y otros scripts externos deben usar
## este método en lugar de leer _is_dead directamente.
func is_dead() -> bool:
	return _is_dead
