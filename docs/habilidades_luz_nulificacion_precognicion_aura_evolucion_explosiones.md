# Dragon Ascension — Luz · Nulificación · Precognición · Aura · Evolución Reactiva · Explosiones
> Stats clave: fuerza · velocidad · ki · vitalidad · resistencia · poder_ki · inteligencia · intel_combate

---

## 1. Manipulación de la Luz

**Descripción:** Control sobre la radiación electromagnética visible. El usuario puede generar, moldear y redirigir la luz para cegar, crear ilusiones, solidificarla en construcciones físicas o moverse a su velocidad. En niveles altos, la luz se convierte en un arma absoluta que atraviesa toda defensa.

---

### Pasivas

| Nombre | Efecto |
|--------|--------|
| **Velocidad de la Luz** | +20% velocidad de movimiento en combate. Los dash y desplazamientos ocurren sin animación de inicio. |
| **Aura Luminosa** | El jugador emite un brillo tenue que reduce en 10% el dodge del enemigo (el destello confunde su percepción). |
| **Absorción Fotónica** | Los ataques de Ki del enemigo (proyectiles de energía) tienen 15% de ser absorbidos, recuperando el 10% del Ki del jugador. |
| **Invisibilidad Parcial** | Al activar el modo vuelo, el jugador se vuelve parcialmente invisible: el dodge sube +20% adicional mientras está en el aire. |
| **Refracción Natural** | Los ataques de tipo energía del enemigo rebotan con 20% de probabilidad, devolviéndole el 30% del daño que habrían causado. |
| **Velocidad Fotónica** | Con velocidad ≥ 200: el primer ataque de cada combate es instantáneo y no puede ser esquivado (el jugador llega antes que la luz). |

---

### Habilidades Activas

#### DESTELLO CEGADOR *(SUPPORT — Control de visión)*
> Un pulso de luz pura que satura los ojos del oponente, dejándolo momentáneamente ciego.
- **Costo de Ki:** 14%
- **Efecto:** El enemigo pierde el 60% de su probabilidad de dodge durante 4 segundos y no puede usar habilidades activas durante 2 segundos (no puede "apuntar").
- **Cooldown:** 10.0s
- **Requisito de equipo:** poder_ki ≥ 80

#### LANZA DE FOTONES *(KI_BLAST — Perforador)*
> Un rayo de luz concentrado a densidad extrema. Viaja tan rápido que no hay tiempo de reaccionar.
- **Costo de Ki:** 22%
- **Daño:** ×2.8 sobre poder_ki + ×0.8 sobre velocidad
- **Hit Count:** 1
- **is_ranged:** true
- **Efecto especial:** Imposible de esquivar si el jugador tiene velocidad ≥ 150. Ignora el 25% de resistencia.
- **Cooldown:** 5.0s
- **Requisito de equipo:** poder_ki ≥ 120, velocidad ≥ 100

#### ILUSIÓN DE COMBATE *(SUPPORT — Engaño)*
> El usuario manipula la luz a su alrededor para crear copias falsas de sí mismo.
- **Costo de Ki:** 25%
- **Efecto:** Durante 6 segundos, el 40% de los ataques del enemigo impactan en una ilusión en lugar del jugador (daño nulo). El jugador ataca normalmente durante este tiempo.
- **Cooldown:** 18.0s
- **Requisito de equipo:** poder_ki ≥ 140, inteligencia ≥ 90

#### ARMADURA DE LUZ SOLIDIFICADA *(SUPPORT — Barrera física)*
> El usuario compacta la luz en una densidad imposible, creando una capa de materia fotónica.
- **Costo de Ki:** 30%
- **Efecto:** Durante 8 segundos, el daño recibido se reduce en 55%. Si el efecto es destruido antes de tiempo (por recibir daño mayor al 40% del HP máximo en un golpe), explota y hace ×2.0 de poder_ki de daño al enemigo.
- **Cooldown:** 22.0s
- **Requisito de equipo:** poder_ki ≥ 160, ki ≥ 150

#### APOCALIPSIS LUMINOSO *(ULTIMATE — Daño masivo de área)*
> El usuario libera la energía lumínica acumulada en una explosión de fotones que arrasa todo.
- **Costo de Ki:** 70%
- **Daño:** ×6.0 sobre poder_ki + ×2.0 sobre velocidad
- **Hit Count:** 1
- **Efecto especial:** Ciega al enemigo durante 5 segundos (dodge 0%, sin habilidades activas). No puede ser esquivado.
- **Cooldown:** 30.0s
- **Requisito de equipo:** poder_ki ≥ 200, velocidad ≥ 150, ki ≥ 200

---

### Cómo Obtenerlo

| Método | Condición |
|--------|-----------|
| **Acción de día:** "Canalización de Ki Luminoso" | Disponible día 10+. Requiere poder_ki ≥ 60. Sube poder_ki y velocidad. Desbloquea "Aura Luminosa". |
| **Acción de día:** "Control de la Velocidad de la Luz" | Disponible día 30+. Requiere velocidad ≥ 120 + poder_ki ≥ 120. Desbloquea "Velocidad Fotónica". |
| **NPC: Maestro de Energía Pura** | Relación media (≥55%). Enseña "Destello Cegador" y "Lanza de Fotones". |
| **NPC: Entidad de Luz / Ser Superior** | Relación alta (≥80%). Enseña "Ilusión de Combate" y "Armadura de Luz Solidificada". |
| **Checkpoint Día 35** | poder_ki ≥ 140 + velocidad ≥ 100 → activa "Refracción Natural" + "Absorción Fotónica". |
| **Checkpoint Día 55** | poder_ki ≥ 180 + velocidad ≥ 150 → desbloquea "Apocalipsis Luminoso". |
| **Flag: Velocista** | Ganar 5 combates sin recibir más de 1 golpe → activa "Invisibilidad Parcial" e "Velocidad de la Luz". |

---
---

## 2. Nulificación de Poder

**Descripción:** La capacidad de anular, suprimir o cancelar los poderes y habilidades de otros. Puede ser activa (tocar al enemigo) o pasiva (campo de nulificación). Incluye Anti-Magia, Negación de Inmortalidad/Regeneración y Negación de Resistencia.

---

### Pasivas

| Nombre | Efecto |
|--------|--------|
| **Campo Supresor** | Los buffs activos del enemigo duran 35% menos tiempo mientras el jugador está cerca. |
| **Anti-Regeneración** | El enemigo no puede recuperar HP mientras el campo de nulificación está activo (pasiva siempre activa al tener esta habilidad). |
| **Penetración de Resistencia** | Todos los ataques del jugador ignoran el 25% de la resistencia del enemigo. |
| **Sellado Pasivo** | Si el enemigo intenta activar una transformación, hay un 20% de que falle automáticamente (el campo la suprime antes de completarse). |
| **Drenaje de Poder** | Por cada segundo en combate, el Ki del enemigo se reduce en 1% (la nulificación suprime lentamente su energía). |

---

### Habilidades Activas

#### SUPRIMIR *(SUPPORT — Debuff de habilidades)*
> El usuario emite un pulso que desactiva temporalmente las capacidades del enemigo.
- **Costo de Ki:** 20%
- **Efecto:** Durante 6 segundos, el enemigo no puede usar habilidades activas (solo ataques básicos). Sus buffs activos quedan suspendidos durante ese tiempo.
- **Cooldown:** 15.0s
- **Requisito de equipo:** intel_combate ≥ 100, inteligencia ≥ 80

#### CANCELACIÓN DE TRANSFORMACIÓN *(STRIKE + Debuff especial)*
> Un golpe preciso que interrumpe el flujo de energía responsable de la transformación activa.
- **Costo de Ki:** 28%
- **Daño:** ×1.5 sobre intel_combate
- **Hit Count:** 1
- **Efecto especial:** Si el enemigo está en una transformación activa, esta se cancela forzosamente. El enemigo queda con -20% a todos sus stats durante 8 segundos (el coste de la transformación interrumpida). Si no hay transformación activa, el ataque hace el doble de daño.
- **Cooldown:** 18.0s
- **Requisito de equipo:** intel_combate ≥ 120, inteligencia ≥ 100

#### NEGACIÓN DE RESISTENCIA *(SUPPORT — Penetración total)*
> El usuario desmantela la resistencia del enemigo a nivel fundamental, anulando sus defensas.
- **Costo de Ki:** 35%
- **Efecto:** Durante 10 segundos, la resistencia del enemigo cae a 0. Todos los ataques del jugador hacen daño sin mitigación alguna durante ese tiempo.
- **Cooldown:** 25.0s
- **Requisito de equipo:** intel_combate ≥ 140, inteligencia ≥ 120

#### CAMPO DE NULIFICACIÓN *(SUPPORT — Zona de supresión)*
> El usuario expande su campo supresor, convirtiendo el área de combate en una zona donde los poderes no funcionan.
- **Costo de Ki:** 40%
- **Efecto:** Durante 12 segundos: el enemigo no puede usar habilidades activas, sus buffs son cancelados, su Ki no puede regenerarse, y cualquier transformación que intente activar falla. El jugador es inmune a los efectos de nulificación del campo.
- **Cooldown:** 30.0s
- **Requisito de equipo:** intel_combate ≥ 160, inteligencia ≥ 140, ki ≥ 150

#### BORRADO DE PODER *(ULTIMATE — Nulificación permanente parcial)*
> El usuario toca el punto central de poder del enemigo y lo suprime de forma semipermanente durante el combate.
- **Costo de Ki:** 60%
- **Daño:** ×2.0 sobre inteligencia
- **Hit Count:** 1
- **Efecto especial:** El enemigo pierde el 40% de todos sus stats de forma permanente hasta el final del combate. Sus habilidades activas tienen un 50% de fallar al intentar usarlas. No puede ser resistido.
- **Cooldown:** 35.0s (1 uso por combate)
- **Requisito de equipo:** intel_combate ≥ 180, inteligencia ≥ 160

---

### Cómo Obtenerlo

| Método | Condición |
|--------|-----------|
| **Acción de día:** "Estudio de Supresión de Ki" | Disponible día 20+. Requiere inteligencia ≥ 80. Sube inteligencia e intel_combate. |
| **NPC: Maestro Anti-Energía** | Relación alta (≥70%). Enseña "Suprimir" y "Cancelación de Transformación". |
| **NPC: Guardián del Equilibrio** | Relación máxima (≥90%). Enseña "Campo de Nulificación" y "Borrado de Poder". |
| **Checkpoint Día 45** | intel_combate ≥ 130 + inteligencia ≥ 110 → activa "Anti-Regeneración" + "Sellado Pasivo". |
| **Checkpoint Día 65** | intel_combate ≥ 160 + haber cancelado transformaciones en 3 combates → desbloquea "Negación de Resistencia". |
| **Flag: Cazador de Poderes** | Haber ganado combates contra enemigos usando transformaciones 5 veces → activa "Campo Supresor" + "Drenaje de Poder". |
| **Requisito base** | Esta habilidad requiere Detección activa (cualquier nivel). No se puede aprender a suprimir lo que no se detecta. |

---
---

## 3. Precognición

**Descripción:** La capacidad de percibir el futuro. En Dragon Ascension, la Precognición va desde la predicción analítica de movimientos de combate (Tipo 1) hasta la visión del futuro impecable e inalterable (Tipo 4). Cada tipo tiene sus propias mecánicas y requisitos.

---

### Tipos en el juego

| Tipo | Nombre | Mecánica principal | Requisito |
|------|--------|-------------------|-----------|
| 1 | Predicción Analítica | Telegraph anticipado +0.4s, +dodge | intel_combate ≥ 90 |
| 2 | Premoniciones | Sentido del peligro pasivo, alertas | intel_combate ≥ 120, inteligencia ≥ 80 |
| 3 | Visión Estándar | Ver el próximo movimiento del enemigo en HUD | intel_combate ≥ 160, inteligencia ≥ 130 |
| 4 | Precognición Impecable | Dodge garantizado ante cualquier ataque | intel_combate ≥ 200, inteligencia ≥ 180 |

---

### Pasivas

| Nombre | Tipo | Efecto |
|--------|------|--------|
| **Lectura de Movimiento** | 1 | Los ataques del enemigo son telegrafíados con 0.4s adicionales de antelación. Dodge +20%. |
| **Instinto de Supervivencia** | 2 | Si el jugador está a punto de recibir un golpe letal, hay un 25% de esquivarlo automáticamente (instinto predictivo). |
| **Visión de Combate** | 3 | Al inicio del turno del enemigo, aparece un indicador en el HUD señalando qué tipo de ataque usará (físico / Ki / habilidad especial). |
| **Futuro Calculado** | 4 | El primer ataque de cada turno del enemigo siempre es esquivado (el jugador ya vio este momento antes de que ocurriera). |
| **Sin Sorpresa Absoluta** | 2+ | Inmunidad total a ataques por sorpresa, traiciones y efectos de "primer golpe garantizado" del enemigo. |
| **Contracara del Destino** | 3+ | Si el jugador esquiva un ataque, el siguiente golpe propio tiene +30% de daño (aprovecha la apertura que ya había visto). |

---

### Habilidades Activas

#### ANTICIPACIÓN *(SUPPORT — Tipo 1)*
> El jugador entra en un estado de análisis hiperactivo. Cada movimiento del enemigo se vuelve predecible.
- **Costo de Ki:** 18%
- **Efecto:** Durante 10 segundos, el dodge sube al 90% garantizado (no llega al 100% porque el Tipo 1 no es visión perfecta, solo análisis). Cada esquive exitoso da un contraataque gratis de ×1.2 fuerza.
- **Cooldown:** 20.0s
- **Requisito de equipo:** intel_combate ≥ 90

#### PREMONICIÓN DE PELIGRO *(SUPPORT — Tipo 2)*
> Un presentimiento oscuro lleva al jugador a prepararse sin saber exactamente para qué.
- **Costo de Ki:** 22%
- **Efecto:** Durante 8 segundos, si el jugador fuera a recibir más del 30% de su HP máximo en un solo golpe, ese golpe se reduce automáticamente al 15% del HP máximo. Funciona sin límite de veces durante la duración.
- **Cooldown:** 25.0s
- **Requisito de equipo:** intel_combate ≥ 120, inteligencia ≥ 80

#### VISIÓN DEL COMBATE *(SUPPORT — Tipo 3)*
> El usuario observa brevemente el futuro del combate y actúa en consecuencia.
- **Costo de Ki:** 30%
- **Efecto:** El próximo ataque del enemigo (independientemente del tipo) falla automáticamente. El jugador contraataca inmediatamente con ×2.5 de daño sobre intel_combate (ya sabía dónde golpear).
- **Cooldown:** 18.0s
- **Requisito de equipo:** intel_combate ≥ 160, inteligencia ≥ 130

#### REESCRITURA DEL MOMENTO *(ULTIMATE — Tipo 4)*
> El usuario ha visto este momento. Sabe exactamente qué pasará. Y lo cambia.
- **Costo de Ki:** 55%
- **Efecto:** Durante 6 segundos, el jugador es completamente intocable (dodge 100%) y cada uno de sus ataques conecta sin posibilidad de fallo. Al terminar, el enemigo recibe el daño acumulado de todos los ataques que hubieran conectado incluso si algunos "fallaron" visualmente.
- **Cooldown:** 40.0s
- **Requisito de equipo:** Tipo 4 activo (intel_combate ≥ 200, inteligencia ≥ 180)

#### PARADOJA TEMPORAL *(ULTIMATE — Reversal)*
> El usuario predijo que el enemigo usaría esta habilidad. La preparación fue perfecta. El ataque del enemigo se vuelve en su contra.
- **Costo de Ki:** 45%
- **Efecto:** El próximo ataque del enemigo (incluidas sus Ultimates) es reflejado de vuelta con el 150% del daño original. Si el enemigo no ataca en los siguientes 3 segundos, el efecto caduca y el Ki no se consume.
- **Cooldown:** 28.0s
- **Requisito de equipo:** intel_combate ≥ 180, inteligencia ≥ 160

---

### Cómo Obtenerlo

| Método | Condición |
|--------|-----------|
| **Acción de día:** "Meditación Analítica" | Desde día 1. Sube intel_combate. Tipo 1 se activa al llegar a intel_combate ≥ 90. |
| **Acción de día:** "Entrenamiento de Intuición" | Disponible día 15+. Sube inteligencia + intel_combate. Desbloquea Tipo 2 con los stats correctos. |
| **NPC: Oráculo / Vidente** | Relación alta (≥75%). Enseña "Premonición de Peligro" y "Visión del Combate". Desbloquea Tipo 3. |
| **NPC: Ser Omnisciente / Dios** | Relación máxima (≥95%). Enseña "Reescritura del Momento" y "Paradoja Temporal". Desbloquea Tipo 4. |
| **Checkpoint Día 30** | intel_combate ≥ 120 → activa "Sin Sorpresa Absoluta" + "Anticipación". |
| **Checkpoint Día 55** | intel_combate ≥ 160 + inteligencia ≥ 130 → activa "Visión de Combate" + "Contracara del Destino". |
| **Checkpoint Día 75** | Tipo 3 activo + inteligencia ≥ 180 → desbloquea Tipo 4. Solo en New Game+. |
| **Minijuego: Dodge** | Completar 5 rondas con esquive perfecto (sin recibir ningún golpe) → activa "Lectura de Movimiento". |

---
---

## 4. Aura

**Descripción:** La energía del usuario envuelve su cuerpo y se proyecta al exterior. Puede servir para intimidar, atacar, defender o potenciar al usuario. El Aura convierte la energía interna en una fuerza tangible que afecta el entorno y al enemigo.

### Tipos de Aura (todos pueden estar activos simultáneamente)

---

### Pasivas

| Nombre | Tipo de Aura | Efecto |
|--------|-------------|--------|
| **Presencia Abrumadora** | Abrumadora | Al inicio del combate, el enemigo pierde 10% de todos sus stats durante los primeros 5 segundos (la presencia del jugador lo desestabiliza). |
| **Escudo de Aura** | Explosiva | El jugador tiene una capa de aura que absorbe el 10% de cada golpe recibido antes de calcular la resistencia. |
| **Miedo Infundido** | Terrorífica | El dodge del enemigo se reduce en 12% (duda ante el aura del jugador). Si el enemigo tiene menos del 30% HP, la reducción sube al 25%. |
| **Ira Controlada** | Inducción de Ira | Cuando el jugador recibe un golpe crítico, el siguiente ataque tiene +35% de daño adicional (el aura canaliza la ira). |
| **Materialización** | Materializada | Los ataques físicos del jugador generan una capa de aura sólida en el impacto, añadiendo ×0.3 sobre poder_ki de daño adicional a cada hit. |
| **Magnetismo Natural** | Carismática | En el loop de días, las acciones con NPCs tienen +15% de éxito. En combate, el enemigo tiene 10% menos de probabilidad de usar habilidades activas (intimidado). |

---

### Habilidades Activas

#### EXPLOSIÓN DE AURA *(SUPPORT — Burst defensivo/ofensivo)*
> El usuario libera toda su aura de golpe en una onda de choque expansiva.
- **Costo de Ki:** 25%
- **Daño:** ×2.0 sobre poder_ki (daño de área, al enemigo)
- **Hit Count:** 1
- **Efecto especial:** Empuja al enemigo (knockback). Durante 3 segundos después de la explosión, el jugador recibe 40% menos daño (el aura actúa como escudo residual).
- **Cooldown:** 12.0s
- **Requisito de equipo:** ki ≥ 100, poder_ki ≥ 80

#### AURA TERRORÍFICA *(SUPPORT — Debuff psicológico)*
> El usuario proyecta su aura de forma aterradora. El enemigo siente que está ante algo que no debería existir.
- **Costo de Ki:** 20%
- **Efecto:** Durante 8 segundos, el enemigo pierde el 30% de su dodge y 20% de su daño de salida (paralizado por el miedo). Si el enemigo tiene intel_combate bajo 80, queda aturdido 1 segundo adicional.
- **Cooldown:** 18.0s
- **Requisito de equipo:** poder_ki ≥ 100, inteligencia ≥ 70

#### CONSTRUCCIÓN DE AURA *(SUPPORT — Arma o armadura de energía)*
> El usuario materializa su aura en una forma sólida: arma o armadura.
- **Costo de Ki:** 30%
- **Efecto (modo arma):** El siguiente ataque del jugador hace ×3.5 sobre poder_ki de daño adicional (el aura amplifica el golpe físico).
- **Efecto (modo armadura):** Crea un escudo de aura que absorbe hasta el 50% del HP máximo del jugador en daño durante 6 segundos.
- **Cooldown:** 20.0s
- **Nota:** El jugador elige el modo al activar la habilidad.
- **Requisito de equipo:** ki ≥ 150, poder_ki ≥ 130

#### AURA CATASTRÓFICA *(ULTIMATE — Supresión de campo total)*
> El aura del usuario se expande hasta cubrir todo el campo de combate, aplastando al enemigo con su sola presencia.
- **Costo de Ki:** 60%
- **Daño:** ×4.0 sobre poder_ki + ×1.5 sobre ki
- **Hit Count:** 3 (el aura golpea en tres pulsos)
- **Efecto especial:** El enemigo pierde el 25% de todos sus stats durante 12 segundos. Si el enemigo tiene una transformación activa, su multiplicador de stats se reduce a la mitad.
- **Cooldown:** 30.0s
- **Requisito de equipo:** ki ≥ 200, poder_ki ≥ 180, vitalidad ≥ 150

#### AURA MÁXIMA *(ULTIMATE — Forma trascendente)*
> El usuario deja de contener su energía. El aura lo envuelve por completo, convirtiéndolo en una tormenta de poder puro.
- **Costo de Ki:** 75%
- **Efecto:** Durante 10 segundos, todos los stats del jugador aumentan en +60%, el escudo de aura absorbe el 20% de cada golpe, y todos los ataques del jugador tienen ×1.5 de daño adicional. Al terminar, el jugador sufre 10% de su HP máximo como coste del esfuerzo.
- **Cooldown:** 40.0s
- **Requisito de equipo:** ki ≥ 250, poder_ki ≥ 200, vitalidad ≥ 180

---

### Cómo Obtenerlo

| Método | Condición |
|--------|-----------|
| **Acción de día:** "Liberación de Aura" | Disponible día 5+. Sube ki y poder_ki. Activa "Escudo de Aura" y "Presencia Abrumadora" al llegar a ki ≥ 80. |
| **Acción de día:** "Control del Aura" | Disponible día 20+. Requiere ki ≥ 120. Desbloquea tipos de aura específicos. |
| **Minijuego: Ki Channel** | Completar con B o superior → activa "Materialización". Con A+ → activa "Ira Controlada". |
| **NPC: Maestro de Ki Avanzado** | Relación media (≥55%). Enseña "Explosión de Aura" y "Aura Terrorífica". |
| **NPC: Guerrero Legendario** | Relación alta (≥80%). Enseña "Construcción de Aura" y "Aura Catastrófica". |
| **Checkpoint Día 40** | ki ≥ 160 + poder_ki ≥ 130 → activa "Miedo Infundido" + "Magnetismo Natural". |
| **Checkpoint Día 60** | ki ≥ 200 + poder_ki ≥ 180 → desbloquea "Aura Máxima". |
| **Raza: Saiyan** | "Ira Controlada" y "Explosión de Aura" tienen efectos un 30% más potentes. |

---
---

## 5. Evolución Reactiva

**Descripción:** El usuario evoluciona en respuesta directa a las amenazas. A diferencia del Desarrollo Acelerado, la Evolución Reactiva crea resistencias y capacidades nuevas basadas en lo que el enemigo le hace al jugador. Cada daño recibido es información. Cada amenaza superada es una adaptación permanente (o temporal).

---

### Pasivas

| Nombre | Efecto |
|--------|--------|
| **Piel Adaptativa** | Recibir el mismo tipo de daño 3 veces en un combate reduce ese daño en 20%. A las 5 veces, en 40%. A las 8 veces, en 60%. |
| **Memoria Biológica** | Las resistencias ganadas por "Piel Adaptativa" en un combate se conservan en el siguiente (máx. 2 combates). |
| **Respuesta Inmediata** | Al recibir el primer golpe de cada combate, los stats del jugador suben 5% durante 10 segundos (reacción de estrés). |
| **Evolución Post-Combate** | Al ganar un combate donde "Piel Adaptativa" se activó al menos una vez, el stat de resistencia sube permanentemente en +1. |
| **Límite Superado** | Cada vez que el jugador activa "Respuesta Inmediata", la duración del buff aumenta en 1 segundo (acumulable entre combates). |

---

### Habilidades Activas

#### ADAPTACIÓN FORZADA *(SUPPORT — Resistencia activa)*
> El usuario activa deliberadamente su mecanismo evolutivo, acelerando la adaptación.
- **Costo de Ki:** 20%
- **Efecto:** Activa inmediatamente 3 cargas de "Piel Adaptativa" contra el tipo de daño más reciente, como si hubiera recibido ese daño 3 veces ya. Adicionalmente sube la resistencia en +10% durante 15 segundos.
- **Cooldown:** 18.0s
- **Requisito de equipo:** resistencia ≥ 120

#### EVOLUCIÓN DE COMBATE *(SUPPORT — Burst adaptativo)*
> En respuesta a una amenaza crítica, el cuerpo del usuario muta para superarla.
- **Costo de Ki:** 30%
- **Condición de activación:** Solo disponible si el jugador ha recibido al menos 30% de su HP en daño en el combate actual.
- **Efecto:** El jugador regenera 30% HP y gana +25% a todos los stats durante 12 segundos. Si ha recibido 60%+ de daño, el bonus sube a +50%.
- **Cooldown:** 25.0s
- **Requisito de equipo:** resistencia ≥ 160, vitalidad ≥ 140

#### INMUNIDAD TEMPORAL *(SUPPORT — Escudo contra lo ya visto)*
> El cuerpo ha aprendido. Lo que ya superó no puede volver a dañarlo del mismo modo.
- **Costo de Ki:** 35%
- **Efecto:** Durante 8 segundos, el jugador es completamente inmune al tipo de daño que más ha recibido en el combate actual. Si durante ese tiempo el enemigo cambia de tipo de ataque, la inmunidad sigue contra el tipo original.
- **Cooldown:** 28.0s
- **Requisito de equipo:** resistencia ≥ 200, vitalidad ≥ 160

#### MUTACIÓN PERMANENTE *(ULTIMATE — Evolución máxima)*
> El usuario lleva su evolución al límite: el cuerpo se transforma para superar todo lo que ha enfrentado.
- **Costo de Ki:** 65%
- **Efecto:** Suma todos los bonos de "Piel Adaptativa" acumulados en el combate y los convierte en un boost de stats permanente (solo para ese combate): por cada 10% de reducción de daño acumulado, todos los stats suben 5%. El buff dura el resto del combate.
- **Cooldown:** 1 uso por combate
- **Requisito de equipo:** resistencia ≥ 250, vitalidad ≥ 200

---

### Cómo Obtenerlo

| Método | Condición |
|--------|-----------|
| **Acción de día:** "Entrenamiento de Aguante Extremo" | Disponible día 15+. Alta ganancia de resistencia. Activa "Respuesta Inmediata" al llegar a resistencia ≥ 100. |
| **Flag: Superviviente Recurrente** | Haber sobrevivido con HP ≤ 10% en 5 combates distintos → activa "Piel Adaptativa" + "Memoria Biológica". |
| **Checkpoint Día 35** | resistencia ≥ 150 + vitalidad ≥ 120 → desbloquea "Adaptación Forzada" y "Evolución Post-Combate". |
| **Checkpoint Día 55** | resistencia ≥ 200 + "Piel Adaptativa" activada 10 veces en el run → desbloquea "Evolución de Combate" e "Inmunidad Temporal". |
| **Checkpoint Día 70** | resistencia ≥ 250 + haber obtenido "Evolución Post-Combate" al menos 5 veces → desbloquea "Mutación Permanente". |
| **Raza: Androide** | "Piel Adaptativa" se activa desde el 2° golpe del mismo tipo (en vez del 3°). "Memoria Biológica" dura 5 combates en lugar de 2. |
| **Sinergia con Regeneración** | Si Regeneración Tier 4+ está activa, la Evolución Reactiva también mejora la velocidad de regeneración en respuesta al daño recibido (+0.5% HP/s por cada tipo de daño adaptado). |

---
---

## 6. Manipulación de Explosiones

**Descripción:** La capacidad de generar, dirigir y controlar explosiones. Desde pequeñas detonaciones de distracción hasta supernovas que destruyen ciudades. El usuario puede no solo crear explosiones sino también absorberlas y redirigirlas. En Dragon Ascension, escala con fuerza y poder_ki.

### Niveles de poder en el juego

| Nivel | Escala | Requisito |
|-------|--------|-----------|
| Bajo | Auto explosion, granadas pequeñas | poder_ki ≥ 80, fuerza ≥ 80 |
| Medio | Explosión de edificio, vehículo | poder_ki ≥ 150, fuerza ≥ 130 |
| Alto | Destruir un bloque, nuclear | poder_ki ≥ 250, fuerza ≥ 200 |
| Cósmico | Supernova, Big Bang local | poder_ki ≥ 400, fuerza ≥ 300 |

---

### Pasivas

| Nombre | Efecto |
|--------|--------|
| **Absorción de Onda** | El jugador absorbe el 20% del daño de las explosiones propias y del enemigo como Ki (el cuerpo se acostumbra a la fuerza de las ondas). |
| **Radio de Terror** | Los ataques explosivos del jugador reducen el dodge del enemigo en 15% durante 3 segundos por el miedo a las ondas de choque. |
| **Propulsión** | El jugador puede usar pequeñas explosiones para moverse: el estado FlyState consume 30% menos Ki (propulsión explosiva más eficiente). |
| **Punto de Detonación** | Cada 3 ataques físicos consecutivos, el siguiente golpe explota en el impacto, haciendo daño de área adicional de ×0.8 sobre poder_ki. |
| **Inmunidad al Retroceso** | El jugador no recibe knockback de sus propias explosiones ni de las del enemigo. |

---

### Habilidades Activas

#### MICRO-DETONACIÓN *(STRIKE — Daño rápido + aturdimiento)*
> Una explosión concentrada en el punto de impacto. La onda de choque interna no deja escapatoria.
- **Costo de Ki:** 18%
- **Daño:** ×2.0 sobre fuerza + ×1.0 sobre poder_ki
- **Hit Count:** 1
- **Efecto especial:** Aturde al enemigo 0.8 segundos. Si conecta en un enemigo ya aturdido o derribado, el daño se duplica.
- **Cooldown:** 6.0s
- **Requisito de equipo:** poder_ki ≥ 80, fuerza ≥ 80

#### LLUVIA EXPLOSIVA *(KI_BLAST — Multi-proyectil)*
> El usuario lanza múltiples proyectiles explosivos en rápida sucesión, cubriendo todo el espacio del enemigo.
- **Costo de Ki:** 30%
- **Daño:** ×1.2 por proyectil sobre poder_ki
- **Hit Count:** 6
- **is_ranged:** true
- **Efecto especial:** Cada proyectil que impacta reduce el dodge del enemigo en 5% (acumulable durante la ráfaga).
- **Cooldown:** 10.0s
- **Requisito de equipo:** poder_ki ≥ 120, fuerza ≥ 100

#### ABSORCIÓN Y REDIRECCIONAMIENTO *(SUPPORT — Reflejo explosivo)*
> El usuario absorbe la energía explosiva del entorno y la devuelve multiplicada.
- **Costo de Ki:** 22%
- **Efecto:** Durante 5 segundos, el próximo ataque explosivo del enemigo (Ki Blast, Ultimate de energía) es absorbido y devuelto con ×1.8 del daño original. Si no hay ataque en ese tiempo, el Ki no se consume.
- **Cooldown:** 16.0s
- **Requisito de equipo:** poder_ki ≥ 140, ki ≥ 120

#### BOMBA DE CONCUSIÓN *(STRIKE — Área grande + derribo)*
> Una explosión de escala media que destruye el equilibrio del enemigo y todo lo que lo rodea.
- **Costo de Ki:** 35%
- **Daño:** ×3.0 sobre fuerza + ×2.0 sobre poder_ki
- **Hit Count:** 1
- **Efecto especial:** Knockback extremo. El enemigo queda derribado 2.5 segundos. El suelo del campo de combate queda "inestable" durante 8 segundos, reduciendo el dodge del enemigo en 20%.
- **Cooldown:** 14.0s
- **Requisito de equipo:** fuerza ≥ 150, poder_ki ≥ 160

#### SUPERNOVA *(ULTIMATE — Daño máximo absoluto)*
> El usuario concentra toda su energía explosiva en un punto singular y la detona. El resultado recuerda al nacimiento de una estrella.
- **Costo de Ki:** 85%
- **Daño:** ×8.0 sobre poder_ki + ×4.0 sobre fuerza
- **Hit Count:** 1
- **Efecto especial:** Imposible de esquivar. Ignora el 50% de la resistencia del enemigo. Si el nivel de explosión es "Cósmico" (poder_ki ≥ 400), ignora el 100% de la resistencia. Aturde al enemigo 4 segundos.
- **Cooldown:** 40.0s (1 uso por combate)
- **Requisito de equipo:** poder_ki ≥ 250, fuerza ≥ 200, ki ≥ 200

#### PROPULSIÓN DE COMBATE *(SUPPORT — Movilidad explosiva)*
> El usuario usa sus propias explosiones para moverse a velocidades imposibles, reposicionándose en un instante.
- **Costo de Ki:** 15%
- **Efecto:** El jugador se lanza a la posición del enemigo en un instante (como Dash Aéreo pero impulsado por explosión). El golpe al llegar tiene ×1.5 de fuerza de daño adicional por la inercia.
- **Cooldown:** 5.0s
- **Requisito de equipo:** fuerza ≥ 120, poder_ki ≥ 100

---

### Cómo Obtenerlo

| Método | Condición |
|--------|-----------|
| **Acción de día:** "Entrenamiento de Ki Ofensivo Explosivo"| Disponible día 8+. Sube poder_ki y fuerza. Activa "Punto de Detonación" al llegar a los umbrales base. |
| **Acción de día:** "Control de Explosiones" | Disponible día 25+. Requiere poder_ki ≥ 120. Desbloquea "Absorción de Onda" + habilidades de nivel medio. |
| **NPC: Experto en Combate Explosivo** | Relación media (≥55%). Enseña "Micro-Detonación" y "Lluvia Explosiva". |
| **NPC: Maestro de Destrucción** | Relación alta (≥80%). Enseña "Bomba de Concusión" y "Supernova". |
| **Checkpoint Día 35** | poder_ki ≥ 150 + fuerza ≥ 130 → activa "Radio de Terror" + "Inmunidad al Retroceso". |
| **Checkpoint Día 55** | poder_ki ≥ 200 + fuerza ≥ 160 → desbloquea nivel "Alto" y "Absorción y Redireccionamiento". |
| **Checkpoint Día 75** | poder_ki ≥ 280 + fuerza ≥ 220 → desbloquea nivel "Cósmico" y el bonus especial de Supernova. |
| **Minijuego: Directional Strike** | Completar con A+ → activa "Propulsión" e "Inmunidad al Retroceso". |
| **Sinergia con Vibraciones** | Si Manipulación de Vibraciones está activa: "Bomba de Concusión" genera ondas sísmicas que aplican el efecto de "Resonancia Interna" (daño residual) simultáneamente. |

---

## Tabla de Sinergias entre Habilidades

| Habilidad A | Habilidad B | Sinergia |
|-------------|-------------|---------|
| Manipulación de Luz | Precognición Tipo 4 | "Reescritura del Momento" activa "Velocidad Fotónica": el jugador actúa antes que la luz misma durante la ventana de invulnerabilidad. |
| Nulificación de Poder | Precognición Tipo 2+ | "Premonición de Peligro" detecta cuándo el enemigo intentará usar una habilidad. "Campo de Nulificación" la cancela antes de que sea activada. |
| Aura (Explosiva) | Manipulación de Explosiones | "Explosión de Aura" cuenta como un ataque explosivo para cargar "Punto de Detonación". "Absorción de Onda" recupera Ki de "Explosión de Aura" propia. |
| Evolución Reactiva | Gran Voluntad | "Llama Interior" + "Respuesta Inmediata" actúan en el mismo golpe recibido, sumando sus bonos de daño simultáneamente. Bajo HP = máximo poder. |
| Precognición Tipo 3+ | Puntos de Presión | "Visión del Combate" revela el momento exacto para "Punto Vital". Cuando el enemigo baja del 35% HP, la Precognición indica automáticamente el instante óptimo. |
| Aura (Terrorífica) | Nulificación de Poder | "Aura Terrorífica" reduce la voluntad del enemigo de activar habilidades, y "Suprimir" las cancela si aun así lo intenta. Combo de control total. |
| Manipulación de Luz | Evolución Reactiva | Si el enemigo usa ataques de luz/energía repetidamente, "Piel Adaptativa" + "Absorción Fotónica" convierten esos ataques en Ki recuperado. |
| Explosiones | Vibraciones | Ver Vibraciones: sinergia ya documentada. Las explosiones generan ondas sísmicas con daño residual de Resonancia Interna. |
