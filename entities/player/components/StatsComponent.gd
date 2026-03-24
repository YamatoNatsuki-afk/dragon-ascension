# entities/player/components/StatsComponent.gd
# Gestiona los stats en runtime: lee CharacterData, aplica modificadores.
# Es un Node hijo del Player — no un autoload.
class_name StatsComponent
extends Node

@export var character_data: CharacterData

# Modificadores temporales (buffs/debuffs): stat_id → valor acumulado
var _modifiers: Dictionary = {}

func _ready() -> void:
	assert(character_data != null, "StatsComponent: CharacterData no asignado.")
	# Conectar al EventBus para aplicar resultados del día
	EventBus.day_action_resolved.connect(_on_day_action_resolved)
	
## Obtiene el valor final de un stat (base + modificadores).
func get_stat(stat_id: StringName) -> float:  # <- el "-> float" es obligatorio
	var base: float = character_data.stats.get(stat_id, 0.0)
	var mod: float  = _modifiers.get(stat_id, 0.0)
	return base + mod

## Modifica el stat BASE permanentemente (entrenamiento, level up).
func add_to_base(stat_id: StringName, amount: float) -> void:
	if not character_data.stats.has(stat_id):
		push_warning("StatsComponent: stat '%s' no existe en CharacterData." % stat_id)
		return
	character_data.stats[stat_id] += amount
	EventBus.player_stats_changed.emit(stat_id, get_stat(stat_id))

## Añade un modificador temporal (buff de transformación, etc.).
func add_modifier(stat_id: StringName, amount: float) -> void:
	_modifiers[stat_id] = _modifiers.get(stat_id, 0.0) + amount
	EventBus.player_stats_changed.emit(stat_id, get_stat(stat_id))

## Elimina un modificador específico.
func remove_modifier(stat_id: StringName, amount: float) -> void:
	_modifiers[stat_id] = _modifiers.get(stat_id, 0.0) - amount
	EventBus.player_stats_changed.emit(stat_id, get_stat(stat_id))

func initialize_from_data(data: CharacterData) -> void:
	assert(data != null, "StatsComponent.initialize_from_data: data es null.")
	character_data = data
	# Notificar al EventBus para que el HUD y otros sistemas se actualicen
	for stat_id: StringName in character_data.base_stats.keys():
		EventBus.player_stats_changed.emit(stat_id, get_stat(stat_id))
func _on_day_action_resolved(_action: DayAction, result: DayActionResult) -> void:
	for stat_id: StringName in result.stat_changes.keys():
		var delta: float = result.stat_changes[stat_id]
		if delta != 0.0:
			add_to_base(stat_id, delta)

	if result.xp_gained > 0.0:
		EventBus.xp_gained.emit(result.xp_gained, character_data.experience)
