# Goku — 23.° Torneo Mundial de Artes Marciales (Dragon Ball Clásico)
**Tier de referencia:** 5-C Bajo (Nivel Lunar)
**Raza:** Saiyajin (sin cola — pérdida permanente)
**Predecesor:** `docs/goku_saga_pikkoro_daimao.md`
**Contexto:** 3 años de entrenamiento bajo Kami-sama. Goku derrota a Piccolo Jr., cuyo cuerpo aguantó un Kamehameha capaz de destruir la Luna.

---

## 0. Changelog respecto a la Saga Piccolo Daimao

| Cambio | Piccolo Daimao | 23.° Torneo |
|---|---|---|
| Tier | 7-C Alto | **5-C Bajo** (Nivel Lunar — salto de varios tiers) |
| Potencia de ataque | Pueblo Grande | **Nivel Lunar** (Kamehameha destruye la Luna) |
| Velocidad | Hipersónico+ | Al menos Hipersónico+ (superior a antes) |
| Fuerza física | Clase K | **Clase M** (confirmada) |
| Resistencia | Pueblo Grande | **Nivel Lunar** |
| Nivel de Ki | Avanzado | **Experto** |
| Transformación (Oozaru) | Disponible | **Eliminada permanentemente** (cola perdida) |
| Nueva habilidad | — | Precognición Tipo 1 |
| Nueva resistencia | — | Creación de Ilusiones |
| Debilidad formalizada | (alineación) | "Permite a rivales alcanzar máx. poder" + baja la guardia |
| Armamento | Bastón, Nube, Semillas | **Solo Semillas del Ermitaño** |
| Alcance máximo | Planetario (Bastón) | Decenas de metros con Ki (sin Bastón) |

> **Hito de diseño crítico:** El salto de 7-C Alto a 5-C Bajo es el mayor gap en toda la progresión de Dragon Ball clásico. El Kamehameha pasa de ser un ataque de Nivel Montaña a ser literalmente capaz de destruir la Luna. Esto debe marcarse como un checkpoint de progresión especial en el meta-juego.

---

## 1. Pérdida Permanente de la Cola — Oozaru Eliminado

**Evento de historia:** La cola de Goku es cortada y no vuelve a crecer (Kami interviene para que no regenere). Este es un cambio permanente e irreversible en el juego.

**Consecuencias mecánicas:**

| Efecto | Descripción |
|---|---|
| Todas las habilidades `[REQUIERE_COLA]` | **Permanentemente desactivadas** |
| FlyState sin Nube Voladora | Sin cambio (Vuelo Natural no requería cola) |
| Detección de luna llena | Inocua; la transformación ya no puede ocurrir |
| `Regeneración de Cola` (pasiva) | Desactivada — la cola no vuelve a crecer |
| Debilidad "agarrar la cola" | **Eliminada** — Goku ya no tiene esa vulnerabilidad |

**Ganancia neta:** Goku pierde el enorme multiplicador Oozaru pero elimina permanentemente su mayor debilidad táctica (la cola como punto de control del rival).

> En el árbol de progresión, cuando ocurre este evento, todas las habilidades `[REQUIERE_COLA]` se marcan como bloqueadas con el texto: *"Cola perdida permanentemente — habilidad no disponible."*

---

## 2. Stats Actualizados

| Stat | Piccolo Daimao | 23.° Torneo | Notas |
|---|---|---|---|
| Fuerza | 95 | 135 | Clase M confirmada |
| Velocidad | 94 | 125 | Al menos Hipersónico+ superior |
| Ki | 88 | 118 | Nivel Experto; Kamehameha lunar sin carga extrema |
| Vitalidad | 85 | 115 | 3 años de entrenamiento bajo Kami |
| Resistencia | 82 | 135 | Nivel Lunar |
| Poder Ki | 80 | 140 | Kamehameha destruye la Luna en disparo base |
| Inteligencia | 40 | 42 | Sin cambio cualitativo |
| Intel Combate | 92 | 112 | Precognición Tipo 1 activa |

> El stat con mayor crecimiento absoluto es **Poder Ki** (+60) — refleja que el Ki Experto convierte el Kamehameha en un ataque de escala planetaria incluso sin carga prolongada.

---

## 3. Manipulación del Ki — Nivel Experto

### 3.1 Qué cambia respecto al Ki Avanzado

| Capacidad | Ki Avanzado | Ki Experto |
|---|---|---|
| Kamehameha base | City Block | **Nivel Lunar** |
| Costo global de Ki | −28% | **−38%** |
| Recuperación de Ki | +25% | **+40%** |
| Supresión de Ki | 15% del Ki real visible | **5% del Ki real visible** |
| Escudo de Ki base | Poder Ki × 1.5 | **Poder Ki × 2.2** |
| Carga Kamehameha nivel máximo | 6 s → Montaña | **3 s → Lunar** |

### 3.2 Pasiva: Flujo de Ki Perfecto

Con Ki Experto (Ki ≥ 110), el Ki se integra completamente con cada movimiento físico:
- Los ataques STRIKE aplican automáticamente Ki concentrado sin costo adicional, añadiendo **+15% daño de tipo ki** a cada golpe físico.
- La Barrera de Ki se regenera pasivamente a razón de Poder Ki × 0.08 por segundo cuando no está recibiendo daño.
- El Ki no cae por debajo del 10% de su máximo en combate (el cuerpo de Goku reserva Ki de forma instintiva).

---

### 3.3 Kamehameha — Nivel Experto

```gdscript
SkillData {
  id               = &"kamehameha_experto"
  display_name     = "Kamehameha (Experto)"
  skill_type       = SkillType.KI_BLAST
  description      = "El Kamehameha de Goku ahora tiene la capacidad de destruir la Luna. Versión de 23.° Torneo."
  ki_cost          = 35.0          # era 28 en versiones anteriores (reducción por eficiencia)
  damage_multiplier = 4.5          # era 2.8 en versión básica; escala Lunar
  cooldown         = 6.0
  hit_count        = 1
  is_ranged        = true
  effect_tags      = [&"ki_blast", &"lunar_tier"]
  required_stats   = { &"ki": 110.0, &"poder_ki": 130.0 }

  # Sistema de carga (tiempos reducidos por Ki Experto):
  # 1.0 s → Nivel Multi-City Block
  # 2.0 s → Nivel Montaña (7-A)
  # 3.0 s → Nivel Lunar (5-C)  ← nuevo máximo, antes requería 6 s
}
```

---

### 3.4 Activa: Barrera de Ki Experta

```gdscript
SkillData {
  id               = &"barrera_ki_experta"
  display_name     = "Barrera de Ki Experta"
  skill_type       = SkillType.SUPPORT
  description      = "Goku proyecta un escudo de Ki de alta densidad que bloquea tanto daño físico como de Ki."
  ki_cost          = 18.0          # era 20
  damage_multiplier = 0.0
  effect_value     = 0.0
  cooldown         = 14.0          # era 18
  hit_count        = 1
  effect_tags      = [&"shield", &"ki_shield"]
  # Absorción: Poder Ki × 2.2 (era × 1.5)
  # Regeneración pasiva: Poder Ki × 0.08 /s cuando no recibe daño
  required_stats   = { &"ki": 110.0, &"poder_ki": 128.0 }
}
```

---

### 3.5 Activa: Liberación Total de Ki

```gdscript
SkillData {
  id               = &"liberacion_total_ki"
  display_name     = "Liberación Total de Ki"
  skill_type       = SkillType.ULTIMATE
  description      = "Goku libera todo su Ki en una explosión omnidireccional de escala planetaria. Último recurso."
  ki_cost          = 90.0          # consume casi todo el Ki
  damage_multiplier = 6.0
  cooldown         = 60.0
  hit_count        = 1
  is_ranged        = false
  effect_tags      = [&"aoe", &"ki_blast", &"lunar_tier"]
  bypasses_ki_shield = true
  regen_negation_tier = 5          # Media; el Ki puro de escala lunar interfiere con regeneración media
  required_stats   = { &"ki": 115.0, &"poder_ki": 138.0 }
  # Radio de efecto: toda la arena de combate.
  # Goku queda con Ki al 5% tras usarlo — extremadamente vulnerable durante 8 s.
}
```

---

## 4. Precognición Tipo 1

### 4.1 Descripción lore
Goku predijo los siguientes movimientos de Tenshinhan durante el 23.° Torneo. No es visión del futuro puro — es la combinación de Intel Combate extremo, Detección de Ki pasiva y la capacidad de leer micro-movimientos musculares antes de que ocurran.

*(Sistema base documentado en `docs/habilidades_luz_nulificacion_precognicion_aura_evolucion_explosiones.md` — esta sección muestra la integración específica con el kit de Goku.)*

---

### 4.2 Pasiva: Lectura de Intención
**Requisito de activación:** Intel Combate ≥ 108

```gdscript
# Con Intel Combate ≥ 108, activo de forma permanente:
Precognicion_T1 {
  descripcion      = "Goku lee los micro-movimientos musculares y el flujo de Ki del rival para anticipar la siguiente acción.",
  adelanto_frames  = 12,           # equivalente a ~0.2 s de anticipación a 60 fps
  probabilidad_base = 0.70,        # 70% de chance de leer el próximo ataque correctamente
  # La probabilidad sube:
  # +10% si el rival ha usado esa acción antes en el combate (memoria de patrón)
  # +15% si Detección de Ki está activa y muestra el flujo de Ki del ataque
  # −20% si el rival tiene Acción Instintiva activa (no hay intención detectable)
  # −30% si el rival está bajo efecto de Kyō-ken propio (comportamiento errático)
}
```

**Efectos al leer correctamente:**
- El próximo ataque del rival tiene 50% de probabilidad de ser esquivado automáticamente (en lugar del valor normal de evasión).
- Si Goku elige no esquivar, recibe los datos del ataque y obtiene +25% al contraataque inmediato.

---

### 4.3 Activa: Análisis Predictivo

```gdscript
SkillData {
  id               = &"analisis_predictivo"
  display_name     = "Análisis Predictivo"
  skill_type       = SkillType.SUPPORT
  description      = "Goku enfoca completamente su lectura del rival. Durante 8 s, predice todos sus movimientos con precisión casi perfecta."
  ki_cost          = 20.0
  cooldown         = 22.0
  effect_value     = 0.0
  hit_count        = 1
  effect_tags      = [&"precognition", &"combat_read"]
  required_stats   = { &"intel_combate": 108.0 }
  # Efectos durante 8 s:
  # Probabilidad de lectura sube a 0.95 (95%)
  # Esquiva automática al 75%
  # Contraataque tras esquiva: +40% daño
  # El rival NO puede engañar a Goku con Kyō-ken ni Imagen Residual (Goku lee el Ki, no la imagen)
  status_duration  = 8.0
  applies_status   = ""            # no aplica status al rival; el efecto es sobre Goku
}
```

---

### 4.4 Interacción de Precognición con el kit completo

| Situación | Resultado |
|---|---|
| Rival usa Kyō-ken vs Goku | La precognición lee el Ki del golpe real, no la finta → finta ineficaz |
| Rival usa Imagen Residual | Goku detecta cuál imagen tiene Ki real → esquiva automáticamente hacia la correcta |
| Rival activa una transformación | Goku detecta el cambio de Ki antes de que sea visible → se prepara en lugar de sorprenderse |
| Rival usa Supresión de Ki | Reduce la efectividad de Precognición al 40% (menos Ki que leer) |
| Rival tiene Acción Instintiva | Precognición baja al 35% (los movimientos instintivos no emiten intención Ki previa) |
| Rival usa Ilusiones | Ver sección 5 — Resistencia a Ilusiones |

---

## 5. Resistencia a Creación de Ilusiones

**Base lore:** Goku puede distinguir entre lo real y lo ilusorio gracias a su Ki y su Detección pasiva.

### 5.1 Mecánica

```gdscript
ResistenciaIlusiones {
  descripcion = "La Detección de Ki pasiva de Goku le permite ignorar imágenes sin firma de Ki real.",
  inmunidad_completa = [
    "Ilusiones visuales sin Ki asociado",
    "Ilusiones de tipo Grado I y II (básicas)"
  ],
  resistencia_parcial = {
    "Ilusiones Grado III" : { reduccion_duracion = 0.50, probabilidad_ignorar = 0.60 },
    "Ilusiones Grado IV"  : { reduccion_duracion = 0.30, probabilidad_ignorar = 0.35 },
    "Ilusiones de Herida" : { probabilidad_ignorar = 0.50 }  # Goku puede sentir que su cuerpo no responde
  },
  sin_resistencia = [
    "Ilusiones perfectas con Ki propio del ilusionista (Grado V)",
    "Ilusiones que afectan directamente al cerebro sin input visual"
  ]
}
```

**Sinergia con Precognición:** Si la ilusión no coincide con el patrón de Ki que Precognición estaba leyendo, Goku la identifica automáticamente (−30% al umbral de detección de ilusiones).

---

## 6. Debilidades Formalizadas

Las debilidades de Goku se actualizan en esta saga para reflejar mejor el perfil lore.

### 6.1 "Permite el Máximo Poder del Rival" (Caótico Bueno — formalizado como debilidad)

Lo que en el 22.° Torneo era solo una mecánica de roleplay con beneficio, ahora tiene un coste real documentado:

```gdscript
DebilidadCarácter {
  nombre = "Combatiente de Corazón — Doble Filo",
  efectos_positivos = {
    "Emoción del Combate" : "+3% stats por stack (máx 5 = +15%)"
  },
  efectos_negativos = {
    "Permitir transformación rival"     : "El rival regresa con todos sus buffs al máximo",
    "Alargar innecesariamente la pelea" : "-10% Vitalidad efectiva por cada 30 s pasados del tiempo óptimo de victoria",
    "Distraerse en combate"             : "20% probabilidad por turno de que Goku 'baje la guardia' → −15% a esquiva durante 3 s"
  }
}
```

### 6.2 "Baja la Guardia al Distraerse"

```gdscript
# Triggers de distracción (20% probabilidad base por turno):
Triggers_Distraccion {
  # Goku se distrae si:
  "Rival hace algo inesperado o impresionante" : { probabilidad = 0.25 },
  "Goku tiene HP > 80%"                        : { bonus_distraccion = 0.10 },  # Cuando está cómodo
  "Rival demuestra una técnica nueva"          : { probabilidad = 0.30 },
  # Mitigación:
  "Precognición Tipo 1 activa"                 : { reduccion = 0.15 },
  "Intel Combate ≥ 108"                        : { reduccion = 0.10 }
}
```

---

## 7. Equipamiento — Cambios

### 7.1 Bastón Sagrado — Perdido
El Bastón Sagrado ya no aparece en el inventario de Goku desde este perfil. No hay evento explícito de pérdida; simplemente deja de usarlo como adulto. En el árbol de progresión, el ítem queda marcado como "no equipado" de forma permanente.

### 7.2 Nube Voladora — Pérdida de Relevancia
La Nube Voladora sigue existiendo como ítem, pero Goku ya tiene Vuelo Natural (Ki ≥ 80). A efectos prácticos solo conserva valor como coleccionable o para otros personajes con `pure_heart = true`. No aparece en "Armamento" de este perfil.

### 7.3 Semillas del Ermitaño — Único Armamento
Sin cambios respecto al perfil anterior. Stock máx. 3, curación 100% HP + 80% Ki, ventana de vulnerabilidad 1.2 s.

---

## 8. Kamehameha — Sistema de Niveles Completo (Actualizado)

Con Ki Experto, el Kamehameha alcanza su forma más potente en Dragon Ball clásico. Tabla unificada de todos los niveles documentados hasta aquí:

| Versión | Tier | Daño (× Poder Ki) | Carga | Disponible desde |
|---|---|---|---|---|
| Básico (Pilaf) | Edificio | 2.8 | 0 s | Doc: goku_saga_pilaf |
| Aéreo / Curvado | Edificio+ | 2.8 | 0 s | 21.° Torneo |
| Cargado Lv.1 | City Block | 4.0 | 2 s → 1 s | Patrulla Roja → 22.° Torneo |
| Cargado Lv.2 | Multi-City Block | 6.5 | 4 s → 3 s | Patrulla Roja → 22.° Torneo |
| Cargado Lv.3 | Montaña (7-A) | 10.0 | 7 s → 6 s → 3 s | Patrulla Roja → Piccolo D. → **23.° T.** |
| **Base Experto** | **Lunar (5-C)** | **4.5** | **0 s** | **23.° Torneo** |
| **Cargado Lunar** | **Lunar (5-C)** | **—** | **3 s** | **23.° Torneo** |

> La versión "Base Experto" de 0 s ya alcanza Lunar (5-C) sin carga porque el Poder Ki de Goku en este tier es suficiente. La carga de 3 s puede amplificarlo aún más, pero el disparo rápido ya es devastador.

---

## 9. Adquisición de Nuevas Habilidades

| Habilidad | Método |
|---|---|
| Ki Experto (pasiva) | Automática al alcanzar Ki ≥ 110 + evento "Entrenamiento completado bajo Kami-sama" |
| Kamehameha Experto | Reemplaza automáticamente la versión anterior al alcanzar Poder Ki ≥ 130 |
| Barrera de Ki Experta | Reemplaza la versión Avanzado al alcanzar Ki ≥ 110 + Poder Ki ≥ 128 |
| Liberación Total de Ki | Ki ≥ 115 + Poder Ki ≥ 138 (disponible en el 23.° Torneo) |
| Precognición Tipo 1 (pasiva) | Intel Combate ≥ 108 — activación automática |
| Análisis Predictivo | Intel Combate ≥ 108 (desbloqueada junto con la pasiva) |
| Resistencia a Ilusiones | Pasiva desbloqueada automáticamente al completar el evento de historia del 23.° Torneo |
| Debilidad "Baja la Guardia" | Formalizada — siempre activa para Goku; no es aprendible ni desactivable |

---

## 10. Sinergias Nuevas

| Habilidad A | Habilidad B | Sinergia |
|---|---|---|
| Precognición Tipo 1 | Detección de Ki | La detección pasiva alimenta la precognición: más Ki leído → mayor precisión de predicción |
| Precognición Tipo 1 | Contraataque | Leer el ataque + +40% daño en respuesta → el mejor combo de daño reactivo de Goku |
| Precognición Tipo 1 | Resistencia a Ilusiones | Si la ilusión no coincide con el Ki leído, se identifica automáticamente |
| Análisis Predictivo | Kamehameha Experto | 8 s de predicción perfecta → Goku encuentra el hueco exacto para cargar 3 s sin interrupción |
| Análisis Predictivo | Emoción del Combate | Goku sabe exactamente cuándo el rival va a subir de potencia (Precognición lee el cambio de Ki) → acumula stacks antes de que el rival golpee |
| Flujo de Ki Perfecto | Onda de Choque | Cada STRIKE ya tiene +15% Ki incluido → Onda de Choque añade bypasses encima → daño total muy alto |
| Liberación Total de Ki | Gran Fuerza de Voluntad | Si Goku usa Liberación Total y cae a Ki ≤ 5%, Gran Fuerza de Voluntad activa el desbordamiento → puede seguir peleando en estado de Ki casi vacío |
| Debilidad "Baja la Guardia" | Desarrollo Acelerado Tipo 1 | Los golpes que Goku recibe por bajar la guardia activan el bonus de poder → la debilidad se convierte en combustible para el Zenkai |

---

## 11. Notas de Diseño

- **El salto a 5-C Bajo es el hito más importante de Dragon Ball clásico** y debe marcarse como tal en el juego. Un checkpoint de historia con cinemática, cambio de música y evento especial confirmaría el nuevo poder al jugador. Los stat caps de los enemigos de las sagas anteriores quedan completamente superados.
- **La pérdida de la cola** elimina la mayor debilidad táctica de Goku. Desde el punto de vista del diseño, es un trade: se cierra para siempre la ruta Oozaru (enorme daño bruto, enorme riesgo) a cambio de nunca más poder ser controlado por la cola. El jugador que jugó las sagas anteriores sabrá valorarlo.
- **Precognición Tipo 1** es el primer sistema del juego que interactúa directamente con la IA del enemigo a nivel de predicción. El sistema de "leer el siguiente movimiento" debe tener algún indicador visual claro — un brillo del aura de Goku cuando activa correctamente la predicción, por ejemplo.
- **La debilidad formalizada** es ahora una mecánica real con coste (-10% Vitalidad efectiva por cada 30 s extra, 20% de distracción por turno). Antes era solo roleplay. Esto crea tensión genuina: el jugador quiere acumular stacks de Emoción, pero alargar demasiado la pelea tiene consecuencias reales.
- **Ki Experto** debería ser el límite del sistema de Ki en Dragon Ball clásico. Las sagas de Z (Saiyajin, Freezer, etc.) requieren un tier nuevo de control de Ki — posiblemente "Maestro" o "Trascendente" — que no se documenta aquí pero debería planificarse para cuando lleguen esas sagas.
