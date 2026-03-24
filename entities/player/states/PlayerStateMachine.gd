# entities/player/states/PlayerStateMachine.gd
# Orquesta los estados. No contiene lógica de gameplay.
class_name PlayerStateMachine
extends Node

@export var initial_state: PlayerState

var current_state: PlayerState
var _states: Dictionary = {}  # StringName → PlayerState

func initialize(p_player: CharacterBody2D) -> void:
	# Registra todos los estados hijos automáticamente
	for child in get_children():
		if child is PlayerState:
			child.player = p_player
			_states[child.name] = child

	assert(initial_state != null, "PlayerStateMachine: initial_state no asignado.")
	_transition_to(initial_state)

func _transition_to(new_state: PlayerState) -> void:
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter()

## Cambia de estado por nombre: state_machine.change_state(&"AttackState")
func change_state(state_name: StringName) -> void:
	if not _states.has(state_name):
		push_error("PlayerStateMachine: estado '%s' no encontrado." % state_name)
		return
	_transition_to(_states[state_name])

func physics_update(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func update(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func handle_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)
