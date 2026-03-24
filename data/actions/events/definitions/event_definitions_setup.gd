# ─────────────────────────────────────────────────────────────────────────────
# PLANTILLAS DE EVENTOS DE RIESGO
# Estos son los valores que debes configurar en el editor de Godot
# al crear los .tres correspondientes.
# Ruta: res://data/actions/events/definitions/
# ─────────────────────────────────────────────────────────────────────────────


# ══════════════════════════════════════════════════
# ARCHIVO: rival_challenge.tres
# Tipo:    EventAction
# ══════════════════════════════════════════════════
#
# Configuración del EventAction:
#   id            = "rival_challenge"
#   display_name  = "Desafío de un rival"
#   description   = "Un guerrero te reta. Puedes ganar experiencia o sufrir una derrota."
#   action_type   = "event"
#   unlock_day    = 1
#   selection_weight = 1.2
#
# Outcomes (crear como sub-recursos EventOutcome dentro del .tres):
#
#   Outcome 1 — Victoria clara
#     narrative_key  = "event.rival.victory"
#     weight         = 2.0
#     xp_gained      = 30.0
#     stat_changes   = { "strength": 1.0 }
#
#   Outcome 2 — Victoria por los pelos
#     narrative_key  = "event.rival.narrow_win"
#     weight         = 3.0
#     xp_gained      = 20.0
#     stat_changes   = { "strength": 0.5, "health_max": -2.0 }
#
#   Outcome 3 — Derrota
#     narrative_key  = "event.rival.defeat"
#     weight         = 2.0
#     xp_gained      = 8.0
#     stat_changes   = { "health_max": -5.0, "defense": -0.5 }
#
#   Outcome 4 — Derrota humillante (raro)
#     narrative_key  = "event.rival.crushing_defeat"
#     weight         = 0.5
#     xp_gained      = 5.0
#     stat_changes   = { "health_max": -10.0, "strength": -1.0 }
#
# Distribución resultante (total peso = 7.5):
#   Victoria clara:     26.7%
#   Victoria apurada:   40.0%
#   Derrota:            26.7%
#   Derrota humillante:  6.6%
#
# Con el escalado de DifficultyScaler.challenge_multiplier(day),
# los daños crecen progresivamente con el día.


# ══════════════════════════════════════════════════
# ARCHIVO: overtraining.tres
# Tipo:    EventAction
# ══════════════════════════════════════════════════
#
# Configuración del EventAction:
#   id            = "overtraining"
#   display_name  = "Sobreentrenamiento"
#   description   = "El cuerpo necesita descanso. Ignorarlo tiene consecuencias."
#   action_type   = "event"
#   unlock_day    = 1
#   selection_weight = 2.5   ← peso alto para que el selector lo elija frecuentemente
#                              cuando aparece (señal de que algo va mal)
#
# Outcomes:
#
#   Outcome 1 — Lesión leve
#     narrative_key  = "event.overtraining.injury"
#     weight         = 3.0
#     xp_gained      = 0.0
#     stat_changes   = { "health_max": -8.0, "strength": -0.5 }
#
#   Outcome 2 — Día perdido (sin progreso)
#     narrative_key  = "event.overtraining.rest_forced"
#     weight         = 4.0
#     xp_gained      = 2.0
#     stat_changes   = {}    ← sin cambios, pero sin ganancias tampoco
#
#   Outcome 3 — Superación (raro — el cuerpo a veces se adapta)
#     narrative_key  = "event.overtraining.breakthrough"
#     weight         = 1.0
#     xp_gained      = 15.0
#     stat_changes   = { "health_max": 3.0 }
#
# Distribución (total peso = 8.0):
#   Lesión leve:   37.5%
#   Día perdido:   50.0%
#   Superación:    12.5%
#
# NOTA: Este evento solo aparece en el pool cuando DebugDayLoop detecta
# que el personaje entrenó el mismo stat el día anterior. No está siempre
# disponible — es un riesgo contextual.


# ══════════════════════════════════════════════════
# ARCHIVO: mysterious_encounter.tres
# Tipo:    EventAction
# (Bonus — evento narrativo para días intermedios)
# ══════════════════════════════════════════════════
#
# Configuración:
#   id            = "mysterious_encounter"
#   display_name  = "Encuentro misterioso"
#   description   = "Un anciano guerrero observa tu entrenamiento."
#   action_type   = "event"
#   unlock_day    = 10
#   selection_weight = 0.6   ← raro, para que sea especial cuando aparece
#
# Outcomes:
#
#   Outcome 1 — Enseñanza (todos los stats suben un poco)
#     narrative_key  = "event.encounter.teaching"
#     weight         = 2.0
#     xp_gained      = 50.0
#     stat_changes   = { "strength": 0.5, "speed": 0.5, "ki_max": 0.5 }
#
#   Outcome 2 — Desafío mental (ki sube, velocidad baja)
#     narrative_key  = "event.encounter.mental_challenge"
#     weight         = 2.0
#     xp_gained      = 30.0
#     stat_changes   = { "ki_max": 2.0, "speed": -0.5 }
#
#   Outcome 3 — No hay encuentro (era una ilusión)
#     narrative_key  = "event.encounter.illusion"
#     weight         = 1.0
#     xp_gained      = 10.0
#     stat_changes   = {}
