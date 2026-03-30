# ============================================================
# res://scenes/character_creation/CharacterCreationScreen.gd
#
# Pantalla de creación de personaje — Dragon Ascension
#
# RESPONSABILIDADES DE ESTE SCRIPT:
#   1. Mostrar los controles de selección (nombre, raza, puntos)
#   2. Leer los valores ingresados por el jugador
#   3. Calcular el build dominante en tiempo real
#   4. Ensamblar CharacterData usando CharacterFactory
#   5. Guardar en disco y notificar a los sistemas globales
#
# DEPENDENCIAS (autoloads / clases del proyecto):
#   RaceRegistry    → provee las RaceDefinition cargadas desde .tres
#   CharacterFactory → construye y valida el CharacterData final
#   BuildAnalyzer   → calcula qué perfil domina según los pesos
#   SaveSystem      → persiste el CharacterData a disco
#   EventBus        → señal global run_started
#   DayManager      → recibe el CharacterData para iniciar el loop
# ============================================================
class_name CharacterCreationScreen
extends Control

# ──────────────────────────────────────────────────────────────
# SEÑAL DIRECTA
# GameManager conecta esta señal con CONNECT_ONE_SHOT.
# Se emite DESPUÉS de run_started para que GameManager
# arranque DayScreen solo cuando todos los sistemas globales
# ya hayan recibido el evento.
# ──────────────────────────────────────────────────────────────
signal character_confirmed(data)  # CharacterData

# ═══════════════════════════════════════════════════════════════
# SECCIÓN 1 — CONSTANTES Y CONFIGURACIÓN
# ═══════════════════════════════════════════════════════════════

# Total de puntos que el jugador puede repartir entre sus stats.
# Cada punto se traduce a 0.1 de stat_priority_weight (rango 0.0–1.0).
# NOTA: Con 8 stats, 16 puntos da ~2 pts/stat promedio —
# suficiente densidad para builds diferenciados.
const TOTAL_POINTS: int = 16

# Máximo por stat individual. Limita a 0.8 de weight máximo,
# evitando builds completamente desequilibrados.
const MAX_PER_STAT: int = 8

# Stats que el jugador puede priorizar — los 8 canónicos del sistema.
# MIGRACIÓN v2: reemplaza [strength, ki_max, speed, defense].
const PRIORITY_STATS: Array[StringName] = [
	&"fuerza",
	&"velocidad",
	&"ki",
	&"vitalidad",
	&"resistencia",
	&"poder_ki",
	&"inteligencia",
	&"intel_combate",
]

# Nombres visibles en la UI para cada stat priorizable.
const STAT_LABELS: Dictionary = {
	&"fuerza":        "Fuerza",
	&"velocidad":     "Velocidad",
	&"ki":            "Ki",
	&"vitalidad":     "Vitalidad",
	&"resistencia":   "Resistencia",
	&"poder_ki":      "Control Ki",
	&"inteligencia":  "Inteligencia",
	&"intel_combate": "Int. Combate",
}

# ═══════════════════════════════════════════════════════════════
# SECCIÓN 2 — ESTADO INTERNO DE LA PANTALLA
# ═══════════════════════════════════════════════════════════════

var _selected_race: RaceDefinition = null
var _all_races: Array[RaceDefinition] = []
var _points_remaining: int = TOTAL_POINTS

# MIGRACIÓN v2: reemplaza {strength, ki_max, speed, defense}.
var _allocation: Dictionary = {
	&"fuerza":        0,
	&"velocidad":     0,
	&"ki":            0,
	&"vitalidad":     0,
	&"resistencia":   0,
	&"poder_ki":      0,
	&"inteligencia":  0,
	&"intel_combate": 0,
}

# ═══════════════════════════════════════════════════════════════
# SECCIÓN 3 — REFERENCIAS A NODOS UI
# ═══════════════════════════════════════════════════════════════

# ── Paleta base — coherente con DayScreen ────────────────────────────────────
const C_BG        := Color(0.07, 0.07, 0.09)
const C_PANEL     := Color(0.12, 0.12, 0.16)
const C_PANEL_ALT := Color(0.17, 0.17, 0.22)
const C_ACCENT    := Color(1.00, 0.78, 0.10)
const C_TEXT      := Color(0.92, 0.90, 0.86)
const C_MUTED     := Color(0.50, 0.49, 0.47)
const C_NEGATIVE  := Color(0.90, 0.32, 0.28)

# ── Paleta extendida Dragon Ball ──────────────────────────────────────────────
const C_POWER_LOW  := Color(1.00, 0.90, 0.10)
const C_POWER_MID  := Color(1.00, 0.50, 0.05)
const C_POWER_HIGH := Color(0.95, 0.15, 0.10)

# Iconos de stat para los labels
# MIGRACIÓN v2: reemplaza iconos de strength, ki_max, speed, defense.
const STAT_ICONS: Dictionary = {
	&"fuerza":        "⚔",
	&"velocidad":     "▶",
	&"ki":            "✦",
	&"vitalidad":     "♥",
	&"resistencia":   "🛡",
	&"poder_ki":      "◈",
	&"inteligencia":  "◆",
	&"intel_combate": "⚡",
}

# ── Textos de lore tipo Dragon Ball por raza ──────────────────────────────────
const DB_RACE_FLAVOR: Dictionary = {
	&"saiyan":   "Un guerrero de sangre real nacido para la batalla.\nCada derrota forja en él un poder inimaginable.\n✦ Tu fuerza y velocidad no tienen límite.",
	&"human":    "La voluntad humana supera cualquier barrera.\nDonde otros se rinden, tú te levantas más fuerte.\n✦ Tu versatilidad es tu mayor arma.",
	&"namekian": "Maestro del Ki interno, guardián de la sabiduría.\nTu espíritu es tan sólido como la roca verde de Namek.\n✦ Tu Ki y defensa son inquebrantables.",
}

const DB_RACE_FLAVOR_DEFAULT := "Un guerrero de potencial desconocido.\nSu historia aún no ha sido escrita.\n✦ El poder duerme dentro de ti."

# ── Textos de lore por build ───────────────────────────────────────────────────
# NOTA: "tank" renombrado a "defensive" para coincidir con BuildData.COMBAT_STYLES.
const DB_BUILD_FLAVOR: Dictionary = {
	&"striker":   "«El camino del guerrero de combate cuerpo a cuerpo.\nNi barreras ni distancias — solo el impacto directo.\nTu puño es tu argumento.»",
	&"ki_user":   "«El camino del maestro de la energía.\nLa distancia no existe cuando el Ki lo borra todo.\nTu voluntad se convierte en destrucción.»",
	&"defensive": "«El camino del bastión inamovible.\nCada golpe recibido es una prueba superada.\nNada te derrumba.»",
	&"balanced":  "«El camino del guerrero completo.\nSin punto débil, sin especialización obvia.\nAdaptable a cualquier batalla.»",
}

const DB_BUILD_FLAVOR_DEFAULT := "«Asigna tus puntos para\ndescubrir tu verdadero\ncamino como guerrero.»"

# ── Sección: Nombre
var _name_input: LineEdit

# ── Sección: Raza
var _race_buttons:       Array[Button]       = []
var _race_styleboxes:    Array[StyleBoxFlat] = []
var _race_desc_label:    Label
var _race_traits_label:  Label
var _aura_preview:       ColorRect

# ── Sección: Stats
var _points_label:       Label
var _stat_value_labels:  Dictionary = {}
var _stat_bar_refs:      Dictionary = {}
var _stat_minus_btns:    Dictionary = {}
var _stat_plus_btns:     Dictionary = {}

# ── Sección: Build Preview
var _build_color_bar:        ColorRect
var _build_panel_sb:         StyleBoxFlat
var _build_name_label:       Label
var _build_desc_label:       Label
var _build_flavor_label:     Label
var _build_scores_container: VBoxContainer

# ── Footer
var _validation_label: Label
var _start_button:     Button

# ═══════════════════════════════════════════════════════════════
# SECCIÓN 4 — ARRANQUE
# ═══════════════════════════════════════════════════════════════

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	_all_races = RaceRegistry.get_all_races()
	_all_races.sort_custom(func(a: RaceDefinition, b: RaceDefinition) -> bool:
		return a.display_name < b.display_name
	)

	if _all_races.is_empty():
		push_error("CharacterCreationScreen: RaceRegistry vacío. ¿Faltan .tres en data/races/definitions/?")
		return

	_selected_race = _all_races[0]

	_build_ui()
	_update_all()

# ═══════════════════════════════════════════════════════════════
# SECCIÓN 5 — LECTURA DE INPUTS DEL JUGADOR
# ═══════════════════════════════════════════════════════════════

## Lee el nombre del LineEdit y lo devuelve limpio.
## Retorna "Kakarot" si el campo está vacío.
func _read_character_name() -> String:
	var raw := _name_input.text.strip_edges()
	return raw if not raw.is_empty() else "Kakarot"

func _read_selected_race() -> RaceDefinition:
	return _selected_race

## Lee la distribución de puntos y la convierte en BuildData.
## Cada punto → 0.1 de stat_priority_weight (rango 0.0–0.8).
func _read_build_data() -> BuildData:
	var build := BuildData.new()

	for stat_id: StringName in PRIORITY_STATS:
		build.stat_priority_weights[stat_id] = _allocation[stat_id] * 0.1

	# El combat_style lo calcula BuildAnalyzer para que sea consistente
	# con la preview que ya ve el jugador.
	var temp  = _make_temp_character_data()
	var ident := BuildAnalyzer.get_build_identity(temp)
	build.combat_style = ident.id if ident != null else &"balanced"

	return build

func _read_appearance() -> AppearanceData:
	var ap       := AppearanceData.new()
	ap.aura_color = _selected_race.default_aura_color
	ap.body_scale = 1.0
	return ap

# ═══════════════════════════════════════════════════════════════
# SECCIÓN 6 — CÁLCULO DEL BUILD DOMINANTE
# ═══════════════════════════════════════════════════════════════

## Construye un CharacterData temporal solo para consultar BuildAnalyzer.
## NUNCA se guarda ni se pasa a otros sistemas.
func _make_temp_character_data():
	var temp_build := BuildData.new()
	for stat_id: StringName in PRIORITY_STATS:
		temp_build.stat_priority_weights[stat_id] = _allocation[stat_id] * 0.1

	var temp = CharacterData.new()
	temp.build = temp_build
	return temp

func _calculate_dominant_build() -> BuildProfile:
	return BuildAnalyzer.get_build_identity(_make_temp_character_data())

# ═══════════════════════════════════════════════════════════════
# SECCIÓN 7 — VALIDACIÓN
# ═══════════════════════════════════════════════════════════════

## Devuelve lista de mensajes de error.
## Lista vacía = formulario válido para crear el personaje.
func _get_validation_errors() -> Array[String]:
	var errors: Array[String] = []

	if _selected_race == null:
		errors.append("⚠  No hay razas disponibles. Verifica data/races/definitions/.")
		return errors

	if _points_remaining > 0:
		errors.append("⚠  Faltan %d puntos por asignar." % _points_remaining)

	var total_assigned := TOTAL_POINTS - _points_remaining
	if total_assigned > TOTAL_POINTS:
		errors.append("⚠  Error interno: puntos excedidos (%d > %d)." % [total_assigned, TOTAL_POINTS])

	return errors

# ═══════════════════════════════════════════════════════════════
# SECCIÓN 8 — CREACIÓN DEL PERSONAJE Y EMISIÓN DE SEÑALES
# ═══════════════════════════════════════════════════════════════

func _on_start_pressed() -> void:
	var errors := _get_validation_errors()
	if not errors.is_empty():
		push_warning("CharacterCreationScreen: Start presionado con errores: %s" % str(errors))
		return

	var char_name  := _read_character_name()
	var race_id    := _read_selected_race().id
	var appearance := _read_appearance()
	var build      := _read_build_data()

	var data = CharacterFactory.create(char_name, race_id, appearance, build)

	if data == null:
		push_error("CharacterCreationScreen: CharacterFactory.create() devolvió null.")
		return

	SaveSystem.save_character(data)
	print("[CharacterCreationScreen] Personaje '%s' guardado. Build: %s" % [
		data.character_name,
		data.build.combat_style
	])

	EventBus.run_started.emit(data)
	character_confirmed.emit(data)

# ═══════════════════════════════════════════════════════════════
# SECCIÓN 9 — CALLBACKS DE UI
# ═══════════════════════════════════════════════════════════════

func _on_name_changed(_new_text: String) -> void:
	_update_footer()

func _on_race_selected(index: int) -> void:
	_selected_race = _all_races[index]
	_update_race_display()

func _on_stat_changed(stat_id: StringName, delta: int) -> void:
	var new_val: int = _allocation[stat_id] + delta

	if new_val < 0 or new_val > MAX_PER_STAT:
		return
	if delta > 0 and _points_remaining <= 0:
		return

	_allocation[stat_id]  = new_val
	_points_remaining    -= delta

	_update_stats_display()
	_update_build_preview()
	_update_footer()

# ═══════════════════════════════════════════════════════════════
# SECCIÓN 10 — ACTUALIZACIÓN DE UI
# ═══════════════════════════════════════════════════════════════

func _update_all() -> void:
	_update_race_display()
	_update_stats_display()
	_update_build_preview()
	_update_footer()

func _update_race_display() -> void:
	for i: int in _race_buttons.size():
		var race      := _all_races[i]
		var is_active := (race == _selected_race)
		var sb        := _race_styleboxes[i]

		if is_active:
			sb.bg_color             = race.default_aura_color.lerp(C_BG, 0.80)
			sb.border_color         = race.default_aura_color
			sb.border_width_bottom  = 4
			sb.border_width_top     = 0
			sb.border_width_left    = 0
			sb.border_width_right   = 0
		else:
			sb.bg_color             = C_PANEL_ALT
			sb.border_color         = Color.TRANSPARENT
			sb.border_width_bottom  = 0

		_race_buttons[i].add_theme_stylebox_override("normal",  sb)
		_race_buttons[i].add_theme_stylebox_override("hover",   sb)
		_race_buttons[i].add_theme_stylebox_override("pressed", sb)
		_race_buttons[i].add_theme_color_override(
			"font_color", race.default_aura_color if is_active else C_MUTED
		)
		_race_buttons[i].add_theme_font_size_override("font_size", 15 if is_active else 13)

	if _selected_race == null:
		return

	var flavor: String = DB_RACE_FLAVOR.get(_selected_race.id, "")
	_race_desc_label.text = flavor if flavor != "" else _selected_race.description

	_aura_preview.color = _selected_race.default_aura_color

	if _selected_race.racial_traits.is_empty():
		_race_traits_label.text = "Sin rasgos especiales"
	else:
		var names: Array[String] = []
		for trait_id: StringName in _selected_race.racial_traits:
			names.append(str(trait_id).replace("_", " ").capitalize())
		_race_traits_label.text = "  ·  ".join(names)

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(_race_desc_label, "modulate",
		_selected_race.default_aura_color.lerp(Color.WHITE, 0.3), 0.15)
	tween.tween_property(_race_desc_label, "modulate", Color.WHITE, 0.20)

func _update_stats_display() -> void:
	var used := TOTAL_POINTS - _points_remaining
	_points_label.text = "%d / %d pts" % [used, TOTAL_POINTS]

	for stat_id: StringName in PRIORITY_STATS:
		var pts: int = _allocation[stat_id]

		var val_lbl := _stat_value_labels[stat_id] as Label
		val_lbl.text = str(pts)
		val_lbl.add_theme_color_override("font_color", _stat_power_color(pts, MAX_PER_STAT))

		var bar     := _stat_bar_refs[stat_id] as ProgressBar
		bar.value    = pts
		var fill_sb := StyleBoxFlat.new()
		fill_sb.bg_color                   = _stat_power_color(pts, MAX_PER_STAT)
		fill_sb.corner_radius_top_left     = 3
		fill_sb.corner_radius_top_right    = 3
		fill_sb.corner_radius_bottom_left  = 3
		fill_sb.corner_radius_bottom_right = 3
		bar.add_theme_stylebox_override("fill", fill_sb)

		(_stat_minus_btns[stat_id] as Button).disabled = (pts <= 0)
		(_stat_plus_btns[stat_id]  as Button).disabled = (pts >= MAX_PER_STAT or _points_remaining <= 0)

func _stat_power_color(pts: int, max_pts: int) -> Color:
	if max_pts <= 0 or pts <= 0:
		return C_POWER_LOW
	var t := float(pts) / float(max_pts)
	if t <= 0.5:
		return C_POWER_LOW.lerp(C_POWER_MID, t * 2.0)
	else:
		return C_POWER_MID.lerp(C_POWER_HIGH, (t - 0.5) * 2.0)

func _update_build_preview() -> void:
	var ident := _calculate_dominant_build()

	if ident == null:
		_build_name_label.text   = "—"
		_build_desc_label.text   = ""
		_build_flavor_label.text = DB_BUILD_FLAVOR_DEFAULT
		_build_color_bar.color   = C_PANEL
		_build_panel_sb.border_color = C_PANEL_ALT
		_build_panel_sb.bg_color     = C_PANEL_ALT
		for child in _build_scores_container.get_children():
			child.queue_free()
		return

	_build_name_label.text = ident.display_name.to_upper()
	_build_desc_label.text = ident.description

	_build_flavor_label.text = DB_BUILD_FLAVOR.get(ident.id, DB_BUILD_FLAVOR_DEFAULT)
	_build_flavor_label.add_theme_color_override("font_color", ident.profile_color.lerp(C_TEXT, 0.35))

	_build_color_bar.color = ident.profile_color

	_build_panel_sb.bg_color     = ident.profile_color.lerp(C_PANEL_ALT, 0.88)
	_build_panel_sb.border_color = ident.profile_color
	_build_panel_sb.border_width_left   = 3
	_build_panel_sb.border_width_right  = 0
	_build_panel_sb.border_width_top    = 0
	_build_panel_sb.border_width_bottom = 0

	for child in _build_scores_container.get_children():
		child.queue_free()

	var all_scores := BuildAnalyzer.get_all_scores(_make_temp_character_data())
	for entry: Dictionary in all_scores:
		var row := _build_score_row(entry.profile as BuildProfile, entry.score as float)
		_build_scores_container.add_child(row)

func _update_footer() -> void:
	var errors   := _get_validation_errors()
	var is_valid := errors.is_empty()

	_start_button.disabled = not is_valid
	_start_button.add_theme_color_override(
		"font_disabled_color", Color(C_BG.r, C_BG.g, C_BG.b, 0.4)
	)

	if not is_valid:
		_validation_label.modulate = Color.WHITE
		_validation_label.add_theme_color_override("font_color", C_NEGATIVE)
		_validation_label.text    = errors[0]
		_validation_label.visible = true
		return

	var name_is_empty := _name_input.text.strip_edges().is_empty()
	if name_is_empty:
		_validation_label.add_theme_color_override("font_color", C_ACCENT)
		_validation_label.text    = "ℹ  Nombre vacío: se usará \"Kakarot\""
		_validation_label.visible = true
	else:
		_validation_label.visible = false

# ═══════════════════════════════════════════════════════════════
# SECCIÓN 11 — CONSTRUCCIÓN DE UI
# ═══════════════════════════════════════════════════════════════

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = C_BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(600, 0)
	panel.add_theme_stylebox_override("panel", _flat_style(C_PANEL))
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	panel.add_child(vbox)

	vbox.add_child(_spacer_v(24))
	vbox.add_child(_ui_title_bar())
	vbox.add_child(_spacer_v(20))
	vbox.add_child(_ui_name_section())
	vbox.add_child(_spacer_v(16))
	vbox.add_child(_ui_divider())
	vbox.add_child(_spacer_v(16))
	vbox.add_child(_ui_race_section())
	vbox.add_child(_spacer_v(16))
	vbox.add_child(_ui_divider())
	vbox.add_child(_spacer_v(16))
	vbox.add_child(_ui_stats_section())
	vbox.add_child(_spacer_v(16))
	vbox.add_child(_ui_divider())
	vbox.add_child(_spacer_v(16))
	vbox.add_child(_ui_build_preview_section())
	vbox.add_child(_spacer_v(20))
	vbox.add_child(_ui_footer_section())
	vbox.add_child(_spacer_v(24))

func _ui_title_bar() -> Control:
	var header_panel := PanelContainer.new()
	var header_sb    := StyleBoxFlat.new()
	header_sb.bg_color            = C_BG.lerp(Color(0.15, 0.12, 0.02), 0.6)
	header_sb.border_color        = C_ACCENT
	header_sb.border_width_bottom = 2
	header_panel.add_theme_stylebox_override("panel", header_sb)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   24)
	margin.add_theme_constant_override("margin_right",  24)
	margin.add_theme_constant_override("margin_top",    12)
	margin.add_theme_constant_override("margin_bottom", 12)
	header_panel.add_child(margin)

	var hbox := HBoxContainer.new()
	margin.add_child(hbox)

	var deco_l := Label.new()
	deco_l.text = "✦ "
	deco_l.add_theme_color_override("font_color", C_ACCENT)
	deco_l.add_theme_font_size_override("font_size", 14)
	hbox.add_child(deco_l)

	var title := Label.new()
	title.text = "CREAR GUERRERO"
	title.add_theme_color_override("font_color", C_ACCENT)
	title.add_theme_font_size_override("font_size", 22)
	hbox.add_child(title)

	var deco_r := Label.new()
	deco_r.text = " ✦"
	deco_r.add_theme_color_override("font_color", C_ACCENT)
	deco_r.add_theme_font_size_override("font_size", 14)
	hbox.add_child(deco_r)

	hbox.add_child(_spacer_expand())

	var sub := Label.new()
	sub.text = "DRAGON ASCENSION"
	sub.add_theme_color_override("font_color", C_MUTED)
	sub.add_theme_font_size_override("font_size", 11)
	hbox.add_child(sub)

	return header_panel

func _ui_name_section() -> Control:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	hbox.add_child(_spacer_h(24))

	var lbl := Label.new()
	lbl.text                  = "NOMBRE"
	lbl.custom_minimum_size.x = 80
	lbl.add_theme_color_override("font_color", C_MUTED)
	lbl.add_theme_font_size_override("font_size", 11)
	hbox.add_child(lbl)

	_name_input = LineEdit.new()
	_name_input.placeholder_text      = "Vacío = Kakarot"
	_name_input.max_length            = 24
	_name_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_name_input.add_theme_color_override("font_color", C_TEXT)
	_name_input.text_changed.connect(_on_name_changed)
	hbox.add_child(_name_input)

	hbox.add_child(_spacer_h(24))
	return hbox

func _ui_race_section() -> Control:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)

	var h_row := HBoxContainer.new()
	h_row.add_child(_spacer_h(24))
	var header := Label.new()
	header.text = "RAZA"
	header.add_theme_color_override("font_color", C_MUTED)
	header.add_theme_font_size_override("font_size", 11)
	h_row.add_child(header)
	vbox.add_child(h_row)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 8)
	btn_row.add_child(_spacer_h(24))
	for i: int in _all_races.size():
		var btn := Button.new()
		btn.text                  = _all_races[i].display_name
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_race_selected.bind(i))

		var sb := StyleBoxFlat.new()
		sb.bg_color                   = C_PANEL_ALT
		sb.corner_radius_top_left     = 4
		sb.corner_radius_top_right    = 4
		sb.corner_radius_bottom_left  = 4
		sb.corner_radius_bottom_right = 4
		sb.content_margin_top         = 8
		sb.content_margin_bottom      = 8
		btn.add_theme_stylebox_override("normal",  sb)
		btn.add_theme_stylebox_override("hover",   sb)
		btn.add_theme_stylebox_override("pressed", sb)

		btn_row.add_child(btn)
		_race_buttons.append(btn)
		_race_styleboxes.append(sb)

	btn_row.add_child(_spacer_h(24))
	vbox.add_child(btn_row)

	var m_row := HBoxContainer.new()
	m_row.add_child(_spacer_h(24))
	var info_panel := PanelContainer.new()
	info_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_panel.add_theme_stylebox_override("panel", _flat_style(C_PANEL_ALT))
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	info_panel.add_child(margin)
	var iv := VBoxContainer.new()
	iv.add_theme_constant_override("separation", 8)
	margin.add_child(iv)

	_race_desc_label = Label.new()
	_race_desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_race_desc_label.add_theme_color_override("font_color", C_TEXT)
	_race_desc_label.add_theme_font_size_override("font_size", 13)
	_race_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	iv.add_child(_race_desc_label)

	var traits_row := HBoxContainer.new()
	traits_row.add_theme_constant_override("separation", 10)
	iv.add_child(traits_row)

	_race_traits_label = Label.new()
	_race_traits_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_race_traits_label.add_theme_color_override("font_color", C_MUTED)
	_race_traits_label.add_theme_font_size_override("font_size", 11)
	traits_row.add_child(_race_traits_label)

	var aura_lbl := Label.new()
	aura_lbl.text = "Aura"
	aura_lbl.add_theme_color_override("font_color", C_MUTED)
	aura_lbl.add_theme_font_size_override("font_size", 11)
	traits_row.add_child(aura_lbl)

	_aura_preview = ColorRect.new()
	_aura_preview.custom_minimum_size = Vector2(44, 20)
	traits_row.add_child(_aura_preview)

	m_row.add_child(info_panel)
	m_row.add_child(_spacer_h(24))
	vbox.add_child(m_row)
	return vbox

func _ui_stats_section() -> Control:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)

	var h_row := HBoxContainer.new()
	h_row.add_child(_spacer_h(24))
	var header := Label.new()
	header.text                  = "PRIORIDADES DE ENTRENAMIENTO"
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_theme_color_override("font_color", C_MUTED)
	header.add_theme_font_size_override("font_size", 11)
	h_row.add_child(header)
	_points_label = Label.new()
	_points_label.add_theme_color_override("font_color", C_ACCENT)
	_points_label.add_theme_font_size_override("font_size", 13)
	h_row.add_child(_points_label)
	h_row.add_child(_spacer_h(24))
	vbox.add_child(h_row)

	var note_row := HBoxContainer.new()
	note_row.add_child(_spacer_h(24))
	var note := Label.new()
	note.text                  = "¿En qué entrenará más tu guerrero?  (1 pto = 10% de prioridad · máx. 8 por stat)"
	note.autowrap_mode         = TextServer.AUTOWRAP_WORD_SMART
	note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	note.add_theme_color_override("font_color", C_MUTED)
	note.add_theme_font_size_override("font_size", 11)
	note_row.add_child(note)
	note_row.add_child(_spacer_h(24))
	vbox.add_child(note_row)

	for stat_id: StringName in PRIORITY_STATS:
		vbox.add_child(_ui_stat_row(stat_id))

	return vbox

func _ui_stat_row(stat_id: StringName) -> Control:
	var outer_panel := PanelContainer.new()
	var outer_sb    := StyleBoxFlat.new()
	outer_sb.bg_color                   = C_BG.lerp(C_PANEL, 0.5)
	outer_sb.corner_radius_top_left     = 6
	outer_sb.corner_radius_top_right    = 6
	outer_sb.corner_radius_bottom_left  = 6
	outer_sb.corner_radius_bottom_right = 6
	outer_sb.content_margin_left   = 24
	outer_sb.content_margin_right  = 24
	outer_sb.content_margin_top    = 10
	outer_sb.content_margin_bottom = 10
	outer_panel.add_theme_stylebox_override("panel", outer_sb)

	var inner := HBoxContainer.new()
	inner.add_theme_constant_override("separation", 10)
	outer_panel.add_child(inner)

	var icon_lbl := Label.new()
	icon_lbl.text = STAT_ICONS.get(stat_id, "·")
	icon_lbl.add_theme_color_override("font_color", C_ACCENT)
	icon_lbl.add_theme_font_size_override("font_size", 16)
	inner.add_child(icon_lbl)

	var name_lbl := Label.new()
	name_lbl.text                  = STAT_LABELS.get(stat_id, str(stat_id)).to_upper()
	name_lbl.custom_minimum_size.x = 100
	name_lbl.add_theme_color_override("font_color", C_TEXT)
	name_lbl.add_theme_font_size_override("font_size", 13)
	inner.add_child(name_lbl)

	var minus := Button.new()
	minus.text                = "−"
	minus.custom_minimum_size = Vector2(42, 42)
	minus.add_theme_font_size_override("font_size", 18)
	_style_control_button(minus, C_POWER_HIGH)
	minus.pressed.connect(_on_stat_changed.bind(stat_id, -1))
	inner.add_child(minus)
	_stat_minus_btns[stat_id] = minus

	var val_lbl := Label.new()
	val_lbl.text                  = "0"
	val_lbl.custom_minimum_size.x = 30
	val_lbl.horizontal_alignment  = HORIZONTAL_ALIGNMENT_CENTER
	val_lbl.add_theme_color_override("font_color", C_POWER_LOW)
	val_lbl.add_theme_font_size_override("font_size", 20)
	inner.add_child(val_lbl)
	_stat_value_labels[stat_id] = val_lbl

	var plus := Button.new()
	plus.text                = "+"
	plus.custom_minimum_size = Vector2(42, 42)
	plus.add_theme_font_size_override("font_size", 18)
	_style_control_button(plus, C_POWER_LOW)
	plus.pressed.connect(_on_stat_changed.bind(stat_id, +1))
	inner.add_child(plus)
	_stat_plus_btns[stat_id] = plus

	var bar := ProgressBar.new()
	bar.min_value             = 0
	bar.max_value             = MAX_PER_STAT
	bar.value                 = 0
	bar.show_percentage       = false
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.custom_minimum_size.y = 12

	var fill := StyleBoxFlat.new()
	fill.bg_color                   = C_POWER_LOW
	fill.corner_radius_top_left     = 4
	fill.corner_radius_top_right    = 4
	fill.corner_radius_bottom_left  = 4
	fill.corner_radius_bottom_right = 4
	bar.add_theme_stylebox_override("fill", fill)

	var bg_sb := StyleBoxFlat.new()
	bg_sb.bg_color                   = C_BG
	bg_sb.corner_radius_top_left     = 4
	bg_sb.corner_radius_top_right    = 4
	bg_sb.corner_radius_bottom_left  = 4
	bg_sb.corner_radius_bottom_right = 4
	bar.add_theme_stylebox_override("background", bg_sb)

	inner.add_child(bar)
	_stat_bar_refs[stat_id] = bar

	return outer_panel

func _ui_build_preview_section() -> Control:
	var m_row := HBoxContainer.new()
	m_row.add_child(_spacer_h(24))

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	_build_panel_sb = StyleBoxFlat.new()
	_build_panel_sb.bg_color                   = C_PANEL_ALT
	_build_panel_sb.corner_radius_top_left     = 6
	_build_panel_sb.corner_radius_top_right    = 6
	_build_panel_sb.corner_radius_bottom_left  = 6
	_build_panel_sb.corner_radius_bottom_right = 6
	panel.add_theme_stylebox_override("panel", _build_panel_sb)

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 14)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	var header := Label.new()
	header.text = "BUILD ESTIMADO"
	header.add_theme_color_override("font_color", C_MUTED)
	header.add_theme_font_size_override("font_size", 11)
	vbox.add_child(header)

	var build_row := HBoxContainer.new()
	build_row.add_theme_constant_override("separation", 14)
	vbox.add_child(build_row)

	_build_color_bar = ColorRect.new()
	_build_color_bar.custom_minimum_size = Vector2(8, 0)
	_build_color_bar.size_flags_vertical = Control.SIZE_EXPAND_FILL
	build_row.add_child(_build_color_bar)

	var tv := VBoxContainer.new()
	tv.add_theme_constant_override("separation", 4)
	tv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	build_row.add_child(tv)

	_build_name_label = Label.new()
	_build_name_label.add_theme_color_override("font_color", C_TEXT)
	_build_name_label.add_theme_font_size_override("font_size", 20)
	tv.add_child(_build_name_label)

	_build_desc_label = Label.new()
	_build_desc_label.add_theme_color_override("font_color", C_MUTED)
	_build_desc_label.add_theme_font_size_override("font_size", 12)
	_build_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tv.add_child(_build_desc_label)

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", C_PANEL)
	vbox.add_child(sep)

	_build_flavor_label = Label.new()
	_build_flavor_label.text            = DB_BUILD_FLAVOR_DEFAULT
	_build_flavor_label.autowrap_mode   = TextServer.AUTOWRAP_WORD_SMART
	_build_flavor_label.add_theme_color_override("font_color", C_MUTED)
	_build_flavor_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(_build_flavor_label)

	var sep2 := HSeparator.new()
	sep2.add_theme_color_override("color", C_PANEL)
	vbox.add_child(sep2)

	_build_scores_container = VBoxContainer.new()
	_build_scores_container.add_theme_constant_override("separation", 4)
	vbox.add_child(_build_scores_container)

	m_row.add_child(panel)
	m_row.add_child(_spacer_h(24))
	return m_row

func _ui_footer_section() -> Control:
	var m_row := HBoxContainer.new()
	m_row.add_child(_spacer_h(24))
	var inner := VBoxContainer.new()
	inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner.add_theme_constant_override("separation", 12)
	m_row.add_child(inner)
	m_row.add_child(_spacer_h(24))

	_validation_label = Label.new()
	_validation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_validation_label.add_theme_color_override("font_color", C_NEGATIVE)
	_validation_label.add_theme_font_size_override("font_size", 13)
	_validation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_validation_label.visible = false
	inner.add_child(_validation_label)

	_start_button = Button.new()
	_start_button.text                = "▶▶  INICIAR LOS 100 DÍAS  ◀◀"
	_start_button.custom_minimum_size = Vector2(0, 62)
	_start_button.add_theme_font_size_override("font_size", 17)
	_style_start_button(_start_button)
	_start_button.pressed.connect(_on_start_pressed)
	inner.add_child(_start_button)

	return m_row

# ═══════════════════════════════════════════════════════════════
# SECCIÓN 12 — HELPERS DE PRESENTACIÓN
# ═══════════════════════════════════════════════════════════════

func _build_score_row(profile: BuildProfile, score: float) -> Control:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)

	var dot := ColorRect.new()
	dot.color               = profile.profile_color
	dot.custom_minimum_size = Vector2(8, 8)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(dot)

	var name_lbl := Label.new()
	name_lbl.text                  = profile.display_name
	name_lbl.custom_minimum_size.x = 80
	name_lbl.add_theme_color_override("font_color", C_MUTED)
	name_lbl.add_theme_font_size_override("font_size", 11)
	hbox.add_child(name_lbl)

	var bar := ProgressBar.new()
	bar.min_value = 0.0; bar.max_value = 1.0; bar.value = score
	bar.show_percentage = false
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.custom_minimum_size.y = 5
	var f := StyleBoxFlat.new(); f.bg_color = profile.profile_color
	bar.add_theme_stylebox_override("fill", f)
	var b := StyleBoxFlat.new(); b.bg_color = C_PANEL
	bar.add_theme_stylebox_override("background", b)
	hbox.add_child(bar)

	var pct := Label.new()
	pct.text = "%.0f%%" % (score * 100.0)
	pct.custom_minimum_size.x = 36
	pct.horizontal_alignment  = HORIZONTAL_ALIGNMENT_RIGHT
	pct.add_theme_color_override("font_color", C_MUTED)
	pct.add_theme_font_size_override("font_size", 11)
	hbox.add_child(pct)
	return hbox

func _flat_style(color: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new(); s.bg_color = color; return s

func _style_start_button(btn: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color                   = C_ACCENT
	normal.border_color               = C_POWER_MID
	normal.border_width_top           = 0
	normal.border_width_bottom        = 3
	normal.border_width_left          = 0
	normal.border_width_right         = 0
	normal.corner_radius_top_left     = 8
	normal.corner_radius_top_right    = 8
	normal.corner_radius_bottom_left  = 8
	normal.corner_radius_bottom_right = 8
	normal.content_margin_top         = 14
	normal.content_margin_bottom      = 14
	btn.add_theme_stylebox_override("normal", normal)

	var hover := StyleBoxFlat.new()
	hover.bg_color                   = Color(C_ACCENT.r + 0.08, C_ACCENT.g + 0.04, C_ACCENT.b)
	hover.border_color               = C_POWER_HIGH
	hover.border_width_bottom        = 4
	hover.corner_radius_top_left     = 8; hover.corner_radius_top_right    = 8
	hover.corner_radius_bottom_left  = 8; hover.corner_radius_bottom_right = 8
	hover.content_margin_top         = 14; hover.content_margin_bottom      = 14
	btn.add_theme_stylebox_override("hover", hover)

	var pressed := StyleBoxFlat.new()
	pressed.bg_color                   = Color(C_ACCENT.r - 0.12, C_ACCENT.g - 0.06, C_ACCENT.b)
	pressed.corner_radius_top_left     = 8; pressed.corner_radius_top_right    = 8
	pressed.corner_radius_bottom_left  = 8; pressed.corner_radius_bottom_right = 8
	pressed.content_margin_top         = 16; pressed.content_margin_bottom      = 12
	btn.add_theme_stylebox_override("pressed", pressed)

	var disabled := StyleBoxFlat.new()
	disabled.bg_color                   = Color(0.25, 0.23, 0.15)
	disabled.border_color               = Color(0.35, 0.33, 0.20)
	disabled.border_width_bottom        = 2
	disabled.corner_radius_top_left     = 8; disabled.corner_radius_top_right    = 8
	disabled.corner_radius_bottom_left  = 8; disabled.corner_radius_bottom_right = 8
	disabled.content_margin_top         = 14; disabled.content_margin_bottom      = 14
	btn.add_theme_stylebox_override("disabled", disabled)

	btn.add_theme_color_override("font_color",          C_BG)
	btn.add_theme_color_override("font_hover_color",    C_BG)
	btn.add_theme_color_override("font_pressed_color",  C_BG)
	btn.add_theme_color_override("font_disabled_color", Color(0.5, 0.48, 0.35))

func _style_control_button(btn: Button, accent_color: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color                   = accent_color.lerp(C_BG, 0.80)
	normal.border_color               = accent_color.lerp(C_BG, 0.50)
	normal.border_width_bottom        = 2
	normal.corner_radius_top_left     = 6
	normal.corner_radius_top_right    = 6
	normal.corner_radius_bottom_left  = 6
	normal.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("normal", normal)

	var hover := StyleBoxFlat.new()
	hover.bg_color                   = accent_color.lerp(C_BG, 0.60)
	hover.border_color               = accent_color
	hover.border_width_bottom        = 2
	hover.corner_radius_top_left     = 6; hover.corner_radius_top_right    = 6
	hover.corner_radius_bottom_left  = 6; hover.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("hover", hover)

	var pressed := StyleBoxFlat.new()
	pressed.bg_color                   = accent_color.lerp(C_BG, 0.40)
	pressed.corner_radius_top_left     = 6; pressed.corner_radius_top_right    = 6
	pressed.corner_radius_bottom_left  = 6; pressed.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("pressed", pressed)

	btn.add_theme_color_override("font_color",       accent_color.lerp(C_TEXT, 0.6))
	btn.add_theme_color_override("font_hover_color", accent_color.lerp(Color.WHITE, 0.3))

func _style_accent(btn: Button) -> void:
	var colors: Array[Color] = [
		C_ACCENT,
		Color(C_ACCENT.r + 0.08, C_ACCENT.g, C_ACCENT.b),
		Color(C_ACCENT.r - 0.1,  C_ACCENT.g - 0.05, C_ACCENT.b),
	]
	var states: Array[String] = ["normal", "hover", "pressed"]
	for i: int in states.size():
		var s := StyleBoxFlat.new()
		s.bg_color                   = colors[i]
		s.corner_radius_top_left     = 4; s.corner_radius_top_right    = 4
		s.corner_radius_bottom_left  = 4; s.corner_radius_bottom_right = 4
		s.content_margin_top = 12;  s.content_margin_bottom = 12
		btn.add_theme_stylebox_override(states[i], s)
	btn.add_theme_color_override("font_color",         C_BG)
	btn.add_theme_color_override("font_hover_color",   C_BG)
	btn.add_theme_color_override("font_pressed_color", C_BG)

func _ui_divider() -> Control:
	var row := HBoxContainer.new()
	row.add_child(_spacer_h(24))
	var sep := HSeparator.new()
	sep.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sep.add_theme_color_override("color", C_PANEL_ALT)
	row.add_child(sep)
	row.add_child(_spacer_h(24))
	return row

func _spacer_h(w: int) -> Control:
	var s := Control.new(); s.custom_minimum_size.x = w; return s

func _spacer_v(h: int) -> Control:
	var s := Control.new(); s.custom_minimum_size.y = h; return s

func _spacer_expand() -> Control:
	var s := Control.new(); s.size_flags_horizontal = Control.SIZE_EXPAND_FILL; return s
