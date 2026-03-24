# entities/player/Player.gd
# El Player ES un orquestador, no un "dios" que hace todo.
# Delega en componentes y state machine.
class_name Player
extends CharacterBody2D

# --- Componentes (asignados desde el inspector o _ready) ---
@onready var state_machine: PlayerStateMachine = $PlayerStateMachine
@onready var stats:         StatsComponent     = $StatsComponent
@onready var health:        HealthComponent    = $HealthComponent
@onready var ki:            KiComponent        = $KiComponent

func _ready() -> void:
	state_machine.initialize(self)

func _physics_process(delta: float) -> void:
	state_machine.physics_update(delta)
	move_and_slide()

func _process(delta: float) -> void:
	state_machine.update(delta)

func _input(event: InputEvent) -> void:
	state_machine.handle_input(event)

func setup(data: CharacterData) -> void:
	stats.initialize_from_data(data)
	_apply_appearance(data.appearance)

func _apply_appearance(appearance: AppearanceData) -> void:
	# Por ahora solo escala — en Fase 4 aquí va el shader de color y el aura
	scale = Vector2.ONE * appearance.body_scale
