# Habilidades: Manipulación del Dolor · Manipulación del Miedo · Manipulación del Hielo · Manipulación del Veneno · Creación de Ilusiones

> Documento de diseño — Dragon Ascension
> Formato: Pasivas | Habilidades Activas (SkillData) | Adquisición

---

## 1. Manipulación del Dolor

### Descripción de Diseño
La Manipulación del Dolor es una de las pocas habilidades del juego que **ignora la Resistencia convencional** del enemigo — ataca directamente el sistema nervioso, no el cuerpo físico. Esto la hace extremadamente poderosa contra enemigos con Resistencia muy alta, pero inútil contra enemigos que no pueden sentir dolor (robots, No-Muertos, entidades conceptuales). Es la contraparte ofensiva natural de Gran Fuerza de Voluntad, que reduce el dolor del usuario.

**Regla especial:** El daño de la Manipulación del Dolor no es reducido por la Resistencia del enemigo. En cambio, es reducido por la Inteligencia del enemigo (barreras mentales) y por habilidades de supresión de dolor.

---

### Pasivas

**Lectura del Umbral**
El usuario puede percibir cuánto dolor está sintiendo el enemigo en tiempo real. Cuando el enemigo tiene activo algún efecto de daño físico (DoT, herida abierta), el usuario gana +15 % de daño en todas sus habilidades de Dolor (apila dolor sobre dolor).

**Nerviosa Afinidad**
Los ataques físicos del usuario tienen un 10 % de probabilidad de dejar una "fibra nerviosa expuesta" en el enemigo durante 5 s. Mientras está activa, cualquier habilidad de Dolor inflige un 20 % más de daño.

**Umbral Propio Elevado**
El usuario, al dominar el dolor ajeno, también eleva su propio umbral: es inmune al efecto de estado "Dolor" y reduce en un 30 % el daño de las habilidades de Manipulación del Dolor enemigas.

**Resonancia de Sufrimiento**
Cuando el usuario activa dos habilidades de Dolor en el mismo combate, la tercera habilidad de Dolor de ese combate tiene su costo de Ki reducido a 0.

---

### Habilidades Activas (SkillData)

**Pulso Nervioso** — KI_BLAST
Ki: 20 · Cooldown: 15 s · Duración del efecto: 6 s
Envía un pulso de Ki dirigido al sistema nervioso del enemigo: inflige daño (Poder Ki × 1,2, ignora Resistencia) y deja al enemigo con "Dolor Moderado" durante 6 s: −15 % de Velocidad y −10 % de Fuerza. Contra enemigos con Inteligencia ≥ 80, el efecto dura solo 3 s (barreras mentales).
*Requisito: Poder Ki ≥ 35, Inteligencia ≥ 20*

**Tortura Neural** — SUPPORT
Ki: 35 · Cooldown: 40 s · Duración: 10 s
Bombardeo sostenido del sistema nervioso: el enemigo entra en "Agonía" durante 10 s. Efectos: −25 % de todos los stats, el enemigo no puede activar transformaciones ni ultimates, y cada golpe recibido durante el estado causa 5 % de daño adicional del HP máximo (el dolor amplifica cada impacto). Falla completamente contra enemigos con Inteligencia ≥ 120.
*Requisito: Poder Ki ≥ 60, Inteligencia ≥ 40, Día ≥ 25*

**Liberación de Dolor** — SUPPORT
Ki: 25 · Cooldown: 30 s · Duración: 15 s
Versión defensiva/de buff: el usuario suprime el propio dolor y libera endorfinas de combate. Durante 15 s: el usuario ignora todos los efectos de estado negativos (Dolor, Miedo, Parálisis, Veneno) y gana +20 % de daño. Al terminar el efecto, el dolor acumulado regresa como penalización suave (−5 % de Velocidad durante 5 s).
*Requisito: Inteligencia ≥ 30, Vitalidad ≥ 40*

**Colapso Nervioso** — ULTIMATE
Ki: 70 · Cooldown: 90 s (1 uso/combate)
Sobrecarga masiva del sistema nervioso del enemigo: daño Poder Ki × 3,5 (ignora Resistencia). El enemigo queda en "Colapso" durante 5 s: completamente incapaz de moverse o atacar (parálisis total). Después del Colapso, el enemigo tiene −30 % de todos los stats de forma permanente durante ese combate (nervios dañados). Contra enemigos No-Muertos o robots: falla con mensaje "Sistema nervioso inexistente".
*Requisito: Poder Ki ≥ 90, Inteligencia ≥ 60, Día ≥ 40*

---

### Adquisición

- **Punto de Presión Avanzado** — Si el jugador tiene Puntos de Presión (documento 3) desbloqueado, Pulso Nervioso se desbloquea automáticamente como extensión de Ki de esa habilidad.
- **Entrenamiento de Anatomía** — Acción de día "Estudio del Cuerpo Humano" ×3 (si existe como acción) o relación ≥ 2 con NPC médico desbloquea Tortura Neural.
- **Evento: El Dolor como Maestro** — Evento narrativo del Día 20–35 donde el personaje supera una lesión grave. Aprender a ignorar el dolor desbloquea Liberación de Dolor.
- **Dominio Neural Completo** — Tener los tres activos anteriores desbloqueados + haberlos usado en al menos 5 combates desbloquea Colapso Nervioso.
- **Sinergia Telepatía** — Si el jugador tiene Telepatía activa, Tortura Neural hace daño adicional igual al 10 % de la Inteligencia del usuario (la mente amplifica el control neural).

---

## 2. Manipulación del Miedo

### Descripción de Diseño
La Manipulación del Miedo opera sobre la psicología del enemigo. A diferencia de Manipulación Empática (que trabaja con el espectro emocional completo), el Miedo es una herramienta de control de combate puro: incapacita, hace cometer errores, y en niveles altos puede destruir la voluntad del enemigo de luchar. Su contraparte es Gran Fuerza de Voluntad, que otorga inmunidad al miedo al usuario.

**Contra-habilidades del miedo:** Aguante de Hierro (Poder de la Furia), Aura de Calma (Manipulación Empática), y Umbral Propio Elevado (Manipulación del Dolor) otorgan inmunidad o reducción al miedo.

---

### Pasivas

**Presencia Aterradora**
Al inicio de cada combate, si el poder total del usuario supera en al menos 1 tier al enemigo, el enemigo empieza con "Miedo Residual": −10 % de Fuerza durante los primeros 15 s del combate.

**Amplificación del Terror**
Cada habilidad de Miedo aplicada sobre el mismo enemigo en el mismo combate aumenta su duración en un 20 % acumulativo. El primer uso dura X segundos, el segundo X × 1,2, el tercero X × 1,44, etc.

**Leer el Terror**
El usuario puede percibir el nivel de miedo del enemigo: cuando el enemigo está bajo efecto de cualquier habilidad de Miedo propia, el usuario gana +20 % de velocidad de movimiento (se mueve más rápido hacia un oponente aterrorizado).

**Voluntad de Hierro (Reflejo)**
El usuario ha interiorizado el miedo tanto que es completamente inmune a las habilidades de Miedo enemigas. Además, cuando el enemigo intenta usar una habilidad de Manipulación del Miedo sobre el usuario, hay un 25 % de probabilidad de que el miedo se refleje de vuelta al enemigo con la mitad de intensidad.

---

### Habilidades Activas (SkillData)

**Inducción de Miedo** — SUPPORT
Ki: 20 · Cooldown: 25 s · Duración: 10 s
Proyecta una onda de terror sobre el enemigo: "Miedo Leve" durante 10 s — el enemigo ataca erráticamente (−20 % de precisión de ataque, mayor probabilidad de abrir huecos en su defensa). El usuario gana +15 % de daño contra un enemigo atemorizado. Complementa y stackea con Inducción de Miedo de Telepatía si está disponible.
*Requisito: Inteligencia ≥ 25, Intel Combate ≥ 20*

**Alucinación de Terror** — SUPPORT
Ki: 40 · Cooldown: 50 s · Duración: 8 s
El usuario proyecta la peor pesadilla del enemigo como alucinación real: el enemigo entra en "Pánico" durante 8 s (−35 % de Velocidad, ataca al azar incluyendo posible auto-daño 20 % de los golpes). El tipo de alucinación depende del perfil del enemigo (configurado en EnemyData). Falla contra enemigos con Inteligencia ≥ 100 o habilidades anti-ilusión.
*Requisito: Inteligencia ≥ 50, Poder Ki ≥ 40, Día ≥ 25*

**Fobia Permanente** — SUPPORT
Ki: 55 · Cooldown: 70 s (1 uso/combate)
Implanta un miedo profundo en el enemigo: el enemigo adquiere "Fobia" al tipo de daño más reciente que le infligió el usuario. Durante el resto del combate, cada vez que el usuario use ese tipo de daño, el enemigo reacciona con pánico durante 1 s adicional por golpe. La Fobia no puede ser eliminada por habilidades de curación del enemigo. Falla contra enemigos sin mente (robots, No-Muertos).
*Requisito: Inteligencia ≥ 70, Día ≥ 35*

**Terror Absoluto** — ULTIMATE
Ki: 80 · Cooldown: 100 s (1 uso/combate)
El usuario se convierte en la encarnación del terror del enemigo: durante 5 s el enemigo queda completamente paralizado por el horror. Tras esos 5 s, el enemigo entra en "Desesperación": no puede activar transformaciones, todas sus habilidades activas entran en cooldown forzado (los cooldowns de todas las activas del enemigo se resetean a su máximo), y tiene −25 % de todos los stats durante 20 s. Si el HP del enemigo es inferior al 25 %, la parálisis dura 8 s en lugar de 5.
*Requisito: Inteligencia ≥ 90, Intel Combate ≥ 60, Día ≥ 50*

---

### Adquisición

- **Primer Stat de Inteligencia** — Al alcanzar Inteligencia ≥ 25 + Intel Combate ≥ 20, Inducción de Miedo se desbloquea automáticamente.
- **Sinergia Empática** — Si el jugador tiene Manipulación Empática activa, Alucinación de Terror se desbloquea con un 20 % de descuento en Ki.
- **Evento: Cara a Cara con el Terror** — Combate especial del Día 25–35 contra un enemigo que usa Creación de Ilusiones. Sobrevivir y derrotarlo desbloquea Fobia Permanente.
- **Maestría del Miedo** — Haber aplicado efectos de miedo en 10 combates distintos desbloquea Terror Absoluto.
- **NPC: El Estratega** — Relación ≥ 3 antes del Día 40. Enseña Fobia Permanente y el pasivo Amplificación del Terror.

---

## 3. Manipulación del Hielo

### Descripción de Diseño
La Manipulación del Hielo trabaja en dos capas: daño por congelación y **control de terreno**. El hielo modifica el escenario de combate creando superficies resbaladizas, paredes de bloqueo, y armaduras defensivas. Es la versión fría y táctica de la Manipulación Elemental, y su combinación más natural es con el Clima (Blizzard), la Tierra (escudo de roca + hielo) y el Agua (amplificador). El frío también ralentiza las reacciones del enemigo de forma acumulativa.

**Sistema de acumulación de frío:** Cada habilidad de Hielo aplica un stack de "Frío" al enemigo (máx. 5). Cada stack reduce la Velocidad del enemigo un 5 %. Con 5 stacks, el enemigo queda "Congelado" (inmovilizado 2 s, stacks se resetean).

---

### Pasivas

**Cuerpo Criogénico**
El usuario es inmune a efectos de ralentización y congelación propios y enemigos. En climas fríos (Nieve activa), su Velocidad aumenta un 10 % en lugar de disminuir.

**Cristalización**
Los efectos de Frío que aplica el usuario tienen un 15 % de probabilidad de aplicar 2 stacks en lugar de 1 (cristalización acelerada).

**Armadura de Hielo Pasiva**
El usuario proyecta una capa de hielo delgada sobre la piel: +8 % de Resistencia pasiva. Al recibir un golpe físico, la capa se rompe emitiendo fragmentos que hacen daño de retorno al enemigo (Poder Ki × 0,3, sin cooldown, máx. 1 vez cada 3 s).

**Fusión Agua-Hielo**
Si el escenario tiene clima "Lluvia" o hay agua presente (evento del día), todas las habilidades de Hielo aplican +1 stack adicional de Frío automáticamente.

---

### Habilidades Activas (SkillData)

**Lanza de Hielo** — KI_BLAST
Ki: 20 · Cooldown: 10 s
Proyectil de hielo sólido de alta velocidad: daño Poder Ki × 1,4 + aplica 2 stacks de Frío. Si el enemigo ya tiene 3 o más stacks de Frío al impactar, el daño sube a Poder Ki × 2,0 y aplica 3 stacks (acelerando la Congelación).
*Requisito: Poder Ki ≥ 30*

**Glaciar Defensivo** — SUPPORT
Ki: 30 · Cooldown: 35 s · Duración: 12 s
El usuario levanta una barrera de hielo masiva: bloquea los próximos 3 ataques recibidos (físicos o ki). Cuando la barrera se rompe por el tercer ataque, explota en fragmentos de hielo que aplican 2 stacks de Frío al enemigo. Si la barrera no es rota antes de que termine la duración, el usuario puede lanzarla como proyectil (daño Poder Ki × 2,5).
*Requisito: Poder Ki ≥ 50, Resistencia ≥ 30*

**Tormenta de Cristal** — KI_BLAST
Ki: 45 · Cooldown: 40 s
Desata una lluvia de agujas de hielo en área: 5 impactos de daño Poder Ki × 0,9 cada uno (total ×4,5), y cada impacto aplica 1 stack de Frío (total 5 stacks → Congelación inmediata). Si el clima "Nieve" está activo, el número de impactos sube a 8.
*Requisito: Poder Ki ≥ 70, Velocidad ≥ 30, Día ≥ 20*

**Apocalipsis Glacial** — ULTIMATE
Ki: 85 · Cooldown: 110 s
El usuario desciende la temperatura del escenario al límite: daño masivo inicial (Poder Ki × 5,0) + el suelo se congela (terreno de hielo activo durante 20 s: el enemigo pierde −20 % de Velocidad adicional permanentemente mientras el terreno esté activo). El enemigo recibe 5 stacks de Frío instantáneos (Congelación inmediata: 2 s de parálisis). Durante el terreno helado, todas las habilidades de Hielo del usuario cuestan 10 Ki menos.
*Requisito: Poder Ki ≥ 110, Velocidad ≥ 50, Día ≥ 45*

---

### Adquisición

- **Evento de Clima Frío** — Evento de día "Ola de Frío" en el Día 8–18. Entrenar en esas condiciones desbloquea Lanza de Hielo y el pasivo Cuerpo Criogénico.
- **NPC: Maestro del Ártico** — Relación ≥ 3 antes del Día 25. Enseña Glaciar Defensivo y el pasivo Cristalización.
- **Sinergia con Clima** — Haber activado el clima "Blizzard" (Manipulación del Clima) en al menos 3 combates desbloquea Tormenta de Cristal automáticamente.
- **Maestría de Frío** — Congelar (5 stacks) al enemigo en 8 combates distintos desbloquea Apocalipsis Glacial.
- **Raza Namekiano** — Adaptados a climas fríos: Fusión Agua-Hielo activa desde el Día 1 sin requisito.

---

## 4. Manipulación del Veneno

### Descripción de Diseño
El Veneno en Dragon Ascension funciona como daño con el tiempo (DoT) escalado en grados, con el añadido especial de que **los grados más altos ignoran o reducen la capacidad de Curación y Regeneración del enemigo** (el veneno neutraliza activamente los procesos de recuperación). Es el contrapeso directo a las habilidades de Curación y Regeneración — un jefe con Veneno de Grado IV puede ser devastador si el jugador depende de esas mecánicas.

**Sistema de grados en combate:** El jugador selecciona el grado al desbloquear la habilidad. Cada grado es una habilidad distinta. Un jugador puede equipar hasta dos habilidades de Veneno simultáneamente. Los grados más altos tienen mayores costos de Ki y están disponibles más tarde en el run.

---

### Pasivas

**Metabolismo Tóxico**
El usuario es inmune a todos los efectos de veneno, ácido, y toxinas ambientales. En combate, los ataques físicos del usuario tienen un 10 % de probabilidad de dejar una toxina residual (Grado I equivalente: 2 % de HP máximo por segundo durante 4 s).

**Concentración Venenosa**
Cada stack de veneno activo sobre el enemigo potencia el siguiente ataque del usuario en un 5 % de daño (máx. +25 % con 5 stacks). El veneno ya aplicado "amplifica" el impacto del golpe físico.

**Resistencia al Antídoto**
Los venenos del usuario son extraordinariamente resistentes: si el enemigo tiene habilidades de Curación, la mitad de su efecto de curación se anula mientras tenga un veneno de Grado III o superior activo.

**Síntesis Rápida**
El cooldown de todas las habilidades de Veneno se reduce un 20 % (pasivo permanente). El usuario sintetiza venenos más rápido de lo normal.

---

### Habilidades Activas por Grado (SkillData)

**Veneno Grado II — Toxina de Combate** — KI_BLAST
Ki: 15 · Cooldown: 18 s · Duración del DoT: 8 s
Inyecta o lanza una toxina moderada al enemigo: daño inmediato Poder Ki × 0,8 + daño por tiempo de 3 % del HP máximo del enemigo por segundo durante 8 s (total potencial 24 % del HP). El enemigo siente fatiga: −10 % de Velocidad durante la duración. El antídoto del enemigo (Curación activa) puede neutralizar el DoT usando 30 % del efecto de curación.
*Requisito: Inteligencia ≥ 20*

**Veneno Grado III — Toxina Severa** — KI_BLAST
Ki: 30 · Cooldown: 28 s · Duración del DoT: 12 s
Toxina de alto daño: daño inmediato Poder Ki × 1,2 + 5 % del HP máximo enemigo por segundo durante 12 s (total potencial 60 % del HP). Neutraliza el 50 % de la eficacia de Curación y Regeneración del enemigo mientras está activo. El enemigo sufre también −20 % de Fuerza (deterioro muscular).
*Requisito: Inteligencia ≥ 40, Día ≥ 20*

**Veneno Grado IV — Toxina Letal** — ULTIMATE
Ki: 55 · Cooldown: 55 s · Duración del DoT: 15 s
Veneno de alta letalidad: daño inmediato Poder Ki × 1,5 + 6 % del HP máximo por segundo durante 15 s (total potencial 90 % del HP). Neutraliza el 80 % de Curación y Regeneración enemigas. El enemigo sufre "Envenenamiento Crítico": −30 % a todos los stats y no puede usar habilidades ULTIMATE mientras el veneno está activo. Solo puede ser neutralizado por purificación especial (habilidades de Curación de nivel "Milagro Vital").
*Requisito: Inteligencia ≥ 60, Poder Ki ≥ 60, Día ≥ 35*

**Veneno Grado Extra — Toxina Conceptual** — ULTIMATE
Ki: 80 · Cooldown: 90 s (1 uso/combate)
Veneno que afecta aspectos no-biológicos: daño Poder Ki × 2,0 instantáneo. El veneno ataca la "energía" del enemigo en lugar del cuerpo: reduce el Ki máximo del enemigo en un 30 % para el resto del combate (su pool de Ki nunca se recupera más allá de ese límite), y todas sus transformaciones activas consumen el doble de Ki por segundo. Funciona incluso contra robots y No-Muertos (ataca el sistema de energía, no la biología). Inutilizable contra entidades de Amortalidad (Inmortalidad Tipo 5).
*Requisito: Inteligencia ≥ 80, Poder Ki ≥ 90, Día ≥ 50*

---

### Adquisición

- **NPC: Envenenador / Alquimista** — Relación ≥ 2 antes del Día 20. Enseña Veneno Grado II y activa el pasivo Metabolismo Tóxico.
- **Entrenamiento de Síntesis** — Acción de día "Alquimia/Síntesis" ×3 desbloquea Veneno Grado III.
- **Evento: La Planta Mortal** — Evento narrativo del Día 30–38 donde el personaje encuentra una planta extremadamente venenosa. Desbloquea Veneno Grado IV al analizar y dominar la toxina.
- **Combinación Absorcíon + Veneno** — Si el jugador tiene Absorción desbloqueada, el pasivo Concentración Venenosa se activa automáticamente.
- **Checkpoint Inteligencia** — Al superar Inteligencia ≥ 80 antes del Día 50, Veneno Grado Extra se desbloquea en el panel.
- **Raza: Sin especificación de raza** — Cualquier raza puede aprender Veneno, pero los personajes de raza Reptil (si existe) tienen todos los grados disponibles desde el Día 1 sin costos de Ki aumentados.

---

## 5. Creación de Ilusiones

### Descripción de Diseño
Las Ilusiones son una herramienta de combate psicológico de alto nivel. Atacan la percepción del enemigo en lugar de su cuerpo, lo que significa que son **completamente ineficaces contra enemigos con Precognición, Ultra Instinto, o Sentidos Mejorados de nivel alto**, pero devastadoras contra todos los demás. Las ilusiones escalan en complejidad: desde simples imágenes falsas que distraen, hasta construcciones mentales que causan daño real ("el dolor que la mente cree que es real, el cuerpo lo siente").

**Mecánica de "Rotura de Ilusión":** Cualquier enemigo con Intel Combate ≥ 80 tiene una probabilidad de romper la ilusión al recibirla (25 % base, escalando con la diferencia de Inteligencia). Si la ilusión es rota, el efecto termina inmediatamente pero el cooldown de la habilidad se reduce a la mitad.

---

### Pasivas

**Maestro del Engaño**
El usuario puede crear imágenes falsas pasivamente durante combate. Cada vez que el usuario usa Teletransportación o Paso Rápido, deja una ilusión estática en la posición original durante 1,5 s. El enemigo puede atacar esa ilusión (pierde el ataque) con un 30 % de probabilidad.

**Percepción Distorsionada**
Las ilusiones del usuario son 20 % más difíciles de romper (la probabilidad de Rotura de Ilusión del enemigo se reduce en 20 puntos porcentuales).

**Dolor Psicosomático**
Cuando el usuario aplica una ilusión de daño al enemigo (Ilusión de Herida o superior), el daño psicosomático que causa es incrementado en un 15 % por cada habilidad de Manipulación Mental o del Dolor activa simultáneamente.

**Escudo de Engaño**
El usuario puede crear una ilusión defensiva de sí mismo: 1 vez por combate, cuando recibe un golpe que sería fatal, hay un 20 % de probabilidad de que el enemigo haya atacado la ilusión en lugar del usuario real (el golpe se cancela y el enemigo pierde 0,5 s de combo). Este 20 % sube al 35 % si el usuario tiene Intel Combate ≥ 100.

---

### Habilidades Activas (SkillData)

**Ilusión Básica: Señuelo** — SUPPORT
Ki: 15 · Cooldown: 18 s · Duración: 6 s
Crea una copia ilusoria estática del usuario en un punto del escenario elegido. El enemigo tiene un 40 % de probabilidad de atacar al señuelo en lugar del usuario durante los 6 s. Si el enemigo ataca al señuelo, el usuario puede contraatacar con un golpe garantizado (daño Fuerza × 1,2) dentro de los 1,5 s siguientes sin cooldown.
*Requisito: Inteligencia ≥ 25*

**Ilusión de Herida** — SUPPORT
Ki: 30 · Cooldown: 35 s · Duración: 8 s
El usuario proyecta en la mente del enemigo la ilusión de que ha sufrido una herida grave: el enemigo cree que está al 30 % de HP durante 8 s (aunque su HP real no cambie). Sus habilidades que escalan con HP (como Explosión de Furia, Gran Fuerza de Voluntad) se activan como si realmente tuviera ese HP. El daño real al enemigo es Poder Ki × 0,5 (psicosomático). Falla contra Intel Combate ≥ 80 del enemigo.
*Requisito: Inteligencia ≥ 45, Poder Ki ≥ 35, Día ≥ 20*

**Laberinto Mental** — SUPPORT
Ki: 50 · Cooldown: 60 s · Duración: 10 s
Construye una ilusión compleja que distorsiona la percepción espacial del enemigo: durante 10 s, la dirección del escenario se invierte para el enemigo (sus movimientos van en la dirección opuesta a la intentada). El enemigo tiene −40 % de Velocidad efectiva y sus ataques a distancia impactan en direcciones erróneas (50 % de probabilidad de fallar completamente). Requiere concentración del usuario: si el usuario recibe daño durante la duración, hay un 30 % de probabilidad de que la ilusión se rompa.
*Requisito: Inteligencia ≥ 65, Poder Ki ≥ 55, Día ≥ 30*

**Pesadilla Real** — ULTIMATE
Ki: 90 · Cooldown: 110 s (1 uso/combate)
La ilusión más poderosa: el usuario construye una realidad alternativa completa en la mente del enemigo durante 6 s. Mecánicamente: el enemigo percibe el combate con todos sus stats reducidos al 50 % (ilusión de debilidad total), sufre daño psicosomático de 10 % del HP máximo por segundo (el cuerpo siente el dolor imaginado como real), y todas sus habilidades activas tienen el doble de cooldown dentro de la ilusión. Al terminar los 6 s, el enemigo "despierta" pero los efectos de debilidad persisten 5 s adicionales (trauma post-ilusión). Completamente inútil contra Ultra Instinto, Precognición Tipo 4, o Sentidos Mejorados de nivel máximo.
*Requisito: Inteligencia ≥ 90, Poder Ki ≥ 80, Día ≥ 50*

---

### Adquisición

- **Inteligencia Umbral** — Al alcanzar Inteligencia ≥ 25, Señuelo se desbloquea automáticamente en el panel.
- **Evento: El Ilusionista** — NPC especial del Día 18–28, un maestro de ilusiones que prueba al personaje con un combate ilusorio. Superarlo desbloquea Ilusión de Herida y el pasivo Maestro del Engaño.
- **Sinergia Telepatía / Miedo** — Tener Telepatía O Manipulación del Miedo desbloqueada reduce el requisito de Día de Laberinto Mental de 30 a 22.
- **NPC: Mago / Maestro Mental** — Relación ≥ 4 antes del Día 45. Enseña Laberinto Mental y activa Percepción Distorsionada.
- **Checkpoint de Inteligencia Extrema** — Alcanzar Inteligencia ≥ 90 antes del Día 50 desbloquea Pesadilla Real automáticamente.
- **Anti-Ilusión** — Si el personaje tiene Sentidos Mejorados de nivel máximo O Precognición Tipo 3+, las ilusiones enemigas fallan automáticamente pero el jugador también recibe un aviso de que sus propias ilusiones serán igualmente resistidas por enemigos de nivel similar.

---

## Tabla de Sinergias Cruzadas

| Habilidad A | Habilidad B | Sinergia |
|---|---|---|
| Manipulación del Dolor (Tortura Neural) | Manipulación del Miedo (Terror Absoluto) | Ambos activos: el enemigo entra en "Colapso Mental Total" — parálisis 8 s en lugar de 5 s y daño de dolor psicosomático simultáneo |
| Manipulación del Hielo (Tormenta de Cristal) | Manipulación del Clima (Blizzard) | Blizzard activo: Tormenta de Cristal aplica 8 impactos en lugar de 5 y cada impacto aplica 2 stacks de Frío |
| Manipulación del Veneno (Grado IV) | Curación (cualquier tier) | El Grado IV neutraliza el 80 % de la Curación del enemigo pero también reduce en un 30 % la efectividad de la Curación del propio usuario si la usa durante el efecto (el veneno en el ambiente interfiere) |
| Creación de Ilusiones (Laberinto Mental) | Teletransportación (Intercambio de Posición) | Laberinto activo + Intercambio: el enemigo ya está confundido sobre las direcciones, el intercambio de posición lo desorienta completamente — 100 % de fallo en su próximo ataque |
| Manipulación del Dolor (Liberación de Dolor) | Poder de la Furia (Explosión de Furia) | Liberación de Dolor activa antes de Explosión de Furia: el multiplicador de "HP perdido" se calcula como si el usuario sintiera el dolor máximo acumulado — bonus de daño aumentado |
| Creación de Ilusiones (Ilusión de Herida) | Gran Fuerza de Voluntad (Último Aliento) | Si la ilusión convence al enemigo de que tiene 5 % de HP, el enemigo activa Último Aliento (si lo tiene), pero el multiplicador se aplica sobre su HP real — el efecto va en contra del enemigo |
| Manipulación del Hielo (5 stacks Congelación) | Manipulación del Dolor (Colapso Nervioso) | Congelación + Colapso Nervioso: el nervioso del enemigo ya está ralentizado por el frío — la parálisis dura 7 s en lugar de 5 s |
| Manipulación del Veneno (Grado Extra) | Absorción (Robo de Poder) | Veneno Extra activo: el Robo de Poder absorbe también el 30 % de reducción de Ki máximo que el veneno causó — el usuario gana esa energía como bonus propio |
| Manipulación del Miedo (Fobia Permanente) | Creación de Ilusiones (Señuelo) | El señuelo adopta la forma del "objeto de miedo" de la Fobia — probabilidad de que el enemigo lo ataque sube de 40 % a 75 % |
