# res://scenes/minigames/SnakeRoadMinigame.gd
#
# Minijuego de timing para el Camino de la Serpiente.
# Se muestra como overlay encima del DayScreen.
#
# MECÁNICA:
#   5 rondas por sesión. Cada ronda tiene un cursor que oscila en una barra.
#   El jugador presiona SPACE o hace click cuando el cursor está en la zona
#   correcta. La precisión determina el multiplicador de km ganados.
#
#   Zonas:
#     Centro (±8%)  → PERFECTO ×2.0  (verde brillante)
#     Medio  (±18%) → BUENO    ×1.5  (verde)
#     Borde  (±30%) → OK       ×1.0  (amarillo)
#     Fuera         → FALLO    ×0.5  (rojo)
#
#   La velocidad del cursor baja con intel_combate:
#     speed_factor = 1.0 - clamp(intel_combate / 200.0, 0.0, 0.5)
#
# SEÑAL:
#   completed(multiplier: float) → emitida al terminar las 5 rondas

class_name SnakeRoadMinigame
extends Control

signal completed(multiplier: float)

# ── Constantes de diseño ──────────────────────────────────────────────────
const ROUNDS:          int   = 5
const BASE_SPEED:      float = 0.9   # fracción del ancho por segundo
const BAR_HEIGHT:      int   = 24
const ZONE_PERFECT:    float = 0.08  # ±8% del centro
const ZONE_GOOD:       float = 0.18
const ZONE_OK:         float = 0.30

# ── Paleta ────────────────────────────────────────────────────────────────
const C_BG         := Color(0.05, 0.05, 0.07, 0.92)
const C_PANEL      := Color(0.12, 0.12, 0.16)
const C_TRACK      := Color(0.20, 0.20, 0.26)
const C_PERFECT    := Color(0.20, 1.00, 0.50)
const C_GOOD       := Color(0.28, 0.85, 0.44)
const C_OK         := Color(1.00, 0.78, 0.10)
const C_MISS       := Color(0.90, 0.30, 0.28)
const C_CURSOR     := Color(1.00, 1.00, 1.00)
const C_TEXT       := Color(0.92, 0.90, 0.86)
const C_MUTED      := Color(0.50, 0.49, 0.47)
const C_ACCENT     := Color(1.00, 0.78, 0.10)

# ── Estado del minijuego ──────────────────────────────────────────────────
var _intel_combate:   float = 0.0
var _round:           int   = 0
var _cursor_pos:      float = 0.5   # 0.0–1.0 en la barra
var _cursor_dir:      float = 1.0   # +1 o -1
var _cursor_speed:    float = BASE_SPEED
var _scores:          Array[float] = []
var _waiting_input:   bool  = true
var _round_animating: bool  = false

# ── Nodos ────────────────────────────────────────────────────────────────
var _title_lbl:    Label
var _km_lbl:       Label
var _round_lbl:    Label
var _bar_rect:     Control   # contenedor de la barra
var _feedback_lbl: Label
var _dots:         Array[Label] = []
var _hint_lbl:     Label

# ── Datos externos ────────────────────────────────────────────────────────
var _base_km:         float = 0.0
var _total_km:        float = 0.0
var _target_km:       float = 1_000_000.0

# ─────────────────────────────────────────────────────────────────────────────

func setup(intel: float, base_km: float, current_km: float, target_km: float) -> void:
	_intel_combate = intel
	_base_km       = base_km
	_total_km      = current_km
	_target_km     = target_km
	# Velocidad del cursor: IC alta = cursor más lento (más fácil de precisar)
	var slow_factor := clampf(intel / 150.0, 0.0, 0.50)
	_cursor_speed   = BASE_SPEED * (1.0 - slow_factor)

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	_start_round()

# ─────────────────────────────────────────────────────────────────────────────
# UI
# ─────────────────────────────────────────────────────────────────────────────

func _build_ui() -> void:
	# Fondo semitransparente
	var bg := ColorRect.new()
	bg.color = C_BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(480, 0)
	var card_sb := StyleBoxFlat.new()
	card_sb.bg_color                   = C_PANEL
	card_sb.corner_radius_top_left     = 8
	card_sb.corner_radius_top_right    = 8
	card_sb.corner_radius_bottom_left  = 8
	card_sb.corner_radius_bottom_right = 8
	card_sb.border_width_top    = 2
	card_sb.border_color        = C_ACCENT.lerp(C_PANEL, 0.5)
	card.add_theme_stylebox_override("panel", card_sb)
	center.add_child(card)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	card.add_child(vbox)

	vbox.add_child(_spacer_v(28))

	# ── Título ────────────────────────────────────────────────────────
	_title_lbl = Label.new()
	_title_lbl.text = "CAMINO DE LA SERPIENTE"
	_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_lbl.add_theme_color_override("font_color", C_ACCENT)
	_title_lbl.add_theme_font_size_override("font_size", 18)
	vbox.add_child(_title_lbl)

	vbox.add_child(_spacer_v(6))

	# ── Progreso total ────────────────────────────────────────────────
	_km_lbl = Label.new()
	_km_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_km_lbl.add_theme_color_override("font_color", C_MUTED)
	_km_lbl.add_theme_font_size_override("font_size", 12)
	vbox.add_child(_km_lbl)
	_update_km_label()

	vbox.add_child(_spacer_v(24))

	# ── Label de ronda ────────────────────────────────────────────────
	_round_lbl = Label.new()
	_round_lbl.text = "RONDA 1 / %d" % ROUNDS
	_round_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_round_lbl.add_theme_color_override("font_color", C_MUTED)
	_round_lbl.add_theme_font_size_override("font_size", 11)
	vbox.add_child(_round_lbl)

	vbox.add_child(_spacer_v(10))

	# ── Barra de timing ───────────────────────────────────────────────
	var bar_wrap := HBoxContainer.new()
	bar_wrap.add_theme_constant_override("separation", 0)
	vbox.add_child(bar_wrap)
	bar_wrap.add_child(_spacer_h(40))

	_bar_rect = Control.new()
	_bar_rect.custom_minimum_size = Vector2(0, BAR_HEIGHT + 16)
	_bar_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_bar_rect.draw.connect(_draw_bar)
	bar_wrap.add_child(_bar_rect)
	bar_wrap.add_child(_spacer_h(40))

	vbox.add_child(_spacer_v(14))

	# ── Feedback ──────────────────────────────────────────────────────
	_feedback_lbl = Label.new()
	_feedback_lbl.text = ""
	_feedback_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_feedback_lbl.add_theme_font_size_override("font_size", 22)
	_feedback_lbl.add_theme_color_override("font_color", C_PERFECT)
	vbox.add_child(_feedback_lbl)

	vbox.add_child(_spacer_v(14))

	# ── Dots de progreso ──────────────────────────────────────────────
	var dots_row := HBoxContainer.new()
	dots_row.alignment = BoxContainer.ALIGNMENT_CENTER
	dots_row.add_theme_constant_override("separation", 10)
	vbox.add_child(dots_row)

	for i in ROUNDS:
		var dot := Label.new()
		dot.text = "○"
		dot.add_theme_color_override("font_color", C_MUTED)
		dot.add_theme_font_size_override("font_size", 18)
		dots_row.add_child(dot)
		_dots.append(dot)

	vbox.add_child(_spacer_v(20))

	# ── Hint ──────────────────────────────────────────────────────────
	_hint_lbl = Label.new()
	_hint_lbl.text = "[ SPACE ] o [ CLICK ] para correr"
	_hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_lbl.add_theme_color_override("font_color", C_MUTED)
	_hint_lbl.add_theme_font_size_override("font_size", 11)
	vbox.add_child(_hint_lbl)

	vbox.add_child(_spacer_v(28))

# ─────────────────────────────────────────────────────────────────────────────
# Loop del juego
# ─────────────────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	if not _waiting_input or _round_animating:
		return

	# Mover cursor
	_cursor_pos += _cursor_dir * _cursor_speed * delta
	if _cursor_pos >= 1.0:
		_cursor_pos = 1.0
		_cursor_dir = -1.0
	elif _cursor_pos <= 0.0:
		_cursor_pos = 0.0
		_cursor_dir = 1.0

	_bar_rect.queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not _waiting_input or _round_animating:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		_register_input()
	elif event is InputEventMouseButton and event.pressed:
		_register_input()

func _register_input() -> void:
	_waiting_input   = false
	_round_animating = true

	# Distancia del cursor al centro (0.5)
	var dist := absf(_cursor_pos - 0.5)  # 0.0 = centro, 0.5 = extremo

	var score: float
	var label: String
	var color: Color

	if dist <= ZONE_PERFECT:
		score = 2.0; label = "¡PERFECTO!"; color = C_PERFECT
	elif dist <= ZONE_GOOD:
		score = 1.5; label = "BUENO";      color = C_GOOD
	elif dist <= ZONE_OK:
		score = 1.0; label = "OK";         color = C_OK
	else:
		score = 0.5; label = "FALLO";      color = C_MISS

	_scores.append(score)

	# Actualizar dot
	var dot_symbols := ["○", "◑", "●", "◉", "✦"]
	var dot_colors  := [C_MUTED, C_OK, C_GOOD, C_PERFECT, C_PERFECT]
	var si := clampi(int((score - 0.5) / 0.5), 0, 4)
	_dots[_round].text = dot_symbols[si]
	_dots[_round].add_theme_color_override("font_color", dot_colors[si])

	# Mostrar feedback animado
	_feedback_lbl.text = label
	_feedback_lbl.add_theme_color_override("font_color", color)
	_feedback_lbl.modulate = Color.WHITE

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(_feedback_lbl, "modulate:a", 0.0, 0.5).set_delay(0.4)
	tween.tween_callback(_advance_round)

func _advance_round() -> void:
	_round         += 1
	_round_animating = false

	if _round >= ROUNDS:
		_finish()
		return

	_round_lbl.text = "RONDA %d / %d" % [_round + 1, ROUNDS]
	# Aumentar levemente la velocidad en cada ronda (presión creciente)
	_cursor_speed  *= 1.12
	_cursor_pos     = 0.5
	_waiting_input  = true
	_bar_rect.queue_redraw()

func _finish() -> void:
	var avg: float = 0.0
	for s in _scores:
		avg += s
	avg /= float(_scores.size())

	_hint_lbl.text   = ""
	_title_lbl.text  = "SESIÓN COMPLETADA"
	_round_lbl.text  = ""

	var km_gained := _base_km * avg
	_total_km       += km_gained
	_update_km_label()

	var result_lbl := Label.new()
	result_lbl.text = "%.0f km recorridos hoy" % km_gained
	result_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_lbl.add_theme_color_override("font_color", C_ACCENT)
	result_lbl.add_theme_font_size_override("font_size", 15)
	_bar_rect.get_parent().add_child(result_lbl)

	# Breve pausa antes de cerrar
	var tween := create_tween()
	tween.tween_interval(1.2)
	tween.tween_callback(func() -> void: completed.emit(avg))

# ─────────────────────────────────────────────────────────────────────────────
# Dibujado de la barra (usando _draw)
# ─────────────────────────────────────────────────────────────────────────────

func _draw_bar() -> void:
	var w := _bar_rect.size.x
	var h := float(BAR_HEIGHT)
	var y := (_bar_rect.size.y - h) * 0.5

	# Fondo de la barra
	_bar_rect.draw_rect(Rect2(0, y, w, h), C_TRACK, true, -1.0, true)

	# Zonas coloreadas (simétricas alrededor del centro)
	var cx := w * 0.5
	_draw_zone(_bar_rect, cx, w, y, h, ZONE_OK,      C_OK.darkened(0.4))
	_draw_zone(_bar_rect, cx, w, y, h, ZONE_GOOD,    C_GOOD.darkened(0.3))
	_draw_zone(_bar_rect, cx, w, y, h, ZONE_PERFECT, C_PERFECT.darkened(0.1))

	# Cursor
	var cx_pos := _cursor_pos * w
	var cw     := 6.0
	var cr     := 3.0
	_bar_rect.draw_rect(
		Rect2(cx_pos - cw * 0.5, y - 2, cw, h + 4),
		C_CURSOR, true, -1.0, true
	)

func _draw_zone(target: Control, cx: float, w: float, y: float, h: float,
		zone: float, color: Color) -> void:
	var half_w := zone * w
	target.draw_rect(Rect2(cx - half_w, y, half_w * 2.0, h), color, true, -1.0, true)

# ─────────────────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────────────────

func _update_km_label() -> void:
	var pct := clampf(_total_km / _target_km * 100.0, 0.0, 100.0)
	_km_lbl.text = "%.0f / %.0f km  (%.1f%%)" % [_total_km, _target_km, pct]

func _start_round() -> void:
	_waiting_input   = true
	_round_animating = false
	_cursor_pos      = 0.5
	_cursor_dir      = 1.0

func _spacer_h(w: int) -> Control:
	var s := Control.new(); s.custom_minimum_size.x = w; return s

func _spacer_v(h: int) -> Control:
	var s := Control.new(); s.custom_minimum_size.y = h; return s
