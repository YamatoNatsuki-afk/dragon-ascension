# entities/player/states/PlayerState.gd
# Clase base para todos los estados del jugador.
# Cada estado solo conoce al Player — no a otros estados.
class_name PlayerState
extends Node

# Referencia al jugador dueño de esta máquina.
# Se asigna desde PlayerStateMachine al inicializar.
var player: CharacterBody2D

## Llamado al ENTRAR al estado.
func enter(_previous_state: PlayerState = null) -> void:
	pass

## Llamado al SALIR del estado.
func exit() -> void:
	pass

## Lógica de física (equivalente a _physics_process).
func physics_update(_delta: float) -> void:
	pass

## Lógica de frame (equivalente a _process).
func update(_delta: float) -> void:
	pass

## Manejo de input (equivalente a _input).
func handle_input(_event: InputEvent) -> void:
	pass
