# Dragon Ascension — Habilidades: Pasivas, Activas y Obtención

> Referencia de diseño para las 8 habilidades del sistema de progresión.
> Stats del juego: fuerza · velocidad · ki · vitalidad · resistencia · poder_ki · inteligencia · intel_combate

---

## 1. Maestría en Armas

**Descripción:** Dominio total sobre toda clase de armas. El usuario posee experiencia sobrehumana en el uso de pistolas, espadas, rifles, explosivos y vehículos de combate. El grado de maestría se refleja directamente en intel_combate.

---

### Pasivas

| Nombre | Efecto |
|--------|--------|
| **Ojo de Francotirador** | +20% de daño en todos los ataques a distancia. Escala con intel_combate. |
| **Movimiento de Arma** | Reducción del 30% en la penalización de precisión al atacar en movimiento. |
| **Mano Firme** | Los Ki Blasts del jugador tienen un 15% menos de probabilidad de ser esquivados por el enemigo. |
| **Arsenal Instintivo** | Cambiar entre modos de ataque (cuerpo a cuerpo / Ki Blast) no genera cooldown adicional. |
| **Lectura del Objetivo** | Cada hit consecutivo sobre el mismo enemigo aumenta el daño en +3% (máx. +30%). Se reinicia al recibir daño. |

---

### Habilidades Activas

#### DISPARO DE PRECISIÓN *(KI_BLAST — Combate)*
> Apunta al punto débil del objetivo con una concentración extrema.
- **Costo de Ki:** 18% del Ki máximo
- **Daño:** ×1.8 sobre poder_ki
- **Hit Count:** 1
- **Efecto especial:** Ignora el 60% de la resistencia del enemigo
- **Cooldown:** 4.0s
- **Requisito de equipo:** intel_combate ≥ 80

#### LLUVIA DE BALAS *(ULTIMATE — Ranged)*
> Descarga simultánea de múltiples proyectiles. Incontrolable e imparable.
- **Costo de Ki:** 45% del Ki máximo
- **Daño:** ×0.6 sobre poder_ki por proyectil
- **Hit Count:** 9
- **is_ranged:** true
- **Efecto especial:** Cada hit tiene 20% de reducir el Ki del enemigo en 5%
- **Cooldown:** 14.0s
- **Requisito de equipo:** poder_ki ≥ 120, intel_combate ≥ 100

#### TIRO A LA CABEZA *(STRIKE — Físico)*
> Un único golpe fulminante al punto más vulnerable del oponente.
- **Costo de Ki:** 10%
- **Daño:** ×3.5 sobre fuerza
- **Hit Count:** 1
- **Efecto especial:** Si el enemigo tiene menos del 30% HP, garantiza un crítico (daño ×2)
- **Cooldown:** 7.0s
- **Requisito de equipo:** fuerza ≥ 100, intel_combate ≥ 90

---

### Cómo Obtenerlo

| Método | Condición |
|--------|-----------|
| **Acción de día:** "Entrenamiento con Armas" | Disponible desde el día 3. Sube intel_combate +2/+3 con riesgo de accidente. |
| **NPC: Armero del Mercado** | Relación media (≥40%). Desbloquea entrenamiento de precisión: +1 intel_combate garantizado. |
| **NPC: Mercenario Veterano** | Relación alta (≥70%). Enseña Disparo de Precisión y Tiro a la Cabeza. |
| **Flag de supervivencia** | Haber ganado 3 combates con HP ≤ 15% → desbloquea Lluvia de Balas. |
| **Checkpoint Día 25** | Si intel_combate ≥ 80, se otorga la pasiva "Lectura del Objetivo" permanentemente. |

---
---

## 2. Capacidades Físicas Sobrehumanas

**Descripción:** Velocidad, fuerza o resistencia que excede todo límite humano. Moverse más rápido de lo que el ojo puede ver, cargar más de 454 kg, soportar fuerzas que destruirían a cualquier ser normal.

---

### Pasivas *(se activan al superar umbrales de stat)*

| Nombre | Umbral | Efecto |
|--------|--------|--------|
| **Movimiento Sobrehumano** | velocidad ≥ 150 | +25% dodge. Los ataques del enemigo tienen 0.15s adicionales de telegraph. |
| **Puño de Hierro** | fuerza ≥ 200 | Los ataques físicos tienen 15% de chance de derribo (el enemigo pierde su turno). |
| **Cuerpo Irrompible** | resistencia ≥ 200 | Inmunidad a aturdimiento. Daño mínimo por hit nunca baja de 1. |
| **Presencia Aplastante** | fuerza + resistencia ≥ 450 | El enemigo pierde 5% de daño cada vez que recibe un golpe (se acumula, máx. -40%). |
| **Masa Crítica** | vitalidad ≥ 250 | HP máximo ×1.30. La barra de HP regenera 0.5% por segundo en combate. |

---

### Habilidades Activas

#### GOLPE DEVASTADOR *(STRIKE — Físico)*
> La concentración total de la fuerza del cuerpo en un solo impacto. El suelo tiembla.
- **Costo de Ki:** 25%
- **Daño:** ×4.0 sobre fuerza
- **Hit Count:** 1
- **Efecto especial:** Knockback extremo. Si el enemigo choca con el límite del mapa, recibe 20% de su HP máximo como daño adicional.
- **Cooldown:** 9.0s
- **Requisito de equipo:** fuerza ≥ 200

#### CARRERA SUPERSÓNICA *(SUPPORT — Buff)*
> El usuario rompe la barrera del sonido. Imposible de seguir con la vista.
- **Costo de Ki:** 20%
- **Efecto:** +120% velocidad de movimiento por 6 segundos. Durante ese tiempo, el dodge se vuelve gratuito (sin cooldown).
- **Cooldown:** 16.0s
- **Requisito de equipo:** velocidad ≥ 150

#### MURALLA DE ACERO *(SUPPORT — Defensa)*
> El usuario endurece cada músculo al máximo. Nada lo mueve.
- **Costo de Ki:** 15%
- **Efecto:** Reduce el daño recibido en 80% durante los próximos 3 golpes. Al terminar, recupera Ki equivalente al daño absorbido ×0.3.
- **Cooldown:** 12.0s
- **Requisito de equipo:** resistencia ≥ 200, vitalidad ≥ 150

#### EXPLOSIÓN DE PODER *(ULTIMATE)*
> El usuario libera toda su energía física en una sola explosión.
- **Costo de Ki:** 60%
- **Daño:** ×5.5 sobre fuerza + ×1.5 sobre velocidad
- **Hit Count:** 3
- **Efecto especial:** Si el enemigo queda con menos del 20% HP, lo derriba permanentemente hasta el fin del combate.
- **Cooldown:** 20.0s
- **Requisito:** fuerza ≥ 200 + velocidad ≥ 150 + resistencia ≥ 200

---

### Cómo Obtenerlo

| Método | Condición |
|--------|-----------|
| **Desbloqueo automático por umbrales** | Cada pasiva se activa al superar su umbral de stat. No requiere acción. |
| **Acción de día:** "Entrenamiento Extremo" | Disponible día 10+. Riesgo de lesión pero ganancias de fuerza/vitalidad/resistencia muy altas. |
| **Checkpoint Día 20: "Primera Muestra de Poder"** | Si cualquier stat físico ≥ 150, se otorga la pasiva "Presencia Aplastante" desbloqueada antes del umbral. |
| **NPC: Maestro de Resistencia** | Relación alta (≥65%). Entrena un stat físico +2 por día, sin riesgo de lesión. |
| **Minijuego: Levantamiento** | Accesible desde día 8. Subir récord otorga fuerza o resistencia permanente. |

---
---

## 3. Artes Marciales

**Descripción:** Técnicas de ataque y defensa personal que llevan el cuerpo humano más allá de sus límites. Kickboxing, Taekwondo, Kendo, Ninjutsu, Muay Thai, Jiu Jitsu, Aikido y más.

---

### Pasivas

| Nombre | Efecto |
|--------|--------|
| **Ritmo de Combate** | Cada hit del combo aumenta el daño del siguiente en +12% (máx. +60%). Se pierde al romper el combo. |
| **Técnica Depurada** | +20% dodge. Escala con intel_combate: intel_combate ≥ 100 → +30%. |
| **Golpe Preciso** | Los ataques físicos ignorar 15% de la resistencia del enemigo. |
| **Reflexos de Luchador** | Reduce el cooldown base de ataque en 20%. |
| **Lectura del Cuerpo** | Cuando el enemigo intenta un ataque, hay un 15% de activar contraataque automático gratis. |

---

### Habilidades Activas

#### KATA EXPLOSIVA *(STRIKE — 4 hits)*
> Secuencia milimétrica de golpes que culmina en un impacto rompedor de guardia.
- **Costo de Ki:** 22%
- **Daño:** ×0.7 los primeros 3 hits, ×2.0 el cuarto hit
- **Hit Count:** 4
- **Efecto especial:** El cuarto hit anula la siguiente esquiva del enemigo.
- **Cooldown:** 5.5s
- **Requisito:** intel_combate ≥ 70

#### BARRIDO DE PIERNA *(STRIKE — Derribo)*
> Un barrido bajo e inesperado que tira al enemigo al suelo, abriendo una ventana de ataque.
- **Costo de Ki:** 12%
- **Daño:** ×1.5 sobre fuerza
- **Hit Count:** 1
- **Efecto especial:** Derriba al enemigo por 2 segundos. Durante ese tiempo, el cooldown del jugador es 0.
- **Cooldown:** 8.0s
- **Requisito:** fuerza ≥ 90, velocidad ≥ 80

#### CONTRAATAQUE PERFECTO *(SUPPORT — Reacción)*
> El usuario entra en un estado de alerta total. Si recibe un golpe, el cuerpo reacciona solo.
- **Costo de Ki:** 18%
- **Efecto:** Por los próximos 1.5 segundos, si recibes daño, automáticamente contraatacas con ×2.5 de fuerza. El contraataque no tiene cooldown.
- **Cooldown:** 10.0s
- **Requisito:** intel_combate ≥ 90, velocidad ≥ 100

#### TORMENTA DE GOLPES *(ULTIMATE — Combo)*
> El usuario desata una racha imposible de seguir. Nadie puede esquivar todos los golpes.
- **Costo de Ki:** 55%
- **Daño:** ×0.5 por hit, ×3.0 el último hit
- **Hit Count:** 12
- **Efecto especial:** Cada hit tiene 40% de no poder ser esquivado.
- **Cooldown:** 18.0s
- **Requisito:** intel_combate ≥ 120, fuerza ≥ 150, velocidad ≥ 120

---

### Cómo Obtenerlo

| Método | Condición |
|--------|-----------|
| **Acción de día:** "Entrenamiento Marcial" | Desde día 1. Sube intel_combate y velocidad. La versión mejorada aparece en día 15+. |
| **NPC: Maestro Roshi** | Relación media (≥50%). Enseña Kata Explosiva y Barrido de Pierna. |
| **NPC: Maestro Dojo** | Relación alta (≥75%). Enseña Contraataque Perfecto y Tormenta de Golpes. |
| **Minijuego: Secuencia Direccional** | Completar con A+ desbloquea pasiva "Ritmo de Combate". |
| **Checkpoint Día 35** | Si intel_combate ≥ 100 + haber ganado 5 combates, se activa la pasiva "Reflexos de Luchador". |

---
---

## 4. Acrobacia

**Descripción:** Control absoluto del propio cuerpo en el espacio. El usuario puede correr por paredes, saltar varias veces en el aire, ignorar superficies irregulares y manipular su propia inercia.

---

### Pasivas

| Nombre | Efecto |
|--------|--------|
| **Cuerpo Ligero** | +30% velocidad de movimiento en combate. |
| **Eficiencia de Vuelo** | El estado FlyState consume 35% menos Ki por segundo. |
| **Esquiva Aérea** | En el aire, el dodge tiene un 25% adicional de éxito. |
| **Sin Punto Ciego** | Inmune a ataques por la espalda y a bonus de posicionamiento del enemigo. |
| **Aceleración Instantánea** | El primer movimiento de cada combate es instantáneo (sin animación de inicio). |

---

### Habilidades Activas

#### DASH AÉREO *(STRIKE — Físico + Reposicionamiento)*
> El usuario se lanza como un rayo a la posición del enemigo y lo golpea al llegar.
- **Costo de Ki:** 16%
- **Daño:** ×2.2 sobre velocidad
- **Hit Count:** 1
- **Efecto especial:** El movimiento es imposible de esquivar si se activa desde el aire.
- **Cooldown:** 4.0s
- **Requisito:** velocidad ≥ 100

#### PARKOUR OFENSIVO *(STRIKE — Multi-hit)*
> El usuario rebota por el terreno con una velocidad imposible, golpeando desde ángulos inesperados.
- **Costo de Ki:** 28%
- **Daño:** ×1.2 por rebote
- **Hit Count:** 4
- **Efecto especial:** Cada hit viene de un ángulo diferente, reduciendo el dodge del enemigo en 10% por hit acumulado.
- **Cooldown:** 7.0s
- **Requisito:** velocidad ≥ 130

#### ESQUIVA PERFECTA *(SUPPORT — Invulnerabilidad corta)*
> Un instante de movimiento tan preciso que ningún ataque puede conectar.
- **Costo de Ki:** 20%
- **Efecto:** 1.2 segundos de esquiva garantizada. Cualquier ataque que llegue durante ese tiempo falla. Al terminar, el siguiente ataque del jugador tiene ×1.8 de daño.
- **Cooldown:** 9.0s
- **Requisito:** velocidad ≥ 120, intel_combate ≥ 80

#### CAÍDA LIBRE CONTROLADA *(ULTIMATE — Área)*
> El usuario sube extremadamente alto y cae como un meteorito sobre el enemigo.
- **Costo de Ki:** 40%
- **Daño:** ×6.0 sobre velocidad + ×2.0 sobre fuerza
- **Hit Count:** 1
- **Efecto especial:** No puede ser esquivado. Si el enemigo tiene el buff de guardia activo, lo elimina.
- **Cooldown:** 16.0s
- **Requisito:** velocidad ≥ 150, vitalidad ≥ 100

---

### Cómo Obtenerlo

| Método | Condición |
|--------|-----------|
| **Acción de día:** "Entrenamiento de Agilidad" | Requiere velocidad ≥ 80 para desbloquearla. Sube velocidad y ki. |
| **Minijuego: Snake Road** | Completar con B o superior desbloquea "Cuerpo Ligero". Con A+ desbloquea "Eficiencia de Vuelo". |
| **Minijuego: Dodge** | Completar 10 rondas sin recibir impacto → desbloquea "Esquiva Aérea" como pasiva. |
| **NPC: Maestro de Movimiento** | Relación media (≥50%). Enseña Dash Aéreo y Parkour Ofensivo. |
| **Checkpoint Día 15** | Si velocidad ≥ 100, se desbloquea el modo de vuelo sin costo adicional de Ki. |

---
---

## 5. Intelecto de Genio

**Descripción:** Capacidad excepcional de conocimiento e inteligencia aplicada al combate y la estrategia. Un genio puede dominar campos tan distintos como la física, la táctica militar, las artes marciales teóricas y la investigación en tiempo récord.

---

### Pasivas

| Nombre | Efecto |
|--------|--------|
| **Mente Analítica** | +30% XP de todas las acciones de día (entrenamiento, eventos, minijuegos). |
| **Aprendizaje Acelerado** | Las acciones de entrenamiento dan +1 punto de stat adicional al resultado. |
| **Estratega Nato** | intel_combate cuenta como ×1.5 para todas las fórmulas de dodge y contraataque. |
| **Lectura del Enemigo** | En combate, siempre visible el porcentaje de Ki actual del enemigo en el HUD. |
| **Anticipación** | 0.4 segundos antes de que el enemigo ataque, aparece una señal visual. Aumenta tiempo de reacción efectivo. |

---

### Habilidades Activas

#### ANÁLISIS DE COMBATE *(SUPPORT — Debuff de información)*
> El usuario estudia al oponente con precisión clínica, encontrando todos sus puntos débiles.
- **Costo de Ki:** 15%
- **Efecto:** Durante 12 segundos, los stats completos del enemigo son visibles en el HUD. Los ataques del jugador hacen +20% de daño adicional.
- **Cooldown:** 20.0s
- **Requisito:** inteligencia ≥ 100

#### TÁCTICA MAESTRA *(SUPPORT — Buff de timing)*
> El usuario calcula el momento exacto del contragolpe perfecto.
- **Costo de Ki:** 22%
- **Efecto:** El siguiente ataque del jugador no tiene cooldown y su daño es ×2.0. Si se combina con un ataque Ultimate, el multiplicador sube a ×2.5.
- **Cooldown:** 14.0s
- **Requisito:** intel_combate ≥ 110, inteligencia ≥ 90

#### PUNTO DÉBIL *(STRIKE — Penetración)*
> Un ataque milimétrico al nervio exacto. No importa lo dura que sea la armadura.
- **Costo de Ki:** 20%
- **Daño:** ×2.8 sobre fuerza + ×1.0 sobre intel_combate
- **Hit Count:** 1
- **Efecto especial:** Ignora el 90% de la resistencia del enemigo.
- **Cooldown:** 8.0s
- **Requisito:** inteligencia ≥ 120, intel_combate ≥ 100

#### MAESTRÍA TOTAL *(ULTIMATE — Campo de control)*
> El usuario entra en un estado de claridad absoluta. Cada movimiento es perfecto.
- **Costo de Ki:** 50%
- **Efecto:** Durante 8 segundos, todos los ataques del jugador son ×1.5, el dodge es 100% efectivo, y los cooldowns se reducen a la mitad.
- **Cooldown:** 25.0s
- **Requisito:** inteligencia ≥ 150, intel_combate ≥ 130

---

### Cómo Obtenerlo

| Método | Condición |
|--------|-----------|
| **Acción de día:** "Estudio y Meditación" | Desde día 1. Sube inteligencia e intel_combate. Acumulable con "Lectura Avanzada" (día 20+). |
| **Acción de día:** "Análisis de Combate" | Desde día 15. Basada en revisar los propios combates. Sube intel_combate fuertemente. |
| **NPC: Científico / Maestro del Conocimiento** | Relación media (≥45%). Sube inteligencia +3 por visita. |
| **Checkpoint Día 30** | Si inteligencia ≥ 120, se otorga "Mente Analítica" y "Aprendizaje Acelerado". |
| **Minijuego: Ki Channel** | Completar con A+ desbloquea "Anticipación" como pasiva. |

---
---

## 6. Sentidos Mejorados

**Descripción:** Sentidos físicos que superan los de cualquier humano normal. Vista, oído, olfato, tacto y sentidos adicionales como la percepción del Ki o la detección de peligro inminente.

---

### Pasivas

| Nombre | Efecto |
|--------|--------|
| **Detección de Ki** | La barra de Ki del enemigo siempre es visible en el HUD de combate. |
| **Sentido del Peligro** | +15% dodge. Si el dodge falla por menos de un 5%, igualmente se activa a medias (daño reducido 50%). |
| **Sin Punto Ciego** | Inmune a bonus de posicionamiento enemigo (ataques por la espalda no tienen bonus de daño). |
| **Radar de Intención** | 0.5 segundos antes de que el enemigo use una habilidad Ultimate, aparece un indicador visual. |
| **Eco del Entorno** | En combate, el jugador siempre sabe la posición exacta del enemigo incluso si este se desplaza fuera del campo de visión. |

---

### Habilidades Activas

#### DETECCIÓN TOTAL *(SUPPORT — Scouting)*
> El usuario expande su percepción a todo el campo de batalla. Nada escapa.
- **Costo de Ki:** 12%
- **Efecto:** Durante 10 segundos, todos los próximos ataques del enemigo son telegrafíados 0.8 segundos antes. El dodge automáticamente tiene +30% de éxito.
- **Cooldown:** 18.0s
- **Requisito:** ki ≥ 80

#### SENTIDO DEL COMBATE *(SUPPORT — Predicción)*
> El usuario entra en un estado de alerta máxima. El peligro no puede sorprenderle.
- **Costo de Ki:** 25%
- **Efecto:** El primer ataque que recibirías en los próximos 3 segundos es automáticamente esquivado (100% de éxito). El contraataque posterior tiene ×1.8 de daño.
- **Cooldown:** 12.0s
- **Requisito:** ki ≥ 100, intel_combate ≥ 80

#### TIEMPO EXPANDIDO *(SUPPORT — Bullet Time)*
> Por un instante, el cerebro del usuario procesa todo a velocidad imposible.
- **Costo de Ki:** 30%
- **Efecto:** El tiempo del combate se ralentiza al 30% durante 2.5 segundos. El jugador actúa a velocidad normal. El daño durante este efecto tiene ×1.4.
- **Cooldown:** 20.0s
- **Requisito:** velocidad ≥ 120, ki ≥ 120, intel_combate ≥ 90

#### PERCEPCIÓN OMNISCIENTE *(ULTIMATE — Pasiva temporal)*
> El usuario percibe absolutamente todo durante un lapso de tiempo. Es imposible fallar.
- **Costo de Ki:** 55%
- **Efecto:** Durante 6 segundos, el dodge es 100% garantizado, los ataques no pueden errar, y cada golpe del jugador reduce el Ki del enemigo en 8%.
- **Cooldown:** 22.0s
- **Requisito:** ki ≥ 150, intel_combate ≥ 120

---

### Cómo Obtenerlo

| Método | Condición |
|--------|-----------|
| **Acción de día:** "Meditación Profunda" | Requiere ki ≥ 60. Sube ki y levemente intel_combate. |
| **Acción de día:** "Entrenamiento de Percepción" | Disponible día 20+. Alta subida de intel_combate. |
| **NPC: Kami / Ser Espiritual** | Relación alta (≥70%). Desbloquea "Radar de Intención" y "Sentido del Combate". |
| **Checkpoint Día 15: "El Mundo Te Habla"** | Si ki ≥ 80, se activa "Detección de Ki" y "Sentido del Peligro" como pasivas. |
| **Raza: Namekiano** | Nivel 1 de Sentidos Mejorados gratuito al crear el personaje. |
| **Minijuego: Apple / Reacción** | Completar con A+ desbloquea "Sin Punto Ciego". |

---
---

## 7. Desarrollo Acelerado

**Descripción:** La capacidad de aumentar habilidades o estadísticas en una fracción del tiempo normal. Algunos personajes mejoran durante el entrenamiento, otros en combate, otros simplemente al existir.

---

### Pasivas *(según tipo)*

| Nombre | Tipo | Efecto |
|--------|------|--------|
| **Talento Natural** | Tipo 1 — Entrenamiento | +35% a las ganancias de stat de todas las acciones de entrenamiento. |
| **Filo de la Batalla** | Tipo 2 — Batalla | Ganar un combate otorga +3% a fuerza y velocidad hasta fin del run (acumulable, máx. +30%). |
| **Espíritu Saiyan** | Tipo 2 — Batalla | Al quedar con HP ≤ 15% y sobrevivir el combate, +8% permanente a todos los stats base. Solo activa una vez por combate. |
| **Subida de Nivel Mejorada** | Tipo 3 — Nivel | Cada nivel subido otorga 1 punto de stat adicional (+1 al repartidor normal). |
| **Evolución Reactiva** | Tipo 4 — Evolución | Recibir el mismo tipo de daño 3 veces en un combate reduce ese daño un 15% de forma acumulable. |
| **Crecimiento Pasivo** | Tipo 5 — Pasivo | +1 a un stat aleatorio por cada 5 días que pasan, independientemente de las acciones. |

---

### Habilidades Activas

#### MODO SUPERACIÓN *(SUPPORT — Buff progresivo)*
> El usuario se niega a rendirse. Cada golpe que recibe lo hace más peligroso.
- **Costo de Ki:** 20%
- **Efecto:** Durante 25 segundos, cada golpe recibido aumenta el daño de salida en +8% (máx. +80%).
- **Cooldown:** 18.0s
- **Requisito:** vitalidad ≥ 100

#### ADRENALINA DE COMBATE *(SUPPORT — Burst)*
> Una explosión de energía pura que lleva el cuerpo al límite absoluto.
- **Costo de Ki:** 30%
- **Efecto:** +50% a todos los stats durante 8 segundos. Al terminar, el jugador sufre -20% de daño de salida durante 5 segundos (fatiga).
- **Cooldown:** 20.0s
- **Requisito:** fuerza ≥ 120, vitalidad ≥ 120

#### LÍMITE ROTO *(ULTIMATE — Desesperación)*
> Solo cuando la muerte parece inevitable, el verdadero poder despierta.
- **Costo de Ki:** 0 (solo disponible con HP ≤ 20%)
- **Daño:** ×8.0 sobre todos los stats combinados
- **Hit Count:** 1
- **Efecto especial:** No tiene cooldown. Puede usarse una sola vez por combate. Recupera 30% de HP al conectar.
- **Requisito:** vitalidad ≥ 150 o raza Saiyan

#### ENTRENAMIENTO RECORD *(SUPPORT — Fuera de combate, en el loop diario)*
> El usuario comprime el esfuerzo de una semana en una sola sesión devastadora.
- **Efecto:** Acción de día especial. Gana el triple de stats que el entrenamiento normal, pero se pierde un día adicional de recuperación.
- **Requisito:** Desarrollo Acelerado activo + día par del run

---

### Cómo Obtenerlo

| Método | Condición |
|--------|-----------|
| **Raza: Saiyan** | "Filo de la Batalla" y "Espíritu Saiyan" activos desde el inicio del run. |
| **Acción de día:** "Entrenamiento Hasta el Límite" | Requiere vitalidad ≥ 100. Riesgo de lesión. Desbloquea "Talento Natural" tras 5 sesiones. |
| **Checkpoint Día 50: "El Límite Es el Comienzo"** | Si hubo al menos 1 activación de "Espíritu Saiyan" o se superaron 3 combates desde HP bajo → desbloquea Límite Roto. |
| **Checkpoint Día 40** | Si nivel ≥ 15, se activa "Subida de Nivel Mejorada". |
| **Flag: Victorias Consecutivas** | Ganar 5 combates seguidos → activa "Crecimiento Pasivo". |

---
---

## 8. Invocación

**Descripción:** La capacidad de llamar a seres de otros planos, dimensiones o mundos para que luchen junto al usuario. Los seres invocados pueden ser entidades mágicas, espíritus, guerreros aliados o incluso objetos de poder.

---

### Pasivas

| Nombre | Efecto |
|--------|--------|
| **Vínculo Espiritual** | Los seres invocados tienen stats equivalentes al 35% de los stats del invocador. |
| **Contrato Reforzado** | Puede haber hasta 2 aliados invocados activos simultáneamente. |
| **Resonancia de Ki** | Mientras haya un ser invocado activo, el Ki del jugador regenera un 10% adicional por segundo. |
| **Devolución de Daño** | Cuando un aliado invocado es destruido, el 40% del daño de su HP se devuelve al enemigo. |
| **Maestro Invocador** | Las habilidades de invocación cuestan 20% menos Ki. |

---

### Habilidades Activas

#### INVOCAR ALIADO *(SUPPORT — Montura/Aliado)*
> El usuario abre un portal y llama a un ser aliado que combate de forma autónoma.
- **Costo de Ki:** 30%
- **Efecto:** Aparece un aliado invocado con HP = 40% del HP máximo del jugador. Ataca al enemigo cada 2.5 segundos con daño equivalente al 25% del daño del jugador. Dura hasta que es eliminado o el combate termina.
- **Cooldown:** 12.0s
- **Requisito:** ki ≥ 100, poder_ki ≥ 80

#### ESCUDO DEL INVOCADO *(SUPPORT — Sacrificio)*
> El aliado invocado se interpone para proteger al invocador del siguiente golpe.
- **Costo de Ki:** 18%
- **Efecto:** El siguiente ataque que recibirías es absorbido por el ser invocado. Si no hay uno activo, se invoca uno momentáneo específicamente para absorber ese golpe.
- **Cooldown:** 10.0s
- **Requisito:** Necesita Invocar Aliado desbloqueado

#### LLUVIA DE ALIADOS *(ULTIMATE — Swarm)*
> El invocador abre múltiples portales a la vez, inundando el campo de batalla.
- **Costo de Ki:** 65%
- **Daño:** ×1.5 por invocación × 5 invocaciones
- **Hit Count:** 5 (uno por aliado)
- **Efecto especial:** Los 5 aliados atacan al mismo tiempo. Cada uno tiene 30% de ignorar el dodge del enemigo.
- **Cooldown:** 22.0s
- **Requisito:** ki ≥ 180, poder_ki ≥ 150, inteligencia ≥ 100

#### PACTO SUPREMO *(ULTIMATE — Jefe invocado)*
> El invocador llama al ser más poderoso de su contrato. Una presencia que hace temblar el suelo.
- **Costo de Ki:** 80% (consumo total si el Ki es menor)
- **Daño:** ×10.0 sobre poder_ki
- **Hit Count:** 1
- **Efecto especial:** Imposible de esquivar. Reduce la resistencia del enemigo a 0 durante 5 segundos.
- **Cooldown:** 30.0s
- **Requisito:** Haber completado el Contrato de Invocación Suprema (flag especial)

---

### Cómo Obtenerlo

| Método | Condición |
|--------|-----------|
| **Las 7 Esferas del Dragón** | Recolectar las 7 durante el run (acciones de día especiales desde día 20+). Desbloquea "Invocar Aliado" y la pasiva "Vínculo Espiritual". |
| **NPC: Espíritu Guardian** | Relación alta (≥80%). Establece un contrato de invocación básico. Desbloquea "Escudo del Invocado". |
| **NPC: Dios de la Destrucción** | Relación máxima (≥95%). Desbloquea "Pacto Supremo" y "Maestro Invocador". |
| **Flag: Alianza Guerrera** | Completar la misión de alianza con otro guerrero (NPC de relación máxima) → desbloquea "Contrato Reforzado". |
| **Checkpoint Día 60** | Si ki ≥ 150 + poder_ki ≥ 120 + haber obtenido al menos 3 esferas → desbloquea "Lluvia de Aliados". |

---

## Resumen de Requisitos de Stats

| Habilidad | Stats principales | Día mínimo sugerido |
|-----------|------------------|---------------------|
| Maestría en Armas | intel_combate, poder_ki | 3 |
| Capacidades Sobrehumanas | fuerza, velocidad, resistencia, vitalidad | 10 |
| Artes Marciales | intel_combate, velocidad, fuerza | 1 |
| Acrobacia | velocidad, ki | 1 |
| Intelecto de Genio | inteligencia, intel_combate | 1 |
| Sentidos Mejorados | ki, intel_combate | 15 |
| Desarrollo Acelerado | vitalidad, fuerza | 20 (o Saiyan) |
| Invocación | ki, poder_ki, inteligencia | 20 |
