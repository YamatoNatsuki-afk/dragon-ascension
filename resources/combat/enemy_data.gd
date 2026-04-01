# res://resources/combat/enemy_data.gd
# LEGACY — Reemplazado por data/enemies/EnemyData.gd
# class_name removida para evitar conflicto con el nuevo EnemyData global.
extends Resource

@export var enemy_name: String = "Saibaman"
@export var base_health: int = 100
@export var base_attack: int = 15
@export var base_defense: int = 5
@export var base_ki: int = 50
@export var exp_reward: int = 30
@export var level: int = 1

# Escala stats según el día actual — centralizado aquí, no en el enemy
func get_scaled_health(day: int) -> int:
	return base_health + (day * 2)

func get_scaled_attack(day: int) -> int:
	return base_attack + day
