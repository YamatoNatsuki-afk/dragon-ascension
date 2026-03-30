# res://core/EventBus.gd  ← Autoload
# Bus central de señales. Ningún sistema importa a otro directamente —
# toda comunicación cross-system pasa por aquí.
#
# GRUPOS DE SEÑALES:
#   Run lifecycle    → run_started, game_completed
#   Loop diario      → day_started, day_actions_ready, day_action_resolved, day_ended
#   Combate          → combat_started, combat_ended, combat_result_ready,
#                      damage_dealt, player_died, player_health_changed, player_stats_changed
#   Progresión       → xp_gained, level_up, checkpoint_reached, build_identity_changed
extends Node

# ─────────────────────────────────────────────────────────────────────────────
# RUN LIFECYCLE
# ─────────────────────────────────────────────────────────────────────────────

## Emitida por CharacterCreationScreen cuando el jugador confirma su personaje.
## CharacterData contiene el estado inicial completo.
signal run_started(character_data)

## Emitida por DayManager cuando current_day supera 100.
signal game_completed(character_data)

# ─────────────────────────────────────────────────────────────────────────────
# LOOP DIARIO
# ─────────────────────────────────────────────────────────────────────────────

## Emitida al inicio de cada día. DayScreen actualiza el header.
signal day_started(day_number: int)

## Emitida después de calcular las acciones disponibles.
## DayScreen y debug_run_simulation esperan esta señal.
signal day_actions_ready(actions: Array)

## Emitida cuando DayManager terminó de resolver la acción del día.
## DayScreen la usa para mostrar el overlay de resultado.
signal day_action_resolved(action, result)

## Emitida al final del día, después de guardar.
## CheckpointSystem y DayScreen escuchan esta señal.
signal day_ended(day_number: int, result)

# ─────────────────────────────────────────────────────────────────────────────
# COMBATE
# ─────────────────────────────────────────────────────────────────────────────

## Emitida por CombatManager para que CombatScene se inicialice.
signal combat_started(difficulty: float)

## Emitida por CombatScene al terminar el combate (victoria o derrota).
## CombatManager escucha esta señal y emite combat_result_ready.
signal combat_ended(won: bool)

## Emitida por CombatManager después de procesar combat_ended.
## DayManager hace await de esta señal para obtener el resultado.
signal combat_result_ready(won: bool)

## Emitida por entidades de combate al aplicar daño.
signal damage_dealt(source, amount: float, type: StringName)

## Emitida cuando el HP del jugador llega a 0.
signal player_died()

## Emitida cuando cambia el HP del jugador.
signal player_health_changed(current_hp: float, max_hp: float)

## Emitida cuando cambia el Ki del jugador durante combate.
signal player_ki_changed(current_ki: float, max_ki: float)

## Emitida cuando cambia un stat del jugador en tiempo real (durante combate).
signal player_stats_changed(stat_id: StringName, new_value: float)

# ─────────────────────────────────────────────────────────────────────────────
# PROGRESIÓN
# ─────────────────────────────────────────────────────────────────────────────

## Emitida cuando el personaje gana XP.
signal xp_gained(amount: float, total: float)

## Emitida por DayManager cuando el personaje sube de nivel.
## DayScreen la escucha para mostrar el overlay de asignación de puntos.
signal level_up(new_level: int, levels_gained: int)

## Emitida por CheckpointSystem después de evaluar y aplicar el checkpoint.
signal checkpoint_reached(result)

## Emitida por CheckpointSystem cuando el build dominante cambia entre días.
signal build_identity_changed(prev_id: StringName, new_profile)

# ─────────────────────────────────────────────────────────────────────────────
# TRANSFORMACIONES
# ─────────────────────────────────────────────────────────────────────────────

## Emitida por TransformationSystem cuando se desbloquea una transformación.
signal transformation_unlocked(transform_id: StringName, character_data)

## Emitida cuando el jugador activa una transformación en combate.
signal transformation_activated(transform_id: StringName, definition)

## Emitida cuando la transformación se desactiva (voluntario, ki agotado, post-combate).
signal transformation_deactivated(transform_id: StringName)

## Emitida cuando la maestría de una transformación cruza un umbral (25/50/75/100%).
signal transformation_mastery_milestone(transform_id: StringName, new_mastery: float)

## Emitida por MinigameRecordSystem cuando se supera un récord con bonus de stat.
signal minigame_record_broken(minigame_id: String, old_score: float, new_score: float, bonuses: Array)

# ─────────────────────────────────────────────────────────────────────────────
# NPCs / ALIADOS
# ─────────────────────────────────────────────────────────────────────────────

## Emitida por NpcSystem cuando cambia el estado de relación con un NPC.
signal npc_relation_changed(npc_id: StringName, old_state: int, new_state: int, character_data)
