# res://core/EventBus.gd
# Autoload. Bus de eventos global desacoplado.
#
# REGLA DE TYPE HINTS EN SEÑALES:
#   Las señales NO pueden usar tipos de clases custom (CharacterData, DayAction, etc.)
#   porque EventBus se carga antes que esas clases en el orden de autoloads.
#   Se usan tipos primitivos o se omite el tipo cuando es una clase del proyecto.
#   Los receptores hacen el cast necesario en su propio scope.
#
extends Node

# ── Run / Partida ─────────────────────────────────────────────────────────────
# Emitida cuando el jugador confirma la creación y arranca los 100 días.
# Receptores típicos: MusicManager, AnalyticsSystem, TransitionManager.
# GameManager usa la señal directa character_confirmed de CharacterCreationScreen
# para el arranque — esta es para el resto de sistemas que quieran reaccionar.
signal run_started(character_data)               # CharacterData

# ── Player ────────────────────────────────────────────────────────────────────
signal player_stats_changed(stat_name: StringName, new_value: float)
signal player_health_changed(new_hp: float, max_hp: float)
signal player_ki_changed(new_ki: float, max_ki: float)
signal player_died()

# ── Day system ────────────────────────────────────────────────────────────────
signal day_started(day_number: int)
signal day_actions_ready(available_actions: Array)
signal day_action_resolved(action, result)       # DayAction, DayActionResult
signal day_ended(day_number: int, result)        # result: DayActionResult
signal game_completed(final_data)               # CharacterData

# ── Meta-progreso ─────────────────────────────────────────────────────────────
signal checkpoint_reached(result)               # CheckpointResult
signal build_identity_changed(prev_id: StringName, new_profile)  # BuildProfile
signal action_unlocked(action_id: StringName)

# ── XP / Progresión ───────────────────────────────────────────────────────────
signal xp_gained(amount: float, total: float)

# ── Combate ───────────────────────────────────────────────────────────────────
signal combat_started(difficulty: float)
signal combat_ended(won: bool)          # Emitida por la lógica de combate (enemigo derrotado)
signal combat_result_ready(won: bool)   # Emitida por CombatManager tras descargar la escena
signal enemy_died(enemy: Node)
signal damage_dealt(target: Node, amount: float, type: String)
