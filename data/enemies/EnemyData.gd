# res://data/enemies/EnemyData.gd
#
# Define un arquetipo de enemigo: color, stats relativos a la curva base,
# comportamiento en combate y parámetros de Ki Blast.
#
# USO:
#   var data := EnemyData.get_for_day(day, difficulty)
#   enemy.setup(difficulty, player, day, data)
#
# COMPORTAMIENTOS:
#   MELEE  — persigue y golpea cuerpo a cuerpo
#   RANGED — mantiene distancia y dispara Ki Blasts
#   HYBRID — melé + Ki Blast ocasional
#
class_name EnemyData
extends Resource

enum Behavior { MELEE, RANGED, HYBRID }

@export var id:            StringName = &""
@export var display_name:  String     = "Enemigo"
@export var color:         Color      = Color(1.0, 0.2, 0.2)
@export var description:   String     = ""

# Multiplicadores sobre la curva de escalado base de Enemy.setup()
@export var hp_mult:           float = 1.0
@export var attack_mult:       float = 1.0
@export var speed_mult:        float = 1.0
@export var resistencia_mult:  float = 1.0
@export var cooldown_override: float = 0.0   # 0 = usar el valor por defecto

# Comportamiento
@export var behavior:          int   = Behavior.MELEE
@export var preferred_range:   float = 48.0    # distancia de combate deseada
@export var ki_blast_mult:     float = 0.7     # daño del Ki Blast como % del attack_power
@export var ki_blast_cooldown: float = 2.5     # segundos entre Ki Blasts

# ─────────────────────────────────────────────────────────────────────────────
# SELECCIÓN AUTOMÁTICA POR DÍA
# ─────────────────────────────────────────────────────────────────────────────

## Devuelve el arquetipo más apropiado según el día de juego y la dificultad.
static func get_for_day(day: int, difficulty: float = 1.0) -> EnemyData:
	if day <= 10 or difficulty < 0.4:
		return _civil()
	elif day <= 20:
		return _bandido()
	elif day <= 40:
		return _guerrero()
	elif day <= 65:
		return _guerrero_ki()
	else:
		return _elite()

## Devuelve todos los arquetipos canónicos (útil para debug/selección manual).
static func get_all() -> Array:
	return [_civil(), _bandido(), _guerrero(), _guerrero_ki(), _elite()]

# ─────────────────────────────────────────────────────────────────────────────
# ARQUETIPOS CANÓNICOS
# ─────────────────────────────────────────────────────────────────────────────

static func _civil() -> EnemyData:
	var d                 := EnemyData.new()
	d.id                   = &"civil"
	d.display_name         = "Civil"
	d.color                = Color(0.60, 0.60, 0.68)
	d.description          = "Un civil sin entrenamiento. Fácil de derrotar."
	d.hp_mult              = 0.60
	d.attack_mult          = 0.50
	d.speed_mult           = 0.70
	d.resistencia_mult     = 0.40
	d.behavior             = Behavior.MELEE
	d.preferred_range      = 44.0
	d.cooldown_override    = 1.9
	return d

static func _bandido() -> EnemyData:
	var d                 := EnemyData.new()
	d.id                   = &"bandido"
	d.display_name         = "Bandido"
	d.color                = Color(0.72, 0.42, 0.10)
	d.description          = "Bandido callejero. Agresivo pero sin técnica."
	d.hp_mult              = 0.78
	d.attack_mult          = 0.82
	d.speed_mult           = 1.10
	d.resistencia_mult     = 0.60
	d.behavior             = Behavior.MELEE
	d.preferred_range      = 40.0
	d.cooldown_override    = 1.1
	return d

static func _guerrero() -> EnemyData:
	var d                 := EnemyData.new()
	d.id                   = &"guerrero"
	d.display_name         = "Guerrero"
	d.color                = Color(0.90, 0.30, 0.18)
	d.description          = "Un guerrero entrenado. Equilibrado y peligroso."
	d.hp_mult              = 1.00
	d.attack_mult          = 1.00
	d.speed_mult           = 1.00
	d.resistencia_mult     = 1.00
	d.behavior             = Behavior.HYBRID
	d.preferred_range      = 48.0
	d.ki_blast_mult        = 0.55
	d.ki_blast_cooldown    = 3.2
	return d

static func _guerrero_ki() -> EnemyData:
	var d                 := EnemyData.new()
	d.id                   = &"guerrero_ki"
	d.display_name         = "Guerrero Ki"
	d.color                = Color(0.48, 0.20, 0.92)
	d.description          = "Experto en Ki. Mantiene distancia y dispara ráfagas de energía."
	d.hp_mult              = 0.82
	d.attack_mult          = 0.68
	d.speed_mult           = 0.88
	d.resistencia_mult     = 0.85
	d.behavior             = Behavior.RANGED
	d.preferred_range      = 145.0
	d.ki_blast_mult        = 1.20
	d.ki_blast_cooldown    = 1.7
	return d

static func _elite() -> EnemyData:
	var d                 := EnemyData.new()
	d.id                   = &"elite"
	d.display_name         = "Guerrero Élite"
	d.color                = Color(0.92, 0.10, 0.50)
	d.description          = "Un combatiente de élite. Rápido, fuerte y maestro del Ki."
	d.hp_mult              = 1.30
	d.attack_mult          = 1.22
	d.speed_mult           = 1.28
	d.resistencia_mult     = 1.18
	d.behavior             = Behavior.HYBRID
	d.preferred_range      = 72.0
	d.ki_blast_mult        = 1.00
	d.ki_blast_cooldown    = 2.0
	d.cooldown_override    = 0.88
	return d
