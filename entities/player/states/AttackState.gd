# res://entities/player/states/AttackState.gd
# v2: Sistema de combo encadenado.
#
# FLUJO DE COMBO:
#   Presionar Z → entra en AttackState → intenta golpear.
#   Si el golpe conecta → _combo_count sube → se emite EventBus.combo_updated.
#   Si Z se vuelve a presionar dentro de COMBO_WINDOW → _is_chaining = true,
#   cooldown reducido a MIN_CHAIN_COOLDOWN → se encadena el siguiente golpe.
#   Si el window expira o el jugador no presiona Z → combo se rompe.
#
# MULTIPLICADORES DE DAÑO POR COMBO:
#   Hit 1 → ×1.00   Hit 2 → ×1.25   Hit 3 → ×1.55
#   Hit 4 → ×1.90   Hit 5+ → ×2.30
#
# EFECTOS VISUALES:
#   • Flash en el enemigo (naranja → rojo → rosa al subir el combo)
#   • Número de daño flotante con fuente creciente
#   • Texto "2 COMBO", "3 COMBO!" … debajo del número (desde hit 2)
#
class_name AttackState
extends PlayerState

const BASE_ATTACK_RANGE:     float = 64.0
const BASE_ATTACK_DURATION:  float = 0.30        # duración de la animación por hit
const COMBO_WINDOW:          float = 0.80        # segundos para encadenar el siguiente hit
const MIN_CHAIN_COOLDOWN:    float = 0.10        # cooldown mínimo al encadenar

const COMBO_MULTS: Array[float] = [1.0, 1.25, 1.55, 1.90, 2.30]
const HIT_COLORS: Array[Color]  = [
	Color(1.00, 0.55, 0.00),   # 1  naranja
	Color(1.00, 0.82, 0.10),   # 2  amarillo
	Color(1.00, 0.40, 0.80),   # 3  rosa
	Color(0.40, 0.80, 1.00),   # 4  azul-cian
	Color(0.95, 0.20, 0.20),   # 5+ rojo brillante
]

# Estado persistente entre entradas del estado (el nodo no se recrea)
var _last_attack_time: float = -999.0
var _last_hit_time:    float = -999.0
var _combo_count:      int   = 0

# ─────────────────────────────────────────────────────────────────────────────
# CICLO DE ESTADO
# ─────────────────────────────────────────────────────────────────────────────

func _get_cooldown() -> float:
	return CombatFormulas.get_attack_cooldown(player.stats.get_stat(&"intel_combate"))

func enter(_previous_state: PlayerState = null) -> void:
	var now: float = Time.get_ticks_msec() / 1000.0
	var since_last_hit: float = now - _last_hit_time
	var is_chaining: bool = since_last_hit <= COMBO_WINDOW and _combo_count > 0

	# Resetear combo si el window expiró
	if not is_chaining and _combo_count > 0:
		_break_combo()

	# Verificar cooldown — las cadenas usan cooldown mínimo
	var effective_cd: float = MIN_CHAIN_COOLDOWN if is_chaining else _get_cooldown()
	if now - _last_attack_time < effective_cd:
		player.state_machine.change_state(&"IdleState")
		return

	_last_attack_time = now
	_try_hit_enemy()

func exit() -> void:
	pass

func update(_delta: float) -> void:
	var elapsed: float = Time.get_ticks_msec() / 1000.0 - _last_attack_time
	if elapsed >= BASE_ATTACK_DURATION:
		# Si el combo expiró mientras esperábamos, romperlo
		var since_hit: float = Time.get_ticks_msec() / 1000.0 - _last_hit_time
		if _combo_count > 0 and since_hit > COMBO_WINDOW:
			_break_combo()
		player.state_machine.change_state(&"IdleState")

func physics_update(_delta: float) -> void:
	player.velocity = Vector2.ZERO

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		# Permitir encadenado durante la animación (a partir del 40% de la duración)
		var elapsed: float = Time.get_ticks_msec() / 1000.0 - _last_attack_time
		if elapsed >= BASE_ATTACK_DURATION * 0.4:
			player.state_machine.change_state(&"AttackState")
	elif event.is_action_pressed("ki_blast"):
		player.state_machine.change_state(&"KiBlastState")
	elif event.is_action_pressed("ki_charge"):
		player.state_machine.change_state(&"KiChargeState")
	elif event.is_action_pressed("transform"):
		player.state_machine.change_state(&"TransformState")
	elif event.is_action_pressed("fly"):
		player.state_machine.change_state(&"FlyState")

# ─────────────────────────────────────────────────────────────────────────────
# LÓGICA DE GOLPE
# ─────────────────────────────────────────────────────────────────────────────

func _try_hit_enemy() -> void:
	var mult: float  = COMBO_MULTS[min(_combo_count, COMBO_MULTS.size() - 1)]
	var base: float  = CombatFormulas.get_phys_damage(
		player.stats.get_stat(&"fuerza"),
		player.stats.get_stat(&"intel_combate")
	)
	var damage: float = base * mult

	var enemy: Enemy = _find_closest_enemy()
	if enemy == null:
		return
	if player.global_position.distance_to(enemy.global_position) > BASE_ATTACK_RANGE:
		return   # fuera de rango — no es miss, el jugador simplemente no alcanzó

	enemy.take_damage(damage)

	_last_hit_time = Time.get_ticks_msec() / 1000.0
	_combo_count  += 1

	_spawn_hit_visuals(enemy.global_position, damage, _combo_count)
	EventBus.combo_updated.emit(_combo_count, mult)

	print("[AttackState] Hit %d! Daño: %.1f (×%.2f) | HP enemy: %.1f" % [
		_combo_count, damage, mult, enemy.current_health
	])

func _break_combo() -> void:
	if _combo_count == 0:
		return
	_combo_count = 0
	EventBus.combo_updated.emit(0, 1.0)

# ─────────────────────────────────────────────────────────────────────────────
# EFECTOS VISUALES
# ─────────────────────────────────────────────────────────────────────────────

func _spawn_hit_visuals(pos: Vector2, damage: float, combo: int) -> void:
	var parent := player.get_parent()
	if parent == null:
		return

	var step: int  = min(combo - 1, HIT_COLORS.size() - 1)
	var col: Color = HIT_COLORS[step]

	# ── Flash de impacto (ColorRect que se desvanece) ─────────────────────────
	var flash      := ColorRect.new()
	flash.color     = col
	var flash_size: float = 28.0 + step * 5.0
	flash.size      = Vector2(flash_size, flash_size)
	flash.position  = pos + Vector2(-flash_size * 0.5, -flash_size * 0.5)
	parent.add_child(flash)
	var tw1 := flash.create_tween()
	tw1.set_parallel(true)
	tw1.tween_property(flash, "scale", Vector2(1.5, 1.5), 0.18)
	tw1.tween_property(flash, "modulate:a", 0.0, 0.22)
	tw1.tween_callback(flash.queue_free)

	# ── Número de daño flotante ────────────────────────────────────────────────
	var dmg_label      := Label.new()
	dmg_label.text      = "%.0f" % damage
	dmg_label.position  = pos + Vector2(-18.0, -52.0)
	var font_size: int  = 16 + step * 4   # crece con el combo
	dmg_label.add_theme_font_size_override("font_size", font_size)
	dmg_label.add_theme_color_override("font_color", col)
	parent.add_child(dmg_label)
	var tw2 := dmg_label.create_tween()
	tw2.set_parallel(true)
	tw2.tween_property(dmg_label, "position:y", dmg_label.position.y - 48.0, 0.75)
	tw2.tween_property(dmg_label, "modulate:a", 0.0, 0.75)
	tw2.tween_callback(dmg_label.queue_free)

	# ── Texto de combo (desde el 2º golpe) ────────────────────────────────────
	if combo >= 2:
		var ctxt      := Label.new()
		ctxt.text      = _combo_text(combo)
		ctxt.position  = pos + Vector2(-32.0, -78.0)
		var csize: int = 13 + step * 3
		ctxt.add_theme_font_size_override("font_size", csize)
		ctxt.add_theme_color_override("font_color", Color(1.0, 0.92, 0.25))
		parent.add_child(ctxt)
		# Efecto de "punch" en la escala: crece y vuelve, luego se desvanece
		var tw3 := ctxt.create_tween()
		tw3.tween_property(ctxt, "scale", Vector2(1.35, 1.35), 0.07)
		tw3.tween_property(ctxt, "scale", Vector2(1.00, 1.00), 0.08)
		var tw4 := ctxt.create_tween()
		tw4.tween_interval(0.30)
		tw4.tween_property(ctxt, "modulate:a", 0.0, 0.40)
		tw4.tween_callback(ctxt.queue_free)

func _combo_text(count: int) -> String:
	match count:
		2: return "2 COMBO"
		3: return "3 COMBO!"
		4: return "4 COMBO!!"
		5: return "5 COMBO!!!"
		_: return "%d COMBO!!!!" % count

# ─────────────────────────────────────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────────────────────────────────────

func _find_closest_enemy() -> Enemy:
	var parent := player.get_parent()
	if parent == null:
		return null
	var closest: Enemy       = null
	var closest_dist: float  = BASE_ATTACK_RANGE
	for child in parent.get_children():
		if child is Enemy:
			var d: float = player.global_position.distance_to(child.global_position)
			if d <= closest_dist:
				closest_dist = d
				closest      = child as Enemy
	return closest
