# res://entities/Enemy/Enemy.gd
#
# IA de enemigo con escalado por día y dificultad.
#
# ESQUIVE:
#   Antes de aplicar daño, Enemy consulta los stats del Player.
#   Si el roll de esquive pasa, el golpe no conecta y se emite una señal visual.
#   El Player no sabe nada de este cálculo — Enemy es el responsable de decidir
#   si su ataque conecta, igual que en un sistema de D&D (el atacante tira contra
#   la defensa del objetivo).
#
# FÓRMULA DE ESQUIVE:
#   dodge_vel = velocidad     / (velocidad     + 100) × 0.50  → cap ~50%
#   dodge_ic  = intel_combate / (intel_combate + 50)  × 0.30  → cap ~30%
#   dodge_total = min(dodge_vel + dodge_ic, 0.75)             → hard cap 75%
#
# Con velocidad=60, intel_combate=6  → ~22% de esquive
# Con velocidad=60, intel_combate=40 → ~32% de esquive
# Con velocidad=120, intel_combate=60 → ~55% de esquive

class_name Enemy
extends CharacterBody2D

var max_health:      float = 100.0
var current_health:  float = 100.0
var attack_power:    float = 15.0
var move_speed:      float = 80.0
var attack_range:    float = 48.0
var attack_cooldown: float = 1.2
var resistencia:     float = 10.0

var _player: CharacterBody2D = null
var _attack_timer: float     = 0.0
var _is_dead: bool           = false

signal died
## Emitida cuando el player esquiva — CombatArena escucha para el efecto visual.
signal attack_dodged(player_position: Vector2)

# ─────────────────────────────────────────────────────────────────────────────
# Setup
# ─────────────────────────────────────────────────────────────────────────────

## Curva de escalado (difficulty=1.0):
##   Día  1: HP  58, ATK  8.4, RES  5
##   Día 50: HP 400, ATK 28,   RES 30
##   Día100: HP 750, ATK 48,   RES 55
func setup(difficulty: float, player_ref: CharacterBody2D, day: int = 1) -> void:
	_player        = player_ref
	max_health     = (50.0 + day * 7.0)  * difficulty
	current_health = max_health
	attack_power   = (8.0  + day * 0.4)  * difficulty
	move_speed     = (60.0 + day * 0.3)  + (difficulty * 15.0)
	resistencia    = (5.0  + day * 0.5)

# ─────────────────────────────────────────────────────────────────────────────
# Loop de física
# ─────────────────────────────────────────────────────────────────────────────

func _physics_process(delta: float) -> void:
	if _is_dead or _player == null:
		return

	_attack_timer -= delta
	var distance := global_position.distance_to(_player.global_position)

	if distance <= attack_range and _attack_timer <= 0.0:
		_try_attack()
	else:
		_move_toward_player()

	move_and_slide()

func _move_toward_player() -> void:
	velocity = (_player.global_position - global_position).normalized() * move_speed

# ─────────────────────────────────────────────────────────────────────────────
# Sistema de ataque y esquive
# ─────────────────────────────────────────────────────────────────────────────

func _try_attack() -> void:
	_attack_timer = attack_cooldown
	velocity      = Vector2.ZERO

	# Calcular probabilidad de esquive del player antes de aplicar daño.
	var dodge_chance := _get_player_dodge_chance()

	if dodge_chance > 0.0 and randf() < dodge_chance:
		# El player esquivó — emitir señal para efecto visual, no aplicar daño.
		attack_dodged.emit(_player.global_position)
		print("[Enemy] Ataque esquivado! (chance: %.0f%%)" % (dodge_chance * 100.0))
		return

	_deal_damage_to_player()

## Calcula la probabilidad de esquive basada en los stats del player.
## Retorna 0.0 si no puede leer los stats (failsafe).
func _get_player_dodge_chance() -> float:
	# Intentar leer StatsComponent del player.
	# El Player expone 'stats' como propiedad pública.
	var stats_component = _player.get("stats")
	if stats_component == null:
		return 0.0

	var velocidad: float      = stats_component.get_stat(&"velocidad")
	var intel_combate: float  = stats_component.get_stat(&"intel_combate")

	# Contribución de velocidad: rango 0–50% con diminishing returns.
	# A velocidad=100: 100/(100+100)*0.50 = 25%
	# A velocidad=200: 200/(200+100)*0.50 = 33%
	var dodge_vel: float = (velocidad / (velocidad + 100.0)) * 0.50

	# Contribución de intel_combate: rango 0–30%.
	# Umbral más bajo (50) porque intel_combate sube más despacio.
	# A ic=20: 20/(20+50)*0.30 = 8.6%
	# A ic=50: 50/(50+50)*0.30 = 15%
	var dodge_ic: float = (intel_combate / (intel_combate + 50.0)) * 0.30

	# Hard cap: máximo 75% de esquive para que el combate nunca sea trivial.
	return minf(dodge_vel + dodge_ic, 0.75)

func _deal_damage_to_player() -> void:
	if _player.has_method("take_damage"):
		_player.take_damage(attack_power)
	elif _player.get("health") != null:
		_player.health.take_damage(attack_power)

# ─────────────────────────────────────────────────────────────────────────────
# Recibir daño
# ─────────────────────────────────────────────────────────────────────────────

func take_damage(amount: float) -> void:
	if _is_dead:
		return
	var mitigation := resistencia / (resistencia + 100.0)
	var final_dmg  := amount * (1.0 - mitigation)
	current_health  = maxf(0.0, current_health - final_dmg)
	if current_health <= 0.0:
		_die()

func _die() -> void:
	if _is_dead: return
	_is_dead = true
	velocity  = Vector2.ZERO
	died.emit()

func get_health_percent() -> float:
	return current_health / max_health if max_health > 0.0 else 0.0
