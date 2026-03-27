# entities/player/components/HealthComponent.gd
# Gestiona los HP del jugador en combate.
# Responsabilidad única: tomar daño, sanar, reportar estado.
#
# INICIALIZACIÓN:
#   NO inicializa en _ready() — CharacterData no está disponible todavía.
#   Player.setup() llama initialize() después de que StatsComponent
#   tenga datos reales. Este orden es obligatorio.
#
class_name HealthComponent
extends Node

# Referencia inyectada por Player._ready() — nunca null al llegar a initialize().
var stats: StatsComponent

var current_hp: float = 0.0

# ─────────────────────────────────────────────────────────────────────────────
# INICIALIZACIÓN
# ─────────────────────────────────────────────────────────────────────────────

## Inicializa HP al máximo. Llamado por Player.setup() después de
## que StatsComponent tiene CharacterData cargado.
func initialize() -> void:
	assert(stats != null,
		"HealthComponent.initialize: stats es null. " +
		"¿Player._ready() cableó health.stats = stats?")
	current_hp = stats.get_stat(&"health_max")
	EventBus.player_health_changed.emit(current_hp, stats.get_stat(&"health_max"))

# ─────────────────────────────────────────────────────────────────────────────
# API DE COMBATE
# ─────────────────────────────────────────────────────────────────────────────

func take_damage(amount: float, type: String = "physical") -> void:
	var defense:   float = stats.get_stat(&"defense")
	var mitigated: float = maxf(0.0, amount - defense * 0.1)
	current_hp = maxf(0.0, current_hp - mitigated)

	EventBus.damage_dealt.emit(get_parent(), mitigated, type)
	EventBus.player_health_changed.emit(current_hp, stats.get_stat(&"health_max"))

	if current_hp <= 0.0:
		EventBus.player_died.emit()

func heal(amount: float) -> void:
	current_hp = minf(stats.get_stat(&"health_max"), current_hp + amount)
	EventBus.player_health_changed.emit(current_hp, stats.get_stat(&"health_max"))

func is_dead() -> bool:
	return current_hp <= 0.0
