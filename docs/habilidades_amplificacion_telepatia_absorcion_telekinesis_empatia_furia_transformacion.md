# Habilidades: Amplificación de Estadísticas · Telepatía · Absorción · Telekinesis · Manipulación Empática · Poder de la Furia · Transformación

> Documento de diseño — Dragon Ascension
> Formato: Pasivas | Habilidades Activas (SkillData) | Adquisición

---

## 1. Amplificación de Estadísticas

### Descripción de Diseño
Representa la capacidad de un personaje de intensificar temporalmente sus parámetros durante el combate mediante un esfuerzo consciente de voluntad o técnica. No es una transformación ni un poder oculto: es puro dominio del propio cuerpo y de la energía que ya se posee. Ideal para builds orientadas al daño explosivo o a la supervivencia situacional.

---

### Pasivas

**Potencial Activo**
En combate, cada 10 % de Ki gastado acumulado otorga un +2 % de Fuerza y +2 % de Velocidad (máx. +20 % de cada stat). El contador se reinicia al morir o huir.

**Capacidad de Carga**
El límite máximo de los boosts de Amplificación se incrementa en +5 % por cada punto de Poder Ki que supere 30 (cap: +50 % adicional al límite de cada boost activo).

**Distribución Eficiente**
Cuando el personaje tiene activos simultáneamente dos o más habilidades de Amplificación, la reducción de duración de cada una se disminuye en un 20 % (duran un 20 % más).

**Sobrecarga Calculada**
Al terminar un boost de Amplificación de forma natural (sin ser cancelado), el stat amplificado se mantiene a un 15 % del bonus original durante 5 segundos adicionales.

---

### Habilidades Activas (SkillData)

**Impulso Focalizado** — SUPPORT
Ki: 15 · Cooldown: 18 s · Duración: 10 s
Aumenta un stat elegido (Fuerza, Velocidad o Resistencia) en +35 % durante 10 segundos. Solo un stat a la vez. Al vencer al enemigo durante el boost, el cooldown se resetea a la mitad.
*Requisito: Ki ≥ 40*

**Amplificación Dual** — SUPPORT
Ki: 30 · Cooldown: 28 s · Duración: 8 s
Aumenta Fuerza y Velocidad simultáneamente en +25 % durante 8 segundos. Usar esta habilidad mientras Impulso Focalizado está activo extiende ambos efectos 3 s extra en lugar de resetear el activo.
*Requisito: Ki ≥ 80, Fuerza ≥ 30*

**Pico de Rendimiento** — SUPPORT
Ki: 50 · Cooldown: 45 s · Duración: 6 s
Amplifica todos los stats simultáneamente en +20 % durante 6 segundos. Inflige 5 % del HP máximo del usuario como daño propio al activar (coste físico de la sobrecarga). Durante el efecto, los ataques son inaparables.
*Requisito: Ki ≥ 120, Vitalidad ≥ 40, Día ≥ 30*

**Amplificación Máxima** — ULTIMATE
Ki: 80 · Cooldown: 120 s · Duración: 12 s
Duplica todos los stats del personaje durante 12 segundos. Al terminar, el personaje queda a la mitad del Ki máximo y con los stats temporalmente reducidos al −10 % del base durante 8 segundos (coste de la sobrecarga). Stackea con transformaciones activas.
*Requisito: Ki ≥ 200, Poder Ki ≥ 60, Día ≥ 55*

---

### Adquisición

- **Entrenamiento de Intensidad** — Acción de día disponible desde el Día 5. Completar el minijuego de resistencia con puntuación S desbloquea el primer nivel (Impulso Focalizado).
- **Checkpoint de Stat** — Alcanzar 60 puntos totales en Fuerza + Velocidad entre los días 15–25 desbloquea Amplificación Dual.
- **Victoria bajo presión** — Ganar 3 combates seguidos sin huir ni usar SUPPORT activa antes del Día 40 desbloquea Pico de Rendimiento.
- **Run largo** — Sobrevivir hasta el Día 55 con al menos dos habilidades de Amplificación equipadas desbloquea Amplificación Máxima.
- **NPC: Maestro de Acondicionamiento** — Relación ≥ 3 con el NPC. Otorga Impulso Focalizado y reduce el requisito de Día de Amplificación Dual a Día 12.

---

## 2. Telepatía

### Descripción de Diseño
La Telepatía en combate se traduce en lectura del estado mental del enemigo: anticipación de movimientos, detección de intenciones y, en niveles altos, interferencia activa que sabotea la concentración o sincroniza al usuario con sus aliados. No daña directamente, pero otorga ventajas informativas masivas.

---

### Pasivas

**Lectura de Intenciones**
El usuario tiene un 20 % de probabilidad de recibir una advertencia visual (indicador en HUD) 0,5 segundos antes del próximo ataque del enemigo. Al subir Inteligencia ≥ 50 la probabilidad sube al 35 %.

**Mente Abierta**
Cuando el enemigo está por debajo del 40 % de HP, el usuario lee su desesperación: +15 % de daño propio contra ese enemigo durante el resto del combate.

**Escudo Empático**
La resistencia mental del usuario reduce el daño de los efectos de estado (miedo, confusión, control mental de jefes) en un 30 %.

**Sincronía Táctica** *(requiere aliado en futura fase multijugador o NPC aliado)*
Cuando un aliado activo ataca al mismo objetivo, el usuario obtiene +10 % de daño durante 3 segundos tras cada ataque del aliado.

---

### Habilidades Activas (SkillData)

**Interferencia Mental** — SUPPORT
Ki: 20 · Cooldown: 22 s · Duración: 8 s
Proyecta ruido telepático en la mente del enemigo: −20 % de Velocidad y −15 % de Fuerza del enemigo durante 8 segundos. El enemigo no puede activar transformaciones durante el efecto.
*Requisito: Inteligencia ≥ 30*

**Lectura Profunda** — SUPPORT
Ki: 10 · Cooldown: 35 s (1 uso/combate)
Escanea la mente del enemigo: revela su HP máximo, sus resistencias y el tipo de próximo ataque especial (texto en HUD). El efecto de "próximo ataque" persiste durante 60 s o hasta que el ataque se ejecute.
*Requisito: Inteligencia ≥ 50, Día ≥ 20*

**Proyección de Miedo** — STRIKE
Ki: 35 · Cooldown: 40 s
Envía una onda de terror psíquico: el enemigo entra en estado "Pánico" durante 5 s (−40 % Velocidad, ataca erráticamente, puede dañarse a sí mismo con un 25 % de probabilidad). El estado Pánico se interrumpe si el usuario ataca directamente.
*Requisito: Inteligencia ≥ 70, Poder Ki ≥ 40*

**Colapso Cognitivo** — ULTIMATE
Ki: 70 · Cooldown: 90 s
Sobrecarga mental masiva: el enemigo queda paralizado (sin acción) durante 4 segundos y sus stats se reducen en −30 % durante 15 segundos posteriores. Contra jefes la parálisis dura 2 s y el debuff se mantiene. Inutilizable si el enemigo tiene ≥ 80 % de HP.
*Requisito: Inteligencia ≥ 100, Día ≥ 45*

---

### Adquisición

- **Meditación Profunda** — Acción de día "Meditar" ×5 consecutivos desbloquea Interferencia Mental.
- **Evento: Encuentro Psíquico** — NPC especial en el Día 18–22 que desafía al jugador a un duelo mental (minijuego de memoria). Victorioso otorga Lectura Profunda.
- **Raza** — Personajes de raza Namekiano comienzan con Lectura de Intenciones (pasiva) activa desde el Día 1.
- **Inteligencia ≥ 70 + Día 30** — Desbloquea Proyección de Miedo automáticamente en el panel de habilidades.
- **Checkpoint Día 45** — Evaluación de build orientada a "Control" (Intel Combate + Inteligencia dominantes) otorga Colapso Cognitivo.

---

## 3. Absorción

### Descripción de Diseño
La Absorción es una de las habilidades más poderosas y versátiles del juego. Permite al usuario apropiarse de energía, materia o poder del entorno o del oponente. Se divide en subtipos con mecánicas distintas y se recomienda como habilidad de rama avanzada con un coste de desbloqueo significativo.

---

### Pasivas

**Hambre Latente**
Cada vez que el usuario recibe daño, absorbe un 3 % del daño recibido como Ki recuperado. Con Absorción de Energía activa, sube al 6 %.

**Acumulación Pasiva**
El usuario acumula "Carga de Absorción" en combate (1 punto por segundo, cap 10). Las habilidades activas de Absorción consumen carga y reducen su costo de Ki en 5 por punto gastado.

**Resistencia Absorbida**
Por cada tipo de daño que el usuario haya absorbido en este combate, gana +5 % de resistencia a ese tipo (máx. +25 % acumulando 5 tipos distintos).

**Retroalimentación**
Al absorber energía de un ataque enemigo, una fracción (10 % del daño absorbido) se retransmite al enemigo como daño de ki.

---

### Habilidades Activas (SkillData)

**Absorción de Energía** — SUPPORT
Ki: 0 (recarga Ki) · Cooldown: 20 s · Duración: 5 s
Durante 5 segundos, el próximo ataque de energía que impacte al usuario es absorbido: no causa daño y recupera Ki igual al 80 % del daño que habría recibido. Solo funciona contra ataques de Ki/energía, no ataques físicos.
*Requisito: Ki ≥ 60, Poder Ki ≥ 25*

**Drenaje Vital** — STRIKE
Ki: 25 · Cooldown: 30 s
Agarra al enemigo y drena su vitalidad: transfiere 15 % del HP máximo del enemigo como HP propio. Si el enemigo está por debajo del 30 % de HP, drena el doble. El agarre puede ser esquivado si el enemigo tiene Velocidad ≥ 1,5× la del usuario.
*Requisito: Fuerza ≥ 40, Día ≥ 25*

**Robo de Poder** — SUPPORT
Ki: 40 · Cooldown: 60 s · Duración: 20 s
Absorbe temporalmente el 20 % de todos los stats del enemigo: el usuario gana ese 20 % como bonus y el enemigo lo pierde durante 20 segundos. Stackea con Amplificación de Estadísticas. Al terminar, los stats vuelven a la normalidad.
*Requisito: Poder Ki ≥ 60, Inteligencia ≥ 40, Día ≥ 35*

**Gran Absorción** — ULTIMATE
Ki: 60 · Cooldown: 120 s · Duración: 30 s
Activa todos los subtipos de Absorción simultáneamente durante 30 s: inmunidad al próximo ataque de energía (Absorción de Energía), recuperación de HP continua del 2 % del max por segundo (Drenaje Vital pasivo), y −15 % a todos los stats del enemigo (Robo de Poder reducido). Al finalizar el efecto, el usuario recupera 30 Ki adicionales.
*Requisito: Tener al menos dos habilidades de Absorción previas desbloqueadas, Día ≥ 60*

---

### Adquisición

- **Evento: Ser Absorbente** — Encuentro con un enemigo que use Absorción en combate (días 20–35). Sobrevivir y derrotarlo desbloquea Absorción de Energía.
- **Raza Majin / Celula (raza custom)** — Desbloquea Drenaje Vital desde el Día 1 como habilidad racial.
- **Entrenamiento Avanzado de Ki** — Acción de día "Manipulación de Ki Extrema" (disponible Día 30+) completada con rango S desbloquea Robo de Poder.
- **NPC: Científico Loco** — Relación ≥ 4. En el Día 40–50 entrega documentos de investigación que desbloquean Gran Absorción.
- **New Game+** — Gran Absorción también disponible desde el inicio del NG+ si se completó el árbol de Absorción en el run anterior.

---

## 4. Telekinesis

### Descripción de Diseño
La Telekinesis es control ambiental puro. En combate permite manipular el espacio de batalla, inmovilizar al enemigo, crear barreras, lanzar proyectiles improvisados o potenciar el cuerpo propio. Es una de las habilidades de mayor utilidad táctica y se presta a combos creativos.

---

### Pasivas

**Campo Gravitatorio**
Los proyectiles del enemigo dirigidos al usuario tienen un 15 % de probabilidad de ser desviados hacia otra dirección. Al alcanzar Poder Ki ≥ 80, la probabilidad sube al 30 %.

**Cuerpo Telekinético**
La telekinesis refuerza pasivamente el cuerpo del usuario: +10 % de Resistencia permanente en combate. Acumula +5 % adicional por cada 2 habilidades activas de Telekinesis equipadas.

**Ancla Mental**
Cuando el usuario está en el aire (FlyState activo), la Telekinesis refuerza su posición: −30 % de retroceso al recibir golpes y +10 % de daño en ataques aéreos.

**Cadena Psíquica**
Al golpear al enemigo con un ataque físico mientras Telekinesis está activa (cualquier habilidad), el impacto hace que el enemigo sea arrastrado 50 unidades adicionales hacia atrás.

---

### Habilidades Activas (SkillData)

**Agarre Telekinético** — SUPPORT
Ki: 20 · Cooldown: 25 s · Duración: 3 s
Inmoviliza al enemigo en el lugar durante 3 segundos (no puede moverse ni atacar). Durante la inmovilización, el daño recibido por el enemigo aumenta un 25 %. El efecto se cancela si el usuario recibe un golpe.
*Requisito: Poder Ki ≥ 30*

**Lanzamiento** — STRIKE
Ki: 30 · Cooldown: 18 s
Levanta telekinéticamente al enemigo y lo lanza contra el borde del escenario o contra el suelo con fuerza. Daño: Poder Ki × 1,8. Si el enemigo choca contra un límite del mapa, queda aturdido 1,5 s adicionales.
*Requisito: Poder Ki ≥ 50, Día ≥ 15*

**Barrera Psíquica** — SUPPORT
Ki: 35 · Cooldown: 35 s · Duración: 6 s
Crea una barrera telekinética que bloquea el siguiente ataque físico Y el siguiente ataque de Ki recibidos. Al absorber el ataque de Ki, la energía se almacena y puede liberarse con el próximo ki blast del usuario como bonus de daño (+50 %). La barrera se destruye tras bloquear ambos ataques o al fin de duración.
*Requisito: Poder Ki ≥ 70, Inteligencia ≥ 35*

**Tormenta Telekinética** — ULTIMATE
Ki: 90 · Cooldown: 100 s
Levanta y lanza simultáneamente al enemigo, fragmentos del escenario (rocas, escombros) y ondas de presión mental en un ataque multifase durante 4 segundos. Daño total: Poder Ki × 4,5 repartido en 6 impactos. Cada impacto tiene un 20 % de probabilidad de aturdir 0,5 s. Rompe barreras y escudos del enemigo.
*Requisito: Poder Ki ≥ 100, Velocidad ≥ 50, Día ≥ 50*

---

### Adquisición

- **Desarrollo Natural de Ki** — Al acumular 100 puntos de Ki + Poder Ki combinados, se desbloquea Agarre Telekinético automáticamente.
- **Evento: Objeto en Movimiento** — En el Día 10–20 aparece un evento en el que objetos se mueven solos cerca del personaje. Investigarlo (acción de día) desbloquea el pasivo Campo Gravitatorio y Agarre Telekinético.
- **NPC: Anciano Sabio** — Relación ≥ 3 antes del Día 30. Enseña Lanzamiento y Barrera Psíquica simultáneamente.
- **Entrenamiento de Ki Extremo (Día 45+)** — Minijuego de concentración mental con rango S+ desbloquea Tormenta Telekinética.
- **Raza Namekiano** — Bonus: Barrera Psíquica disponible desde el Día 1 sin requisito de Poder Ki (pero sí de Ki ≥ 25).

---

## 5. Manipulación Empática

### Descripción de Diseño
La Manipulación Empática opera en la capa emocional del combate. El usuario puede debilitar al enemigo induciéndole miedo, culpa o dolor emocional, o potenciar su propia performance canalizando emociones positivas. Sinergia natural con Telepatía y Gran Fuerza de Voluntad.

---

### Pasivas

**Empatía Combativa**
El usuario lee las emociones del enemigo en tiempo real: cuando el enemigo tiene Miedo activo (HP < 35 %), el usuario gana +20 % de Velocidad. Cuando el enemigo tiene Rabia activa (HP < 50 % y está infligiendo daño), el usuario gana +15 % de Resistencia.

**Resonancia Emocional**
Cada habilidad de Manipulación Empática aplicada sobre el enemigo reduce el cooldown de las demás en 4 segundos. Máximo 1 reducción por habilidad activa.

**Aura de Calma**
El usuario es inmune al efecto de estado "Pánico" (otorgado por Proyección de Miedo de Telepatía y efectos similares). Además, reduce el daño de ataques de rabia del enemigo (tipo Poder de la Furia) en un 20 %.

**Lazo Empático**
Cuando un aliado NPC está en combate, el usuario absorbe pasivamente un 10 % del daño que el aliado habría recibido como Ki propio (el aliado no toma ese daño, el usuario convierte el 10 % en Ki).

---

### Habilidades Activas (SkillData)

**Inducción de Miedo** — SUPPORT
Ki: 20 · Cooldown: 28 s · Duración: 10 s
Proyecta terror emocional sobre el enemigo: −25 % de Fuerza y −20 % de Velocidad durante 10 s. Si el enemigo ya está por debajo del 50 % de HP, el efecto se amplía a −35 % de ambos stats.
*Requisito: Inteligencia ≥ 25, Intel Combate ≥ 20*

**Sobrecarga de Culpa** — STRIKE
Ki: 35 · Cooldown: 45 s
Satura al enemigo con emociones de arrepentimiento y culpa. El enemigo se inmoviliza 2 s y pierde un 8 % de HP adicional por segundo durante 4 s (daño emocional, ignora Resistencia). Total potencial: −40 % HP en 4 s + inmovilización inicial.
*Requisito: Inteligencia ≥ 50, Día ≥ 28*

**Impulso Aliado** — SUPPORT
Ki: 15 · Cooldown: 20 s · Duración: 15 s
Canaliza energía emocional positiva hacia el usuario (o aliado si existe): +30 % de Fuerza y +20 % de Velocidad durante 15 s. Acumula con Amplificación de Estadísticas. Reduce también el cooldown de todas las habilidades activas del usuario en 3 s al activarse.
*Requisito: Intel Combate ≥ 30*

**Catarsis Total** — ULTIMATE
Ki: 65 · Cooldown: 90 s
Libera una onda de energía emocional masiva: el usuario se cura un 25 % de su HP máximo, el enemigo queda con todos sus stats reducidos en −20 % durante 20 s y entra en estado "Desesperación" (no puede activar transformaciones ni ultimates durante ese tiempo). Escala con Inteligencia: por cada 20 puntos de Intel sobre 40, el heal sube +5 %.
*Requisito: Inteligencia ≥ 60, Intel Combate ≥ 50, Día ≥ 40*

---

### Adquisición

- **NPC: Consejero / Monje** — Relación ≥ 2 antes del Día 20. Desbloquea Inducción de Miedo e Impulso Aliado.
- **Evento: Crisis Emocional** — Evento narrativo en torno al Día 25 donde el personaje enfrenta una pérdida o traición. Superarlo desbloquea Sobrecarga de Culpa.
- **Build Estratégica** — Al tener Intel Combate + Inteligencia como stats dominantes en el Checkpoint del Día 35, se desbloquea Resonancia Emocional (pasiva) y acceso a Catarsis Total.
- **Requisito de Telepatía** — Si el jugador ya tiene Interferencia Mental (de Telepatía), el costo de Ki de todas las habilidades de Manipulación Empática se reduce en 5.

---

## 6. Poder de la Furia

### Descripción de Diseño
El Poder de la Furia convierte el dolor emocional y la rabia en energía de combate. Cuanto más daño recibe el usuario o más difícil se vuelve el combate, mayor es el potencial de poder. Es un pago de riesgo-recompensa: el jugador que no huye y absorbe el castigo recibe una ventaja creciente. Diferente al Modo Berserk (que es incontrolado), la Furia aquí es dirigida.

---

### Pasivas

**Llama de Combate**
Por cada 10 % de HP que el usuario pierda durante el combate (no recuperable), gana +8 % de daño permanente durante esa pelea. Máximo: +80 % al 10 % de HP.

**Catalizador de Rabia**
La primera vez que el usuario alcanza el 50 % de HP en un combate, su Velocidad aumenta en +15 % de forma permanente durante esa pelea.

**Aguante de Hierro**
Cuando el Poder de la Furia está activo (cualquier habilidad de Furia encendida), la Resistencia del usuario sube un 20 % adicional. El usuario no puede ser intimidado (inmune a efectos de miedo).

**Furia Acumulada**
Cada golpe recibido sin contraatacar dentro de los últimos 3 segundos añade un stack de "Furia" (máx. 5). Cada stack otorga +4 % de daño al próximo ataque físico del usuario. Los stacks se consumen en el primer ataque.

---

### Habilidades Activas (SkillData)

**Arrebato de Rabia** — STRIKE
Ki: 10 · Cooldown: 15 s
Libera un golpe cargado de rabia pura. Daño: Fuerza × 2,0 + 5 % del HP total perdido en el combate como daño bonus. Si el usuario tiene HP < 50 %, el multiplicador de Fuerza sube a ×2,8.
*Requisito: Fuerza ≥ 25*

**Berserker Controlado** — SUPPORT
Ki: 30 · Cooldown: 50 s · Duración: 12 s
Entra en un estado de rabia dirigida: +40 % de Fuerza, −15 % de Resistencia durante 12 s. Durante el estado, el usuario no puede usar habilidades SUPPORT ni ULTIMATE, pero los cooldowns de STRIKE se reducen a la mitad. Al terminar, recupera un 10 % de HP.
*Requisito: Fuerza ≥ 50, Vitalidad ≥ 30, Día ≥ 20*

**Venganza** — STRIKE
Ki: 40 · Cooldown: 60 s
Solo usable si el usuario ha recibido daño en los últimos 5 segundos. Daño: Fuerza × 1,5 + 80 % del daño recibido en los últimos 5 s como daño adicional (el dolor se convierte en fuerza ofensiva). Si este golpe reduce al enemigo a menos del 20 % de HP, el cooldown se resetea completamente.
*Requisito: Fuerza ≥ 60, Vitalidad ≥ 40, Día ≥ 30*

**Explosión de Furia** — ULTIMATE
Ki: 0 (no requiere Ki) · Cooldown: 80 s · Activable solo si HP < 40%
Libera toda la rabia acumulada en un ataque devastador: daño = (HP máximo − HP actual) × 2,5. Si el usuario está a menos del 15 % de HP, el multiplicador sube a ×3,5. El usuario recupera 20 % de HP tras el golpe. Este ataque no puede ser bloqueado.
*Requisito: Fuerza ≥ 80, Vitalidad ≥ 50, Día ≥ 45*

---

### Adquisición

- **Primera Derrota** — Al perder el primer combate del run, se desbloquea el pasivo Llama de Combate automáticamente (el dolor enseña).
- **Combate de Supervivencia** — Ganar un combate con menos del 15 % de HP desbloquea Arrebato de Rabia.
- **Evento: Provocación del Enemigo** — En el Día 20–30, un NPC enemigo humilla al personaje. La reacción de rabia desbloquea Berserker Controlado.
- **Checkpoint de Resistencia** — Completar el Checkpoint del Día 35 con Fuerza + Vitalidad dominantes en el build desbloquea Venganza.
- **Furia Extrema** — Haber usado Arrebato de Rabia + Berserker Controlado en un mismo combate en al menos 3 ocasiones desbloquea Explosión de Furia.
- **Raza Saiyan** — Todos los pasivos de Poder de la Furia se activan ante la muerte de un aliado (Saiyan Rage). Arrebato de Rabia se desbloquea desde el Día 1.

---

## 7. Transformación

### Descripción de Diseño
A diferencia de las Transformaciones totales del sistema principal (Super Saiyan, Kaioken, etc.), esta habilidad representa modificaciones parciales y controladas del cuerpo: endurecer la piel, agrandar un miembro, reforzar un órgano. No es un cambio de forma completo ni desbloquea habilidades nuevas: potencia lo que ya existe. Complementa el sistema de Transformaciones sin reemplazarlo.

---

### Pasivas

**Adaptación Física**
Cada combate aumenta permanentemente la eficiencia del cuerpo en un 0,5 % (acumulativo, máx. +15 % global). Este bonus se aplica a todos los stats en combate como un multiplicador silencioso.

**Cuerpo Forjado**
Mientras cualquier habilidad activa de Transformación está en uso, los ataques físicos recibidos reducen su daño en un 8 % adicional a la Resistencia base.

**Transformación Sostenida**
La duración de todas las transformaciones parciales activas se extiende +3 segundos. Si el usuario tiene activa una Transformación del sistema principal simultáneamente, el bonus sube a +6 segundos.

**Reversión Rápida**
Al terminar una habilidad de Transformación parcial, el usuario recupera un 5 % de Ki. Si la transformación fue cancelada manualmente (no por duración), recupera un 10 % en su lugar.

---

### Habilidades Activas (SkillData)

**Piel de Acero** — SUPPORT
Ki: 15 · Cooldown: 20 s · Duración: 10 s
Endurece la piel del usuario: +30 % de Resistencia durante 10 s. Los primeros 2 golpes recibidos durante el efecto no provocan retroceso (el usuario no es empujado). Acumula con la Resistencia base y las transformaciones del sistema principal.
*Requisito: Vitalidad ≥ 30, Resistencia ≥ 20*

**Extremidades Potenciadas** — SUPPORT
Ki: 20 · Cooldown: 22 s · Duración: 8 s
Modifica temporalmente los miembros del usuario: +35 % de Fuerza y +20 % de Velocidad de ataque durante 8 s. El rango de los ataques físicos aumenta ligeramente (+15 % de alcance). Stackea con Amplificación de Estadísticas.
*Requisito: Fuerza ≥ 35, Velocidad ≥ 25, Día ≥ 15*

**Adaptación de Combate** — SUPPORT
Ki: 30 · Cooldown: 40 s · Duración: 15 s
El cuerpo se adapta al tipo de daño predominante del enemigo: gana +25 % de resistencia al tipo de ataque más reciente recibido. Si el enemigo alterna tipos, el bonus se aplica al último recibido. Complementa la pasiva Piel Adaptativa de Evolución Reactiva si ambas están desbloqueadas (en ese caso el bonus sube a +40 %).
*Requisito: Resistencia ≥ 40, Vitalidad ≥ 40, Día ≥ 25*

**Transformación Límite** — ULTIMATE
Ki: 70 · Cooldown: 90 s · Duración: 20 s
Transforma parcialmente todo el cuerpo al límite físico posible: +50 % de todos los stats durante 20 s. No es una transformación del sistema principal: no requiere maestría ni Ki especial, pero tampoco habilita las ventajas de las transformaciones completas. Al terminar, el usuario sufre −10 % en todos los stats durante 10 s (fatiga de la sobrecarga muscular y celular).
*Requisito: Fuerza ≥ 60, Vitalidad ≥ 50, Resistencia ≥ 40, Día ≥ 40*

---

### Adquisición

- **Entrenamiento Físico Extremo** — Completar 10 días de entrenamiento físico (cualquier acción de Fuerza/Velocidad) desbloquea Piel de Acero.
- **Checkpoint del Día 15** — Personaje con Fuerza + Vitalidad + Resistencia como stats dominantes desbloquea Extremidades Potenciadas.
- **Evento: Mutación Menor** — En el Día 22–30, evento donde el cuerpo del personaje reacciona a un combate difícil con una micro-mutación. Desbloquea Adaptación de Combate.
- **Maestría en Transformaciones** — Tener al menos una transformación del sistema principal con ≥ 50 % de maestría desbloquea el pasivo Transformación Sostenida y Transformación Límite.
- **Raza Androide** — Transformación parcial reemplazada por "Mejora de Sistema": mismas mecánicas pero sin el costo de fatiga al terminar Transformación Límite.

---

## Tabla de Sinergias Cruzadas

| Habilidad A | Habilidad B | Sinergia |
|---|---|---|
| Amplificación Máxima | Transformación Límite | Ambas activas → duración de Amplificación +5 s, stat bonus se multiplican |
| Telepatía (Interferencia Mental) | Manipulación Empática (Inducción de Miedo) | Debuffs se acumulan: −40 % Vel y −35 % Fuerza combinados |
| Absorción de Energía | Telekinesis (Barrera Psíquica) | Activar ambas: el Ki absorbido por la Barrera se añade al pool de Absorción |
| Poder de la Furia (Explosión) | Amplificación (Pico de Rendimiento) | Pico de Rendimiento activo antes de Explosión de Furia → multiplicador ×4,0 en lugar de ×2,5 |
| Telekinesis (Agarre) + Arrebato de Rabia | — | Agarre inmoviliza 3 s; Arrebato usado durante el agarre no puede ser esquivado |
| Manipulación Empática (Catarsis Total) | Regeneración (cualquier tier) | Heal de Catarsis se aplica antes que la Regen, maximizando el HP base sobre el que regenera |
| Absorción (Robo de Poder) | Amplificación Dual | Los stats robados se amplifican con el bonus de Amplificación: efecto neto mayor |
| Transformación Límite | Sistema de Transformaciones (principal) | Transformación parcial stackea con la transformación completa activa — no se anulan mutuamente |
| Telepatía (Lectura de Intenciones) | Precognición (cualquier tipo) | La advertencia de Telepatía y la ventana de Precognición se combinan: window de esquive doble |
