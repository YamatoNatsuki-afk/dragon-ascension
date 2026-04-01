# res://systems/CombatFormulas.gd
#
# Utilidad estática — centraliza TODAS las fórmulas de combate.
# No extiende Node; no se instancia. Se llama directamente:
#   CombatFormulas.get_move_speed(velocidad)
#
# PRINCIPIO DE DISEÑO:
#   Todas las fórmulas usan diminishing returns (forma x/(x+k))
#   para que el juego sea jugable en TODOS los tiers (Civil → Absoluto).
#
# RANGOS ESPERADOS POR TIER:
#   Civil         (stat ~13):  velocidad→194  daño→113  ki→78
#   Elite         (stat ~120): velocidad→372  daño→375  ki→720
#   Legendario    (stat ~1000):velocidad→520  daño→476  ki→6000
#
class_name CombatFormulas


# ─────────────────────────────────────────────────────────────────────────────
# MOVIMIENTO
# ─────────────────────────────────────────────────────────────────────────────

## Velocidad de movimiento en píxeles/segundo.
## Rango: ~194 px/s (Civil) → ~520 px/s (Legendario+)
## Arena = 1152px. A 350 px/s cruzarla tarda ~3.3s — rango de combate correcto.
static func get_move_speed(velocidad: float) -> float:
	return 150.0 + (velocidad / (velocidad + 80.0)) * 400.0


# ─────────────────────────────────────────────────────────────────────────────
# DAÑO FÍSICO
# ─────────────────────────────────────────────────────────────────────────────

## Daño base de un ataque físico normal.
## intel_combate añade un bonus menor — el expertise mejora la eficiencia del golpe.
## Rango: ~113 (Civil fuerza=13) → ~476 (Legendario fuerza=1000)
static func get_phys_damage(fuerza: float, intel_combate: float = 0.0) -> float:
	var base: float  = (fuerza / (fuerza + 50.0)) * 500.0
	var bonus: float = intel_combate * 0.5
	return base + bonus


# ─────────────────────────────────────────────────────────────────────────────
# DAÑO KI
# ─────────────────────────────────────────────────────────────────────────────

## Daño de un ataque de Ki (blast, kamehameha, etc.).
## poder_ki es el stat primario; ki añade volumen de energía.
## Rango: ~130 (Civil) → ~570 (Legendario)
static func get_ki_damage(poder_ki: float, ki: float = 0.0) -> float:
	var base: float  = (poder_ki / (poder_ki + 50.0)) * 600.0
	var bonus: float = (ki / (ki + 200.0)) * 100.0
	return base + bonus


# ─────────────────────────────────────────────────────────────────────────────
# KI
# ─────────────────────────────────────────────────────────────────────────────

## Ki máximo del jugador.
## Rango: ~78 (Civil ki=13) → ~6150 (Legendario ki=1000)
static func get_max_ki(ki: float, poder_ki: float = 0.0) -> float:
	return ki * 6.0 + poder_ki * 3.0

## Ki regenerado por segundo (pasivamente, sin cargar).
## Al menos 1.0/s para que el sistema nunca se quede bloqueado.
static func get_ki_regen(ki: float) -> float:
	return maxf(ki * 0.05, 1.0)

## Ki regenerado por segundo mientras se carga activamente (botón hold).
## 5× la regen pasiva — carga manual es significativamente más rápida.
static func get_ki_charge_rate(ki: float) -> float:
	return get_ki_regen(ki) * 5.0

## Costo de Ki de un Ki Blast estándar.
## Escala suavemente para que en tiers bajos no sea imposible pagar.
static func get_ki_blast_cost(max_ki: float) -> float:
	return maxf(max_ki * 0.15, 5.0)  # 15% del Ki máximo, mínimo 5


# ─────────────────────────────────────────────────────────────────────────────
# DEFENSA
# ─────────────────────────────────────────────────────────────────────────────

## Porcentaje de mitigación de daño (0.0–0.75 hard cap).
## Fórmula de diminishing returns: nunca bloquea más del 75%.
## En HealthComponent ya existe esta fórmula — referencia a aquí en futuras refactors.
static func get_mitigation(resistencia: float) -> float:
	return minf(resistencia / (resistencia + 100.0), 0.75)


# ─────────────────────────────────────────────────────────────────────────────
# COOLDOWNS
# ─────────────────────────────────────────────────────────────────────────────

## Cooldown real de ataque físico (segundos).
## intel_combate reduce hasta un 40% el cooldown base.
static func get_attack_cooldown(intel_combate: float, base_cooldown: float = 0.7) -> float:
	return base_cooldown * (1.0 - intel_combate / (intel_combate + 150.0))


# ─────────────────────────────────────────────────────────────────────────────
# ESQUIVE
# ─────────────────────────────────────────────────────────────────────────────

## Probabilidad de esquivar un ataque (0.0–0.75).
## Documentado también en Enemy.gd — esta es la fuente canónica.
## Con velocidad=60, intel_combate=6:  ~22%
## Con velocidad=120, intel_combate=60: ~55%
static func get_dodge_chance(velocidad: float, intel_combate: float) -> float:
	var dodge_vel: float = (velocidad / (velocidad + 100.0)) * 0.50
	var dodge_ic: float  = (intel_combate / (intel_combate + 50.0))  * 0.30
	return minf(dodge_vel + dodge_ic, 0.75)
