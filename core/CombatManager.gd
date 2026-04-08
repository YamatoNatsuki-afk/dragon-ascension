# res://core/CombatManager.gd
# Autoload. El puente entre el loop de días y el combate en tiempo real.
#
# v2: Conecta TransformationSystem al inicio/fin de cada combate.
#   start_combat() → TransformationSystem.start_combat(player, data)
#   _finish_combat() → TransformationSystem.end_combat()
extends Node

const COMBAT_SCENE_PATH := "res://scenes/combat_arena/CombatArena.tscn"

var _combat_active:       bool  = false
var _combat_scene:        Node  = null

## HP ratio del jugador al finalizar el último combate real.
## HealthComponent o Player lo registra via set_final_hp_ratio() antes de emitir combat_ended.
## DayManager._execute_combat() lo lee para propagar a DayActionResult.
var last_combat_hp_ratio: float = 1.0

## Llamado por HealthComponent o Player justo antes de emitir combat_ended.
## Permite que DayManager sepa si el jugador llegó near-death.
func set_final_hp_ratio(ratio: float) -> void:
	last_combat_hp_ratio = clampf(ratio, 0.0, 1.0)

func start_combat(difficulty: float = 1.0) -> void:
	last_combat_hp_ratio = 1.0   # reset antes de cada combate
	if _combat_active:
		push_warning("CombatManager.start_combat: ya hay un combate activo.")
		return

	var data = GameStateProvider.get_character_data()
	if data == null:
		push_error("CombatManager.start_combat: CharacterData es null.")
		EventBus.combat_result_ready.emit(false)
		return

	if not ResourceLoader.exists(COMBAT_SCENE_PATH):
		push_error("CombatManager.start_combat: CombatArena no encontrada en '%s'." \
			% COMBAT_SCENE_PATH)
		EventBus.combat_result_ready.emit(false)
		return

	_combat_active = true

	_combat_scene      = load(COMBAT_SCENE_PATH).instantiate()
	_combat_scene.name = "CombatArena"
	get_tree().root.add_child(_combat_scene)

	var player: Player = _find_player(_combat_scene)
	if player == null:
		push_error("CombatManager: nodo Player no encontrado en CombatArena.")
		_abort_combat()
		return

	player.setup(data)

	# Conectar TransformationSystem al combate actual
	var ts := get_node_or_null("/root/TransformationSystem")
	if ts != null:
		ts.start_combat(player, data)
	else:
		push_warning("[CombatManager] TransformationSystem no encontrado — transformaciones desactivadas.")

	if not EventBus.combat_ended.is_connected(_on_combat_ended):
		EventBus.combat_ended.connect(_on_combat_ended, CONNECT_ONE_SHOT)
	if not EventBus.player_died.is_connected(_on_player_died):
		EventBus.player_died.connect(_on_player_died, CONNECT_ONE_SHOT)

	# Emitir DESPUÉS de conectar — CombatArena escucha este evento en _ready()
	EventBus.combat_started.emit(difficulty)

	print("[CombatManager] Combate iniciado. Dificultad: %.2f | Personaje: %s | Día: %d" % [
		difficulty, data.character_name, data.current_day
	])

func force_end_combat(won: bool = false) -> void:
	if not _combat_active:
		return
	_finish_combat(won)

func _find_player(scene: Node) -> Player:
	if scene is Player:
		return scene as Player
	for child: Node in scene.get_children():
		if child is Player:
			return child as Player
	return null

func _on_combat_ended(won: bool) -> void:
	_finish_combat(won)

func _on_player_died() -> void:
	# No-op: CombatArena muestra el overlay de resultado y luego emite combat_ended.
	pass

func _finish_combat(won: bool) -> void:
	if not _combat_active:
		return

	# Desconectar TransformationSystem — limpia modificadores y aplica penalización
	var ts := get_node_or_null("/root/TransformationSystem")
	if ts != null:
		ts.end_combat()

	print("[CombatManager] Combate terminado. Resultado: %s" % ("Victoria" if won else "Derrota"))
	_unload_combat_scene()
	_combat_active = false
	EventBus.combat_result_ready.emit(won)

func _unload_combat_scene() -> void:
	if _combat_scene != null and is_instance_valid(_combat_scene):
		_combat_scene.queue_free()
	_combat_scene = null

func _abort_combat() -> void:
	_unload_combat_scene()
	_combat_active = false
	push_error("CombatManager: combate abortado.")
	EventBus.combat_result_ready.emit(false)
