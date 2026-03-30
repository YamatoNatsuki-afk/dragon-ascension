# res://resources/combat/combat_result.gd
class_name CombatResult
extends Resource

enum Outcome { VICTORY, DEFEAT, FLED }

@export var outcome: Outcome = Outcome.VICTORY
@export var exp_gained: int = 0
@export var damage_taken: int = 0
@export var ki_spent: int = 0
@export var turns_survived: int = 0

# Conveniencia para el DayManager — evita match repetitivos
func is_victory() -> bool:
	return outcome == Outcome.VICTORY
