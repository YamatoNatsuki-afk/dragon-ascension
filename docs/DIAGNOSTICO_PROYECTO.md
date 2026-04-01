# Dragon Ascension — Diagnóstico y Mapa del Proyecto

> Generado: 2026-04-01
> Estado del engine: Godot 4.6.1
> Rama de referencia: `dragon-ascension-main`

---

## 1. Mapa de Arquitectura

### 1.1 Capas del sistema

```
┌─────────────────────────────────────────────────────────────────┐
│  CAPA DE PRESENTACIÓN                                           │
│  scenes/DayScreen.tscn  ←→  scenes/CombatArena.tscn            │
│  scenes/CharacterCreationScreen.tscn                            │
│  scenes/*Minigame.tscn (×7)  ·  scenes/TrainingGround.tscn     │
│  ui/hud/HUD.tscn                                                │
└───────────────────────┬─────────────────────────────────────────┘
                        │ señales EventBus / llamadas directas
┌───────────────────────▼─────────────────────────────────────────┐
│  AUTOLOADS (singletons)                                         │
│                                                                 │
│  GameManager ──────► DayManager ──────────────────────────────► │
│     │                  │  ↕ EventBus (bus central)              │
│     │           NpcSystem   CheckpointSystem   FlagSystem       │
│     │           TransformationSystem   BuildAnalyzer            │
│     │           CombatManager   ActionRegistry                  │
│     │           StatRegistry   RaceRegistry                     │
│     │           TransformationRegistry   GameStateProvider      │
│     │                                                           │
│     └──► SaveSystem  (lectura/escritura de CharacterData)       │
└───────────────────────┬─────────────────────────────────────────┘
                        │ instancia y destruye
┌───────────────────────▼─────────────────────────────────────────┐
│  ENTIDADES EN ESCENA                                            │
│  Player (CharacterBody2D)                                       │
│    ├── StatsComponent   HealthComponent   KiComponent           │
│    └── PlayerStateMachine                                       │
│         └── [Idle · Move · Attack · KiBlast · KiCharge         │
│              Fly · Hurt · Transform]                            │
│  Enemy (CharacterBody2D)                                        │
│    └── comportamientos: MELEE · RANGED · HYBRID                 │
└───────────────────────┬─────────────────────────────────────────┘
                        │ lee
┌───────────────────────▼─────────────────────────────────────────┐
│  CAPA DE DATOS (Resources)                                      │
│  CharacterData  ·  SkillData  ·  SkillLoadout                   │
│  EnemyData  ·  TransformationDefinition  ·  TransformationState │
│  RaceDefinition  ·  StatDefinition  ·  BuildProfile             │
│  DayAction (y subtipos)  ·  CheckpointDefinition                │
│  NpcDefinition  ·  NpcRelationState  ·  NpcTrainingAction       │
│  EquipmentData  ·  EquipmentItem                                │
│  CheckpointConsequence (y subtipos ×5)                          │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Flujo del loop de día

```
GameManager.start_run()
    └─► DayManager._start_day()          [señal: day_started]
            └─► DayScreen muestra acciones disponibles
                    └─► jugador elige acción
                            └─► DayManager.execute_action(action)
                                    ├─► SYNC: TrainingAction / EventAction / NpcEncounterAction
                                    │       └─► DayManager._resolve()
                                    │               ├── aplica stat changes
                                    │               ├── XP + level-up
                                    │               ├── flags
                                    │               ├── TransformationSystem.check_unlock_conditions()
                                    │               └── NpcSystem.update_relations()
                                    │
                                    └─► ASYNC: CombatEventAction
                                            └─► await EventBus.combat_result_ready
                                                    ← CombatArena emite resultado
                                                            └─► DayManager._resolve()
                            └─► DayManager._end_day()
                                    ├── current_day++
                                    ├── SaveSystem.save()
                                    ├── señal day_ended
                                    └── si day == 100: señal game_completed
```

### 1.3 Flujo de combate

```
CombatArena._ready()
    └─► CombatManager.start_combat(character_data, enemy_data?)
            ├─► instancia Player.tscn → Player.setup(data)
            ├─► instancia Enemy.tscn → Enemy.setup(day, enemy_data?)
            ├─► TransformationSystem.start_combat(player, data)
            └─► señal: combat_started

[loop: Player state machine ↔ Enemy AI]
    ├── Player inputs → AttackState / KiBlastState / KiChargeState / FlyState
    ├── CombatFormulas → daño, esquive, cooldowns, velocidad
    ├── EventBus: damage_dealt, combo_updated, player_health_changed, player_ki_changed
    └── Enemy.died → CombatArena._end_combat(won=true)
        Player.died → CombatArena._end_combat(won=false)

CombatArena._end_combat()
    └─► señal: combat_result_ready(result: CombatResult)
            └─► DayManager._resolve() ← retoma el await
```

---

## 2. Inventario de Recursos (.tres existentes)

### Implementados y poblados con datos reales

| Categoría | Archivos .tres | Estado |
|---|---|---|
| **Razas** | `saiyan`, `human`, `namekian` | ✅ Completo (3/3) |
| **Stats** | `fuerza`, `velocidad`, `ki`, `vitalidad`, `resistencia`, `poder_ki`, `inteligencia`, `intel_combate` | ✅ Completo (8/8) |
| **Entrenamiento** | 15 maestros/locaciones (`train_fuerza`, `train_ki`, `train_muten_roshi`, `train_kaio`, `train_kami`, etc.) | ✅ Sólido |
| **Checkpoints** | `cp_day_25`, `cp_day_50`, `cp_day_75`, `cp_day_100` | ✅ Estructura básica |
| **Eventos narrativos** | 7 eventos (`encounter_bulma`, `rival_challenge`, `overtraining`, etc.) | ✅ Base inicial |
| **Build profiles** | `balanced`, `striker`, `defensive`, `ki_user` | ✅ Funcional |
| **Acción de combate** | `bandit_encounter` | ✅ 1 arquetipo |
| **Snake Road** | `snake_road.tres` | ✅ Funcional |

### Diseñados pero vacíos / sin instanciar

| Categoría | .gd existe | .tres existe | Brecha |
|---|---|---|---|
| **SkillData** | ✅ | ❌ (solo `skills_placeholder.txt`) | **CRÍTICA** — 0 habilidades como recurso |
| **TransformationDefinition** | ✅ | ❌ | **CRÍTICA** — 0 transformaciones como recurso |
| **EnemyData** | ✅ | ❌ | **ALTA** — solo el genérico por día |
| **NpcDefinition** | ✅ | ❌ | **ALTA** — NpcSystem sin NPCs definidos |
| **EquipmentData / EquipmentItem** | ✅ | ❌ | **MEDIA** — Semillas y objetos sin instanciar |

---

## 3. Estado de Implementación por Sistema

### 3.1 Loop de día ← **FUNCIONAL**
- DayManager con máquina de fases completa (IDLE → DAY_START → AWAITING_ACTION → EXECUTING → RESOLVING → DAY_END)
- Acciones sync y async funcionando
- XP, levelup, flags, stats operativos

### 3.2 Combate 2D ← **FUNCIONAL (base sólida)**
- Player con 8 estados implementados
- Enemy con 3 comportamientos (MELEE / RANGED / HYBRID)
- CombatFormulas con 10 fórmulas tuneadas y con diminishing returns
- Esquive con probabilidad, cooldowns variables por intel_combate

### 3.3 Sistema de transformaciones ← **ARQUITECTURA LISTA, SIN DATOS**
- TransformationSystem, TransformationRegistry, TransformationState: código completo
- Lógica de activación, multiplicadores, drenaje, maestría: implementada
- Condiciones de desbloqueo: Kaio-ken ×1/×3/×4, Oozaru, SSJ1, Forma Gigante codificadas
- **Falta:** cero archivos `.tres` de TransformationDefinition — las transformaciones no existen en runtime

### 3.4 Sistema de habilidades ← **DATOS LISTOS, EJECUTOR INEXISTENTE**
- SkillData.gd completamente definido (incluyendo los 8 campos añadidos este proyecto)
- SkillLoadout.gd existe para equipar habilidades
- **Falta:** cero archivos `.tres` de SkillData; ningún sistema que ejecute habilidades en combate

### 3.5 NPC y relaciones ← **ESQUELETO SIN CONTENIDO**
- NpcSystem.gd y NpcRelationState.gd existen
- NpcTrainingAction, NpcEncounterAction, NpcEncounterOutcome existen
- **Falta:** cero NpcDefinition .tres — los NPCs no tienen identidad en runtime

### 3.6 Checkpoints y consecuencias ← **FUNCIONAL (básico)**
- CheckpointSystem con 5 tipos de consecuencias implementados
- 4 checkpoints de hito (días 25/50/75/100) definidos
- Consecuencias: ModifyStat, SetFlag, UnlockAction, InjectEvent, ModifySelectionWeight

### 3.7 Minijuegos ← **FUNCIONAL (sin integración de stats)**
- 7 minijuegos implementados como escenas independientes
- MinigameRecordSystem con milestones y bonificaciones de stats
- La integración de récords con stats funciona vía EventBus

---

## 4. Brechas Críticas — Sistemas Diseñados Sin Código

Las siguientes mecánicas están **documentadas en detalle** en `docs/` pero **no tienen ningún código de ejecución** en el proyecto:

### 4.1 Sistema de Pasivas ← **NO EXISTE**
**Impacto:** BLOQUEANTE para la mayoría del contenido documentado

Habilidades como `Precognición Tipo 1`, `Evolución Reactiva`, `Eficiencia de Ki Refinada`, `Aura`, `Detectar Contenciones`, `Caótico Bueno` son pasivas permanentes o de combate. Actualmente no hay ningún sistema que las registre o aplique.

**Necesita:** `PassiveSystem.gd` que lea `SkillLoadout.passive_skills[]` del CharacterData y aplique efectos al inicio del combate / por turno / bajo condición.

```
Propuesta mínima:
PassiveSystem.gd (autoload o componente de CombatManager)
  ├── apply_combat_passives(character_data, context)  ← al inicio del combate
  ├── on_turn_start(player, enemy, context)           ← cada frame/turno
  └── on_condition(event, player, enemy)              ← por evento (hurt, ki_low, etc.)
```

### 4.2 Sistema de Ejecución de Skills ← **NO EXISTE**
**Impacto:** BLOQUEANTE para combate avanzado

SkillData define parámetros. Nada los ejecuta. No hay SkillExecutor, ni handler de skills activos en Player ni en CombatManager.

**Necesita:** Un `SkillExecutor.gd` que tome un `SkillData` + contexto y resuelva daño, efectos, cooldowns, consumo de Ki. Probablemente uno por tipo (STRIKE, KI_BLAST, SUPPORT, ULTIMATE) o un sistema de efectos genérico.

### 4.3 Sistema de Estados de Control (Status Effects) ← **NO EXISTE**
**Impacto:** ALTA — necesario para Puntos de Presión, Taiyoken, Parálisis, etc.

`SkillData.applies_status` define qué estado aplica (`"blind"`, `"stagger"`, `"paralysis"`, etc.) pero no hay ningún sistema que:
- Registre el estado activo en Player o Enemy
- Aplique el efecto por duración (`status_duration`)
- Lo limpie al expirar

**Necesita:** `StatusEffectSystem.gd` o diccionario de efectos activos en HealthComponent/Player.

### 4.4 Negación de Regeneración ← **CAMPO EXISTE, LECTOR NO EXISTE**
**Impacto:** MEDIA — necesario para Puño Perforante, técnicas anti-regen

`regen_negation_tier` está en SkillData y documentado con tabla de 9 niveles. Pero `HealthComponent` no consulta este campo en ningún momento — la regeneración siempre aplica completa independientemente del ataque recibido.

**Necesita:** HealthComponent.apply_damage() reciba opcionalmente un `SkillData` y verifique `regen_negation_tier` contra el `regen_tier` del personaje/enemigo.

### 4.5 Puntos de Presión ← **CAMPOS EXISTEN, HANDLER NO EXISTE**
**Impacto:** MEDIA

`pressure_point_chance` y `pressure_point_duration` están en SkillData. No hay código que tire el dado, compruebe `resistencia_neurologica` del objetivo, ni aplique KO temporal.

### 4.6 Kaio-ken con Costo de Vitalidad ← **DOCUMENTADO, SIN IMPLEMENTAR**
**Impacto:** ALTA — es la mecánica distintiva del Kaio-ken

La documentación define costos de HP por segundo (×2→5%, ×3→10%, ×4→18%, ×10→40%). `TransformationSystem._process()` tiene lógica de drenaje pero solo maneja `ki_drain_per_second`. No hay `hp_drain_per_second` en TransformationDefinition ni en el _process loop.

**Necesita:** Campo `hp_drain_per_second` en TransformationDefinition + lectura en TransformationSystem._process().

### 4.7 Alineación / Mecánica Caótico Bueno ← **NO EXISTE**
**Impacto:** BAJA-MEDIA — distintivo de Goku

La mecánica de stacks de "Emoción del Combate", opción "Dejar vivir" a ≤20% HP, y penalización por huir no tienen ningún código. Son Goku-específicas pero arquitectónicamente encajan en el PassiveSystem.

---

## 5. Puntos de Inflexión del Proyecto

Los **puntos de inflexión** son momentos en los que una decisión de implementación cierra o abre un espacio de posibilidades. Se listan en orden de impacto.

---

### PI-1 ▸ Implementar PassiveSystem + SkillExecutor
**Tipo:** Fundacional
**Bloquea:** ~80% del contenido documentado en `docs/`
**Esfuerzo:** Alto (~3-5 días de diseño+código)

Sin un sistema que registre y aplique habilidades pasivas y ejecute habilidades activas, todo el diseño de Goku (y de cualquier otro personaje) permanece como documentación muerta. Este es el mayor punto de inflexión del proyecto.

La decisión clave aquí es el **modelo de ejecución de skills activos**:
- **Opción A (Comandos discretos):** Cada SkillType tiene un handler específico (StrikeHandler, KiBlastHandler, SupportHandler, UltimateHandler). Explícito, fácil de debuggear, difícil de extender.
- **Opción B (Effect pipeline):** SkillData define una lista de efectos (Damage, Heal, StatusApply, Knockback, etc.) y SkillExecutor los resuelve en orden. Flexible, permite combinar efectos sin código nuevo.
- **Recomendación:** Opción B, con tipos de efecto como diccionario o pequeñas Resources anidadas. Permite que las futuras habilidades de otros personajes se definan sin tocar el ejecutor.

---

### PI-2 ▸ Poblar TransformationDefinition .tres
**Tipo:** Contenido crítico
**Bloquea:** Combate con transformaciones, progresión de Goku
**Esfuerzo:** Medio (~1-2 días)

El código está listo. Hace falta crear los archivos `.tres` para: `transform_kaioken`, `transform_kaioken_x3`, `transform_kaioken_x4`, `transform_oozaru`, `transform_ssj1`. Sin ellos, TransformationSystem.try_activate() siempre retorna false aunque el jugador tenga los requisitos.

**Decisión clave:** ¿Kaio-ken tiene `hp_drain_per_second` o se implementa como costo de Ki con penalización post-uso? Definirlo ahora evita tener que refactorizar TransformationDefinition más adelante.

---

### PI-3 ▸ Modelo de StatusEffects
**Tipo:** Arquitectónico
**Bloquea:** Blind, Stagger, Paralysis, KO por Puntos de Presión, Freeze
**Esfuerzo:** Medio (~2 días)

La decisión es si los estados de control viven en:
- **Opción A:** Diccionario `{ "blind": {duration: 4.0, ...} }` en Player y Enemy, leído por la state machine
- **Opción B:** Nodos `StatusEffect` instanciados como hijos de Player/Enemy, con `_process()` propio

Opción A es más liviana y encaja mejor con la arquitectura actual (datos en diccionarios, no nodos extra). La state machine ya tiene estados de Hurt — agregar chequeos de status en cada estado es straightforward.

---

### PI-4 ▸ Primera oleada de SkillData .tres
**Tipo:** Contenido
**Desbloquea:** El catálogo de habilidades jugable, balance inicial
**Esfuerzo:** Bajo (rellenar datos desde la documentación)

Una vez que PI-1 exista, crear los `.tres` de las habilidades más fundamentales de Goku:
`kamehameha`, `kiai`, `dragonthrow`, `image_residual`, `ki_concentrado`, `supresion_ki`, `golpe_ki_concentrado`.

Este punto marca el paso de "el juego simula" a "el juego tiene contenido propio". Es también el primer test real del sistema de balance.

---

### PI-5 ▸ Catálogo de EnemyData
**Tipo:** Contenido
**Bloquea:** Variedad de combate, escalado por día
**Esfuerzo:** Medio

Actualmente el Enemy se construye con stats escalados por día y sin identidad propia. DifficultyScaler.gd existe pero no hay enemigos nommados. Crear una docena de EnemyData .tres (Bandido, Soldado Patrulla Roja, Demon Clansman, Saibaman, etc.) es el punto de inflexión que hace que el combate tenga contexto narrativo.

---

### PI-6 ▸ Zenkai Boost y Near-Death Events
**Tipo:** Mecánica de progresión
**Impacto:** Narrativo y de diseño
**Esfuerzo:** Bajo-Medio

El `near_death_event` flag se chequea en TransformationSystem para desbloquear SSJ1. La mecánica Zenkai (bonus permanente post-derrota para saiyans) está diseñada en `docs/goku_vs_raditz.md` pero no tiene código. Es un punto de inflexión narrativo: cuando implementarlo cambia cuándo el jugador puede acceder a SSJ1.

**Necesita:** En DayManager._resolve() o CheckpointSystem, cuando el resultado de combate es derrota y la raza es saiyan, aplicar un pequeño bonus a stats y setear flag. La dificultad no es el código sino definir el balance (¿cuánto bonus? ¿con cooldown? ¿acumulable?).

---

### PI-7 ▸ NPC System con Definiciones Reales
**Tipo:** Contenido + Feature
**Bloquea:** Relaciones, entrenamiento con maestros, Alineación en meta-juego
**Esfuerzo:** Medio-Alto

NpcSystem tiene el esqueleto completo. Sin NpcDefinition .tres, los encuentros son genéricos. El punto de inflexión es crear los primeros 5-6 NPCs con identidad real (Maestro Roshi, Korin, Yamcha, Piccolo, etc.) porque eso activa la mecánica de relaciones, los bonos de entrenamiento específicos, y las rutas de historia alternativas.

---

## 6. Deuda Técnica Conocida

| Deuda | Ubicación | Severidad |
|---|---|---|
| Kaio-ken no drena HP | TransformationSystem._process() | Alta |
| `regen_negation_tier` nunca se lee | HealthComponent | Media |
| `pressure_point_chance` sin handler | (inexistente) | Media |
| `applies_status` sin sistema receptor | (inexistente) | Media |
| `bypasses_ki_shield` y `bypasses_physical_resistance` sin lector | CombatFormulas / HealthComponent | Media |
| `pure_heart` flag referenciado pero sin setter canónico | FlagSystem (implícito) | Baja |
| `incompatible_con` en TransformationDefinition sin validador | TransformationSystem.try_activate() | Media |
| Enemy sin soporte para Regen / Inmortalidad tiers | Enemy.gd | Baja (futuro) |
| CombatArena sin soporte para efectos de transformación visual | CombatArena.gd | Baja |

---

## 7. Hoja de Ruta Recomendada

### Fase A — Fundación de Skills (Prioridad 1)
1. Diseñar e implementar `PassiveSystem.gd`
2. Diseñar e implementar `SkillExecutor.gd` (effect pipeline, Opción B del PI-1)
3. Implementar `StatusEffectSystem` como diccionario en Player/Enemy
4. Añadir `hp_drain_per_second` a TransformationDefinition + lector en TransformationSystem
5. Añadir verificación de `incompatible_con` en TransformationSystem.try_activate()
6. Añadir lectura de `regen_negation_tier` y `bypasses_*` en HealthComponent/CombatFormulas

### Fase B — Primer contenido jugable de Goku (Prioridad 2)
1. Crear `.tres` de TransformationDefinition: Kaio-ken ×1/×3/×4, Oozaru, SSJ1
2. Crear `.tres` de SkillData: las 10 habilidades fundamentales de Goku (DB Clásico)
3. Implementar flag `pure_heart` con setter en alineación / CharacterFactory
4. Implementar Zenkai Boost en DayManager._resolve() para saiyans

### Fase C — Variedad de combate y NPCs (Prioridad 3)
1. Crear 10-15 EnemyData `.tres` con identidades narrativas
2. Crear 6 NpcDefinition `.tres` (maestros principales)
3. Implementar mecánica "Dejar vivir" (Caótico Bueno) en CombatArena
4. Expandir checkpoints con consecuencias de habilidades (UnlockSkillConsequence si se necesita)

### Fase D — Contenido DBZ (Prioridad 4)
1. TransformationDefinition: SSJ1 Full Power, SSJ2, SSJ3
2. SkillData: habilidades DBZ (Genki-Dama, Shunkan Ido, Kienzan, etc.)
3. Mecánicas de fusión (Metamoru / Potara) — requieren diseño arquitectónico propio
4. Sistema de Inmortalidad tiers (requiere refactor de HealthComponent)

---

## 8. Señales EventBus — Cobertura

| Señal | Emitida en | Escuchada en | Estado |
|---|---|---|---|
| `run_started` | GameManager | DayScreen | ✅ |
| `day_started` | DayManager | DayScreen | ✅ |
| `day_actions_ready` | DayManager | DayScreen | ✅ |
| `day_action_resolved` | DayManager | DayScreen | ✅ |
| `day_ended` | DayManager | DayScreen/GameManager | ✅ |
| `game_completed` | DayManager | GameManager | ✅ |
| `combat_started` | CombatManager | CombatArena/HUD | ✅ |
| `combat_ended` | CombatArena | CombatManager | ✅ |
| `combat_result_ready` | CombatArena | DayManager (await) | ✅ |
| `damage_dealt` | Player/Enemy | HUD | ✅ |
| `combo_updated` | AttackState | HUD | ✅ |
| `player_died` | HealthComponent | CombatArena | ✅ |
| `player_health_changed` | HealthComponent | HUD | ✅ |
| `player_ki_changed` | KiComponent | HUD | ✅ |
| `player_stats_changed` | StatsComponent | HUD | ✅ |
| `xp_gained` | DayManager | DayScreen | ✅ |
| `level_up` | DayManager | DayScreen | ✅ |
| `checkpoint_reached` | CheckpointSystem | DayManager | ✅ |
| `build_identity_changed` | BuildAnalyzer | DayScreen | ✅ |
| `transformation_unlocked` | TransformationSystem | DayScreen | ✅ |
| `transformation_activated` | TransformationSystem | HUD/CombatArena | ✅ |
| `transformation_deactivated` | TransformationSystem | HUD/CombatArena | ✅ |
| `transformation_mastery_milestone` | TransformationSystem | DayScreen | ✅ |
| `minigame_record_broken` | MinigameRecordSystem | DayScreen | ✅ |
| `npc_relation_changed` | NpcSystem | DayScreen | ✅ |
| `action_unlocked` | ActionRegistry | DayScreen | ✅ |
| **`skill_activated`** | **—** | **—** | ❌ Falta (PI-1) |
| **`status_effect_applied`** | **—** | **—** | ❌ Falta (PI-3) |
| **`passive_triggered`** | **—** | **—** | ❌ Falta (PI-1) |

---

## 9. Resumen Ejecutivo

El proyecto tiene una **arquitectura backend sólida** — el loop de 100 días, las fases de DayManager, el bus de señales, el sistema de consecuencias, las fórmulas de combate y la máquina de estados del jugador son código funcional y bien estructurado. El enfoque data-driven (Resources .tres) está correctamente establecido.

La **brecha principal** es la que existe entre la capa de datos (SkillData, TransformationDefinition, NpcDefinition) y su ejecución en runtime: los esquemas están definidos pero los archivos de contenido no existen, y los sistemas que leerían esos datos en combate (PassiveSystem, SkillExecutor, StatusEffectSystem) tampoco existen.

Dicho de otro modo: el juego puede correr un run de 100 días con entrenamiento y combate básico, pero no puede usar ninguna de las habilidades documentadas en `docs/`, ni transformarse, ni aplicar estados de control.

El **punto de inflexión más rentable** es implementar PassiveSystem + SkillExecutor (PI-1), porque es el único que desbloquea todo lo demás en cascada. Una vez que existe el ejecutor, cada `.tres` de SkillData añadido es contenido jugable inmediato sin código adicional.
