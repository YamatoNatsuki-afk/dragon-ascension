# Auditoría Técnica — Dragon Ascension (Godot 4)
> **Rol:** Senior Game Architect + Lead Designer
> **Fecha:** 30 de marzo, 2026
> **Archivos revisados:** 85 archivos `.gd`, arquitectura completa de resources, sistemas de checkpoint, minijuegos y combat.

---

## Resumen Ejecutivo

El proyecto tiene una base arquitectónica sólida: el uso de `Custom Resources`, el `EventBus` desacoplado, y la separación entre `DayManager`, `CheckpointSystem` y `BuildAnalyzer` son decisiones correctas. Sin embargo, existen **4 bugs activos** que pueden causar soft-lock o comportamiento incorrecto en producción, y **3 decisiones de diseño** que penalizan injustamente builds defensivos y generan una ruta óptima obvia. A continuación, el análisis por prioridad.

---

## PRIORIDAD ALTA — Bugs activos y riesgos de soft-lock

### A1. Bug crítico: XP escala cuadráticamente con el día

**Archivo:** `data/characters/training/TrainingAction.gd`, línea 104

```gdscript
# CÓDIGO ACTUAL (con bug):
result.xp_gained = total_gain * 10.0 * DifficultyScaler.reward_multiplier(ctx.day_number)

# EL PROBLEMA:
# total_gain ya incluye reward_multiplier(day) en su cálculo (línea 91):
# gain_raw = base_gain * day_scale * (0.5 + weight) * ...
#                        ^^^^^^^^^^^
#                        esto ES reward_multiplier(day)
#
# Por lo tanto XP ∝ reward_multiplier(day)²
# Día 1:   XP multiplier ≈ 1.0² = 1.0x
# Día 50:  XP multiplier ≈ 2.3² = 5.3x
# Día 100: XP multiplier ≈ 2.84² = 8.1x
#
# Un jugador en día 100 gana ~8x más XP que en día 1 POR PUNTO DE STAT GANADO.
# Esto causa nivel máximo muy temprano y puntos de stat sin usar acumulados.
```

**Corrección:**
```gdscript
# OPCIÓN A: Quitar el segundo reward_multiplier (XP proporcional al gain real)
result.xp_gained = total_gain * 10.0

# OPCIÓN B: Usar gain_base sin escalar (XP con escala simple, no compuesta)
result.xp_gained = base_gain * 10.0 * DifficultyScaler.reward_multiplier(ctx.day_number)
```

---

### A2. Bug crítico: flags de resultado pueden corromper FlagSystem

**Archivo:** `core/DayManager.gd`, líneas 287-292

```gdscript
# CÓDIGO ACTUAL (con bug silencioso):
for flag_id: StringName in result_flags:
    _character_data.saved_flags[flag_id] = true
    if FlagSystem.has_method("set_flag"):
        FlagSystem.set_flag(flag_id, true)
    elif FlagSystem.has_method("set"):
        FlagSystem.set(flag_id, true)  # ← PELIGRO: set() en un Node
                                       # setea una PROPIEDAD del Autoload, no un flag
                                       # Godot 4 no distingue — simplemente ejecuta.
```

Si `FlagSystem` no expone `set_flag()` (ej: refactor, typo en el nombre), el `elif` llama a `set(flag_id, true)` que en Godot 4 intenta **setear una propiedad del nodo** con ese nombre. Resultado: datos corruptos silenciosos o errores de acceso.

**Corrección:**
```gdscript
# ROBUSTO: fallar ruidosamente si el contrato no se cumple
for flag_id: StringName in result_flags:
    _character_data.saved_flags[flag_id] = true
    if FlagSystem.has_method("set_flag"):
        FlagSystem.set_flag(flag_id, true)
    else:
        push_error("DayManager: FlagSystem no tiene set_flag(). Flag '%s' solo en saved_flags." % flag_id)
```

---

### A3. Bug de diseño: `expected_score(1)` devuelve 0

**Archivo:** `systems/PerformanceEvaluator.gd`, línea 73

```gdscript
static func _expected_score(day: int) -> float:
    var n := float(max(1, day))
    return EXPECTED_POWER_PER_DAY * (n * log(n) - n + 1.0) * 1.2
    # n=1: 1.8 * (1*log(1) - 1 + 1.0) * 1.2 = 1.8 * 0 * 1.2 = 0.0
```

`performance_ratio()` usa `max(1.0, expected)` como denominador, así que no divide por cero. Pero el efecto es: **en día 1, cualquier power_score > 1.0 da ratio EXCEPTIONAL**. Si el primer checkpoint es el día 1, cualquier personaje pasa con EXCEPTIONAL sin importar sus stats.

```gdscript
# CORRECCIÓN: Añadir una base mínima razonable
static func _expected_score(day: int) -> float:
    var n := float(max(1, day))
    var base := EXPECTED_POWER_PER_DAY * (n * log(n) - n + 1.0) * 1.2
    return maxf(base, EXPECTED_POWER_PER_DAY * n * 0.8)  # mínimo lineal suave
```

---

### A4. Riesgo de soft-lock: overtraining sin `expires_on_day`

**Archivo:** `core/ActionRegistry.gd`, línea 108

```gdscript
func _add_event_overtraining() -> void:
    var a := EventAction.new()
    a.selection_weight = 2.5  # ← el peso MÁS ALTO de todos los eventos
    a.unlock_day = 1           # ← disponible desde día 1, nunca expira
    # outcome: vitalidad -= 8.0, fuerza -= 0.5
    # En día 100 con challenge_multiplier = 2.0x → vitalidad -= 16.0 por evento
```

Un build defensivo que depende de `vitalidad` como stat central puede ser destruido por overtraining repetido en late game. El campo `expires_on_day` no existe en `DayAction`.

**Corrección — añadir `expires_on_day` a DayAction.gd:**
```gdscript
# En DayAction.gd — añadir campo:
@export var expires_on_day: int = 0  # 0 = nunca expira

# En is_available():
func is_available(ctx: DayContext) -> bool:
    if ctx.day_number < unlock_day:
        return false
    if expires_on_day > 0 and ctx.day_number >= expires_on_day:
        return false  # ← nueva condición de expiración
    # ... resto sin cambios
```

Esto también te permite implementar eventos "de ventana": acciones disponibles solo entre días 20-40, creando las decisiones con costo de oportunidad que buscabas.

---

## PRIORIDAD MEDIA — Fallas de diseño que crean ruta óptima

### M1. La curva de expectativa penaliza builds defensivos injustamente

**El problema raíz está en la interacción entre dos fórmulas:**

```gdscript
# PerformanceEvaluator.compute_power_score():
score += val * (0.5 + priority)  # priority = stat_priority_weight

# TrainingAction.execute() — stat primario:
gain_raw = base_gain * day_scale * (0.5 + weight) * scale_mult * mini_mult
```

Un striker con `fuerza=1.0` gana `base_gain * 1.5` de fuerza, y esa fuerza se cuenta como `fuerza_val * 1.5` en el power_score. La sinergia es `1.5 × 1.5 = 2.25x` multiplicador efectivo.

Un defensive con `vitalidad=1.0` hace exactamente lo mismo → `1.5 × 1.5 = 2.25x`. Hasta aquí es justo.

**El problema real:** El evento `overtraining` tiene `selection_weight = 2.5` y hace `-8.0` a vitalidad. Para un striker, perder 8 de vitalidad tiene impacto casi nulo en su power_score (porque weight vitalidad ≈ 0, multiplier = 0.5). Para un defensive, es `-8.0 * 1.5 = -12.0` de power_score en un solo evento.

**Recalibración Bottom-Up recomendada:**

```gdscript
# Paso 1: Ejecutar simulaciones para cada build archetype
# (ya tienes debug_run_simulation() y ProgressTracker.gd)
# Nota: este sería tu workflow de calibración manual, no código de producción

# Paso 2: Ajustar expected_score para reflejar la ganancia real por acción
# Fórmula propuesta que escala con el promedio de acciones disponibles:

static func _expected_score(day: int) -> float:
    var n := float(max(1, day))
    # Ganancia base esperada por día, INCLUYENDO que no todos los días son óptimos
    # Factor 0.7 = ajuste para 70th percentile de jugadores (no el jugador perfecto)
    var daily_gain_estimate := 2.0 * DifficultyScaler.reward_multiplier(int(n)) * 1.0 * 0.7
    # Integral aproximada: acumulado hasta día n
    var cumulative := daily_gain_estimate * (n * log(max(n, 1.0)) * 0.4 + n * 0.6)
    # El power_score pondera con (0.5 + priority_avg), promedio ~1.0 para builds enfocados
    return cumulative * 1.0
```

**Recomendación práctica:** Reemplaza los thresholds fijos por un sistema de grading relativo. En vez de comparar contra una curva matemática, compara contra el percentil del histórico de simulaciones:

```gdscript
# En PerformanceEvaluator — añadir sistema de percentiles calibrado:
const GRADE_PERCENTILES: Dictionary = {
    Grade.EXCEPTIONAL: 0.85,  # top 15% de runs simulados
    Grade.HIGH:        0.60,  # top 40%
    Grade.NORMAL:      0.35,  # top 65%
    # LOW: cualquier cosa por debajo
}
```

---

### M2. `compute_power_score` crea trampa implícita para jugadores que cambian de build

Si un jugador entrena fuerza durante 40 días pero luego cambia sus `stat_priority_weights` a ki (sin respec), su power_score **cae instantáneamente** aunque sus stats reales no cambiaron. El checkpoint del día 50 lo puede penalizar sin que haya "jugado mal".

**Corrección — separar el score de identidad del score de progresión:**

```gdscript
# PerformanceEvaluator — dos scores distintos:

## Score de PROGRESIÓN: usa pesos neutrales (0.0 + 1.0 = igual para todos los stats)
## Mide cuánto stat total acumulaste, sin importar el build
static func compute_progression_score(data) -> float:
    var score: float = 0.0
    for stat_id in data.base_stats:
        score += data.base_stats[stat_id]
    return score

## Score de IDENTIDAD: usa pesos del build (mide qué tan bien ejecutaste TU build)
## Solo usado para feedback narrativo, no para checkpoints bloqueantes
static func compute_identity_score(data) -> float:
    var weights: Dictionary = data.build.stat_priority_weights
    var score: float = 0.0
    for stat_id in data.base_stats:
        var val: float = data.base_stats[stat_id]
        var priority: float = weights.get(stat_id, 0.5)
        score += val * (0.5 + priority)
    return score
```

Los **checkpoints bloqueantes** (si los activas) deben usar `compute_progression_score`, que es justo para todos los builds. El `compute_identity_score` es para la narrativa: "Tu dedicación como Striker supera toda expectativa."

---

### M3. Sobre la separación BuildIdentityData vs TrainingProgressData

Tu intuición es correcta, pero el código actual **ya resuelve el problema de respec** con `reset_bonuses()`. La separación tiene valor real en tres escenarios específicos:

```
SEPARAR SÍ cuando necesites:
  1. Sistema de presets/loadouts: guarda múltiples identidades y alterna entre ellas
  2. Pantalla de selección: carga solo la identidad (sin bonuses) para mostrar en UI
  3. Multiplayer/comparación: transmitir identidad sin exponer el progreso

SEPARAR NO si:
  - Solo tienes un personaje activo a la vez (estado actual del proyecto)
  - El respec solo hace reset_bonuses() — ya funciona
```

Si decides separar, el contrato mínimo sería:

```gdscript
# BuildIdentityData.gd — solo la intención
class_name BuildIdentityData
extends Resource

@export var combat_style: StringName = &"balanced"
@export var stat_priority_weights: Dictionary = {}
@export var archetype_label: String = ""  # "Striker", "Ki User", etc.

# TrainingProgressData.gd — solo la progresión acumulada
class_name TrainingProgressData
extends Resource

@export var stat_bonuses: Dictionary = {}

func reset() -> void:
    for key in stat_bonuses:
        stat_bonuses[key] = 0

# CharacterData tendría ambos:
# @export var build_identity: BuildIdentityData
# @export var training_progress: TrainingProgressData
```

**Advertencia de migración:** Si separas ahora, `PerformanceEvaluator`, `BuildAnalyzer`, `TrainingAction`, y `DayManager._log_build()` necesitan actualizar cómo acceden a los datos. Es refactor no trivial para un MVP.

---

## PRIORIDAD BAJA — Deuda técnica y escalabilidad

### B1. Propuesta de `BaseMinigame.gd` — contrato estandarizado

El problema actual: `DayScreen` usa duck-typing para detectar minijuegos, y `SnakeRoadMinigame` requiere 3 variables de estado especiales en DayScreen que ningún otro minijuego necesita. Esto viola el principio de que DayScreen no debe conocer la implementación de cada minijuego.

**Implementación de `MinigameResult.gd` (nuevo Resource):**
```gdscript
# res://data/minigames/MinigameResult.gd
class_name MinigameResult
extends RefCounted

var minigame_id: StringName = &""
var multiplier: float = 1.0          # 0.5 (poor) → 2.0 (perfect)
var score_pct: float = 0.0           # 0.0 → 1.0 para récords
var metadata: Dictionary = {}        # score, combo, time, etc. — específico de cada minijuego
```

**Implementación de `BaseMinigame.gd`:**
```gdscript
# res://scenes/minigames/BaseMinigame.gd
class_name BaseMinigame
extends Control

## Contrato único con DayScreen y DayManager.
## Todo minijuego DEBE heredar de esto.
signal completed(result: MinigameResult)

## ID único para MinigameRecordSystem.
@export var minigame_id: StringName = &""

## Tipos de acción compatibles con este minijuego.
@export var supported_action_types: Array[StringName] = [&"training"]

# Datos configurados por DayScreen antes de add_child()
var _action_name: String = ""
var _target_stats: Array[StringName] = []

## Punto de entrada único desde DayScreen.
## Override setup_extra() en subclases para datos adicionales.
func setup(action_name: String, target_stats: Array[StringName]) -> void:
    _action_name  = action_name
    _target_stats = target_stats
    setup_extra()

## Override en subclases si necesitan configuración extra (ej: SnakeRoad necesita km_base).
func setup_extra() -> void:
    pass

## Llamar desde subclases cuando el minijuego termina.
## Centraliza la creación del resultado y el registro de récords.
func _finish_with_score(multiplier: float, score_pct: float, extra_meta: Dictionary = {}) -> void:
    var result        := MinigameResult.new()
    result.minigame_id = minigame_id
    result.multiplier  = clampf(multiplier, 0.5, 2.0)
    result.score_pct   = clampf(score_pct, 0.0, 1.0)
    result.metadata    = extra_meta
    completed.emit(result)
```

**DayScreen solo necesita saber:**
```gdscript
# En DayScreen — lanzar un minijuego:
func _launch_minigame(minigame: BaseMinigame, action: DayAction) -> void:
    minigame.setup(action.display_name, action.target_stats if action.has("target_stats") else [])
    _minigame_overlay = minigame
    minigame.completed.connect(_on_minigame_completed)
    add_child(minigame)

func _on_minigame_completed(result: MinigameResult) -> void:
    DayManager.pending_training_multiplier = result.multiplier
    MinigameRecordSystem.record(result)  # ya tienes este sistema
    _cleanup_minigame()
    DayManager.execute_action(_pending_training_action)
```

Nota: `SnakeRoadMinigame` necesitaría pasar sus datos especiales vía `setup_extra()` con una variable exportada o un método específico en la subclase, no en DayScreen.

---

### B2. `CheckpointSystem._find_event_bus()` es frágil

```gdscript
# CÓDIGO ACTUAL — busca con lista de nombres candidatos:
var candidates := ["EventBus", "event_bus", "Events", "Bus", "GameEvents", "SignalBus"]

# CORRECCIÓN — acoplar al nombre configurado en Project Settings:
const EVENT_BUS_AUTOLOAD_NAME := "EventBus"  # Debe coincidir con project.godot

func _connect_signals() -> void:
    var bus := get_node_or_null("/root/" + EVENT_BUS_AUTOLOAD_NAME)
    assert(bus != null,
        "[CheckpointSystem] EventBus no encontrado en '/root/%s'. " % EVENT_BUS_AUTOLOAD_NAME +
        "Verifica Project Settings → Autoloads.")
    bus.day_ended.connect(_on_day_ended)
```

El mismo patrón de `_find_event_bus()` existe en `DayScreen` — también debería simplificarse.

---

### B3. `BuildAnalyzer` tiene un cache estático que no se invalida

```gdscript
# BuildAnalyzer.gd:
static var _profiles: Array[BuildProfile] = []
static var _profiles_loaded: bool = false
```

En Godot 4, las variables estáticas persisten entre escenas en la misma sesión. Si modificas un `.tres` de perfil en el editor durante desarrollo, los cambios no se reflejan hasta reiniciar. El método `reload_profiles()` existe pero nadie lo llama.

**Corrección para desarrollo:**
```gdscript
# Añadir en _ensure_profiles_loaded() para builds de debug:
static func _ensure_profiles_loaded() -> void:
    if _profiles_loaded:
        return
    # En debug, recargar siempre para reflejar cambios del editor
    if OS.is_debug_build():
        _profiles_loaded = false
    # ... resto sin cambios
```

---

## Verificación de la Fórmula de Checkpoints — Análisis Numérico

```
Fórmula actual: expected_score(n) = 1.8 * (n*ln(n) - n + 1.0) * 1.2

Simulación de un Striker puro (fuerza weight=1.0, base_gain=2.0):
  Ganancia diaria ≈ 2.0 * reward_mult(day) * 1.5
  Ganancia acumulada en día N ≈ 3.0 * integral(1,N) [1 + 0.4*ln(t)] dt
                              ≈ 3.0 * [0.6*N + 0.4*N*ln(N) - 0.6]

  Día 25: fuerza acumulada ≈ 3.0 * [15 + 10*3.22 - 0.6] ≈ 140
          power_score ≈ 140 * 1.5 = 210
          expected_score(25) ≈ 122
          ratio = 1.72 → SIEMPRE EXCEPTIONAL ⚠️

Simulación de un Balanced (todos los weights en 0.5, split entre 3 stats):
  power_score(25) ≈ 93
  expected_score(25) ≈ 122
  ratio = 0.76 → apenas NORMAL ⚠️

CONCLUSIÓN: La curva favorece masivamente a builds focalizados.
El 1.2 de corrección fue insuficiente — debería ser ~0.75 para hacer la curva
alcanzable por builds balanceados sin penalizarlos.

CORRECCIÓN RECOMENDADA:
  expected_score(n) = 1.8 * (n*ln(n) - n + 1.0) * 0.75

  Verifica con debug_run_simulation() usando seed fija antes de cambiar.
```

---

## Preguntas Provocativas

**Sobre la arquitectura:**
- Si el jugador puede "ver" sus `stat_priority_weights` en la UI como porcentajes de intención, ¿qué pasa cuando la IA de entrenamiento ignora esas intenciones porque no hay acciones disponibles que los suban? ¿El jugador siente que el juego "no lo escucha"?
- ¿Por qué el `combat_style` vive en `BuildData` si el `BuildAnalyzer` ya determina la identidad de build dinámicamente? ¿Son la misma cosa expresada dos veces?

**Sobre el loop de 100 días:**
- Si cada día se toma UNA decisión, ¿qué pasa el día 99 cuando el jugador sabe exactamente qué build es? ¿Las últimas 10 decisiones son emocionantes o mecánicas? El `expires_on_day` que propones podría ser la respuesta, pero ¿hay suficientes acciones "de ventana" diseñadas para crear urgencia real?
- El minijuego multiplica las ganancias de 0.5x a 2.0x. Eso significa que la HABILIDAD en el minijuego tiene más impacto que la ESTRATEGIA de elección de acción en muchos casos. ¿Eso es el juego que querés hacer?

**Sobre el modelo de datos:**
- Actualmente `CharacterData.base_stats` es un `Dictionary` sin tipado estricto. ¿Qué pasa cuando en el día 75 agregás un stat nuevo (`instinto` para la transformación SSJ4)? ¿Todos los savegames existentes tienen `0` para ese stat, o tienen `null`, o crashean?
- El `SaveSystem.save_character()` se llama al final de cada día Y después de cada checkpoint. Si el juego crashea ENTRE esas dos llamadas (ej: durante la ejecución de consecuencias), ¿el savegame queda en un estado inconsistente?

**Sobre el futuro del proyecto:**
- ¿El sistema de checkpoints "bloqueantes" (`is_blocking = true`) está pensado para dificultades altas o para el modo principal? Si bloquea el juego cuando la fórmula está descalibrada, los primeros players en probar el juego tendrán una pésima experiencia.
- El `DebugDayLoop` existe y es poderoso. ¿Tenés una suite de simulaciones que corras antes de cada commit para verificar que el balance no se rompió? Ese debería ser tu primer `CI` antes de código.

---

## Checklist de Acción Inmediata

| Prioridad | Archivo | Cambio |
|-----------|---------|--------|
| 🔴 Alta | `TrainingAction.gd:104` | Quitar segundo `reward_multiplier` del cálculo de XP |
| 🔴 Alta | `DayManager.gd:292` | Eliminar el `elif FlagSystem.set()` — falla ruidosamente |
| 🔴 Alta | `PerformanceEvaluator.gd:74` | Añadir base mínima a `expected_score(1)` |
| 🔴 Alta | `DayAction.gd` | Añadir `expires_on_day: int = 0` y evaluarlo en `is_available()` |
| 🟡 Media | `PerformanceEvaluator.gd` | Cambiar factor 1.2 → 0.75 en la curva de expectativa |
| 🟡 Media | `PerformanceEvaluator.gd` | Separar `compute_progression_score()` del `compute_identity_score()` |
| 🟡 Media | `ActionRegistry.gd` | Bajar `overtraining.selection_weight` a 1.0 y añadir `expires_on_day = 60` |
| 🟢 Baja | `BaseMinigame.gd` | Crear clase base con señal `completed(result: MinigameResult)` |
| 🟢 Baja | `CheckpointSystem.gd` | Reemplazar `_find_event_bus()` con referencia directa al nombre canónico |
| 🟢 Baja | `BuildAnalyzer.gd` | Añadir invalidación de cache en debug builds |
