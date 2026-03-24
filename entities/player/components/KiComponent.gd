# entities/player/components/KiComponent.gd
class_name KiComponent
extends Node

@export var stats: StatsComponent

var current_ki: float

func _ready() -> void:
	assert(stats != null, "KiComponent: StatsComponent no asignado.")
	current_ki = stats.get_stat(&"ki_max")

func spend(amount: float) -> bool:
	if current_ki < amount:
		return false
	current_ki -= amount
	EventBus.player_ki_changed.emit(current_ki, stats.get_stat(&"ki_max"))
	return true

func recover(amount: float) -> void:
	current_ki = minf(current_ki + amount, stats.get_stat(&"ki_max"))
	EventBus.player_ki_changed.emit(current_ki, stats.get_stat(&"ki_max"))

func is_empty() -> bool:
	return current_ki <= 0.0
