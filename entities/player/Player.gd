# res://entities/player/Player.gd
#
# Orquestador del personaje jugable. Delega en componentes y state machine.
#
# CONTRATO DE INICIALIZACIÓN:
#   1. _ready() cablea referencias entre componentes (sin leer datos todavía).
#   2. setup(data) es llamado externamente por CombatManager antes de que
#      el jugador sea visible o interactivo.
#   3. setup() inicializa los componentes en orden obligatorio:
#      stats → health → ki → señales → apariencia
#
# NUNCA leer stats, health ni ki en _ready() — CharacterData no está disponible
# hasta que setup() lo inyecta.

class_name Player
extends CharacterBody2D

@onready var state_machine: PlayerStateMachine = $PlayerStateMachine
@onready var stats:         StatsComponent     = $StatsComponent
@onready var health:        HealthComponent    = $HealthComponent
@onready var ki:            KiComponent        = $KiComponent

func _ready() -> void:
	# Cablear componentes entre sí.
	# HealthComponent y KiComponent necesitan StatsComponent para leer stats.
	# Se hace aquí porque _ready() de los hijos ya corrió — es seguro.
	health.stats = stats
	ki.stats     = stats

	# La state machine necesita la referencia al Player para acceder a componentes.
	state_machine.initialize(self)

func _physics_process(delta: float) -> void:
	state_machine.physics_update(delta)
	move_and_slide()

func _process(delta: float) -> void:
	state_machine.update(delta)

func _input(event: InputEvent) -> void:
	state_machine.handle_input(event)

## Punto de entrada único para inyectar CharacterData al Player.
## DEBE llamarse antes de que el jugador sea visible o interactivo.
## Llamado por CombatManager después de instanciar Player.tscn.
func setup(data) -> void:  # data: CharacterData
	assert(data != null, "Player.setup: CharacterData es null.")

	# Orden obligatorio:
	# 1. Stats primero — HealthComponent y KiComponent leen de aquí.
	stats.initialize_from_data(data)

	# 2. Health y Ki después — ahora stats tiene datos reales.
	health.initialize()
	ki.initialize()

	# 3. Conectar señal hurt DESPUÉS de initialize() para que current_hp
	#    ya esté calculado cuando llegue el primer golpe.
	#    Desconectar antes de reconectar — seguro si setup() se llama más de una vez.
	if health.hurt.is_connected(_on_hurt):
		health.hurt.disconnect(_on_hurt)
	health.hurt.connect(_on_hurt)

	# 4. Apariencia al final — no depende de stats ni de health.
	_apply_appearance(data.appearance)

# ─────────────────────────────────────────────────────────────────────────────
# CALLBACKS DE COMPONENTES
# ─────────────────────────────────────────────────────────────────────────────

## Receptor de HealthComponent.hurt — activa HurtState al recibir daño.
##
## DISEÑO:
##   HealthComponent emite hurt(amount) después de aplicar mitigación.
##   Player decide qué hacer con esa información — en este caso, entrar a HurtState.
##   Separar la detección (HealthComponent) de la reacción (Player) mantiene
##   ambos componentes desacoplados y testables por separado.
##
## GUARD:
##   No transicionar si el player ya está muerto — evita entrar a HurtState
##   en el mismo frame que se emite player_died.
func _on_hurt(_amount: float) -> void:
	if health.is_dead():
		return
	state_machine.change_state(&"HurtState")

# ─────────────────────────────────────────────────────────────────────────────
# PRIVADO
# ─────────────────────────────────────────────────────────────────────────────

func _apply_appearance(appearance: AppearanceData) -> void:
	if appearance == null:
		return
	# Fase 4: aquí va shader de color, aura, etc.
	scale = Vector2.ONE * appearance.body_scale
