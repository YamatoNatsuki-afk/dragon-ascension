# res://core/NpcSystem.gd  ← Autoload
#
# Gestiona las definiciones de NPCs, el estado de relación y los bonuses.
#
# FLUJO DE DESBLOQUEO:
#   1. DayManager._resolve() llama check_npc_conditions(character_data) post-flags
#   2. NpcSystem verifica si algún NPC cumple condiciones para pasar a KNOWN/ALLY
#   3. Si cambia de estado, emite npc_relation_changed → DayScreen actualiza UI
#
# FLUJO DE BONUS EN ENTRENAMIENTO:
#   TrainingAction.execute() llama NpcSystem.get_training_mult(stat_id, char_data)
#   → Retorna el multiplicador más alto entre todos los aliados activos para ese stat
#
# FLUJO DE BONUS EN COMBATE:
#   CombatManager consulta NpcSystem.get_combat_bonuses(char_data)
#   → Retorna un Dictionary con dodge_bonus, damage_mult, counter_chance, ki_recovery

extends Node

# ─────────────────────────────────────────────────────────────────────────────
# DEFINICIONES CANÓNICAS
# ─────────────────────────────────────────────────────────────────────────────

var _definitions: Dictionary = {}   # StringName → NpcDefinition

func _ready() -> void:
	_build_canonical_definitions()
	print("[NpcSystem] %d NPC(s) cargados: %s" % [
		_definitions.size(),
		"  ·  ".join(_definitions.keys().map(func(k): return str(k)))
	])

func _build_canonical_definitions() -> void:
	_definitions[&"npc_krilin"]  = _def_krilin()
	_definitions[&"npc_roshi"]   = _def_roshi()
	_definitions[&"npc_piccolo"] = _def_piccolo()
	_definitions[&"npc_karin"]   = _def_karin()
	_definitions[&"npc_kami"]    = _def_kami()
	_definitions[&"npc_rey_kai"] = _def_rey_kai()

# ── Definiciones ─────────────────────────────────────────────────────────────

func _make(id_: StringName, name_: String, desc: String,
		col: Color, icon_: String) -> NpcDefinition:
	var d := NpcDefinition.new()
	d.id           = id_
	d.display_name = name_
	d.description  = desc
	d.color        = col
	d.icon         = icon_
	d.ally_flag    = id_
	return d

func _def_krilin() -> NpcDefinition:
	var d := _make(&"npc_krilin", "Krilin",
		"Tu mejor amigo y rival. Juntos entrenan más rápido.",
		Color(0.80, 0.65, 0.30), "👊")
	d.required_flag             = &"npc_known_bulma"
	d.min_day                   = 10
	d.ally_stat_requirement     = [&"velocidad", 15.0]
	d.training_stat_mults       = { &"velocidad": 1.20, &"intel_combate": 1.15 }
	d.training_target_stats     = [&"velocidad", &"intel_combate"]
	d.training_base_gain        = 3.5
	d.master_bonus_multiplier   = 1.40
	d.combat_dodge_bonus        = 0.12
	d.combat_damage_mult        = 1.0
	d.combat_bonus_desc         = "Esquiva +12%"
	d.training_quotes = [
		"¡Vamos, no te rindas! ¡Yo tampoco me rindo!",
		"Si entrenas el doble, puedes superar cualquier límite.",
		"La velocidad lo es todo en un combate real.",
	]
	return d

func _def_roshi() -> NpcDefinition:
	var d := _make(&"npc_roshi", "Maestro Roshi",
		"El Maestro Tortuga conoce los secretos del cuerpo y la velocidad.",
		Color(0.50, 0.80, 0.95), "🐢")
	d.required_flag             = &"npc_roshi_intro"
	d.min_day                   = 5
	d.ally_stat_requirement     = [&"velocidad", 20.0]
	d.training_stat_mults       = { &"velocidad": 1.25, &"vitalidad": 1.20, &"resistencia": 1.10 }
	d.training_target_stats     = [&"velocidad", &"vitalidad"]
	d.training_base_gain        = 4.0
	d.master_bonus_multiplier   = 1.35
	d.combat_dodge_bonus        = 0.08
	d.combat_ki_recovery        = 1.5
	d.combat_bonus_desc         = "Esquiva +8% / Ki recovery"
	d.training_quotes = [
		"El cuerpo es un templo. Trátalo como tal.",
		"La tortuga supera a la liebre... con el entrenamiento correcto.",
		"Velocidad no es solo moverse rápido. Es moverse con propósito.",
	]
	return d

func _def_piccolo() -> NpcDefinition:
	var d := _make(&"npc_piccolo", "Piccolo",
		"Tu rival de siempre. Nadie te empuja más al límite que él.",
		Color(0.25, 0.75, 0.35), "🟢")
	d.required_flag             = &"rival_attention"
	d.min_day                   = 35
	d.ally_stat_requirement     = [&"fuerza", 60.0]
	d.training_stat_mults       = { &"fuerza": 1.25, &"resistencia": 1.25, &"intel_combate": 1.15 }
	d.training_target_stats     = [&"fuerza", &"resistencia"]
	d.training_base_gain        = 4.5
	d.master_bonus_multiplier   = 1.45
	d.combat_counter_chance     = 0.20
	d.combat_damage_mult        = 1.12
	d.combat_bonus_desc         = "Daño +12% / Contraataque 20%"
	d.training_quotes = [
		"No estás entrenando. Estás perdiendo el tiempo.",
		"Si no puedes superar tus límites hoy, ¿para qué existes?",
		"Concentración. Sin ella, la fuerza no vale nada.",
	]
	return d

func _def_karin() -> NpcDefinition:
	var d := _make(&"npc_karin", "Karin",
		"El sabio gato de la Torre. Sus frijoles sagrados despiertan el Ki.",
		Color(0.95, 0.85, 0.40), "🌿")
	d.required_flag             = &""   # solo día
	d.min_day                   = 40
	d.ally_stat_requirement     = [&"ki", 15.0]
	d.training_stat_mults       = { &"ki": 1.30, &"poder_ki": 1.30, &"vitalidad": 1.10 }
	d.training_target_stats     = [&"ki", &"poder_ki"]
	d.training_base_gain        = 3.8
	d.master_bonus_multiplier   = 1.50
	d.combat_ki_recovery        = 3.0
	d.combat_bonus_desc         = "Ki recovery ×3/s en combate"
	d.training_quotes = [
		"El Ki no se fuerza. Se canaliza.",
		"Sube más alto. El techo siempre está más arriba de lo que crees.",
		"La calma es poder. El caos es debilidad.",
	]
	return d

func _def_kami() -> NpcDefinition:
	var d := _make(&"npc_kami", "Kami",
		"El Dios de la Tierra. Su guía agudiza la mente y el instinto.",
		Color(0.60, 0.50, 0.95), "✦")
	d.required_flag             = &"survived_raditz"
	d.min_day                   = 50
	d.ally_stat_requirement     = [&"intel_combate", 25.0]
	d.training_stat_mults       = { &"intel_combate": 1.35, &"inteligencia": 1.25, &"ki": 1.15 }
	d.training_target_stats     = [&"intel_combate", &"inteligencia"]
	d.training_base_gain        = 4.0
	d.master_bonus_multiplier   = 1.40
	d.combat_dodge_bonus        = 0.10
	d.combat_counter_chance     = 0.10
	d.combat_bonus_desc         = "Esquiva +10% / Contraataque 10%"
	d.training_quotes = [
		"La mente es el arma más poderosa. Afílala.",
		"Ver el ataque antes de que ocurra — eso es verdadero poder.",
		"El instinto de combate se entrena, no se hereda.",
	]
	return d

func _def_rey_kai() -> NpcDefinition:
	var d := _make(&"npc_rey_kai", "Rey Kai",
		"El maestro del Kaio-ken. Solo los más fuertes llegan hasta él.",
		Color(0.95, 0.40, 0.20), "👑")
	d.required_flag             = &""
	d.min_day                   = 60
	d.ally_stat_requirement     = [&"ki", 25.0]
	d.training_stat_mults = {
		&"fuerza": 1.20, &"velocidad": 1.20, &"ki": 1.20,
		&"resistencia": 1.15, &"vitalidad": 1.15,
		&"poder_ki": 1.20, &"intel_combate": 1.15, &"inteligencia": 1.10
	}
	d.training_target_stats     = [&"ki", &"fuerza", &"velocidad"]
	d.training_base_gain        = 5.0
	d.master_bonus_multiplier   = 1.50
	d.combat_damage_mult        = 1.15
	d.combat_ki_recovery        = 2.0
	d.combat_bonus_desc         = "Daño +15% / Ki recovery"
	d.training_quotes = [
		"El Kaio-ken no es solo técnica. Es voluntad.",
		"En el Camino de la Serpiente aprendiste a sufrir. Ahora aprende a trascenderlo.",
		"Más allá de tus límites hay otro límite. Y más allá de ese, otro.",
	]
	# El Rey Kai desbloquea el flag de Kaioken al volverse aliado
	d.ally_flag = &"trained_kaio"
	return d

# ─────────────────────────────────────────────────────────────────────────────
# API PÚBLICA
# ─────────────────────────────────────────────────────────────────────────────

func get_definition(npc_id: StringName) -> NpcDefinition:
	return _definitions.get(npc_id, null)

func get_all() -> Array:
	return _definitions.values()

## Retorna los NPCs disponibles como aliados para el personaje dado.
## "Disponible" = ALLY o MASTER en este momento.
func get_active_allies(character_data) -> Array:
	var result: Array = []
	var nrs := _get_relation_state(character_data)
	if nrs == null:
		return result
	for def: NpcDefinition in _definitions.values():
		if nrs.is_ally(def.id):
			result.append(def)
	return result

## Retorna los NPCs conocidos pero no aliados todavía (KNOWN o FRIENDLY).
func get_known_npcs(character_data) -> Array:
	var result: Array = []
	var nrs := _get_relation_state(character_data)
	if nrs == null:
		return result
	for def: NpcDefinition in _definitions.values():
		var rel: int = nrs.get_relation(def.id)
		if rel >= 1 and rel < 3:
			result.append(def)
	return result

## Multiplicador de entrenamiento para un stat dado — máximo entre todos los aliados.
func get_training_mult(stat_id: StringName, character_data) -> float:
	var best: float = 1.0
	var nrs := _get_relation_state(character_data)
	if nrs == null:
		return best
	for def: NpcDefinition in _definitions.values():
		if nrs.is_ally(def.id):
			var m: float = def.get_training_mult(stat_id, nrs.get_relation(def.id))
			if m > best:
				best = m
	return best

## Retorna los bonuses de combate combinados de todos los aliados activos.
func get_combat_bonuses(character_data) -> Dictionary:
	var dodge:   float = 0.0
	var damage:  float = 1.0
	var counter: float = 0.0
	var ki_rec:  float = 0.0
	var nrs := _get_relation_state(character_data)
	if nrs != null:
		for def: NpcDefinition in _definitions.values():
			if nrs.is_ally(def.id):
				dodge   += def.combat_dodge_bonus
				damage  *= def.combat_damage_mult
				counter  = maxf(counter, def.combat_counter_chance)
				ki_rec  += def.combat_ki_recovery
	return {
		"dodge_bonus":    clampf(dodge, 0.0, 0.40),
		"damage_mult":    damage,
		"counter_chance": clampf(counter, 0.0, 0.50),
		"ki_recovery":    ki_rec,
	}

# ─────────────────────────────────────────────────────────────────────────────
# VERIFICACIÓN DE CONDICIONES — llamado por DayManager post-flags
# ─────────────────────────────────────────────────────────────────────────────

func check_npc_conditions(character_data) -> void:
	if character_data == null:
		return
	var nrs   := _get_relation_state(character_data)
	var flags: Dictionary = character_data.saved_flags
	var stats: Dictionary = character_data.base_stats
	var day   : int = character_data.current_day

	for def: NpcDefinition in _definitions.values():
		var current_rel: int = nrs.get_relation(def.id)

		# UNKNOWN → KNOWN: verificar disponibilidad básica
		if current_rel == 0 and def.is_available(day, flags):
			nrs.set_relation(def.id, 1)
			_emit_relation_changed(def.id, 0, 1, character_data)

		# KNOWN/FRIENDLY → ALLY: verificar stat requirement
		if current_rel >= 1 and current_rel < 3:
			if def.can_become_ally(stats, flags):
				nrs.set_relation(def.id, 3)
				# Setear ally_flag en el personaje
				if def.ally_flag != &"":
					character_data.saved_flags[def.ally_flag] = true
					if FlagSystem.has_method("set_flag"):
						FlagSystem.set_flag(def.ally_flag, true)
					elif FlagSystem.has_method("set"):
						FlagSystem.set(def.ally_flag, true)
				_emit_relation_changed(def.id, current_rel, 3, character_data)
				print("[NpcSystem] ✦ ALIADO: %s → %s" % [def.display_name, character_data.character_name])

## Registra una interacción de entrenamiento y avanza la relación si corresponde.
## Retorna el nuevo estado de relación.
func register_training(npc_id: StringName, character_data) -> int:
	var nrs := _get_relation_state(character_data)
	if nrs == null:
		return 0
	var count: int = nrs.register_interaction(npc_id)
	var current: int = nrs.get_relation(npc_id)

	# ALLY → MASTER: requiere ≥ 10 entrenamientos
	if current == 3 and count >= 10:
		nrs.set_relation(npc_id, 4)
		_emit_relation_changed(npc_id, 3, 4, character_data)
		print("[NpcSystem] ★ MAESTRO: %s" % npc_id)

	return nrs.get_relation(npc_id)

# ─────────────────────────────────────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────────────────────────────────────

func _get_relation_state(data) -> NpcRelationState:
	if data == null:
		return null
	var nrs = data.get("npc_relation_state")
	if nrs == null:
		nrs = NpcRelationState.new()
		data.npc_relation_state = nrs
	return nrs

func _emit_relation_changed(npc_id: StringName, old_rel: int, new_rel: int, data) -> void:
	var bus := get_node_or_null("/root/EventBus")
	if bus != null and bus.has_signal("npc_relation_changed"):
		bus.npc_relation_changed.emit(npc_id, old_rel, new_rel, data)
