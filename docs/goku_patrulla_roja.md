# Goku — Saga de la Patrulla Roja (Dragon Ball Clásico)
**Tier de referencia:** 8-B base · 8-A como Oozaru · hasta 7-A con Kamehameha Cargado
**Raza:** Saiyajin (cola presente)
**Predecesor:** `docs/goku_21_torneo.md` → `docs/goku_saga_pilaf.md`

---

## 0. Changelog respecto al 21.° Torneo

| Cambio | 21.° Torneo | Patrulla Roja |
|---|---|---|
| Tier base | 8-C Alto | 8-B |
| Tier Oozaru | 8-B | 8-A |
| Tier máximo (Kamehameha) | — | 7-A (Montaña) |
| Potencia de ataque | Edificio Grande | City Block |
| Potencia Oozaru | City Block (49 t) | Multi-City Block (147 t) |
| Velocidad | Hipersónico | Hipersónico+ (par Tao Pai Pai) |
| Fuerza física | Clase K | Clase K (confirmada, sin salto de clase) |
| Resistencia base | Edificio Grande | City Block |
| Resistencia Oozaru | City Block | Multi-City Block |
| Nueva habilidad | — | Curación (Semillas del Ermitaño) |
| Nueva habilidad | — | Gran Fuerza de Voluntad |
| Nueva resistencia | — | Hielo |
| Nueva resistencia | — | Veneno |
| Nuevo armamento | — | Semillas del Ermitaño (consumible) |
| Inteligencia marcial | Genio | Genio Extraordinario (declarado mejor del mundo) |

---

## 1. Stats Actualizados

| Stat | 21.° Torneo | Patrulla Roja | Notas |
|---|---|---|---|
| Fuerza | 55 | 65 | Clase K sólida post-Korin |
| Velocidad | 50 | 65 | Hipersónico+; par a Tao Pai Pai |
| Ki | 35 | 52 | Kamehameha alcanza Nivel Montaña con carga larga |
| Vitalidad | 48 | 62 | 6 horas bebiendo Agua Ultra Divina |
| Resistencia | 44 | 58 | City Block |
| Poder Ki | 34 | 50 | Carga estática → potencia enormemente amplificada |
| Inteligencia | 32 | 38 | Declarado mejor artista marcial del mundo |
| Intel Combate | 50 | 68 | Lee movimientos, contenciones y debilidades en tiempo real |

> El salto más grande de esta saga está en **Ki** y **Poder Ki**: el entrenamiento con Korin multiplicó el poder varias veces y desbloqueó la mecánica de Kamehameha Cargado.

---

## 2. Nuevas Habilidades

### 2.1 Curación — Semillas del Ermitaño

**Tipo:** Ítem consumible (no SkillData; es equipamiento de combate)
**Descripción lore:** Las Semillas del Ermitaño (Senzu en otras versiones) restauran completamente el cuerpo. Goku las lleva como armamento opcional después de su paso por la Torre de Korin.

**Efectos en juego:**

```gdscript
ItemData {
  nombre        = "Semilla del Ermitaño"
  tipo          = ItemType.CONSUMIBLE_COMBATE
  usos_por_combate = 1        # solo 1 semilla usable por combate
  stock_maximo  = 3           # máximo 3 en inventario
  tiempo_uso    = 1.2         # segundos de animación (ventana de vulnerabilidad)
  efectos = [
    Curar_HP     { porcentaje = 1.00 },      # restaura HP al 100%
    Curar_Ki     { porcentaje = 0.80 },      # restaura 80% del Ki máximo
    Eliminar_Debuffs { tipos = ["veneno", "paralisis", "congelacion", "quemadura"] }
  ]
  adquisicion = "Korin vende 1 semilla por visita a la Torre (evento de día). Máx 3 almacenables."
  notas = "El tiempo de uso crea una ventana de 1.2 s donde Goku es vulnerable. Enemigos con Intel Combate ≥ 50 intentarán interrumpir la animación."
}
```

**Pasiva de portador:** Tener al menos 1 Semilla en inventario otorga +5% a Vitalidad (Goku sabe que tiene respaldo; confianza en combate).

---

### 2.2 Gran Fuerza de Voluntad

**Tipo:** Pasiva permanente (desbloqueada tras el evento "Agua Ultra Divina")
**Descripción lore:** Goku sobrevivió 6 horas bebiendo el Agua Ultra Divina — un veneno que solo superan aquellos con una voluntad y espíritu extraordinarios.

**Efectos en juego:**

| Situación | Efecto |
|---|---|
| HP ≤ 15% | Inmunidad a efectos de miedo, parálisis psíquica y rendición forzada |
| HP ≤ 10% | +30% a todos los stats de ataque (desbordamiento de voluntad) |
| Estado "herido de muerte" | Goku puede ejecutar 1 acción adicional antes de caer (retardo de KO de 2.0 s) |
| Intentos de Sellado mental | Resistencia +40% (voluntad contrarresta el Sellado Tipo 1) |

**Interacción con Desarrollo Acelerado Tipo 2 (Zenkai):**
Cuando Gran Fuerza de Voluntad está activa (HP ≤ 15%), el umbral de Zenkai se activa automáticamente aunque HP no haya caído por debajo del 30% en esa instancia de combate, siempre que la caída haya sido muy rápida (daño > 40% del HP máximo en un solo golpe).

---

## 3. Nuevas Resistencias

### 3.1 Resistencia al Hielo
**Base lore:** Goku pudo salir de ser congelado.

| Efecto de Hielo | Reducción |
|---|---|
| Daño directo de hielo | −45% |
| Congelación (Frío acumulado) | Umbral de stacks para congelación aumentado de 5 a 7 |
| Duración de congelación si ocurre | −60% duración |

**Nota de diseño:** No es inmunidad total — un enemigo con Hielo potente puede seguir congelando a Goku, pero necesita acumular significativamente más stacks y la congelación dura muy poco.

---

### 3.2 Resistencia al Veneno
**Base lore:** Goku bebió el Agua Ultra Divina (veneno de dioses) y sobrevivió 6 horas.

| Grado de Veneno | Efecto sobre Goku |
|---|---|
| Básico (Grado I) | Inmune |
| Leve (Grado II) | Inmune |
| Moderado (Grado III) | −70% duración del DoT |
| Fuerte (Grado IV) | −50% daño y duración del DoT |
| Extra (Grado V / venenos divinos) | −30% daño; Goku lo siente pero lo aguanta |

**Sinergia con Gran Fuerza de Voluntad:** Si el veneno reduce HP ≤ 15%, Gran Fuerza de Voluntad activa su efecto de desbordamiento en lugar de que Goku pierda el combate.

---

## 4. Kamehameha Cargado — Mecánica Nueva (7-A)

La carga lenta de Ki en un punto fijo amplifica enormemente la potencia del Kamehameha. Esta es la razón por la que Goku en esta saga puede alcanzar Nivel Montaña con la misma técnica que antes solo llegaba a Nivel Edificio.

### 4.1 Sistema de Carga

```gdscript
SkillData {
  nombre       = "Kamehameha Cargado"
  tipo         = SkillType.KI_BLAST
  descripcion  = "Goku canaliza Ki en un punto fijo durante un tiempo prolongado antes de disparar. La potencia se amplifica exponencialmente con el tiempo de carga."
  requisitos   = { ki: 50, poder_ki: 48 }
  costo_ki     = 60
  cooldown     = 25.0
  carga_minima = 2.0   # segundos mínimos para activar la versión cargada
  efectos_por_nivel_de_carga = {
    "2.0 s"  : { daño = poder_ki * 4.0,  tier = "City Block" },
    "4.0 s"  : { daño = poder_ki * 6.5,  tier = "Multi-City Block" },
    "7.0 s"  : { daño = poder_ki * 10.0, tier = "Montaña (7-A)" }
  }
  vulnerabilidades_durante_carga = [
    "Goku no puede moverse mientras carga",
    "Recibe +25% más daño durante la carga",
    "Interrupciones con daño ≥ 15% HP max cancelan la carga"
  ]
  notas = "La versión de 7.0 s solo es viable si el enemigo está inmovilizado, cegado (Taiyoken) o Goku tiene cobertura aliada. El riesgo/recompensa define cuándo usarla."
}
```

### 4.2 Kamehameha Impulsado (variante cuerpo a cuerpo)
*(Ya existe desde Pilaf; aquí escala a nueva potencia)*

```gdscript
# Con Poder Ki 50: daño del impulso + impacto directo
Kamehameha_Impulso {
  daño_vuelo  = poder_ki * 1.5,   # daño de propulsión al acercarse
  daño_impacto = poder_ki * 3.0,  # golpe directo al contacto (un solo brazo, como vs Rey Pikkoro)
  cooldown     = 9.0
}
```

---

## 5. Escalado de Intel Combate — Genio Extraordinario

Con Intel Combate en 68, Goku en esta saga tiene capacidades que se traducen en mecánicas específicas:

| Capacidad lore | Mecánica |
|---|---|
| Lee contenciones del enemigo | Si el enemigo tiene HP > 80% y usa una habilidad débil, Goku detecta la reserva y obtiene +15% daño en su próxima acción |
| Encuentra 2 debilidades en una técnica al verla | Al recibir una técnica nueva, la copia (Mímica) Y aplica −10% a la defensa del enemigo contra esa técnica propia |
| Supera a Korin en 3 días (vs 3 años de Roshi) | En el meta-juego: el tiempo de entrenamiento para subir un punto de stat se reduce en 40% respecto al promedio |
| Declarado mejor artista marcial del mundo | Bonus de +10% a todos los ataques de tipo STRIKE contra enemigos con Artes Marciales como habilidad principal |

---

## 6. Oozaru — Escalado a 8-A

### 6.1 Stats como Oozaru (Patrulla Roja)

| Stat | Multiplicador | Valor efectivo |
|---|---|---|
| Fuerza | × 10 | 650 (147 toneladas confirmadas → Clase M sólida) |
| Velocidad | × 5 | 325 (Hipersónico+ → Hipersónico++) |
| Vitalidad | × 8 | 496 |
| Resistencia | × 6 | 348 (Multi-City Block) |
| Poder Ki | × 4 | 200 (Aliento de Energía de mayor potencia) |
| Inteligencia | → 2 | Berserk |
| Intel Combate | → 5 | Pierde artes marciales finas |

### 6.2 Aliento de Energía (escalado)

```gdscript
SkillData {
  nombre  = "Aliento de Energía — 8-A"
  efectos = [
    Daño { base = poder_ki * 6.5, tipo = "ki_bruto", area_de_efecto = true, radio = 4.0 }
    # Era 5.5 en 21.° Torneo
  ]
}
```

---

## 7. Adquisición de Nuevas Habilidades

| Habilidad / Ítem | Método |
|---|---|
| Semillas del Ermitaño | Evento "Torre de Korin" (Day 30–40 del meta-juego); después disponibles para compra a Korin |
| Gran Fuerza de Voluntad | Desbloqueada automáticamente al completar el evento "Agua Ultra Divina" (HP baja a ≤ 5% durante 6 rondas seguidas y Goku sobrevive) |
| Resistencia al Hielo | Pasiva desbloqueada al sobrevivir un ataque de congelación total (evento de historia o combate con enemigo Hielo) |
| Resistencia al Veneno | Pasiva desbloqueada en el evento "Agua Ultra Divina" |
| Kamehameha Cargado | Desbloqueado al alcanzar Ki ≥ 50 + Poder Ki ≥ 48 (post-Korin) |

---

## 8. Sinergias Nuevas

| Habilidad A | Habilidad B | Sinergia |
|---|---|---|
| Gran Fuerza de Voluntad | Desarrollo Acelerado | A HP ≤ 15%, ambas activan simultáneamente: voluntad + boost de poder + inmunidad a efectos de rendición = estado de "último recurso" |
| Gran Fuerza de Voluntad | Semilla del Ermitaño | Si Goku sobrevive con HP ≤ 10%, puede usar la Semilla en el estado de desbordamiento (1.2 s de animación con +30% stats, muy difícil de interrumpir) |
| Kamehameha Cargado | Taiyoken | Combo viable: Taiyoken ciega → 7 s de carga sin interrupción posible → Kamehameha 7-A |
| Kamehameha Cargado | Imagen Residual | La imagen ocupa la atención del enemigo mientras Goku carga en otra posición |
| Resistencia al Veneno | Gran Fuerza de Voluntad | El veneno no puede reducir HP por debajo del umbral de "voluntad activa"; si lo baja, activa el desbordamiento |
| Resistencia al Hielo | Hasshuken | El Hasshuken puede romper la congelación parcial (1–2 stacks de Frío) con el impacto multi-hit |
| Intel Combate 68 | Mímica Tipo 1 | Al copiar una técnica, Goku simultáneamente detecta la debilidad estructural: la versión copiada hace −10% defensa adicional en el enemigo |

---

## 9. Notas de Diseño

- **El salto de poder de Korin** es el mayor gap entre versiones en Dragon Ball clásico. En términos de juego debe reflejarse en una curva de progresión abrupta: los stats de Ki y Poder Ki casi se duplican en el evento de la Torre.
- **Kamehameha Cargado a 7 s** es la primera habilidad del juego que puede alcanzar un tier fundamentalmente más alto que el del personaje base. Diseñarla como un "nuke de alto riesgo" (inmóvil, vulnerable, lenta) es la decisión correcta para mantener el balance.
- **Gran Fuerza de Voluntad** transforma los estados críticos de Goku en oportunidades. Esto debe ser visible en la UI: cuando HP cae a ≤ 15%, el aura de Goku debería cambiar de color (referencia visual al momento de límite roto).
- **Las Semillas del Ermitaño** como ítem con stock limitado (máx 3) fuerzan al jugador a gestionarlas estratégicamente. La ventana de vulnerabilidad durante su uso es la contrapartida correcta a su poder de curación total.
- En esta saga, Goku ya **no tiene nada que aprender de Roshi** según el propio maestro — esto debe reflejarse en el árbol de habilidades: las habilidades marciales base están completamente desbloqueadas y el crecimiento pasa a ser de Ki y transformaciones.
