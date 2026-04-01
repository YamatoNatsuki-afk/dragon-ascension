# Habilidades: Gravedad · Espacio · PES · Petrificación · Interacción No-Física · Espacial · Temporal · Time Stop · Sellado · Borrado Existencial · Zero Absoluto · Danmaku · Calor · Sigilo · Acción Instintiva · Parálisis · Magma

> Documento de diseño — Dragon Ascension
> Formato: Pasivas | Habilidades Activas (SkillData) | Adquisición
> Nota de escala: Habilidades marcadas con ★ son endgame (Día 50+). Las marcadas con ★★ son NG+ exclusivas.

---

## 1. Manipulación de la Gravedad

### Descripción de Diseño
La Gravedad opera como una fuerza de campo que afecta la posición, velocidad y resistencia del enemigo en el escenario. Puede atraer (acercar), repeler (lanzar) o comprimir (daño de aplastamiento). En niveles altos, genera singularidades gravitacionales que actúan como trampas de área. Es un contrapoder natural de la Telekinesis (ambas manipulan la posición del enemigo pero por mecanismos distintos) y de la Teletransportación (la gravedad extrema puede anclar al enemigo).

**Regla especial:** Los efectos gravitacionales ignoran la Resistencia física del enemigo (la gravedad no es un golpe — es una fuerza de entorno). Sin embargo, enemigos con Manipulación Espacial o Temporal son inmunes.

---

### Pasivas

**Gravedad Personal**
El usuario tiene un campo gravitacional propio: los proyectiles del enemigo tienen un 15 % de probabilidad de ser ligeramente desviados de su trayectoria. Contra proyectiles de Ki, la probabilidad sube al 20 %.

**Masa Aumentada**
El usuario puede incrementar su propia densidad pasivamente: +15 % de Resistencia al impacto físico. El retroceso al recibir golpes se reduce un 30 %.

**Atracción de Energía**
Cuando el usuario tiene activo un campo gravitacional (cualquier habilidad de Gravedad activa), recupera 2 Ki por segundo pasivamente al "atraer" energía ambiental.

**Dominancia Gravitacional**
Cada habilidad de Gravedad aplicada sobre el mismo enemigo en el mismo combate aumenta su efecto en un 10 % acumulativo (máx. +40 %).

---

### Habilidades Activas (SkillData)

**Campo Gravitacional** — SUPPORT
Ki: 25 · Cooldown: 20 s · Duración: 10 s
Crea un campo de alta gravedad alrededor del enemigo: −30 % de Velocidad y −20 % de Fuerza (el peso aumentado les dificulta moverse y atacar). Ignora Resistencia. Los ataques a distancia del enemigo pierden un 25 % de alcance (la gravedad desvía los proyectiles).
*Requisito: Poder Ki ≥ 40*

**Impulso Gravitacional** — STRIKE
Ki: 35 · Cooldown: 25 s
Invierte la gravedad local sobre el enemigo y lo lanza verticalmente: daño Poder Ki × 2,0 al impactar el suelo. Si el escenario tiene techo (futuras escenas cerradas), el enemigo también impacta el techo (daño doble). En escenario abierto, el enemigo queda con −20 % de Velocidad durante 5 s (desorientación post-caída).
*Requisito: Poder Ki ≥ 60, Día ≥ 20*

**Zona de Aplastamiento** ★ — SUPPORT
Ki: 50 · Cooldown: 50 s · Duración: 8 s
Genera un punto de gravedad extrema sobre el enemigo: el enemigo recibe 4 % del HP máximo como daño por segundo (aplastamiento), queda ralentizado −50 % de Velocidad, y no puede usar Teletransportación ni Vuelo durante la duración. Si el enemigo tiene Inmortalidad activa, el daño por segundo se aplica igualmente (ignora resistencia a daño, no la inmortalidad).
*Requisito: Poder Ki ≥ 90, Inteligencia ≥ 50, Día ≥ 40*

**Singularidad** ★ — ULTIMATE
Ki: 85 · Cooldown: 110 s (1 uso/combate)
Crea un micro agujero negro en el centro del escenario durante 6 s: atrae al enemigo continuamente hacia el centro (imposible resistir sin Manipulación Espacial/Temporal), inflige daño de 6 % del HP máximo por segundo, y anula todos los efectos de movimiento del enemigo. Al terminar, la singularidad colapsa y emite una onda de repulsión que lanza al enemigo al borde del mapa (posible BFR). El usuario es inmune al efecto de atracción.
*Requisito: Poder Ki ≥ 130, Inteligencia ≥ 70, Día ≥ 55*

---

### Adquisición

- **Entrenamiento de Alta Gravedad** — Acción de día "Gravedad Extrema" (disponible Día 15+) ×5 desbloquea Campo Gravitacional y el pasivo Masa Aumentada.
- **NPC: Científico Cósmico** — Relación ≥ 3 antes del Día 30. Enseña Impulso Gravitacional.
- **Checkpoint de Poder Ki** — Alcanzar Poder Ki ≥ 90 antes del Día 40 desbloquea Zona de Aplastamiento.
- **Sinergia Espacial** — Tener Creación de Portales + Manipulación de la Gravedad activos desbloquea Singularidad.
- **Raza Saiyajin** — Entrenamiento en gravedad aumentada es parte de su historia: Campo Gravitacional disponible desde el Día 5 sin requisito de Poder Ki.

---

## 2. Espacio (Sistema de Resistencia al Vacío)

### Descripción de Diseño
El "Espacio" no es una habilidad de combate estándar sino un **sistema de resistencia pasiva** que permite al personaje operar en entornos espaciales o extremos. Se implementa como un árbol de resistencias que se desbloquea progresivamente y que es prerequisito para el Vuelo Espacial avanzado y para combates en escenarios cósmicos (futuras expansiones).

**Resistencia Tipo 1 (Minutos en el Espacio):** Protección contra radiación cósmica, pérdida de oxígeno y exposición UV. En términos de juego: inmunidad a efectos de estado "Radiación" y "Asfixia" que podrían aplicar ciertos jefes cósmicos.

**Resistencia Tipo 2 (Horas en el Espacio):** Adaptación fisiológica completa: el personaje no sufre pérdida de stats por ambientes de microgravedad, temperaturas extremas, ni cambios de presión. Permite combatir en escenarios espaciales sin penalizaciones.

---

### Pasivas

**Adaptación al Vacío I (Tipo 1)**
Inmunidad a efectos de estado "Radiación Cósmica" y "Asfixia" en combate. El usuario puede operar sin oxígeno durante un combate completo sin penalizaciones.

**Adaptación al Vacío II (Tipo 2)**
El usuario es inmune a penalizaciones de temperatura extrema (calor estelar o frío del vacío). Las habilidades de Hielo del enemigo pierden un 15 % de efectividad contra este usuario.

**Cuerpo Estelar**
El usuario ha interiorizado las leyes del cosmos: en cualquier escenario de combate, sus habilidades de Ki viajan sin fricción (como en el vacío) — los proyectiles del usuario tienen un 10 % más de velocidad y alcance.

**Resistencia Cósmica**
El usuario gana +20 % de Resistencia contra cualquier ataque basado en fuerzas cósmicas (gravedad, radiación, calor estelar, vacío).

---

### Adquisición

- **Vuelo Espacial prerequisito** — Desbloquear Vuelo Espacial activa automáticamente Adaptación al Vacío I.
- **Completar Vuelo Espacial avanzado** — Usar Bombardeo Atmosférico en 5 combates activa Adaptación al Vacío II.
- **Entrenamiento Cósmico** — Acción de día "Meditación Cósmica" (Día 40+) ×3 activa Cuerpo Estelar.
- **Raza Saiyajin** — Resistencia Cósmica activa desde el Día 1 (su fisiología ya es resistente al espacio).

---

## 3. Percepción Extrasensorial (PES)

### Descripción de Diseño
La PES es la habilidad de información por excelencia: no hace daño directamente, pero otorga al usuario conocimiento que ninguna otra habilidad puede proporcionar. Detecta Ki oculto, lee niveles de poder, ve seres invisibles, y anticipa movimientos. Es la versión más amplia de Detección (documento 3), con aplicaciones que van más allá del Ki y tocan lo espiritual y lo conceptual.

---

### Pasivas

**Radar de Ki**
El usuario siente cualquier fuente de Ki en el escenario sin excepción. Detecta al enemigo aunque esté invisible (Maestría del Sigilo), aunque suprima su Ki, o aunque use ilusiones de posición. La posición real siempre es visible en el HUD como un marcador.

**Lectura de Poder**
Al inicio de cada combate, el usuario lee automáticamente el poder total del enemigo: el HUD muestra su tier aproximado y si es superior, igual o inferior al usuario. Si el enemigo tiene Supresión de Ki activa, la lectura muestra "SUPRIMIDO" en lugar del valor real.

**Vista Espiritual**
El usuario puede ver y detectar entidades no-físicas: los enemigos de tipo "No-Muerto", "Espíritu" o "Astral" son completamente visibles y atacables normalmente. Sinergia directa con Interacción No-Física.

**Sentido Sexto Combativo**
Cuando el usuario no puede ver al enemigo (oscuridad, invisibilidad avanzada), su PES suple la visión: no hay penalización de precisión y puede contraatacar normalmente.

---

### Habilidades Activas (SkillData)

**Escaneo Profundo** — SUPPORT
Ki: 10 · Cooldown: 45 s (1 uso/combate)
Escanea completamente al enemigo: revela HP actual y máximo, todos sus stats, resistencias activas, habilidades equipadas (listadas en HUD), y el tipo de próximo ataque especial. La información persiste visible durante todo el combate. Si el enemigo tiene Ocultamiento de Poder, el escaneo falla y solo revela "PODER DESCONOCIDO".
*Requisito: Inteligencia ≥ 30*

**Detección Dimensional** — SUPPORT
Ki: 20 · Cooldown: 30 s · Duración: 20 s
El usuario expande su PES más allá del plano físico: detecta cualquier efecto oculto activo sobre el enemigo (venenos, sellos, ilusiones propias o ajenas), puede ver a través de cualquier ilusión durante la duración, e identifica si el enemigo tiene Inmortalidad activa y de qué tipo. Revela también si el enemigo planea usar una habilidad en los próximos 3 s.
*Requisito: Inteligencia ≥ 50, Día ≥ 20*

**Bloqueo de Aura** — SUPPORT
Ki: 35 · Cooldown: 40 s · Duración: 15 s
El usuario emite un pulso de PES que interfiere con el Ki del enemigo: el enemigo no puede ocultar su poder, no puede activar Supresión de Ki, y sus transformaciones consumen el doble de Ki durante la duración. Además, el usuario recibe una advertencia visual 1 s antes de cada ataque del enemigo (lectura anticipada del movimiento muscular y de Ki).
*Requisito: Inteligencia ≥ 60, Intel Combate ≥ 40, Día ≥ 30*

**Conciencia Omnidireccional** ★ — ULTIMATE
Ki: 60 · Cooldown: 80 s · Duración: 20 s
El usuario alcanza una conciencia total del combate: esquive automático del 35 % de todos los ataques (la PES anticipa cada movimiento), daño aumentado un 25 % (conoce perfectamente los puntos débiles del enemigo), e inmunidad a ilusiones y fintas. Durante el efecto, el Escaneo Profundo y Detección Dimensional se activan automáticamente sin costo adicional.
*Requisito: Inteligencia ≥ 80, Intel Combate ≥ 60, Día ≥ 45*

---

### Adquisición

- **Meditación** — Acción de día "Meditar" ×5 consecutivos desbloquea Escaneo Profundo y el pasivo Radar de Ki.
- **Sinergia Detección** — Si el jugador tiene la habilidad Detección (documento 3), Radar de Ki y Lectura de Poder se activan automáticamente sin adquisición adicional.
- **Evento: El Sabio Ciego** — NPC especial del Día 20–30 que ve sin ojos. Relación ≥ 2 enseña Detección Dimensional.
- **Checkpoint de Inteligencia** — Alcanzar Inteligencia ≥ 60 + Intel Combate ≥ 40 desbloquea Bloqueo de Aura.
- **Maestría de PES** — Usar Escaneo Profundo en 10 combates distintos desbloquea Conciencia Omnidireccional.

---

## 4. Petrificación

### Descripción de Diseño
La Petrificación convierte al enemigo en piedra, eliminando completamente su capacidad de acción. Es una de las pocas habilidades del juego que puede resultar en una victoria sin reducir el HP a 0 — un enemigo completamente petrificado es una victoria por incapacitación. Ignora la Resistencia física convencional (piedra no depende de la dureza del cuerpo). Su contrapoder es la habilidad de salir de la petrificación por fuerza pura (alta Fuerza del enemigo puede romper la piedra).

**Mecánica de Petrificación:** Se aplica en capas (1-3). Con 3 capas el enemigo está completamente petrificado. Cada capa reduce la Velocidad del enemigo un 25 %. Con 3 capas completas: victoria por petrificación si el enemigo no puede romper la piedra en 5 s.

---

### Pasivas

**Mirada Pétrea**
Los ataques físicos del usuario tienen un 8 % de probabilidad de aplicar 1 capa de Petrificación al impactar.

**Dominio del Mineral**
El usuario puede trabajar con piedra y tierra de forma natural: las habilidades de Manipulación de la Tierra cuestan 10 Ki menos (si está disponible). Los escudos de piedra propios duran un 25 % más.

**Resistencia Pétrea**
El usuario tiene una capa fina de mineral en la piel: +10 % de Resistencia pasiva. Si el enemigo tiene Petrificación, el usuario es inmune a ella.

**Fractura Estratégica**
Cuando un enemigo tiene al menos 1 capa de Petrificación activa, todos los ataques del usuario ganan +20 % de daño (la piedra crea puntos de fractura).

---

### Habilidades Activas (SkillData)

**Mirada de Piedra** — KI_BLAST
Ki: 25 · Cooldown: 18 s
Proyecta energía petrificante al enemigo: aplica 1 capa de Petrificación (−25 % de Velocidad). Si el enemigo ya tiene 1 capa, este ataque aplica 2 capas directamente. Si el enemigo tiene Resistencia ≥ 80, la probabilidad de aplicar cada capa se reduce un 20 %.
*Requisito: Poder Ki ≥ 40, Inteligencia ≥ 25*

**Oleada Pétrea** — KI_BLAST
Ki: 40 · Cooldown: 30 s
Onda de energía mineral de área amplia: aplica 2 capas de Petrificación directamente. Si el enemigo ya tenía 1 capa, queda completamente petrificado (3 capas — inmovilización total). Daño directo: Poder Ki × 1,5 (la energía mineral también golpea).
*Requisito: Poder Ki ≥ 65, Día ≥ 22*

**Estatua Viviente** ★ — ULTIMATE
Ki: 70 · Cooldown: 90 s (1 uso/combate)
Petrificación completa instantánea: aplica 3 capas de golpe. El enemigo queda completamente inmóvil durante 5 s. Si la Fuerza del enemigo es ≥ 2× la del usuario, rompe la piedra en 3 s en lugar de 5. Si el enemigo está al 30 % de HP o menos, la petrificación es permanente (victoria por incapacitación). Funciona incluso contra enemigos con Inmortalidad Tipo 1 y 2 (petrifica el cuerpo sin matarlo).
*Requisito: Poder Ki ≥ 90, Inteligencia ≥ 50, Día ≥ 40*

---

### Adquisición

- **Evento: El Ser Petrificador** — Combate especial del Día 18–28 contra un enemigo que usa Petrificación (referencia a Dabura). Sobrevivir desbloquea Mirada de Piedra.
- **Sinergia Tierra** — Tener Manipulación de la Tierra desbloqueada reduce el cooldown de todas las habilidades de Petrificación en 5 s.
- **NPC: El Escultor** — Relación ≥ 3 antes del Día 30. Enseña Oleada Pétrea.
- **Maestría de Petrificación** — Petrificar completamente al enemigo en 5 combates distintos desbloquea Estatua Viviente.

---

## 5. Interacción No-Física

### Descripción de Diseño
Esta habilidad resuelve un problema de targeting: ciertos enemigos del juego son intangibles por naturaleza (No-Muertos, Espíritus, entidades conceptuales de NG+). Sin Interacción No-Física, los ataques del usuario los atraviesan sin efecto. Con ella, el usuario puede golpear y dañar a cualquier entidad independientemente de su estado corporal. Es una habilidad de utility pura — no hace daño directamente, pero habilita el daño donde antes era imposible.

---

### Pasivas

**Toque Espiritual**
Los ataques físicos del usuario afectan a entidades no-corpóreas normalmente. Los fantasmas, espíritus, y formas astrales pueden ser golpeados y dañados como si fueran físicos.

**Corporeización Forzada**
Cuando el usuario ataca a una entidad intangible, la fuerza del impacto la corporiza temporalmente (2 s): durante esos 2 s la entidad es completamente física y puede recibir daño de todas las fuentes (no solo del usuario).

**Ancla de Existencia**
El usuario puede "anclar" al enemigo al plano físico: el enemigo no puede usar Desvío Dimensional, Incorporeidad, ni ninguna forma de esquive intangible durante 5 s tras ser golpeado por el usuario. Cooldown interno: 15 s.

**Visión Transcendental**
Sinergiza con PES: el usuario ve cualquier entidad de cualquier plano de existencia. Los enemigos con invisibilidad basada en cambio de plano son completamente visibles.

---

### Adquisición (sin habilidades activas propias)

La Interacción No-Física no tiene habilidades activas — es un sistema de pasivas que se desbloquea como prerequisito o como bonus de otras habilidades.

- **PES activa** — Desbloquear Vista Espiritual (pasiva de PES) activa automáticamente Toque Espiritual.
- **Evento: El Encuentro Espiritual** — En el Día 25–35, evento donde el personaje encuentra una entidad intangible. Interactuar con ella desbloquea Corporeización Forzada.
- **Inmortalidad Tipo 7 (racial)** — Los No-Muertos tienen todas las pasivas de Interacción No-Física desde el Día 1 (conocen bien el plano espiritual).
- **NG+ bonus** — En NG+, Ancla de Existencia se activa automáticamente si el jugador terminó el run anterior con PES desbloqueada.

---

## 6. Manipulación Espacial

### Descripción de Diseño
La Manipulación Espacial es una versión más fundamental y versátil que la Creación de Portales. Donde los portales son puntos discretos de conexión, la Manipulación Espacial deforma el espacio continuo — dobla la trayectoria de proyectiles, comprime el espacio entre el usuario y el enemigo para ataques imposibles, o expande el espacio alrededor del usuario para crear distancias insalvables. Es el requisito de alto nivel para Manipulación del Espacio-Tiempo y para resistir la Gravedad extrema.

---

### Pasivas

**Geometría Fluida**
El usuario percibe el espacio como maleable: los proyectiles del enemigo tienen un 20 % de probabilidad de ser curvados levemente por el usuario sin acción consciente, resultando en un fallo. Con Intel Combate ≥ 80, la probabilidad sube al 30 %.

**Distorsión Local**
El usuario puede comprimir o expandir el espacio a su alrededor pasivamente: el rango de sus ataques físicos aumenta un 15 % (espacio comprimido hacia el enemigo) y el retroceso recibido se reduce un 20 % (espacio expandido tras el impacto).

**Pliegue Defensivo**
1 vez por combate, cuando recibe un ataque que lo llevaría a menos del 20 % de HP, el usuario dobla el espacio automáticamente: el ataque es redirigido a un punto vacío del escenario. El usuario no recibe daño de ese golpe específico.

**Impermeabilidad Espacial**
El usuario es inmune a efectos de BFR basados en portales y dimensiones de bolsillo. Cualquier intento de teletransportarlo sin su consentimiento falla.

---

### Habilidades Activas (SkillData)

**Corte Espacial** — STRIKE
Ki: 35 · Cooldown: 22 s
El usuario desgarra el espacio en una línea recta hacia el enemigo: daño Poder Ki × 2,2 que ignora Resistencia física (el corte es del espacio mismo, no un golpe). Si el enemigo tiene Incorporeidad activa, el corte aún impacta (el espacio también existe para entidades no-físicas).
*Requisito: Poder Ki ≥ 70, Inteligencia ≥ 40*

**Compresión Espacial** — SUPPORT
Ki: 30 · Cooldown: 28 s · Duración: 8 s
El usuario comprime el espacio alrededor del enemigo: el enemigo no puede alejarse más de 150 unidades del usuario (el espacio se "enreda") y su Velocidad efectiva se reduce un 35 %. El usuario puede moverse normalmente. Anula Teletransportación durante la duración.
*Requisito: Poder Ki ≥ 85, Inteligencia ≥ 55, Día ≥ 30*

**Reflejo Espacial** — SUPPORT
Ki: 40 · Cooldown: 35 s
El usuario crea un espejo espacial: el próximo ataque de Ki del enemigo (dentro de 3 s) es reflejado de vuelta con un 30 % más de daño. Si el ataque es un ULTIMATE del enemigo, el reflejo aplica solo el 50 % (la energía es demasiado grande para reflejar completamente). No funciona contra ataques físicos.
*Requisito: Poder Ki ≥ 95, Inteligencia ≥ 65, Día ≥ 35*

**Colapso Espacial** ★★ — ULTIMATE
Ki: 100 · Cooldown: 120 s (1 uso/combate)
El usuario colapsa el espacio en un punto: el enemigo es comprimido espacialmente sufriendo daño de Poder Ki × 6,0 (ignora Resistencia), queda en un espacio "plegado" durante 4 s (inmovilizado completamente), y al liberarse, el espacio se expande bruscamente lanzándolo 500 unidades (potencial BFR). El usuario necesita 1,5 s de concentración antes de activar (interrumpible si recibe daño).
*Requisito: NG+ o Día ≥ 65, Poder Ki ≥ 140, Inteligencia ≥ 85*

---

### Adquisición

- **Prerequisito Portales** — Tener Creación de Portales con ≥ 15 usos totales desbloquea Corte Espacial y el pasivo Geometría Fluida.
- **Checkpoint de Poder Ki** — Alcanzar Poder Ki ≥ 85 antes del Día 35 desbloquea Compresión Espacial.
- **NPC: El Maestro del Espacio** — Relación ≥ 4 antes del Día 40. Enseña Reflejo Espacial y activa Pliegue Defensivo.
- **NG+ avanzado** — Colapso Espacial disponible en NG+ con árbol previo completo.

---

## 7. Manipulación Temporal

### Descripción de Diseño
La Manipulación Temporal es la habilidad de mayor impacto sistémico del juego. Junto con Time Stop, opera en una categoría especial: afecta el flujo del tiempo del combate en lugar de stats o posiciones. En el sistema de 100 días, tiene también aplicaciones fuera del combate (revertir acciones del día, "recordar" el futuro de un checkpoint). Es prerequisito de Time Stop y de Viaje Dimensional Temporal.

**Nota de balance:** La Manipulación Temporal no "para" el tiempo completamente hasta Time Stop. Sus efectos son de aceleración/desaceleración relativa, permitiendo un diseño escalado.

---

### Pasivas

**Percepción Dilatada**
El usuario procesa el tiempo ligeramente más rápido: todos los cooldowns de sus habilidades se reducen un 10 % de forma pasiva permanente.

**Eco Temporal**
Cuando el usuario es golpeado, hay un 15 % de probabilidad de que el golpe "no ocurra" — el usuario revierte brevemente ese instante de tiempo personal. Solo funciona 2 veces por combate.

**Flujo Ralentizado**
Cuando el HP del usuario cae por debajo del 30 %, percibe el tiempo un 20 % más lento durante 10 s (efecto similar a una Amplificación de Velocidad temporal). Cooldown: 1 vez/combate.

**Conciencia Temporal**
El usuario siente los cambios en el flujo del tiempo: es inmune a los efectos de Time Stop del enemigo hasta por 3 s (escapa del tiempo detenido antes que el resto). Contra enemigos que tienen Time Stop, esta pasiva es crítica.

---

### Habilidades Activas (SkillData)

**Ralentización Temporal** — SUPPORT
Ki: 30 · Cooldown: 35 s · Duración: 8 s
El usuario ralentiza el tiempo local alrededor del enemigo: el enemigo opera al 40 % de su velocidad normal durante 8 s (todos sus stats de Velocidad reducidos al 40 %). El usuario se mueve normalmente. Los cooldowns del enemigo siguen corriendo en tiempo normal (se acumulan más rápido relativamente para el enemigo).
*Requisito: Inteligencia ≥ 55, Intel Combate ≥ 40*

**Aceleración Propia** — SUPPORT
Ki: 35 · Cooldown: 40 s · Duración: 10 s
El usuario acelera su propio flujo temporal: +60 % de Velocidad efectiva, cooldowns reducidos al 50 % durante 10 s. El usuario parece moverse a velocidad imposible. Si el enemigo tiene Precognición activa, el efecto de velocidad se reduce a +30 % (predice los movimientos aun acelerados).
*Requisito: Inteligencia ≥ 65, Velocidad ≥ 60, Día ≥ 30*

**Reversión Temporal** ★ — SUPPORT
Ki: 60 · Cooldown: 90 s (1 uso/combate)
El usuario revierte el tiempo del combate 5 s atrás: el HP del usuario vuelve al valor que tenía 5 s antes, los cooldowns de sus habilidades se revierten también, y el enemigo mantiene su HP actual (el tiempo del enemigo no se revierte). La Reversión no puede usarse si el usuario tiene 0 HP (ya murió — no hay usuario para revertir).
*Requisito: Inteligencia ≥ 80, Poder Ki ≥ 90, Día ≥ 45*

**Paradoja Temporal** ★★ — ULTIMATE
Ki: 90 · Cooldown: 1 uso/run
El usuario crea una paradoja: "el combate ya terminó en victoria" — el enemigo experimenta la realidad de haber perdido. Mecánicamente: el enemigo sufre el daño total acumulado del combate actual como daño adicional instantáneo (equivalente a todo el daño que el usuario ya infligió durante el combate, aplicado de nuevo de golpe). Si ese daño supera el HP restante del enemigo, victoria inmediata. Si no, el enemigo queda con Conmoción Temporal (−30 % de todos los stats durante 15 s).
*Requisito: NG+, Inteligencia ≥ 100, Intel Combate ≥ 80, Día ≥ 30 del NG+*

---

### Adquisición

- **Prerequisito de Inteligencia** — Inteligencia ≥ 55 + Intel Combate ≥ 40 desbloquea Ralentización Temporal automáticamente.
- **Evento: La Fisura Temporal** — En el Día 28–38, evento donde el tiempo fluctúa brevemente en el entorno. Investigarlo desbloquea Aceleración Propia.
- **NPC: El Cronista** — Relación ≥ 4 antes del Día 45. Enseña Reversión Temporal.
- **NG+ exclusivo** — Paradoja Temporal disponible desde el inicio del NG+ si se completó el árbol de Manipulación Temporal.

---

## 8. Time Stop (Detención Temporal)

### Descripción de Diseño
Time Stop es la forma especializada más extrema de Manipulación Temporal. En Dragon Ascension se implementa como la habilidad más poderosa disponible antes del Borrado Existencial. Detiene completamente el tiempo del combate excepto para el usuario durante una ventana limitada. El balance principal es que **la duración escala con el Intel Combate del usuario y decrece por cada impacto ejecutado** — es una ventana de oportunidad, no tiempo libre ilimitado.

---

### Pasivas

**Dominio del Instante**
Mientras el tiempo está detenido (Time Stop activo), el usuario puede ejecutar hasta 3 acciones antes de que el tiempo se reanude. Cada habilidad activa adicional usada en tiempo detenido consume 1 s de la duración base.

**Experiencia en el Vacío**
El usuario ha experimentado el tiempo detenido antes: es inmune al Time Stop del enemigo. Si el enemigo activa Time Stop, el usuario puede actuar normalmente durante la primera mitad de su duración (escapa antes).

**Instante Eterno**
Cada vez que el usuario usa Time Stop en combate, el cooldown de su próximo uso se reduce en 10 s (dominando el arte, se vuelve más eficiente). Máx. −30 s de reducción acumulada.

---

### Habilidades Activas (SkillData)

**Detención Parcial** — SUPPORT
Ki: 50 · Cooldown: 60 s · Duración: 3 s
Detiene el tiempo localmente alrededor del enemigo durante 3 s: el enemigo no puede moverse ni atacar, pero el usuario puede actuar normalmente. El usuario puede ejecutar hasta 2 ataques durante los 3 s (cada ataque consume 1 s). Tras la detención, el enemigo no nota que el tiempo se detuvo (no hay penalización de guard del enemigo al reanudarse).
*Requisito: Manipulación Temporal desbloqueada, Inteligencia ≥ 75, Día ≥ 40*

**Detención Total** ★ — ULTIMATE
Ki: 80 · Cooldown: 100 s · Duración: 5 s base
Detiene el tiempo completamente durante 5 s base (+1 s por cada 20 puntos de Intel Combate sobre 60, máx. +4 s = 9 s total). El usuario puede atacar libremente — cada golpe reduce la duración en 0,8 s. Enemigos con Conciencia Temporal (Pasiva de Manipulación Temporal) escapan en la mitad del tiempo. No se puede usar Singularidad ni Paradoja Temporal durante el tiempo detenido (las fuerzas cósmicas también están congeladas).
*Requisito: Detención Parcial desbloqueada, Inteligencia ≥ 90, Intel Combate ≥ 70, Día ≥ 50*

---

### Adquisición

- **Prerequisito obligatorio** — Manipulación Temporal con al menos Ralentización Temporal desbloqueada.
- **Evento: El Maestro del Tiempo** — NPC especial del Día 38–48 (referencia a Hit/Guldo de Dragon Ball). Combate de práctica donde el jugador aprende a moverse en tiempo detenido. Otorga Detención Parcial.
- **Maestría de Ralentización** — Usar Ralentización Temporal en 15 combates distintos desbloquea Detención Total.
- **Raza especial: Reloj** — Si existe una raza de manipuladores del tiempo, Detención Parcial disponible desde el Día 1.

---

## 9. Sellado

### Descripción de Diseño
El Sellado es una victoria alternativa más "limpia" que el BFR o la Petrificación: el objetivo queda contenido, no destruido ni expulsado. En combate, hay tres tipos (Normal, de Poder, del Alma), cada uno con distintas aplicaciones. El Sellado es también el único contrapoder que puede neutralizar la Inmortalidad de forma temporal (un inmortal sellado no puede morir... pero tampoco puede actuar).

---

### Pasivas

**Artesano de Sellos**
Los sellos del usuario son un 20 % más difíciles de romper (el enemigo necesita un 20 % más de Fuerza relativa para escapar). El tiempo de duración de todos los sellos propios aumenta un 25 %.

**Sello Reactivo**
Cuando el usuario reduce el HP del enemigo al 50 %, un sello parcial se activa automáticamente: el enemigo tiene −15 % de Velocidad durante 8 s (sello de movimiento parcial).

**Conocedor de Sellos**
El usuario puede identificar y romper sellos enemigos sobre sí mismo en la mitad del tiempo normal. Inmune a Sellado de Poder del enemigo 1 vez por combate.

---

### Habilidades Activas (SkillData)

**Sello de Movimiento** — SUPPORT
Ki: 30 · Cooldown: 35 s · Duración: 6 s
Sella la movilidad del enemigo: no puede moverse (anclado en posición) durante 6 s, pero puede seguir atacando desde donde está. El sello se rompe automáticamente si la Fuerza del enemigo ≥ 2,5× la del usuario. Durante el sellado, el daño del usuario aumenta un 30 %.
*Requisito: Ki ≥ 60, Inteligencia ≥ 35*

**Sello de Poder** — SUPPORT
Ki: 45 · Cooldown: 55 s · Duración: 12 s
Sella la energía del enemigo: el enemigo no puede usar habilidades activas de Ki (ULTIMATE, KI_BLAST bloqueados), no puede activar transformaciones, y su Ki máximo se reduce al 30 % del valor original durante 12 s. Ataques físicos del enemigo no son afectados. Si el enemigo tiene Inmortalidad Tipo 8 (ligada al Ki), el sello la desactiva temporalmente.
*Requisito: Ki ≥ 80, Inteligencia ≥ 55, Día ≥ 25*

**Gran Sellado (Mafuba)** ★ — ULTIMATE
Ki: 70 · Cooldown: 1 uso/combate · Requisito: Ítem "Ofuda de Contención" en inventario
Técnica de sellado total: el usuario sella al enemigo en un recipiente dimensional. Si tiene éxito (probabilidad base 55 %, +5 % por cada 30 puntos de Inteligencia sobre 55): victoria por sellado inmediata. Si falla: el enemigo rompe el sello, recupera 15 % de HP y el usuario pierde el Ofuda (debe conseguir otro). Contra Inmortalidad Tipo 5 y 9: imposible (el ser trasciende los sellos convencionales).
*Requisito: Inteligencia ≥ 70, Ki ≥ 100, Día ≥ 40*

---

### Adquisición

- **NPC: El Maestro del Mafuba** — Referencia al Maestro Roshi/Trunks del Futuro. Relación ≥ 3 antes del Día 30. Enseña Sello de Movimiento y Sello de Poder.
- **Evento: El Ritual del Sello** — Evento narrativo del Día 35–45. El personaje aprende el Gran Sellado (Mafuba). El Ofuda de Contención se obtiene como ítem de recompensa del evento.
- **Ítem: Ofuda** — El Ofuda es un ítem consumible obtenible también en intercambio con ciertos NPCs (precio alto). Sin él, Gran Sellado no puede usarse.

---

## 10. Borrado Existencial ★★

### Descripción de Diseño
El Borrado Existencial es la habilidad ofensiva más poderosa del juego — solo disponible en NG+ avanzado y en ciertos jefes narrativos (como Beerus con el Hakai). Borra al objetivo de la existencia en lugar de reducir su HP a 0. No es daño convencional: es eliminación directa. Su balance es que tiene múltiples condiciones de fallo y que el usuario también debe ser immune a él para usarlo (la energía requiere dominio total para no afectarse).

---

### Pasivas

**Vacío Interior**
El usuario comprende el vacío a nivel fundamental: es inmune al Borrado Existencial enemigo (prerequisito para tener la habilidad). Los efectos de estado que "eliminan" aspectos del usuario (Sellado de Poder, etc.) duran un 40 % menos.

**Presencia Aniquiladora**
El aura del usuario suprime la existencia circundante levemente: al inicio de cada combate, el enemigo pierde 5 % del HP máximo de forma no reducible (existencia parcialmente borrada por la mera presencia).

---

### Habilidades Activas (SkillData)

**Hakai Parcial** ★★ — ULTIMATE
Ki: 80 · Cooldown: 1 uso/combate
Borra parcialmente al enemigo de la existencia: elimina el 40 % de su HP máximo de forma no reducible (ignora Inmortalidad Tipos 1–4, no ignora Tipo 5 y 9). El enemigo también pierde todas sus habilidades activas de buff actuales (se borran del estado del combate). No puede ser absorbido ni reflejado.
*Requisito: NG+, Inteligencia ≥ 100, Poder Ki ≥ 160, Día ≥ 25 del NG+*

**Borrado Total (Hakai)** ★★ — ULTIMATE
Ki: 130 · Cooldown: 1 uso/run
Solo funciona si el enemigo tiene ≤ 20 % de HP. Borra completamente al enemigo de la existencia: victoria instantánea sin animación de muerte. Falla contra Inmortalidad Tipo 5 y 9 (el ser trasciende el borrado). Si falla, el usuario pierde 50 % de su HP actual por el esfuerzo fallido. Contra jefes narrativos: puede fallar con un mensaje de lore específico.
*Requisito: NG+ Día ≥ 50, Hakai Parcial desbloqueado, Inteligencia ≥ 120*

---

### Adquisición

- **NG+ exclusivo** — Ninguna ruta de adquisición en el primer run.
- **Evento Narrativo de NG+** — En el Día 20 del NG+, encuentro con una entidad que usa el Hakai. Sobrevivir y comprender el poder desbloquea Hakai Parcial.
- **Maestría de NG+** — Usar Hakai Parcial en 10 combates del NG+ desbloquea Borrado Total.

---

## 11. Zero Absoluto ★

### Descripción de Diseño
El Zero Absoluto es la culminación de la Manipulación del Hielo — no como extensión de stacks de Frío sino como una habilidad cualitativamente diferente que trabaja a nivel atómico. Ignora la Resistencia convencional del enemigo (la resistencia física no protege de que los átomos dejen de moverse). Solo puede ser contrarrestado por Calor Absoluto o por entidades incorpóreas.

---

### Pasivas

**Frío Atómico**
Los ataques físicos del usuario siempre aplican 1 stack de Frío adicional sin costo extra. En ambiente de Nieve/Blizzard, aplican 2 stacks adicionales.

**Núcleo Gélido**
El usuario genera un frío tan intenso que cualquier fuente de calor cercana (fuego, magma) pierde un 30 % de su efectividad contra el usuario.

---

### Habilidades Activas (SkillData)

**Aliento del Vacío** — KI_BLAST
Ki: 50 · Cooldown: 45 s
Emite un soplo de frío cercano al zero absoluto: daño Poder Ki × 2,5 que ignora Resistencia física. Aplica congelación inmediata (3 capas de Frío directas). Si el enemigo tiene Resistencia ≥ 100, el daño igualmente no es reducido (nivel atómico). Falla contra entidades incorpóreas.
*Requisito: Manipulación del Hielo con Apocalipsis Glacial desbloqueado, Poder Ki ≥ 100, Día ≥ 45*

**Zero Absoluto** ★ — ULTIMATE
Ki: 100 · Cooldown: 1 uso/combate
Reduce la temperatura del enemigo al zero absoluto: muerte instantánea si el enemigo tiene ≤ 50 % de HP (los átomos colapsan — ignora Resistencia e Inmortalidad Tipos 1 y 2). Si tiene más de 50 % de HP, inflige Poder Ki × 7,0 de daño (ignora Resistencia) y lo congela durante 4 s. El usuario también recibe el 5 % de ese daño (la energía es difícil de contener). Contra Calor Absoluto del enemigo: ambas fuerzas se cancelan (ningún efecto).
*Requisito: Aliento del Vacío desbloqueado, Poder Ki ≥ 130, Día ≥ 55*

---

### Adquisición

- **Árbol de Hielo completo** — Prerequisito obligatorio: tener Apocalipsis Glacial desbloqueado.
- **Evento: El Polo Absoluto** — Evento de entrenamiento extremo del Día 42–52. Desbloquea Aliento del Vacío.
- **Maestría del Frío** — Congelar completamente al enemigo en 15 combates distintos desbloquea Zero Absoluto.

---

## 12. Danmaku

### Descripción de Diseño
El Danmaku es la habilidad de saturación de proyectiles — no proyectiles poderosos individuales sino avalanchas que abruman al enemigo por número puro. En el motor 2D de Dragon Ascension, se implementa como una habilidad que lanza múltiples Ki Blasts en patrones: radial, en abanico, en espiral. El daño individual es bajo pero la cantidad hace imposible esquivar todo sin habilidades específicas (Acción Instintiva, Teletransportación, Time Stop).

---

### Pasivas

**Cadencia de Fuego**
El usuario lanza Ki Blasts normales un 20 % más rápido (cooldown del ataque básico de Ki reducido permanentemente).

**Patrón Variable**
Las habilidades de Danmaku del usuario pueden cambiar su patrón de disparo entre usos: radial, lineal múltiple, o espiral. Cada patrón tiene una ventaja táctica diferente.

**Saturación**
Cuando el usuario dispara 5 o más proyectiles en 3 s (contando proyectiles de Danmaku), el enemigo queda "Saturado": −15 % de Velocidad durante 5 s (sobrecargado de estímulos, reacciona más lento).

---

### Habilidades Activas (SkillData)

**Lluvia de Ki** — KI_BLAST
Ki: 30 · Cooldown: 18 s
Lanza 8 esferas de Ki en patrón de abanico: cada una hace Poder Ki × 0,5 de daño. Total si todas impactan: Poder Ki × 4,0. El enemigo puede esquivar algunas pero es difícil evitar todas. Activa Saturación automáticamente. Si el enemigo tiene Barrera activa, la barrera bloquea las primeras 3 esferas pero colapsa.
*Requisito: Poder Ki ≥ 45*

**Espiral Devastadora** — KI_BLAST
Ki: 50 · Cooldown: 35 s
Lanza 12 esferas en patrón espiral que cubren el escenario durante 2 s: cada esfera hace Poder Ki × 0,6 (total potencial: Poder Ki × 7,2). El patrón espiral es casi imposible de esquivar completamente sin Teletransportación o Time Stop. 2 s después de activar, el usuario puede detonar todas las esferas restantes simultáneamente.
*Requisito: Poder Ki ≥ 75, Día ≥ 22*

**Tormenta Definitiva** ★ — ULTIMATE
Ki: 85 · Cooldown: 90 s · Duración: 6 s
Durante 6 s el usuario lanza proyectiles continuamente en todos los patrones simultáneamente: 3 proyectiles por segundo en patrón radial (18 proyectiles totales), cada uno Poder Ki × 0,8. Daño total potencial: Poder Ki × 14,4. El usuario puede moverse y atacar físicamente durante la tormenta (los proyectiles se lanzan de forma semi-autónoma). El enemigo queda Saturado automáticamente.
*Requisito: Poder Ki ≥ 110, Velocidad ≥ 60, Día ≥ 50*

---

### Adquisición

- **Ki elevado** — Alcanzar Ki ≥ 80 + Poder Ki ≥ 45 desbloquea Lluvia de Ki automáticamente.
- **Entrenamiento de Disparo** — Minijuego de Ki con precisión (KiChannelMinigame o DirectionalStrikeMinigame) con rango S ×5 desbloquea Espiral Devastadora.
- **Sinergia Tormenta Eléctrica** — Tener Manipulación Eléctrica activa: cada proyectil de Danmaku tiene un 10 % de probabilidad de paralizar 0,3 s al impactar.
- **Maestría de Disparo** — Disparar más de 100 proyectiles totales en la historia del run desbloquea Tormenta Definitiva.

---

## 13. Manipulación del Calor

### Descripción de Diseño
La Manipulación del Calor es la habilidad elemental de temperatura amplia — controla tanto el calor extremo como el frío extremo, siendo el "árbol madre" del que derivan el Fuego, el Hielo y el Magma. En diseño de juego, es una habilidad de generalista elemental que da acceso a una versión básica de todas las manipulaciones de temperatura sin los bonus especializados de cada rama.

---

### Pasivas

**Maestría Térmica**
El usuario controla la temperatura de su cuerpo: inmune a efectos de quemadura y congelación de bajo nivel (Grado I-II). Los ataques de Fuego e Hielo del enemigo pierden un 20 % de efectividad.

**Transferencia Térmica**
Cuando el usuario recibe daño de fuego o frío, absorbe parte de la energía: recupera 5 Ki por cada golpe de este tipo recibido.

**Temperatura Óptima**
El usuario mantiene su cuerpo a temperatura perfecta durante combate: +10 % a todos los stats en climas extremos (Tormenta, Nieve, calor extremo de escenarios volcánicos).

---

### Habilidades Activas (SkillData)

**Onda Calorífica** — KI_BLAST
Ki: 20 · Cooldown: 15 s
Emite una onda de calor intenso: daño Poder Ki × 1,3 + quemadura (2 % del HP máximo por segundo durante 5 s). Los enemigos con armadura de hielo o barreras frías reciben el doble de daño de la quemadura.
*Requisito: Poder Ki ≥ 35*

**Control Térmico Dual** — SUPPORT
Ki: 35 · Cooldown: 40 s · Duración: 12 s
El usuario controla simultáneamente calor y frío: el próximo ataque de Fuego que reciba es absorbido (inmune) y el próximo ataque de Hielo es reflejado al enemigo con un 20 % de bonus de daño. Además, los propios ataques del usuario en este período alternan entre quemadura y congelación aleatoriamente.
*Requisito: Poder Ki ≥ 65, Inteligencia ≥ 35, Día ≥ 20*

**Calor Absoluto** ★ — ULTIMATE
Ki: 90 · Cooldown: 1 uso/combate
Eleva la temperatura al máximo teórico positivo: daño Poder Ki × 5,0 (ignora Resistencia física). Neutraliza completamente cualquier efecto de frío activo en el escenario (Blizzard, Zero Absoluto parcial, stacks de Frío). Contra Zero Absoluto del enemigo: ambos se cancelan (ningún daño de ninguno). El usuario recibe 10 % de su HP máximo como daño propio (el calor también lo afecta levemente).
*Requisito: Poder Ki ≥ 110, Día ≥ 50*

---

### Adquisición

- **Árbol elemental** — Desbloquear Manipulación del Hielo O Manipulación del Magma activa Onda Calorífica automáticamente.
- **Entrenamiento Elemental** — Completar "Entrenamiento en Volcán" Y "Entrenamiento en el Ártico" (acciones de día) desbloquea Control Térmico Dual.
- **Maestría del Calor** — Usar Onda Calorífica en 15 combates distintos desbloquea Calor Absoluto.

---

## 14. Maestría del Sigilo

### Descripción de Diseño
El Sigilo transforma el estilo de combate: en lugar de confrontación directa, el usuario ataca desde posiciones ocultas, obtiene bonuses masivos en el primer golpe de cada encuentro, y puede reposicionarse sin ser detectado. En el sistema de 100 días, el Sigilo también tiene aplicaciones en acciones de día (espionaje, robo, infiltración de eventos especiales). Es la habilidad más "stealth-RPG" del juego — el daño no escala con Fuerza sino con **Intel Combate** (cuánto mejor entiende el usuario cuándo y dónde atacar).

---

### Pasivas

**Primer Golpe**
El primer ataque de cada combate (antes de que el enemigo reaccione) tiene un +50 % de daño bonus y no puede ser esquivado.

**Sombra en Movimiento**
Cuando el usuario no está atacando, su silueta se difumina levemente: −15 % de probabilidad de que los ataques del enemigo lo localicen correctamente (ligera evasión pasiva).

**Lectura Táctica**
El usuario aprende del patrón de ataque del enemigo: después del tercer golpe recibido en el combate, el usuario gana +10 % de daño permanente para ese combate (ha leído la táctica).

**Infiltración**
Fuera del combate: el usuario puede acceder a acciones de día de "Espionaje" e "Infiltración" que normalmente están bloqueadas. Estas acciones revelan información de NPCs, eventos futuros, y rutas de entrenamiento ocultas.

---

### Habilidades Activas (SkillData)

**Camuflaje** — SUPPORT
Ki: 20 · Cooldown: 30 s · Duración: 5 s
El usuario se vuelve invisible durante 5 s: el enemigo no puede localizarlo ni atacarlo. El usuario puede moverse libremente. Si ataca durante el camuflaje, el ataque tiene +60 % de daño (emboscada) pero el camuflaje se rompe al atacar. El camuflaje también se rompe si el enemigo tiene PES activa.
*Requisito: Velocidad ≥ 50, Intel Combate ≥ 35*

**Golpe en la Sombra** — STRIKE
Ki: 30 · Cooldown: 22 s
El usuario se mueve a la sombra del enemigo y ataca desde atrás: teletransporte de posicionamiento (100 unidades detrás del enemigo) + golpe garantizado de Intel Combate × 2,5 (el daño escala con Intel Combate, no con Fuerza). El golpe no puede ser bloqueado ni esquivado. Si el usuario tiene Camuflaje activo al activar, el daño aumenta a Intel Combate × 3,5.
*Requisito: Velocidad ≥ 65, Intel Combate ≥ 50, Día ≥ 20*

**Emboscada Perfecta** ★ — ULTIMATE
Ki: 60 · Cooldown: 80 s
El usuario desaparece por completo del combate durante 3 s (invisible e intangible) y reaparece con un golpe devastador desde el ángulo óptimo: daño Intel Combate × 5,0, ignora el 50 % de la Resistencia (el golpe apunta a puntos débiles). Activa automáticamente el efecto de Primer Golpe del pasivo aunque no sea el inicio del combate. Si el enemigo tiene Acción Instintiva o Precognición activos, el daño se reduce a Intel Combate × 3,0.
*Requisito: Intel Combate ≥ 80, Velocidad ≥ 80, Día ≥ 40*

---

### Adquisición

- **Acciones de día de Espionaje** — Completar "Espiar al Enemigo" (acción de día) ×3 desbloquea Camuflaje y el pasivo Primer Golpe.
- **Evento: El Asesino en la Sombra** — NPC del Día 18–28 que usa sigilo en un combate. Derrotarlo (con HP > 50 %) desbloquea Golpe en la Sombra.
- **Checkpoint de Intel Combate** — Alcanzar Intel Combate ≥ 80 desbloquea Emboscada Perfecta y el pasivo Infiltración.
- **Raza Androide** — Los Androides pueden modular su emisión de Ki: Camuflaje oculta también la señal de Ki (no detectable por PES/Radar de Ki).

---

## 15. Acción Instintiva

### Descripción de Diseño
La Acción Instintiva es la versión "entrenada" del Ultra Instinto de Goku — no requiere un estado especial sino que es el resultado de años de entrenamiento hasta que el cuerpo actúa sin intervención consciente. En juego, se traduce como un sistema de esquive y contraataque automático que funciona como segunda capa de defensa pasiva. A diferencia de Precognición (que predice el futuro), Acción Instintiva reacciona al presente de forma más rápida de lo humanamente posible.

---

### Pasivas

**Reflejos Perfectos**
El usuario esquiva automáticamente el 15 % de todos los ataques físicos recibidos (esquive instintivo sin acción consciente). El porcentaje sube al 25 % cuando el HP está por debajo del 50 %.

**Contraataque Instintivo**
Cuando el usuario esquiva un ataque con Reflejos Perfectos, el cuerpo contraataca automáticamente: golpe de Fuerza × 0,8 sin costo de Ki (1 vez cada 3 s máx.).

**Cuerpo Autónomo**
El usuario puede elaborar estrategia mentalmente mientras su cuerpo lucha: el costo de Ki de todas las habilidades SUPPORT se reduce un 15 % (la mente está libre de gestionar Ki mientras el cuerpo se mueve solo).

**Impenetrabilidad a Ilusiones**
Como el cuerpo actúa sin pensamiento consciente, las fintas y técnicas ilusorias son inútiles. Las ilusiones del enemigo fallan automáticamente si el usuario tiene Acción Instintiva activa.

---

### Habilidades Activas (SkillData)

**Modo Instintivo** — SUPPORT
Ki: 40 · Cooldown: 50 s · Duración: 12 s
El usuario activa plenamente el modo instintivo durante 12 s: los Reflejos Perfectos suben al 40 % de esquive, cada esquive exitoso genera automáticamente un contraataque de Fuerza × 1,0, y el usuario es inmune a efectos de estado durante la duración (el instinto esquiva hasta los efectos). Todas las ilusiones del enemigo fallan garantizadamente.
*Requisito: Velocidad ≥ 80, Intel Combate ≥ 70, Día ≥ 38*

**Ultra Instinto (Parcial)** ★ — ULTIMATE
Ki: 70 · Cooldown: 90 s · Duración: 8 s
Versión accesible del Ultra Instinto: durante 8 s el cuerpo actúa completamente de forma autónoma al nivel más alto posible. Esquive automático del 60 % de todos los ataques (físicos y de Ki), los ataques físicos propios se ejecutan instintivamente buscando puntos débiles (+30 % de daño), e inmunidad completa a ilusiones, fintas, y efectos de Miedo. Al terminar, el usuario queda con −20 % de Velocidad durante 5 s (cuerpo agotado tras la operación autónoma extrema). No es el Ultra Instinto dominado de Goku — es una aproximación mortal al estado.
*Requisito: Modo Instintivo desbloqueado, Velocidad ≥ 100, Intel Combate ≥ 90, Día ≥ 55*

---

### Adquisición

- **Entrenamiento de Reacción** — Completar el minijuego de esquive (DodgeMinigame) con rango S ×8 desbloquea Reflejos Perfectos (pasiva) y acceso a Modo Instintivo.
- **NPC: Maestro de los Instintos** — Referencia a Whis. Relación ≥ 4 antes del Día 45. Enseña Modo Instintivo.
- **Velocidad + Intel Combate extremos** — Alcanzar Velocidad ≥ 100 + Intel Combate ≥ 90 antes del Día 55 desbloquea Ultra Instinto Parcial.
- **Raza Ángel (custom, si existe)** — Acción Instintiva activa desde el Día 1 con Reflejos Perfectos al 30 % base.

---

## 16. Inducción de Parálisis

### Descripción de Diseño
La Inducción de Parálisis es una habilidad de control puro: no hace daño directo pero crea las condiciones ideales para maximizar el daño de otras habilidades. Es la culminación de varias mecánicas ya existentes (Eléctrica, Veneno, Telekinesis, Puntos de Presión) — si el jugador tiene cualquiera de esas habilidades, la Parálisis potencia sus efectos y los sinergiza. También existe como habilidad independiente para builds de control.

---

### Pasivas

**Maestría de la Inmovilización**
Todos los efectos de parálisis/aturdimiento/inmovilización del usuario duran un 25 % más. Esto incluye los de Telekinesis, Hielo, Electricidad, y Puntos de Presión.

**Punto Débil Motor**
El usuario conoce los puntos del sistema motor: los ataques físicos del usuario tienen un 12 % de probabilidad de aplicar una parálisis parcial de 0,5 s (no consume cooldown ni Ki).

**Cadena de Control**
Cuando el usuario aplica dos efectos de inmovilización diferentes sobre el mismo enemigo en el mismo combate, el segundo efecto tiene el doble de duración.

---

### Habilidades Activas (SkillData)

**Paralización Neural** — KI_BLAST
Ki: 25 · Cooldown: 20 s · Duración: 2,5 s
Golpe de energía dirigido al sistema nervioso motor: parálisis completa durante 2,5 s (el enemigo no puede moverse ni atacar). No hace daño directo. Durante la parálisis el usuario puede actuar libremente y el enemigo recibe +30 % de daño de todas las fuentes. Al terminar, el enemigo no puede ser paralizado por esta habilidad durante 10 s (inmunidad post-efecto).
*Requisito: Poder Ki ≥ 40, Inteligencia ≥ 30*

**Parálisis Progresiva** — SUPPORT
Ki: 40 · Cooldown: 35 s · Duración: 15 s
Aplica una parálisis que se intensifica con el tiempo: en los primeros 5 s el enemigo tiene −20 % de Velocidad, en los segundos 5 s −40 %, en los últimos 5 s −60 % (casi inmóvil). El proceso es gradual — el enemigo puede actuar pero cada vez peor. Si la Resistencia del enemigo ≥ 80, el progreso de la parálisis es la mitad.
*Requisito: Poder Ki ≥ 65, Inteligencia ≥ 50, Día ≥ 25*

**Inmovilización Total** ★ — ULTIMATE
Ki: 65 · Cooldown: 70 s (1 uso/combate)
Parálisis total de todo el sistema motor del enemigo: 4 s de inmovilización completa + daño de Poder Ki × 1,5 por segundo durante esos 4 s (daño neural acumulado). El daño durante la inmovilización no puede ser mitigado por Resistencia. Tras los 4 s, el enemigo tiene −30 % de Velocidad permanente para el resto del combate (daño nervioso residual). No funciona contra robots o entidades sin sistema nervioso (aplica daño de Ki normal en su lugar pero no la parálisis).
*Requisito: Poder Ki ≥ 90, Inteligencia ≥ 65, Día ≥ 40*

---

### Adquisición

- **Sinergia natural** — Tener Manipulación Eléctrica O Puntos de Presión O Veneno Grado III desbloquea Paralización Neural automáticamente (extensión de los efectos ya conocidos).
- **Entrenamiento de Control** — Acción de día "Técnicas de Inmovilización" ×3 desbloquea Parálisis Progresiva.
- **Combinación de control** — Tener Telekinesis + Inducción de Parálisis activos en el mismo combate 10 veces desbloquea Inmovilización Total.

---

## 17. Manipulación del Magma

### Descripción de Diseño
El Magma combina la Tierra (masa, impacto, escudo) y el Fuego (daño continuo, quemadura). Es la habilidad elemental de mayor daño de zona del juego: el magma persiste en el suelo, causando daño continuo a todo lo que toque. En el motor 2D, el magma derramado actúa como trampa de terreno — áreas del suelo que dañan al enemigo si las pisa. El usuario es inmune al propio magma (condición de la habilidad).

**Sistema de Terreno de Magma:** Las habilidades de Magma pueden dejar "charcos" de lava en el suelo que duran 10 s. Cualquier entidad (enemigo) que entre en contacto recibe 3 % del HP máximo por segundo. El usuario es inmune.

---

### Pasivas

**Piel de Basalto**
El usuario ha interiorizado el magma: inmune a quemaduras y calor extremo. Los ataques de fuego del enemigo pierden un 25 % de efectividad. El usuario puede moverse sobre charcos de magma propios sin penalización.

**Núcleo Volcánico**
Los ataques físicos del usuario tienen un 15 % de probabilidad de dejar una marca de magma en el enemigo: 2 % del HP máximo por segundo durante 4 s (quemadura superficial). La marca se apila: hasta 3 marcas simultáneas (máx. 6 % por segundo).

**Calor Residual**
Cuando termina cualquier habilidad de Magma activa, el calor persiste en el área durante 3 s adicionales: el daño por terreno de magma continúa sin nuevas activaciones.

**Forja del Guerrero**
El usuario convierte el dolor del calor en fuerza: cuando está rodeado de magma propio (terreno activo), gana +15 % de Fuerza.

---

### Habilidades Activas (SkillData)

**Proyectil de Magma** — KI_BLAST
Ki: 25 · Cooldown: 14 s
Lanza una bola de roca fundida: daño Poder Ki × 1,5 + quemadura (3 % HP/s durante 5 s) + deja un charco de magma de radio pequeño donde impacta (dura 10 s).
*Requisito: Fuerza ≥ 40, Poder Ki ≥ 35*

**Erupción** — STRIKE
Ki: 40 · Cooldown: 35 s
El usuario golpea el suelo creando una erupción local: la tierra se abre y lanza magma hacia el enemigo (daño Fuerza × 2,0 + Poder Ki × 1,0) + el escenario queda con 3 charcos de magma aleatorios (10 s). Si hay Manipulación de la Tierra activa, los charcos duran 18 s y su radio es mayor.
*Requisito: Fuerza ≥ 60, Poder Ki ≥ 55, Día ≥ 20*

**Armadura de Magma** ★ — SUPPORT
Ki: 45 · Cooldown: 50 s · Duración: 15 s
El usuario se recubre de magma fundido: +35 % de Resistencia, y cualquier enemigo que golpee físicamente al usuario recibe daño de retorno (Fuerza × 0,5 + quemadura 3 % HP/s durante 4 s). El usuario puede "verter" la armadura al final de su duración como ataque: el magma se lanza en área haciendo Poder Ki × 3,0 y creando 5 charcos.
*Requisito: Vitalidad ≥ 60, Fuerza ≥ 70, Día ≥ 30*

**Supervolcán** ★ — ULTIMATE
Ki: 90 · Cooldown: 110 s
El usuario abre una fisura volcánica masiva bajo el enemigo: explosión inicial de Fuerza × 3,0 + Poder Ki × 2,0 (ignora el 30 % de Resistencia por la temperatura extrema), el escenario queda cubierto de magma casi completamente durante 20 s (el enemigo no puede pisar el suelo sin recibir daño: 4 % HP/s). El usuario vuela durante el efecto (FlyState automático). Al terminar, la lava se solidifica en roca: la Manipulación de la Tierra puede usar esa roca solidificada como material para sus habilidades.
*Requisito: Fuerza ≥ 90, Poder Ki ≥ 100, FlyState desbloqueado, Día ≥ 50*

---

### Adquisición

- **Prerequisito elemental** — Tener Manipulación de la Tierra O Manipulación del Calor desbloquea Proyectil de Magma automáticamente.
- **Entrenamiento Volcánico** — Acción de día "Entrenar en Volcán" ×4 desbloquea Erupción y el pasivo Piel de Basalto.
- **NPC: El Guardián del Volcán** — Relación ≥ 3 antes del Día 35. Enseña Armadura de Magma.
- **Checkpoint de Fuerza extrema** — Alcanzar Fuerza ≥ 90 antes del Día 50 desbloquea Supervolcán.
- **Sinergia Tierra+Fuego** — Tener Manipulación de la Tierra + Manipulación del Calor ambas activas reduce todos los cooldowns de Magma en 8 s.

---

## Tabla de Sinergias Cruzadas

| Habilidad A | Habilidad B | Sinergia |
|---|---|---|
| Manipulación de la Gravedad (Singularidad) | BFR | La singularidad ya atrae al borde — activa condición BFR automáticamente si el enemigo llega al límite del mapa |
| Time Stop | Danmaku (Espiral Devastadora) | Disparar la Espiral en tiempo detenido: todos los proyectiles impactan al instante (el enemigo no puede moverse para esquivar ninguno) |
| Petrificación (3 capas) | Zero Absoluto | Enemigo petrificado + Zero Absoluto: los átomos de la piedra también colapsan — daño aumentado un 50 % sobre el total |
| Sellado de Poder | Borrado Existencial (Hakai Parcial) | Sellado de Poder primero: el enemigo no puede usar habilidades activas al recibir el Hakai. No puede activar Inmortalidad activa |
| Maestría del Sigilo (Camuflaje) | Manipulación Temporal (Time Stop) | Activar ambos: el usuario es invisible E invulnerable durante el tiempo detenido. Combo de eliminación perfecta |
| Acción Instintiva (Modo Instintivo) | Precognición (cualquier tipo) | La Acción Instintiva reacciona al presente; la Precognición predice el futuro — juntas: esquive del 80 % de todos los ataques |
| PES (Conciencia Omnidireccional) | Maestría del Sigilo (Primer Golpe) | PES activa hace que el "primer golpe" sea cualquier ataque que tome al enemigo desprevenido, no solo el primero del combate |
| Magma (Supervolcán) | Manipulación de la Tierra (Colisión Continental) | Lava solidificada + Colisión Continental: usa la roca solidificada del Supervolcán como proyectil masivo con +40 % de daño base |
| Inducción de Parálisis (Inmovilización Total) | Danmaku (Tormenta Definitiva) | Enemigo paralizado + Tormenta Definitiva: todos los proyectiles impactan garantizados. Daño total máximo teórico |
| Manipulación Espacial (Reflejo Espacial) | Danmaku (Lluvia de Ki) | El reflejo devuelve la lluvia completa: 8 proyectiles reflejados de vuelta al enemigo con +30 % bonus |
| Manipulación Temporal (Reversión) | Acción Instintiva | La Reversión restaura el HP pero mantiene el estado de Modo Instintivo activo — el usuario reinicia fresco con el instinto en marcha |
| Borrado Existencial | Inmortalidad Tipo 5/9 del enemigo | El Borrado falla: mensaje de lore específico explicando por qué esa inmortalidad concreta trasciende la eliminación |
