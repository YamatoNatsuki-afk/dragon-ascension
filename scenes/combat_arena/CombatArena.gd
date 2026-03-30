# res://scenes/combat_arena/CombatArena.gd
extends Node2D

@onready var player: Player = $Player
@onready var enemy: Enemy   = $Enemy

const PLAYER_SPAWN       := Vector2(300.0, 300.0)
const ENEMY_SPAWN        := Vector2(700.0, 300.0)
const COMBAT_START_DELAY := 2

var _combat_active: bool  = false
var _player_can_act: bool = false
var _day_screen: Node     = null
var _hp_label: Label
var _enemy_hp_label: Label

func _ready() -> void:
	_day_screen = get_tree().root.get_node_or_null("DayScreen")
	if _day_screen:
		_day_screen.visible = false

	player.global_position = PLAYER_SPAWN
	enemy.global_position  = ENEMY_SPAWN
	enemy.set_physics_process(false)

	_create_ui()

	EventBus.combat_started.connect(_on_combat_started, CONNECT_ONE_SHOT)
	enemy.died.connect(_on_enemy_died)
	enemy.attack_dodged.connect(_on_attack_dodged)
	if not EventBus.player_died.is_connected(_on_player_died):
		EventBus.player_died.connect(_on_player_died, CONNECT_ONE_SHOT)
	EventBus.player_health_changed.connect(_on_player_hp_changed)

func _create_ui() -> void:
	var bg           := ColorRect.new()
	bg.color          = Color(0.08, 0.08, 0.12)
	bg.size           = Vector2(1152, 648)
	bg.position       = Vector2.ZERO
	add_child(bg)
	move_child(bg, 0)

	var pr           := ColorRect.new()
	pr.color          = Color(0.2, 0.5, 1.0)
	pr.size           = Vector2(32, 48)
	pr.position       = Vector2(-16, -24)
	player.add_child(pr)

	var er           := ColorRect.new()
	er.color          = Color(1.0, 0.2, 0.2)
	er.size           = Vector2(40, 48)
	er.position       = Vector2(-20, -24)
	enemy.add_child(er)

	_hp_label        = Label.new()
	_hp_label.position = Vector2(20, 20)
	_hp_label.add_theme_font_size_override("font_size", 18)
	add_child(_hp_label)

	_enemy_hp_label  = Label.new()
	_enemy_hp_label.position = Vector2(20, 50)
	_enemy_hp_label.add_theme_font_size_override("font_size", 18)
	add_child(_enemy_hp_label)

	var attack_btn   := Button.new()
	attack_btn.text   = "⚔ ATACAR  [Z]"
	attack_btn.size   = Vector2(160, 50)
	attack_btn.position = Vector2(460, 560)
	attack_btn.pressed.connect(_on_attack_pressed)
	add_child(attack_btn)

	var flee_btn     := Button.new()
	flee_btn.text     = "🏃 HUIR  [ESC]"
	flee_btn.size     = Vector2(160, 50)
	flee_btn.position = Vector2(640, 560)
	flee_btn.pressed.connect(_on_flee_pressed)
	add_child(flee_btn)

	var info         := Label.new()
	info.text         = "WASD: mover"
	info.position     = Vector2(460, 530)
	info.add_theme_font_size_override("font_size", 13)
	add_child(info)

func _on_combat_started(difficulty: float) -> void:
	var day: int = GameStateProvider.get_character_data().current_day
	enemy.setup(difficulty, player, day)
	_update_hp_labels()
	_start_countdown()

func _start_countdown() -> void:
	var countdown    := Label.new()
	countdown.add_theme_font_size_override("font_size", 96)
	countdown.position  = Vector2(520, 240)
	countdown.modulate  = Color(1.0, 0.8, 0.0)
	add_child(countdown)

	for i in range(COMBAT_START_DELAY, 0, -1):
		countdown.text = str(i)
		await get_tree().create_timer(1.0).timeout

	countdown.text = "¡LUCHA!"
	await get_tree().create_timer(0.5).timeout
	countdown.queue_free()

	enemy.set_physics_process(true)
	_player_can_act = true
	_combat_active  = true

func _update_hp_labels() -> void:
	var ph := player.health.current_hp
	# FIX: health_max era un stat ID eliminado. get_max_hp() es la fuente
	# canónica — derivada de vitalidad * 8 en HealthComponent.
	var pm := player.health.get_max_hp()
	_hp_label.text       = "Player HP: %.0f / %.0f" % [ph, pm]
	_enemy_hp_label.text = "Enemy HP: %.0f / %.0f" % [enemy.current_health, enemy.max_health]

func _process(_delta: float) -> void:
	if _combat_active and is_instance_valid(enemy):
		_enemy_hp_label.text = "Enemy HP: %.0f / %.0f" % [
			enemy.current_health, enemy.max_health
		]

func _on_player_hp_changed(current: float, maximum: float) -> void:
	if is_instance_valid(_hp_label):
		_hp_label.text = "Player HP: %.0f / %.0f" % [current, maximum]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and _player_can_act:
		_on_attack_pressed()
	if event.is_action_pressed("ui_cancel"):
		_on_flee_pressed()

func _on_attack_pressed() -> void:
	if not _player_can_act or not _combat_active:
		return
	player.state_machine.change_state(&"AttackState")

func _on_flee_pressed() -> void:
	if not _combat_active:
		return
	_end_combat(false)
	print("[CombatArena] Jugador huyó del combate.")
	EventBus.combat_ended.emit(false)

func _on_enemy_died() -> void:
	if not _combat_active:
		return
	print("[CombatArena] Enemy derrotado — Victoria.")
	_end_combat(true)
	EventBus.combat_ended.emit(true)

func _on_player_died() -> void:
	if not _combat_active:
		return
	print("[CombatArena] Player derrotado — Derrota.")
	_end_combat(false)

## Efecto visual de esquive: texto "ESQUIVADO" que sube y desaparece.
## Se spawnea sobre la posición del player para que sea legible sin saturar la UI.
func _on_attack_dodged(player_pos: Vector2) -> void:
	var label := Label.new()
	label.text     = "ESQUIVADO"
	label.position = player_pos + Vector2(-40, -60)
	label.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0))
	label.add_theme_font_size_override("font_size", 16)
	add_child(label)

	var tween := label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 40, 0.6)
	tween.tween_property(label, "modulate:a", 0.0, 0.6)
	tween.tween_callback(label.queue_free)

func _end_combat(won: bool) -> void:
	_combat_active  = false
	_player_can_act = false
	enemy.set_physics_process(false)
	_restore_day_screen()
	print("[CombatArena] Combate terminado. Resultado: %s" % ("Victoria" if won else "Derrota"))

func _restore_day_screen() -> void:
	if _day_screen and is_instance_valid(_day_screen):
		_day_screen.visible = true
