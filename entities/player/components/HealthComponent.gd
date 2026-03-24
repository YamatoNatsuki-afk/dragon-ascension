# entities/player/components/HealthComponent.gd
# Responsabilidad única: gestionar HP. No sabe de animaciones ni input.
class_name HealthComponent
extends Node

@export var stats: StatsComponent  # Referencia al componente de stats

var current_hp: float

func _ready() -> void:
	current_hp = stats.get_stat(&"health_max")

func take_damage(amount: float, type: String = "physical") -> void:
	var defense: float = stats.get_stat(&"defense")  # <- tipo explícito
	var mitigated: float = maxf(0.0, amount - defense * 0.1)
	current_hp = maxf(0.0, current_hp - mitigated)

	EventBus.damage_dealt.emit(get_parent(), mitigated, type)
	EventBus.player_health_changed.emit(current_hp, stats.get_stat(&"health_max"))

	if current_hp <= 0.0:
		EventBus.player_died.emit()

func heal(amount: float) -> void:
	current_hp = min(stats.get_stat(&"health_max"), current_hp + amount)
	EventBus.player_health_changed.emit(current_hp, stats.get_stat(&"health_max"))

func is_dead() -> bool:
	return current_hp <= 0.0
