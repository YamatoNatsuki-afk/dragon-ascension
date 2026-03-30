# res://scenes/minigames/TrainingMinigame.gd
#
# Minijuego de entrenamiento — "Sincronización de Ki".
#
# MECÁNICA:
#   Dos barras verticales con cursores independientes.
#   Un único input (SPACE o click) frena ambos cursores al mismo tiempo.
#   El score es el promedio de las dos zonas tocadas.
#
#   Esto representa sincronizar el poder físico con el ki interno:
#   no basta con ser fuerte, hay que estar alineado.
#
#   Zonas (distancia al centro de la barra):
#     PERFECTO (±8%)   → ×2.0 (dorado)
#     BUENO    (±18%)  → ×1.5 (verde)
#     OK       (±28%)  → ×1.0 (amarillo)
#     FALLO            → ×0.5 (rojo)
#
#   La barra derecha siempre va más rápido que la izquierda (+20%).
#   En rondas posteriores ambas aceleran.
#
# SEÑAL:
#   completed(multiplier: float) → promedio ponderado de 3 rondas

class_name TrainingMinigame
extends Control

signal completed(multiplier: float)

# ── Constantes ────────────────────────────────────────────────────────────────
const ROUNDS:         int   = 3
const BASE_SPEED_L:   float = 0.7   # fracción de la altura por segundo (barra izq)
const BASE_SPEED_R:   float = 0.85  # barra derecha siempre más rápida
const BAR_WIDTH:      int   = 48
const ZONE_PERFECT:   float = 0.08
const ZONE_GOOD:      float = 0.18
const ZONE_OK:        float = 0.28
const CURSOR_HEIGHT:  int   = 10

# ── Paleta ────────────────────────────────────────────────────────────────────
const C_BG         := Color(0.05, 0.05, 0.07, 0.92)
const C_PANEL      := Color(0.12, 0.12, 0.16)
const C_PANEL_ALT  := Color(0.17, 0.17, 0.22)
const C_TRACK      := Color(0.20, 0.20, 0.26)
const C_PERFECT    := Color(0.20, 1.00, 0.50)
const C_GOOD       := Color(0.28, 0.85, 0.44)
const C_OK         := Color(1.00, 0.78, 0.10)
const C_MISS       := Color(0.90, 0.30, 0.28)
const C_CURSOR     := Color(1.00, 1.00, 1.00)
const C_TEXT       := Color(0.92, 0.90, 0.86)
const C_MUTED      := Color(0.50, 0.49, 0.47)
const C_ACCENT     := Color(1.00, 0.78, 0.10)

# ── Estado ────────────────────────────────────────────────────────────────────
var _round:           int   = 0
var _pos_l:           float = 0.2   # 0.0=arriba, 1.0=abajo
var _pos_r:           float = 0.7
var _dir_l:           float = 1.0
var _dir_r:           float = -1.0
var _speed_l:         float = BASE_SPEED_L
var _speed_r:         float = BASE_SPEED_R
var _waiting_input:   bool  = true
var _animating:       bool  = false
var _scores:          Array[float] = []

# ── Info del entrenamiento ────────────────────────────────────────────────────
var _action_name:     String = ""
var _target_stats:    Array[StringName] = []

# ── Nodos ─────────────────────────────────────────────────────────────────────
var _round_lbl:       Label
var _feedback_lbl:    Label
var _hint_lbl:        Label
var _bar_l:           Control
var _bar_r:           Control
var _dots:            Array[Label] = []
var _stat_lbl:        Label

# ─────────────────────────────────────────────────────────────────────────────

func setup(action_name: String, target_stats: Array[StringName]) -> void:
	_action_name  = action_name
	_target_stats = target_stats

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()

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
	card.custom_minimum_size = Vector2(360, 0)
	var card_sb := StyleBoxFlat.new()
	card_sb.bg_color                   = C_PANEL
	card_sb.corner_radius_top_left     = 8; card_sb.corner_radius_top_right    = 8
	card_sb.corner_radius_bottom_left  = 8; card_sb.corner_radius_bottom_right = 8
	card_sb.border_width_top           = 2
	card_sb.border_color               = C_GOOD.lerp(C_PANEL, 0.5)
	card.add_theme_stylebox_override("panel", card_sb)
	center.add_child(card)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	card.add_child(vbox)

	vbox.add_child(_spacer_v(24))

	# Título
	var title := Label.new()
	title.text                    = "ENTRENAMIENTO"
	title.horizontal_alignment    = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", C_GOOD)
	title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title)

	vbox.add_child(_spacer_v(4))

	# Nombre de la acción
	var action_lbl := Label.new()
	action_lbl.text                 = _action_name
	action_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	action_lbl.add_theme_color_override("font_color", C_TEXT)
	action_lbl.add_theme_font_size_override("font_size", 13)
	vbox.add_child(action_lbl)

	vbox.add_child(_spacer_v(4))

	# Stats objetivo
	_stat_lbl = Label.new()
	var stat_str := "  ·  ".join(_target_stats.map(func(s): return str(s)))
	_stat_lbl.text                 = stat_str
	_stat_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stat_lbl.add_theme_color_override("font_color", C_MUTED)
	_stat_lbl.add_theme_font_size_override("font_size", 11)
	vbox.add_child(_stat_lbl)

	vbox.add_child(_spacer_v(20))

	# Round label
	_round_lbl = Label.new()
	_round_lbl.text                 = "RONDA 1 / %d" % ROUNDS
	_round_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_round_lbl.add_theme_color_override("font_color", C_MUTED)
	_round_lbl.add_theme_font_size_override("font_size", 11)
	vbox.add_child(_round_lbl)

	vbox.add_child(_spacer_v(14))

	# ── Las dos barras ────────────────────────────────────────────────────────
	var bars_row := HBoxContainer.new()
	bars_row.alignment = BoxContainer.ALIGNMENT_CENTER
	bars_row.add_theme_constant_override("separation", 32)
	vbox.add_child(bars_row)

	_bar_l = _build_bar_node("KI FÍSICO",   false)
	_bar_r = _build_bar_node("KI INTERNO",  true)
	bars_row.add_child(_bar_l)
	bars_row.add_child(_bar_r)

	vbox.add_child(_spacer_v(16))

	# Feedback
	_feedback_lbl = Label.new()
	_feedback_lbl.text                 = ""
	_feedback_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_feedback_lbl.add_theme_font_size_override("font_size", 20)
	_feedback_lbl.add_theme_color_override("font_color", C_PERFECT)
	_feedback_lbl.custom_minimum_size.y = 30
	vbox.add_child(_feedback_lbl)

	vbox.add_child(_spacer_v(12))

	# Dots de progreso
	var dots_row := HBoxContainer.new()
	dots_row.alignment = BoxContainer.ALIGNMENT_CENTER
	dots_row.add_theme_constant_override("separation", 12)
	vbox.add_child(dots_row)

	for i in ROUNDS:
		var dot := Label.new()
		dot.text = "○"
		dot.add_theme_color_override("font_color", C_MUTED)
		dot.add_theme_font_size_override("font_size", 18)
		dots_row.add_child(dot)
		_dots.append(dot)

	vbox.add_child(_spacer_v(16))

	# Hint
	_hint_lbl = Label.new()
	_hint_lbl.text                 = "[ SPACE ] o [ CLICK ] para sincronizar"
	_hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_lbl.add_theme_color_override("font_color", C_MUTED)
	_hint_lbl.add_theme_font_size_override("font_size", 11)
	vbox.add_child(_hint_lbl)

	vbox.add_child(_spacer_v(24))

## Construye una barra vertical con su label.
func _build_bar_node(label_text: String, is_right: bool) -> VBoxContainer:
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	vb.alignment = BoxContainer.ALIGNMENT_CENTER

	var lbl := Label.new()
	lbl.text                 = label_text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_color_override("font_color", C_MUTED)
	lbl.add_theme_font_size_override("font_size", 9)
	vb.add_child(lbl)

	var bar := Control.new()
	bar.custom_minimum_size = Vector2(BAR_WIDTH, 180)
	if is_right:
		bar.draw.connect(_draw_bar_right)
	else:
		bar.draw.connect(_draw_bar_left)
	vb.add_child(bar)

	return vb

# ─────────────────────────────────────────────────────────────────────────────
# Loop
# ─────────────────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	if not _waiting_input or _animating:
		return

	# Mover cursores — rebotan en 0 y 1
	_pos_l = _move_cursor(_pos_l, _dir_l, _speed_l * delta)
	if _pos_l >= 1.0:
		_pos_l = 1.0; _dir_l = -1.0
	elif _pos_l <= 0.0:
		_pos_l = 0.0; _dir_l = 1.0

	_pos_r = _move_cursor(_pos_r, _dir_r, _speed_r * delta)
	if _pos_r >= 1.0:
		_pos_r = 1.0; _dir_r = -1.0
	elif _pos_r <= 0.0:
		_pos_r = 0.0; _dir_r = 1.0

	# Redibujar ambas barras
	var bar_l_ctrl := (_bar_l.get_child(1) as Control)
	var bar_r_ctrl := (_bar_r.get_child(1) as Control)
	bar_l_ctrl.queue_redraw()
	bar_r_ctrl.queue_redraw()

func _move_cursor(pos: float, dir: float, step: float) -> float:
	return pos + dir * step

func _unhandled_input(event: InputEvent) -> void:
	if not _waiting_input or _animating:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		_register_input()
	elif event is InputEventMouseButton and event.pressed:
		_register_input()

func _register_input() -> void:
	_waiting_input = false
	_animating     = true

	# Evaluar ambos cursores
	var score_l := _eval_cursor(_pos_l)
	var score_r := _eval_cursor(_pos_r)
	var score   := (score_l + score_r) * 0.5

	_scores.append(score)

	# Determinar feedback
	var label: String
	var color: Color
	if score >= 1.9:
		label = "¡SINCRONÍA PERFECTA!"; color = C_PERFECT
	elif score >= 1.4:
		label = "BUENA SINCRONÍA";      color = C_GOOD
	elif score >= 0.9:
		label = "SINCRONÍA OK";         color = C_OK
	else:
		label = "DESINCRONIZADO";       color = C_MISS

	# Actualizar dot
	var dot_symbols := ["○", "◑", "●", "◉", "★"]
	var si := clampi(int((score - 0.25) / 0.4), 0, 4)
	_dots[_round].text = dot_symbols[si]
	_dots[_round].add_theme_color_override("font_color",
		[C_MUTED, C_OK, C_GOOD, C_PERFECT, C_PERFECT][si])

	_feedback_lbl.text = label
	_feedback_lbl.add_theme_color_override("font_color", color)

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(_feedback_lbl, "modulate:a", 0.0, 0.5).set_delay(0.4)
	tween.tween_callback(_advance_round)

func _eval_cursor(pos: float) -> float:
	# Distancia al centro (0.5)
	var dist := absf(pos - 0.5)
	if dist <= ZONE_PERFECT: return 2.0
	if dist <= ZONE_GOOD:    return 1.5
	if dist <= ZONE_OK:      return 1.0
	return 0.5

func _advance_round() -> void:
	_round    += 1
	_animating = false

	if _round >= ROUNDS:
		_finish()
		return

	_round_lbl.text = "RONDA %d / %d" % [_round + 1, ROUNDS]

	# Acelerar en cada ronda — la dificultad sube gradualmente
	_speed_l *= 1.18
	_speed_r *= 1.18

	# Reset cursores a posiciones opuestas (fuerza al jugador a anticipar)
	_pos_l = 0.15
	_pos_r = 0.85
	_dir_l =  1.0
	_dir_r = -1.0

	_waiting_input = true

	var bar_l_ctrl := (_bar_l.get_child(1) as Control)
	var bar_r_ctrl := (_bar_r.get_child(1) as Control)
	bar_l_ctrl.queue_redraw()
	bar_r_ctrl.queue_redraw()

func _finish() -> void:
	var avg: float = 0.0
	for s in _scores:
		avg += s
	avg /= float(_scores.size())

	_hint_lbl.text  = ""
	_round_lbl.text = ""

	var result_lbl := Label.new()
	var pct := int((avg / 2.0) * 100.0)
	result_lbl.text                 = "Eficiencia: %d%%" % pct
	result_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_lbl.add_theme_color_override("font_color", C_ACCENT)
	result_lbl.add_theme_font_size_override("font_size", 15)

	# Insertar label antes del último spacer
	var vbox := _dots[0].get_parent().get_parent()
	vbox.add_child(result_lbl)

	var tween := create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(func() -> void: completed.emit(avg))

# ─────────────────────────────────────────────────────────────────────────────
# Dibujo de barra vertical
# ─────────────────────────────────────────────────────────────────────────────

func _draw_bar_left() -> void:
	var bar := (_bar_l.get_child(1) as Control)
	_draw_bar_impl(bar, _pos_l)

func _draw_bar_right() -> void:
	var bar := (_bar_r.get_child(1) as Control)
	_draw_bar_impl(bar, _pos_r)

func _draw_bar_impl(bar: Control, pos: float) -> void:
	var w := float(BAR_WIDTH)
	var h := bar.size.y

	# Fondo
	bar.draw_rect(Rect2(0, 0, w, h), C_TRACK, true)

	# Zonas coloreadas simétricas alrededor del centro vertical
	var cy := h * 0.5
	_draw_zone_v(bar, cy, h, w, ZONE_OK,      C_OK.darkened(0.4))
	_draw_zone_v(bar, cy, h, w, ZONE_GOOD,    C_GOOD.darkened(0.3))
	_draw_zone_v(bar, cy, h, w, ZONE_PERFECT, C_PERFECT.darkened(0.1))

	# Cursor horizontal
	var cy_cursor := pos * h
	bar.draw_rect(
		Rect2(0, cy_cursor - CURSOR_HEIGHT * 0.5, w, CURSOR_HEIGHT),
		C_CURSOR, true
	)

func _draw_zone_v(bar: Control, cy: float, h: float, w: float,
		zone: float, color: Color) -> void:
	var half := zone * h
	bar.draw_rect(Rect2(0, cy - half, w, half * 2.0), color, true)

# ─────────────────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────────────────

func _spacer_v(height: int) -> Control:
	var s := Control.new(); s.custom_minimum_size.y = height; return s
