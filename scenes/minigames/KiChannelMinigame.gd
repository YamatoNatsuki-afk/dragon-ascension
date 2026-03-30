# res://scenes/minigames/KiChannelMinigame.gd
#
# Minijuego: CANALIZACIÓN DE KI — para Ki / Poder Ki
#
# Una barra vertical sube mientras mantenés SPACE/click.
# La zona dorada fluctúa. Hay que mantener la barra DENTRO de la zona.
# Si excedés el tope → "Explosión" (penalización).
# Tiempo dentro de la zona acumula puntos. 5 rondas de 3 segundos cada una.

class_name KiChannelMinigame
extends Control

signal completed(multiplier: float)

const ROUNDS:        int   = 5
const ROUND_TIME:    float = 3.5
const FILL_SPEED:    float = 0.55   # fracción por segundo (subida)
const DRAIN_SPEED:   float = 0.35   # fracción por segundo (bajada al soltar)
const ZONE_SIZE:     float = 0.22   # tamaño de la zona dorada (fracción)
const ZONE_SPEED:    float = 0.18   # velocidad de movimiento de la zona

const C_BG        := Color(0.05, 0.05, 0.07, 0.93)
const C_PANEL     := Color(0.12, 0.12, 0.16)
const C_ACCENT    := Color(1.00, 0.78, 0.10)
const C_KI        := Color(0.30, 0.60, 1.00)
const C_ZONE      := Color(0.20, 1.00, 0.50)
const C_OVERFLOW  := Color(0.95, 0.25, 0.20)
const C_TEXT      := Color(0.92, 0.90, 0.86)
const C_MUTED     := Color(0.50, 0.49, 0.47)

var _fill:      float = 0.2   # nivel actual 0.0–1.0
var _zone_y:    float = 0.5   # centro de zona dorada 0.0–1.0
var _zone_dir:  float = 1.0
var _holding:   bool  = false
var _overflow:  bool  = false

var _round:     int   = 0
var _timer:     float = 0.0
var _score:     float = 0.0
var _round_score: float = 0.0
var _active:    bool  = false

var _bar_node:  Control
var _score_lbl: Label
var _round_lbl: Label
var _timer_lbl: Label
var _status_lbl: Label
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

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(320, 0)
	var sb := StyleBoxFlat.new()
	sb.bg_color = C_PANEL
	sb.corner_radius_top_left = 8; sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8; sb.corner_radius_bottom_right = 8
	sb.border_width_top = 2; sb.border_color = C_KI.lerp(C_PANEL, 0.4)
	card.add_theme_stylebox_override("panel", sb)
	center.add_child(card)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	card.add_child(vbox)

	vbox.add_child(_spacer_v(20))

	var title := Label.new()
	title.text = "CANALIZACIÓN DE KI"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", C_KI)
	title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title)

	vbox.add_child(_spacer_v(4))

	var sub := Label.new()
	sub.text = _action_name
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_color_override("font_color", C_MUTED)
	sub.add_theme_font_size_override("font_size", 12)
	vbox.add_child(sub)

	vbox.add_child(_spacer_v(16))

	# Fila: ronda + timer + score
	var info_row := HBoxContainer.new()
	info_row.add_theme_constant_override("separation", 0)
	info_row.add_child(_spacer_h(20))
	_round_lbl = Label.new()
	_round_lbl.text = "1/%d" % ROUNDS
	_round_lbl.add_theme_color_override("font_color", C_MUTED)
	_round_lbl.add_theme_font_size_override("font_size", 12)
	_round_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_row.add_child(_round_lbl)
	_timer_lbl = Label.new()
	_timer_lbl.text = "%.1f" % ROUND_TIME
	_timer_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_timer_lbl.add_theme_color_override("font_color", C_ACCENT)
	_timer_lbl.add_theme_font_size_override("font_size", 18)
	_timer_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_row.add_child(_timer_lbl)
	_score_lbl = Label.new()
	_score_lbl.text = "0%"
	_score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_score_lbl.add_theme_color_override("font_color", C_ZONE)
	_score_lbl.add_theme_font_size_override("font_size", 12)
	_score_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_row.add_child(_score_lbl)
	info_row.add_child(_spacer_h(20))
	vbox.add_child(info_row)

	vbox.add_child(_spacer_v(14))

	# Barra de Ki
	var bar_row := HBoxContainer.new()
	bar_row.add_theme_constant_override("separation", 0)
	bar_row.add_child(_spacer_h(80))
	_bar_node = Control.new()
	_bar_node.custom_minimum_size = Vector2(80, 240)
	_bar_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_bar_node.draw.connect(_draw_bar)
	bar_row.add_child(_bar_node)
	bar_row.add_child(_spacer_h(80))
	vbox.add_child(bar_row)

	vbox.add_child(_spacer_v(14))

	# Status
	_status_lbl = Label.new()
	_status_lbl.text = "Mantén presionado"
	_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_lbl.add_theme_color_override("font_color", C_KI)
	_status_lbl.add_theme_font_size_override("font_size", 15)
	vbox.add_child(_status_lbl)

	vbox.add_child(_spacer_v(10))

	_hint_lbl = Label.new()
	_hint_lbl.text = "[ SPACE ] o mantén [ CLICK ]"
	_hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_lbl.add_theme_color_override("font_color", C_MUTED)
	_hint_lbl.add_theme_font_size_override("font_size", 11)
	vbox.add_child(_hint_lbl)

	vbox.add_child(_spacer_v(20))

# ─────────────────────────────────────────────────────────────────────────────
# Loop
# ─────────────────────────────────────────────────────────────────────────────

func _start_round() -> void:
	_fill        = 0.15
	_zone_y      = randf_range(0.3, 0.7)
	_zone_dir    = 1.0 if randf() > 0.5 else -1.0
	_timer       = ROUND_TIME
	_round_score = 0.0
	_overflow    = false
	_active      = true
	_round_lbl.text = "%d/%d" % [_round + 1, ROUNDS]

func _process(delta: float) -> void:
	if not _active:
		return

	# Mover zona
	_zone_y += _zone_dir * ZONE_SPEED * delta
	if _zone_y >= 0.85 - ZONE_SIZE * 0.5:
		_zone_y = 0.85 - ZONE_SIZE * 0.5; _zone_dir = -1.0
	if _zone_y <= 0.15 + ZONE_SIZE * 0.5:
		_zone_y = 0.15 + ZONE_SIZE * 0.5; _zone_dir = 1.0

	# Fill
	if _holding:
		_fill += FILL_SPEED * delta
	else:
		_fill -= DRAIN_SPEED * delta
	_fill = clampf(_fill, 0.0, 1.0)

	# Overflow
	if _fill >= 0.98:
		_overflow = true
		_fill     = 0.0
		_holding  = false
		_status_lbl.text = "¡EXPLOSIÓN!"
		_status_lbl.add_theme_color_override("font_color", Color(1, 0.3, 0.2))

	# Dentro de zona → acumular puntos
	var zone_min := _zone_y - ZONE_SIZE * 0.5
	var zone_max := _zone_y + ZONE_SIZE * 0.5
	if _fill >= zone_min and _fill <= zone_max and not _overflow:
		_round_score += delta / ROUND_TIME
		_status_lbl.text = "✦ EN ZONA"
		_status_lbl.add_theme_color_override("font_color", C_ZONE)
	elif not _overflow:
		if _holding:
			_status_lbl.text = "Subiendo..."
		else:
			_status_lbl.text = "Mantén presionado"
		_status_lbl.add_theme_color_override("font_color", C_KI)

	# Timer
	_timer -= delta
	_timer_lbl.text = "%.1f" % maxf(_timer, 0.0)
	_score_lbl.text = "%d%%" % int(_round_score * 100.0)

	if _overflow:
		_overflow = false   # reset para siguiente intento en la ronda

	_bar_node.queue_redraw()

	if _timer <= 0.0:
		_active = false
		_score += _round_score
		_round += 1
		if _round >= ROUNDS:
			_finish()
		else:
			_timer_lbl.text = "—"
			await get_tree().create_timer(0.4).timeout
			_start_round()

func _finish() -> void:
	_hint_lbl.text = ""
	var pct: float = clampf(_score / float(ROUNDS), 0.0, 1.0)
	var mult       := lerpf(0.5, 2.0, pct)
	_status_lbl.text = "Sincronía: %d%%" % int(pct * 100.0)
	_status_lbl.add_theme_color_override("font_color", C_ACCENT)
	await get_tree().create_timer(1.0).timeout
	completed.emit(mult)

# ─────────────────────────────────────────────────────────────────────────────
# Dibujo de barra
# ─────────────────────────────────────────────────────────────────────────────

func _draw_bar() -> void:
	var w := _bar_node.size.x
	var h := _bar_node.size.y

	# Fondo
	_bar_node.draw_rect(Rect2(0, 0, w, h), Color(0.15, 0.15, 0.20), true)

	# Zona dorada
	var zone_min := _zone_y - ZONE_SIZE * 0.5
	var zone_max := _zone_y + ZONE_SIZE * 0.5
	_bar_node.draw_rect(
		Rect2(0, (1.0 - zone_max) * h, w, ZONE_SIZE * h),
		Color(C_ZONE.r, C_ZONE.g, C_ZONE.b, 0.22), true
	)
	# Bordes de zona
	_bar_node.draw_line(
		Vector2(0, (1.0 - zone_max) * h),
		Vector2(w, (1.0 - zone_max) * h),
		Color(C_ZONE.r, C_ZONE.g, C_ZONE.b, 0.7), 2.0
	)
	_bar_node.draw_line(
		Vector2(0, (1.0 - zone_min) * h),
		Vector2(w, (1.0 - zone_min) * h),
		Color(C_ZONE.r, C_ZONE.g, C_ZONE.b, 0.7), 2.0
	)

	# Fill de ki
	var fill_h := _fill * h
	var in_zone := _fill >= zone_min and _fill <= zone_max
	var fill_col := C_ZONE if in_zone else C_KI
	_bar_node.draw_rect(Rect2(0, h - fill_h, w, fill_h), fill_col, true)

	# Línea de nivel actual
	_bar_node.draw_line(
		Vector2(0, h - fill_h),
		Vector2(w, h - fill_h),
		Color(1, 1, 1, 0.8), 2.0
	)

# ─────────────────────────────────────────────────────────────────────────────
# Input
# ─────────────────────────────────────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_SPACE:
		_holding = event.pressed
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			_holding = mb.pressed

# ─────────────────────────────────────────────────────────────────────────────

func _spacer_h(w: int) -> Control:
	var s := Control.new(); s.custom_minimum_size.x = w; return s
func _spacer_v(h: int) -> Control:
	var s := Control.new(); s.custom_minimum_size.y = h; return s
