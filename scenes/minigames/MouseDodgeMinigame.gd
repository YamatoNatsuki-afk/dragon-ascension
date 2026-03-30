# res://scenes/minigames/MouseDodgeMinigame.gd
#
# ESQUIVA CON RATÓN — Velocidad
#
# El jugador es un orbe que sigue al mouse.
# Proyectiles vienen de los bordes con velocidad creciente.
# RACHA: cada segundo sobrevivido suma streak. Multiplicador ×1 → ×2 → ×4...
# VIDAS: 3. Al acabarse, termina.
# Botón salir siempre visible.

class_name MouseDodgeMinigame
extends Control

signal completed(multiplier: float)

const MAX_LIVES:       int   = 3
const BASE_PROJ_SPEED: float = 180.0
const SPEED_GAIN_RATE: float = 12.0   # px/s ganados por segundo
const PLAYER_R:        float = 14.0
const PROJ_R:          float = 11.0
const SPAWN_RATE:      float = 1.2    # proyectiles por segundo (base)
const SPAWN_RATE_MAX:  float = 4.0    # máximo proyectiles por segundo

const C_BG      := Color(0.05, 0.05, 0.07, 0.95)
const C_PLAYER  := Color(0.30, 0.70, 1.00)
const C_ACCENT  := Color(1.00, 0.78, 0.10)
const C_TEXT    := Color(0.92, 0.90, 0.86)
const C_MUTED   := Color(0.50, 0.49, 0.47)
const C_MISS    := Color(0.90, 0.28, 0.22)
const C_TRAIL   := Color(0.30, 0.70, 1.00)

var _lives:        int   = MAX_LIVES
var _score:        float = 0.0    # segundos sobrevividos × multiplicador
var _streak_time:  float = 0.0    # tiempo desde último hit recibido
var _total_time:   float = 0.0
var _speed:        float = BASE_PROJ_SPEED
var _spawn_t:      float = 0.5
var _active:       bool  = false
var _game_over:    bool  = false
var _invincible:   float = 0.0    # frames de invencibilidad post-hit

var _player_pos:   Vector2 = Vector2.ZERO
var _player_trail: Array   = []   # Array[Vector2]

# Proyectiles: Array[Dictionary] {pos, vel, col}
var _projectiles:  Array = []

var _feedback_text: String = ""
var _feedback_col:  Color  = C_ACCENT
var _feedback_t:    float  = 0.0
var _hit_flash:     float  = 0.0

var _canvas:       Control
var _score_lbl:    Label
var _lives_lbl:    Label
var _mult_lbl:     Label
var _time_lbl:     Label
var _exit_btn:     Button

var _action_name:  String = ""
var _target_stats: Array[StringName] = []

# ─────────────────────────────────────────────────────────────────────────────

func setup(action_name: String, target_stats: Array[StringName]) -> void:
	_action_name  = action_name
	_target_stats = target_stats

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()
	await get_tree().process_frame
	_player_pos = size * 0.5
	_active = true

# ─────────────────────────────────────────────────────────────────────────────
# UI
# ─────────────────────────────────────────────────────────────────────────────

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = C_BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	_canvas = Control.new()
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.draw.connect(_draw_game)
	add_child(_canvas)

	var hud := HBoxContainer.new()
	hud.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hud.custom_minimum_size.y = 52
	hud.add_theme_constant_override("separation", 0)
	add_child(hud)

	hud.add_child(_spacer(20))
	_lives_lbl = _hud_lbl("♥ ♥ ♥", C_MISS, 18)
	hud.add_child(_lives_lbl)
	hud.add_child(_spacer(0, true))
	hud.add_child(_hud_lbl("ESQUIVA", C_ACCENT, 16))
	hud.add_child(_spacer(0, true))
	_time_lbl = _hud_lbl("0.0s", C_TEXT, 14)
	hud.add_child(_time_lbl)
	hud.add_child(_spacer(16))
	_score_lbl = _hud_lbl("0", C_ACCENT, 18)
	hud.add_child(_score_lbl)
	hud.add_child(_spacer(20))

	# Multiplicador
	_mult_lbl = Label.new()
	_mult_lbl.set_anchors_preset(Control.PRESET_CENTER)
	_mult_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mult_lbl.position.y = -size.y * 0.3
	_mult_lbl.add_theme_font_size_override("font_size", 22)
	_mult_lbl.add_theme_color_override("font_color", C_ACCENT)
	add_child(_mult_lbl)

	_exit_btn = Button.new()
	_exit_btn.text = "Terminar"
	_exit_btn.custom_minimum_size = Vector2(120, 36)
	_exit_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_exit_btn.position -= Vector2(140, 50)
	_exit_btn.add_theme_font_size_override("font_size", 13)
	_exit_btn.add_theme_color_override("font_color", C_MUTED)
	_exit_btn.pressed.connect(_on_exit_pressed)
	add_child(_exit_btn)

func _hud_lbl(text: String, color: Color, font_size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override("font_color", color)
	l.add_theme_font_size_override("font_size", font_size)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.custom_minimum_size.y = 52
	return l

func _spacer(w: int, expand: bool = false) -> Control:
	var s := Control.new()
	if expand: s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	else: s.custom_minimum_size.x = w
	return s

# ─────────────────────────────────────────────────────────────────────────────
# Loop
# ─────────────────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	if not _active or _game_over:
		return

	_total_time   += delta
	_streak_time  += delta
	_feedback_t    = maxf(0.0, _feedback_t - delta)
	_hit_flash     = maxf(0.0, _hit_flash - delta)
	_invincible    = maxf(0.0, _invincible - delta)

	# Player sigue el mouse
	_player_pos = get_local_mouse_position()
	_player_pos = _player_pos.clamp(
		Vector2(PLAYER_R, PLAYER_R + 52),
		Vector2(size.x - PLAYER_R, size.y - PLAYER_R)
	)

	# Trail
	_player_trail.append(_player_pos)
	if _player_trail.size() > 8:
		_player_trail.pop_front()

	# Score acumula con multiplicador
	var mult := _streak_multiplier()
	_score += delta * float(mult)

	# Acelerar con el tiempo
	_speed = BASE_PROJ_SPEED + _total_time * SPEED_GAIN_RATE

	# Spawn de proyectiles
	_spawn_t -= delta
	if _spawn_t <= 0.0:
		_spawn_projectile()
		var rate := clampf(SPAWN_RATE + _total_time * 0.06, SPAWN_RATE, SPAWN_RATE_MAX)
		_spawn_t = 1.0 / rate * randf_range(0.7, 1.3)

	# Mover proyectiles + colisión
	var to_remove: Array = []
	for proj in _projectiles:
		proj.pos += proj.vel * delta
		# Fuera de pantalla
		if proj.pos.x < -40 or proj.pos.x > size.x + 40 \
		or proj.pos.y < -40 or proj.pos.y > size.y + 40:
			to_remove.append(proj)
			continue
		# Colisión con jugador
		if _invincible <= 0.0:
			if proj.pos.distance_to(_player_pos) < PLAYER_R + PROJ_R:
				to_remove.append(proj)
				_register_hit()

	for proj in to_remove:
		_projectiles.erase(proj)

	_refresh_hud()
	_canvas.queue_redraw()

func _spawn_projectile() -> void:
	# Spawn en borde aleatorio
	var w := size.x; var h := size.y
	var side := randi() % 4
	var pos: Vector2
	var target := _player_pos + Vector2(
		randf_range(-60, 60), randf_range(-60, 60)
	)
	match side:
		0: pos = Vector2(randf_range(0, w), -20)
		1: pos = Vector2(w + 20, randf_range(0, h))
		2: pos = Vector2(randf_range(0, w), h + 20)
		3: pos = Vector2(-20, randf_range(0, h))

	var direction := (target - pos).normalized()
	var speed_var := _speed * randf_range(0.85, 1.15)

	# Color según velocidad
	var speed_ratio := clampf((_speed - BASE_PROJ_SPEED) / 300.0, 0.0, 1.0)
	var col := Color(0.95, 0.25, 0.20).lerp(Color(1.0, 0.55, 0.05), speed_ratio)

	_projectiles.append({
		"pos": pos,
		"vel": direction * speed_var,
		"col": col,
		"trail": [],
	})

func _register_hit() -> void:
	_lives       -= 1
	_streak_time  = 0.0
	_invincible   = 0.8
	_hit_flash    = 0.4
	_show_feedback("¡IMPACTO!", C_MISS)

	if _lives <= 0:
		_finish()

func _streak_multiplier() -> int:
	if _streak_time < 3.0:   return 1
	if _streak_time < 8.0:   return 2
	if _streak_time < 16.0:  return 4
	if _streak_time < 30.0:  return 8
	return 16

func _show_feedback(text: String, color: Color) -> void:
	_feedback_text = text
	_feedback_col  = color
	_feedback_t    = 0.7

func _refresh_hud() -> void:
	var hearts := "♥ ".repeat(_lives) + "♡ ".repeat(MAX_LIVES - _lives)
	_lives_lbl.text = hearts.strip_edges()
	_score_lbl.text  = "%d" % int(_score)
	_time_lbl.text   = "%.1fs" % _total_time
	var mult := _streak_multiplier()
	_mult_lbl.text = "×%d" % mult if mult > 1 else ""

# ─────────────────────────────────────────────────────────────────────────────
# Fin
# ─────────────────────────────────────────────────────────────────────────────

func _finish() -> void:
	_game_over = true
	_active    = false
	_exit_btn.visible = false

	var max_ref: float = 60.0   # 60 segundos = score de referencia
	var pct: float = clampf(_total_time / max_ref, 0.0, 1.0)
	var result_mult := lerpf(0.5, 2.0, pct)

	_show_feedback("Tiempo: %.1fs" % _total_time, C_ACCENT)
	_canvas.queue_redraw()
	await get_tree().create_timer(1.5).timeout
	completed.emit(result_mult)

func _on_exit_pressed() -> void:
	if not _game_over:
		_finish()

# ─────────────────────────────────────────────────────────────────────────────
# Dibujo
# ─────────────────────────────────────────────────────────────────────────────

func _draw_game() -> void:
	# Trail del jugador
	for i in _player_trail.size():
		var alpha := float(i) / float(_player_trail.size()) * 0.4
		var r     := PLAYER_R * (float(i) / float(_player_trail.size())) * 0.7
		_canvas.draw_circle(_player_trail[i], r,
			Color(C_TRAIL.r, C_TRAIL.g, C_TRAIL.b, alpha))

	# Proyectiles
	for proj in _projectiles:
		_canvas.draw_circle(proj.pos, PROJ_R, proj.col)
		# Mini trail
		# (simplificado — solo el orbe)

	# Jugador
	var p_col := C_PLAYER
	if _invincible > 0.0:
		var flash := fmod(_invincible * 8.0, 1.0) > 0.5
		p_col = Color(1, 1, 1, 0.3) if flash else C_PLAYER
	if _hit_flash > 0.0:
		_canvas.draw_circle(_player_pos, PLAYER_R + 10,
			Color(C_MISS.r, C_MISS.g, C_MISS.b, _hit_flash * 0.6))
	_canvas.draw_circle(_player_pos, PLAYER_R, p_col)
	# Brillo central
	_canvas.draw_circle(_player_pos - Vector2(3, 3), PLAYER_R * 0.35,
		Color(1, 1, 1, 0.4))

	# Feedback
	if _feedback_t > 0.0:
		var alpha := clampf(_feedback_t / 0.5, 0.0, 1.0)
		_canvas.draw_string(
			ThemeDB.fallback_font,
			Vector2(size.x * 0.5 - 80, size.y * 0.4),
			_feedback_text,
			HORIZONTAL_ALIGNMENT_CENTER, 160, 24,
			Color(_feedback_col.r, _feedback_col.g, _feedback_col.b, alpha)
		)
