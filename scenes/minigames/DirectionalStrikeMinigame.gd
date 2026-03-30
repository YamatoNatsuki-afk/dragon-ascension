# res://scenes/minigames/DirectionalStrikeMinigame.gd
# GOLPE DIRECCIONAL — Fuerza / Resistencia
# FIX: DIR_DATA indices corregidos en _draw_game (índice 3 = Vector2, índice 2 = Color)

class_name DirectionalStrikeMinigame
extends Control

signal completed(multiplier: float)

const MAX_LIVES:      int   = 3
const BASE_SPEED:     float = 280.0
const SPEED_GAIN:     float = 8.0
const HIT_ZONE_R:     float = 52.0
const PERFECT_R:      float = 22.0
const MAX_STREAK_MULT:int   = 5
const SPAWN_INTERVAL: float = 0.85

const C_BG       := Color(0.05, 0.05, 0.07, 0.95)
const C_CENTER   := Color(0.18, 0.18, 0.24)
const C_HIT_ZONE := Color(0.28, 0.85, 0.44, 0.30)
const C_ACCENT   := Color(1.00, 0.78, 0.10)
const C_MUTED    := Color(0.50, 0.49, 0.47)
const C_MISS     := Color(0.90, 0.28, 0.22)
const C_HIT      := Color(0.28, 0.85, 0.44)

# [label, keys, color, vector]
const DIR_DATA: Array = [
	["▲  W", [KEY_W, KEY_UP],    Color(0.30, 0.80, 1.00), Vector2(0, -1)],
	["▶  D", [KEY_D, KEY_RIGHT], Color(1.00, 0.55, 0.10), Vector2(1,  0)],
	["▼  S", [KEY_S, KEY_DOWN],  Color(0.85, 0.28, 0.85), Vector2(0,  1)],
	["◀  A", [KEY_A, KEY_LEFT],  Color(0.30, 0.85, 0.44), Vector2(-1, 0)],
]

var _lives:        int   = MAX_LIVES
var _score:        int   = 0
var _streak:       int   = 0
var _max_streak:   int   = 0
var _speed:        float = BASE_SPEED
var _spawn_t:      float = 0.5
var _active:       bool  = false
var _game_over:    bool  = false

var _proj_dir:    int   = -1
var _proj_pos:    float = 0.0
var _proj_active: bool  = false
var _proj_hit:    bool  = false
var _proj_flash:  float = 0.0

var _feedback_text: String = ""
var _feedback_col:  Color  = C_HIT
var _feedback_t:    float  = 0.0

var _canvas:    Control
var _score_lbl: Label
var _streak_lbl:Label
var _lives_lbl: Label
var _mult_lbl:  Label
var _exit_btn:  Button

var _action_name:  String = ""
var _target_stats: Array[StringName] = []

func setup(action_name: String, target_stats: Array[StringName], _mode: String = "") -> void:
	_action_name  = action_name
	_target_stats = target_stats

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	await get_tree().process_frame
	_active = true

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = C_BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	_canvas = Control.new()
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.draw.connect(_draw_game)
	add_child(_canvas)

	var hud := HBoxContainer.new()
	hud.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hud.custom_minimum_size.y = 52
	hud.add_theme_constant_override("separation", 0)
	add_child(hud)

	hud.add_child(_sp(20))
	_lives_lbl = _lbl("♥ ♥ ♥", Color(0.90, 0.28, 0.22), 18)
	hud.add_child(_lives_lbl)
	hud.add_child(_sp(0, true))
	hud.add_child(_lbl("GOLPE DIRECCIONAL", C_ACCENT, 16))
	hud.add_child(_sp(0, true))
	_score_lbl = _lbl("0", C_ACCENT, 18)
	hud.add_child(_score_lbl)
	hud.add_child(_sp(20))

	var sb := VBoxContainer.new()
	sb.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	sb.add_theme_constant_override("separation", 2)
	sb.position.y -= 90
	add_child(sb)

	_mult_lbl = Label.new()
	_mult_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mult_lbl.add_theme_font_size_override("font_size", 26)
	_mult_lbl.add_theme_color_override("font_color", C_ACCENT)
	sb.add_child(_mult_lbl)

	_streak_lbl = Label.new()
	_streak_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_streak_lbl.add_theme_font_size_override("font_size", 12)
	_streak_lbl.add_theme_color_override("font_color", C_MUTED)
	sb.add_child(_streak_lbl)

	_exit_btn = Button.new()
	_exit_btn.text = "Terminar"
	_exit_btn.custom_minimum_size = Vector2(120, 36)
	_exit_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_exit_btn.position -= Vector2(140, 50)
	_exit_btn.add_theme_color_override("font_color", C_MUTED)
	_exit_btn.pressed.connect(_on_exit_pressed)
	add_child(_exit_btn)
	_refresh_hud()

func _lbl(text: String, color: Color, sz: int) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override("font_color", color)
	l.add_theme_font_size_override("font_size", sz)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.custom_minimum_size.y = 52
	return l

func _sp(w: int, expand: bool = false) -> Control:
	var s := Control.new()
	if expand: s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	else: s.custom_minimum_size.x = w
	return s

func _process(delta: float) -> void:
	if not _active or _game_over:
		return
	if _feedback_t > 0.0: _feedback_t -= delta
	if _proj_flash > 0.0: _proj_flash -= delta
	if not _proj_active:
		_spawn_t -= delta
		if _spawn_t <= 0.0:
			_spawn_projectile()
	if _proj_active and not _proj_hit:
		var travel_time := 1.0 / (_speed / _arena_radius())
		_proj_pos += delta / travel_time
		if _proj_pos >= 1.2:
			_register_miss()
	_canvas.queue_redraw()
	_refresh_hud()

func _arena_radius() -> float:
	return minf(size.x, size.y) * 0.38

func _spawn_projectile() -> void:
	_proj_dir    = randi() % 4
	_proj_pos    = 0.0
	_proj_active = true
	_proj_hit    = false
	_spawn_t     = SPAWN_INTERVAL * maxf(0.6, 1.0 - _streak * 0.02)

func _try_hit(dir_index: int) -> void:
	if not _proj_active or _proj_hit:
		return
	if dir_index != _proj_dir:
		_register_miss()
		return
	var dist       := absf(_proj_pos - 1.0)
	var is_perfect := dist <= (PERFECT_R / _arena_radius())
	var in_zone    := dist <= (HIT_ZONE_R / _arena_radius())
	if not in_zone and _proj_pos < 0.7:
		return
	if not in_zone:
		_register_miss()
		return
	_proj_hit   = true
	_proj_flash = 0.15
	_streak    += 1
	_max_streak = maxi(_max_streak, _streak)
	_speed     += SPEED_GAIN
	var mult: int = _streak_multiplier()
	_score += (3 if is_perfect else 1) * mult
	if is_perfect:
		_show_feedback("★ PERFECTO  ×%d" % mult, C_ACCENT)
	elif _streak >= 5:
		_show_feedback("RACHA ×%d!" % mult, Color(1.0, 0.6, 0.1))
	else:
		_show_feedback("¡GOLPE!", C_HIT)
	await get_tree().create_timer(0.10).timeout
	_proj_active = false

func _register_miss() -> void:
	_proj_active = false
	_proj_hit    = false
	_lives      -= 1
	_streak      = 0
	_show_feedback("FALLO", C_MISS)
	if _lives <= 0:
		_finish()

func _streak_multiplier() -> int:
	return int(pow(2, mini(_streak - 1, MAX_STREAK_MULT))) if _streak > 0 else 1

func _show_feedback(text: String, color: Color) -> void:
	_feedback_text = text
	_feedback_col  = color
	_feedback_t    = 0.6

func _refresh_hud() -> void:
	_lives_lbl.text = ("♥ ".repeat(_lives) + "♡ ".repeat(MAX_LIVES - _lives)).strip_edges()
	_score_lbl.text = str(_score)
	var mult: int = _streak_multiplier()
	_mult_lbl.text   = "×%d" % mult if _streak >= 2 else ""
	_streak_lbl.text = "racha: %d" % _streak if _streak >= 2 else ""
	if _streak >= 2:
		_mult_lbl.add_theme_color_override("font_color",
			C_ACCENT if _streak < 5 else Color(1.0, 0.5, 0.1))

func _finish() -> void:
	_game_over = true
	_active    = false
	_exit_btn.visible = false
	var pct: float = clampf(float(_score) / 200.0, 0.0, 1.0)
	pct = clampf(pct * (1.0 + float(_max_streak) * 0.05), 0.0, 1.0)
	_show_feedback("Score: %d  |  Racha máx: %d" % [_score, _max_streak], C_ACCENT)
	_canvas.queue_redraw()
	await get_tree().create_timer(1.5).timeout
	completed.emit(lerpf(0.5, 2.0, pct))

func _on_exit_pressed() -> void:
	if not _game_over:
		_finish()

func _unhandled_input(event: InputEvent) -> void:
	if not _active or _game_over:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key := (event as InputEventKey).keycode
		for i in DIR_DATA.size():
			if key in DIR_DATA[i][1]:
				_try_hit(i)
				return

func _draw_game() -> void:
	var cx := _canvas.size.x * 0.5
	var cy := _canvas.size.y * 0.5
	var center := Vector2(cx, cy)
	var R      := _arena_radius()

	_canvas.draw_arc(center, HIT_ZONE_R, 0, TAU, 48, C_HIT_ZONE, 18.0, true)
	_canvas.draw_arc(center, PERFECT_R,  0, TAU, 32,
		Color(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 0.25), 10.0, true)
	_canvas.draw_circle(center, 24, C_CENTER)

	# Guías — FIX: índice 3 = Vector2, índice 2 = Color
	for i in 4:
		var dir_vec: Vector2 = DIR_DATA[i][3]
		var end_pt := center + dir_vec * R
		_canvas.draw_line(center, end_pt, Color(0.25, 0.25, 0.30, 0.5), 2.0)
		_canvas.draw_string(ThemeDB.fallback_font,
			center + dir_vec * (R + 24) - Vector2(20, 8),
			DIR_DATA[i][0], HORIZONTAL_ALIGNMENT_CENTER, -1, 14,
			Color(0.45, 0.45, 0.50))

	if _proj_active:
		var dir_vec: Vector2 = DIR_DATA[_proj_dir][3]
		var col: Color       = DIR_DATA[_proj_dir][2]
		var proj_pt := center + dir_vec * (R * (1.0 - _proj_pos))
		var trail_len := minf(_proj_pos, 0.25)
		for t in 5:
			var alpha: float = float(t) / 5.0 * 0.5
			_canvas.draw_circle(
				proj_pt + dir_vec * (R * trail_len * (1.0 - float(t) / 5.0)),
				8.0 + t * 2.0, Color(col.r, col.g, col.b, alpha))
		var proj_r: float = 30.0 if (_proj_hit and _proj_flash > 0) else 18.0
		if _proj_hit and _proj_flash > 0:
			_canvas.draw_circle(proj_pt, proj_r + 8, Color(col.r, col.g, col.b, 0.4))
		_canvas.draw_circle(proj_pt, proj_r, col)
		_canvas.draw_string(ThemeDB.fallback_font,
			proj_pt - Vector2(10, 8), DIR_DATA[_proj_dir][0].substr(0, 1),
			HORIZONTAL_ALIGNMENT_CENTER, -1, 18, Color.WHITE)

	if _feedback_t > 0.0:
		var alpha: float = clampf(_feedback_t / 0.4, 0.0, 1.0)
		_canvas.draw_string(ThemeDB.fallback_font,
			center - Vector2(80, 60), _feedback_text,
			HORIZONTAL_ALIGNMENT_CENTER, 160, 22,
			Color(_feedback_col.r, _feedback_col.g, _feedback_col.b, alpha))
