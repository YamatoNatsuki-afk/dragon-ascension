# res://core/TransformationSystem.gd  ← Autoload
#
# Gestiona la activación de transformaciones durante el combate
# y aplica sus multiplicadores a los stats del jugador.
#
# FLUJO:
#   CombatManager o Player llama TransformationSystem.try_activate(id)
#   → Verifica condiciones (desbloqueada, ki suficiente, raza compatible)
#   → Aplica multiplicadores a StatsComponent del jugador
#   → Inicia drenaje de HP/Ki en _process
#   → Al desactivar: revierte multiplicadores + aplica penalización post-combate
#
# CONDICIONES DE DESBLOQUEO (verificadas por DayManager / CheckpointSystem):
#   Kaioken       : flag "trained_kaio" (entrenó con el Rey Kai)
#   Kaioken ×3    : flag "transform_kaioken" + maestría ≥ 0.50 + intel_combate ≥ 50
#   Kaioken ×4    : flag "transform_kaioken_x3" + maestría ≥ 0.50 + resistencia ≥ 60
#   Oozaru        : raza saiyan + flag "has_tail" (no fue cortada)
#   SSJ1          : raza saiyan + poder_total ≥ 900 + flag "near_death_event"
#   Forma Gigante : raza namekian + vitalidad ≥ 40

extends Node

# ─────────────────────────────────────────────────────────────────────────────
# ESTADO
# ─────────────────────────────────────────────────────────────────────────────

var _active_def:      TransformationDefinition = null
var _active_mastery:  float = 0.0
var _player_ref:      Node  = null   # Player node — inyectado por CombatManager
var _character_data          = null   # CharacterData — inyectado por CombatManager
var _in_combat:       bool  = false

# Multiplicadores aplicados actualmente (para poder revertirlos limpiamente)
var _applied_multipliers: Dictionary = {}

# ─────────────────────────────────────────────────────────────────────────────
# INICIALIZACIÓN
# ─────────────────────────────────────────────────────────────────────────────

func start_combat(player: Node, character_data) -> void:
	_player_ref     = player
	_character_data = character_data
	_in_combat      = true
	_active_def     = null
	_applied_multipliers.clear()

func end_combat() -> void:
	if _active_def != null:
		deactivate()
	_in_combat      = false
	_player_ref     = null

# ─────────────────────────────────────────────────────────────────────────────
# ACTIVACIÓN / DESACTIVACIÓN
# ─────────────────────────────────────────────────────────────────────────────

## Intenta activar una transformación. Retorna true si se activó.
func try_activate(transform_id: StringName) -> bool:
	if _character_data == null:
		return false

	var tr_node: Node = get_node_or_null("/root/TransformationRegistry")
	var def: TransformationDefinition = null
	if tr_node != null:
		def = tr_node.get_definition(transform_id)
	if def == null:
		push_warning("[TransformationSystem] Transformación desconocida: '%s'" % transform_id)
		return false

	var ts := _get_transform_state()
	if ts == null or not ts.is_unlocked(transform_id):
		return false

	if not def.is_available_for_race(_character_data.race_id):
		return false

	# Desactivar la transformación actual si hay una
	if _active_def != null:
		deactivate()

	_active_def     = def
	_active_mastery = ts.get_mastery(transform_id)
	ts.activate(transform_id)

	_apply_multipliers(def)

	EventBus.transformation_activated.emit(transform_id, def)
	print("[TransformationSystem] ✦ %s activado (maestría %.0f%%)" % [
		def.display_name, _active_mastery * 100.0
	])
	return true

func deactivate() -> void:
	if _active_def == null:
		return

	var def := _active_def
	_revert_multipliers()
	_apply_post_combat_penalty(def)

	var ts := _get_transform_state()
	if ts != null:
		ts.deactivate()

	EventBus.transformation_deactivated.emit(def.id)
	print("[TransformationSystem] %s desactivado." % def.display_name)

	_active_def = null
	_applied_multipliers.clear()

# ─────────────────────────────────────────────────────────────────────────────
# MULTIPLICADORES
# ─────────────────────────────────────────────────────────────────────────────

func _apply_multipliers(def: TransformationDefinition) -> void:
	if _character_data == null:
		return
	_applied_multipliers.clear()
	for stat_id: StringName in def.stat_multipliers.keys():
		var base: float   = _character_data.base_stats.get(stat_id, 0.0)
		var mult: float   = def.get_stat_multiplier(stat_id)
		var new_val: float = base * mult
		_applied_multipliers[stat_id] = base   # guardar valor original
		_character_data.base_stats[stat_id] = new_val
		if EventBus.has_signal("player_stats_changed"):
			EventBus.player_stats_changed.emit(stat_id, new_val)

func _revert_multipliers() -> void:
	if _character_data == null:
		return
	for stat_id: StringName in _applied_multipliers.keys():
		var original: float = _applied_multipliers[stat_id]
		_character_data.base_stats[stat_id] = original
		if EventBus.has_signal("player_stats_changed"):
			EventBus.player_stats_changed.emit(stat_id, original)

func _apply_post_combat_penalty(def: TransformationDefinition) -> void:
	if def.post_combat_stat == &"" or _character_data == null:
		return
	# La penalización se reduce con la maestría
	var mastery_reduction := lerpf(1.0, def.mastery_min_drain_ratio, _active_mastery)
	var delta := def.post_combat_delta * mastery_reduction
	var stat_id := def.post_combat_stat
	var current: float = _character_data.base_stats.get(stat_id, 0.0)
	_character_data.base_stats[stat_id] = maxf(current + delta, 0.1)
	if delta < 0.0:
		print("[TransformationSystem] Penalización post-combate: %s %+.1f" % [stat_id, delta])

# ─────────────────────────────────────────────────────────────────────────────
# DRENAJE EN TIEMPO REAL
# ─────────────────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	if not _in_combat or _active_def == null or _player_ref == null:
		return

	var hp_drain := _active_def.get_hp_drain(_active_mastery)
	var ki_drain := _active_def.get_ki_drain(_active_mastery)

	# HP drain — se aplica como porcentaje del HP máximo
	if hp_drain > 0.0:
		var max_hp: float = _character_data.get_max_hp() if _character_data.has_method("get_max_hp") else 100.0
		var drain_abs := max_hp * hp_drain * delta
		if _player_ref.has_method("take_damage"):
			_player_ref.take_damage(drain_abs, &"transform_drain")

	# Ki drain
	if ki_drain > 0.0 and _player_ref.has_node("KiComponent"):
		var ki_comp := _player_ref.get_node("KiComponent")
		if ki_comp.has_method("spend"):
			var drained: bool = ki_comp.spend(ki_drain * delta)
			if not drained:
				# Sin ki → desactivar transformación
				deactivate()

# ─────────────────────────────────────────────────────────────────────────────
# DESBLOQUEO — llamado desde CheckpointSystem o eventos narrativos
# ─────────────────────────────────────────────────────────────────────────────

## Desbloquea una transformación para el personaje dado.
## Se llama desde DayManager._resolve() cuando se setea el flag de desbloqueo.
func unlock_for_character(character_data, transform_id: StringName) -> void:
	var ts := _get_transform_state_from(character_data)
	if ts == null:
		return
	if ts.is_unlocked(transform_id):
		return

	ts.unlock(transform_id)
	print("[TransformationSystem] ✦ DESBLOQUEADA: %s para %s" % [
		transform_id, character_data.character_name
	])
	if EventBus.has_signal("transformation_unlocked"):
		EventBus.transformation_unlocked.emit(transform_id, character_data)

## Verifica si un personaje cumple las condiciones para desbloquear una transformación.
## Llamado por CheckpointSystem y por condiciones de acciones.
func check_unlock_conditions(character_data) -> void:
	if character_data == null:
		return
	var flags: Dictionary = character_data.saved_flags
	var stats: Dictionary = character_data.base_stats
	var race:  StringName = character_data.race_id
	var poder: float = character_data.get_poder_total() if character_data.has_method("get_poder_total") else 0.0
	var ts    := _get_transform_state_from(character_data)
	if ts == null:
		return

	# ── Kaioken (cualquier raza) ──────────────────────────────────────────
	if not ts.is_unlocked(&"transform_kaioken"):
		if flags.get(&"trained_kaio", false):
			unlock_for_character(character_data, &"transform_kaioken")

	# ── Kaioken ×3 ───────────────────────────────────────────────────────
	if not ts.is_unlocked(&"transform_kaioken_x3"):
		var kk_mastery := ts.get_mastery(&"transform_kaioken")
		if ts.is_unlocked(&"transform_kaioken") and kk_mastery >= 0.50 \
		   and stats.get(&"intel_combate", 0.0) >= 50.0:
			unlock_for_character(character_data, &"transform_kaioken_x3")

	# ── Kaioken ×4 ───────────────────────────────────────────────────────
	if not ts.is_unlocked(&"transform_kaioken_x4"):
		var kk3_mastery := ts.get_mastery(&"transform_kaioken_x3")
		if ts.is_unlocked(&"transform_kaioken_x3") and kk3_mastery >= 0.50 \
		   and stats.get(&"resistencia", 0.0) >= 60.0:
			unlock_for_character(character_data, &"transform_kaioken_x4")

	# ── Oozaru (Saiyan + cola) ────────────────────────────────────────────
	if race == &"saiyan" and not ts.is_unlocked(&"transform_oozaru"):
		if flags.get(&"has_tail", true):   # default true para saiyans
			unlock_for_character(character_data, &"transform_oozaru")

	# ── SSJ1 (Saiyan + poder ≥ 900 + near_death) ─────────────────────────
	if race == &"saiyan" and not ts.is_unlocked(&"transform_ssj1"):
		if poder >= 900.0 and flags.get(&"near_death_event", false):
			unlock_for_character(character_data, &"transform_ssj1")

	# ── Forma Gigante (Namekiano + vitalidad ≥ 40) ────────────────────────
	if race == &"namekian" and not ts.is_unlocked(&"transform_giant"):
		if stats.get(&"vitalidad", 0.0) >= 40.0:
			unlock_for_character(character_data, &"transform_giant")

# ─────────────────────────────────────────────────────────────────────────────
# MAESTRÍA — llamado por acciones de entrenamiento de maestría
# ─────────────────────────────────────────────────────────────────────────────

## Añade XP de maestría a una transformación.
## Retorna true si se cruzó un umbral de maestría.
func add_mastery(character_data, transform_id: StringName, xp: float) -> bool:
	var ts := _get_transform_state_from(character_data)
	if ts == null:
		return false
	var crossed := ts.add_mastery_xp(transform_id, xp)
	if crossed:
		check_unlock_conditions(character_data)
		if EventBus.has_signal("transformation_mastery_milestone"):
			EventBus.transformation_mastery_milestone.emit(
				transform_id, ts.get_mastery(transform_id)
			)
	return crossed

# ─────────────────────────────────────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────────────────────────────────────

func _get_transform_state() -> TransformationState:
	return _get_transform_state_from(_character_data)

func _get_transform_state_from(data) -> TransformationState:
	if data == null:
		return null
	var ts = data.get("transformation_state") if data.get("transformation_state") != null else null
	if ts == null:
		# Crear estado si no existe (personajes viejos sin el campo)
		ts = TransformationState.new()
		data.transformation_state = ts
	return ts

func is_active() -> bool:
	return _active_def != null

func get_active_definition() -> TransformationDefinition:
	return _active_def

func get_active_mastery() -> float:
	return _active_mastery
