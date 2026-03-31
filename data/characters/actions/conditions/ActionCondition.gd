# res://data/characters/actions/conditions/ActionCondition.gd
#
# Condición atómica evaluable contra un DayContext.
# Se usan en arrays en DayAction.conditions[].
#
# TIPOS ACTUALES:
#   DAY_MIN        → ctx.day_number >= value_int
#   FLAG_SET       → saved_flags[flag_id] == true
#   FLAG_UNSET     → saved_flags[flag_id] != true
#   STAT_MIN       → base_stats[stat_id] >= value_float
#
# TIPOS FUTUROS (declarados, no implementados):
#   NPC_AVAILABLE  → NpcRegistry.has(npc_id) — Fase C
#   IS_DEAD        → character_data tiene flag "is_dead" — Fase D
#   ALIGNMENT      → character_data.alignment == value_string — Fase D
#
# Diseño:
#   Cada condición es un Resource → se puede crear y editar en el Inspector de Godot.
#   Un DayAction evalúa su array completo con AND implícito.
#   Para OR, se crean múltiples DayAction con distintas condiciones.

class_name ActionCondition
extends Resource

enum Type {
	DAY_MIN,
	FLAG_SET,
	FLAG_UNSET,
	STAT_MIN,
	## Verdadero si el performance_ratio actual del personaje es >= value_float.
	## Calcula el ratio en el momento de la evaluación (sin caché).
	## Usar con value_float = 2.0 para eventos que solo aparecen cuando el jugador
	## va muy por encima de la curva esperada (ej: Desgaste por Poder).
	PERFORMANCE_RATIO_MIN,
	NPC_AVAILABLE,  # Fase C — siempre true por ahora
	IS_DEAD,        # Fase D — siempre false por ahora
	ALIGNMENT,      # Fase D — siempre true por ahora
}

@export var type: Type = Type.DAY_MIN

## Para FLAG_SET / FLAG_UNSET / NPC_AVAILABLE
@export var flag_id: StringName = &""

## Para STAT_MIN
@export var stat_id: StringName = &""

## Para DAY_MIN / valores enteros futuros
@export var value_int: int = 0

## Para STAT_MIN / valores float futuros
@export var value_float: float = 0.0

## Para ALIGNMENT (futuro)
@export var value_string: String = ""

# ─────────────────────────────────────────────────────────────────────────────

## Evalúa la condición contra el contexto del día.
## Retorna true si la condición se cumple.
func evaluate(ctx: DayContext) -> bool:
	match type:
		Type.DAY_MIN:
			return ctx.day_number >= value_int

		Type.FLAG_SET:
			return ctx.character_data.saved_flags.get(flag_id, false) == true

		Type.FLAG_UNSET:
			return ctx.character_data.saved_flags.get(flag_id, false) != true

		Type.STAT_MIN:
			return ctx.character_data.base_stats.get(stat_id, 0.0) >= value_float

		Type.PERFORMANCE_RATIO_MIN:
			# PerformanceEvaluator es clase estática pura (RefCounted) — sin dependencia circular.
			# Calcula: compute_power_score(data) / max(1.0, expected_score(day)).
			var ratio := PerformanceEvaluator.performance_ratio(ctx.character_data)
			return ratio >= value_float

		Type.NPC_AVAILABLE:
			# Fase C: cuando NpcRegistry exista, consultar aquí.
			return true

		Type.IS_DEAD:
			# Fase D: cuando el sistema de muerte exista, consultar aquí.
			return false

		Type.ALIGNMENT:
			# Fase D: cuando el sistema de alineación exista, consultar aquí.
			return true

	return true
