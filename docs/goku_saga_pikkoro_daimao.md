# Goku — Saga del Rey Piccolo (Dragon Ball Clásico)
**Tier de referencia:** 7-C Alto base · 7-B Bajo como Oozaru · hasta 7-A con Kamehameha Cargado
**Raza:** Saiyajin (cola presente)
**Predecesor:** `docs/goku_22_torneo.md`
**Contexto:** Goku lucha herido de muerte, con la mayoría de sus extremidades inutilizadas, y aun así mata al Rey Piccolo atravesándolo.

---

## 0. Changelog respecto al 22.° Torneo

| Cambio | 22.° Torneo | Saga Piccolo Daimao |
|---|---|---|
| Tier base | 8-B | **7-C Alto** (salto de tier completo) |
| Tier Oozaru | 8-A | **7-B Bajo** (1.15 Megatones) |
| Tier máximo Kamehameha | 7-A | 7-A (mismo techo, base mucho más alta) |
| Potencia de ataque | City Block | **Pueblo Grande** (mató al Rey Piccolo) |
| Potencia Oozaru | Multi-City Block | **Ciudad Pequeña** (1.15 Mt) |
| Velocidad | Hipersónico+ | Al menos Hipersónico+ (superior a antes) |
| Fuerza física | Clase K | Clase K (confirmada, mayor margen interno) |
| Resistencia | City Block | Pueblo Grande |
| Resistencia Oozaru | Multi-City Block | Ciudad Pequeña |
| Nueva habilidad | Detectar Ki (activa) | **Detección de Ki** (pasiva permanente) |
| Nueva habilidad | — | **Puntos de Presión** |
| Nueva habilidad | — | **Vuelo** (natural, sin Nube Voladora) |
| Nueva habilidad | — | **Manipulación de Vibraciones** |
| Nueva habilidad | — | **Manipulación de la Luz** (Taiyoken reclasificado) |
| Nueva habilidad | — | **Negación de Regeneración Media-Alta** |

> **Nota crítica:** Este es el primer tier en que Goku demuestra feats que van más allá del daño puro: matar a un Namekiano (que regenera mientras la cabeza esté intacta) atravesándolo es Negación de Regeneración, no solo daño alto.

---

## 1. Stats Actualizados

| Stat | 22.° Torneo | Piccolo Daimao | Notas |
|---|---|---|---|
| Fuerza | 74 | 95 | Clase K con mayor margen; capaz de perforar a un Namekiano |
| Velocidad | 76 | 94 | Al menos Hipersónico+ superior; pelea con extremidades dañadas |
| Ki | 70 | 88 | Ki Avanzado consolidado; detección pasiva sin costo |
| Vitalidad | 70 | 85 | Combate herido de muerte con mayoría de extremidades inutilizadas |
| Resistencia | 67 | 82 | Pueblo Grande; aguanta ataque de Piccolo gravemente herido |
| Poder Ki | 62 | 80 | Kamehameha de Montaña en 6 s; Nivel Pueblo Grande en disparo base |
| Inteligencia | 40 | 40 | Sin cambio (sigue siendo Genio Extraordinario en combate) |
| Intel Combate | 78 | 92 | Pelea con cálculo perfecto incluso mutilado |

> El stat más importante del salto es **Intel Combate**: Goku derrota al Rey Piccolo no por superarlo en poder bruto, sino encontrando el ángulo exacto de penetración con un solo brazo funcional.

---

## 2. Detección de Ki — Pasiva Permanente

### 2.1 Reclasificación desde el 22.° Torneo

En el 22.° Torneo la Detección de Ki era una habilidad activa con costo y cooldown. En esta saga queda absorbida como **sentido pasivo siempre activo**.

**Efectos pasivos (sin costo, sin cooldown):**

| Información detectada | Condición |
|---|---|
| Presencia de enemigos fuera de pantalla | Automático |
| Nivel de Ki relativo (mayor / similar / menor que Goku) | Automático |
| Si el enemigo está suprimiendo su Ki | Ki ≥ 80 vs supresión del rival |
| Stats revelados (poder_ki, vitalidad_actual, ki_actual) | Intel Combate ≥ 85 |
| Contenciones (poder oculto disponible) | Intel Combate ≥ 90 |
| Intenciones hostiles (detección de emboscada) | Siempre |

**La habilidad activa "Detectar Ki" del 22.° Torneo** se convierte en **"Análisis Profundo"**: mismo efecto que antes pero con cooldown reducido a 12 s (antes 20 s) y duración extendida a 25 s (antes 15 s), porque ahora la detección base ya no requiere acción.

---

## 3. Puntos de Presión

### 3.1 Pasiva: Conocimiento de Anatomía de Combate
**Requisito:** Intel Combate ≥ 88
**Descripción:** Goku conoce los nodos nerviosos y puntos vitales del cuerpo humano y de razas similares. Un golpe preciso en el lugar correcto puede incapacitar a un oponente independientemente de su nivel de resistencia bruta.

**Efecto pasivo:** Cada ataque de tipo STRIKE tiene un 5% de probabilidad de golpear un punto de presión menor (Stagger 0.8 s). La probabilidad sube al 15% si el diferencial de Intel Combate a favor de Goku es ≥ 10.

---

### 3.2 Activa: Toque de Presión

```gdscript
SkillData {
  id                     = &"toque_de_presion"
  display_name           = "Toque de Presión"
  skill_type             = SkillType.STRIKE
  description            = "Goku apunta a un punto neurológico exacto. Un empujón puede dejar al objetivo inconsciente."
  ki_cost                = 15.0
  damage_multiplier      = 0.4           # daño físico bajo — no es un ataque de fuerza
  cooldown               = 10.0
  hit_count              = 1
  is_ranged              = false
  pressure_point_chance  = 0.75          # 75% de KO/incapacitación
  pressure_point_duration = 8.0          # 8 s inconsciente; 0 = KO completo si pasa el check
  applies_status         = "paralysis"
  status_duration        = 8.0
  effect_tags            = [&"pressure_point", &"neurological"]
  bypasses_ki_shield     = true          # el escudo de ki no protege los nervios físicos
  required_stats         = { &"intel_combate": 88.0 }
  # Contrarrestado por: resistencia neurológica del objetivo, Inmortalidad Tipo 1-2,
  # cuerpos no biológicos, PES activa (detectan el intento).
}
```

---

### 3.3 Activa: Golpe al Nervio Vital

```gdscript
SkillData {
  id                     = &"golpe_nervio_vital"
  display_name           = "Golpe al Nervio Vital"
  skill_type             = SkillType.ULTIMATE
  description            = "Goku concentra Ki y precisión anatómica en un punto que colapsa el sistema nervioso central del objetivo."
  ki_cost                = 40.0
  damage_multiplier      = 0.6
  cooldown               = 25.0
  hit_count              = 1
  pressure_point_chance  = 1.0           # garantizado contra objetivos sin resistencia especial
  pressure_point_duration = 0.0          # KO completo (termina el combate)
  applies_status         = "paralysis"
  status_duration        = 0.0
  effect_tags            = [&"pressure_point", &"neurological"]
  bypasses_ki_shield     = true
  regen_negation_tier    = 2             # Regeneración Baja no restaura el sistema nervioso colapsado
  required_stats         = { &"intel_combate": 92.0, &"ki": 80.0 }
  # Inmunidades del objetivo: Inmortalidad tipos 3+, razas no biológicas,
  # Gran Fuerza de Voluntad (reduce duración a 3 s en vez de KO).
}
```

---

## 4. Vuelo — Natural (sin Nube Voladora)

### 4.1 Cambio respecto a versiones anteriores

Hasta el 22.° Torneo, Goku volaba exclusivamente mediante la **Nube Voladora** (ítem externo). En esta saga demuestra control de Ki suficiente para sustentarse en el aire por sí mismo.

**Efectos del cambio:**
- La `FlyState.gd` ya existe en el proyecto. Ahora Goku puede entrar a ella **sin costo adicional de Ki** (antes requería el ítem "Nube Voladora").
- La Nube Voladora sigue siendo útil: ofrece +30% de velocidad de vuelo (Goku puede volar más rápido montado en ella que bajo su propio control).
- En el meta-juego de día: el vuelo natural no consume PA de transporte (igual que la Nube, pero sin requisito de `pure_heart`).

**Pasiva: Vuelo Libre**
```gdscript
# Activación: Ki ≥ 80 (umbral de esta saga)
# La FlyState se puede activar directamente sin consumir ningún ítem.
# Velocidad de vuelo base = velocidad_stat * 0.9  (ligeramente más lenta que la Nube)
# Manos libres = true (puede atacar y lanzar Ki en vuelo, igual que antes)
```

### 4.2 Activa: Propulsión de Ki (vuelo ofensivo)

```gdscript
SkillData {
  id               = &"propulsion_ki"
  display_name     = "Propulsión de Ki"
  skill_type       = SkillType.STRIKE
  description      = "Goku se propulsa en el aire con un blast de Ki desde los pies y embiste al objetivo. Versión ofensiva del vuelo."
  ki_cost          = 20.0
  damage_multiplier = 1.8               # daño de impacto al colisionar
  cooldown         = 8.0
  hit_count        = 1
  is_ranged        = false
  effect_tags      = [&"aerial", &"rush"]
  required_stats   = { &"ki": 80.0, &"velocidad": 88.0 }
  # Equivale mecánicamente a "Kamehameha como impulso" (Saga Pilaf) pero
  # sin gastar el cooldown del Kamehameha. Herramienta de movilidad y daño.
}
```

---

## 5. Manipulación de las Vibraciones

### 5.1 Origen lore
El entrenamiento bajo Kami desarrolló en Goku la capacidad de transmitir vibraciones a través de sus golpes y del suelo. Esto se manifiesta como daño que ignora la resistencia física superficial al actuar desde el interior.

### 5.2 Pasiva: Golpe Resonante
**Requisito:** Intel Combate ≥ 88
**Efecto:** El 20% de los ataques STRIKE de Goku transmiten vibraciones internas.

```gdscript
# El 20% de todos los STRIKE aplica:
Vibración_Interna {
  daño_bonus           = fuerza * 0.3,
  tipo                 = "vibration",
  bypasses_ki_shield   = true,     # las vibraciones pasan a través del escudo de ki
  bypasses_physical_resistance = true  # actúan desde el interior del cuerpo
}
```

---

### 5.3 Activa: Onda de Choque

```gdscript
SkillData {
  id                         = &"onda_de_choque"
  display_name               = "Onda de Choque"
  skill_type                 = SkillType.STRIKE
  description                = "Goku golpea el suelo o al objetivo transmitiendo una onda vibratoria que daña desde el interior."
  ki_cost                    = 18.0
  damage_multiplier          = 1.4
  cooldown                   = 11.0
  hit_count                  = 1
  effect_tags                = [&"vibration", &"ground_aoe"]
  bypasses_ki_shield         = true
  bypasses_physical_resistance = true
  applies_status             = "stagger"
  status_duration            = 1.2
  required_stats             = { &"fuerza": 90.0, &"intel_combate": 85.0 }
}
```

---

### 5.4 Activa: Resonancia Interna

```gdscript
SkillData {
  id                         = &"resonancia_interna"
  display_name               = "Resonancia Interna"
  skill_type                 = SkillType.ULTIMATE
  description                = "Goku toca al objetivo y transmite una vibración que resuena con su estructura interna, causando daño continuo desde dentro."
  ki_cost                    = 45.0
  damage_multiplier          = 2.0
  cooldown                   = 22.0
  hit_count                  = 1
  effect_tags                = [&"vibration", &"internal", &"dot"]
  bypasses_ki_shield         = true
  bypasses_physical_resistance = true
  applies_status             = "stagger"
  status_duration            = 0.5
  effect_value               = 12.0    # daño por segundo del DoT de vibración durante 5 s
  regen_negation_tier        = 3       # Regeneración Baja-Alta no repara tejido que sigue vibrando
  required_stats             = { &"fuerza": 92.0, &"ki": 82.0, &"intel_combate": 90.0 }
}
```

---

## 6. Manipulación de la Luz — Taiyoken Reclasificado

### 6.1 Por qué cambia de categoría

En versiones anteriores el Taiyoken era una habilidad de soporte que producía un destello. En esta saga se reconoce explícitamente que Goku **manipula luz** al ejecutarlo — no solo genera brillo, sino que controla la dirección, intensidad y zona de efecto del destello.

### 6.2 Pasiva: Control de Luz Básico
**Requisito:** Ki ≥ 80
**Efecto:** El Taiyoken puede modularse:
- Rango de alcance ajustable (zona pequeña vs pantalla completa).
- Intensidad reducida (cegadora solo para el objetivo, sin afectar aliados).
- Duración extendida: 3 s → 4 s a Ki ≥ 85.

### 6.3 Taiyoken Actualizado

```gdscript
SkillData {
  id               = &"taiyoken_avanzado"
  display_name     = "Taiyoken (Avanzado)"
  skill_type       = SkillType.SUPPORT
  description      = "Goku genera y dirige un destello de luz cegador. Versión avanzada: puede ajustar zona e intensidad."
  ki_cost          = 14.0             # era 12 en versiones anteriores
  damage_multiplier = 0.0
  cooldown         = 9.0
  hit_count        = 1
  is_ranged        = false
  effect_tags      = [&"light", &"blind"]
  applies_status   = "blind"
  status_duration  = 4.0              # era 3.0
  effect_value     = 0.75             # reducción de precisión enemiga mientras dure el cegamiento
  required_stats   = { &"intel_combate": 85.0 }
  # Modulación de zona: radio ajustable 1.0 m (objetivo único) → pantalla completa.
  # Aliados con Intel Combate ≥ 40 anticipan el destello y no son afectados.
}
```

### 6.4 Activa: Destello Dirigido

```gdscript
SkillData {
  id               = &"destello_dirigido"
  display_name     = "Destello Dirigido"
  skill_type       = SkillType.KI_BLAST
  description      = "Goku concentra la luz en un haz dirigido que no solo ciega sino que causa daño por energía lumínica concentrada."
  ki_cost          = 28.0
  damage_multiplier = 1.2
  cooldown         = 15.0
  hit_count        = 1
  is_ranged        = true
  effect_tags      = [&"light", &"blind", &"ki_blast"]
  applies_status   = "blind"
  status_duration  = 3.0
  required_stats   = { &"ki": 82.0, &"poder_ki": 76.0, &"intel_combate": 88.0 }
  # Diferencia del Taiyoken normal: hace daño además de cegar.
  # Rango medio (no pantalla completa). Apunta a un objetivo específico.
}
```

---

## 7. Negación de Regeneración — Hasta Media-Alta

### 7.1 Contexto lore
Los Namekianos se regeneran siempre que su cabeza esté intacta. El Rey Piccolo murió porque Goku lo atravesó de lado a lado — el daño interno fue tan severo que ni la regeneración cabeza-intacta pudo compensarlo. Esto define la capacidad de **Negación de Regeneración Media-Alta** (tier 6 en el sistema de SkillData).

### 7.2 Pasiva: Daño Perforante
**Requisito:** Fuerza ≥ 90, Intel Combate ≥ 90
**Efecto:** Los ataques de tipo STRIKE con suficiente fuerza aplican daño interno que interfiere con la regeneración del objetivo.

```gdscript
# Activación automática cuando fuerza ≥ 90 y el ataque supera el 30% del HP máximo del objetivo:
Daño_Perforante {
  regen_negation_tier        = 6,    # niega Regeneración hasta Media-Alta
  bypasses_physical_resistance = false,  # aún se reduce por resistencia física
  condicion                  = "daño_por_golpe >= hp_max_objetivo * 0.30"
}
```

### 7.3 Activa: Puño Perforante

```gdscript
SkillData {
  id                     = &"punio_perforante"
  display_name           = "Puño Perforante"
  skill_type             = SkillType.ULTIMATE
  description            = "Goku concentra todo su Ki y fuerza en un puño que atraviesa al objetivo. Mata a seres con regeneración de nivel medio."
  ki_cost                = 55.0
  damage_multiplier      = 3.2
  cooldown               = 30.0
  hit_count              = 1
  is_ranged              = false
  effect_tags            = [&"piercing", &"internal"]
  bypasses_ki_shield     = true
  regen_negation_tier    = 6         # niega Regeneración hasta Media-Alta (tier 6/9)
  required_stats         = { &"fuerza": 92.0, &"ki": 85.0, &"intel_combate": 90.0 }
  # Lore: Este es el ataque que mató al Rey Piccolo. Solo puede usarse a distancia 0
  # (toque directo). Goku queda momentáneamente expuesto tras el golpe.
  # NO niega: Regeneración Alta (tier 7+), Inmortalidad tipos 5-9.
}
```

### 7.4 Tabla de Interacciones con Regeneración

| Tipo de Regeneración del Objetivo | ¿Negada por Goku? |
|---|---|
| Regeneración Baja-Baja (tier 1) | Sí (pasiva activa) |
| Regeneración Baja (tier 2) | Sí (pasiva activa) |
| Regeneración Baja-Alta (tier 3) | Sí (pasiva si daño ≥ 30% HP) |
| Regeneración Media-Baja (tier 4) | Sí (Puño Perforante) |
| Regeneración Media (tier 5) | Sí (Puño Perforante) |
| **Regeneración Media-Alta (tier 6)** | **Sí (Puño Perforante — límite de esta saga)** |
| Regeneración Alta (tier 7) | **No** — Piccolo Jr. y superiores la superan |
| Inmortalidad tipos 5-9 | **No** — requiere habilidades específicas (Hakai, etc.) |

---

## 8. Oozaru — Escalado a 7-B Bajo

### 8.1 Stats como Oozaru (Piccolo Daimao)

| Stat | Multiplicador | Valor efectivo |
|---|---|---|
| Fuerza | × 10 | 950 (Ciudad Pequeña; 1.15 Megatones) |
| Velocidad | × 5 | 470 (Hipersónico++) |
| Vitalidad | × 8 | 680 |
| Resistencia | × 6 | 492 (Ciudad Pequeña) |
| Poder Ki | × 4 | 320 |
| Inteligencia | → 2 | Berserk |
| Intel Combate | → 5 | Sin técnicas finas |

### 8.2 Aliento de Energía (escalado)

```gdscript
SkillData {
  id              = &"aliento_energia_7b"
  display_name    = "Aliento de Energía — 7-B"
  efectos = [
    Daño { base = poder_ki * 7.0, tipo = "ki_bruto", area_de_efecto = true, radio = 5.0 }
    # Era 6.5 en la saga anterior
  ]
}
```

---

## 9. Adquisición de Nuevas Habilidades

| Habilidad | Método |
|---|---|
| Detección de Ki (pasiva) | Automática al alcanzar Ki ≥ 80; absorbe la habilidad activa del 22.° Torneo |
| Toque de Presión | Intel Combate ≥ 88 + evento "Entrenamiento bajo Kami" |
| Golpe al Nervio Vital | Intel Combate ≥ 92 + Ki ≥ 80 + usar Toque de Presión ≥ 5 veces |
| Vuelo Natural | Ki ≥ 80 desbloqueado — FlyState ya no requiere Nube Voladora |
| Propulsión de Ki | Ki ≥ 80 + Velocidad ≥ 88 (disponible junto al vuelo natural) |
| Onda de Choque | Fuerza ≥ 90 + Intel Combate ≥ 85 |
| Resonancia Interna | Fuerza ≥ 92 + Ki ≥ 82 + usar Onda de Choque ≥ 3 veces |
| Taiyoken Avanzado | Reemplaza automáticamente al Taiyoken base al alcanzar Intel Combate ≥ 85 |
| Destello Dirigido | Ki ≥ 82 + Poder Ki ≥ 76 + Intel Combate ≥ 88 |
| Daño Perforante (pasiva) | Fuerza ≥ 90 + Intel Combate ≥ 90 — activación automática |
| Puño Perforante | Fuerza ≥ 92 + Ki ≥ 85 + Intel Combate ≥ 90 + evento "Morte del Rey Piccolo" |

---

## 10. Sinergias Nuevas

| Habilidad A | Habilidad B | Sinergia |
|---|---|---|
| Toque de Presión | Imagen Residual | La imagen distrae → Goku toca el punto de presión por detrás (ventaja de posición → +20% probabilidad de KO) |
| Toque de Presión | Kyō-ken | Kyō-ken baja la guardia → Toque de Presión en el momento de confusión (la probabilidad sube al 95%) |
| Onda de Choque | Taiyoken Avanzado | Taiyoken ciega → Onda de Choque sin posibilidad de esquiva (el objetivo no ve la vibración llegar) |
| Resonancia Interna | Gran Fuerza de Voluntad | Si el DoT de Resonancia lleva HP ≤ 15%, activa el desbordamiento de voluntad → Goku contraataca en estado de límite roto |
| Destello Dirigido | Kamehameha Curvado | Cegar al objetivo con Destello → Kamehameha curvado llega desde el ángulo ciego del destello |
| Puño Perforante | Detección de Ki | Detección revela si el objetivo tiene regeneración alta → Goku decide si vale el costo de Ki del Puño o usa otro enfoque |
| Vuelo Natural | Propulsión de Ki | Combo de movilidad aérea: volar → acumular velocidad → Propulsión como rush final |
| Daño Perforante (pasiva) | Desarrollo Acelerado Tipo 1 | A HP bajo, el bonus de Desarrollo sube la Fuerza → más fácil alcanzar el 30% del HP del objetivo por golpe → activa la negación de regen pasiva |

---

## 11. Actualización del Proyecto — SkillData.gd

En esta saga se actualizó `data/skills/SkillData.gd` con los siguientes campos nuevos:

| Campo | Tipo | Propósito |
|---|---|---|
| `regen_negation_tier` | `int` (0–9) | Nivel de Regeneración que la habilidad puede negar |
| `pressure_point_chance` | `float` (0.0–1.0) | Probabilidad de incapacitación por punto de presión |
| `pressure_point_duration` | `float` | Duración del estado de incapacitación (0 = KO) |
| `applies_status` | `String` | Estado de control aplicado ("blind", "paralysis", etc.) |
| `status_duration` | `float` | Duración del estado de control |
| `effect_tags` | `Array[StringName]` | Tags de categoría (&"light", &"vibration", &"piercing"…) |
| `bypasses_ki_shield` | `bool` | Ignora escudos de Ki |
| `bypasses_physical_resistance` | `bool` | Ignora reducción de Resistencia física |

Métodos helper añadidos: `has_tag(tag)` y `negates_regen(tier)`.

---

## 12. Notas de Diseño

- **El salto de tier (8-B → 7-C Alto)** es el mayor gap entre versiones consecutivas de Goku en Dragon Ball clásico. En términos de juego debe sentirse como un hito de progresión claro — el tutorial debería marcar este momento con un evento especial ("Goku supera sus límites luchando herido de muerte").
- **Negación de Regeneración** introduce por primera vez una interacción con el sistema de Inmortalidad documentado en `habilidades_longevidad_vuelo_espacial_inmortalidad_goku.md`. El Puño Perforante (tier 6) establece a Piccolo Jr. como el primer rival que lo supera — motivación narrativa para que el jugador busque formas de subir el tier de negación.
- **Vuelo Natural** es uno de los cambios más impactantes en el meta-juego de día: Goku deja de depender de un ítem para la movilidad aérea. La Nube Voladora sigue siendo útil (+30% velocidad) pero ya no es obligatoria.
- **Puntos de Presión** añaden una victoria alternativa al kit de Goku: además de reducir HP a 0, puede KO al rival con precisión anatómica. Esto lo diferencia de personajes de fuerza bruta y refuerza su identidad como el mayor artista marcial del mundo.
- **SkillData.gd actualizado** sirve a todo el proyecto, no solo a Goku. Los tags `&"vibration"` y `&"light"` ya están disponibles para cualquier personaje que tenga esas habilidades en sus propios docs.
