# core/CombatManager.gd
# Autoload. El puente entre el loop de días y el combate en tiempo real.
#
# RESPONSABILIDADES:
#   - Cargar y descargar la escena de combate
#   - Inyectar CharacterData al Player via Player.setup()
#   - Comunicar el resultado de vuelta al sistema que solicitó el combate
#
# CONTRATO CON EL DAY LOOP:
#   El combate puede ser solicitado de dos formas:
#
#   1. Desde la UI / GameManager (combate manual, menú de entrenamiento real):
#        CombatManager.start_combat(difficulty)
#
#   2. Desde DayManager (cuando una CombatEventAction desencadena combate real):
#        [futuro — Fase D] DayManager awaita EventBus.combat_ended antes de
#        llamar a _resolve(). Por ahora CombatEventAction sigue siendo stub.
#
# INVARIANTE:
#   Solo puede haber un combate activo a la vez. start_combat() es no-op
#   si _combat_active es true.
#
extends Node

const COMBAT_SCENE_PATH := "res://scenes/combat/CombatScene.tscn"

var _combat_active: bool = false
var _combat_scene:  Node = null

# ─────────────────────────────────────────────────────────────────────────────
# API PÚBLICA
# ─────────────────────────────────────────────────────────────────────────────

## Inicia un combate con la dificultad indicada.
## Carga CombatScene, inyecta CharacterData al Player y conecta las señales
## de fin de combate.
##
## difficulty: multiplicador de poder del enemigo (1.0 = balanceado al día actual)
func start_combat(difficulty: float = 1.0) -> void:
	if _combat_active:
		push_warning("CombatManager.start_combat: ya hay un combate activo.")
		return

	var data = GameStateProvider.get_character_data()  # CharacterData
	if data == null:
		push_error("CombatManager.start_combat: CharacterData es null. " +
			"¿DayManager.initialize() fue llamado?")
		return

	if not ResourceLoader.exists(COMBAT_SCENE_PATH):
		push_error("CombatManager.start_combat: CombatScene no encontrada en '%s'. " \
			% COMBAT_SCENE_PATH +
			"Crea la escena o actualiza COMBAT_SCENE_PATH.")
		return

	_combat_active = true

	# Cargar e instanciar la escena de combate
	_combat_scene = load(COMBAT_SCENE_PATH).instantiate()
	_combat_scene.name = "CombatScene"
	get_tree().root.add_child(_combat_scene)

	# ── EL PUENTE — inyectar CharacterData al Player ──────────────────────────
	# Player.setup() es el único punto de entrada de datos al combate.
	# Después de esta llamada, StatsComponent tiene los datos reales
	# y HealthComponent / KiComponent están inicializados con valores correctos.
	var player: Player = _find_player(_combat_scene)
	if player == null:
		push_error("CombatManager: nodo Player no encontrado en CombatScene. " +
			"¿El nodo raíz o un hijo directo tiene class_name Player?")
		_abort_combat()
		return

	player.setup(data)

	# ── Conectar señales de resultado ─────────────────────────────────────────
	# ONE_SHOT: se desconectan automáticamente al recibir la señal.
	# Evita acumulación de conexiones si start_combat() se llama varias veces.
	EventBus.combat_ended.connect(_on_combat_ended, CONNECT_ONE_SHOT)
	EventBus.player_died.connect(_on_player_died,   CONNECT_ONE_SHOT)

	EventBus.combat_started.emit(difficulty)
	print("[CombatManager] Combate iniciado. Dificultad: %.2f | Personaje: %s | Día: %d" % [
		difficulty, data.character_name, data.current_day
	])

## Termina el combate activo externamente (ej: pausa forzada, debug).
## En flujo normal el combate termina via EventBus.combat_ended o player_died.
func force_end_combat(won: bool = false) -> void:
	if not _combat_active:
		return
	_finish_combat(won)

# ─────────────────────────────────────────────────────────────────────────────
# PRIVADO
# ─────────────────────────────────────────────────────────────────────────────

## Busca el nodo Player en la escena de combate.
## Primero comprueba la raíz, luego los hijos directos.
## Esto da flexibilidad en cómo se estructura CombatScene.tscn.
func _find_player(scene: Node) -> Player:
	if scene is Player:
		return scene as Player
	for child: Node in scene.get_children():
		if child is Player:
			return child as Player
	return null

## Receptor de EventBus.combat_ended — victoria por lógica de combate.
func _on_combat_ended(won: bool) -> void:
	_finish_combat(won)

## Receptor de EventBus.player_died — derrota.
func _on_player_died() -> void:
	# Desconectar combat_ended si aún está conectado (puede no haberse emitido)
	if EventBus.combat_ended.is_connected(_on_combat_ended):
		EventBus.combat_ended.disconnect(_on_combat_ended)
	_finish_combat(false)

## Finaliza el combate: desarga escena, limpia estado, notifica resultado.
func _finish_combat(won: bool) -> void:
	if not _combat_active:
		return

	print("[CombatManager] Combate terminado. Resultado: %s" % ("Victoria" if won else "Derrota"))

	_unload_combat_scene()
	_combat_active = false

	# Notificar al sistema que solicitó el combate.
	# DayManager (Fase D) awaita esta señal para continuar el día.
	EventBus.combat_result_ready.emit(won)

## Descarga la escena de combate si existe.
func _unload_combat_scene() -> void:
	if _combat_scene != null and is_instance_valid(_combat_scene):
		_combat_scene.queue_free()
	_combat_scene = null

## Cancela un combate que no pudo iniciarse correctamente.
func _abort_combat() -> void:
	_unload_combat_scene()
	_combat_active = false
	push_error("CombatManager: combate abortado por error de inicialización.")
