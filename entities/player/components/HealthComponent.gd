# res://entities/player/components/HealthComponent.gd
#
# Gestiona los HP del jugador en combate.
#   HP max     = vitalidad * 8
#   Mitigación = resistencia / (resistencia + 100)  → diminishing returns
#
# SEÑALES:
#   hurt(amount)  → emitida tras cada golpe recibido (post-mitigación).
#                   Player conecta esta señal para transicionar a HurtState.
#                   Mantiene HealthComponent desacoplado de la StateMachine.

class_name HealthComponent
extends Node

## Emitida tras recibir daño. Player escucha esto para entrar a HurtState.
signal hurt(amount: float)

var stats: StatsComponent

var current_hp: float = 0.0

func initialize() -> void:
	assert(stats != null, "HealthComponent.initialize: stats es null.")
	current_hp = _get_max_hp()
	EventBus.player_health_changed.emit(current_hp, _get_max_hp())

func _get_max_hp() -> float:
	return stats.get_stat(&"vitalidad") * 8.0

func _get_mitigation() -> float:
	var res: float = stats.get_stat(&"resistencia")
	return res / (res + 100.0)

func take_damage(amount: float, type: String = "physical") -> void:
	var mitigation := _get_mitigation()
	var mitigated  := amount * (1.0 - mitigation)
	mitigated       = maxf(mitigated, 0.0)
	current_hp      = maxf(0.0, current_hp - mitigated)

	EventBus.damage_dealt.emit(get_parent(), mitigated, type)
	EventBus.player_health_changed.emit(current_hp, _get_max_hp())

	# Notificar al Player para que entre a HurtState.
	# Usamos señal en lugar de referencia directa para mantener
	# HealthComponent desacoplado de la StateMachine.
	# Player conecta esta señal en su setup():
	#   health.hurt.connect(_on_hurt)
	if mitigated > 0.0:
		hurt.emit(mitigated)

	if current_hp <= 0.0:
		EventBus.player_died.emit()

func heal(amount: float) -> void:
	current_hp = minf(_get_max_hp(), current_hp + amount)
	EventBus.player_health_changed.emit(current_hp, _get_max_hp())

func is_dead() -> bool:
	return current_hp <= 0.0

func get_max_hp() -> float:
	return _get_max_hp()
