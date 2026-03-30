# res://data/transformations/TransformationDefinition.gd
#
# Resource que define UNA transformación.
# No contiene estado — solo la definición estática.
# El estado (desbloqueada, maestría) vive en TransformationState.
#
# MULTIPLICADORES:
#   stat_multipliers → Dictionary[StringName, float]
#   Un stat ausente = multiplicador 1.0 (sin cambio)
#
# DRAWBACKS:
#   hp_drain_per_sec  → HP que pierde por segundo mientras está activa
#   ki_drain_per_sec  → Ki que pierde por segundo
#   post_combat_stat  → stat que se penaliza después del combate
#   post_combat_delta → cuánto cae ese stat (negativo = pérdida)
#
# MAESTRÍA (0.0–1.0):
#   La maestría reduce los drawbacks proporcionalmente.
#   Al 1.0 (maestría completa) los drawbacks bajan a mastery_min_drain_ratio
#   y se desbloquea el entrenamiento con "peso extra" (×2 gains).
#
# CONDICIONES DE DESBLOQUEO:
#   Se expresan como ActionConditions — reutilizamos el sistema existente.

class_name TransformationDefinition
extends Resource

## ID único de la transformación. Usado como flag en CharacterData.saved_flags.
## Convención: "transform_ssj1", "transform_oozaru", "transform_kaioken", etc.
@export var id: StringName = &""

## Nombre visible en UI.
@export var display_name: String = ""

## Descripción lore de la transformación.
@export var description: String = ""

## Color del aura en combate.
@export var aura_color: Color = Color(1.0, 0.9, 0.3)

## Razas que pueden usar esta transformación. Vacío = todas las razas.
@export var allowed_races: Array[StringName] = []

## Flag que se setea en CharacterData.saved_flags cuando se desbloquea.
## Normalmente igual al id, pero puede ser diferente si viene de un evento narrativo.
@export var unlock_flag: StringName = &""

# ─────────────────────────────────────────────────────────────────────────────
# MULTIPLICADORES
# ─────────────────────────────────────────────────────────────────────────────

## Multiplicadores por stat durante la transformación.
## Stats ausentes = 1.0 (sin cambio).
## Ejemplo SSJ1: { &"fuerza": 8.0, &"velocidad": 8.0, &"ki": 8.0, ... }
@export var stat_multipliers: Dictionary = {}

# ─────────────────────────────────────────────────────────────────────────────
# DRAWBACKS
# ─────────────────────────────────────────────────────────────────────────────

## HP perdido por segundo mientras la transformación está activa. 0 = sin drenaje.
@export var hp_drain_per_sec: float = 0.0

## Ki perdido por segundo mientras la transformación está activa. 0 = sin drenaje.
@export var ki_drain_per_sec: float = 0.0

## Stat que se penaliza DESPUÉS del combate por haber usado la transformación.
## Deja en &"" si no hay penalización post-combate.
@export var post_combat_stat: StringName = &""

## Delta negativo aplicado al stat post_combat_stat después del combate.
@export var post_combat_delta: float = 0.0

## Multiplicador de control de intel_combate durante la transformación.
## Oozaru: 0.1 (casi sin control). SSJ1: 1.0 (control completo).
@export var combat_control_mult: float = 1.0

# ─────────────────────────────────────────────────────────────────────────────
# MAESTRÍA
# ─────────────────────────────────────────────────────────────────────────────

## Con maestría al 100%, los drenajes se reducen a este ratio del original.
## Ejemplo: 0.25 → al maestrear SSJ1, el ki_drain baja 75%.
@export var mastery_min_drain_ratio: float = 0.25

## Con maestría ≥ 0.75, se desbloquea "entrenamiento pesado" (×2 gains en acciones de maestría).
@export var heavy_training_mastery_threshold: float = 0.75

## Stat primario que mejora con el entrenamiento de maestría.
@export var mastery_primary_stat: StringName = &"ki"

## Stat secundario que mejora con el entrenamiento de maestría.
@export var mastery_secondary_stat: StringName = &"resistencia"

# ─────────────────────────────────────────────────────────────────────────────
# API
# ─────────────────────────────────────────────────────────────────────────────

## Retorna el multiplicador efectivo de un stat dado, con la maestría aplicada.
## La maestría reduce los drawbacks pero NO reduce los multiplicadores positivos.
func get_stat_multiplier(stat_id: StringName) -> float:
	return float(stat_multipliers.get(stat_id, 1.0))

## Retorna el drenaje de HP efectivo según la maestría del personaje.
func get_hp_drain(mastery: float) -> float:
	if hp_drain_per_sec <= 0.0:
		return 0.0
	var ratio := lerpf(1.0, mastery_min_drain_ratio, clampf(mastery, 0.0, 1.0))
	return hp_drain_per_sec * ratio

## Retorna el drenaje de Ki efectivo según la maestría del personaje.
func get_ki_drain(mastery: float) -> float:
	if ki_drain_per_sec <= 0.0:
		return 0.0
	var ratio := lerpf(1.0, mastery_min_drain_ratio, clampf(mastery, 0.0, 1.0))
	return ki_drain_per_sec * ratio

## Retorna true si la raza dada puede usar esta transformación.
func is_available_for_race(race_id: StringName) -> bool:
	if allowed_races.is_empty():
		return true
	return race_id in allowed_races

## Retorna true si el entrenamiento pesado está disponible con esta maestría.
func has_heavy_training(mastery: float) -> bool:
	return mastery >= heavy_training_mastery_threshold
