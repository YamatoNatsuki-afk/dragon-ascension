# entities/player/components/StatsComponent.gd
#
# Mirror en runtime de los stats del personaje.
#
# RESPONSABILIDADES:
#   - Leer base_stats desde CharacterData y exponerlos al juego
#   - Gestionar modificadores temporales (buffs, debuffs, transformaciones)
#   - Notificar a la UI cuando cambian los stats via EventBus
#
# CONTRATO EXPLÍCITO:
#   - StatsComponent NUNCA escribe CharacterData.base_stats directamente.
#   - La única fuente de escritura de base_stats es DayManager._resolve().
#   - StatsComponent escucha day_action_resolved solo para notificar la UI,
#     no para aplicar cambios (DayManager ya los aplicó antes de emitir).
#
class_name StatsComponent
extends Node

@export var character_data: Resource  # CharacterData

# Modificadores temporales (buffs/debuffs): stat_id → valor acumulado delta.
# No se persisten en CharacterData — son solo para la sesión de combate actual.
var _modifiers: Dictionary = {}

# ─────────────────────────────────────────────────────────────────────────────
# INICIALIZACIÓN
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	# Si character_data viene del editor por @export, conectar directamente.
	# Si no, initialize_from_data() se llamará en runtime — sin assert aquí
	# porque ambas rutas son válidas dependiendo del contexto (editor vs runtime).
	if character_data != null:
		_connect_signals()

## Inicialización en runtime (CharacterData viene de GameStateProvider o SaveSystem).
## Llamar esto desde el nodo padre después de instanciar Player.tscn.
func initialize_from_data(data) -> void:  # data: CharacterData
	assert(data != null, "StatsComponent.initialize_from_data: data es null.")
	character_data = data
	_connect_signals()
	# Sincronizar la UI con el estado actual del personaje al entrar en escena.
	_broadcast_all_stats()

# ─────────────────────────────────────────────────────────────────────────────
# API PÚBLICA — GETTERS
# ─────────────────────────────────────────────────────────────────────────────

## Valor final de un stat: base (desde CharacterData) + modificadores temporales.
## Es el valor que deben usar HealthComponent, KiComponent, y el sistema de combate.
func get_stat(stat_id: StringName) -> float:
	if character_data == null:
		push_warning("StatsComponent.get_stat: character_data no inicializado. " +
			"¿Se llamó initialize_from_data()?")
		return 0.0
	var base: float = character_data.base_stats.get(stat_id, 0.0)
	var mod: float  = _modifiers.get(stat_id, 0.0)
	return base + mod

## Retorna true si el stat existe en CharacterData.
func has_stat(stat_id: StringName) -> bool:
	if character_data == null:
		return false
	return character_data.base_stats.has(stat_id)

# ─────────────────────────────────────────────────────────────────────────────
# API PÚBLICA — MODIFICADORES TEMPORALES
# Buffs y debuffs que duran solo durante el combate o una transformación.
# No persisten en CharacterData.
# ─────────────────────────────────────────────────────────────────────────────

## Añade un modificador temporal (buff de transformación, estados de combate, etc.).
func add_modifier(stat_id: StringName, amount: float) -> void:
	_modifiers[stat_id] = _modifiers.get(stat_id, 0.0) + amount
	EventBus.player_stats_changed.emit(stat_id, get_stat(stat_id))

## Elimina un modificador temporal específico.
func remove_modifier(stat_id: StringName, amount: float) -> void:
	_modifiers[stat_id] = _modifiers.get(stat_id, 0.0) - amount
	EventBus.player_stats_changed.emit(stat_id, get_stat(stat_id))

## Limpia todos los modificadores temporales.
## Llamar al salir de combate o al desactivar una transformación completa.
func clear_modifiers() -> void:
	_modifiers.clear()
	_broadcast_all_stats()

# ─────────────────────────────────────────────────────────────────────────────
# PRIVADO
# ─────────────────────────────────────────────────────────────────────────────

## Conecta las señales del EventBus.
## Protegido contra doble conexión — seguro llamarlo más de una vez.
func _connect_signals() -> void:
	if not EventBus.day_action_resolved.is_connected(_on_day_action_resolved):
		EventBus.day_action_resolved.connect(_on_day_action_resolved)

## Emite player_stats_changed para todos los stats actuales.
## Sirve para sincronizar el HUD al inicializar o al limpiar modificadores.
func _broadcast_all_stats() -> void:
	for stat_id: StringName in character_data.base_stats.keys():
		EventBus.player_stats_changed.emit(stat_id, get_stat(stat_id))

## Receptor de la resolución del día (EventBus.day_action_resolved).
##
## IMPORTANTE: DayManager ya aplicó los cambios a CharacterData.base_stats
## antes de emitir esta señal. Esta función SOLO notifica a la UI.
## Aplicar los cambios aquí sería una doble escritura — no hacerlo.
func _on_day_action_resolved(_action: DayAction, result: DayActionResult) -> void:
	if character_data == null:
		return

	# Notificar solo los stats que cambiaron — evitar emitir señales innecesarias.
	for stat_id: StringName in result.stat_changes.keys():
		if result.stat_changes[stat_id] != 0.0:
			# get_stat() lee el valor ya actualizado en CharacterData por DayManager.
			EventBus.player_stats_changed.emit(stat_id, get_stat(stat_id))

	if result.xp_gained > 0.0:
		EventBus.xp_gained.emit(result.xp_gained, character_data.experience)
