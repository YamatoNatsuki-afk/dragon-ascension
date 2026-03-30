# res://data/characters/events/NpcEncounterAction.gd
#
# Acción de encuentro con un NPC específico.
# Al ejecutarse, elige un outcome ponderado y lo aplica:
#   - Cambios de stats
#   - Flags seteadas en CharacterData.saved_flags
#   - XP ganada
#
# DISEÑO:
#   Los encuentros NPC son eventos de UN solo uso — una vez que el flag
#   principal está seteado, is_available() retorna false y la acción
#   desaparece del panel.
#
#   Esto evita que el jugador spamee el mismo encuentro para farmear stats.
#
# EJEMPLO DE FLUJO (Encuentro con Bulma):
#   1. Aparece en sección EVENTOS a partir del día 1
#   2. Jugador elige "Encuentro con Bulma"
#   3. Se ejecuta outcome elegido (ej: "Bulma te presenta a Roshi")
#   4. Flag npc_known_bulma = true y npc_roshi_intro = true se setean
#   5. A partir del día siguiente, Roshi aparece disponible sin esperar día 10
#   6. El evento "Encuentro con Bulma" ya no aparece más

class_name NpcEncounterAction
extends DayAction

## ID del NPC que se conoce en este encuentro.
@export var npc_id: StringName = &""

## Nombre del NPC para mostrar en la UI.
@export var npc_name: String = ""

## Flag que se chequea para saber si este encuentro ya ocurrió.
## Si este flag está en saved_flags, la acción no aparece más.
@export var completion_flag: StringName = &""

## Outcomes posibles, seleccionados por peso.
@export var outcomes: Array[NpcEncounterOutcome] = []

# ─────────────────────────────────────────────────────────────────────────────

## Sobreescribe is_available — oculta la acción si ya ocurrió el encuentro.
func is_available(ctx: DayContext) -> bool:
	if not super.is_available(ctx):
		return false
	# Si el completion_flag ya está seteado, el encuentro ya ocurrió
	if completion_flag != &"":
		var flags: Dictionary = ctx.character_data.get("saved_flags") \
			if ctx.character_data.get("saved_flags") != null else {}
		if flags.get(completion_flag, false):
			return false
	return true

func execute(ctx: DayContext) -> DayActionResult:
	var result := DayActionResult.new()
	result.action_type = &"event"
	result.success     = true

	if outcomes.is_empty():
		result.narrative_key = "npc.%s.no_outcomes" % npc_id
		return result

	# Selección ponderada del outcome
	var chosen: NpcEncounterOutcome = _pick_outcome(ctx)
	if chosen == null:
		result.narrative_key = "npc.%s.error" % npc_id
		return result

	# Aplicar stat changes
	result.stat_changes  = chosen.stat_changes.duplicate()
	result.xp_gained     = chosen.xp_gained
	result.narrative_key = chosen.narrative_key

	# Aplicar flags — se setean en saved_flags para disponibilidad inmediata
	# y en FlagSystem si está disponible (para logging)
	for flag_id: StringName in chosen.flags_to_set:
		result.flags_to_set.append(flag_id)

	# El completion_flag también se setea para que el evento no repita
	if completion_flag != &"":
		result.flags_to_set.append(completion_flag)

	return result

# ─────────────────────────────────────────────────────────────────────────────

func _pick_outcome(ctx: DayContext) -> NpcEncounterOutcome:
	var total: float = 0.0
	for o: NpcEncounterOutcome in outcomes:
		total += o.weight

	var roll: float = ctx.rng.randf() * total
	var acc:  float = 0.0
	for o: NpcEncounterOutcome in outcomes:
		acc += o.weight
		if roll <= acc:
			return o

	return outcomes[-1]  # fallback
