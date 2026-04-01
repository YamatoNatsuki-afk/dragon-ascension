# Goku — Era Raditz / Inicio de Dragon Ball Z
**Tier de referencia:** 5-C Bajo (Nivel Lunar)
**Raza:** Saiyajin (sin cola — pérdida permanente desde el 23.° Torneo)
**Predecesor:** `docs/goku_23_torneo.md`
**Contexto:** Goku en el momento del enfrentamiento con Raditz, incluyendo técnicas adquiridas durante su entrenamiento post-muerte con Kaio-sama y en el planeta Yardrat (línea de tiempo completa de la era temprana de DBZ).

---

## 0. Changelog respecto al 23.° Torneo

| Cambio | 23.° Torneo | Era Raditz |
|---|---|---|
| Tier | 5-C Bajo | 5-C Bajo (mismo tier, comparable a Piccolo) |
| Potencia de ataque | Nivel Lunar | Nivel Lunar (comparable a Raditz) |
| Alcance | Decenas de metros con Ki | **Planetario con Ki** (Ki de Piccolo llega a la Luna) |
| Nueva habilidad | — | Aura |
| Nueva habilidad | — | Evolución Reactiva |
| Nueva habilidad | — | Manipulación de Explosiones |
| Nueva resistencia | — | Detección (puede ocultar su Ki) |
| Nuevas técnicas | — | Kaio-ken (hasta ×20), Genki-Dama, Kienzan, Telepatía, Shunkan Ido |
| Nuevas debilidades | Caótico Bueno, baja guardia | + Kaio-ken (daño corporal), Genki-Dama (carga larga), vacío espacial |
| Nota cola | Cola perdida permanentemente | Sin cambio — cola no vuelve (irreversible) |

> **Nota sobre el perfil:** Este documento cubre el arco de tiempo desde el combate con Raditz hasta las técnicas aprendidas en el planeta Yardrat (Shunkan Ido). Las técnicas marcadas con ★ solo están disponibles tras el evento de historia correspondiente.

---

## 1. Corrección de Alcance — Planetario con Ki

El 23.° Torneo ya tenía un Kamehameha de Nivel Lunar, pero el alcance documentado decía "Decenas de Metros." Esta era una inconsistencia: si el blast destruye la Luna, su alcance es necesariamente planetario. Se actualiza retroactivamente:

- **23.° Torneo y anteriores (Kamehameha Cargado):** alcance planetario en la versión de carga máxima.
- **Era Raditz:** alcance planetario confirmado explícitamente incluso en disparos base (comparable a Piccolo, cuyas ráfagas llegan a la Luna).

---

## 2. Stats Actualizados

| Stat | 23.° Torneo | Era Raditz | Notas |
|---|---|---|---|
| Fuerza | 135 | 140 | Sin cambio significativo base; Kaio-ken lo multiplica |
| Velocidad | 125 | 132 | Comparable a Piccolo post-23.° Torneo |
| Ki | 118 | 125 | Entrenamiento con Kaio-sama; base para Kaio-ken |
| Vitalidad | 115 | 118 | Gravitación 10× en el planeta de Kaio fortalece el cuerpo |
| Resistencia | 135 | 140 | Nivel Lunar confirmado |
| Poder Ki | 140 | 145 | Escala Raditz / Piccolo confirmada |
| Inteligencia | 42 | 44 | Capacidad de conducir, mayor experiencia vital |
| Intel Combate | 112 | 118 | Predicción por corrientes de aire; adaptación a gravedad extrema |

> **Los valores base de esta era son similares al 23.° Torneo.** El verdadero salto de poder de Goku en DBZ llega con el Kaio-ken y, posteriormente, el Super Saiyajin. Esta versión es el "punto cero" de DBZ.

---

## 3. Nuevas Habilidades

### 3.1 Aura

**Tipo:** Pasiva permanente (activación visual al liberar Ki)
**Descripción lore:** El Ki de Goku en DBZ es lo suficientemente denso para ser visible a simple vista como un aura de luz alrededor del cuerpo.

**Efectos en juego:**

| Efecto | Descripción |
|---|---|
| Visual | El aura es visible para todos en escena — no puede ocultarse sin Supresión de Ki activa |
| Intimidación pasiva | Enemigos con Intel Combate ≤ 80 reciben −10% a sus stats de ataque al ver el aura desplegada |
| Detección de distancia | El aura actúa como baliza de Ki — Goku puede ser detectado por cualquier sensor de Ki a distancia planetaria mientras el aura está visible |
| Amplificación de Ki | Cuando el aura está activa (liberando Ki libremente), el costo de todas las habilidades de Ki se reduce un 5% adicional |
| Activación | Goku puede suprimir el aura voluntariamente (Supresión de Ki) o liberarla a voluntad |

---

### 3.2 Evolución Reactiva

**Tipo:** Pasiva permanente (Fisiología Saiyajin — nivel superior)
**Descripción lore:** Goku se adaptó a la gravedad 10× del planeta de Kaio. Los Saiyajin pueden superar debilidades completamente — incluida la debilidad de la cola, que puede ser entrenada hasta no afectar al Saiyajin.

**Efectos en juego:**

```gdscript
EvolucionReactiva {
  descripcion = "Goku puede adaptarse a condiciones extremas y superar limitaciones físicas con suficiente exposición.",

  # Adaptación a gravedad:
  gravedad_multiplicador_maximo = 10.0,   # entrenó bajo 10G; puede combatir en condiciones hasta 10G sin penalización
  bonus_por_entrenamiento_gravedad = {
    "stats de Fuerza y Vitalidad tras semana de entrenamiento bajo xG" : "+2% por G de diferencia con la base"
  },

  # Superación de debilidades (cola — histórico):
  # La cola está perdida permanentemente, por lo que esta parte
  # es solo lore; en partidas donde la cola existiera podría entrenarla
  # hasta que agarrarla no la debilite (requeriría evento específico).

  # Adaptación reactiva en combate:
  adaptacion_progresiva = {
    "Si recibe el mismo tipo de daño 3 veces seguidas" : "resistencia a ese tipo +10% para el resto del combate",
    "Máximo de adaptaciones activas simultáneas"       : 3
  }
}
```

---

### 3.3 Manipulación de Explosiones

**Tipo:** Pasiva + modificador de técnicas existentes
**Descripción lore:** Goku puede hacer detonar sus ráfagas de Ki de forma controlada — en el punto de impacto, en vuelo, o en el momento exacto que elija.

**Pasiva:** Todas las habilidades de tipo `KI_BLAST` tienen acceso al modificador de explosión.

```gdscript
ModificadorExplosion {
  descripcion = "Goku puede elegir cuándo y dónde explotan sus ráfagas de Ki.",
  variantes = {
    "Explosión en impacto"   : { radio_adicional = 1.5, daño_splash = daño_base * 0.4 },
    "Explosión en vuelo"     : { detona_en_punto_elegido = true, util_vs_esquiva = true },
    "Explosión retardada"    : { delay = 1.5, daño = daño_base * 1.3 }  # acumula más energía
  },
  costo_adicional_ki = 8.0,   # activa el modificador de explosión en cualquier KI_BLAST
  # La variante "vuelo" convierte KI_BLASTs en guiados hasta el punto de detonación
}
```

**Activa: Kienzan (Disco Destructor)** — primer uso de manipulación de explosiones + corte:

```gdscript
SkillData {
  id                     = &"kienzan"
  display_name           = "Kienzan"
  skill_type             = SkillType.KI_BLAST
  description            = "Goku lanza un disco de Ki afilado como navaja. Puede atravesar oponentes varias veces más fuertes y resistentes que el disco mismo."
  ki_cost                = 22.0
  damage_multiplier      = 3.5
  cooldown               = 10.0
  hit_count              = 1
  is_ranged              = true
  effect_tags            = [&"ki_blast", &"cutting", &"piercing"]
  bypasses_physical_resistance = true   # corta independientemente de la resistencia del objetivo
  bypasses_ki_shield     = false        # un escudo de Ki sólido puede detener el disco
  regen_negation_tier    = 4            # Media-Baja; el corte interfiere con regeneración parcial
  required_stats         = { &"ki": 118.0, &"poder_ki": 138.0 }
  # Lore: copiado de Krillin. El disco puede ser guiado en vuelo (con costo adicional de ki = 5.0).
  # NO puede cortar a seres con resistencia especial a corte (Inmortalidad tipos que regeneran el corte).
}
```

---

### 3.4 Resistencia a Detección — Ocultación de Ki

**Base lore:** Los usuarios de Ki experimentados pueden ocultar su nivel de poder para no ser detectados.

**Efectos en juego:**

| Nivel de Ki de Goku | Capacidad de ocultación |
|---|---|
| Ki ≥ 118 (esta era) | Puede reducir el Ki aparente al 5% del real (mejora de la Supresión de Avanzado que lo dejaba al 15%) |
| Supresión activa | Bloquea PES básica y Detección de Ki de rivales con Ki ≤ 100 |
| Supresión vs rival con Ki ≥ 110 | Solo reduce el Ki visible; un sensor suficientemente potente lo detecta igualmente |
| Condición de ruptura | Usar cualquier habilidad con costo ≥ 25 de Ki rompe la supresión |

> La Supresión de Ki ya existía como habilidad activa desde el 22.° Torneo. Esta resistencia formaliza que Goku también puede resistir ser detectado — no solo suprimir, sino hacerlo con mayor eficacia.

---

## 4. Técnicas Nuevas

### 4.1 ★ Kaio-ken (hasta ×4 en Saga Saiyajin; hasta ×20 en Saga Freezer)

```gdscript
SkillData {
  id               = &"kaio_ken"
  display_name     = "Kaio-ken"
  skill_type       = SkillType.SUPPORT
  description      = "Técnica de Kaio-sama. Multiplica momentáneamente todo el Ki, Fuerza y Velocidad de Goku. Tensiona el cuerpo severamente si se usa en exceso."
  ki_cost          = 0.0          # no consume Ki: consume Vitalidad como recurso alternativo
  effect_value     = 0.0
  cooldown         = 0.0          # sin cooldown; el coste es el daño al cuerpo
  required_stats   = { &"ki": 120.0 }

  # Sistema de niveles (implementado como variantes del mismo skill):
  # Kaio-ken ×2  : Fuerza ×2, Velocidad ×2, Ki ×2 — coste: 5% Vitalidad /s
  # Kaio-ken ×3  : Fuerza ×3, Velocidad ×3, Ki ×3 — coste: 10% Vitalidad /s
  # Kaio-ken ×4  : Fuerza ×4, Velocidad ×4, Ki ×4 — coste: 18% Vitalidad /s
  # Kaio-ken ×10 : Fuerza ×10, etc.             — coste: 40% Vitalidad /s (saga Freezer)
  # Kaio-ken ×20 : máximo alcanzado              — coste: 80% Vitalidad /s (solo vs Freezer 100%)

  # Penalización al desactivar:
  # Dolor intenso post-uso: −30% a todos los stats durante (duración_uso × 0.5) segundos
  # Si Vitalidad cae a 0 por Kaio-ken: KO inmediato (Goku "se desgarra por dentro")

  # Incompatibilidad: NO puede combinarse con Super Saiyajin
  # (las emociones de la transformación hacen el control del Ki imposible — ver docs SSJ)

  effect_tags      = [&"kaio_ken", &"multiplier", &"self_damage"]
}
```

**Tabla de niveles:**

| Nivel | Multiplicador | Coste Vitalidad /s | Disponible desde |
|---|---|---|---|
| ×2 | ×2 todo | 5% | Entrenamiento con Kaio ★ |
| ×3 | ×3 todo | 10% | Igual |
| ×4 | ×4 todo | 18% | Igual (máx. inicial) |
| ×10 | ×10 todo | 40% | Saga Freezer ★★ |
| ×20 | ×20 todo | 80% | Solo vs Freezer 100% ★★ |

---

### 4.2 ★ Genki-Dama (Bomba de Espíritu)

```gdscript
SkillData {
  id               = &"genki_dama"
  display_name     = "Genki-Dama"
  skill_type       = SkillType.ULTIMATE
  description      = "El ataque definitivo de Goku. Recolecta energía de todas las formas de vida del entorno para crear una esfera de Ki masiva. Requiere corazón puro."
  ki_cost          = 0.0           # no usa el Ki de Goku — usa el Ki del entorno
  damage_multiplier = 12.0         # potencia escala con el entorno y el tiempo de carga
  cooldown         = 120.0         # solo una vez por combate en la práctica
  hit_count        = 1
  is_ranged        = false         # se lanza desde arriba (no es proyectil lateral)
  effect_tags      = [&"genki_dama", &"spirit_bomb", &"pure_ki", &"aoe"]
  regen_negation_tier = 7          # Alta; la energía de la vida pura interfiere con regeneración alta
  required_stats   = { &"ki": 118.0 }

  # Requisito especial: pure_heart = true
  # Sin corazón puro, la técnica no puede ejecutarse.

  # Sistema de carga:
  # Carga mínima (30 s):  daño = poder_ki × 8.0   — Nivel Lunar básico
  # Carga media  (60 s):  daño = poder_ki × 12.0  — Nivel Lunar potente
  # Carga máxima (120 s): daño = poder_ki × 18.0  — trasciende el tier (solo vs jefes de saga)

  # Aceleración: aliados que aporten Ki conscientemente reducen el tiempo en 40%
  # Durante la carga: Goku no puede moverse ni atacar → VULNERABLE TOTAL

  # Reflejo: El objetivo puede devolver la Genki-Dama si su Ki es oscuro/malicioso
  # y más poderoso que la esfera. Goku puede ATRAPAR su propia Genki-Dama si puro.

  bypasses_ki_shield         = true   # la energía de la vida pura penetra barreras de Ki oscuro
  bypasses_physical_resistance = false
}
```

---

### 4.3 ★ Telepatía (Comunicación Mental)

```gdscript
SkillData {
  id               = &"telepatia_kaio"
  display_name     = "Telepatía"
  skill_type       = SkillType.SUPPORT
  description      = "Comunicación telepática aprendida de Kaio-sama. Permite hablar mentalmente con aliados y leer superficialmente la mente de otros poniendo la mano en su frente."
  ki_cost          = 5.0
  cooldown         = 0.0
  hit_count        = 1
  effect_tags      = [&"mental", &"telepathy"]
  required_stats   = { &"intel_combate": 110.0, &"ki": 115.0 }

  # Uso en combate:
  # Colocar la mano en la frente del objetivo → revela su próximo movimiento con certeza (100%)
  # Requiere toque físico — no funciona a distancia en combate
  # En el meta-juego de día: comunicación sin hablar, coordinación con aliados

  # Uso a distancia (solo fuera de combate):
  # Goku puede transmitir pensamientos a usuarios de Ki que conozca → distancia ilimitada
}
```

---

### 4.4 ★★ Shunkan Ido (Teletransportación Instantánea)

*(Aprendido en el planeta Yardrat — disponible solo tras el evento de historia "Regreso de Yardrat")*

```gdscript
SkillData {
  id               = &"shunkan_ido"
  display_name     = "Shunkan Ido"
  skill_type       = SkillType.SUPPORT
  description      = "Teletransportación instantánea fijando la señal de Ki de un objetivo. Requiere concentración (dedos en la frente) y una señal de Ki activa como destino."
  ki_cost          = 15.0
  cooldown         = 3.0           # puede usarse repetidamente si hay señales disponibles
  hit_count        = 1
  effect_tags      = [&"teleportation", &"instant_movement"]
  required_stats   = { &"ki": 120.0, &"intel_combate": 112.0 }

  # Mecánica:
  # Goku pone los dedos índice y medio en la frente → 0.5 s de concentración
  # Selecciona una señal de Ki detectada → teletransporte instantáneo
  # Puede teletransportar a otros si están en contacto físico

  # Limitaciones:
  # Necesita una señal de Ki como destino — no puede ir a lugares vacíos
  # La señal debe ser de un ser que Goku haya "fijado" (conoce su Ki)
  # Inutilizable si Supresión de Ki del objetivo bloquea la señal completamente
  # Tiempo de concentración (0.5 s) es una ventana de vulnerabilidad

  # Variante sin dedos: puede teletransportarse sin el gesto si el objetivo es muy familiar
  # (aliados cercanos, señales de Ki muy conocidas) — cooldown adicional = 1.0 s

  # Interacción con Kaio-ken: puede activar Kaio-ken DESPUÉS del Shunkan Ido para
  # llegar al objetivo y golpear antes de que reaccione
}
```

---

## 5. Debilidades Nuevas

### 5.1 Kaio-ken — Coste Corporal

```gdscript
DebilidadKaioKen {
  descripcion = "El Kaio-ken tensiona el cuerpo de Goku. Uso excesivo causa dolor intenso y agotamiento.",
  penalizacion_post_uso = {
    duracion        = duracion_kaio_ken_usada * 0.5,  # en segundos
    reduccion_stats = 0.30,                           # −30% a todos los stats
    movilidad       = "reducida_al_70_pct"
  },
  ko_si_vitalidad_cero = true,     # si el Kaio-ken consume toda la Vitalidad → KO inmediato
  incompatible_con     = ["super_saiyajin", "transformacion_emocional"]
}
```

### 5.2 Genki-Dama — Carga Larga

Durante la carga de la Genki-Dama:
- Goku es completamente inmóvil.
- Su Vitalidad efectiva se reduce al 50% (está distraído absorbiendo energía del entorno).
- Cualquier interrupción con daño ≥ 20% HP cancela la carga y desperdicia el Ki acumulado.
- Solución lore: necesita protección de aliados o que el rival esté incapacitado.

### 5.3 Vacío Espacial

```gdscript
DebilidadEspacial {
  descripcion = "Goku no puede sobrevivir en el vacío del espacio sin ayuda externa.",
  efecto      = "En entornos espaciales sin atmósfera, pierde Vitalidad al 5% /s",
  mitigacion  = [
    "Burbuja de Ki (no documentada aún — requiere Ki Maestro)",
    "Escafandra o protección externa"
  ],
  nota = "Freezer sobrevive en el vacío espacial. Esto es una desventaja táctica real en combates espaciales."
}
```

---

## 6. Evolución Reactiva — Detalles de Implementación

La Evolución Reactiva tiene dos expresiones principales en esta era:

### 6.1 Adaptación a la Gravedad de Kaio

| Condición | Efecto tras adaptación |
|---|---|
| Entrenamiento en 10G (evento de historia) | +8% permanente a Fuerza y Vitalidad base |
| Combate en condiciones de alta gravedad | Sin penalización hasta 10G |
| Por encima de 10G | Penalización normal reanuda (Goku aún no puede adaptarse a 100G+ hasta las sagas de Namek/Cell) |

### 6.2 Adaptación en Combate (Pasiva Refinada)

Mejora sobre la versión base de Desarrollo Acelerado:

```gdscript
EvolucionReactiva_Combate {
  # Versión mejorada del Desarrollo Acelerado Tipo 1:
  umbral_1  = { hp_pct = 0.75, bonus_stats = 0.08 },    # era 0.05
  umbral_2  = { hp_pct = 0.50, bonus_stats = 0.18 },    # era 0.12
  umbral_3  = { hp_pct = 0.25, bonus_stats = 0.28 },    # era 0.20
  # Nueva capa — adaptación al tipo de daño recibido:
  adaptacion_tipo_daño = {
    "Mismo tipo de daño recibido 3 veces seguidas" : "resistencia +12%",
    "Máximo de adaptaciones activas"               : 3
  }
}
```

---

## 7. Adquisición de Técnicas (Árbol de Historia)

| Técnica | Disponibilidad | Evento requerido |
|---|---|---|
| Kaio-ken ×2/×3/×4 | ★ (Saga Saiyajin) | "Entrenamiento en el Más Allá con Kaio-sama" |
| Genki-Dama | ★ (Saga Saiyajin) | Igual — requiere además `pure_heart = true` |
| Kienzan | Disponible desde esta era | Ki ≥ 118 + Intel Combate ≥ 108 (copiado de Krillin) |
| Telepatía | ★ (post-Raditz) | "Entrenamiento con Kaio-sama" |
| Shunkan Ido | ★★ (post-Freezer) | "Regreso del planeta Yardrat" — bloqueado hasta entonces |
| Kaio-ken ×10/×20 | ★★ (Saga Freezer) | "Dominio del Kaio-ken — Saga Freezer" |

---

## 8. Sinergias Nuevas

| Habilidad A | Habilidad B | Sinergia |
|---|---|---|
| Kaio-ken ×4 | Kamehameha Experto | Combo clásico: ×4 multiplica Poder Ki × 4 → Kamehameha de daño × 4 base → el más potente disponible en Saga Saiyajin |
| Kaio-ken | Gran Fuerza de Voluntad | Si el Kaio-ken reduce HP ≤ 15%, Gran Fuerza de Voluntad evita el KO y añade el +30% de desbordamiento encima del multiplicador |
| Shunkan Ido | Kaio-ken | Teletransportar al punto ciego del rival → activar Kaio-ken ×4 → golpear antes de que reaccione |
| Shunkan Ido | Toque de Presión | Aparecer al lado del rival → punto de presión instantáneo (sin ventana de defensa) |
| Genki-Dama | Taiyoken Avanzado | Cegar al rival → cargar Genki-Dama sin ser interrumpido (rival no ve a Goku durante los primeros 4 s de carga) |
| Kienzan | Manipulación de Explosiones | El disco de Ki puede detonar al impactar → corte + explosión simultáneos |
| Evolución Reactiva | Desarrollo Acelerado | Las adaptaciones al tipo de daño se acumulan mientras los stacks de Desarrollo Acelerado suben → a HP bajo, Goku está al pico de poder Y resistiendo mejor el tipo de daño del rival |
| Telepatía (mano) | Análisis Predictivo | Telepatía revela el próximo movimiento con 100% de certeza → Análisis Predictivo usa ese dato para garantizar el esquive automático |

---

## 9. Interacción Kaio-ken × Super Saiyajin — Nota de Diseño

El perfil confirma que Kaio-ken y Super Saiyajin son **incompatibles** en esta era. La razón:

> *"Las intensas emociones causadas por la transformación del Super Saiyajin hacen que sea difícil controlar adecuadamente el Ki de uno, lo que hace que la combinación sea increíblemente arriesgada en el mejor de los casos y letal en el peor."*

**En el sistema de juego:**
- Intentar activar Kaio-ken mientras Super Saiyajin está activo → evento de error: *"El Ki está demasiado inestable."*
- Intentar activar Super Saiyajin mientras Kaio-ken está activo → forzar desactivación del Kaio-ken primero.
- **Excepción futura (Super Saiyajin Blue):** documentar en la saga correspondiente cuando el Ki esté completamente controlado en estado SSJ.

---

## 10. Notas de Diseño

- **Kaio-ken** es el primer sistema de multiplicador del juego. La implementación debe mostrar claramente el coste en Vitalidad por segundo — barra secundaria o indicador de "combustión" — para que el jugador gestione conscientemente cuánto tiempo lo mantiene activo.
- **Genki-Dama** es el único ULTIMATE que no usa el Ki de Goku sino el del entorno. Esto significa que puede usarse incluso con Ki bajo, pero necesita protección durante la carga. Es el ataque de mayor daño absoluto del juego en este tier — pero de uso situacional.
- **Shunkan Ido** cambia el meta-juego de movilidad por completo. Una vez disponible, Goku puede escapar de cualquier situación, teletransportar aliados, y crear aperturas imposibles de otro modo. Su limitación (necesita señal de Ki) es la contraparte correcta.
- **Evolución Reactiva** debería ser visible para el jugador como "adaptación en combate": un contador de adaptaciones activas (máx. 3) en la HUD, mostrando qué tipos de daño está resistiendo mejor Goku en tiempo real.
- **Nota sobre la cola:** El perfil lista "Regeneración Baja-Alta (cola)" como habilidad del personaje. Esto es un listado acumulativo lore del wiki de origen que incluye todas las habilidades históricas. **En el juego, la cola está perdida permanentemente desde el 23.° Torneo.** La Regeneración de Cola no aplica en partidas que empiecen desde cualquier saga post-23.° Torneo.
