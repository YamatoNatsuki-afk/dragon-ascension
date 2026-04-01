# Goku — Saga Pilaf (Dragon Ball Clásico)
**Tier de referencia:** 8-C base · 8-C Alto como Oozaru
**Raza:** Saiyajin (cola presente)
**Rol en el juego:** Personaje jugable inicial; punto de partida canónico antes de cualquier transformación mayor.

---

## Resumen de Perfil

| Stat base sugerido | Valor inicial (Day 1) | Notas |
|---|---|---|
| Fuerza | 38 | Clase 25 físico; base alta para nivel 8-C |
| Velocidad | 32 | Supersónico; alcanza pterodáctilos, esquiva disparos |
| Ki | 22 | Ki Básico; potencia de edificio con Kamehameha |
| Vitalidad | 35 | Blindaje anti-bala, resistencia comparable al acero |
| Resistencia | 30 | Nivel Edificio; inmune a impactos de bala |
| Poder Ki | 20 | Proyección básica; sin Kaioken todavía |
| Inteligencia | 28 | Genio en combate; copia técnicas al verlas 1 vez |
| Intel Combate | 40 | Reflejo y lectura de combate excepcionales |

> Estos valores escalan con la progresión normal del juego; son el punto de partida antes de transformaciones.

---

## 1. Capacidades Físicas — Pasivas

### 1.1 Sentidos Excepcionales
**Tipo:** Pasiva permanente
**Descripción lore:** Goku rastrea olores a distancia, ve claramente a gran alcance y detecta movimiento por vibraciones en el aire incluso en oscuridad total.

**Efectos en juego:**
- No sufre penalización de precisión en entornos de oscuridad o humo.
- Puede detectar enemigos ocultos (Sigilo Básico no funciona contra él; requiere Sigilo ≥ Rango 3).
- Bonus de +10% a Intel Combate contra enemigos que intenten emboscadas.

---

### 1.2 Blindaje Saiyajin
**Tipo:** Pasiva permanente
**Descripción lore:** El cuerpo de Goku tiene una durabilidad comparable al acero; las balas no lo afectan.

**Efectos en juego:**
- Inmunidad completa a daño de tipo "proyectil físico bajo" (ataques marcados con la tag `PHYSICAL_BULLET`).
- Reducción de daño físico del 8% de forma pasiva (cuenta como Resistencia natural, no como escudo de ki).

---

### 1.3 Desarrollo Acelerado — Tipos 1 y 2
**Tipo:** Pasiva permanente (Fisiología Saiyajin)
**Descripción lore:** El poder de un Saiyajin aumenta considerablemente a medida que recibe daño. Si se recupera de un estado crítico, alcanza un nuevo pico de poder (Zenkai).

**Efectos en juego:**

| Umbral de HP restante | Efecto Tipo 1 (en combate) |
|---|---|
| < 75 % HP | +5% a Fuerza y Velocidad |
| < 50 % HP | +12% a Fuerza y Velocidad |
| < 25 % HP | +20% a Fuerza y Velocidad; +10% Poder Ki |

**Tipo 2 — Zenkai Post-Combate:**
Si Goku termina el combate con HP ≤ 30% y sobrevive, al día siguiente recibe:
- +2 puntos permanentes distribuidos automáticamente en el stat más bajo entre Fuerza, Velocidad y Poder Ki.
- El bonus es acumulable entre combates.
*(Ver: Sistema Zenkai en `docs/habilidades_longevidad_vuelo_espacial_inmortalidad_goku.md`)*

---

### 1.4 Mímica Tipo 1 — Réplica Instantánea
**Tipo:** Pasiva permanente
**Descripción lore:** Basta ver una técnica una sola vez para copiarla.

**Efectos en juego:**
- Después de recibir un ataque especial de un enemigo (SkillType ≠ STRIKE básico), Goku desbloquea temporalmente esa técnica como "Técnica Copiada" durante el resto del combate.
- La técnica copiada usa los stats de Goku (no los del enemigo).
- Limitación: solo 1 técnica copiada activa simultáneamente; se sobrescribe al copiar otra.
- Post-combate, las técnicas copiadas no se retienen (solo duran 1 combate) salvo que se adquieran formalmente.

---

### 1.5 Regeneración Baja-Alta — Cola
**Tipo:** Pasiva condicional
**Descripción lore:** La cola de Goku vuelve a crecer con el tiempo si es cortada.

**Efectos en juego:**
- Si Goku pierde la cola (evento de historia o mechanic futura), a los 7 días de juego regresa.
- La cola es requisito para la transformación Oozaru.
- Mientras la cola está ausente, Goku pierde acceso a todas las habilidades con tag `[REQUIERE_COLA]`.

---

## 2. Manipulación del Ki (Básico) — Pasiva + Activas

### 2.1 Pasiva: Control de Ki Innato
- Reduce el costo de Ki de todas las habilidades Ki en 10%.
- El Ki se recupera un 15% más rápido en combate que el valor base.

---

### 2.2 Amplificación de Estadísticas (Ki Básico)

```gdscript
SkillData {
  nombre       = "Potenciación de Ki"
  tipo         = SkillType.SUPPORT
  descripcion  = "Goku canaliza su Ki para amplificar temporalmente sus capacidades físicas."
  requisitos   = { ki: 22, intel_combate: 30 }
  costo_ki     = 18
  cooldown     = 14.0
  duracion     = 10.0
  efectos = [
    StatBuff { stat = "fuerza",    multiplicador = 1.25 },
    StatBuff { stat = "velocidad", multiplicador = 1.20 },
    StatBuff { stat = "poder_ki",  multiplicador = 1.15 }
  ]
  notas = "Versión básica sin coste post-buff. Precursora del Kaioken."
}
```

---

### 2.3 Proyección de Energía — Kamehameha

```gdscript
SkillData {
  nombre       = "Kamehameha"
  tipo         = SkillType.KI_BLAST
  descripcion  = "Técnica insignia. Goku concentra ki entre sus manos y dispara una ola de energía devastadora."
  requisitos   = { ki: 22, poder_ki: 18 }
  costo_ki     = 28
  cooldown     = 6.0
  duracion     = 0.0   # proyectil instantáneo
  efectos = [
    Daño { base = poder_ki * 2.8, tipo = "ki", penetra_escudo_fisico = true }
  ]
  variantes_desbloqueables = [
    "Kamehameha Aéreo",          # disparo desde los pies para impulsarse
    "Kamehameha Curvado",        # dobla trayectoria en vuelo
    "Kamehameha desde Impulso"   # usado para atacar cuerpo a cuerpo tras el vuelo
  ]
  notas = "Aprendido copiando al Maestro Roshi. Variantes se desbloquean con Intel Combate ≥ 45."
}
```

---

### 2.4 Kiai

```gdscript
SkillData {
  nombre       = "Kiai"
  tipo         = SkillType.SUPPORT
  descripcion  = "Proyección invisible de fuerza ki. Puede ejecutarse con las manos o solo con la mirada."
  requisitos   = { ki: 18, intel_combate: 25 }
  costo_ki     = 10
  cooldown     = 3.5
  efectos = [
    Daño       { base = poder_ki * 0.9, tipo = "ki_contundente" },
    Knockback  { fuerza = 1.5 },
    Stagger    { duracion = 0.4 }
  ]
  variante_mirada = {
    descripcion = "Versión visual (sin gestos): mismo daño, menor cooldown (2.5 s). Requiere Intel Combate ≥ 40."
  }
}
```

---

### 2.5 Creación de Campo de Fuerza (Barrera Ki Básica)

```gdscript
SkillData {
  nombre       = "Barrera de Ki"
  tipo         = SkillType.SUPPORT
  descripcion  = "Goku proyecta su ki como escudo defensivo a su alrededor."
  requisitos   = { ki: 20, poder_ki: 16 }
  costo_ki     = 20
  cooldown     = 18.0
  duracion     = 5.0
  efectos = [
    Escudo { absorcion = poder_ki * 1.5, tipo = "ki", bloquea_proyectiles_fisicos = true }
  ]
  notas = "Nivel básico. Versiones avanzadas con Ki ≥ 50."
}
```

---

## 3. Artes Marciales — Técnicas Activas

### 3.1 Jan Ken (Piedra · Tijeras · Papel)

```gdscript
SkillData {
  nombre       = "Jan Ken"
  tipo         = SkillType.STRIKE
  descripcion  = "Técnica inicial de Goku. Tres variantes según el grito: golpe fuerte (Piedra), golpe a los ojos (Tijeras) o palma abierta (Papel)."
  requisitos   = { fuerza: 20, intel_combate: 15 }
  costo_ki     = 0
  cooldown     = 2.0
  variantes = {
    "Piedra"  : { daño = fuerza * 1.4,  efecto = Stagger(0.5) },
    "Tijeras" : { daño = fuerza * 0.9,  efecto = Ceguera(2.0) },
    "Papel"   : { daño = fuerza * 1.1,  efecto = Knockback(1.2) }
  }
  notas = "La variante se elige aleatoriamente o se puede fijar con Intel Combate ≥ 30."
}
```

---

### 3.2 Dragonthrow

```gdscript
SkillData {
  nombre       = "Dragonthrow"
  tipo         = SkillType.STRIKE
  descripcion  = "Goku agarra al enemigo por el brazo, cola o antenas y lo lanza con fuerza."
  requisitos   = { fuerza: 25, velocidad: 22 }
  costo_ki     = 5
  cooldown     = 7.0
  efectos = [
    Agarre    { probabilidad_exito = 0.75 },
    Daño      { base = fuerza * 1.6, al_impacto_con_suelo = true },
    Knockdown { duracion = 1.2 }
  ]
  bonus_vs_cola_antenas = { extra_daño = 0.3, agarre_garantizado = true }
}
```

---

### 3.3 Hasshuken (Ocho Brazos)

```gdscript
SkillData {
  nombre       = "Hasshuken"
  tipo         = SkillType.STRIKE
  descripcion  = "Goku mueve los brazos a tal velocidad que aparentan ser ocho. Contrarresta ataques multi-hit y confunde al oponente."
  requisitos   = { velocidad: 30, intel_combate: 35 }
  costo_ki     = 12
  cooldown     = 12.0
  duracion     = 4.0
  efectos = [
    Golpe_Multiple { hits = 8, daño_por_hit = fuerza * 0.5 },
    Reflect_Melee  { probabilidad = 0.4, duracion = 4.0 }
  ]
  notas = "Copiado del Rey Chappa. Contrarrestar Shiyoken requiere que ambas habilidades se den en el mismo frame de activación."
}
```

---

### 3.4 Kyō-ken (Finta Salvaje)

```gdscript
SkillData {
  nombre       = "Kyō-ken"
  tipo         = SkillType.SUPPORT
  descripcion  = "Goku finge comportarse como un animal salvaje para distraer al enemigo y golpear cuando baja la guardia."
  requisitos   = { intel_combate: 28, velocidad: 25 }
  costo_ki     = 8
  cooldown     = 10.0
  efectos = [
    Debuff_Guardia { reduccion_defensa_enemigo = 0.20, duracion = 3.0 },
    Bonus_Proximo_Ataque { multiplicador = 1.5, ventana = 2.0 }
  ]
  notas = "El enemigo debe tener Intel Combate < 35 para caer en la finta. Enemigos con Acción Instintiva son inmunes."
}
```

---

### 3.5 Taiyoken (Destello Solar)

```gdscript
SkillData {
  nombre       = "Taiyoken"
  tipo         = SkillType.SUPPORT
  descripcion  = "Goku lleva las manos a la cara y genera un destello de luz cegador."
  requisitos   = { intel_combate: 30, ki: 15 }
  costo_ki     = 12
  cooldown     = 9.0
  efectos = [
    Ceguera { duracion = 3.0, radio = "pantalla_completa" },
    Reduccion_Precision_Enemigo { valor = 0.70, duracion = 3.0 }
  ]
  inmunidades_enemigas = ["Sentidos Mejorados Rango 4+", "Percepción Extrasensorial activa"]
  notas = "Copiado de Tenshinhan durante el Torneo Mundial."
}
```

---

## 4. Invocación — Nube Voladora

### 4.1 Pasiva: Vínculo con la Nube
- Si Goku tiene el corazón puro (flag `pure_heart = true`), la Nube Voladora responde a su llamado.
- En el meta-juego de día: la Nube reduce el costo de viaje entre localizaciones a 0 PA (Puntos de Acción).

### 4.2 Activa: Montura Aérea

```gdscript
SkillData {
  nombre       = "Nube Voladora"
  tipo         = SkillType.SUPPORT
  descripcion  = "Goku invoca la Nube Voladora para desplazarse en el aire."
  requisitos   = { pure_heart = true }   # flag especial, no stat numérico
  costo_ki     = 0
  cooldown     = 0.0
  efectos = [
    Movilidad_Aerea { velocidad_vuelo = velocidad * 1.3, manos_libres = true }
  ]
  notas = "No consume ki de vuelo propio. Distinta a Vuelo activo. Puede usarse para lanzar Kamehameha desde el aire."
}
```

---

## 5. Transformación — Oozaru `[REQUIERE_COLA]`

### 5.1 Condición de Activación
- **Trigger:** Exposición a la Luna Llena (evento de escena) mientras la cola está presente.
- **Control:** La transformación es **involuntaria**; Goku no puede activarla ni desactivarla a voluntad.
- En el juego se puede modelar como un evento scripted en combates nocturnos especiales (saga de la Patrulla Roja, combate contra Pilaf).

### 5.2 Stats como Oozaru

| Stat | Multiplicador sobre base |
|---|---|
| Fuerza | × 10 |
| Velocidad | × 5 (Hipersónico+) |
| Vitalidad | × 8 |
| Resistencia | × 6 |
| Inteligencia | → 2 (Modo Berserk; anula control) |
| Intel Combate | → 5 (pierde artes marciales finas) |

### 5.3 Habilidades activas en Oozaru

```gdscript
SkillData {
  nombre       = "Aliento de Energía"
  tipo         = SkillType.KI_BLAST
  descripcion  = "El Oozaru dispara una enorme ráfaga de energía desde la boca."
  requisitos   = { forma_activa = "Oozaru" }
  costo_ki     = 35
  cooldown     = 5.0
  efectos = [
    Daño { base = poder_ki * 4.5, tipo = "ki_bruto", area_de_efecto = true, radio = 3.0 }
  ]
}
```

```gdscript
SkillData {
  nombre       = "Aplastamiento Oozaru"
  tipo         = SkillType.STRIKE
  descripcion  = "El Oozaru golpea o pisa con su enorme masa corporal."
  requisitos   = { forma_activa = "Oozaru" }
  costo_ki     = 0
  cooldown     = 3.0
  efectos = [
    Daño      { base = fuerza * 3.0, tipo = "fisico_masivo" },
    Knockdown { duracion = 2.0 },
    AoE       { radio = 2.5 }
  ]
}
```

### 5.4 Debilidades de la forma Oozaru

| Vulnerabilidad | Efecto |
|---|---|
| Cola agarrada | HP → 0 instantáneo (victory condition del enemigo) |
| Cola cortada | Goku revierte a forma base, KO si HP < 10% |
| Luna oculta / día | Transformación termina automáticamente |
| Modo Berserk | Puede atacar aliados en modo historia |

---

## 6. Resistencias — Inmunidades Base

| Tipo de daño/efecto | Estado |
|---|---|
| Proyectiles físicos bajos (balas) | Inmune (Blindaje) |
| Manipulación Eléctrica | Resistente (−50% daño) |
| Manipulación del Dolor | Resistente (reducción de penalización; no inmune) |
| Manipulación del Miedo | Inmune si Ki ≥ 30 (aura fuerte contrarresta el aura de intimidación) |

---

## 7. Equipamiento — Efectos en Juego

### 7.1 Bastón Sagrado (Nyoibo)

| Atributo | Valor |
|---|---|
| Alcance máximo | Planetario (363 300 km; solo en contexto de saga / historia) |
| Alcance en combate | 5 metros (arma de melee extendida) |
| Daño base | fuerza × 1.3, tipo "físico_contundente" |
| Habilidad especial | Puede expandirse instantáneamente para crear distancia o alcanzar objetivos lejanos |

**Pasiva de arma:** El Bastón obedece a la voluntad de Goku mentalmente; no puede ser desarmado con métodos normales de desarme.

### 7.2 Nube Voladora
*(Ver sección 4 — Invocación)*

### 7.3 Radar del Dragón (Opcional)
- Ítem de exploración en el meta-juego de día.
- Reduce el costo de Puntos de Acción para encontrar objetivos de misión en 50%.
- No tiene efecto en combate.

---

## 8. Rompimiento de la 4ta Pared

**Tipo:** Habilidad situacional / evento de historia
**Descripción:** Goku puede romper partes del manga físico. En juego esto se modela como un evento scripted único sin mecánica recurrente (no entra en SkillData; es un trigger de narrativa).

---

## 9. Adquisición de Habilidades

| Habilidad | Método |
|---|---|
| Sentidos Excepcionales | Pasiva desde el inicio (raza + entrenamiento con Abuelo Gohan) |
| Blindaje Saiyajin | Pasiva desde el inicio |
| Desarrollo Acelerado Tipos 1 y 2 | Pasiva desde el inicio (Fisiología Saiyajin) |
| Mímica Tipo 1 | Pasiva desde el inicio; se activa al recibir técnicas enemigas |
| Regeneración de Cola | Pasiva (requiere evento "Cola cortada" para ser relevante) |
| Potenciación de Ki | Disponible Day 1 si jugador elige inicio con Goku |
| Kamehameha | Desbloqueado en evento de historia (observar a Maestro Roshi; Day 3–5) |
| Kiai | Entrenamiento con Korin o Maestro Roshi (Day 15+) |
| Barrera de Ki | Entrenamiento con Maestro Roshi (Day 20+) |
| Jan Ken | Disponible Day 1 (enseñada por Abuelo Gohan) |
| Dragonthrow | Aprendida en Torneo o entrenamiento (Day 10+) |
| Hasshuken | Copiada del Rey Chappa (evento de torneo) |
| Kyō-ken | Disponible Day 1 (técnica propia de Goku) |
| Taiyoken | Copiada de Tenshinhan (evento de torneo; Day 25+) |
| Nube Voladora | Ítem / evento; requiere `pure_heart = true` |
| Oozaru | Activación automática por evento nocturno si cola presente |

---

## 10. Sinergias y Conflictos

| Habilidad A | Habilidad B | Sinergia |
|---|---|---|
| Desarrollo Acelerado | Zenkai Boost | El Zenkai sólo se activa si HP ≤ 30% → incentiva jugar al límite |
| Mímica Tipo 1 | Kamehameha Copiado | Si el enemigo usa una variante de Kamehameha, Goku la replica con sus propios stats |
| Kyō-ken | Hasshuken | Combo: Kyō-ken baja la guardia → Hasshuken golpea 8 veces con −20% defensa del enemigo |
| Oozaru | Blindaje Saiyajin | El Blindaje escala con el tamaño (en Oozaru reduce daño físico un 20% adicional) |
| Oozaru | Cola (vulnerabilidad) | La mayor debilidad ofensiva. Enemigos con Agarre garantizado pueden activar KO instantáneo |
| Taiyoken | Kamehameha | Combo clásico: cegar al enemigo → disparar Kamehameha sin contraataque posible |
| Bastón Sagrado | Dragonthrow | El Bastón puede usarse para atrapar la cola del enemigo Oozaru desde distancia |
| Sentidos Excepcionales | Taiyoken propio | Goku puede cegar al enemigo pero él mismo no sufre el destello (inmune a su propio Taiyoken) |

---

## 11. Notas de Diseño

- **Goku Saga Pilaf** es la versión más limpia de Goku para nuevos jugadores: sin transformaciones complejas, sin Kaioken, sin costes post-buff. Ideal como personaje tutorial.
- El sistema **Zenkai** debe estar activo desde el inicio para establecer el loop de riesgo-recompensa que define la identidad del personaje.
- La **Oozaru** en este tier solo debería aparecer en combates de historia (Saga Pilaf, Saga Patrulla Roja), nunca como elección del jugador, para mantener la tensión narrativa y el riesgo de la cola.
- Los **stats de Intel Combate altos** desde el inicio reflejan que Goku, incluso de niño, lee el combate mejor que cualquier humano entrenado.
