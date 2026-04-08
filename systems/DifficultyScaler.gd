# res://systems/DifficultyScaler.gd
# Utilidad estática pura — sin estado, sin nodo, sin autoload.
# Todas las fórmulas en un solo lugar para facilitar balance.
class_name DifficultyScaler
extends RefCounted

## Multiplicador de recompensas (XP, ganancias de stat).
## Crece rápido al principio, se aplana después del día 50.
## Día 1 = 1.0x, Día 25 = ~1.8x, Día 50 = ~2.3x, Día 100 = ~2.7x
static func reward_multiplier(day: int) -> float:
	return 1.0 + log(max(1, day)) * 0.4

## Multiplicador de dificultad para eventos y combates.
## Lineal y más suave que las recompensas para que el riesgo sea manejable.
## Día 1 = 1.0x, Día 50 = 1.49x, Día 100 = 1.99x
static func challenge_multiplier(day: int) -> float:
	return 1.0 + (day - 1) * 0.01

## Factor de varianza — cuánta aleatoriedad hay en el resultado.
## Aumenta con los días para mantener la tensión.
## Rango: 0.1 (día 1) a 0.35 (día 100)
static func variance_factor(day: int) -> float:
	return lerp(0.1, 0.35, clampf((day - 1) / 99.0, 0.0, 1.0))

## Aplica varianza aleatoria a un valor base usando el RNG del contexto.
## Ej: apply_variance(10.0, 0.2, rng) devuelve entre 8.0 y 12.0
static func apply_variance(base_value: float, variance: float, rng: RandomNumberGenerator) -> float:
	var min_v := base_value * (1.0 - variance)
	var max_v := base_value * (1.0 + variance)
	return rng.randf_range(min_v, max_v)
