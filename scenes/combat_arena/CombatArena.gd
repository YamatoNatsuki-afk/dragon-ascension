# res://scenes/combat_arena/CombatArena.gd
#
# v5: HUD mejorado + cámara espectadora.
#
# CAPAS:
#   CanvasLayer -10  → fondo (siempre llena pantalla)
#   Node2D root      → player, enemy, VFX flotantes (espacio mundo)
#   CanvasLayer  10  → HUD completo (siempre en pantalla)
#
# HUD:
#   Top-left    → HP + barra de color del jugador, barra de Ki
#   Top-right   → HP + barra de color del enemigo
#   Top-center  → Indicador de transformación activa (oculto por defecto)
#   Mid-left    → Indicador "▲ VOLANDO"
#   Bottom      → Botones de acción + info de controles
#   Top-right   → Modo de cámara activo
#
# CÁMARA (CombatCamera):
#   TAB          → ciclar modo (Jugador / Enemigo / Ambos / Libre)
#   Rueda ratón  → zoom in/out
#   IJKL         → panear en modo Libre
#   R            → resetear al jugador
#
extends Node2D

@onready var player: Player = $Player
@onready var enemy: Enemy   = $Enemy

const PLAYER_SPAWN       := Vector2(300.0, 300.0)
const ENEMY_SPAWN        := Vector2(700.0, 300.0)
const COMBAT_START_DELAY := 2

var _combat_active:  bool = false
var _player_can_act: bool = false
var _day_screen: Node     = null

# ── Estadísticas de combate ───────────────────────────────────────────────────
var _damage_dealt:    float = 0.0
var _damage_received: float = 0.0
var _max_combo:       int   = 0

# ── Cámara ────────────────────────────────────────────────────────────────────
var _camera: CombatCamera = null

# ── HUD CanvasLayer y referencias ─────────────────────────────────────────────
var _hud: CanvasLayer

# Jugador — esquina superior izquierda
var _hp_label:           Label
var _player_hp_bar_bg:   ColorRect
var _player_hp_bar_fill: ColorRect

# Ki — bajo la HP del jugador
var _ki_bar_bg:    ColorRect
var _ki_bar_fill:  ColorRect
var _ki_label:     Label

# Enemigo — esquina superior derecha
var _enemy_header:      Label
var _enemy_hp_label:    Label
var _enemy_hp_bar_bg:   ColorRect
var _enemy_hp_bar_fill: ColorRect

# Indicador de transformación — top-center, oculto por defecto
var _transform_bg:    ColorRect
var _transform_label: Label

# Indicador de vuelo
var _fly_label: Label

# Indicador de modo de cámara — top-right
var _camera_mode_label: Label

# Contador de combo — centro inferior del HUD
var _combo_bg:    ColorRect
var _combo_label: Label

# Panel de nivel de poder — bajo la barra de Ki
var _power_label: Label
var _tier_label:  Label
var _tier_bar_bg:   ColorRect
var _tier_bar_fill: ColorRect

# Overlay de resultado
var _overlay_layer: CanvasLayer

# ─────────────────────────────────────────────────────────────────────────────
# READY
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	_day_screen = get_tree().root.get_node_or_null("DayScreen")
	if _day_screen:
		_day_screen.visible = false

	player.global_position = PLAYER_SPAWN
	enemy.global_position  = ENEMY_SPAWN
	enemy.set_physics_process(false)

	_register_input("ki_blast",     KEY_X)
	_register_input("ki_charge",    KEY_C)
	_register_input("transform",    KEY_T)
	_register_input("fly",          KEY_SPACE)
	_register_input("camera_cycle", KEY_TAB)

	_create_ui()
	_create_camera()

	EventBus.combat_started.connect(_on_combat_started, CONNECT_ONE_SHOT)
	EventBus.player_ki_changed.connect(_on_player_ki_changed)
	EventBus.player_health_changed.connect(_on_player_hp_changed)
	EventBus.transformation_activated.connect(_on_transformation_activated)
	EventBus.transformation_deactivated.connect(_on_transformation_deactivated)
	EventBus.combo_updated.connect(_on_combo_updated)
	enemy.died.connect(_on_enemy_died)
	enemy.attack_dodged.connect(_on_attack_dodged)
	if not EventBus.player_died.is_connected(_on_player_died):
		EventBus.player_died.connect(_on_player_died, CONNECT_ONE_SHOT)

# ─────────────────────────────────────────────────────────────────────────────
# UI
# ─────────────────────────────────────────────────────────────────────────────

func _create_ui() -> void:
	# ── Fondo (debajo del mundo) ──────────────────────────────────────────────
	var bg_layer   := CanvasLayer.new(); bg_layer.layer = -10; add_child(bg_layer)
	var bg         := ColorRect.new()
	bg.color        = Color(0.08, 0.08, 0.12)
	bg.size         = Vector2(1152, 648)
	bg_layer.add_child(bg)

	# ── Placeholders visuales en espacio mundo ────────────────────────────────
	var pr         := ColorRect.new()
	pr.color        = Color(0.2, 0.5, 1.0); pr.size = Vector2(32, 48); pr.position = Vector2(-16, -24)
	player.add_child(pr)

	var er         := ColorRect.new()
	er.color        = Color(1.0, 0.2, 0.2); er.size = Vector2(40, 48); er.position = Vector2(-20, -24)
	enemy.add_child(er)

	# ── HUD CanvasLayer ───────────────────────────────────────────────────────
	_hud = CanvasLayer.new(); _hud.layer = 10; add_child(_hud)

	# ── Bloque jugador (top-left) ─────────────────────────────────────────────
	var pl_header      := Label.new()
	pl_header.text      = "JUGADOR"
	pl_header.position  = Vector2(14, 10)
	pl_header.add_theme_font_size_override("font_size", 11)
	pl_header.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0))
	_hud.add_child(pl_header)

	_player_hp_bar_bg           = ColorRect.new()
	_player_hp_bar_bg.color      = Color(0.15, 0.08, 0.08)
	_player_hp_bar_bg.size       = Vector2(220, 16)
	_player_hp_bar_bg.position   = Vector2(14, 26)
	_hud.add_child(_player_hp_bar_bg)

	_player_hp_bar_fill          = ColorRect.new()
	_player_hp_bar_fill.color     = Color(0.2, 0.85, 0.3)
	_player_hp_bar_fill.size      = Vector2(220, 16)
	_player_hp_bar_fill.position  = Vector2(14, 26)
	_hud.add_child(_player_hp_bar_fill)

	_hp_label          = Label.new()
	_hp_label.position  = Vector2(242, 25)
	_hp_label.add_theme_font_size_override("font_size", 13)
	_hud.add_child(_hp_label)

	# Ki bar bajo la HP
	var ki_lbl_static       := Label.new()
	ki_lbl_static.text       = "KI"
	ki_lbl_static.position   = Vector2(14, 48)
	ki_lbl_static.add_theme_font_size_override("font_size", 11)
	ki_lbl_static.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
	_hud.add_child(ki_lbl_static)

	_ki_bar_bg          = ColorRect.new()
	_ki_bar_bg.color     = Color(0.07, 0.07, 0.18)
	_ki_bar_bg.size      = Vector2(180, 12)
	_ki_bar_bg.position  = Vector2(34, 49)
	_hud.add_child(_ki_bar_bg)

	_ki_bar_fill          = ColorRect.new()
	_ki_bar_fill.color     = Color(0.3, 0.75, 1.0)
	_ki_bar_fill.size      = Vector2(180, 12)
	_ki_bar_fill.position  = Vector2(34, 49)
	_hud.add_child(_ki_bar_fill)

	_ki_label          = Label.new()
	_ki_label.position  = Vector2(220, 46)
	_ki_label.add_theme_font_size_override("font_size", 11)
	_hud.add_child(_ki_label)

	# ── Bloque enemigo (top-right) ────────────────────────────────────────────
	_enemy_header          = Label.new()
	_enemy_header.text     = "ENEMIGO"
	_enemy_header.position = Vector2(910, 10)
	_enemy_header.add_theme_font_size_override("font_size", 11)
	_enemy_header.add_theme_color_override("font_color", Color(1.0, 0.6, 0.5))
	_hud.add_child(_enemy_header)

	_enemy_hp_bar_bg           = ColorRect.new()
	_enemy_hp_bar_bg.color      = Color(0.15, 0.08, 0.08)
	_enemy_hp_bar_bg.size       = Vector2(220, 16)
	_enemy_hp_bar_bg.position   = Vector2(910, 26)
	_hud.add_child(_enemy_hp_bar_bg)

	_enemy_hp_bar_fill          = ColorRect.new()
	_enemy_hp_bar_fill.color     = Color(0.9, 0.25, 0.2)
	_enemy_hp_bar_fill.size      = Vector2(220, 16)
	_enemy_hp_bar_fill.position  = Vector2(910, 26)
	_hud.add_child(_enemy_hp_bar_fill)

	_enemy_hp_label          = Label.new()
	_enemy_hp_label.position  = Vector2(910, 46)
	_enemy_hp_label.add_theme_font_size_override("font_size", 11)
	_hud.add_child(_enemy_hp_label)

	# ── Indicador de transformación (top-center, oculto) ─────────────────────
	_transform_bg          = ColorRect.new()
	_transform_bg.color     = Color(1.0, 0.9, 0.2, 0.25)
	_transform_bg.size      = Vector2(260, 28)
	_transform_bg.position  = Vector2(446, 12)
	_transform_bg.visible   = false
	_hud.add_child(_transform_bg)

	_transform_label          = Label.new()
	_transform_label.text      = ""
	_transform_label.position  = Vector2(452, 14)
	_transform_label.add_theme_font_size_override("font_size", 14)
	_transform_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.3))
	_transform_label.visible   = false
	_hud.add_child(_transform_label)

	# ── Indicador de vuelo (izquierda media) ──────────────────────────────────
	_fly_label          = Label.new()
	_fly_label.text      = "▲  VOLANDO"
	_fly_label.position  = Vector2(14, 96)
	_fly_label.add_theme_font_size_override("font_size", 12)
	_fly_label.add_theme_color_override("font_color", Color(0.6, 1.0, 0.9))
	_fly_label.visible   = false
	_hud.add_child(_fly_label)

	# ── Indicador de modo de cámara (top-right, bajo el bloque enemigo) ───────
	_camera_mode_label          = Label.new()
	_camera_mode_label.text     = "📷 [TAB] Jugador"
	_camera_mode_label.position = Vector2(910, 64)
	_camera_mode_label.add_theme_font_size_override("font_size", 12)
	_camera_mode_label.add_theme_color_override("font_color", Color(0.65, 0.85, 1.0))
	_hud.add_child(_camera_mode_label)

	# ── Botones de acción ─────────────────────────────────────────────────────
	var attack_btn     := Button.new()
	attack_btn.text     = "⚔ ATACAR  [Z]"
	attack_btn.size     = Vector2(155, 46)
	attack_btn.position = Vector2(340, 556)
	attack_btn.pressed.connect(_on_attack_pressed)
	_hud.add_child(attack_btn)

	var ki_btn         := Button.new()
	ki_btn.text         = "✦ KI BLAST  [X]"
	ki_btn.size         = Vector2(155, 46)
	ki_btn.position     = Vector2(505, 556)
	ki_btn.pressed.connect(_on_ki_blast_pressed)
	_hud.add_child(ki_btn)

	var charge_btn     := Button.new()
	charge_btn.text     = "⚡ CARGAR  [C]"
	charge_btn.size     = Vector2(140, 46)
	charge_btn.position = Vector2(670, 556)
	charge_btn.pressed.connect(_on_ki_charge_pressed)
	_hud.add_child(charge_btn)

	var fly_btn        := Button.new()
	fly_btn.text        = "▲ VOLAR  [SPACE]"
	fly_btn.size        = Vector2(155, 46)
	fly_btn.position    = Vector2(340, 504)
	fly_btn.pressed.connect(_on_fly_pressed)
	_hud.add_child(fly_btn)

	var transform_btn  := Button.new()
	transform_btn.text  = "✦ TRANSFORMAR  [T]"
	transform_btn.size  = Vector2(170, 46)
	transform_btn.position = Vector2(505, 504)
	transform_btn.pressed.connect(_on_transform_pressed)
	_hud.add_child(transform_btn)

	var flee_btn       := Button.new()
	flee_btn.text       = "🏃 HUIR  [ESC]"
	flee_btn.size       = Vector2(155, 46)
	flee_btn.position   = Vector2(686, 504)
	flee_btn.pressed.connect(_on_flee_pressed)
	_hud.add_child(flee_btn)

	# Línea de controles
	var info := Label.new()
	info.text     = "WASD: mover   Z: atacar   X: Ki   C: cargar   T: transform   Space: volar   ESC: huir   TAB: cámara   Scroll: zoom"
	info.position = Vector2(14, 612)
	info.add_theme_font_size_override("font_size", 10)
	info.add_theme_color_override("font_color", Color(0.55, 0.6, 0.65))
	_hud.add_child(info)

	var cam_info := Label.new()
	cam_info.text     = "Cámara Libre → IJKL: panear   R: centrar en jugador"
	cam_info.position = Vector2(14, 626)
	cam_info.add_theme_font_size_override("font_size", 10)
	cam_info.add_theme_color_override("font_color", Color(0.45, 0.5, 0.58))
	_hud.add_child(cam_info)

	# ── Panel de nivel de poder (bajo Ki bar) ─────────────────────────────────
	var pw_header       := Label.new()
	pw_header.text       = "PODER"
	pw_header.position   = Vector2(14, 66)
	pw_header.add_theme_font_size_override("font_size", 10)
	pw_header.add_theme_color_override("font_color", Color(0.8, 0.65, 1.0))
	_hud.add_child(pw_header)

	_power_label          = Label.new()
	_power_label.text      = "0"
	_power_label.position  = Vector2(56, 64)
	_power_label.add_theme_font_size_override("font_size", 12)
	_power_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.7))
	_hud.add_child(_power_label)

	_tier_label          = Label.new()
	_tier_label.text      = "Civil"
	_tier_label.position  = Vector2(140, 64)
	_tier_label.add_theme_font_size_override("font_size", 12)
	_hud.add_child(_tier_label)

	_tier_bar_bg          = ColorRect.new()
	_tier_bar_bg.color     = Color(0.12, 0.08, 0.18)
	_tier_bar_bg.size      = Vector2(120, 8)
	_tier_bar_bg.position  = Vector2(14, 82)
	_hud.add_child(_tier_bar_bg)

	_tier_bar_fill          = ColorRect.new()
	_tier_bar_fill.color     = Color(0.7, 0.4, 1.0)
	_tier_bar_fill.size      = Vector2(0, 8)
	_tier_bar_fill.position  = Vector2(14, 82)
	_hud.add_child(_tier_bar_fill)

	# ── Contador de combo (centro, alto de pantalla) ───────────────────────────
	_combo_bg           = ColorRect.new()
	_combo_bg.color      = Color(0.0, 0.0, 0.0, 0.45)
	_combo_bg.size       = Vector2(200, 52)
	_combo_bg.position   = Vector2(476, 110)
	_combo_bg.visible    = false
	_hud.add_child(_combo_bg)

	_combo_label          = Label.new()
	_combo_label.text      = ""
	_combo_label.position  = Vector2(480, 112)
	_combo_label.add_theme_font_size_override("font_size", 36)
	_combo_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))
	_combo_label.visible   = false
	_hud.add_child(_combo_label)

# ─────────────────────────────────────────────────────────────────────────────
# CÁMARA
# ─────────────────────────────────────────────────────────────────────────────

func _create_camera() -> void:
	_camera = CombatCamera.new()
	add_child(_camera)
	_camera.mode_changed.connect(_on_camera_mode_changed)

func _on_camera_mode_changed(mode_name: String) -> void:
	if is_instance_valid(_camera_mode_label):
		_camera_mode_label.text = "📷 [TAB] %s" % mode_name

# ─────────────────────────────────────────────────────────────────────────────
# COMBATE
# ─────────────────────────────────────────────────────────────────────────────

func _on_combat_started(difficulty: float) -> void:
	var day: int = GameStateProvider.get_character_data().current_day
	enemy.setup(difficulty, player, day)   # EnemyData seleccionado internamente
	_camera.setup(player, enemy)
	# Mostrar nombre del tipo de enemigo en la cabecera del HUD
	if is_instance_valid(_enemy_header) and enemy.enemy_data != null:
		_enemy_header.text = enemy.enemy_data.display_name.to_upper()
	# Números de daño flotantes sobre el jugador cuando recibe golpes
	if not player.health.hurt.is_connected(_on_player_hurt):
		player.health.hurt.connect(_on_player_hurt)
	# Rastrear daño infligido al enemigo
	if not enemy.damage_received.is_connected(_on_enemy_damage_received):
		enemy.damage_received.connect(_on_enemy_damage_received)
	# Resetear estadísticas de combate
	_damage_dealt    = 0.0
	_damage_received = 0.0
	_max_combo       = 0
	_update_hp_display(player.health.current_hp, player.health.get_max_hp(), true)
	_update_enemy_hp_display()
	_update_ki_bar(player.ki.current_ki, player.ki.get_max_ki())
	_update_power_level_display()
	_start_countdown()

func _start_countdown() -> void:
	var countdown          := Label.new()
	countdown.add_theme_font_size_override("font_size", 96)
	countdown.position      = Vector2(476, 220)
	countdown.modulate      = Color(1.0, 0.8, 0.0)
	countdown.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hud.add_child(countdown)

	for i in range(COMBAT_START_DELAY, 0, -1):
		countdown.text = str(i)
		await get_tree().create_timer(1.0).timeout

	countdown.text = "¡LUCHA!"
	await get_tree().create_timer(0.5).timeout
	countdown.queue_free()

	enemy.set_physics_process(true)
	_player_can_act = true
	_combat_active  = true

# ─────────────────────────────────────────────────────────────────────────────
# ACTUALIZACIÓN DE HUD
# ─────────────────────────────────────────────────────────────────────────────

## Actualiza la barra y texto de HP. is_player=true → jugador, false → enemigo.
func _update_hp_display(current: float, maximum: float, is_player: bool) -> void:
	var ratio: float   = clampf(current / maxf(maximum, 1.0), 0.0, 1.0)
	var bar_fill: ColorRect
	var label: Label
	if is_player:
		bar_fill = _player_hp_bar_fill
		label    = _hp_label
	else:
		bar_fill = _enemy_hp_bar_fill
		label    = _enemy_hp_label

	if is_instance_valid(bar_fill):
		bar_fill.size.x = 220.0 * ratio
		bar_fill.color  = _hp_bar_color(ratio)
	if is_instance_valid(label):
		label.text = "%.0f / %.0f" % [current, maximum]

func _update_enemy_hp_display() -> void:
	if is_instance_valid(enemy):
		_update_hp_display(enemy.current_health, enemy.max_health, false)

## Devuelve el color de la barra de HP según el ratio (verde→amarillo→rojo).
func _hp_bar_color(ratio: float) -> Color:
	if ratio > 0.6:
		return Color(0.18, 0.82, 0.30)       # verde
	elif ratio > 0.3:
		return Color(0.95, 0.80, 0.15)       # amarillo
	else:
		return Color(0.90, 0.22, 0.18)       # rojo

func _update_ki_bar(current: float, maximum: float) -> void:
	if not is_instance_valid(_ki_bar_fill):
		return
	var ratio: float = clampf(current / maxf(maximum, 1.0), 0.0, 1.0)
	_ki_bar_fill.size.x = 180.0 * ratio
	# Ki bar cambia de azul a dorado al ir cargándose
	_ki_bar_fill.color  = Color(0.3 + ratio * 0.6, 0.75 - ratio * 0.2, 1.0 - ratio * 0.7)
	if is_instance_valid(_ki_label):
		_ki_label.text = "%.0f / %.0f" % [current, maximum]

# ─────────────────────────────────────────────────────────────────────────────
# PROCESS — polling de estado de vuelo + HP del enemigo
# ─────────────────────────────────────────────────────────────────────────────

func _process(_delta: float) -> void:
	if not _combat_active:
		return

	# HP enemigo (se actualiza frecuentemente desde proceso)
	if is_instance_valid(enemy):
		_update_enemy_hp_display()

	# Indicador de vuelo — el nodo se llama "FlyState" en el árbol de escena
	if is_instance_valid(player) and is_instance_valid(_fly_label):
		var st := player.state_machine.current_state
		_fly_label.visible = (st != null and st.name == &"FlyState")

# ─────────────────────────────────────────────────────────────────────────────
# CALLBACKS DE SEÑALES
# ─────────────────────────────────────────────────────────────────────────────

func _on_player_hp_changed(current: float, maximum: float) -> void:
	_update_hp_display(current, maximum, true)

func _on_player_ki_changed(current: float, maximum: float) -> void:
	_update_ki_bar(current, maximum)

func _on_transformation_activated(_transform_id: StringName, definition) -> void:
	if not is_instance_valid(_transform_label) or definition == null:
		return
	# Obtener nombre (TransformationDefinition tiene display_name exportado)
	var def_name: String = str(_transform_id)
	if "display_name" in definition:
		def_name = definition.display_name
	_transform_label.text    = "✦  %s" % def_name
	_transform_label.visible = true
	_transform_bg.visible    = true
	# Colorear con el aura de la transformación
	if "aura_color" in definition:
		var c: Color = definition.aura_color
		_transform_bg.color = Color(c.r, c.g, c.b, 0.28)
		_transform_label.add_theme_color_override("font_color", c.lightened(0.35))

func _on_transformation_deactivated(_transform_id: StringName) -> void:
	if is_instance_valid(_transform_label):
		_transform_label.visible = false
	if is_instance_valid(_transform_bg):
		_transform_bg.visible    = false

## Llamada cuando el player recibe daño (HealthComponent.hurt).
## Muestra el número de daño en rojo sobre el jugador.
func _on_player_hurt(amount: float) -> void:
	_damage_received += amount
	_spawn_world_text(
		player.global_position + Vector2(0.0, -30.0),
		"-%.0f" % amount,
		Color(1.0, 0.25, 0.20),
		20,
		0.70
	)

func _on_enemy_damage_received(amount: float) -> void:
	_damage_dealt += amount

## Llamada por EventBus.combo_updated cada vez que un hit encadena o el combo se rompe.
func _on_combo_updated(count: int, _multiplier: float) -> void:
	if not is_instance_valid(_combo_label):
		return
	if count == 0:
		# Combo roto — desvanecer el contador
		var tw := _combo_label.create_tween()
		tw.tween_property(_combo_label, "modulate:a", 0.0, 0.35)
		tw.tween_callback(func() -> void:
			_combo_label.visible = false
			_combo_bg.visible    = false
		)
		return

	if count > _max_combo:
		_max_combo = count
	_combo_label.text      = "%d HIT%s" % [count, "!" if count >= 3 else ""]
	_combo_label.visible   = true
	_combo_bg.visible      = true
	_combo_label.modulate.a = 1.0
	# Color escala del amarillo al rojo al subir el combo
	var colors: Array[Color] = [
		Color(1.0, 0.9, 0.2),   # 1
		Color(1.0, 0.72, 0.1),  # 2
		Color(1.0, 0.45, 0.1),  # 3
		Color(1.0, 0.2, 0.6),   # 4
		Color(0.8, 0.2, 1.0),   # 5+
	]
	var cidx: int = min(count - 1, colors.size() - 1)
	_combo_label.add_theme_color_override("font_color", colors[cidx])
	# Efecto de "punch" en la escala
	var tw := _combo_label.create_tween()
	tw.tween_property(_combo_label, "scale", Vector2(1.30, 1.30), 0.06)
	tw.tween_property(_combo_label, "scale", Vector2(1.00, 1.00), 0.10)

func _update_power_level_display() -> void:
	var data = GameStateProvider.get_character_data()
	if data == null:
		return
	var tier_data: Dictionary = data.get_tier_data()
	if is_instance_valid(_power_label):
		_power_label.text = "%.0f" % tier_data.poder
	if is_instance_valid(_tier_label):
		_tier_label.text = tier_data.name
		_tier_label.add_theme_color_override("font_color", tier_data.color)
	if is_instance_valid(_tier_bar_fill):
		_tier_bar_fill.size.x = 120.0 * tier_data.progress
		_tier_bar_fill.color  = tier_data.color

# ─────────────────────────────────────────────────────────────────────────────
# OVERLAY DE RESULTADO
# ─────────────────────────────────────────────────────────────────────────────

func _show_result_overlay(won: bool) -> void:
	_overlay_layer = CanvasLayer.new()
	_overlay_layer.layer = 20
	add_child(_overlay_layer)

	# Fondo semitransparente
	var bg          := ColorRect.new()
	bg.color         = Color(0.0, 0.0, 0.0, 0.65)
	bg.size          = Vector2(1152, 648)
	_overlay_layer.add_child(bg)

	# Banner de resultado
	var banner_color: Color = Color(0.1, 0.75, 0.25) if won else Color(0.85, 0.15, 0.15)
	var banner          := ColorRect.new()
	banner.color         = Color(banner_color.r, banner_color.g, banner_color.b, 0.35)
	banner.size          = Vector2(500, 60)
	banner.position      = Vector2(326, 140)
	_overlay_layer.add_child(banner)

	var result_label          := Label.new()
	result_label.text          = "¡VICTORIA!" if won else "DERROTA"
	result_label.position      = Vector2(340, 144)
	result_label.add_theme_font_size_override("font_size", 42)
	result_label.add_theme_color_override("font_color", banner_color.lightened(0.4))
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.size          = Vector2(480, 56)
	_overlay_layer.add_child(result_label)

	# Estadísticas de combate
	var stats_y: float = 230.0
	var stat_lines: Array[String] = [
		"Daño infligido:    %.0f" % _damage_dealt,
		"Daño recibido:     %.0f" % _damage_received,
		"Combo máximo:      %d" % _max_combo,
	]
	for line in stat_lines:
		var lbl          := Label.new()
		lbl.text          = line
		lbl.position      = Vector2(400, stats_y)
		lbl.add_theme_font_size_override("font_size", 18)
		lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
		_overlay_layer.add_child(lbl)
		stats_y += 30.0

	# Nivel de poder
	var data = GameStateProvider.get_character_data()
	if data != null:
		var tier_data: Dictionary = data.get_tier_data()
		var poder_lbl      := Label.new()
		poder_lbl.text      = "Nivel de poder:  %.0f  (%s)" % [tier_data.poder, tier_data.name]
		poder_lbl.position  = Vector2(400, stats_y + 10.0)
		poder_lbl.add_theme_font_size_override("font_size", 18)
		poder_lbl.add_theme_color_override("font_color", tier_data.color.lightened(0.3))
		_overlay_layer.add_child(poder_lbl)

	# Temporizador de salida
	var timer_label          := Label.new()
	timer_label.position      = Vector2(440, 420)
	timer_label.add_theme_font_size_override("font_size", 16)
	timer_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
	_overlay_layer.add_child(timer_label)

	for i in range(3, 0, -1):
		timer_label.text = "Continuando en %d..." % i
		await get_tree().create_timer(1.0).timeout

	# Restaurar DayScreen y emitir resultado después del overlay
	_restore_day_screen()
	EventBus.combat_ended.emit(won)

## Texto flotante genérico en espacio mundo.
func _spawn_world_text(pos: Vector2, text: String, color: Color,
		font_size: int = 16, duration: float = 0.75) -> void:
	var label      := Label.new()
	label.text      = text
	label.position  = pos
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	add_child(label)   # espacio mundo — sigue la cámara
	var tween := label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 52.0, duration)
	tween.tween_property(label, "modulate:a", 0.0, duration)
	tween.tween_callback(label.queue_free)

func _on_attack_dodged(player_pos: Vector2) -> void:
	# Texto flotante en espacio mundo
	var label      := Label.new()
	label.text      = "ESQUIVADO"
	label.position  = player_pos + Vector2(-40, -60)
	label.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0))
	label.add_theme_font_size_override("font_size", 16)
	add_child(label)   # mundo, no HUD

	var tween := label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 40, 0.6)
	tween.tween_property(label, "modulate:a", 0.0, 0.6)
	tween.tween_callback(label.queue_free)

func _on_enemy_died() -> void:
	if not _combat_active: return
	print("[CombatArena] Enemy derrotado — Victoria.")
	_end_combat(true)
	_show_result_overlay(true)

func _on_player_died() -> void:
	if not _combat_active: return
	print("[CombatArena] Player derrotado — Derrota.")
	_end_combat(false)
	_show_result_overlay(false)

# ─────────────────────────────────────────────────────────────────────────────
# INPUT
# ─────────────────────────────────────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	if not _player_can_act: return
	if event.is_action_pressed("attack"):         _on_attack_pressed()
	elif event.is_action_pressed("ki_blast"):     _on_ki_blast_pressed()
	elif event.is_action_pressed("ki_charge"):    _on_ki_charge_pressed()
	elif event.is_action_pressed("transform"):    _on_transform_pressed()
	elif event.is_action_pressed("fly"):          _on_fly_pressed()
	elif event.is_action_pressed("ui_cancel"):    _on_flee_pressed()

func _on_attack_pressed() -> void:
	if not _player_can_act or not _combat_active: return
	player.state_machine.change_state(&"AttackState")

func _on_ki_blast_pressed() -> void:
	if not _player_can_act or not _combat_active: return
	player.state_machine.change_state(&"KiBlastState")

func _on_ki_charge_pressed() -> void:
	if not _player_can_act or not _combat_active: return
	player.state_machine.change_state(&"KiChargeState")

func _on_transform_pressed() -> void:
	if not _player_can_act or not _combat_active: return
	player.state_machine.change_state(&"TransformState")

func _on_fly_pressed() -> void:
	if not _player_can_act or not _combat_active: return
	player.state_machine.change_state(&"FlyState")

func _on_flee_pressed() -> void:
	if not _combat_active: return
	print("[CombatArena] Jugador huyó del combate.")
	_end_combat(false)
	_restore_day_screen()               # Huir restaura inmediatamente (sin overlay)
	EventBus.combat_ended.emit(false)

# ─────────────────────────────────────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────────────────────────────────────

func _register_input(action: StringName, keycode: int) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
		var ev     := InputEventKey.new()
		ev.keycode  = keycode
		InputMap.action_add_event(action, ev)

# ─────────────────────────────────────────────────────────────────────────────
# FIN DE COMBATE
# ─────────────────────────────────────────────────────────────────────────────

func _end_combat(_won: bool) -> void:
	_combat_active  = false
	_player_can_act = false
	enemy.set_physics_process(false)
	# _restore_day_screen() se llama en _show_result_overlay() o _on_flee_pressed()
	# para evitar que el DayScreen reaparezca mientras el overlay de resultado está activo.
	print("[CombatArena] Combate terminado.")

func _restore_day_screen() -> void:
	if _day_screen and is_instance_valid(_day_screen):
		_day_screen.visible = true
