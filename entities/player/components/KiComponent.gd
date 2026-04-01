# res://entities/player/components/KiComponent.gd
#
# Gestiona el Ki del jugador en combate.
# Responsabilidad: gastar, recuperar, regenerar Ki y notificar a la UI.
#
# FIX v2: El bug original leía &"ki_max" que no existe en CharacterData.
#   El stat correcto es &"ki". CombatFormulas.get_max_ki() lo convierte
#   a Ki máximo real usando la fórmula: ki*6.0 + poder_ki*3.0
#
# REGENERACIÓN PASIVA:
#   _process() acumula regen cada frame basado en CombatFormulas.get_ki_regen().
#   Se activa automáticamente al inicializar. No requiere ningún input.
#
# RECARGA ACTIVA:
#   charge_tick(delta) debe llamarse desde KiChargeState para regen acelerada.
#   5× la regen pasiva según CombatFormulas.get_ki_charge_rate().
#
# INICIALIZACIÓN:
#   NO inicializa en _ready() — CharacterData no está disponible todavía.
#   Player.setup() llama initialize() después de que StatsComponent
#   tenga datos reales. Este orden es obligatorio.
#
class_name KiComponent
extends Node

# Referencia inyectada por Player._ready().
var stats: StatsComponent

var current_ki: float = 0.0

# Acumulador interno para la regen pasiva.
# Evita emitir señales de EventBus en cada frame — solo cuando hay cambio real.
var _regen_accum: float = 0.0

# ─────────────────────────────────────────────────────────────────────────────
# INICIALIZACIÓN
# ─────────────────────────────────────────────────────────────────────────────

## Inicializa Ki al máximo. Llamado por Player.setup() después de
## que StatsComponent tiene CharacterData cargado.
func initialize() -> void:
	assert(stats != null,
		"KiComponent.initialize: stats es null. " +
		"¿Player._ready() cableó ki.stats = stats?")
	current_ki = _get_max_ki()
	EventBus.player_ki_changed.emit(current_ki, _get_max_ki())

# ─────────────────────────────────────────────────────────────────────────────
# REGEN PASIVA
# ─────────────────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	if stats == null:
		return
	var max_ki := _get_max_ki()
	if current_ki >= max_ki:
		return

	_regen_accum += CombatFormulas.get_ki_regen(stats.get_stat(&"ki")) * delta

	# Aplicar solo cuando hay al menos 1 unidad acumulada — evita spam de señales.
	if _regen_accum >= 1.0:
		var to_recover := floorf(_regen_accum)
		_regen_accum  -= to_recover
		_apply_recover(to_recover)

# ─────────────────────────────────────────────────────────────────────────────
# API DE COMBATE
# ─────────────────────────────────────────────────────────────────────────────

## Gasta Ki. Retorna false si no hay suficiente — el caller decide qué hacer.
func spend(amount: float) -> bool:
	if current_ki < amount:
		return false
	current_ki -= amount
	EventBus.player_ki_changed.emit(current_ki, _get_max_ki())
	return true

## Recupera Ki externamente (pociones, eventos, etc.).
func recover(amount: float) -> void:
	_apply_recover(amount)

## Recarga activa — llamar desde KiChargeState en cada physics_update(delta).
## Usa la tasa acelerada (5× regen pasiva).
func charge_tick(delta: float) -> void:
	var rate := CombatFormulas.get_ki_charge_rate(stats.get_stat(&"ki"))
	_apply_recover(rate * delta)

func is_empty() -> bool:
	return current_ki <= 0.0

func get_max_ki() -> float:
	return _get_max_ki()

func get_fill_ratio() -> float:
	var max_ki := _get_max_ki()
	if max_ki <= 0.0:
		return 0.0
	return current_ki / max_ki

# ─────────────────────────────────────────────────────────────────────────────
# PRIVADO
# ─────────────────────────────────────────────────────────────────────────────

func _get_max_ki() -> float:
	# FIX: era stats.get_stat(&"ki_max") — stat inexistente en CharacterData.
	# Ahora usa CombatFormulas con los stats reales: ki y poder_ki.
	return CombatFormulas.get_max_ki(
		stats.get_stat(&"ki"),
		stats.get_stat(&"poder_ki")
	)

func _apply_recover(amount: float) -> void:
	var max_ki := _get_max_ki()
	var before := current_ki
	current_ki  = minf(current_ki + amount, max_ki)
	if current_ki != before:
		EventBus.player_ki_changed.emit(current_ki, max_ki)
