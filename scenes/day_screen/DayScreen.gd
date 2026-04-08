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
var _transforms_container: VBoxContainer
var _allies_container: VBoxContainer
var _radar_chart: Control
var _actions_title: Label
var _actions_container: VBoxContainer
var _result_overlay: PanelContainer
var _result_action_label: Label
var _result_changes_container: VBoxContainer
var _result_xp_label: Label
var _result_narrative_label: Label
var _continue_button: Button

# ── Minijuego activo ───────────────────────────────────────────────────────
var _minigame_overlay: Control = null
var _pending_snake_action: SnakeRoadAction = null
var _pending_snake_km_base: float = 0.0
var _pending_snake_ctx: DayContext = null
var _pending_training_action: DayAction = null
var _active_minigame_id: String = ""   # ID del minijuego activo para récords
var _tier_name_label:  Label
var _tier_sub_label:   Label
var _tier_poder_label: Label
var _tier_bar:         ProgressBar
var _tier_bar_fill_sb: StyleBoxFlat
var _tier_panel_sb:    StyleBoxFlat

# ── Nivel y puntos ──────────────────────────────────────────────────────────
var _level_label:      Label
var _level_bar:        ProgressBar
var _level_bar_sb:     StyleBoxFlat
var _points_badge:     PanelContainer
var _points_count_lbl: Label
var _stat_points_overlay: Control = null

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
	# FIX B2: Reemplaza _find_event_bus() (búsqueda por lista de nombres candidatos)
	# por una referencia directa al nombre canónico del Autoload.
	# Si EventBus no existe bajo este nombre, el assert falla ruidosamente en vez de
	# conectarse silenciosamente al nodo equivocado o no conectarse en absoluto.
	assert(EventBus != null,
		"DayScreen: EventBus no encontrado. Verifica Project Settings → Autoloads.")
	EventBus.day_started.connect(_on_day_started)
	EventBus.day_actions_ready.connect(_on_day_actions_ready)
	EventBus.day_action_resolved.connect(_on_day_action_resolved)
	EventBus.day_ended.connect(_on_day_ended)
	EventBus.game_completed.connect(_on_game_completed)
	if EventBus.has_signal("level_up"):
		EventBus.level_up.connect(_on_level_up)
	if EventBus.has_signal("transformation_unlocked"):
		EventBus.transformation_unlocked.connect(_on_transformation_unlocked)
	if EventBus.has_signal("transformation_mastery_milestone"):
		EventBus.transformation_mastery_milestone.connect(_on_mastery_milestone)
	if EventBus.has_signal("minigame_record_broken"):
		EventBus.minigame_record_broken.connect(_on_minigame_record_broken)
	if EventBus.has_signal("npc_relation_changed"):
		EventBus.npc_relation_changed.connect(_on_npc_relation_changed)

func _on_npc_relation_changed(npc_id: StringName, _old: int, new_state: int, _data) -> void:
	var npc_sys := get_node_or_null("/root/NpcSystem")
	var name_str := str(npc_id)
	var col      := Color(0.90, 0.80, 0.30)
	if npc_sys != null:
		var def = npc_sys.get_definition(npc_id)
		if def != null:
			name_str = def.display_name
			col      = def.color
	match new_state:
		3: _show_unlock_banner("✦ NUEVO ALIADO", name_str, col)
		4: _show_unlock_banner("★ MAESTRO DESBLOQUEADO", name_str, col)
	_refresh_allies()

func _on_minigame_record_broken(_id: String, _old: float, _new: float, _bonuses: Array) -> void:
	# La señal se emite desde MinigameRecordSystem — el banner ya lo muestra
	# _show_record_bonus_banner. Este handler existe para extensibilidad futura.
	_refresh_stats()

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

	# Botón récords
	var rec_btn := Button.new()
	rec_btn.text = "★ RÉCORDS"
	rec_btn.flat = true
	rec_btn.add_theme_font_size_override("font_size", 11)
	rec_btn.add_theme_color_override("font_color", C_MUTED)
	rec_btn.add_theme_color_override("font_hover_color", C_ACCENT)
	rec_btn.pressed.connect(_show_records_overlay)
	hbox.add_child(rec_btn)

	hbox.add_child(_spacer_h(12))

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
	vbox.add_child(_section_title("NIVEL DE PODER"))

	var sep1 := HSeparator.new()
	sep1.add_theme_color_override("color", C_PANEL_ALT)
	vbox.add_child(sep1)

	vbox.add_child(_spacer_v(10))

	# ── Bloque de tier ────────────────────────────────────────────────────
	vbox.add_child(_build_tier_block())

	vbox.add_child(_spacer_v(14))

	var sep2 := HSeparator.new()
	sep2.add_theme_color_override("color", C_PANEL_ALT)
	vbox.add_child(sep2)

	vbox.add_child(_spacer_v(10))
	vbox.add_child(_build_level_block())

	vbox.add_child(_spacer_v(10))

	var sep_lv := HSeparator.new()
	sep_lv.add_theme_color_override("color", C_PANEL_ALT)
	vbox.add_child(sep_lv)

	vbox.add_child(_spacer_v(10))
	vbox.add_child(_section_title("ESTADÍSTICAS"))

	var sep3 := HSeparator.new()
	sep3.add_theme_color_override("color", C_PANEL_ALT)
	vbox.add_child(sep3)

	vbox.add_child(_spacer_v(6))

	# ── Radar chart ──────────────────────────────────────────────────────
	_radar_chart = Control.new()
	_radar_chart.custom_minimum_size = Vector2(208, 180)
	_radar_chart.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_radar_chart.draw.connect(_draw_radar)
	vbox.add_child(_radar_chart)

	# ── Valores numéricos debajo del radar ───────────────────────────────
	_stats_container = VBoxContainer.new()
	_stats_container.add_theme_constant_override("separation", 1)
	_stats_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var stats_wrap2 := HBoxContainer.new()
	stats_wrap2.add_theme_constant_override("separation", 0)
	stats_wrap2.add_child(_spacer_h(12))
	stats_wrap2.add_child(_stats_container)
	stats_wrap2.add_child(_spacer_h(12))
	vbox.add_child(stats_wrap2)

	vbox.add_child(_spacer_v(4))

	_refresh_stats()

	# ── Sección de transformaciones ───────────────────────────────────────
	vbox.add_child(_spacer_v(10))

	var sep_tf := HSeparator.new()
	sep_tf.add_theme_color_override("color", C_PANEL_ALT)
	vbox.add_child(sep_tf)

	vbox.add_child(_spacer_v(10))
	vbox.add_child(_section_title("TRANSFORMACIONES"))

	var sep_tf2 := HSeparator.new()
	sep_tf2.add_theme_color_override("color", C_PANEL_ALT)
	vbox.add_child(sep_tf2)

	vbox.add_child(_spacer_v(8))

	var tf_wrap := HBoxContainer.new()
	tf_wrap.add_theme_constant_override("separation", 0)
	vbox.add_child(tf_wrap)
	tf_wrap.add_child(_spacer_h(16))

	_transforms_container = VBoxContainer.new()
	_transforms_container.add_theme_constant_override("separation", 8)
	_transforms_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tf_wrap.add_child(_transforms_container)
	tf_wrap.add_child(_spacer_h(16))

	vbox.add_child(_spacer_v(12))

	_refresh_transforms()

	# ── Sección de aliados ────────────────────────────────────────────────
	vbox.add_child(_spacer_v(6))

	var sep_al := HSeparator.new()
	sep_al.add_theme_color_override("color", C_PANEL_ALT)
	vbox.add_child(sep_al)

	vbox.add_child(_spacer_v(8))
	vbox.add_child(_section_title("ALIADOS"))

	var sep_al2 := HSeparator.new()
	sep_al2.add_theme_color_override("color", C_PANEL_ALT)
	vbox.add_child(sep_al2)

	vbox.add_child(_spacer_v(8))

	var al_wrap := HBoxContainer.new()
	al_wrap.add_theme_constant_override("separation", 0)
	vbox.add_child(al_wrap)
	al_wrap.add_child(_spacer_h(16))

	_allies_container = VBoxContainer.new()
	_allies_container.add_theme_constant_override("separation", 6)
	_allies_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	al_wrap.add_child(_allies_container)
	al_wrap.add_child(_spacer_h(16))

	vbox.add_child(_spacer_v(12))

	_refresh_allies()
	return panel

## Bloque compacto de nivel y barra de XP.
## Si hay puntos disponibles muestra un badge pulsante para asignarlos.
func _build_level_block() -> Control:
	var wrap := HBoxContainer.new()
	wrap.add_theme_constant_override("separation", 0)
	wrap.add_child(_spacer_h(16))

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 4)
	inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrap.add_child(inner)
	wrap.add_child(_spacer_h(16))

	# Fila: NIVEL X  +  badge de puntos
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	inner.add_child(row)

	_level_label = Label.new()
	_level_label.text = "NIVEL  0"
	_level_label.add_theme_color_override("font_color", C_TEXT)
	_level_label.add_theme_font_size_override("font_size", 14)
	_level_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_level_label)

	# Badge de puntos disponibles (visible solo cuando hay puntos)
	_points_badge = PanelContainer.new()
	_points_badge.visible = false
	var badge_sb := StyleBoxFlat.new()
	badge_sb.bg_color                   = C_POSITIVE
	badge_sb.corner_radius_top_left     = 10
	badge_sb.corner_radius_top_right    = 10
	badge_sb.corner_radius_bottom_left  = 10
	badge_sb.corner_radius_bottom_right = 10
	badge_sb.content_margin_left        = 8
	badge_sb.content_margin_right       = 8
	badge_sb.content_margin_top         = 2
	badge_sb.content_margin_bottom      = 2
	_points_badge.add_theme_stylebox_override("panel", badge_sb)

	var badge_btn := Button.new()
	badge_btn.flat = true
	badge_btn.add_child(_points_badge)
	badge_btn.pressed.connect(_show_stat_points_overlay)
	row.add_child(badge_btn)

	var badge_inner := HBoxContainer.new()
	badge_inner.add_theme_constant_override("separation", 4)
	badge_inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_points_badge.add_child(badge_inner)

	var badge_icon := Label.new()
	badge_icon.text = "▲"
	badge_icon.add_theme_color_override("font_color", C_BG)
	badge_icon.add_theme_font_size_override("font_size", 10)
	badge_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge_inner.add_child(badge_icon)

	_points_count_lbl = Label.new()
	_points_count_lbl.text = "0 pts"
	_points_count_lbl.add_theme_color_override("font_color", C_BG)
	_points_count_lbl.add_theme_font_size_override("font_size", 10)
	_points_count_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge_inner.add_child(_points_count_lbl)

	# Barra de XP
	_level_bar = ProgressBar.new()
	_level_bar.min_value          = 0.0
	_level_bar.max_value          = 1.0
	_level_bar.value              = 0.0
	_level_bar.show_percentage    = false
	_level_bar.custom_minimum_size = Vector2(0, 5)

	_level_bar_sb = StyleBoxFlat.new()
	_level_bar_sb.bg_color                   = C_ACCENT
	_level_bar_sb.corner_radius_top_left     = 2
	_level_bar_sb.corner_radius_top_right    = 2
	_level_bar_sb.corner_radius_bottom_left  = 2
	_level_bar_sb.corner_radius_bottom_right = 2
	_level_bar.add_theme_stylebox_override("fill", _level_bar_sb)

	var bar_bg := StyleBoxFlat.new()
	bar_bg.bg_color                   = C_PANEL_ALT
	bar_bg.corner_radius_top_left     = 2; bar_bg.corner_radius_top_right    = 2
	bar_bg.corner_radius_bottom_left  = 2; bar_bg.corner_radius_bottom_right = 2
	_level_bar.add_theme_stylebox_override("background", bar_bg)
	inner.add_child(_level_bar)

	# Label de XP
	var xp_lbl := Label.new()
	xp_lbl.name = "XpNextLabel"
	xp_lbl.text = ""
	xp_lbl.add_theme_color_override("font_color", C_MUTED)
	xp_lbl.add_theme_font_size_override("font_size", 10)
	inner.add_child(xp_lbl)

	return wrap

## Actualiza el bloque de nivel con los datos actuales.
func _refresh_level() -> void:
	if _character_data == null or _level_label == null:
		return
	var lvl:  int   = _character_data.get("level") if _character_data.get("level") != null else 0
	var pts:  int   = _character_data.get("stat_points_available") if _character_data.get("stat_points_available") != null else 0
	var prog: float = _character_data.level_progress() if _character_data.has_method("level_progress") else 0.0
	var xp_next: float = _character_data.xp_to_next_level() if _character_data.has_method("xp_to_next_level") else 0.0

	_level_label.text = "NIVEL  %d" % lvl
	_level_bar.value  = prog

	# Badge de puntos
	if pts > 0:
		_points_badge.visible    = true
		_points_count_lbl.text   = "%d pt%s" % [pts, "s" if pts > 1 else ""]
		# Animación de pulso
		var tween := create_tween()
		tween.set_loops(0)
		tween.tween_property(_points_badge, "modulate:a", 0.6, 0.6)
		tween.tween_property(_points_badge, "modulate:a", 1.0, 0.6)
	else:
		_points_badge.visible = false

	# Label "Siguiente nivel en X XP"
	var xp_lbl := _level_label.get_parent().get_node_or_null("XpNextLabel") as Label
	if xp_lbl:
		xp_lbl.text = "Siguiente nivel: %.0f XP" % maxf(xp_next, 0.0)

# ── Overlay de asignación de puntos ──────────────────────────────────────────

func _show_stat_points_overlay() -> void:
	if _stat_points_overlay != null:
		return  # Ya visible

	var pts: int = _character_data.get("stat_points_available") if \
		_character_data.get("stat_points_available") != null else 0
	if pts <= 0:
		return

	var overlay := PanelContainer.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	var ov_bg := StyleBoxFlat.new()
	ov_bg.bg_color = Color(0, 0, 0, 0.65)
	overlay.add_theme_stylebox_override("panel", ov_bg)
	_stat_points_overlay = overlay
	add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(340, 0)
	var card_sb := StyleBoxFlat.new()
	card_sb.bg_color                   = C_PANEL
	card_sb.corner_radius_top_left     = 8; card_sb.corner_radius_top_right    = 8
	card_sb.corner_radius_bottom_left  = 8; card_sb.corner_radius_bottom_right = 8
	card_sb.border_width_top           = 2
	card_sb.border_color               = C_POSITIVE
	card.add_theme_stylebox_override("panel", card_sb)
	center.add_child(card)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	card.add_child(vbox)

	vbox.add_child(_spacer_v(20))

	var title := Label.new()
	title.text                 = "¡SUBISTE DE NIVEL!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", C_POSITIVE)
	title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title)

	vbox.add_child(_spacer_v(6))

	var pts_lbl := Label.new()
	pts_lbl.name               = "PtsRemaining"
	pts_lbl.text               = "%d punto%s disponible%s" % [pts, "s" if pts > 1 else "", "s" if pts > 1 else ""]
	pts_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pts_lbl.add_theme_color_override("font_color", C_ACCENT)
	pts_lbl.add_theme_font_size_override("font_size", 13)
	vbox.add_child(pts_lbl)

	vbox.add_child(_spacer_v(16))

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", C_PANEL_ALT)
	vbox.add_child(sep)

	vbox.add_child(_spacer_v(12))

	# Una fila por cada stat
	const STAT_LABELS_SP: Dictionary = {
		&"fuerza": "Fuerza", &"velocidad": "Velocidad", &"ki": "Ki",
		&"vitalidad": "Vitalidad", &"resistencia": "Resistencia",
		&"poder_ki": "Control Ki", &"inteligencia": "Inteligencia",
		&"intel_combate": "Int. Combate",
	}
	const STAT_ICONS_SP: Dictionary = {
		&"fuerza": "⚔", &"velocidad": "▶", &"ki": "✦", &"vitalidad": "♥",
		&"resistencia": "🛡", &"poder_ki": "◈", &"inteligencia": "◆", &"intel_combate": "⚡",
	}

	for stat_id: StringName in [&"fuerza", &"velocidad", &"ki", &"vitalidad",
			&"resistencia", &"poder_ki", &"inteligencia", &"intel_combate"]:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		row.add_child(_spacer_h(16))

		var icon := Label.new()
		icon.text = STAT_ICONS_SP.get(stat_id, "·")
		icon.add_theme_color_override("font_color", C_MUTED)
		icon.add_theme_font_size_override("font_size", 13)
		row.add_child(icon)

		var name_lbl := Label.new()
		name_lbl.text                  = STAT_LABELS_SP.get(stat_id, str(stat_id))
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.add_theme_color_override("font_color", C_TEXT)
		name_lbl.add_theme_font_size_override("font_size", 13)
		row.add_child(name_lbl)

		var val_lbl := Label.new()
		val_lbl.text = "%.1f" % _character_data.base_stats.get(stat_id, 0.0)
		val_lbl.add_theme_color_override("font_color", C_MUTED)
		val_lbl.add_theme_font_size_override("font_size", 12)
		row.add_child(val_lbl)

		var plus_btn := Button.new()
		plus_btn.text                = "+1"
		plus_btn.custom_minimum_size = Vector2(48, 32)
		plus_btn.add_theme_font_size_override("font_size", 13)

		var plus_sb := StyleBoxFlat.new()
		plus_sb.bg_color                   = C_POSITIVE.lerp(C_BG, 0.7)
		plus_sb.border_color               = C_POSITIVE
		plus_sb.border_width_bottom        = 2
		plus_sb.corner_radius_top_left     = 4; plus_sb.corner_radius_top_right    = 4
		plus_sb.corner_radius_bottom_left  = 4; plus_sb.corner_radius_bottom_right = 4
		plus_btn.add_theme_stylebox_override("normal", plus_sb)
		plus_btn.add_theme_color_override("font_color", C_POSITIVE.lerp(C_TEXT, 0.4))

		plus_btn.pressed.connect(_on_stat_point_assigned.bind(stat_id, card))
		row.add_child(plus_btn)
		row.add_child(_spacer_h(16))

		vbox.add_child(row)

	vbox.add_child(_spacer_v(16))

	var close_btn := Button.new()
	close_btn.text                = "Asignar después"
	close_btn.custom_minimum_size = Vector2(0, 36)
	var close_row := HBoxContainer.new()
	close_row.add_child(_spacer_expand())
	close_row.add_child(close_btn)
	close_row.add_child(_spacer_expand())
	vbox.add_child(close_row)

	close_btn.add_theme_color_override("font_color", C_MUTED)
	close_btn.add_theme_font_size_override("font_size", 12)
	close_btn.pressed.connect(_close_stat_points_overlay)

	vbox.add_child(_spacer_v(16))

func _on_stat_point_assigned(stat_id: StringName, card: PanelContainer) -> void:
	var pts: int = _character_data.get("stat_points_available") if \
		_character_data.get("stat_points_available") != null else 0
	if pts <= 0:
		return

	# Aplicar +1 al stat
	var current: float = _character_data.base_stats.get(stat_id, 0.0)
	_character_data.base_stats[stat_id] = snappedf(current + 1.0, 0.1)
	_character_data.stat_points_available = pts - 1

	# Actualizar label de puntos restantes
	var pts_lbl := card.get_node_or_null("%PtsRemaining") as Label
	var new_pts: int = _character_data.stat_points_available
	if pts_lbl:
		pts_lbl.text = "%d punto%s disponible%s" % [new_pts, "s" if new_pts > 1 else "", "s" if new_pts > 1 else ""]

	_refresh_stats()

	if new_pts <= 0:
		_close_stat_points_overlay()

func _close_stat_points_overlay() -> void:
	if _stat_points_overlay:
		_stat_points_overlay.queue_free()
		_stat_points_overlay = null
	_refresh_level()

# ── Bloque de tier ─────────────────────────────────────────────────────────
#
# Muestra:
#   - Nombre del tier (grande, coloreado con el color del tier)
#   - Sub-label estilo VS Battles (flavor text pequeño y muted)
#   - Número de poder total
#   - Barra de progreso hacia el siguiente tier (coloreada igual)
#   - Indicador de tier actual / total ("3 / 8")
#
# Todos los nodos que necesitan actualizarse se guardan en variables de instancia.
# _refresh_tier() los actualiza sin reconstruir el árbol de nodos.

func _build_tier_block() -> Control:
	var wrap := HBoxContainer.new()
	wrap.add_theme_constant_override("separation", 0)

	wrap.add_child(_spacer_h(16))

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 6)
	inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrap.add_child(inner)

	wrap.add_child(_spacer_h(16))

	# ── Fila nombre + índice ─────────────────────────────────────────────
	var name_row := HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 6)
	inner.add_child(name_row)

	_tier_name_label = Label.new()
	_tier_name_label.text = "—"
	_tier_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tier_name_label.add_theme_font_size_override("font_size", 20)
	_tier_name_label.add_theme_color_override("font_color", C_ACCENT)
	name_row.add_child(_tier_name_label)

	var index_label := Label.new()
	index_label.name = "TierIndexLabel"
	index_label.text = ""
	index_label.add_theme_font_size_override("font_size", 11)
	index_label.add_theme_color_override("font_color", C_MUTED)
	index_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	name_row.add_child(index_label)

	# ── Sub-label VS Battles ─────────────────────────────────────────────
	_tier_sub_label = Label.new()
	_tier_sub_label.text = ""
	_tier_sub_label.add_theme_font_size_override("font_size", 11)
	_tier_sub_label.add_theme_color_override("font_color", C_MUTED)
	inner.add_child(_tier_sub_label)

	# ── Barra de progreso ────────────────────────────────────────────────
	_tier_bar = ProgressBar.new()
	_tier_bar.min_value           = 0.0
	_tier_bar.max_value           = 1.0
	_tier_bar.value               = 0.0
	_tier_bar.show_percentage     = false
	_tier_bar.custom_minimum_size = Vector2(0, 8)

	_tier_bar_fill_sb = StyleBoxFlat.new()
	_tier_bar_fill_sb.bg_color                   = C_ACCENT
	_tier_bar_fill_sb.corner_radius_top_left     = 3
	_tier_bar_fill_sb.corner_radius_top_right    = 3
	_tier_bar_fill_sb.corner_radius_bottom_left  = 3
	_tier_bar_fill_sb.corner_radius_bottom_right = 3
	_tier_bar.add_theme_stylebox_override("fill", _tier_bar_fill_sb)

	var bar_bg := StyleBoxFlat.new()
	bar_bg.bg_color                   = C_PANEL_ALT
	bar_bg.corner_radius_top_left     = 3
	bar_bg.corner_radius_top_right    = 3
	bar_bg.corner_radius_bottom_left  = 3
	bar_bg.corner_radius_bottom_right = 3
	_tier_bar.add_theme_stylebox_override("background", bar_bg)

	inner.add_child(_tier_bar)

	# ── Fila poder + siguiente tier ──────────────────────────────────────
	var poder_row := HBoxContainer.new()
	poder_row.add_theme_constant_override("separation", 0)
	inner.add_child(poder_row)

	_tier_poder_label = Label.new()
	_tier_poder_label.text = "Poder: —"
	_tier_poder_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tier_poder_label.add_theme_font_size_override("font_size", 11)
	_tier_poder_label.add_theme_color_override("font_color", C_TEXT)
	poder_row.add_child(_tier_poder_label)

	var next_label := Label.new()
	next_label.name = "TierNextLabel"
	next_label.text = ""
	next_label.add_theme_font_size_override("font_size", 11)
	next_label.add_theme_color_override("font_color", C_MUTED)
	poder_row.add_child(next_label)

	return wrap

## Actualiza todos los nodos del bloque de tier con los datos actuales.
func _refresh_tier() -> void:
	if _character_data == null or _tier_name_label == null:
		return

	var d: Dictionary = _character_data.get_tier_data()
	var col: Color    = d["color"]

	# Nombre y color
	_tier_name_label.text = d["name"].to_upper()
	_tier_name_label.add_theme_color_override("font_color", col)

	# Sub-label
	_tier_sub_label.text = d["sub_label"]
	_tier_sub_label.add_theme_color_override("font_color", col.lerp(C_MUTED, 0.5))

	# Poder
	_tier_poder_label.text = "Poder: %d" % int(d["poder"])

	# Índice de tier
	var index_lbl := _tier_name_label.get_parent().get_node_or_null("TierIndexLabel") as Label
	if index_lbl:
		index_lbl.text = "%d / %d" % [d["index"] + 1, d["total"]]

	# Barra de progreso
	_tier_bar.value           = d["progress"]
	_tier_bar_fill_sb.bg_color = col

	# Label "siguiente tier"
	var next_lbl := _tier_poder_label.get_parent().get_node_or_null("TierNextLabel") as Label
	if next_lbl:
		if d["is_max"]:
			next_lbl.text = "TIER MÁXIMO"
			next_lbl.add_theme_color_override("font_color", col)
		else:
			var needed: int = int(d["tier_max"] - d["poder"])
			next_lbl.text = "Siguiente: %d" % needed
			next_lbl.add_theme_color_override("font_color", C_MUTED)

	# Animación de pulso al subir de tier — el nombre destella con el color
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(_tier_name_label, "modulate",
		Color(col.r, col.g, col.b, 1.4), 0.12)
	tween.tween_property(_tier_name_label, "modulate", Color.WHITE, 0.20)

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

func _on_day_action_resolved(action, result) -> void:
	_state = State.SHOWING_RESULT
	_show_result(action, result)

func _on_day_ended(_day_number: int, _result) -> void:
	_mark_actions_seen()
	_refresh_stats()

func _on_game_completed(_final_data) -> void:
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

	# Definición de secciones: id interno → [label UI, color acento, orden]
	# El orden determina en qué posición aparece cada sección.
	const SECTION_DEFS: Dictionary = {
		&"maestro":  ["✦  MAESTROS",      Color(1.00, 0.78, 0.10), 0],
		&"training": ["▲  ENTRENAMIENTO", Color(0.28, 0.85, 0.44), 1],
		&"event":    ["⚠  EVENTOS",       Color(0.94, 0.62, 0.15), 2],
		&"combat":   ["⚠  EVENTOS",       Color(0.94, 0.62, 0.15), 2],
	}

	# Agrupar acciones por categoría efectiva
	var groups: Dictionary = {}
	for action: DayAction in _available_actions:
		# get_display_category() existe en el DayAction nuevo.
		# Fallback a action_type para compatibilidad con el DayAction viejo.
		var cat: StringName
		if action.has_method("get_display_category"):
			cat = action.get_display_category()
		else:
			var dc = action.get("display_category")
			cat = dc if dc != null and dc != &"" else action.action_type
		# Normalizar: combat y event van al mismo bucket visualmente
		if cat == &"combat":
			cat = &"event"
		if not groups.has(cat):
			groups[cat] = []
		groups[cat].append(action)

	# Ordenar categorías según SECTION_DEFS, desconocidas al final
	var sorted_cats: Array = groups.keys()
	sorted_cats.sort_custom(func(a, b):
		var oa: int = SECTION_DEFS.get(a, ["", Color.WHITE, 99])[2]
		var ob: int = SECTION_DEFS.get(b, ["", Color.WHITE, 99])[2]
		return oa < ob
	)

	# Construir cada sección
	for cat: StringName in sorted_cats:
		var actions_in_cat: Array = groups[cat]
		if actions_in_cat.is_empty():
			continue
		var def: Array = SECTION_DEFS.get(cat, [str(cat).to_upper(), C_MUTED, 99])
		_actions_container.add_child(
			_build_section(def[0], def[1], actions_in_cat, ctx)
		)

	# Marcar acciones como vistas al final del día (via _on_day_ended)
	# No marcamos aquí para que el badge dure mientras elegís

func _clear_action_buttons() -> void:
	for child in _actions_container.get_children():
		child.queue_free()

## Construye una sección colapsable con su header y cards de acciones.
func _build_section(label: String, accent: Color,
		actions: Array, ctx: DayContext) -> VBoxContainer:

	var section := VBoxContainer.new()
	section.add_theme_constant_override("separation", 0)
	section.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# ── Header colapsable ──────────────────────────────────────────────
	var header_btn := Button.new()
	header_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_btn.custom_minimum_size.y = 28

	var header_style := StyleBoxFlat.new()
	header_style.bg_color                   = C_PANEL_ALT
	header_style.corner_radius_top_left     = 4
	header_style.corner_radius_top_right    = 4
	header_style.corner_radius_bottom_left  = 0
	header_style.corner_radius_bottom_right = 0
	header_style.content_margin_left        = 12
	header_style.content_margin_right       = 12
	header_style.content_margin_top         = 6
	header_style.content_margin_bottom      = 6
	for s in ["normal", "hover", "pressed", "focus"]:
		header_btn.add_theme_stylebox_override(s, header_style)

	var header_inner := HBoxContainer.new()
	header_inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header_inner.set_anchors_preset(Control.PRESET_FULL_RECT)
	header_inner.add_theme_constant_override("separation", 6)
	header_btn.add_child(header_inner)

	var header_lbl := Label.new()
	header_lbl.text = label
	header_lbl.add_theme_color_override("font_color", accent)
	header_lbl.add_theme_font_size_override("font_size", 11)
	header_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header_inner.add_child(header_lbl)

	var count_lbl := Label.new()
	count_lbl.text = str(actions.size())
	count_lbl.add_theme_color_override("font_color", C_MUTED)
	count_lbl.add_theme_font_size_override("font_size", 11)
	count_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header_inner.add_child(count_lbl)

	var arrow_lbl := Label.new()
	arrow_lbl.text = "▾"
	arrow_lbl.add_theme_color_override("font_color", C_MUTED)
	arrow_lbl.add_theme_font_size_override("font_size", 11)
	arrow_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header_inner.add_child(arrow_lbl)

	section.add_child(header_btn)

	# ── Contenido (cards) ──────────────────────────────────────────────
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 4)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var content_wrap_style := StyleBoxFlat.new()
	content_wrap_style.bg_color                   = Color(C_PANEL.r, C_PANEL.g, C_PANEL.b, 0.5)
	content_wrap_style.border_width_left           = 2
	content_wrap_style.border_color                = accent.lerp(C_PANEL_ALT, 0.6)
	content_wrap_style.corner_radius_bottom_left   = 4
	content_wrap_style.corner_radius_bottom_right  = 4
	content_wrap_style.content_margin_left         = 8
	content_wrap_style.content_margin_right        = 8
	content_wrap_style.content_margin_top          = 6
	content_wrap_style.content_margin_bottom       = 8

	var content_panel := PanelContainer.new()
	content_panel.add_theme_stylebox_override("panel", content_wrap_style)
	content_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_panel.add_child(content)
	section.add_child(content_panel)

	for action: DayAction in actions:
		content.add_child(_build_action_card(action, ctx))

	# Espaciado entre secciones
	section.add_child(_spacer_v(6))

	# Toggle colapso
	header_btn.pressed.connect(func():
		var is_visible: bool = not content_panel.visible
		content_panel.visible = is_visible
		arrow_lbl.text = "▾" if is_visible else "▸"
	)

	return section

func _build_action_card(action: DayAction, ctx: DayContext) -> Button:
	var is_risky := action is EventAction or action is CombatEventAction
	var seen: Array = _character_data.get("seen_action_ids") if _character_data.get("seen_action_ids") != null else []
	var is_new: bool = not (action.id in seen)

	var btn := Button.new()
	btn.custom_minimum_size.y = 56
	btn.size_flags_horizontal  = Control.SIZE_EXPAND_FILL
	btn.clip_contents          = false

	var normal := StyleBoxFlat.new()
	normal.bg_color             = C_PANEL
	normal.border_width_left    = 3
	normal.border_color         = C_EVENT if is_risky else (C_ACCENT if is_new else C_PANEL_ALT)
	normal.corner_radius_top_left     = 4
	normal.corner_radius_top_right    = 4
	normal.corner_radius_bottom_left  = 4
	normal.corner_radius_bottom_right = 4
	normal.content_margin_left   = 12
	normal.content_margin_right  = 12
	normal.content_margin_top    = 8
	normal.content_margin_bottom = 8
	btn.add_theme_stylebox_override("normal", normal)

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color     = C_PANEL_ALT
	hover.border_color = C_ACCENT if not is_risky else C_EVENT
	btn.add_theme_stylebox_override("hover", hover)

	var pressed_sb := normal.duplicate() as StyleBoxFlat
	pressed_sb.bg_color = Color(0.20, 0.20, 0.26)
	btn.add_theme_stylebox_override("pressed", pressed_sb)

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 2)
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.set_anchors_preset(Control.PRESET_FULL_RECT)
	btn.add_child(inner)

	# ── Fila superior: nombre + badge NUEVO ───────────────────────────
	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 6)
	top_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.add_child(top_row)

	if is_risky:
		var icon := Label.new()
		icon.text = "⚠"
		icon.add_theme_color_override("font_color", C_EVENT)
		icon.add_theme_font_size_override("font_size", 12)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		top_row.add_child(icon)

	var name_lbl := Label.new()
	name_lbl.text = action.display_name
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.add_theme_color_override("font_color", C_TEXT)
	name_lbl.add_theme_font_size_override("font_size", 13)
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_row.add_child(name_lbl)

	if is_new:
		var new_badge := Label.new()
		new_badge.text = " NUEVO "
		new_badge.add_theme_color_override("font_color", C_BG)
		new_badge.add_theme_font_size_override("font_size", 10)
		new_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var badge_sb := StyleBoxFlat.new()
		badge_sb.bg_color                   = C_ACCENT
		badge_sb.corner_radius_top_left     = 3
		badge_sb.corner_radius_top_right    = 3
		badge_sb.corner_radius_bottom_left  = 3
		badge_sb.corner_radius_bottom_right = 3
		new_badge.add_theme_stylebox_override("normal", badge_sb)
		top_row.add_child(new_badge)

	# ── Fila inferior: stats afectados (solo TrainingAction) ──────────
	if action is TrainingAction:
		var stats_lbl := Label.new()
		var target := (action as TrainingAction).target_stats
		var stats_str := "  ".join(target.map(func(s): return str(s)))
		stats_lbl.text = stats_str
		stats_lbl.add_theme_color_override("font_color", C_MUTED)
		stats_lbl.add_theme_font_size_override("font_size", 10)
		stats_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		inner.add_child(stats_lbl)

	btn.pressed.connect(_on_action_selected.bind(action))
	return btn

func _on_action_selected(action: DayAction) -> void:
	if _state != State.SHOWING_ACTIONS:
		return
	_state = State.WAITING
	# Deshabilitar todos los botones mientras se resuelve.
	for section in _actions_container.get_children():
		for child in section.get_children():
			if child is Button:
				(child as Button).disabled = true
			elif child is PanelContainer:
				for card in child.get_children():
					for btn in card.get_children():
						if btn is Button:
							(btn as Button).disabled = true

	# ── TrainingAction con minijuego ───────────────────────────────────────
	if action is TrainingAction:
		var ta := action as TrainingAction
		if ta.has_method("get") and ta.get("has_minigame") == true:
			_pending_training_action = action
			_show_training_minigame(ta)
			return  # DayManager.execute_action se llama desde el callback

	# ── SnakeRoadAction ────────────────────────────────────────────────────
	if action is SnakeRoadAction:
		var snake := action as SnakeRoadAction
		if not snake.minigame_requested.is_connected(_on_snake_minigame_requested):
			snake.minigame_requested.connect(_on_snake_minigame_requested.bind(snake))

	DayManager.execute_action(action)

## Selecciona y muestra el minijuego correcto según el stat primario de la acción.
## DirectionalMinigame cubre fuerza/velocidad/resistencia con modos distintos.
func _show_training_minigame(action: TrainingAction) -> void:
	var target: Array[StringName] = action.target_stats \
		if action.get("target_stats") != null else []
	var primary: StringName = target[0] if not target.is_empty() else &"vitalidad"

	var mg: Control
	match primary:
		&"fuerza":
			var m := DirectionalStrikeMinigame.new()
			m.setup(action.display_name, target, "fuerza")
			mg = m
		&"velocidad":
			var m := DirectionalStrikeMinigame.new()
			m.setup(action.display_name, target, "velocidad")
			mg = m
		&"resistencia":
			var m := DirectionalStrikeMinigame.new()
			m.setup(action.display_name, target, "resistencia")
			mg = m
		&"ki", &"poder_ki":
			var m := KiChannelMinigame.new()
			m.setup(action.display_name, target)
			mg = m
		&"intel_combate", &"inteligencia":
			var m := SequenceMinigame.new()
			m.setup(action.display_name, target)
			mg = m
		_:
			var m := TrainingMinigame.new()
			m.setup(action.display_name, target)
			mg = m

	mg.set_anchors_preset(Control.PRESET_FULL_RECT)
	mg.completed.connect(_on_training_minigame_completed)
	_minigame_overlay = mg

	# Guardar ID para el sistema de récords
	_active_minigame_id = _minigame_id_for_stat(primary)

	add_child(mg)

## Convierte el stat primario al ID de minijuego para el sistema de récords.
func _minigame_id_for_stat(stat: StringName) -> String:
	match stat:
		&"fuerza":       return "directional_strike"
		&"resistencia":  return "apple"
		&"velocidad":    return "dodge"
		&"ki", &"poder_ki": return "ki_channel"
		&"intel_combate", &"inteligencia": return "sequence"
		_:               return "training_sync"

## Recibe el multiplicador del minijuego de entrenamiento.
func _on_training_minigame_completed(multiplier: float) -> void:
	if _minigame_overlay:
		_minigame_overlay.queue_free()
		_minigame_overlay = null

	# Guardar récord — convertir multiplier (0.5–2.0) a score (0–100)
	var score_pct: float = clampf((multiplier - 0.5) / 1.5 * 100.0, 0.0, 100.0)
	var rec_node := get_node_or_null("/root/MinigameRecordSystem")
	if rec_node != null and _active_minigame_id != "" and _character_data != null:
		var bonuses: Array = rec_node.save_score(_active_minigame_id, score_pct, _character_data)
		if not bonuses.is_empty():
			_show_record_bonus_banner(_active_minigame_id, score_pct, bonuses)
	_active_minigame_id = ""

	if _pending_training_action == null:
		return

	if DayManager.get("pending_training_multiplier") != null:
		DayManager.pending_training_multiplier = multiplier

	var action := _pending_training_action
	_pending_training_action = null
	DayManager.execute_action(action)

## Banner de bonus de récord — aparece sobre todo.
func _show_record_bonus_banner(minigame_id: String, score: float, bonuses: Array) -> void:
	var banner := PanelContainer.new()
	banner.set_anchors_preset(Control.PRESET_TOP_WIDE)
	banner.custom_minimum_size.y = 80
	var sb := StyleBoxFlat.new()
	sb.bg_color           = Color(0.10, 0.08, 0.02, 0.95)
	sb.border_color       = C_ACCENT
	sb.border_width_bottom = 3
	banner.add_theme_stylebox_override("panel", sb)
	add_child(banner)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	banner.add_child(vbox)

	var h := Label.new()
	h.text = "★ NUEVO RÉCORD — %.0f%%" % score
	h.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	h.add_theme_color_override("font_color", C_ACCENT)
	h.add_theme_font_size_override("font_size", 13)
	vbox.add_child(h)

	# Mostrar bonuses
	var bonus_parts: Array[String] = []
	for b in bonuses:
		bonus_parts.append("%s +%.1f" % [str(b.stat_id), b.delta])
	var n := Label.new()
	n.text = "  ·  ".join(bonus_parts)
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	n.add_theme_color_override("font_color", C_POSITIVE)
	n.add_theme_font_size_override("font_size", 16)
	vbox.add_child(n)

	var sub := Label.new()
	sub.text = "Bonus permanente aplicado"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_color_override("font_color", C_MUTED)
	sub.add_theme_font_size_override("font_size", 10)
	vbox.add_child(sub)

	banner.modulate.a = 0.0
	var t := create_tween()
	t.set_trans(Tween.TRANS_SINE)
	t.tween_property(banner, "modulate:a", 1.0, 0.3)
	t.tween_interval(3.0)
	t.tween_property(banner, "modulate:a", 0.0, 0.5)
	t.tween_callback(banner.queue_free)

## Recibe la señal de SnakeRoadAction y muestra el minijuego.
func _on_snake_minigame_requested(km_base: float, current_km: float,
		action: SnakeRoadAction) -> void:
	_pending_snake_action  = action
	_pending_snake_km_base = km_base
	_pending_snake_ctx     = DayContext.create(_character_data)

	var mg := SnakeRoadMinigame.new()
	mg.set_script(load("res://scenes/minigames/SnakeRoadMinigame.gd"))
	mg.set_anchors_preset(Control.PRESET_FULL_RECT)
	mg.setup(
		_character_data.base_stats.get(&"intel_combate", 0.0),
		km_base,
		current_km,
		1_000_000.0
	)
	mg.completed.connect(_on_snake_minigame_completed)
	_minigame_overlay = mg
	add_child(mg)

## Recibe el multiplicador del minijuego y resuelve la acción.
func _on_snake_minigame_completed(multiplier: float) -> void:
	if _minigame_overlay:
		_minigame_overlay.queue_free()
		_minigame_overlay = null

	# Guardar récord del Camino de la Serpiente
	var score_pct: float = clampf((multiplier - 0.5) / 1.5 * 100.0, 0.0, 100.0)
	var rec_node := get_node_or_null("/root/MinigameRecordSystem")
	if rec_node != null and _character_data != null:
		var bonuses: Array = rec_node.save_score("snake_road", score_pct, _character_data)
		if not bonuses.is_empty():
			_show_record_bonus_banner("snake_road", score_pct, bonuses)

	if _pending_snake_action == null:
		return

	var result := _pending_snake_action.resolve_with_multiplier(
		_pending_snake_ctx, multiplier, _pending_snake_km_base
	)
	_pending_snake_action = null
	_pending_snake_ctx    = null

	_state = State.SHOWING_RESULT
	_show_result(_pending_snake_action if _pending_snake_action else DayAction.new(), result)

## Marca todas las acciones actuales como vistas.
## Llamado por _on_day_ended para que el badge dure un día completo.
func _mark_actions_seen() -> void:
	if _character_data == null:
		return
	if _character_data.get("seen_action_ids") == null:
		return  # CharacterData viejo sin el campo — no hacer nada
	for action: DayAction in _available_actions:
		if not (action.id in _character_data.seen_action_ids):
			_character_data.seen_action_ids.append(action.id)

# ─────────────────────────────────────────────────────────────────────────────
# Panel de resultado
# ─────────────────────────────────────────────────────────────────────────────

func _show_result(action, result) -> void:
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

	# Cita del NPC (si el resultado viene de NpcTrainingAction)
	var quote: String = result.extra_data.get("npc_quote", "")
	if not quote.is_empty():
		var npc_name: String = result.extra_data.get("npc_name", "")
		var npc_col: Color   = result.extra_data.get("npc_color", C_MUTED)
		_result_narrative_label.text = "\"%s\"\n— %s" % [quote, npc_name]
		_result_narrative_label.add_theme_color_override("font_color", npc_col)
	else:
		_result_narrative_label.text = result.narrative_key.replace(".", "  ·  ").replace("_", " ")
		_result_narrative_label.add_theme_color_override("font_color", C_MUTED)

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

func _on_level_up(_new_level: int, _levels_gained: int) -> void:
	_refresh_level()
	var tween := create_tween()
	tween.tween_interval(0.8)
	tween.tween_callback(_show_stat_points_overlay)

func _on_transformation_unlocked(transform_id: StringName, _char_data) -> void:
	var name_str := str(transform_id)
	var color    := Color(1.0, 0.85, 0.10)
	var tr_node  := get_node_or_null("/root/TransformationRegistry")
	if tr_node != null:
		var def = tr_node.get_definition(transform_id)
		if def != null:
			name_str = def.display_name
			color    = def.aura_color
	_show_unlock_banner("✦ TRANSFORMACIÓN DESBLOQUEADA", name_str, color)
	_refresh_transforms()

func _on_mastery_milestone(transform_id: StringName, new_mastery: float) -> void:
	var tr_node := get_node_or_null("/root/TransformationRegistry")
	var name_str := str(transform_id)
	if tr_node != null:
		var def = tr_node.get_definition(transform_id)
		if def != null:
			name_str = def.display_name
	var pct := int(new_mastery * 100.0)
	_show_unlock_banner("★ MAESTRÍA ALCANZADA", "%s  —  %d%%" % [name_str, pct],
		Color(0.80, 0.95, 1.00))
	_refresh_transforms()

## Reconstruye las cards de transformaciones desbloqueadas.
func _refresh_transforms() -> void:
	if _transforms_container == null or _character_data == null:
		return
	for child in _transforms_container.get_children():
		child.queue_free()

	var ts = _character_data.get("transformation_state")
	var tr_node := get_node_or_null("/root/TransformationRegistry")

	# Sin transformaciones desbloqueadas
	if ts == null or ts.unlocked_ids.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "Ninguna desbloqueada aún"
		empty_lbl.add_theme_color_override("font_color", C_MUTED)
		empty_lbl.add_theme_font_size_override("font_size", 11)
		_transforms_container.add_child(empty_lbl)
		return

	for transform_id: StringName in ts.unlocked_ids:
		var mastery: float = ts.get_mastery(transform_id)
		var def = tr_node.get_definition(transform_id) if tr_node != null else null
		_transforms_container.add_child(
			_build_transform_card(transform_id, mastery, def)
		)

## Construye una card compacta para una transformación.
func _build_transform_card(transform_id: StringName, mastery: float, def) -> VBoxContainer:
	var card := VBoxContainer.new()
	card.add_theme_constant_override("separation", 4)

	# Nombre + color de aura
	var name_str: String = def.display_name if def != null else str(transform_id)
	var aura_col: Color  = def.aura_color   if def != null else Color(1.0, 0.85, 0.1)

	var name_row := HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 6)
	card.add_child(name_row)

	# Indicador de color de aura
	var dot := Label.new()
	dot.text = "◆"
	dot.add_theme_color_override("font_color", aura_col)
	dot.add_theme_font_size_override("font_size", 10)
	name_row.add_child(dot)

	var name_lbl := Label.new()
	name_lbl.text = name_str
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.add_theme_color_override("font_color", C_TEXT)
	name_lbl.add_theme_font_size_override("font_size", 12)
	name_row.add_child(name_lbl)

	# Porcentaje de maestría
	var pct_lbl := Label.new()
	pct_lbl.text = "%.0f%%" % (mastery * 100.0)
	pct_lbl.add_theme_color_override("font_color", aura_col if mastery >= 1.0 else C_MUTED)
	pct_lbl.add_theme_font_size_override("font_size", 11)
	name_row.add_child(pct_lbl)

	# Barra de maestría
	var bar := ProgressBar.new()
	bar.min_value            = 0.0
	bar.max_value            = 1.0
	bar.value                = mastery
	bar.show_percentage      = false
	bar.custom_minimum_size  = Vector2(0, 5)

	var fill_sb := StyleBoxFlat.new()
	fill_sb.bg_color = aura_col
	fill_sb.corner_radius_top_left     = 2; fill_sb.corner_radius_top_right    = 2
	fill_sb.corner_radius_bottom_left  = 2; fill_sb.corner_radius_bottom_right = 2
	bar.add_theme_stylebox_override("fill", fill_sb)

	var bg_sb := StyleBoxFlat.new()
	bg_sb.bg_color = C_PANEL_ALT
	bg_sb.corner_radius_top_left     = 2; bg_sb.corner_radius_top_right    = 2
	bg_sb.corner_radius_bottom_left  = 2; bg_sb.corner_radius_bottom_right = 2
	bar.add_theme_stylebox_override("background", bg_sb)
	card.add_child(bar)

	# Label de estado
	var state_lbl := Label.new()
	if mastery >= 1.0:
		state_lbl.text = "★ Maestría completa"
		state_lbl.add_theme_color_override("font_color", aura_col)
	elif mastery >= 0.75:
		state_lbl.text = "Avanzado  —  drenaje -%.0f%%" % ((1.0 - _drain_ratio(def, mastery)) * 100.0)
		state_lbl.add_theme_color_override("font_color", C_TEXT)
	elif mastery >= 0.50:
		state_lbl.text = "Intermedio  —  entrenamiento pesado activo" if def != null and def.has_heavy_training(mastery) else "Intermedio"
		state_lbl.add_theme_color_override("font_color", C_TEXT)
	elif mastery >= 0.25:
		state_lbl.text = "Básico  —  drawbacks completos"
		state_lbl.add_theme_color_override("font_color", C_MUTED)
	else:
		state_lbl.text = "Iniciando — control mínimo"
		state_lbl.add_theme_color_override("font_color", C_MUTED)
	state_lbl.add_theme_font_size_override("font_size", 10)
	card.add_child(state_lbl)

	return card

func _drain_ratio(def, mastery: float) -> float:
	if def == null:
		return 1.0
	var min_r: float = def.get("mastery_min_drain_ratio") if def.get("mastery_min_drain_ratio") != null else 0.25
	return lerpf(1.0, min_r, mastery)

## Reconstruye las cards de aliados activos.
func _refresh_allies() -> void:
	if _allies_container == null or _character_data == null:
		return
	for child in _allies_container.get_children():
		child.queue_free()

	var npc_sys := get_node_or_null("/root/NpcSystem")
	if npc_sys == null:
		var lbl := Label.new()
		lbl.text = "Sistema no disponible"
		lbl.add_theme_color_override("font_color", C_MUTED)
		lbl.add_theme_font_size_override("font_size", 10)
		_allies_container.add_child(lbl)
		return

	var nrs = _character_data.get("npc_relation_state")
	var allies: Array = npc_sys.get_active_allies(_character_data)
	var known: Array  = npc_sys.get_known_npcs(_character_data)

	if allies.is_empty() and known.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "Ningún aliado aún"
		empty_lbl.add_theme_color_override("font_color", C_MUTED)
		empty_lbl.add_theme_font_size_override("font_size", 11)
		_allies_container.add_child(empty_lbl)
		return

	# Aliados activos primero
	for def in allies:
		var rel: int = nrs.get_relation(def.id) if nrs != null else 3
		_allies_container.add_child(_build_ally_card(def, rel))

	# Conocidos pero no aliados — más compactos
	for def in known:
		var rel: int = nrs.get_relation(def.id) if nrs != null else 1
		_allies_container.add_child(_build_ally_card(def, rel))

## Card de aliado compacta.
## Activos (ALLY/MASTER): nombre en color + bonus resumido.
## Conocidos (KNOWN/FRIENDLY): nombre en gris + condición para volverse aliado.
func _build_ally_card(def: NpcDefinition, relation: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)

	# Icono / estado
	var icon_lbl := Label.new()
	icon_lbl.text = def.icon if def.icon != "" else "◆"
	icon_lbl.add_theme_color_override("font_color", def.color if relation >= 3 else C_MUTED)
	icon_lbl.add_theme_font_size_override("font_size", 11)
	icon_lbl.custom_minimum_size.x = 18
	row.add_child(icon_lbl)

	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 1)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)

	# Nombre + estado
	var name_row := HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 4)
	info.add_child(name_row)

	var name_lbl := Label.new()
	name_lbl.text = def.display_name
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.add_theme_color_override("font_color", def.color if relation >= 3 else C_MUTED)
	name_lbl.add_theme_font_size_override("font_size", 12)
	name_row.add_child(name_lbl)

	var state_lbl := Label.new()
	match relation:
		4: state_lbl.text = "MAESTRO"
		3: state_lbl.text = "ALIADO"
		2: state_lbl.text = "Amistoso"
		_: state_lbl.text = "Conocido"
	state_lbl.add_theme_color_override("font_color",
		C_ACCENT if relation == 4 else (C_POSITIVE if relation == 3 else C_MUTED))
	state_lbl.add_theme_font_size_override("font_size", 9)
	name_row.add_child(state_lbl)

	# Bonus o condición
	var sub_lbl := Label.new()
	sub_lbl.add_theme_font_size_override("font_size", 10)
	if relation >= 3:
		# Mostrar bonus de combate
		sub_lbl.text = def.combat_bonus_desc if def.combat_bonus_desc != "" else \
			_summarize_training_mults(def)
		sub_lbl.add_theme_color_override("font_color", C_TEXT.lerp(C_MUTED, 0.3))
	else:
		# Mostrar condición para aliarse
		if not def.ally_stat_requirement.is_empty():
			var stat_id: StringName = def.ally_stat_requirement[0]
			var req_val: float      = float(def.ally_stat_requirement[1])
			var cur_val: float      = _character_data.base_stats.get(stat_id, 0.0)
			sub_lbl.text = "%s %.0f / %.0f" % [str(stat_id), cur_val, req_val]
			sub_lbl.add_theme_color_override("font_color",
				C_POSITIVE if cur_val >= req_val else C_MUTED)
		else:
			sub_lbl.text = "Día %d" % def.min_day
			sub_lbl.add_theme_color_override("font_color", C_MUTED)
	info.add_child(sub_lbl)

	return row

func _summarize_training_mults(def: NpcDefinition) -> String:
	var parts: Array[String] = []
	for stat_id: StringName in def.training_stat_mults.keys():
		var m: float = float(def.training_stat_mults[stat_id])
		parts.append("%s ×%.2f" % [str(stat_id), m])
	return "  ".join(parts.slice(0, 2))

## Banner temporal que aparece en la parte superior del DayScreen.
## Se usa para transformaciones desbloqueadas, también para checkpoints pasados.
func _show_unlock_banner(header: String, name_str: String, color: Color) -> void:
	var banner := PanelContainer.new()
	banner.set_anchors_preset(Control.PRESET_TOP_WIDE)
	banner.custom_minimum_size.y = 64
	var sb := StyleBoxFlat.new()
	sb.bg_color     = color.lerp(C_BG, 0.70)
	sb.border_color = color
	sb.border_width_bottom = 3
	banner.add_theme_stylebox_override("panel", sb)
	add_child(banner)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	banner.add_child(vbox)

	var h := Label.new()
	h.text = header
	h.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	h.add_theme_color_override("font_color", color)
	h.add_theme_font_size_override("font_size", 11)
	vbox.add_child(h)

	var n := Label.new()
	n.text = name_str.to_upper()
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	n.add_theme_color_override("font_color", C_TEXT)
	n.add_theme_font_size_override("font_size", 18)
	vbox.add_child(n)

	# Animación: aparece + se desvanece
	banner.modulate.a = 0.0
	var t := create_tween()
	t.set_trans(Tween.TRANS_SINE)
	t.tween_property(banner, "modulate:a", 1.0, 0.3)
	t.tween_interval(2.5)
	t.tween_property(banner, "modulate:a", 0.0, 0.5)
	t.tween_callback(banner.queue_free)

func _refresh_stats() -> void:
	if _character_data == null:
		return
	for child in _stats_container.get_children():
		child.queue_free()

	_xp_label.text = "XP  %d" % int(_character_data.experience)
	_refresh_tier()
	_refresh_level()
	_refresh_transforms()
	_refresh_allies()

	if _radar_chart != null:
		_radar_chart.queue_redraw()

	# Valores numéricos: 2 columnas compactas
	const STAT_ORDER: Array = [
		&"fuerza", &"velocidad", &"ki", &"vitalidad",
		&"resistencia", &"poder_ki", &"inteligencia", &"intel_combate"
	]
	const STAT_SHORT: Dictionary = {
		&"fuerza": "FUE", &"velocidad": "VEL", &"ki": "KI",
		&"vitalidad": "VIT", &"resistencia": "RES", &"poder_ki": "PKI",
		&"inteligencia": "INT", &"intel_combate": "I.C",
	}
	var priorities: Dictionary = _character_data.build.stat_priority_weights
	var row: HBoxContainer = null
	for i: int in STAT_ORDER.size():
		if i % 2 == 0:
			row = HBoxContainer.new()
			row.add_theme_constant_override("separation", 0)
			_stats_container.add_child(row)
		var stat_id: StringName = STAT_ORDER[i]
		var val: float          = _character_data.base_stats.get(stat_id, 0.0)
		var priority: float     = priorities.get(stat_id, 0.5)
		var col: Color          = C_ACCENT if priority >= 0.8 else (C_TEXT if priority >= 0.4 else C_MUTED)
		var cell := _stat_mini_cell(STAT_SHORT.get(stat_id, str(stat_id)), val, col)
		row.add_child(cell)

# Celda compacta de stat para la vista de 2 columnas
func _stat_mini_cell(short_name: String, val: float, col: Color) -> HBoxContainer:
	var cell := HBoxContainer.new()
	cell.add_theme_constant_override("separation", 4)
	cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var name_lbl := Label.new()
	name_lbl.text = short_name
	name_lbl.custom_minimum_size.x = 30
	name_lbl.add_theme_color_override("font_color", col)
	name_lbl.add_theme_font_size_override("font_size", 10)
	cell.add_child(name_lbl)

	var val_lbl := Label.new()
	val_lbl.text = "%.1f" % val
	val_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	val_lbl.add_theme_color_override("font_color", C_TEXT)
	val_lbl.add_theme_font_size_override("font_size", 10)
	cell.add_child(val_lbl)

	return cell

# Radar chart octagonal estilo Xenoverse
# 8 stats en disposición circular, el área llena muestra el perfil del personaje
func _draw_radar() -> void:
	if _character_data == null or _radar_chart == null:
		return

	const STAT_ORDER: Array = [
		&"fuerza", &"velocidad", &"ki", &"vitalidad",
		&"poder_ki", &"inteligencia", &"intel_combate", &"resistencia"
	]
	const STAT_LABELS: Dictionary = {
		&"fuerza": "FUE", &"velocidad": "VEL", &"ki": "KI",
		&"vitalidad": "VIT", &"poder_ki": "PKI",
		&"inteligencia": "INT", &"intel_combate": "IC", &"resistencia": "RES",
	}
	const MAX_VAL: float = 200.0
	const N: int = 8

	var cx: float = _radar_chart.size.x * 0.5
	var cy: float = _radar_chart.size.y * 0.5
	var R: float  = minf(_radar_chart.size.x, _radar_chart.size.y) * 0.36
	var center := Vector2(cx, cy)

	# Función para obtener punto en el eje i con ratio t (0–1)
	var axis_pt := func(i: int, t: float) -> Vector2:
		var angle := -PI * 0.5 + TAU * float(i) / float(N)
		return center + Vector2(cos(angle), sin(angle)) * R * t

	# ── Fondo — anillos de referencia ────────────────────────────────────
	for ring_t: float in [0.25, 0.5, 0.75, 1.0]:
		var pts: PackedVector2Array = []
		for i in N:
			pts.append(axis_pt.call(i, ring_t))
		var ring_col := Color(0.25, 0.25, 0.32, 0.4) if ring_t < 1.0 else Color(0.35, 0.35, 0.45, 0.6)
		_radar_chart.draw_polyline(
			PackedVector2Array(Array(pts) + [pts[0]]),
			ring_col, 1.0
		)

	# ── Ejes ──────────────────────────────────────────────────────────────
	for i in N:
		_radar_chart.draw_line(center, axis_pt.call(i, 1.0),
			Color(0.25, 0.25, 0.32, 0.5), 1.0)

	# ── Polígono del personaje ────────────────────────────────────────────
	var priorities: Dictionary = _character_data.build.stat_priority_weights
	var data_pts: PackedVector2Array = []
	for i in N:
		var stat_id: StringName = STAT_ORDER[i]
		var val: float = _character_data.base_stats.get(stat_id, 0.0)
		var t: float   = clampf(val / MAX_VAL, 0.0, 1.0)
		data_pts.append(axis_pt.call(i, t))

	# Relleno semitransparente
	_radar_chart.draw_colored_polygon(data_pts,
		Color(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 0.18))

	# Contorno del polígono
	_radar_chart.draw_polyline(
		PackedVector2Array(Array(data_pts) + [data_pts[0]]),
		Color(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 0.85), 1.5
	)

	# Puntos en cada vértice — coloreados según prioridad del build
	for i in N:
		var stat_id: StringName = STAT_ORDER[i]
		var priority: float = priorities.get(stat_id, 0.5)
		var pt_col: Color   = C_ACCENT if priority >= 0.8 else (C_TEXT if priority >= 0.4 else C_MUTED)
		_radar_chart.draw_circle(data_pts[i], 3.0, pt_col)

	# ── Labels de ejes ────────────────────────────────────────────────────
	for i in N:
		var angle := -PI * 0.5 + TAU * float(i) / float(N)
		var label_pt := center + Vector2(cos(angle), sin(angle)) * (R + 14.0)
		var lbl: String = STAT_LABELS.get(STAT_ORDER[i], "?")
		var stat_id: StringName = STAT_ORDER[i]
		var priority: float = priorities.get(stat_id, 0.5)
		var lbl_col: Color  = C_ACCENT if priority >= 0.8 else Color(0.65, 0.65, 0.70)
		_radar_chart.draw_string(
			ThemeDB.fallback_font,
			label_pt - Vector2(10, 7),
			lbl,
			HORIZONTAL_ALIGNMENT_CENTER, -1, 10,
			lbl_col
		)

# ─────────────────────────────────────────────────────────────────────────────
# Panel de récords de minijuegos
# ─────────────────────────────────────────────────────────────────────────────

var _records_overlay: Control = null

func _show_records_overlay() -> void:
	if _records_overlay != null:
		_records_overlay.queue_free()
		_records_overlay = null
		return

	var overlay := PanelContainer.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	var ov_bg := StyleBoxFlat.new()
	ov_bg.bg_color = Color(0, 0, 0, 0.70)
	overlay.add_theme_stylebox_override("panel", ov_bg)
	_records_overlay = overlay
	add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(480, 0)
	var card_sb := StyleBoxFlat.new()
	card_sb.bg_color                   = C_PANEL
	card_sb.corner_radius_top_left     = 8; card_sb.corner_radius_top_right    = 8
	card_sb.corner_radius_bottom_left  = 8; card_sb.corner_radius_bottom_right = 8
	card_sb.border_width_top           = 2
	card_sb.border_color               = C_ACCENT
	card.add_theme_stylebox_override("panel", card_sb)
	center.add_child(card)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	card.add_child(vbox)

	vbox.add_child(_spacer_v(20))

	# Título
	var title := Label.new()
	title.text = "★  RÉCORDS DE MINIJUEGOS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", C_ACCENT)
	title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title)

	vbox.add_child(_spacer_v(4))

	var sub := Label.new()
	sub.text = "Superar umbrales otorga bonuses permanentes de stat"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_color_override("font_color", C_MUTED)
	sub.add_theme_font_size_override("font_size", 11)
	vbox.add_child(sub)

	vbox.add_child(_spacer_v(16))

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", C_PANEL_ALT)
	vbox.add_child(sep)

	vbox.add_child(_spacer_v(12))

	# Obtener datos del RecordSystem
	var rec_node := get_node_or_null("/root/MinigameRecordSystem")
	var records_data: Array = []
	if rec_node != null and _character_data != null:
		records_data = rec_node.get_all_records(_character_data)

	# Si no hay datos, mostrar mensaje
	if records_data.is_empty():
		var empty := Label.new()
		empty.text = "Ningún minijuego completado aún"
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.add_theme_color_override("font_color", C_MUTED)
		vbox.add_child(empty)
	else:
		var scroll := ScrollContainer.new()
		scroll.custom_minimum_size.y = 360
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		vbox.add_child(scroll)

		var list := VBoxContainer.new()
		list.add_theme_constant_override("separation", 4)
		list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.add_child(list)

		for entry: Dictionary in records_data:
			list.add_child(_build_record_row(entry))

	vbox.add_child(_spacer_v(16))

	# Botón cerrar
	var close_row := HBoxContainer.new()
	close_row.add_child(_spacer_expand())
	var close_btn := Button.new()
	close_btn.text = "Cerrar"
	close_btn.custom_minimum_size = Vector2(120, 36)
	close_btn.add_theme_color_override("font_color", C_MUTED)
	close_btn.pressed.connect(func():
		if _records_overlay:
			_records_overlay.queue_free()
			_records_overlay = null
	)
	close_row.add_child(close_btn)
	close_row.add_child(_spacer_expand())
	vbox.add_child(close_row)

	vbox.add_child(_spacer_v(16))

## Construye una fila de récord para un minijuego.
func _build_record_row(entry: Dictionary) -> VBoxContainer:
	var row_vbox := VBoxContainer.new()
	row_vbox.add_theme_constant_override("separation", 4)

	var wrap := HBoxContainer.new()
	wrap.add_theme_constant_override("separation", 0)
	wrap.add_child(_spacer_h(16))
	row_vbox.add_child(wrap)

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 4)
	inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrap.add_child(inner)
	wrap.add_child(_spacer_h(16))

	var score: float      = entry.get("score", 0.0)
	var name_str: String  = entry.get("name", "?")
	var next_t: int       = entry.get("next_threshold", -1)
	var next_b: Dictionary = entry.get("next_bonus", {})
	var never_played: bool = score <= 0.0

	# Fila nombre + score
	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 6)
	inner.add_child(top_row)

	var name_lbl := Label.new()
	name_lbl.text = name_str
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.add_theme_color_override("font_color", C_TEXT if not never_played else C_MUTED)
	name_lbl.add_theme_font_size_override("font_size", 13)
	top_row.add_child(name_lbl)

	var score_lbl := Label.new()
	if never_played:
		score_lbl.text = "Sin jugar"
		score_lbl.add_theme_color_override("font_color", C_MUTED)
	else:
		score_lbl.text = "%.0f%%" % score
		score_lbl.add_theme_color_override("font_color",
			C_ACCENT if score >= 75.0 else (C_POSITIVE if score >= 50.0 else C_TEXT))
	score_lbl.add_theme_font_size_override("font_size", 13)
	top_row.add_child(score_lbl)

	# Barra de progreso con umbrales marcados
	var bar_container := Control.new()
	bar_container.custom_minimum_size = Vector2(0, 14)
	bar_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar_container.draw.connect(_draw_record_bar.bind(bar_container, score, next_t))
	inner.add_child(bar_container)

	# Próximo bonus
	if next_t > 0 and not next_b.is_empty():
		var bonus_parts: Array[String] = []
		for stat_id: StringName in next_b.keys():
			bonus_parts.append("%s +%.1f" % [str(stat_id), float(next_b[stat_id])])
		var bonus_row := HBoxContainer.new()
		bonus_row.add_theme_constant_override("separation", 4)
		inner.add_child(bonus_row)

		var arrow_lbl := Label.new()
		arrow_lbl.text = "→ %d%%" % next_t
		arrow_lbl.add_theme_color_override("font_color", C_ACCENT)
		arrow_lbl.add_theme_font_size_override("font_size", 10)
		bonus_row.add_child(arrow_lbl)

		var bonus_lbl := Label.new()
		bonus_lbl.text = "  ".join(bonus_parts)
		bonus_lbl.add_theme_color_override("font_color", C_POSITIVE)
		bonus_lbl.add_theme_font_size_override("font_size", 10)
		bonus_row.add_child(bonus_lbl)
	elif next_t < 0:
		# Todos los umbrales obtenidos
		var done_lbl := Label.new()
		done_lbl.text = "★ Todos los bonuses obtenidos"
		done_lbl.add_theme_color_override("font_color", C_ACCENT)
		done_lbl.add_theme_font_size_override("font_size", 10)
		inner.add_child(done_lbl)

	# Separador entre filas
	var sep := HSeparator.new()
	sep.add_theme_color_override("color", C_PANEL_ALT)
	row_vbox.add_child(sep)

	return row_vbox

## Dibuja la barra de progreso del récord con marcas en 25/50/75/100%.
func _draw_record_bar(ctrl: Control, score: float, next_t: int) -> void:
	var w: float = ctrl.size.x
	var h: float = ctrl.size.y
	if w <= 0:
		return

	# Fondo
	ctrl.draw_rect(Rect2(0, 2, w, h - 4),
		Color(C_PANEL_ALT.r, C_PANEL_ALT.g, C_PANEL_ALT.b, 0.8), true, -1.0, true)

	# Relleno según score
	if score > 0.0:
		var fill_w: float = (score / 100.0) * w
		var fill_col: Color = C_ACCENT if score >= 75.0 else (C_POSITIVE if score >= 50.0 else C_TEXT.lerp(C_MUTED, 0.3))
		ctrl.draw_rect(Rect2(0, 2, fill_w, h - 4), fill_col, true, -1.0, true)

	# Marcas de umbral
	for t: int in [25, 50, 75, 100]:
		var x: float = (float(t) / 100.0) * w
		var mark_col: Color
		if score >= float(t):
			mark_col = Color(0.0, 0.0, 0.0, 0.5)  # superado — marca oscura
		elif t == next_t:
			mark_col = Color(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 0.9)  # próximo — brillante
		else:
			mark_col = Color(0.4, 0.4, 0.5, 0.6)  # pendiente — gris
		ctrl.draw_line(Vector2(x, 0), Vector2(x, h), mark_col, 1.5)

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
