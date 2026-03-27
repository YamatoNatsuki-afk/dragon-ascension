# entities/player/components/KiComponent.gd
# Gestiona el Ki del jugador en combate.
# Responsabilidad única: gastar, recuperar Ki, reportar estado.
#
# INICIALIZACIÓN:
#   NO inicializa en _ready() — CharacterData no está disponible todavía.
#   Player.setup() llama initialize() después de que StatsComponent
#   tenga datos reales. Este orden es obligatorio.
#
class_name KiComponent
extends Node

# Referencia inyectada por Player._ready() — nunca null al llegar a initialize().
var stats: StatsComponent

var current_ki: float = 0.0

# ─────────────────────────────────────────────────────────────────────────────
# INICIALIZACIÓN
# ─────────────────────────────────────────────────────────────────────────────

## Inicializa Ki al máximo. Llamado por Player.setup() después de
## que StatsComponent tiene CharacterData cargado.
func initialize() -> void:
	assert(stats != null,
		"KiComponent.initialize: stats es null. " +
		"¿Player._ready() cableó ki.stats = stats?")
	current_ki = stats.get_stat(&"ki_max")
	EventBus.player_ki_changed.emit(current_ki, stats.get_stat(&"ki_max"))

# ─────────────────────────────────────────────────────────────────────────────
# API DE COMBATE
# ─────────────────────────────────────────────────────────────────────────────

## Gasta Ki. Retorna false si no hay suficiente — el caller decide qué hacer.
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
