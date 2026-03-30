# res://core/BuildData.gd
#
# Representa la configuración de build de un personaje.
# Contiene dos tipos de datos:
#
#   stat_bonuses          → bonuses PLANOS acumulados por entrenamiento/equipo.
#                           Se suman sobre CharacterData.base_stats al calcular el stat final.
#
#   stat_priority_weights → pesos que indican al sistema de entrenamiento
#                           qué stats priorizar. 0.0 = ignorar, 1.0 = máxima prioridad.
#                           NO afectan stats directamente — solo guían la IA de entrenamiento.
#
#   combat_style          → estilo de combate del personaje. Usado por el sistema
#                           de combate para seleccionar comportamientos y animaciones.

class_name BuildData
extends Resource

# ─────────────────────────────────────────────────────────
# Constantes
# ─────────────────────────────────────────────────────────

## IDs canónicos del sistema. Deben coincidir con StatDefinition .tres
const STAT_IDS: Array[StringName] = [
	&"fuerza",
	&"velocidad",
	&"ki",
	&"vitalidad",
	&"resistencia",
	&"poder_ki",
	&"inteligencia",
	&"intel_combate",
]

## Estilos de combate disponibles.
## Usados por AttackState, AnimationController y BuildAnalyzer.
const COMBAT_STYLES: Array[StringName] = [
	&"striker",    # Físico agresivo, combos cortos
	&"ki_user",    # Ki blasts y distancia
	&"balanced",   # Mixto
	&"defensive",  # Contraataques y resistencia
]

# ─────────────────────────────────────────────────────────
# Datos exportados
# ─────────────────────────────────────────────────────────

## Nombre descriptivo del build (debug y UI de personalización)
@export var build_name: String = "Default"

## Estilo de combate activo. Determina comportamientos en combate.
@export var combat_style: StringName = &"balanced"

## Bonuses PLANOS acumulados sobre base_stats.
## Modificados por entrenamiento completado y equipo equipado.
@export var stat_bonuses: Dictionary = {
	&"fuerza":        0,
	&"velocidad":     0,
	&"ki":            0,
	&"vitalidad":     0,
	&"resistencia":   0,
	&"poder_ki":      0,
	&"inteligencia":  0,
	&"intel_combate": 0,
}

## Pesos de prioridad para el sistema de entrenamiento.
## 0.0 = nunca entrenar este stat | 1.0 = máxima prioridad.
## No afectan stats directamente.
@export var stat_priority_weights: Dictionary = {
	&"fuerza":        0.5,
	&"velocidad":     0.5,
	&"ki":            0.5,
	&"vitalidad":     0.5,
	&"resistencia":   0.5,
	&"poder_ki":      0.5,
	&"inteligencia":  0.5,
	&"intel_combate": 0.5,
}

# ─────────────────────────────────────────────────────────
# API pública — stat_bonuses
# ─────────────────────────────────────────────────────────

## Devuelve el bonus plano de un stat. Retorna 0 si el ID no existe.
func get_bonus(stat_id: StringName) -> int:
	if not stat_bonuses.has(stat_id):
		push_warning("BuildData.get_bonus: stat_id desconocido '%s'" % stat_id)
		return 0
	return stat_bonuses[stat_id]

## Aplica un bonus plano a un stat. Valida que el ID sea canónico.
func apply_bonus(stat_id: StringName, amount: int) -> void:
	if not stat_bonuses.has(stat_id):
		push_error("BuildData.apply_bonus: stat_id inválido '%s'" % stat_id)
		return
	stat_bonuses[stat_id] += amount

## Resetea todos los bonuses a 0 (respec de entrenamiento).
func reset_bonuses() -> void:
	for key in stat_bonuses:
		stat_bonuses[key] = 0

# ─────────────────────────────────────────────────────────
# API pública — stat_priority_weights
# ─────────────────────────────────────────────────────────

## Devuelve el peso de prioridad de un stat. Retorna 0.5 si no existe.
func get_weight(stat_id: StringName) -> float:
	return stat_priority_weights.get(stat_id, 0.5)

## Asigna el peso de prioridad de un stat. Clampea entre 0.0 y 1.0.
func set_weight(stat_id: StringName, weight: float) -> void:
	if not stat_priority_weights.has(stat_id):
		push_error("BuildData.set_weight: stat_id inválido '%s'" % stat_id)
		return
	stat_priority_weights[stat_id] = clampf(weight, 0.0, 1.0)

# ─────────────────────────────────────────────────────────
# API pública — validación
# ─────────────────────────────────────────────────────────

## Devuelve true si todos los IDs en ambos dicts son canónicos.
## Úsalo en SaveSystem y tests.
func is_valid() -> bool:
	for key in stat_bonuses:
		if key not in STAT_IDS:
			return false
	for key in stat_priority_weights:
		if key not in STAT_IDS:
			return false
	if combat_style not in COMBAT_STYLES:
		push_warning("BuildData.is_valid: combat_style '%s' no reconocido." % combat_style)
	return true

## Debug: imprime el build completo en consola.
func debug_print() -> void:
	print("=== BuildData: %s (estilo: %s) ===" % [build_name, combat_style])
	print("  -- Bonuses --")
	for stat_id in STAT_IDS:
		print("    %s: +%d" % [stat_id, get_bonus(stat_id)])
	print("  -- Pesos de entrenamiento --")
	for stat_id in STAT_IDS:
		print("    %s: %.2f" % [stat_id, get_weight(stat_id)])
