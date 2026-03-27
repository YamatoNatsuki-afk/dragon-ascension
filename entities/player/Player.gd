# entities/player/Player.gd
# Orquestador del personaje jugable. Delega en componentes y state machine.
#
# CONTRATO DE INICIALIZACIÓN:
#   1. _ready() cablea las referencias entre componentes (sin leer datos todavía).
#   2. setup(data) es llamado externamente por CombatManager antes de que
#      el jugador sea visible o interactivo.
#   3. setup() inicializa los componentes en orden correcto:
#      stats primero → health y ki después (dependen de stats).
#
# NUNCA leer stats, health ni ki en _ready() — CharacterData no está disponible
# hasta que setup() lo inyecta.
#
class_name Player
extends CharacterBody2D

@onready var state_machine: PlayerStateMachine = $PlayerStateMachine
@onready var stats:         StatsComponent     = $StatsComponent
@onready var health:        HealthComponent    = $HealthComponent
@onready var ki:            KiComponent        = $KiComponent

func _ready() -> void:
	# Cablear componentes entre sí.
	# HealthComponent y KiComponent necesitan la referencia a StatsComponent
	# para leer stats en runtime. Se hace aquí porque _ready() de los hijos
	# ya corrió — la asignación es segura y no requiere que CharacterData exista.
	#
	# Nota: esto podría hacerse también en el editor (NodePath en el inspector),
	# pero el cableado en código es más robusto ante cambios de estructura del .tscn.
	health.stats = stats
	ki.stats     = stats

	# La state machine necesita la referencia al Player para acceder a componentes.
	# Se inicializa al final, después de que todo esté cableado.
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

	# 3. Apariencia al final — no depende de stats.
	_apply_appearance(data.appearance)

func _apply_appearance(appearance: AppearanceData) -> void:
	if appearance == null:
		return
	# Fase 4: aquí va shader de color, aura, etc.
	scale = Vector2.ONE * appearance.body_scale
