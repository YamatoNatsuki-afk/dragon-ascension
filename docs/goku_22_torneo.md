# Goku — 22.° Torneo Mundial de Artes Marciales (Dragon Ball Clásico)
**Tier de referencia:** 8-B base · 8-A como Oozaru · hasta 7-A con Kamehameha Cargado
**Raza:** Saiyajin (cola presente)
**Predecesor:** `docs/goku_patrulla_roja.md`
**Contexto:** 3 años de entrenamiento intensivo post-Patrulla Roja bajo Korin y Kami-sama.

---

## 0. Changelog respecto a la Saga Patrulla Roja

| Cambio | Patrulla Roja | 22.° Torneo |
|---|---|---|
| Tier base | 8-B | 8-B (mismo tier, mayor potencia intra-tier) |
| Tier Oozaru | 8-A | 8-A (mismo tier, mayor potencia intra-tier) |
| Tier máximo Kamehameha | 7-A | 7-A (mismo techo) |
| Potencia de ataque | City Block | City Block (superior al valor anterior; 3 años de entrenamiento) |
| Velocidad | Hipersónico+ | Al menos Hipersónico+ (superior a antes) |
| Nivel Ki | Básico → Intermedio | **Avanzado** (salto cualitativo, no solo cuantitativo) |
| Nueva habilidad principal | — | Manipulación del Ki (Avanzado) |
| Nueva mecánica de personaje | — | Alineación Caótico Bueno (efectos en combate y meta-juego) |
| Armamento | Bastón, Nube, Semillas | Igual |

> **Nota de diseño:** El tier no sube, pero la brecha dentro del mismo tier es significativa. Mecánicamente esto se refleja en stats más altos y en el salto de Ki Básico/Intermedio a Ki Avanzado, que desbloquea técnicas cualitativamente diferentes.

---

## 1. Stats Actualizados

| Stat | Patrulla Roja | 22.° Torneo | Notas |
|---|---|---|---|
| Fuerza | 65 | 74 | 3 años de entrenamiento físico continuo |
| Velocidad | 65 | 76 | Al menos Hipersónico+ superior; mayor margen sobre humanos de élite |
| Ki | 52 | 70 | Salto a Ki Avanzado; dominio de aplicaciones refinadas |
| Vitalidad | 62 | 70 | Durabilidad continua (entrenamiento bajo Kami) |
| Resistencia | 58 | 67 | City Block sólido |
| Poder Ki | 50 | 62 | Kamehameha más eficiente; menor tiempo de carga para mismo daño |
| Inteligencia | 38 | 40 | Genio Extraordinario; sin cambio cualitativo |
| Intel Combate | 68 | 78 | Entrenamiento con Kami eleva la lectura de combate |

---

## 2. Manipulación del Ki — Nivel Avanzado

### 2.1 Qué cambia respecto al Ki Básico/Intermedio

El salto a Ki Avanzado no es solo más potencia: Goku aprende a usar el Ki con **precisión quirúrgica**. Esto desbloquea tres categorías nuevas de aplicación.

---

### 2.2 Pasiva: Eficiencia de Ki Refinada

Con Ki Avanzado (Ki ≥ 65), todas las habilidades de Ki tienen:
- Costo de Ki reducido en un 18% adicional (acumulativo con el 10% del nivel Básico → total −28%).
- Recuperación de Ki en combate +25% respecto al nivel Básico.
- El Kamehameha Cargado reduce el tiempo mínimo de cada nivel en 1.0 s (2 s → 1 s, 4 s → 3 s, 7 s → 6 s).

---

### 2.3 Activa: Detectar Ki (Lectura de Aura)

```gdscript
SkillData {
  nombre       = "Detectar Ki"
  tipo         = SkillType.SUPPORT
  descripcion  = "Goku extiende su sentido del Ki para leer el nivel de poder y las intenciones del enemigo."
  requisitos   = { ki: 65, intel_combate: 70 }
  costo_ki     = 8
  cooldown     = 20.0
  duracion     = 15.0
  efectos = [
    Revelar_Stats_Enemigo {
      stats_revelados    = ["poder_ki", "vitalidad_actual", "ki_actual"],
      muestra_contenciones = true    # si el enemigo tiene más poder oculto
    },
    Bonus_Intel_Combate { valor = 10, duracion = 15.0 }
  ]
  notas = "Si el enemigo tiene un poder oculto (transformación disponible, skill reservada), el juego muestra un indicador '??' junto al stat revelado. Esencial para no subestimar a un rival."
}
```

---

### 2.4 Activa: Control de Ki Preciso — Golpe Concentrado

```gdscript
SkillData {
  nombre       = "Golpe de Ki Concentrado"
  tipo         = SkillType.STRIKE
  descripcion  = "Goku concentra todo su Ki en el punto de impacto de un golpe físico, amplificando masivamente el daño en un único contacto."
  requisitos   = { ki: 68, poder_ki: 58, intel_combate: 72 }
  costo_ki     = 30
  cooldown     = 12.0
  efectos = [
    Daño {
      base                 = (fuerza + poder_ki) * 2.2,
      tipo                 = "ki_fisico",
      ignora_escudo_fisico = false,
      ignora_escudo_ki     = true     # penetra barreras de ki por concentración extrema
    },
    Ruptura_Armadura { reduccion_resistencia_enemiga = 0.15, duracion = 8.0 }
  ]
  notas = "La versión refinada del Kiai aplicada al contacto directo. Diferente al Kiai (rango) — este requiere toque físico."
}
```

---

### 2.5 Activa: Supresión de Ki

```gdscript
SkillData {
  nombre       = "Supresión de Ki"
  tipo         = SkillType.SUPPORT
  descripcion  = "Goku comprime su aura de Ki para que no sea detectable. Oculta su nivel de poder real ante enemigos con Detección de Ki."
  requisitos   = { ki: 65, intel_combate: 68 }
  costo_ki     = 12
  cooldown     = 30.0
  duracion     = 20.0
  efectos = [
    Ocultar_Ki {
      ki_aparente          = ki * 0.15,    # muestra solo el 15% del ki real
      bloquea_deteccion    = true,
      bloquea_pep_basico   = true          # PES básica no detecta el ki suprimido
    }
  ]
  condicion_de_ruptura = "Si Goku usa una habilidad Ki ≥ 30 de costo, la supresión se rompe automáticamente."
  notas = "Útil en el meta-juego de día para evitar ser evaluado por NPCs que miden el poder. En combate permite un primer golpe sorpresa."
}
```

---

### 2.6 Activa: Liberación de Ki — Explosión de Aura

```gdscript
SkillData {
  nombre       = "Explosión de Aura"
  tipo         = SkillType.SUPPORT
  descripcion  = "Goku libera una explosión de Ki omnidireccional que empuja a los enemigos cercanos y rompe proyectiles entrantes."
  requisitos   = { ki: 70, poder_ki: 60 }
  costo_ki     = 25
  cooldown     = 15.0
  efectos = [
    AoE_Knockback {
      radio    = 3.0,
      fuerza   = 2.0,
      daño     = poder_ki * 0.8
    },
    Destruir_Proyectiles {
      radio    = 3.0,
      tipos    = ["ki_blast", "fisico_proyectil"]
    }
  ]
  notas = "Contramedida contra Danmaku y múltiples ki blasts simultáneos. No destruye técnicas de área persistente como Zona de Magma."
}
```

---

## 3. Alineación — Caótico Bueno

**Descripción lore:** Goku valora la paz pero busca una buena pelea por encima de todo. Prolonga combates deliberadamente para hacerlos más interesantes. Dejó vivir a Piccolo, a Vegeta, y permitió que Freezer alcanzara su forma final. Sin embargo, tiene un corazón verdaderamente puro (puede montar la Nube Voladora).

### 3.1 Efectos en Combate

| Situación | Efecto mecánico |
|---|---|
| Goku tiene al enemigo a ≤ 20% HP | Aparece opción de diálogo "Dejar vivir" — si se elige, el combate termina con victoria pero el enemigo no queda incapacitado permanentemente |
| El jugador elige "Dejar vivir" | El enemigo puede reaparecer en combates futuros con Zenkai (más fuerte). Riesgo narrativo real. |
| El jugador elige "Dejar vivir" con un jefe de historia | Desbloquea ruta de historia alternativa (p.ej. Piccolo comme aliado eventual) |
| Goku detecta que el enemigo está conteniendo poder | Puede provocar al enemigo para que libere su potencial (botón de "provocar") antes de la batalla real |
| Goku usa Supresión de Ki frente a un enemigo fuerte | El enemigo subestima a Goku; comienza el combate sin transformaciones activas |

### 3.2 Mecánica "Alargar la Pelea"

Goku puede deliberadamente usar acciones sub-óptimas para extender el combate (mecánica opcional de roleplay):

```gdscript
MecánicaCarácter {
  nombre = "Caótico Bueno — Combatiente de Corazón"
  efecto_pasivo = {
    # Si Goku podría terminar el combate con un golpe final pero no lo hace (pasa turno):
    # → gana 1 stack de "Emoción del Combate"
    # Cada stack: +3% a todos los stats (máx 5 stacks = +15%)
    # Los stacks se pierden al terminar el combate
    stacks_emocion_maximos = 5,
    bonus_por_stack        = 0.03
  }
}
```

### 3.3 Efectos en el Meta-juego de Día

| Acción de día | Modificador por alineación |
|---|---|
| Negociar con NPCs de alineación Neutral o Buena | +15% probabilidad de éxito (corazón puro) |
| Negociar con NPCs de alineación Maliciosa | −10% (Goku no es diplomático con los que él considera que están mal) |
| Provocar a rivales para combates de entrenamiento | Disponible solo para Goku; otros personajes no tienen esta opción |
| Usar Nube Voladora | Disponible solo si `pure_heart = true` (Alineación Buena activa) |
| Montar guardia o huir de un conflicto | Goku sufre penalización de "aburrimiento": −5% a Intel Combate hasta el próximo combate |

---

## 4. Escalado de Técnicas Existentes

### 4.1 Kamehameha (reducción de tiempos de carga)

Con Ki Avanzado (pasiva), los tiempos del Kamehameha Cargado bajan 1 s por nivel:

| Nivel | Tiempo Patrulla Roja | Tiempo 22.° Torneo | Tier |
|---|---|---|---|
| Básico | 2.0 s | 1.0 s | City Block |
| Medio | 4.0 s | 3.0 s | Multi-City Block |
| Máximo | 7.0 s | 6.0 s | Montaña (7-A) |

### 4.2 Kiai — Versión Mirada (mejorada)

Con Intel Combate 78, la versión de mirada del Kiai ya no requiere condición adicional y tiene cooldown reducido:

```gdscript
Kiai_Mirada {
  requisitos  = { intel_combate: 70 },   # antes requería 40
  cooldown    = 2.0,                     # igual que antes
  efectos     = [
    Daño    { base = poder_ki * 1.1 },   # +0.2 respecto a versión Patrulla Roja
    Stagger { duracion = 0.5 }
  ]
}
```

### 4.3 Detectar Contenciones (mejora de Intel Combate pasiva)

Con Intel Combate ≥ 75 (antes el umbral era 68), Goku puede detectar contenciones **sin gastar la acción de "Detectar Ki"**:
- El juego muestra automáticamente un indicador visual si el enemigo está usando menos del 60% de su poder real.
- Esto hace que la mecánica de "Alargar la Pelea" sea más relevante: Goku sabe cuándo el rival puede dar más.

---

## 5. Adquisición de Nuevas Habilidades

| Habilidad | Método |
|---|---|
| Manipulación del Ki Avanzado (pasiva) | Desbloqueada automáticamente al alcanzar Ki ≥ 65 tras 3 años de entrenamiento (evento de historia: "Entrenamiento con Kami") |
| Detectar Ki | Disponible tras desbloquear Ki Avanzado; Ki ≥ 65 + Intel Combate ≥ 70 |
| Golpe de Ki Concentrado | Ki ≥ 68 + Poder Ki ≥ 58 + Intel Combate ≥ 72 |
| Supresión de Ki | Ki ≥ 65 + Intel Combate ≥ 68 |
| Explosión de Aura | Ki ≥ 70 + Poder Ki ≥ 60 |
| Mecánica Caótico Bueno | Activada automáticamente para Goku; no es una habilidad aprendible por otros personajes |

---

## 6. Sinergias Nuevas

| Habilidad A | Habilidad B | Sinergia |
|---|---|---|
| Supresión de Ki | Kamehameha Cargado | El enemigo no detecta la acumulación de Ki durante la carga; el blast llega como sorpresa total |
| Detectar Ki | Mecánica "Alargar la Pelea" | Goku sabe cuándo el enemigo tiene poder oculto → lo provoca deliberadamente → acumula stacks de Emoción mientras el rival se transforma |
| Explosión de Aura | Imagen Residual | Imagen distrae → enemigo lanza ataque → Explosión de Aura al contacto destruye el ataque y lanza al enemigo |
| Golpe de Ki Concentrado | Dragonthrow | Dragonthrow inmoviliza → Golpe Concentrado en el punto de impacto con el suelo (daño combinado) |
| Supresión de Ki | Kyō-ken | Doble confusión: el enemigo ve un poder bajo Y un comportamiento errático; probabilidad de Kyō-ken sube al 95% sin importar la Intel Combate del rival |
| Detectar Contenciones (pasiva) | "Dejar vivir" | Goku detecta poder oculto → elige dejar vivir → el rival regresa con ese poder desbloqueado → mayor desafío futuro (loop de narrativa) |

---

## 7. Notas de Diseño

- **Ki Avanzado es un salto cualitativo**, no solo cuantitativo. La diferencia con Ki Básico en juego debe ser visible: las nuevas habilidades (Detectar Ki, Supresión, Explosión de Aura) no existían antes sin importar cuántos stats se tuvieran.
- **La mecánica Caótico Bueno** es la principal aportación de diseño de este perfil. Es el rasgo de carácter más definitorio de Goku y debería ser uno de los diferenciadores clave de jugar como él versus otros personajes. El riesgo de "dejar vivir" crea momentos de narrativa emergente que otros personajes no generan.
- **Los stacks de Emoción del Combate** recompensan al jugador por jugar de manera sub-óptima y "divertida", que es exactamente como Goku pelea. Es un incentivo mecánico que refuerza la identidad del personaje.
- **Supresión de Ki** abre opciones tácticas en el meta-juego de día: Goku puede infiltrarse en eventos o zonas sin ser identificado como una amenaza de alto poder. Esto es relevante si el sistema de día tiene NPCs que reaccionan al nivel de poder del jugador.
- La **Detección de Contenciones pasiva** a Intel Combate ≥ 75 es un lujo de información que pone a Goku en una posición meta-estratégica única: sabe más del estado real del enemigo que cualquier otro personaje sin gastar acciones.
