# data/checkpoints/consequences/CheckpointConsequence.gd
# Resource base abstracto. Cada subclase implementa apply().
# El CheckpointSystem llama consequence.apply(data) sin saber el tipo concreto.
#
# Diseño: las consecuencias no tienen acceso al árbol de escena ni a autoloads
# directamente desde su código — reciben el CharacterData como argumento.
# Aquellas que necesitan acceder a otros sistemas (FlagSystem, ActionRegistry)
# los llaman como singletons, que es aceptable porque son autoloads globales.
class_name CheckpointConsequence
extends Resource

@export var description: String = ""  # Para mostrar en UI/debug

## Aplica la consecuencia. Devuelve un dict con los cambios producidos
## (para logging y para incluir en CheckpointResult.stat_delta).
func apply(data: CharacterData) -> Dictionary:
	push_error("CheckpointConsequence.apply(): no implementado en '%s'." % resource_path)
	return {}

## Descripción legible de lo que hace esta consecuencia.
## Override en subclases para logging más preciso.
func describe() -> String:
	return description if description != "" else "(consecuencia sin descripción)"


# ══════════════════════════════════════════════
# SetFlagConsequence
# Establece un flag en FlagSystem.
# Otros sistemas leen este flag para cambiar su comportamiento.
# ══════════════════════════════════════════════
class_name SetFlagConsequence
extends CheckpointConsequence

@export var flag_id: StringName = &""
@export var flag_value: bool = true   # Para flags más complejos usar flag_value_string

## Valor alternativo String para flags no-booleanos ("elite", "failed", etc.)
@export var flag_value_string: String = ""

func apply(_data: CharacterData) -> Dictionary:
	assert(flag_id != &"", "SetFlagConsequence: flag_id no puede estar vacío.")
	var value: Variant = flag_value_string if flag_value_string != "" else flag_value
	FlagSystem.set_flag(flag_id, value)
	return { "flag_set": flag_id }

func describe() -> String:
	var val: String = flag_value_string if flag_value_string != "" else str(flag_value)
	return "Flag '%s' = %s" % [flag_id, val]


# ══════════════════════════════════════════════
# UnlockActionConsequence
# Desbloquea una acción que estaba marcada como bloqueada por flag.
# ActionRegistry.get_available() la incluirá a partir de ahora.
# ══════════════════════════════════════════════
class_name UnlockActionConsequence
extends CheckpointConsequence

@export var action_id: StringName = &""

func apply(_data: CharacterData) -> Dictionary:
	assert(action_id != &"", "UnlockActionConsequence: action_id no puede estar vacío.")
	# El flag de desbloqueo sigue una convención: "unlocked:{action_id}"
	# ActionRegistry comprueba este flag en is_available()
	FlagSystem.set_flag(_unlock_flag(action_id), true)
	EventBus.action_unlocked.emit(action_id)
	return { "action_unlocked": action_id }

func describe() -> String:
	return "Desbloquea acción '%s'" % action_id

static func _unlock_flag(id: StringName) -> StringName:
	return ("unlocked:" + str(id)) as StringName

## Utilidad estática que ActionRegistry usa para comprobar desbloqueos.
static func is_unlocked(action_id: StringName) -> bool:
	return FlagSystem.has(_unlock_flag(action_id))


# ══════════════════════════════════════════════
# ModifyStatConsequence
# Modifica un stat base del personaje (reemplaza el sistema anterior).
# Acepta delta positivo y negativo.
# ══════════════════════════════════════════════
class_name ModifyStatConsequence
extends CheckpointConsequence

@export var stat_id: StringName = &""
@export var delta: float        = 0.0
@export var min_value: float    = 1.0   # Evita que el stat llegue a 0

func apply(data: CharacterData) -> Dictionary:
	assert(stat_id != &"", "ModifyStatConsequence: stat_id no puede estar vacío.")
	assert(delta != 0.0,   "ModifyStatConsequence: delta es 0, no tiene efecto.")

	var current: float = data.base_stats.get(stat_id, 0.0)
	var new_val: float = maxf(min_value, current + delta)
	data.base_stats[stat_id] = new_val

	EventBus.player_stats_changed.emit(stat_id, new_val)
	return { stat_id: delta }

func describe() -> String:
	var sign := "+" if delta >= 0.0 else ""
	return "%s%s a '%s'" % [sign, delta, stat_id]


# ══════════════════════════════════════════════
# InjectEventConsequence
# Inyecta un evento en el pool de acciones disponibles por N días.
# ActionRegistry lo incluye automáticamente durante ese período.
# ══════════════════════════════════════════════
class_name InjectEventConsequence
extends CheckpointConsequence

@export var event_action_id: StringName = &""
@export var duration_days: int          = 3     # Cuántos días estará disponible

func apply(data: CharacterData) -> Dictionary:
	assert(event_action_id != &"", "InjectEventConsequence: event_action_id vacío.")
	# Almacena el evento inyectado con su día de expiración
	var expiry_day := data.current_day + duration_days
	var key        := ("injected_event:" + str(event_action_id)) as StringName
	FlagSystem.set_flag(key, expiry_day)
	return { "event_injected": event_action_id, "expires_day": expiry_day }

func describe() -> String:
	return "Inyecta evento '%s' por %d días" % [event_action_id, duration_days]

## Comprueba si un evento inyectado sigue activo para el día dado.
static func is_event_active(event_id: StringName, current_day: int) -> bool:
	var key     := ("injected_event:" + str(event_id)) as StringName
	var expiry  := FlagSystem.get_value(key, 0)
	return current_day <= int(expiry)


# ══════════════════════════════════════════════
# ModifySelectionWeightConsequence
# Modifica el peso de selección de una acción por N días.
# ActionSelector lee estos modificadores temporales de FlagSystem.
# ══════════════════════════════════════════════
class_name ModifySelectionWeightConsequence
extends CheckpointConsequence

@export var action_id: StringName = &""
@export var weight_multiplier: float = 2.0  # 2.0 = doble de probable, 0.5 = mitad
@export var duration_days: int       = 5

func apply(data: CharacterData) -> Dictionary:
	assert(action_id != &"", "ModifySelectionWeightConsequence: action_id vacío.")
	assert(weight_multiplier > 0.0, "ModifySelectionWeightConsequence: multiplicador debe ser > 0.")

	var expiry_day := data.current_day + duration_days
	var key        := ("weight_mod:%s" % action_id) as StringName
	# Guardamos {multiplicador, expiración} como String JSON-like para FlagSystem
	FlagSystem.set_flag(key, "%s:%d" % [weight_multiplier, expiry_day])
	return { "weight_modified": action_id, "multiplier": weight_multiplier }

func describe() -> String:
	return "Peso x%.1f para '%s' por %d días" % [weight_multiplier, action_id, duration_days]

## Obtiene el multiplicador activo para una acción en el día dado.
## Devuelve 1.0 si no hay modificador activo.
static func get_active_multiplier(action_id: StringName, current_day: int) -> float:
	var key   := ("weight_mod:%s" % action_id) as StringName
	var raw   := str(FlagSystem.get_value(key, ""))
	if raw == "":
		return 1.0
	var parts := raw.split(":")
	if parts.size() < 2:
		return 1.0
	var multiplier := float(parts[0])
	var expiry     := int(parts[1])
	return multiplier if current_day <= expiry else 1.0
