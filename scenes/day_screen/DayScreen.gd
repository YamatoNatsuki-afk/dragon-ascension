# res://scenes/day_screen/DayScreen.gd
# Pantalla principal del loop de 100 días.
# Construye toda su UI en código — no necesita nodos en el .tscn.
# Conecta al EventBus y llama a DayManager — no tiene lógica de gameplay.
class_name DayScreen
extends Control

# ── Estados ────────────────────────────────────────────────────────────────
enum State { WAITING, SHOWING_ACTIONS, SHOWING_RESULT }
var _state: State = State.WAITING

# ── Datos ──────────────────────────────────────────────────────────────────
var _character_data  # CharacterData
var _available_actions: Array[DayAction] = []

# ── Nodos UI (creados en _build_ui) ────────────────────────────────────────
var _day_label: Label
var _xp_label: Label
var _stats_container: VBoxContainer
var _actions_title: Label
var _actions_container: VBoxContainer
var _result_overlay: PanelContainer
var _result_action_label: Label
var _result_changes_container: VBoxContainer
var _result_xp_label: Label
var _result_narrative_label: Label
var _continue_button: Button

# ── Paleta ─────────────────────────────────────────────────────────────────
const C_BG        := Color(0.07, 0.07, 0.09)
const C_PANEL     := Color(0.12, 0.12, 0.16)
const C_PANEL_ALT := Color(0.17, 0.17, 0.22)
const C_ACCENT    := Color(1.00, 0.78, 0.10)
const C_POSITIVE  := Color(0.28, 0.85, 0.44)
const C_NEGATIVE  := Color(0.90, 0.32, 0.28)
const C_TEXT      := Color(0.92, 0.90, 0.86)
const C_MUTED     := Color(0.50, 0.49, 0.47)
const C_EVENT     := Color(0.94, 0.62, 0.15)

# ─────────────────────────────────────────────────────────────────────────────
# Arranque
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	_character_data = GameStateProvider.get_character_data()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	_connect_signals()

func _connect_signals() -> void:
	EventBus.day_started.connect(_on_day_started)
	EventBus.day_actions_ready.connect(_on_day_actions_ready)
	EventBus.day_action_resolved.connect(_on_day_action_resolved)
	EventBus.day_ended.connect(_on_day_ended)
	EventBus.game_completed.connect(_on_game_completed)

# ─────────────────────────────────────────────────────────────────────────────
# Construcción de UI
# ─────────────────────────────────────────────────────────────────────────────

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = C_BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 2)
	add_child(root)

	root.add_child(_build_header())

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 2)
	root.add_child(body)

	body.add_child(_build_stats_panel())
	body.add_child(_build_actions_panel())

	_result_overlay = _build_result_overlay()
	_result_overlay.visible = false
	add_child(_result_overlay)

# ── Header ────────────────────────────────────────────────────────────────

func _build_header() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _flat_style(C_PANEL))

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 0)
	panel.add_child(hbox)

	hbox.add_child(_spacer_h(20))

	var title := Label.new()
	title.text = "DRAGON ASCENSION"
	title.add_theme_color_override("font_color", C_ACCENT)
	title.add_theme_font_size_override("font_size", 15)
	title.add_theme_constant_override("outline_size", 0)
	hbox.add_child(title)

	hbox.add_child(_spacer_expand())

	if _character_data:
		var char_label := Label.new()
		char_label.text = "%s  ·  %s" % [_character_data.character_name, str(_character_data.race_id)]
		char_label.add_theme_color_override("font_color", C_MUTED)
		char_label.add_theme_font_size_override("font_size", 13)
		hbox.add_child(char_label)

	hbox.add_child(_spacer_h(32))

	_xp_label = Label.new()
	_xp_label.text = "XP  0"
	_xp_label.add_theme_color_override("font_color", C_TEXT)
	_xp_label.add_theme_font_size_override("font_size", 13)
	hbox.add_child(_xp_label)

	hbox.add_child(_spacer_h(32))

	_day_label = Label.new()
	_day_label.text = "DÍA  —  / 100"
	_day_label.add_theme_color_override("font_color", C_ACCENT)
	_day_label.add_theme_font_size_override("font_size", 15)
	hbox.add_child(_day_label)

	hbox.add_child(_spacer_h(20))

	return panel

# ── Panel de stats ────────────────────────────────────────────────────────

func _build_stats_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = 240
	panel.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _flat_style(C_PANEL))

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	panel.add_child(vbox)

	vbox.add_child(_spacer_v(16))
	vbox.add_child(_section_title("ESTADÍSTICAS"))

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", C_PANEL_ALT)
	vbox.add_child(sep)

	vbox.add_child(_spacer_v(8))

	var stats_wrap := HBoxContainer.new()
	stats_wrap.add_theme_constant_override("separation", 0)
	vbox.add_child(stats_wrap)

	stats_wrap.add_child(_spacer_h(16))

	_stats_container = VBoxContainer.new()
	_stats_container.add_theme_constant_override("separation", 14)
	_stats_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats_wrap.add_child(_stats_container)

	stats_wrap.add_child(_spacer_h(16))

	_refresh_stats()
	return panel

# ── Panel de acciones ─────────────────────────────────────────────────────

func _build_actions_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _flat_style(C_BG))

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	panel.add_child(vbox)

	vbox.add_child(_spacer_v(16))

	var title_row := HBoxContainer.new()
	title_row.add_child(_spacer_h(20))
	_actions_title = Label.new()
	_actions_title.text = "SELECCIONA UNA ACCIÓN"
	_actions_title.add_theme_color_override("font_color", C_MUTED)
	_actions_title.add_theme_font_size_override("font_size", 11)
	title_row.add_child(_actions_title)
	vbox.add_child(title_row)

	vbox.add_child(_spacer_v(8))

	var sep_row := HBoxContainer.new()
	sep_row.add_child(_spacer_h(20))
	var sep := HSeparator.new()
	sep.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sep.add_theme_color_override("color", C_PANEL)
	sep_row.add_child(sep)
	sep_row.add_child(_spacer_h(20))
	vbox.add_child(sep_row)

	vbox.add_child(_spacer_v(12))

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical        = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode     = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(scroll)

	var scroll_wrap := HBoxContainer.new()
	scroll_wrap.add_theme_constant_override("separation", 0)
	scroll_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(scroll_wrap)

	scroll_wrap.add_child(_spacer_h(20))

	_actions_container = VBoxContainer.new()
	_actions_container.add_theme_constant_override("separation", 8)
	_actions_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_wrap.add_child(_actions_container)

	scroll_wrap.add_child(_spacer_h(20))

	vbox.add_child(_spacer_v(16))

	return panel

# ── Overlay de resultado ─────────────────────────────────────────────────

func _build_result_overlay() -> PanelContainer:
	var overlay := PanelContainer.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.0, 0.0, 0.0, 0.70)
	overlay.add_theme_stylebox_override("panel", bg_style)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(500, 0)
	card.add_theme_stylebox_override("panel", _flat_style(C_PANEL))
	center.add_child(card)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	card.add_child(vbox)

	vbox.add_child(_spacer_v(28))

	_result_action_label = Label.new()
	_result_action_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_action_label.add_theme_color_override("font_color", C_ACCENT)
	_result_action_label.add_theme_font_size_override("font_size", 20)
	vbox.add_child(_result_action_label)

	vbox.add_child(_spacer_v(20))

	var sep_row := HBoxContainer.new()
	sep_row.add_child(_spacer_h(40))
	var sep := HSeparator.new()
	sep.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sep.add_theme_color_override("color", C_PANEL_ALT)
	sep_row.add_child(sep)
	sep_row.add_child(_spacer_h(40))
	vbox.add_child(sep_row)

	vbox.add_child(_spacer_v(20))

	var changes_row := HBoxContainer.new()
	changes_row.add_child(_spacer_h(60))
	_result_changes_container = VBoxContainer.new()
	_result_changes_container.add_theme_constant_override("separation", 10)
	_result_changes_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	changes_row.add_child(_result_changes_container)
	changes_row.add_child(_spacer_h(60))
	vbox.add_child(changes_row)

	vbox.add_child(_spacer_v(16))

	_result_xp_label = Label.new()
	_result_xp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_xp_label.add_theme_color_override("font_color", C_ACCENT)
	_result_xp_label.add_theme_font_size_override("font_size", 15)
	vbox.add_child(_result_xp_label)

	vbox.add_child(_spacer_v(10))

	_result_narrative_label = Label.new()
	_result_narrative_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_narrative_label.add_theme_color_override("font_color", C_MUTED)
	_result_narrative_label.add_theme_font_size_override("font_size", 12)
	_result_narrative_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_result_narrative_label)

	vbox.add_child(_spacer_v(28))

	var btn_row := HBoxContainer.new()
	btn_row.add_child(_spacer_expand())
	_continue_button = Button.new()
	_continue_button.text = "Continuar  →"
	_continue_button.custom_minimum_size = Vector2(180, 40)
	_continue_button.add_theme_font_size_override("font_size", 14)
	_style_button_accent(_continue_button)
	_continue_button.pressed.connect(_on_continue_pressed)
	btn_row.add_child(_continue_button)
	btn_row.add_child(_spacer_expand())
	vbox.add_child(btn_row)

	vbox.add_child(_spacer_v(28))

	return overlay

# ─────────────────────────────────────────────────────────────────────────────
# Respuestas al EventBus
# ─────────────────────────────────────────────────────────────────────────────

func _on_day_started(day_number: int) -> void:
	_day_label.text = "DÍA  %d  /  100" % day_number
	_refresh_stats()

func _on_day_actions_ready(actions: Array) -> void:
	_available_actions.clear()
	for a in actions:
		if a is DayAction:
			_available_actions.append(a)
	_state = State.SHOWING_ACTIONS
	_populate_action_buttons()

func _on_day_action_resolved(action, result) -> void:  # action: DayAction, result: DayActionResult
	_state = State.SHOWING_RESULT
	_show_result(action, result)

func _on_day_ended(_day_number: int, _result) -> void:  # _result: DayActionResult
	_refresh_stats()

func _on_game_completed(_final_data) -> void:  # _final_data: CharacterData
	_actions_title.text = "¡100 DÍAS COMPLETADOS!"
	_clear_action_buttons()
	_continue_button.text = "Ver resumen"

# ─────────────────────────────────────────────────────────────────────────────
# Botón continuar
# ─────────────────────────────────────────────────────────────────────────────

func _on_continue_pressed() -> void:
	_result_overlay.visible = false
	_state = State.WAITING
	var day: int = _character_data.current_day
	if DayManager.phase == DayManager.Phase.IDLE and day >= 1 and day <= 100:
		DayManager.start_day()

# ─────────────────────────────────────────────────────────────────────────────
# Botones de acción
# ─────────────────────────────────────────────────────────────────────────────

func _populate_action_buttons() -> void:
	_clear_action_buttons()
	var ctx := DayContext.create(_character_data)
	for action: DayAction in _available_actions:
		_actions_container.add_child(_build_action_card(action, ctx))

func _clear_action_buttons() -> void:
	for child in _actions_container.get_children():
		child.queue_free()

func _build_action_card(action: DayAction, ctx: DayContext) -> Button:
	var is_risky := action is EventAction or action is CombatEventAction
	var weight   := ActionSelector.compute_weight(action, ctx)

	var btn := Button.new()
	btn.custom_minimum_size.y = 60
	btn.size_flags_horizontal  = Control.SIZE_EXPAND_FILL
	btn.clip_contents          = false

	# Estilo normal
	var normal := StyleBoxFlat.new()
	normal.bg_color             = C_PANEL
	normal.border_width_left    = 3
	normal.border_color         = C_EVENT if is_risky else C_PANEL_ALT
	normal.corner_radius_top_left     = 4
	normal.corner_radius_top_right    = 4
	normal.corner_radius_bottom_left  = 4
	normal.corner_radius_bottom_right = 4
	normal.content_margin_left   = 16
	normal.content_margin_right  = 16
	normal.content_margin_top    = 10
	normal.content_margin_bottom = 10
	btn.add_theme_stylebox_override("normal", normal)

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color     = C_PANEL_ALT
	hover.border_color = C_ACCENT if not is_risky else C_EVENT
	btn.add_theme_stylebox_override("hover", hover)

	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.20, 0.20, 0.26)
	btn.add_theme_stylebox_override("pressed", pressed)

	# Contenido interno
	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 3)
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.set_anchors_preset(Control.PRESET_FULL_RECT)
	btn.add_child(inner)

	# Fila superior: nombre + peso
	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 6)
	top_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.add_child(top_row)

	if is_risky:
		var icon := Label.new()
		icon.text = "⚠"
		icon.add_theme_color_override("font_color", C_EVENT)
		icon.add_theme_font_size_override("font_size", 13)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		top_row.add_child(icon)

	var name_lbl := Label.new()
	name_lbl.text = action.display_name
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.add_theme_color_override("font_color", C_TEXT)
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_row.add_child(name_lbl)

	var weight_lbl := Label.new()
	weight_lbl.text = "%.2f" % weight
	weight_lbl.add_theme_color_override("font_color", C_MUTED)
	weight_lbl.add_theme_font_size_override("font_size", 12)
	weight_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_row.add_child(weight_lbl)

	# Fila inferior: tipo de acción
	var type_lbl := Label.new()
	type_lbl.text = str(action.action_type).to_upper()
	type_lbl.add_theme_color_override("font_color", C_EVENT if is_risky else C_MUTED)
	type_lbl.add_theme_font_size_override("font_size", 11)
	type_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.add_child(type_lbl)

	btn.pressed.connect(_on_action_selected.bind(action))
	return btn

func _on_action_selected(action: DayAction) -> void:
	if _state != State.SHOWING_ACTIONS:
		return
	_state = State.WAITING
	# Deshabilitar todos los botones mientras se resuelve
	for child in _actions_container.get_children():
		if child is Button:
			(child as Button).disabled = true
	DayManager.execute_action(action)

# ─────────────────────────────────────────────────────────────────────────────
# Panel de resultado
# ─────────────────────────────────────────────────────────────────────────────

func _show_result(action, result) -> void:  # action: DayAction, result: DayActionResult
	for child in _result_changes_container.get_children():
		child.queue_free()

	_result_action_label.text = action.display_name

	if result.stat_changes.is_empty():
		var no_change := Label.new()
		no_change.text = "Sin cambios de stats"
		no_change.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		no_change.add_theme_color_override("font_color", C_MUTED)
		_result_changes_container.add_child(no_change)
	else:
		for stat_id: StringName in result.stat_changes.keys():
			var delta: float = result.stat_changes[stat_id]
			_result_changes_container.add_child(_stat_change_row(stat_id, delta))

	_result_xp_label.text = "+ %.1f XP" % result.xp_gained if result.xp_gained > 0.0 else ""
	_result_narrative_label.text = result.narrative_key.replace(".", "  ·  ").replace("_", " ")

	# Deshabilitar el botón durante el fade-in — sin esto, el evento mouse_up
	# del click en la acción activa el botón en cascada porque el overlay
	# aparece justo debajo del cursor y se auto-presiona frame a frame.
	_continue_button.disabled = true
	_result_overlay.visible   = true
	_result_overlay.modulate  = Color.TRANSPARENT
	var tween := create_tween()
	tween.tween_property(_result_overlay, "modulate", Color.WHITE, 0.25)
	tween.tween_callback(func() -> void: _continue_button.disabled = false)

func _stat_change_row(stat_id: StringName, delta: float) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)

	var name_lbl := Label.new()
	name_lbl.text = str(stat_id)
	name_lbl.custom_minimum_size.x = 130
	name_lbl.add_theme_color_override("font_color", C_TEXT)
	name_lbl.add_theme_font_size_override("font_size", 14)
	row.add_child(name_lbl)

	var delta_lbl := Label.new()
	var positive  := delta >= 0.0
	delta_lbl.text = ("%+.1f" % delta) + ("  ▲" if positive else "  ▼")
	delta_lbl.add_theme_color_override("font_color", C_POSITIVE if positive else C_NEGATIVE)
	delta_lbl.add_theme_font_size_override("font_size", 15)
	row.add_child(delta_lbl)

	return row

# ─────────────────────────────────────────────────────────────────────────────
# Refresh de stats
# ─────────────────────────────────────────────────────────────────────────────

func _refresh_stats() -> void:
	if _character_data == null:
		return
	for child in _stats_container.get_children():
		child.queue_free()

	_xp_label.text = "XP  %d" % int(_character_data.experience)

	var priorities: Dictionary = _character_data.build.stat_priority_weights
	for stat_id: StringName in _character_data.base_stats.keys():
		var val: float      = _character_data.base_stats[stat_id]
		var priority: float = priorities.get(stat_id, 0.5)
		_stats_container.add_child(_stat_row(stat_id, val, priority))

func _stat_row(stat_id: StringName, val: float, priority: float) -> VBoxContainer:
	var container := VBoxContainer.new()
	container.add_theme_constant_override("separation", 4)

	# Nombre + valor
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	container.add_child(row)

	var col: Color
	if priority >= 0.8:
		col = C_ACCENT
	elif priority >= 0.4:
		col = C_TEXT
	else:
		col = C_MUTED

	var name_lbl := Label.new()
	name_lbl.text = str(stat_id)
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.add_theme_color_override("font_color", col)
	name_lbl.add_theme_font_size_override("font_size", 13)
	row.add_child(name_lbl)

	var val_lbl := Label.new()
	val_lbl.text = "%.1f" % val
	val_lbl.add_theme_color_override("font_color", C_TEXT)
	val_lbl.add_theme_font_size_override("font_size", 13)
	row.add_child(val_lbl)

	# Barra de progreso (max referencia = 200 al día 100)
	var bar := ProgressBar.new()
	bar.min_value              = 0.0
	bar.max_value              = 200.0
	bar.value                  = val
	bar.show_percentage        = false
	bar.custom_minimum_size.y  = 5

	var fill_sb := StyleBoxFlat.new()
	fill_sb.bg_color = col
	fill_sb.corner_radius_top_left     = 2
	fill_sb.corner_radius_top_right    = 2
	fill_sb.corner_radius_bottom_left  = 2
	fill_sb.corner_radius_bottom_right = 2
	bar.add_theme_stylebox_override("fill", fill_sb)

	var bg_sb := StyleBoxFlat.new()
	bg_sb.bg_color = C_PANEL_ALT
	bg_sb.corner_radius_top_left     = 2
	bg_sb.corner_radius_top_right    = 2
	bg_sb.corner_radius_bottom_left  = 2
	bg_sb.corner_radius_bottom_right = 2
	bar.add_theme_stylebox_override("background", bg_sb)

	container.add_child(bar)
	return container

# ─────────────────────────────────────────────────────────────────────────────
# Utilidades de estilo y layout
# ─────────────────────────────────────────────────────────────────────────────

func _flat_style(color: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	return s

func _style_button_accent(btn: Button) -> void:
	for state in ["normal", "hover", "pressed"]:
		var s := StyleBoxFlat.new()
		s.bg_color = C_ACCENT if state == "normal" else (
			Color(C_ACCENT.r + 0.1, C_ACCENT.g, C_ACCENT.b) if state == "hover" else
			Color(C_ACCENT.r - 0.1, C_ACCENT.g - 0.05, C_ACCENT.b)
		)
		s.corner_radius_top_left     = 4
		s.corner_radius_top_right    = 4
		s.corner_radius_bottom_left  = 4
		s.corner_radius_bottom_right = 4
		s.content_margin_top    = 10
		s.content_margin_bottom = 10
		btn.add_theme_stylebox_override(state, s)
	btn.add_theme_color_override("font_color",         C_BG)
	btn.add_theme_color_override("font_hover_color",   C_BG)
	btn.add_theme_color_override("font_pressed_color", C_BG)

func _section_title(text: String) -> Control:
	var hbox := HBoxContainer.new()
	hbox.add_child(_spacer_h(16))
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_color_override("font_color", C_MUTED)
	lbl.add_theme_font_size_override("font_size", 11)
	hbox.add_child(lbl)
	return hbox

func _spacer_h(width: int) -> Control:
	var s := Control.new()
	s.custom_minimum_size.x = width
	return s

func _spacer_v(height: int) -> Control:
	var s := Control.new()
	s.custom_minimum_size.y = height
	return s

func _spacer_expand() -> Control:
	var s := Control.new()
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return s
