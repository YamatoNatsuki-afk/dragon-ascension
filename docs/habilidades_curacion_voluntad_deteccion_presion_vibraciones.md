# Dragon Ascension — Curación · Voluntad · Detección · Puntos de Presión · Vibraciones
> Stats clave: fuerza · velocidad · ki · vitalidad · resistencia · poder_ki · inteligencia · intel_combate

---

## 1. Curación

**Descripción:** La capacidad de restaurar la salud de organismos vivos. A diferencia de la Regeneración (que es pasiva e involuntaria), la Curación es activa y puede aplicarse tanto a uno mismo como a aliados. Cura heridas, huesos rotos, venenos, enfermedades y baja vitalidad.

### Tipos en el juego (progresión lineal)

| Tier | Nombre | Potencia de curación | Requisito |
|------|--------|---------------------|-----------|
| 1 | Aceleración de la Recuperación | +20% HP en 5s | ki ≥ 60 |
| 2 | Curación de Heridas Leve | 35% HP instantáneo | ki ≥ 100, poder_ki ≥ 60 |
| 3 | Curación de Lesiones Medias | 60% HP + elimina debuffs | ki ≥ 150, poder_ki ≥ 120 |
| 4 | Curación de Lesiones Mortales | 100% HP + revive aliados | ki ≥ 250, poder_ki ≥ 200, inteligencia ≥ 120 |

---

### Pasivas

| Nombre | Tier | Efecto |
|--------|------|--------|
| **Aura Vital** | 1 | Regenera 0.8% HP/s durante el combate. Al finalizar un combate, recupera el 25% del HP perdido. |
| **Toque Restaurador** | 1 | Cada vez que el jugador golpea al enemigo, recupera el 3% del daño infligido como HP. |
| **Pureza de Ki** | 2 | Inmune a veneno y efectos de corrosión. Las enfermedades no pueden reducir los stats del jugador. |
| **Sanador Eficiente** | 2 | Todas las habilidades de curación cuestan 25% menos Ki. |
| **Transferencia Vital** | 3 | Al curar a un aliado invocado, el jugador también recupera el 20% de lo que curó. |
| **Límite de la Muerte** | 4 | Si el HP caería a 0 y hay Ki disponible, se activa una microcuración automática de 15% HP (consume 30% Ki). Una vez por combate. |

---

### Habilidades Activas

#### PULSO DE VIDA *(SUPPORT — Curación rápida)*
> Una ola de energía vital que sella las heridas más urgentes en un instante.
- **Costo de Ki:** 15%
- **Efecto:** Recupera 25% del HP máximo instantáneamente.
- **Efecto Tier 2+:** Adicionalmente elimina 1 debuff activo.
- **Cooldown:** 14.0s
- **Requisito de equipo:** ki ≥ 60

#### RESTAURACIÓN PLENA *(SUPPORT — Curación masiva)*
> El usuario canaliza todo su Ki en una restauración completa del tejido dañado.
- **Costo de Ki:** 40%
- **Efecto:** Recupera el 70% del HP máximo en 3 segundos (distribuido en pulsos de 23% por segundo). Durante esos 3 segundos el jugador recibe 30% menos daño.
- **Efecto Tier 3+:** También elimina todos los debuffs activos.
- **Cooldown:** 25.0s
- **Requisito de equipo:** ki ≥ 150, poder_ki ≥ 120

#### DRENAJE CURATIVO *(STRIKE — Vampirismo)*
> El usuario extrae la energía vital del enemigo y la convierte en su propia salud.
- **Costo de Ki:** 20%
- **Daño:** ×1.5 sobre poder_ki
- **Hit Count:** 1
- **Efecto especial:** Recupera HP igual al 80% del daño infligido. Si el enemigo está bajo el 30% HP, la absorción sube al 120%.
- **Cooldown:** 9.0s
- **Requisito de equipo:** ki ≥ 100, poder_ki ≥ 80

#### CAMPO REGENERADOR *(SUPPORT — Buff prolongado)*
> El usuario emite un campo de energía curativa que lo sostiene durante todo el combate.
- **Costo de Ki:** 30%
- **Efecto:** Durante 20 segundos, la regeneración pasiva se multiplica ×5. Si el jugador tiene activa la habilidad de Regeneración, los dos efectos se suman.
- **Cooldown:** 35.0s
- **Requisito de equipo:** ki ≥ 180, poder_ki ≥ 150

#### MILAGRO VITAL *(ULTIMATE — Curación total de emergencia)*
> En el borde entre la vida y la muerte, el sanador libera toda su energía de una sola vez.
- **Costo de Ki:** 80%
- **Efecto:** Recupera 100% del HP máximo instantáneamente. Elimina todos los debuffs. Durante 5 segundos, el daño recibido se reduce al 10%.
- **Efecto Tier 4:** Si hay un aliado invocado, también lo cura al 100%.
- **Cooldown:** 50.0s (1 uso por combate)
- **Requisito de equipo:** ki ≥ 250, poder_ki ≥ 200, inteligencia ≥ 120

---

### Cómo Obtenerlo

| Método | Condición |
|--------|-----------|
| **Acción de día:** "Meditación Curativa" | Desde día 1. Sube ki y poder_ki. Desbloquea Tier 1 al alcanzar ki ≥ 60. |
| **Acción de día:** "Estudio de Medicina Ki" | Disponible día 15+. Requiere ki ≥ 80. Sube poder_ki e inteligencia. Desbloquea Tier 2. |
| **NPC: Curandero / Médico Ki** | Relación media (≥50%). Enseña "Pulso de Vida" y "Drenaje Curativo". |
| **NPC: Kami / Dios Guardián** | Relación alta (≥75%). Enseña "Restauración Plena" y "Campo Regenerador". Desbloquea Tier 3. |
| **NPC: Dios de la Destrucción** | Relación máxima (≥90%). Enseña "Milagro Vital". Desbloquea Tier 4. |
| **Checkpoint Día 30** | Si ki ≥ 100 + poder_ki ≥ 80 → se activa la pasiva "Pureza de Ki" y "Sanador Eficiente". |
| **Checkpoint Día 60** | Si Tier 3 activo + inteligencia ≥ 100 → se activa "Límite de la Muerte". |
| **Raza: Namekiano** | Tier 1 activo desde el inicio. "Aura Vital" duplica su regeneración. |

---
---

## 2. Gran Fuerza de Voluntad

**Descripción:** Una fuerza de voluntad tan poderosa que permite al usuario resistir el dolor físico, traumas psicológicos, control mental y cualquier forma de tentación o coerción. La voluntad del usuario actúa como una fuerza tangible en el combate: cuanto más adversa la situación, mayor es el poder que despierta.

---

### Pasivas

| Nombre | Efecto |
|--------|--------|
| **Mente Blindada** | Inmune a efectos de control mental, confusión y reducción de inteligencia. Los debuffs psicológicos no tienen efecto. |
| **Umbral de Dolor** | El jugador no recibe penalización de daño por HP bajo hasta el 10% HP (estándar: 40%). |
| **Llama Interior** | Por cada 20% de HP perdido, el daño de salida aumenta en +10% (máximo +50% a HP crítico). |
| **Espíritu Indomable** | Si el jugador recibe un golpe que lo llevaría directamente del 100% al 0% HP, ese golpe solo puede reducir el HP al 1%. Una vez por combate. |
| **Resistencia Mental** | Los debuffs de stats (reducción de fuerza, velocidad, etc.) duran 50% menos tiempo. |
| **Fe en Uno Mismo** | Al inicio de cada combate, el jugador obtiene un buff de +10% a todos los stats que dura 8 segundos. Representa la confianza del personaje. |

---

### Habilidades Activas

#### AGUANTE FÉRREO *(SUPPORT — Resistencia de corta duración)*
> La voluntad del usuario vence al dolor. El cuerpo obedece aunque proteste.
- **Costo de Ki:** 15%
- **Efecto:** Durante 6 segundos, el jugador no puede ser aturdido, derribado ni empujado. El daño recibido se reduce en 35%.
- **Cooldown:** 12.0s
- **Requisito de equipo:** resistencia ≥ 100

#### EXPLOSIÓN DE VOLUNTAD *(SUPPORT — Burst de poder bajo presión)*
> Cuando todo parece perdido, la voluntad toma el control y desata el verdadero poder.
- **Costo de Ki:** 20%
- **Condición de activación:** Solo disponible cuando el HP está bajo el 40%.
- **Efecto:** +80% a todos los stats durante 10 segundos. Al terminar, el HP se estabiliza al 15% si estaba por debajo.
- **Cooldown:** 25.0s
- **Requisito de equipo:** resistencia ≥ 150, vitalidad ≥ 120

#### NEGATIVA ABSOLUTA *(SUPPORT — Anti-muerte temporal)*
> El usuario se niega categóricamente a caer. Es más que determinación: es una ley que él mismo impone.
- **Costo de Ki:** 35%
- **Efecto:** Durante 8 segundos, el HP del jugador no puede bajar del 1%. Todo daño que debería eliminarlo se acumula y se convierte en reducción de Ki en su lugar.
- **Cooldown:** 30.0s
- **Requisito de equipo:** resistencia ≥ 200, vitalidad ≥ 180

#### ROMPER LOS LÍMITES *(ULTIMATE — Trascendencia momentánea)*
> La voluntad del usuario supera toda barrera física. Por un instante, es más de lo que su cuerpo debería poder ser.
- **Costo de Ki:** 50%
- **Efecto:** Durante 12 segundos: todos los stats aumentan en +100%, el jugador es inmune a debuffs, y los cooldowns se reducen a la mitad. Al terminar, sufre 15% de su HP máximo como daño por el esfuerzo.
- **Cooldown:** 40.0s
- **Requisito de equipo:** resistencia ≥ 250, inteligencia ≥ 100

#### ÚLTIMO ALIENTO *(ULTIMATE — Reversión definitiva)*
> El usuario lleva su cuerpo al límite final de su existencia. Un golpe que nace de la negativa pura a morir.
- **Costo de Ki:** 0 (se activa solo con HP ≤ 5%)
- **Daño:** ×(10 − HP_porcentaje×10) sobre todos los stats combinados. A 1% HP = ×9.9, a 5% HP = ×9.5.
- **Hit Count:** 1
- **Efecto especial:** No puede ser esquivado. Después de usarla, el HP se recupera al 20%.
- **Cooldown:** 1 uso por combate
- **Requisito de equipo:** vitalidad ≥ 200, resistencia ≥ 200

---

### Cómo Obtenerlo

| Método | Condición |
|--------|-----------|
| **Acción de día:** "Entrenamiento Mental" | Disponible desde día 1. Sube resistencia e inteligencia. Desbloquea pasiva "Umbral de Dolor" al llegar a resistencia ≥ 100. |
| **Acción de día:** "Meditación de Combate" | Disponible día 10+. Sube inteligencia, intel_combate e indirectamente activa "Mente Blindada". |
| **Flag: Superación** | Haber sobrevivido 5 combates con HP ≤ 10% → desbloquea "Llama Interior" y "Aguante Férreo". |
| **Checkpoint Día 25** | Si resistencia ≥ 150 + vitalidad ≥ 120 → activa "Espíritu Indomable" y "Explosión de Voluntad". |
| **Checkpoint Día 45** | Si resistencia ≥ 200 + vitalidad ≥ 180 → activa "Negativa Absoluta" y "Resistencia Mental". |
| **Checkpoint Día 65** | Si "Negativa Absoluta" usada al menos 3 veces → activa "Último Aliento" y "Romper los Límites". |
| **Evento narrativo:** "La Prueba del Límite" | Día 50. El personaje enfrenta un enemigo imposible. Sobrevivir (no necesariamente ganar) desbloquea "Fe en Uno Mismo". |
| **Raza: Humano** | La Gran Fuerza de Voluntad escala con mayor eficiencia para los humanos: todas sus pasivas dan +20% adicional. |

---
---

## 3. Detección

**Descripción:** La capacidad de sentir la presencia de seres, materia, energía, poder o conceptos. En Dragon Ball, esto se conoce como "detectar el Ki". Los usuarios más avanzados pueden leer el nivel exacto de poder del oponente, detectar intenciones hostiles o incluso percibir amenazas ocultas a distancias enormes.

---

### Pasivas

| Nombre | Efecto |
|--------|--------|
| **Radar de Ki** | La barra de Ki del enemigo es siempre visible en el HUD. Muestra el porcentaje exacto en tiempo real. |
| **Sentido de Amenaza** | 0.5 segundos antes de que el enemigo use una habilidad Ultimate, aparece un indicador visual de alerta. |
| **Lectura de Poder** | Al inicio de cada combate, el HUD muestra brevemente el nivel de poder del enemigo en comparación con el jugador (más débil / a la par / más fuerte / peligroso / inalcanzable). |
| **Sin Sorpresa** | Inmune a ataques por sorpresa. Ningún bonus de daño por posicionamiento tiene efecto. |
| **Triangulación Vital** | Si hay varios enemigos, el jugador siempre sabe la posición del más peligroso, marcado en el HUD. |
| **Detección Profunda** | Puede percibir si el enemigo tiene reservas ocultas de poder (transformaciones disponibles, habilidades no usadas). Aparece como un indicador en el HUD. |

---

### Habilidades Activas

#### EXPLORACIÓN DE KI *(SUPPORT — Scouting)*
> El usuario extiende su percepción por todo el campo de batalla, sin dejar punto ciego.
- **Costo de Ki:** 12%
- **Efecto:** Durante 12 segundos, todos los ataques del enemigo son telegrafíados con 0.6 segundos de antelación. El dodge tiene +25% de éxito adicional.
- **Cooldown:** 18.0s
- **Requisito de equipo:** ki ≥ 80

#### ANÁLISIS DE COMBATIENTE *(SUPPORT — Revelación de stats)*
> El usuario lee al enemigo con precisión quirúrgica, encontrando cada debilidad.
- **Costo de Ki:** 18%
- **Efecto:** Durante 15 segundos, todos los stats del enemigo son visibles en el HUD. Los ataques del jugador hacen +15% de daño adicional (explota las debilidades encontradas). Si el enemigo está en una transformación, también se ven sus modificadores.
- **Cooldown:** 22.0s
- **Requisito de equipo:** ki ≥ 100, intel_combate ≥ 80

#### PULSO DE DETECCIÓN *(SUPPORT — Revelación de área)*
> El usuario emite una onda de Ki que atraviesa todo el entorno, revelando lo invisible.
- **Costo de Ki:** 20%
- **Efecto:** Revela si el enemigo tiene habilidades especiales aún sin usar. Durante 8 segundos, la velocidad de reacción efectiva del jugador aumenta (los ataques rápidos del enemigo pueden esquivarse más fácilmente, como si hubieran sido ralentizados visualmente).
- **Cooldown:** 20.0s
- **Requisito de equipo:** ki ≥ 120, inteligencia ≥ 80

#### SUPRESIÓN DE KI *(STRIKE — Debuff de poder)*
> El usuario detecta el flujo de Ki del enemigo y lo interrumpe en el punto exacto.
- **Costo de Ki:** 25%
- **Daño:** ×1.2 sobre intel_combate
- **Hit Count:** 1
- **Efecto especial:** Reduce el Ki del enemigo en 35% y le impide regenerarlo durante 8 segundos. Si el enemigo está en una transformación que requiere Ki, esta se cancela.
- **Cooldown:** 15.0s
- **Requisito de equipo:** ki ≥ 130, intel_combate ≥ 100

#### VISIÓN OMNISCIENTE *(ULTIMATE — Percepción total)*
> Por unos instantes, el usuario percibe todo con una claridad absoluta y perfecta.
- **Costo de Ki:** 55%
- **Efecto:** Durante 8 segundos: el jugador conoce cada movimiento del enemigo antes de que ocurra (dodge garantizado al 100%), puede ver todos los stats y buffs/debuffs del enemigo, y sus propios ataques ignoran el 40% de la resistencia del enemigo.
- **Cooldown:** 30.0s
- **Requisito de equipo:** ki ≥ 200, intel_combate ≥ 130, inteligencia ≥ 100

---

### Cómo Obtenerlo

| Método | Condición |
|--------|-----------|
| **Acción de día:** "Meditación de Ki" | Desde día 1. Sube ki. Al alcanzar ki ≥ 60, se activa "Radar de Ki" automáticamente. |
| **Acción de día:** "Práctica de Detección" | Disponible día 10+. Requiere ki ≥ 80. Sube ki e intel_combate. Desbloquea "Sentido de Amenaza". |
| **NPC: Maestro de Ki** | Relación media (≥50%). Enseña "Exploración de Ki" y "Análisis de Combatiente". |
| **NPC: Kami / Kaiō** | Relación alta (≥70%). Enseña "Pulso de Detección" y desbloquea "Lectura de Poder". |
| **Checkpoint Día 20** | Si ki ≥ 100 + intel_combate ≥ 70 → activa "Sin Sorpresa" y "Lectura de Poder". |
| **Checkpoint Día 40** | Si ki ≥ 150 + inteligencia ≥ 80 → activa "Detección Profunda" y desbloquea "Supresión de Ki". |
| **Raza: Saiyan / Namekiano** | "Radar de Ki" activo desde el inicio del run. Los Namekianos además comienzan con "Sentido de Amenaza". |
| **Minijuego: Apple / Reacción** | Completar con A+ → activa "Triangulación Vital" como pasiva. |

---
---

## 4. Puntos de Presión

**Descripción:** Conocimiento profundo de los grupos de nervios y puntos vitales del cuerpo. Golpear estos puntos con precisión puede provocar parálisis, inhibir el flujo de chi del enemigo, apagar funciones corporales o, en el punto más extremo, matar con un solo golpe en el lugar correcto.

---

### Pasivas

| Nombre | Efecto |
|--------|--------|
| **Golpe Preciso** | Los ataques físicos del jugador ignoran el 20% de la resistencia del enemigo (el golpe siempre encuentra un punto débil). |
| **Inhibición de Chi** | Cada hit físico reduce el Ki del enemigo en un 3% adicional. |
| **Lectura del Sistema Nervioso** | +15% de probabilidad de que cada golpe cause un "micro-aturdimiento" de 0.2 segundos (interrumpe los ataques del enemigo pero no lo detiene completamente). |
| **Anatomía de Combate** | El jugador conoce los puntos críticos de cada tipo de enemigo. Los ataques en las primeras 2 interacciones del combate hacen +25% de daño (primeras impresiones). |
| **Flujo Cortado** | Si el enemigo está usando una habilidad activa, un golpe físico tiene 20% de interrumpirla (cancelación de skill). |

---

### Habilidades Activas

#### GOLPE PARALIZANTE *(STRIKE — Control)*
> Un golpe seco y preciso al grupo nervioso exacto. El cuerpo del enemigo deja de responder.
- **Costo de Ki:** 18%
- **Daño:** ×1.8 sobre intel_combate + ×0.5 sobre fuerza
- **Hit Count:** 1
- **Efecto especial:** Paraliza al enemigo durante 2.5 segundos (no puede atacar ni moverse). Si intel_combate ≥ 150, la parálisis dura 4 segundos.
- **Cooldown:** 10.0s
- **Requisito de equipo:** intel_combate ≥ 100, velocidad ≥ 90

#### CORTE DE CHI *(STRIKE — Debuff de Ki)*
> El usuario golpea los meridianos de energía del enemigo, cortando su flujo vital.
- **Costo de Ki:** 20%
- **Daño:** ×1.2 sobre intel_combate
- **Hit Count:** 2
- **Efecto especial:** El Ki del enemigo se reduce en 50% y no puede regenerarse durante 10 segundos. Cualquier transformación activa del enemigo que consuma Ki se desactiva.
- **Cooldown:** 14.0s
- **Requisito de equipo:** intel_combate ≥ 120, inteligencia ≥ 90

#### DESCARGA NERVIOSA *(STRIKE — Multi-parálisis)*
> El usuario golpea con velocidad extrema múltiples puntos de presión simultáneamente.
- **Costo de Ki:** 30%
- **Daño:** ×0.9 por hit sobre intel_combate
- **Hit Count:** 5
- **Efecto especial:** Cada hit tiene 40% de causar un micro-aturdimiento de 0.3s. Si los 5 hits conectan, el enemigo queda paralizado 3 segundos.
- **Cooldown:** 16.0s
- **Requisito de equipo:** intel_combate ≥ 130, velocidad ≥ 120

#### PUNTO VITAL *(STRIKE — Daño extremo en un golpe)*
> Un golpe en el punto más crítico del cuerpo del oponente. Si conecta en el lugar exacto, el resultado es devastador.
- **Costo de Ki:** 40%
- **Daño:** ×5.0 sobre intel_combate + ×2.0 sobre inteligencia
- **Hit Count:** 1
- **Efecto especial:** Si el enemigo tiene menos de 35% HP cuando este golpe conecta, es un golpe letal directo (KO instantáneo). Si tiene más HP, simplemente hace el daño calculado e ignora toda la resistencia.
- **Cooldown:** 20.0s
- **Requisito de equipo:** intel_combate ≥ 150, inteligencia ≥ 130, velocidad ≥ 110

#### INHIBICIÓN TOTAL *(ULTIMATE — Shutdown de combate)*
> El usuario toca con precisión milimétrica cada punto de control del cuerpo del enemigo. El resultado es el apagado completo de sus capacidades.
- **Costo de Ki:** 55%
- **Daño:** ×3.0 sobre intel_combate
- **Hit Count:** 3
- **Efecto especial:** El enemigo pierde el 40% de todos sus stats durante 12 segundos y no puede usar habilidades activas durante ese tiempo.
- **Cooldown:** 28.0s
- **Requisito de equipo:** intel_combate ≥ 170, inteligencia ≥ 150

---

### Cómo Obtenerlo

| Método | Condición |
|--------|-----------|
| **Acción de día:** "Estudio Anatómico" | Disponible día 8+. Sube inteligencia e intel_combate. Desbloquea "Golpe Preciso" al llegar a intel_combate ≥ 80. |
| **Acción de día:** "Práctica de Precisión" | Disponible día 15+. Alta ganancia de intel_combate. Requiere intel_combate ≥ 100 para desbloquear. |
| **NPC: Maestro de Artes Marciales Internas** | Relación alta (≥70%). Enseña "Golpe Paralizante" y "Corte de Chi". Requiere Artes Marciales desbloqueadas. |
| **NPC: Sensei de Medicina de Combate** | Relación alta (≥75%). Enseña "Descarga Nerviosa" e "Inhibición Total". |
| **Checkpoint Día 35** | Si intel_combate ≥ 130 + inteligencia ≥ 90 → activa "Flujo Cortado" y desbloquea "Punto Vital". |
| **Flag: Precisión** | Haber ganado 3 combates sin recibir daño → activa "Anatomía de Combate" y "Lectura del Sistema Nervioso". |
| **Requisito de Artes Marciales** | Puntos de Presión requiere que Artes Marciales esté desbloqueada (cualquier nivel). |

---
---

## 5. Manipulación de las Vibraciones

**Descripción:** La capacidad de crear, controlar y proyectar vibraciones a través del suelo, el agua o el aire. Desde ondas de choque destructivas hasta resonancias que desestabilizan el interior del cuerpo del enemigo. A diferencia del daño por fuerza bruta, las vibraciones penetran defensas físicas y actúan desde dentro.

---

### Pasivas

| Nombre | Efecto |
|--------|--------|
| **Onda Persistente** | Cada ataque físico del jugador genera una micro-vibración que reduce la resistencia del enemigo en 2% por hit (acumulable hasta -20%). Se reinicia al terminar el combate. |
| **Suelo Inestable** | El enemigo pierde un 10% de su dodge base (las vibraciones del suelo desequilibran su posicionamiento). |
| **Cuerpo Resonante** | El jugador puede sentir las vibraciones del suelo, dándole +8% de dodge adicional y "Sin Sorpresa" ante ataques terrestres. |
| **Amplificación Natural** | Si el jugador golpea a un enemigo ya paralizado, aturdido o derribado, el daño tiene +40% adicional (las vibraciones amplifican el daño en cuerpos inmóviles). |
| **Eco de Batalla** | Al encadenar 3 o más hits seguidos, el cuarto hit genera automáticamente una mini-onda de choque que hace daño de área equivalente al 50% del último hit. |

---

### Habilidades Activas

#### ONDA DE CHOQUE *(KI_BLAST — Proyectil de vibración)*
> El usuario libera una onda de vibración pura que atraviesa al enemigo desde dentro.
- **Costo de Ki:** 22%
- **Daño:** ×2.5 sobre poder_ki + ×0.5 sobre fuerza
- **Hit Count:** 1
- **is_ranged:** true
- **Efecto especial:** Ignora el 30% de la resistencia del enemigo (las vibraciones bypasean la defensa superficial). Aturde por 0.8 segundos.
- **Cooldown:** 5.0s
- **Requisito de equipo:** poder_ki ≥ 100, fuerza ≥ 80

#### TERREMOTO *(STRIKE — Daño de área + desequilibrio)*
> El usuario golpea el suelo con tal fuerza que genera una onda sísmica que atraviesa el campo de batalla.
- **Costo de Ki:** 28%
- **Daño:** ×2.0 sobre fuerza + ×1.5 sobre poder_ki
- **Hit Count:** 1
- **Efecto especial:** Derriba al enemigo durante 2 segundos. Reduce el dodge del enemigo en 20% durante 8 segundos (el suelo sigue temblando).
- **Cooldown:** 10.0s
- **Requisito de equipo:** fuerza ≥ 150, poder_ki ≥ 80

#### RESONANCIA INTERNA *(STRIKE — Daño acumulativo)*
> El usuario mantiene el contacto justo el tiempo necesario para que las vibraciones entren en resonancia con los órganos internos del enemigo.
- **Costo de Ki:** 35%
- **Daño:** ×1.0 sobre poder_ki en el impacto inicial + ×0.5 por segundo durante 5 segundos (daño residual de resonancia)
- **Hit Count:** 1 + 5 ticks
- **Efecto especial:** El daño residual ignora completamente la resistencia del enemigo.
- **Cooldown:** 12.0s
- **Requisito de equipo:** poder_ki ≥ 150, ki ≥ 120

#### BARRERA VIBRATORIA *(SUPPORT — Escudo)*
> El usuario genera un campo de vibraciones a su alrededor que desintegra los ataques entrantes.
- **Costo de Ki:** 25%
- **Efecto:** Durante 6 segundos, el 50% de cada ataque recibido es desviado por las vibraciones (daño reducido a la mitad). Si un ataque físico llega, tiene 30% de rebotar y golpear al enemigo con el 30% del daño original.
- **Cooldown:** 18.0s
- **Requisito de equipo:** poder_ki ≥ 130, fuerza ≥ 100

#### TORMENTA SÍSMICA *(ULTIMATE — Vibración máxima)*
> El usuario libera todas las vibraciones acumuladas en una explosión de energía sísmica que destruye todo a su alrededor.
- **Costo de Ki:** 65%
- **Daño:** ×4.0 sobre poder_ki + ×2.0 sobre fuerza + la resistencia acumulada por "Onda Persistente" se añade directamente al daño.
- **Hit Count:** 6
- **Efecto especial:** Cada hit reduce la resistencia del enemigo en 5% adicional. El enemigo queda aturdido 3 segundos después del último hit.
- **Cooldown:** 25.0s
- **Requisito de equipo:** poder_ki ≥ 200, fuerza ≥ 160, ki ≥ 150

#### RESONANCIA DESTRUCTIVA *(ULTIMATE — Daño puro interno)*
> Las vibraciones entran en la frecuencia exacta del cuerpo del enemigo. Lo que está dentro se destruye, sin importar lo que proteja el exterior.
- **Costo de Ki:** 80%
- **Daño:** ×8.0 sobre poder_ki
- **Hit Count:** 1
- **Efecto especial:** Ignora el 100% de la resistencia del enemigo. No puede ser esquivado. Si el enemigo tiene una barrera o buff defensivo, lo elimina antes de aplicar el daño.
- **Cooldown:** 35.0s
- **Requisito de equipo:** poder_ki ≥ 250, ki ≥ 200, fuerza ≥ 150

---

### Cómo Obtenerlo

| Método | Condición |
|--------|-----------|
| **Acción de día:** "Entrenamiento de Ki Ofensivo" | Disponible día 5+. Sube poder_ki y fuerza. Desbloquea "Onda Persistente" al llegar a poder_ki ≥ 80. |
| **Acción de día:** "Control de Vibraciones" | Disponible día 20+. Requiere poder_ki ≥ 100. Alta ganancia de poder_ki y ki. Desbloquea las habilidades activas. |
| **NPC: Maestro de Energía** | Relación media (≥55%). Enseña "Onda de Choque" y "Barrera Vibratoria". |
| **NPC: Guerrero Tierra** | Relación alta (≥75%). Enseña "Terremoto" y "Resonancia Interna". |
| **Checkpoint Día 30** | Si poder_ki ≥ 100 + fuerza ≥ 100 → activa "Suelo Inestable" y "Cuerpo Resonante". |
| **Checkpoint Día 50** | Si poder_ki ≥ 180 + ki ≥ 150 → activa "Amplificación Natural" y desbloquea "Tormenta Sísmica". |
| **Flag: Cadena** | Haber ejecutado un combo de 5+ hits 10 veces en combate → activa "Eco de Batalla". |
| **Minijuego: Ki Channel** | Completar con S → desbloquea "Resonancia Destructiva". |

---

## Tabla de Compatibilidad entre Habilidades

> Algunas habilidades se potencian mutuamente cuando ambas están activas.

| Habilidad A | Habilidad B | Sinergia |
|-------------|-------------|---------|
| Curación | Regeneración | La curación activa y la regeneración pasiva se suman sin cap. El "Campo Regenerador" triplica la tasa de Regeneración pasiva. |
| Curación | Gran Voluntad | "Límite de la Muerte" de Curación y "Espíritu Indomable" de Voluntad se activan en orden, dando dos capas de protección anti-muerte. |
| Gran Voluntad | Regeneración | "Llama Interior" se combina con los tiers de regeneración: más daño cuando más bajo el HP, y a la vez el HP se va recuperando. |
| Detección | Puntos de Presión | "Análisis de Combatiente" revela el sistema nervioso del enemigo, haciendo que "Punto Vital" garantice KO si el HP objetivo ya era bajo. |
| Detección | Manipulación de Vibraciones | "Pulso de Detección" revela la frecuencia de vibración natural del enemigo. "Resonancia Interna" hace el doble de daño residual. |
| Puntos de Presión | Gran Voluntad | "Golpe Paralizante" combinado con "Aguante Férreo": el jugador es inmune al daño mientras el enemigo está paralizado, creando una ventana de ataque libre perfecta. |
| Vibraciones | Artes Marciales | "Eco de Batalla" de Vibraciones activa automáticamente la bonus de "Ritmo de Combate" de Artes Marciales en cada onda de choque generada. |
| Curación | Invocación | "Milagro Vital" también cura aliados invocados al máximo. Con "Transferencia Vital" activa, curar aliados devuelve HP al jugador también. |
