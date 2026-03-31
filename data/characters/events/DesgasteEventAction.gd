# res://data/characters/events/DesgasteEventAction.gd
#
# Acción de evento especial: "Desgaste por Poder".
# Solo aparece en el pool cuando el personaje supera un performance_ratio >= 2.0
# (configurado via ActionCondition.PERFORMANCE_RATIO_MIN en ActionRegistry).
#
# MECÁNICA DE 3 DÍAS:
#   Al ejecutarse, escribe directamente en FlagSystem la clave de inyección que
#   ya usa InjectEventConsequence: "injected_event:<followup_event_id>" = día_de_expiración.
#   ActionRegistry._inject_active_events() detecta esa clave y añade el evento
#   de seguimiento al pool durante los días restantes — sin ningún cambio en
#   ActionRegistry, DayManager ni en ningún otro sistema.
#
# FLUJO COMPLETO:
#   Día N   : desgaste_por_poder aparece (ratio >= 2.0) → aplica penalización fuerte
#             → inyecta desgaste_seguimiento para días N+1 y N+2
#   Días N+1/N+2: desgaste_seguimiento aparece (inyectado) → penalización menor
#   Día N+3 : el flag expira, desgaste_seguimiento desaparece del pool

class_name DesgasteEventAction
extends EventAction

## ID del evento de seguimiento a inyectar en FlagSystem.
## Debe coincidir con el ID registrado en ActionRegistry.
@export var followup_event_id: StringName = &"desgaste_seguimiento"

## Cuántos días adicionales (sin contar el día actual) dura el seguimiento.
## Con 2, el efecto total cubre 3 días: hoy + 2 días de eco.
@export var followup_duration: int = 2

# ─────────────────────────────────────────────────────────────────────────────

func execute(ctx: DayContext) -> DayActionResult:
	# Ejecutar el comportamiento base de EventAction (selección ponderada de outcome,
	# escalado por challenge_multiplier, etc.) sin duplicar lógica.
	var result: DayActionResult = super.execute(ctx)

	# Inyectar el evento de seguimiento si está configurado.
	# Mecanismo idéntico al de InjectEventConsequence.apply():
	#   FlagSystem["injected_event:<id>"] = día_de_expiración
	# ActionRegistry._inject_active_events() lo detecta y añade el evento al pool.
	if followup_event_id != &"" and followup_duration > 0:
		var expiry_day: int    = ctx.day_number + followup_duration
		var key: StringName    = ("injected_event:" + str(followup_event_id)) as StringName
		FlagSystem.set_flag(key, expiry_day)

		# Registrar en extra_data para que la UI y DebugDayLoop puedan informarlo.
		result.extra_data["desgaste_followup_id"]     = followup_event_id
		result.extra_data["desgaste_followup_expiry"] = expiry_day

	return result
