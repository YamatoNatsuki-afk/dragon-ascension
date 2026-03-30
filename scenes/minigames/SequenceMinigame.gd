# res://scenes/minigames/SequenceMinigame.gd
#
# Minijuego: LECTURA DE COMBATE — para Intel Combate / Inteligencia
#
# 4 zonas se iluminan en secuencia. El jugador las repite en orden.
# Cada ronda añade un paso. 5 rondas. Error = fallo de ronda.

class_name SequenceMinigame
extends Control

signal completed(multiplier: float)

const ROUNDS:        int   = 5
const BASE_SEQ_LEN:  int   = 3    # longitud inicial
const SHOW_DELAY:    float = 0.55  # tiempo entre iluminaciones
const SHOW_DURATION: float = 0.40  # cuánto dura cada iluminación

const C_BG    := Color(0.05, 0.05, 0.07, 0.93)
const C_PANEL := Color(0.12, 0.12, 0.16)
const C_MUTED := Color(0.50, 0.49, 0.47)
const C_TEXT  := Color(0.92, 0.90, 0.86)
const C_ACCENT:= Color(1.00, 0.78, 0.10)

# Colores y etiquetas de cada zona (4 zonas)
const ZONE_COLORS: Array = [
	Color(0.28, 0.85, 0.44),   # verde  (↑ arriba)
	Color(0.30, 0.60, 1.00),   # azul   (→ derecha)
	Color(0.95, 0.25, 0.20),   # rojo   (↓ abajo)
	Color(1.00, 0.78, 0.10),   # dorado (← izquierda)
]
const ZONE_LABELS: Array = ["▲", "▶", "▼", "◀"]
const ZONE_KEYS: Array   = [KEY_UP, KEY_RIGHT, KEY_DOWN, KEY_LEFT]

var _sequence:      Array[int] = []
var _player_input:  Array[int] = []
var _showing:       bool = false
var _accepting:     bool = false
var _lit_zone:      int  = -1
var _lit_timer:     float = 0.0

var _round:         int   = 0
var _score:         int   = 0   # rondas superadas
var _active:        bool  = false

var _zone_nodes:    Array = []  # Array[Control]
var _status_lbl:    Label
var _round_lbl:     Label
var _hint_lbl:      Label
var _progress_dots: Array = []  # Array[Label] mostrando la secuencia

var _action_name:   String = ""
var _target_stats:  Array[StringName] = []

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
	card.custom_minimum_size = Vector2(380, 0)
	var sb := StyleBoxFlat.new()
	sb.bg_color = C_PANEL
	sb.corner_radius_top_left = 8; sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8; sb.corner_radius_bottom_right = 8
	sb.border_width_top = 2; sb.border_color = ZONE_COLORS[2].lerp(C_PANEL, 0.4)
	card.add_theme_stylebox_override("panel", sb)
	center.add_child(card)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	card.add_child(vbox)

	vbox.add_child(_spacer_v(20))

	var title := Label.new()
	title.text = "LECTURA DE COMBATE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", ZONE_COLORS[2])
	title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title)

	vbox.add_child(_spacer_v(6))

	_round_lbl = Label.new()
	_round_lbl.text = "RONDA 1 / %d" % ROUNDS
	_round_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_round_lbl.add_theme_color_override("font_color", C_MUTED)
	_round_lbl.add_theme_font_size_override("font_size", 12)
	vbox.add_child(_round_lbl)

	vbox.add_child(_spacer_v(20))

	# Grid 2×2 de zonas
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	var grid_row := HBoxContainer.new()
	grid_row.add_child(_spacer_expand())
	grid_row.add_child(grid)
	grid_row.add_child(_spacer_expand())
	vbox.add_child(grid_row)

	for i in 4:
		var zone := _build_zone_button(i)
		grid.add_child(zone)
		_zone_nodes.append(zone)

	vbox.add_child(_spacer_v(20))

	# Dots de progreso (muestra cuántos pasos de la secuencia quedan)
	var dots_row := HBoxContainer.new()
	dots_row.alignment = BoxContainer.ALIGNMENT_CENTER
	dots_row.add_theme_constant_override("separation", 8)
	vbox.add_child(dots_row)
	for i in BASE_SEQ_LEN + ROUNDS:
		var dot := Label.new()
		dot.text = "○"
		dot.add_theme_color_override("font_color", C_MUTED)
		dot.add_theme_font_size_override("font_size", 16)
		dots_row.add_child(dot)
		_progress_dots.append(dot)

	vbox.add_child(_spacer_v(16))

	_status_lbl = Label.new()
	_status_lbl.text = "Observa la secuencia..."
	_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_lbl.add_theme_color_override("font_color", C_TEXT)
	_status_lbl.add_theme_font_size_override("font_size", 15)
	vbox.add_child(_status_lbl)

	vbox.add_child(_spacer_v(10))

	_hint_lbl = Label.new()
	_hint_lbl.text = "Flechas ← → ↑ ↓ o click en los paneles"
	_hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_lbl.add_theme_color_override("font_color", C_MUTED)
	_hint_lbl.add_theme_font_size_override("font_size", 11)
	vbox.add_child(_hint_lbl)

	vbox.add_child(_spacer_v(20))

func _build_zone_button(index: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(120, 80)

	var sb := StyleBoxFlat.new()
	sb.bg_color = ZONE_COLORS[index].lerp(Color(0.1, 0.1, 0.13), 0.82)
	sb.border_color = ZONE_COLORS[index].lerp(Color(0.1, 0.1, 0.13), 0.55)
	sb.border_width_bottom = 3
	sb.corner_radius_top_left = 6; sb.corner_radius_top_right = 6
	sb.corner_radius_bottom_left = 6; sb.corner_radius_bottom_right = 6
	panel.add_theme_stylebox_override("panel", sb)
	panel.set_meta("sb", sb)
	panel.set_meta("index", index)

	var lbl := Label.new()
	lbl.text = ZONE_LABELS[index]
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	lbl.add_theme_color_override("font_color", ZONE_COLORS[index])
	lbl.add_theme_font_size_override("font_size", 32)
	panel.add_child(lbl)

	# Click para input
	var btn := Button.new()
	btn.flat = true
	btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	btn.pressed.connect(_on_zone_clicked.bind(index))
	panel.add_child(btn)

	return panel

# ─────────────────────────────────────────────────────────────────────────────
# Lógica
# ─────────────────────────────────────────────────────────────────────────────

func _start_round() -> void:
	_accepting = false
	_showing   = false
	_player_input.clear()
	_round_lbl.text = "RONDA %d / %d" % [_round + 1, ROUNDS]

	# Generar secuencia
	var seq_len := BASE_SEQ_LEN + _round
	_sequence.clear()
	for i in seq_len:
		_sequence.append(randi() % 4)

	# Actualizar dots
	for i in _progress_dots.size():
		var dot := _progress_dots[i] as Label
		if i < seq_len:
			dot.text = "○"
			dot.add_theme_color_override("font_color", C_MUTED)
			dot.visible = true
		else:
			dot.visible = false

	_status_lbl.text = "Observa..."
	_status_lbl.add_theme_color_override("font_color", C_TEXT)

	await get_tree().create_timer(0.5).timeout
	_show_sequence()

func _show_sequence() -> void:
	_showing = true
	for i in _sequence.size():
		var zone_idx: int = _sequence[i]
		_light_zone(zone_idx)
		await get_tree().create_timer(SHOW_DURATION).timeout
		_unlight_zone(zone_idx)
		await get_tree().create_timer(SHOW_DELAY - SHOW_DURATION).timeout
	_showing = false
	_accepting = true
	_active    = true
	_status_lbl.text = "¡Repite la secuencia!"
	_status_lbl.add_theme_color_override("font_color", C_ACCENT)

func _light_zone(index: int) -> void:
	var panel := _zone_nodes[index] as PanelContainer
	var sb := panel.get_meta("sb") as StyleBoxFlat
	sb.bg_color = ZONE_COLORS[index].lerp(Color(0.1, 0.1, 0.13), 0.30)
	sb.border_color = ZONE_COLORS[index]
	sb.border_width_bottom = 5

func _unlight_zone(index: int) -> void:
	var panel := _zone_nodes[index] as PanelContainer
	var sb := panel.get_meta("sb") as StyleBoxFlat
	sb.bg_color = ZONE_COLORS[index].lerp(Color(0.1, 0.1, 0.13), 0.82)
	sb.border_color = ZONE_COLORS[index].lerp(Color(0.1, 0.1, 0.13), 0.55)
	sb.border_width_bottom = 3

func _register_input(zone_index: int) -> void:
	if not _accepting:
		return

	_player_input.append(zone_index)
	_light_zone(zone_index)
	var tween := create_tween()
	tween.tween_interval(0.12)
	tween.tween_callback(_unlight_zone.bind(zone_index))

	# Actualizar dot
	var pos := _player_input.size() - 1
	if pos < _progress_dots.size():
		var dot := _progress_dots[pos] as Label
		if _player_input[pos] == _sequence[pos]:
			dot.text = "●"
			dot.add_theme_color_override("font_color", ZONE_COLORS[zone_index])
		else:
			dot.text = "✗"
			dot.add_theme_color_override("font_color", Color(0.95, 0.25, 0.20))

	# Verificar
	var current_pos := _player_input.size() - 1
	if _player_input[current_pos] != _sequence[current_pos]:
		# Error
		_accepting = false
		_active    = false
		_status_lbl.text = "✗ Error"
		_status_lbl.add_theme_color_override("font_color", Color(0.95, 0.25, 0.20))
		_round += 1
		await get_tree().create_timer(0.8).timeout
		_advance()
		return

	if _player_input.size() >= _sequence.size():
		# Ronda completada
		_accepting = false
		_active    = false
		_score    += 1
		_status_lbl.text = "✓ ¡Correcto!"
		_status_lbl.add_theme_color_override("font_color", ZONE_COLORS[0])
		_round += 1
		await get_tree().create_timer(0.6).timeout
		_advance()

func _advance() -> void:
	if _round >= ROUNDS:
		_finish()
	else:
		_start_round()

func _finish() -> void:
	_hint_lbl.text = ""
	var pct: float = float(_score) / float(ROUNDS)
	var mult       := lerpf(0.5, 2.0, pct)
	_status_lbl.text = "Precisión: %d%%" % int(pct * 100.0)
	_status_lbl.add_theme_color_override("font_color", C_ACCENT)
	await get_tree().create_timer(1.0).timeout
	completed.emit(mult)

# ─────────────────────────────────────────────────────────────────────────────
# Input
# ─────────────────────────────────────────────────────────────────────────────

func _on_zone_clicked(index: int) -> void:
	_register_input(index)

func _unhandled_input(event: InputEvent) -> void:
	if not _active:
		return
	if event is InputEventKey and event.pressed:
		var key := (event as InputEventKey).keycode
		for i in ZONE_KEYS.size():
			if key == ZONE_KEYS[i]:
				_register_input(i)
				return

# ─────────────────────────────────────────────────────────────────────────────

func _spacer_v(h: int) -> Control:
	var s := Control.new(); s.custom_minimum_size.y = h; return s
func _spacer_expand() -> Control:
	var s := Control.new(); s.size_flags_horizontal = Control.SIZE_EXPAND_FILL; return s
