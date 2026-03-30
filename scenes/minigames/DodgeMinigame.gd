# res://scenes/minigames/DodgeMinigame.gd
#
# Minijuego: REFLEJOS DE COMBATE — para Velocidad
#
# Personaje en la parte baja. Objetos caen desde arriba.
# A/D o flechas para moverse. Atrapá estrellas ⭐, esquivá bombas 💣.
# 5 rondas de 8 segundos.

class_name DodgeMinigame
extends Control

signal completed(multiplier: float)

const ROUNDS:         int   = 5
const ROUND_TIME:     float = 7.0
const PLAYER_SPEED:   float = 380.0
const FALL_SPEED:     float = 180.0
const SPAWN_INTERVAL: float = 0.7
const PLAYER_SIZE:    float = 28.0
const OBJ_SIZE:       float = 26.0

const C_BG      := Color(0.05, 0.05, 0.07, 0.93)
const C_PANEL   := Color(0.12, 0.12, 0.16)
const C_ACCENT  := Color(1.00, 0.78, 0.10)
const C_PLAYER  := Color(0.30, 0.60, 1.00)
const C_STAR    := Color(1.00, 0.90, 0.10)
const C_BOMB    := Color(0.95, 0.25, 0.20)
const C_MUTED   := Color(0.50, 0.49, 0.47)
const C_TEXT    := Color(0.92, 0.90, 0.86)

var _px:        float = 0.5    # posición X del jugador (0–1)
var _objects:   Array = []
var _spawn_t:   float = 0.0
var _round_t:   float = 0.0
var _round:     int   = 0
var _score:     int   = 0
var _active:    bool  = false
var _move_left: bool  = false
var _move_right:bool  = false

var _canvas:    Control
var _score_lbl: Label
var _timer_lbl: Label
var _round_lbl: Label
var _status_lbl:Label
var _hint_lbl:  Label

var _action_name:  String = ""
var _target_stats: Array[StringName] = []

# ─────────────────────────────────────────────────────────────────────────────

func setup(action_name: String, target_stats: Array[StringName]) -> void:
	_action_name  = action_name
	_target_stats = target_stats

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	await get_tree().process_frame
	_start_round()

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
	_canvas.draw.connect(_draw_game)
	add_child(_canvas)

	var hud := HBoxContainer.new()
	hud.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hud.custom_minimum_size.y = 48
	hud.add_theme_constant_override("separation", 0)
	add_child(hud)

	hud.add_child(_spacer_h(20))
	_round_lbl = _hud_label("RONDA 1/%d" % ROUNDS, C_MUTED, 13)
	hud.add_child(_round_lbl)
	hud.add_child(_spacer_expand())
	var title := _hud_label("REFLEJOS DE COMBATE", C_ACCENT, 16)
	hud.add_child(title)
	hud.add_child(_spacer_expand())
	_timer_lbl = _hud_label("%.1f" % ROUND_TIME, C_ACCENT, 18)
	hud.add_child(_timer_lbl)
	hud.add_child(_spacer_h(16))
	_score_lbl = _hud_label("0 pts", C_STAR, 14)
	hud.add_child(_score_lbl)
	hud.add_child(_spacer_h(20))

	_status_lbl = Label.new()
	_status_lbl.set_anchors_preset(Control.PRESET_CENTER)
	_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_lbl.add_theme_font_size_override("font_size", 28)
	_status_lbl.add_theme_color_override("font_color", C_STAR)
	_status_lbl.modulate.a = 0.0
	add_child(_status_lbl)

	_hint_lbl = Label.new()
	_hint_lbl.text = "[ A / D ] o [ ← / → ] para moverse"
	_hint_lbl.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_lbl.add_theme_color_override("font_color", C_MUTED)
	_hint_lbl.add_theme_font_size_override("font_size", 12)
	_hint_lbl.position.y -= 32
	add_child(_hint_lbl)

func _hud_label(text: String, color: Color, font_size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override("font_color", color)
	l.add_theme_font_size_override("font_size", font_size)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.custom_minimum_size.y = 48
	return l

# ─────────────────────────────────────────────────────────────────────────────
# Lógica
# ─────────────────────────────────────────────────────────────────────────────

func _start_round() -> void:
	_objects.clear()
	_round_t  = ROUND_TIME
	_spawn_t  = 0.3
	_active   = true
	_round_lbl.text = "RONDA %d/%d" % [_round + 1, ROUNDS]

func _process(delta: float) -> void:
	if not _active:
		return

	# Mover jugador
	var move := 0.0
	if _move_left:  move -= 1.0
	if _move_right: move += 1.0
	_px = clampf(_px + move * PLAYER_SPEED * delta / size.x, 0.04, 0.96)

	# Spawn
	_spawn_t -= delta
	if _spawn_t <= 0.0:
		_spawn_object()
		_spawn_t = SPAWN_INTERVAL * randf_range(0.75, 1.25)

	# Mover objetos + colisión
	var player_px := _px * size.x
	var player_y  := size.y * 0.82
	var to_remove: Array = []

	var speed := FALL_SPEED * (1.0 + _round * 0.10)
	for obj in _objects:
		obj.y += speed * delta
		if obj.y > size.y + 40:
			to_remove.append(obj)
			continue
		# Colisión con jugador
		if abs(obj.x - player_px) < (PLAYER_SIZE + OBJ_SIZE) * 0.5 \
		   and abs(obj.y - player_y) < (PLAYER_SIZE + OBJ_SIZE) * 0.5:
			to_remove.append(obj)
			match obj.type:
				"star":
					_score += 3
					_flash_status("★ +3", C_STAR)
				"bomb":
					_score = maxi(0, _score - 4)
					_flash_status("💣 -4", C_BOMB)

	for obj in to_remove:
		_objects.erase(obj)

	_score_lbl.text = "%d pts" % _score

	# Timer
	_round_t -= delta
	_timer_lbl.text = "%.1f" % maxf(_round_t, 0.0)
	_canvas.queue_redraw()

	if _round_t <= 0.0:
		_active = false
		_round += 1
		if _round >= ROUNDS:
			_finish()
		else:
			_timer_lbl.text = "—"
			await get_tree().create_timer(0.4).timeout
			_start_round()

func _spawn_object() -> void:
	var type := "bomb" if randf() < 0.30 else "star"
	_objects.append({
		"type": type,
		"x":    randf_range(30.0, size.x - 30.0),
		"y":    -20.0,
	})

func _flash_status(text: String, color: Color) -> void:
	_status_lbl.text = text
	_status_lbl.add_theme_color_override("font_color", color)
	_status_lbl.modulate.a = 1.0
	var t := create_tween()
	t.tween_property(_status_lbl, "modulate:a", 0.0, 0.4).set_delay(0.2)

func _finish() -> void:
	_hint_lbl.text = ""
	var max_pts := ROUNDS * int(ROUND_TIME / SPAWN_INTERVAL) * 3
	var pct: float = clampf(float(_score) / float(max(max_pts, 1)), 0.0, 1.0)
	var mult       := lerpf(0.5, 2.0, pct)
	_flash_status("Score: %d%%" % int(pct * 100.0), Color(1, 0.78, 0.10))
	await get_tree().create_timer(1.2).timeout
	completed.emit(mult)

# ─────────────────────────────────────────────────────────────────────────────
# Dibujo
# ─────────────────────────────────────────────────────────────────────────────

func _draw_game() -> void:
	var w := _canvas.size.x
	var h := _canvas.size.y
	var player_x := _px * w
	var player_y := h * 0.82

	# Jugador
	_canvas.draw_circle(Vector2(player_x, player_y), PLAYER_SIZE * 0.5, C_PLAYER)
	_canvas.draw_string(
		ThemeDB.fallback_font,
		Vector2(player_x - 12, player_y + 10),
		"🥋", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE
	)

	# Objetos
	for obj in _objects:
		var icon := "⭐" if obj.type == "star" else "💣"
		var col  := C_STAR if obj.type == "star" else C_BOMB
		_canvas.draw_string(
			ThemeDB.fallback_font,
			Vector2(obj.x - 13, obj.y + 12),
			icon, HORIZONTAL_ALIGNMENT_LEFT, -1, 26, col
		)

# ─────────────────────────────────────────────────────────────────────────────
# Input
# ─────────────────────────────────────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key := (event as InputEventKey).keycode
		var pressed := (event as InputEventKey).pressed
		match key:
			KEY_A, KEY_LEFT:  _move_left  = pressed
			KEY_D, KEY_RIGHT: _move_right = pressed

# ─────────────────────────────────────────────────────────────────────────────

func _spacer_h(w: int) -> Control:
	var s := Control.new(); s.custom_minimum_size.x = w; return s
func _spacer_expand() -> Control:
	var s := Control.new(); s.size_flags_horizontal = Control.SIZE_EXPAND_FILL; return s
