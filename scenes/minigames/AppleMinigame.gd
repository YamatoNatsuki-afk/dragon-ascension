# res://scenes/minigames/AppleMinigame.gd
#
# Minijuego: GOLPE DE PUÑO — para Fuerza / Resistencia
#
# Manzanas caen desde arriba. SPACE o click las golpea si están en la zona.
# ⭐ Estrellas = PERFECTO (×3 puntos). 💣 Bombas = penalización (-5 pts).
# 5 rondas. Score 0–100 → multiplicador 0.5×–2.0×.

class_name AppleMinigame
extends Control

signal completed(multiplier: float)

# ── Constantes ────────────────────────────────────────────────────────────────
const ROUNDS:       int   = 5
const OBJECTS_PER_ROUND: int = 6
const FALL_SPEED:   float = 220.0   # px/s base
const HIT_ZONE_Y:   float = 0.72    # fracción de altura donde está el puño
const HIT_ZONE_H:   float = 80.0    # altura de la zona de golpe en px
const SPAWN_DELAY:  float = 0.55    # segundos entre objetos

# Paleta
const C_BG        := Color(0.05, 0.05, 0.07, 0.93)
const C_PANEL     := Color(0.12, 0.12, 0.16)
const C_ACCENT    := Color(1.00, 0.78, 0.10)
const C_POSITIVE  := Color(0.28, 0.85, 0.44)
const C_NEGATIVE  := Color(0.90, 0.30, 0.28)
const C_TEXT      := Color(0.92, 0.90, 0.86)
const C_MUTED     := Color(0.50, 0.49, 0.47)
const C_STAR      := Color(1.00, 0.90, 0.10)
const C_BOMB      := Color(0.95, 0.25, 0.20)
const C_APPLE     := Color(0.85, 0.20, 0.20)

# ── Estado ────────────────────────────────────────────────────────────────────
var _score:         int   = 0
var _round:         int   = 0
var _objects_spawned: int = 0
var _objects_done:  int   = 0
var _spawn_timer:   float = 0.0
var _spawning:      bool  = false
var _active:        bool  = false
var _hit_flash:     float = 0.0   # timer para flash de zona

# Objetos en pantalla: Array[Dictionary] con keys: type, x, y, hit
var _objects: Array = []

var _action_name:   String = ""
var _target_stats:  Array[StringName] = []

# Nodos UI
var _canvas:        Control
var _score_lbl:     Label
var _round_lbl:     Label
var _feedback_lbl:  Label
var _hint_lbl:      Label
var _combo_lbl:     Label

var _combo: int = 0
var _max_combo: int = 0

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

	# Canvas de juego (área central)
	_canvas = Control.new()
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.draw.connect(_draw_game)
	add_child(_canvas)

	# HUD superior
	var hud := HBoxContainer.new()
	hud.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hud.custom_minimum_size.y = 48
	hud.add_theme_constant_override("separation", 0)
	add_child(hud)

	hud.add_child(_spacer_h(20))

	_round_lbl = Label.new()
	_round_lbl.text = "RONDA 1/%d" % ROUNDS
	_round_lbl.add_theme_color_override("font_color", C_MUTED)
	_round_lbl.add_theme_font_size_override("font_size", 13)
	_round_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_round_lbl.custom_minimum_size.y = 48
	hud.add_child(_round_lbl)

	hud.add_child(_spacer_expand())

	var title := Label.new()
	title.text = "GOLPE DE PUÑO"
	title.add_theme_color_override("font_color", C_ACCENT)
	title.add_theme_font_size_override("font_size", 16)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	title.custom_minimum_size.y = 48
	hud.add_child(title)

	hud.add_child(_spacer_expand())

	_score_lbl = Label.new()
	_score_lbl.text = "0 pts"
	_score_lbl.add_theme_color_override("font_color", C_ACCENT)
	_score_lbl.add_theme_font_size_override("font_size", 15)
	_score_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_score_lbl.custom_minimum_size.y = 48
	hud.add_child(_score_lbl)

	hud.add_child(_spacer_h(20))

	# Feedback centro-pantalla
	_feedback_lbl = Label.new()
	_feedback_lbl.set_anchors_preset(Control.PRESET_CENTER)
	_feedback_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_feedback_lbl.add_theme_font_size_override("font_size", 32)
	_feedback_lbl.add_theme_color_override("font_color", C_POSITIVE)
	_feedback_lbl.modulate.a = 0.0
	add_child(_feedback_lbl)

	# Combo label
	_combo_lbl = Label.new()
	_combo_lbl.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	_combo_lbl.position.x -= 120
	_combo_lbl.position.y -= 40
	_combo_lbl.add_theme_font_size_override("font_size", 20)
	_combo_lbl.add_theme_color_override("font_color", C_STAR)
	_combo_lbl.modulate.a = 0.0
	add_child(_combo_lbl)

	# Hint inferior
	_hint_lbl = Label.new()
	_hint_lbl.text = "[ SPACE ] o [ CLICK ] para golpear"
	_hint_lbl.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_lbl.add_theme_color_override("font_color", C_MUTED)
	_hint_lbl.add_theme_font_size_override("font_size", 12)
	_hint_lbl.position.y -= 32
	add_child(_hint_lbl)

# ─────────────────────────────────────────────────────────────────────────────
# Lógica de juego
# ─────────────────────────────────────────────────────────────────────────────

func _start_round() -> void:
	_objects.clear()
	_objects_spawned = 0
	_objects_done    = 0
	_spawn_timer     = 0.0
	_spawning        = true
	_active          = true
	_round_lbl.text  = "RONDA %d/%d" % [_round + 1, ROUNDS]

func _process(delta: float) -> void:
	if not _active:
		return

	# Spawn de objetos
	if _spawning and _objects_spawned < OBJECTS_PER_ROUND:
		_spawn_timer -= delta
		if _spawn_timer <= 0.0:
			_spawn_object()
			_spawn_timer = SPAWN_DELAY * randf_range(0.7, 1.3)

	# Mover objetos
	var speed := FALL_SPEED * (1.0 + _round * 0.12)
	var h     := size.y
	var to_remove: Array = []

	for obj in _objects:
		if obj.hit:
			obj.y += delta * speed * 0.3   # los golpeados caen más lento
			obj.alpha = maxf(0.0, obj.alpha - delta * 3.0)
			if obj.alpha <= 0.0:
				to_remove.append(obj)
				_objects_done += 1
		else:
			obj.y += delta * speed
			if obj.y > h + 40:
				# Pasó la zona sin ser golpeado
				to_remove.append(obj)
				_objects_done += 1
				if obj.type != "bomb":
					_combo = 0   # rompés el combo si dejás pasar una manzana/estrella
					_show_feedback("MISS", C_MUTED, 22)

	for obj in to_remove:
		_objects.erase(obj)

	# Flash de zona
	if _hit_flash > 0.0:
		_hit_flash -= delta

	_canvas.queue_redraw()

	# Verificar fin de ronda
	if _objects_spawned >= OBJECTS_PER_ROUND and _objects.is_empty() and _active:
		_active = false
		_round += 1
		if _round >= ROUNDS:
			_finish()
		else:
			await get_tree().create_timer(0.5).timeout
			_start_round()

func _spawn_object() -> void:
	_objects_spawned += 1
	var rng := randf()
	var type: String
	if rng < 0.12:
		type = "bomb"
	elif rng < 0.30:
		type = "star"
	else:
		type = "apple"

	var margin := 60.0
	_objects.append({
		"type":  type,
		"x":     randf_range(margin, size.x - margin),
		"y":     -30.0,
		"hit":   false,
		"alpha": 1.0,
		"scale": randf_range(0.85, 1.15),
	})

func _try_hit() -> void:
	if not _active:
		return
	var hit_y  := size.y * HIT_ZONE_Y
	var hit_zone_min := hit_y - HIT_ZONE_H * 0.5
	var hit_zone_max := hit_y + HIT_ZONE_H * 0.5
	_hit_flash = 0.12

	var hit_any := false
	for obj in _objects:
		if obj.hit:
			continue
		if obj.y >= hit_zone_min and obj.y <= hit_zone_max:
			obj.hit = true
			hit_any = true
			match obj.type:
				"apple":
					_score  += 2
					_combo  += 1
					_max_combo = maxi(_max_combo, _combo)
					var bonus := mini(_combo - 1, 4) * 1
					_score += bonus
					if _combo >= 3:
						_show_feedback("COMBO ×%d!" % _combo, C_STAR, 28)
					else:
						_show_feedback("¡GOLPE!", C_POSITIVE, 26)
				"star":
					_score  += 5
					_combo  += 1
					_max_combo = maxi(_max_combo, _combo)
					_show_feedback("★ PERFECTO!", C_STAR, 32)
				"bomb":
					_score  = maxi(0, _score - 5)
					_combo   = 0
					_show_feedback("💣 BOMBA", C_NEGATIVE, 28)

	if not hit_any:
		_show_feedback("FALLO", C_MUTED, 22)
		_combo = 0

	_score_lbl.text = "%d pts" % _score

func _finish() -> void:
	_hint_lbl.text = ""
	# Bonus por combo máximo
	_score += _max_combo * 2

	# Normalizar a 0–100
	var max_possible := ROUNDS * OBJECTS_PER_ROUND * 5 + ROUNDS * 4
	var pct: float   = clampf(float(_score) / float(max_possible), 0.0, 1.0)
	var multiplier   := lerpf(0.5, 2.0, pct)

	_show_feedback("Eficiencia: %d%%" % int(pct * 100.0), C_ACCENT, 28)

	await get_tree().create_timer(1.2).timeout
	completed.emit(multiplier)

func _show_feedback(text: String, color: Color, size_px: int) -> void:
	_feedback_lbl.text = text
	_feedback_lbl.add_theme_color_override("font_color", color)
	_feedback_lbl.add_theme_font_size_override("font_size", size_px)
	_feedback_lbl.modulate.a = 1.0
	var t := create_tween()
	t.tween_property(_feedback_lbl, "modulate:a", 0.0, 0.45).set_delay(0.3)

# ─────────────────────────────────────────────────────────────────────────────
# Input
# ─────────────────────────────────────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		_try_hit()
	elif event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		_try_hit()

# ─────────────────────────────────────────────────────────────────────────────
# Dibujo
# ─────────────────────────────────────────────────────────────────────────────

func _draw_game() -> void:
	var w := _canvas.size.x
	var h := _canvas.size.y
	var hit_y := h * HIT_ZONE_Y

	# Zona de golpe
	var zone_alpha := 0.35 + (_hit_flash / 0.12) * 0.4 if _hit_flash > 0 else 0.18
	_canvas.draw_rect(
		Rect2(0, hit_y - HIT_ZONE_H * 0.5, w, HIT_ZONE_H),
		Color(C_POSITIVE.r, C_POSITIVE.g, C_POSITIVE.b, zone_alpha)
	)
	# Línea central de zona
	_canvas.draw_line(
		Vector2(0, hit_y), Vector2(w, hit_y),
		Color(C_POSITIVE.r, C_POSITIVE.g, C_POSITIVE.b, 0.6), 2.0
	)

	# Puño / ícono de golpe
	var fist_str := "👊"
	_canvas.draw_string(
		ThemeDB.fallback_font,
		Vector2(w * 0.5 - 20, hit_y + 12),
		fist_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 32,
		Color(1, 1, 1, 0.7 + (_hit_flash / 0.12) * 0.3 if _hit_flash > 0 else 0.5)
	)

	# Objetos
	for obj in _objects:
		var col: Color
		var icon: String
		match obj.type:
			"apple": col = C_APPLE;  icon = "🍎"
			"star":  col = C_STAR;   icon = "⭐"
			"bomb":  col = C_BOMB;   icon = "💣"
			_:       col = C_TEXT;   icon = "?"
		var alpha: float = obj.alpha
		_canvas.draw_string(
			ThemeDB.fallback_font,
			Vector2(obj.x - 16, obj.y + 16),
			icon, HORIZONTAL_ALIGNMENT_LEFT, -1,
			int(32 * obj.scale),
			Color(col.r, col.g, col.b, alpha)
		)

# ─────────────────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────────────────

func _spacer_h(w: int) -> Control:
	var s := Control.new(); s.custom_minimum_size.x = w; return s

func _spacer_expand() -> Control:
	var s := Control.new(); s.size_flags_horizontal = Control.SIZE_EXPAND_FILL; return s
