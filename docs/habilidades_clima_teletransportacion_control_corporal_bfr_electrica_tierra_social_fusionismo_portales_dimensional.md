# Habilidades: Clima · Teletransportación · Control Corporal · BFR · Eléctrica · Tierra · Influencia Social · Fusionismo · Portales · Viaje Dimensional

> Documento de diseño — Dragon Ascension
> Formato: Pasivas | Habilidades Activas (SkillData) | Adquisición

---

## 1. Manipulación del Clima

### Descripción de Diseño
El usuario puede alterar las condiciones atmosféricas del escenario de combate, afectando tanto al enemigo como, en ciertos casos, al propio usuario. El clima actúa como una capa de estado de campo: persiste durante varios turnos/segundos y modifica las reglas del combate mientras está activo. Es una de las pocas habilidades que opera a nivel de "arena" en lugar de a nivel de personaje. En una implementación futura, el fondo visual del CombatArena podría reflejar el clima activo.

---

### Pasivas

**Sensibilidad Atmosférica**
Al inicio de cada combate, el usuario detecta automáticamente cualquier efecto climático activo del escenario (evento aleatorio o habilidad del enemigo) e ignora el 30 % de sus penalizaciones.

**Dominio del Viento**
Cuando hay un clima de tipo Viento activo (propio o externo), la Velocidad del usuario aumenta un 15 % y sus proyectiles de Ki viajan un 20 % más rápido.

**Conductor Natural**
Cuando hay un clima de tipo Tormenta/Relámpago activo, los ataques físicos del usuario ganan un bonus de daño eléctrico igual al 10 % de su Poder Ki.

**Ojo del Huracán**
Dentro de los 3 segundos inmediatamente posteriores a activar cualquier clima propio, el usuario es inmune a los efectos de estado (aturdimiento, ralentización, parálisis).

---

### Habilidades Activas (SkillData)

**Viento Cortante** — KI_BLAST
Ki: 25 · Cooldown: 18 s · Duración del clima: 12 s
Invoca un viento fuerte que lanza una ráfaga de cortes de aire al enemigo (Fuerza × 1,4) y establece clima "Viento" durante 12 s: el enemigo tiene −15 % de Velocidad y sus proyectiles son desviados un 10 % de las veces.
*Requisito: Velocidad ≥ 30*

**Tormenta Eléctrica** — KI_BLAST
Ki: 40 · Cooldown: 35 s · Duración del clima: 15 s
Convoca nubes de tormenta: lanza 3 rayos aleatorios sobre el enemigo (Poder Ki × 1,2 cada uno) y establece clima "Tormenta" durante 15 s. Durante la Tormenta, cada ataque físico del usuario tiene un 20 % de probabilidad de golpear con daño eléctrico adicional (Poder Ki × 0,5).
*Requisito: Poder Ki ≥ 50, Velocidad ≥ 25*

**Blizzard** — SUPPORT
Ki: 35 · Cooldown: 40 s · Duración del clima: 18 s
Desata una ventisca de hielo: establece clima "Nieve" durante 18 s. El enemigo sufre −25 % de Velocidad y −10 % de Fuerza progresivamente (aumenta 2 % cada 3 s hasta el cap). El usuario ignora las penalizaciones de temperatura del clima frío.
*Requisito: Ki ≥ 70, Día ≥ 30*

**Cataclismo Climático** — ULTIMATE
Ki: 85 · Cooldown: 120 s · Duración del clima: 25 s
Desencadena una tormenta perfecta: activa los tres climas (Viento, Tormenta, Nieve) simultáneamente durante 25 s. El enemigo sufre las penalizaciones de los tres tipos y recibe un impacto inicial de daño múltiple (3 rayos + rafaga de viento + granizo: daño total Poder Ki × 5,0). El usuario recibe todos los bonus de los pasivos climáticos al mismo tiempo.
*Requisito: Poder Ki ≥ 120, Velocidad ≥ 60, Día ≥ 55*

---

### Adquisición

- **Evento Climático** — En el Día 8–15, evento de día "Tormenta Inesperada". El personaje la observa y aprende Viento Cortante si tiene Velocidad ≥ 20.
- **Acción de Entrenamiento "Al Aire Libre"** — Completar 5 días consecutivos con entrenamiento exterior desbloquea Tormenta Eléctrica.
- **NPC: Maestro de los Elementos** — Relación ≥ 3 antes del Día 35. Enseña Blizzard.
- **Completar árbol parcial** — Tener Viento Cortante + Tormenta Eléctrica + Blizzard desbloqueados y haber ganado 3 combates usando clima desbloquea Cataclismo Climático.
- **Raza Namekiano** — Sensibilidad Atmosférica mejorada: ignoran 50 % de penalizaciones climáticas enemigas en lugar del 30 %.

---

## 2. Teletransportación

### Descripción de Diseño
La Teletransportación es una habilidad de movimiento disruptivo puro: permite al usuario romper el ritmo del combate reposicionándose instantáneamente, esquivando ataques, intercambiando posición con el enemigo o enviándolo fuera del escenario. En el motor de combate 2D, se implementa como teleporte de posición en el mapa con efectos de después imagen. Es la base del BFR activo.

La jerarquía de tipos refleja la rareza: Auto-dirigida es básica; Espacial es avanzada; Dimensional y Temporal son endgame/NG+.

---

### Pasivas

**Instinto de Escape**
Cuando el usuario recibe un golpe que lo llevaría a menos del 25 % de HP, hay un 20 % de probabilidad de activar un micro-teleporte automático (2 metros atrás) que reduce el daño a la mitad. Cooldown interno: 30 s.

**Rastro Fantasma**
Al teletransportarse, el usuario deja una imagen espejo en la posición original durante 1 s. Si el enemigo ataca la imagen, pierde 0,5 s de cooldown en el próximo ataque del usuario. No causa daño al enemigo.

**Economía de Movimiento**
Cada habilidad de Teletransportación usada en combate reduce el costo de Ki del siguiente ataque físico o Ki Blast en 8 (no acumula, solo aplica al siguiente).

**Dominancia Espacial**
Tras teletransportarse, el primer ataque ejecutado dentro de los 1,5 s siguientes ignora el 30 % de la Resistencia del enemigo (ataque de sorpresa).

---

### Habilidades Activas (SkillData)

**Paso Rápido** — SUPPORT
Ki: 15 · Cooldown: 10 s
Pseudo-Teletransportación: el usuario se mueve a una velocidad tan extrema que parece teletransportarse a un punto del mapa (hasta 200 unidades). Se reposiciona instantáneamente. No es un esquive de golpe único — si un ataque ya está en trayectoria puede impactar igual.
*Requisito: Velocidad ≥ 40*

**Intercambio de Posición** — SUPPORT
Ki: 30 · Cooldown: 22 s
Intercambia la posición del usuario con la del enemigo al instante. El enemigo queda desorientado 1 s (−30 % Velocidad). Si el usuario ejecuta un ataque en ese 1 s, el daño aumenta un 40 %.
*Requisito: Velocidad ≥ 60, Poder Ki ≥ 30, Día ≥ 20*

**Teletransportación Reactiva** — SUPPORT
Ki: 25 · Cooldown: 18 s (1 carga, máx. 2 cargas)
El usuario se prepara para un teleporte reactivo: si recibe un ataque en los próximos 2 s, se teletransporta automáticamente a la espalda del enemigo y contraataca con un golpe garantizado (daño Fuerza × 1,5). Si los 2 s pasan sin ataque, la carga se mantiene pero el cooldown empieza.
*Requisito: Velocidad ≥ 75, Intel Combate ≥ 40*

**Gran Teletransportación** — ULTIMATE
Ki: 70 · Cooldown: 90 s
Teletransportación Espacial completa: el usuario desaparece por 1,5 s (invulnerable) y puede reaparecer en cualquier punto del escenario. Al reaparecer, cae sobre el enemigo con un golpe devastador (Fuerza × 3,0 + Poder Ki × 2,0) o puede elegir simplemente reposicionarse. Variante ofensiva: si aparece sobre el enemigo, el ataque no puede ser esquivado.
*Requisito: Velocidad ≥ 100, Día ≥ 45*

---

### Adquisición

- **Velocidad Umbral** — Al alcanzar Velocidad ≥ 40, Paso Rápido se desbloquea automáticamente en el panel.
- **Evento: El que se Mueve Primero** — Combate especial en el Día 20–28 contra un enemigo que usa Intercambio de Posición. Sobrevivir y copiar la técnica desbloquea Intercambio de Posición.
- **Entrenamiento con NPC: Maestro de Velocidad** — Relación ≥ 4 antes del Día 35. Enseña Teletransportación Reactiva.
- **Son Goku Reference** — El evento de la Técnica de Teletransportación del Maestro es un evento especial del Día 40–50 (referencia a Dragon Ball). Completa el minijuego "Detectar Ki" para desbloquear Gran Teletransportación.
- **Pseudo-Teletransportación** — Paso Rápido es técnicamente la versión básica. Al equiparla y usarla 10 veces en combate, el personaje "aprende" la sensación y reduce el cooldown permanentemente a 8 s.

---

## 3. Control Corporal

### Descripción de Diseño
El Control Corporal tiene cinco niveles de profundidad (del texto fuente), que en el juego se traducen en cuatro habilidades activas progresivas y un árbol de pasivas que escalan juntos. Es una habilidad intrínseca del cuerpo, sin costo de Ki en sus niveles básicos, y que en niveles altos permite regeneración y adaptación. Complementa directamente a Regeneración y Evolución Reactiva.

---

### Pasivas

**Regulación Vital**
El usuario controla activamente sus funciones corporales: +15 % de eficiencia en recuperación de HP fuera del combate (entre días). Durante combate, el sangrado y efectos de "daño con el tiempo" duran un 25 % menos.

**Modulación Muscular**
El usuario puede ajustar su fisiología en tiempo real: al inicio de un combate, elige entre +10 % de Fuerza o +10 % de Velocidad como bonus pasivo permanente durante esa pelea. El bonus dura todo el combate.

**Adaptación Celular**
Una vez por combate, cuando el usuario recibe daño de un tipo concreto que lo llevaría por debajo del 30 % de HP, las células reaccionan: gana +15 % de Resistencia a ese tipo específico de daño para el resto del combate.

**Arquitectura Perfecta**
Cada 20 puntos de Vitalidad por encima de 40, el usuario gana +3 % a todos los stats (multiplicador de "cuerpo optimizado"). Máx. +18 % al llegar a Vitalidad 160.

---

### Habilidades Activas (SkillData)

**Control Básico: Sobrecarga Muscular** — SUPPORT
Ki: 5 · Cooldown: 15 s · Duración: 8 s
Activa las funciones básicas al máximo: +20 % de Fuerza durante 8 s. Reduce el daño del siguiente golpe recibido en un 10 % (el cuerpo se tensa anticipando el impacto). No requiere Ki elevado — es control puro del cuerpo.
*Requisito: Vitalidad ≥ 20*

**Control Avanzado: Modificación Corporal** — SUPPORT
Ki: 20 · Cooldown: 25 s · Duración: 10 s
El usuario alarga o endurece extremidades temporalmente: +25 % de alcance en ataques físicos y +20 % de daño en el primer golpe de cada combo. Además, puede elegir al activar: cabello como látigo (mayor alcance) o uñas endurecidas (+5 % de daño de penetración que ignora Resistencia).
*Requisito: Vitalidad ≥ 40, Resistencia ≥ 25, Día ≥ 15*

**Control de Órganos: Resistencia Extrema** — SUPPORT
Ki: 30 · Cooldown: 40 s · Duración: 12 s
El usuario potencia órganos internos individuales: Corazón (+15 % de regeneración de Ki por segundo), Pulmones (+20 % de Velocidad), o Musculatura (+30 % de Fuerza). Elegir al activar. Puede mantener la función parcial de los órganos dañados: si el HP cae por debajo del 10 % durante el efecto, el usuario no muere instantáneamente sino que tiene 3 s adicionales antes de la derrota.
*Requisito: Vitalidad ≥ 60, Día ≥ 28*

**Control Celular: Regeneración Activa** — ULTIMATE
Ki: 50 · Cooldown: 70 s · Duración: 20 s
Activa el control a nivel celular: regenera un 3 % de HP máximo por segundo durante 20 s (total: +60 % HP máximo). Además, neutraliza venenos y efectos de estado negativos al activar. Durante el efecto, el usuario gana +20 % de Resistencia. Si Regeneración (sistema de habilidad de Regeneración del documento 2) está activa simultáneamente, el porcentaje por segundo se duplica.
*Requisito: Vitalidad ≥ 80, Resistencia ≥ 50, Día ≥ 40*

---

### Adquisición

- **Estadística de Vitalidad** — Alcanzar Vitalidad 20 desbloquea Control Básico automáticamente. Es una de las pocas habilidades que se desbloquea por stat puro.
- **Entrenamiento Físico Intensivo** — Acción de día "Entrenamiento de Resistencia Extrema" ×3 desbloquea Control Avanzado.
- **Evento: Herida Grave** — Evento narrativo donde el personaje sobrevive a una herida que debería matarlo. Desbloquea Control de Órganos.
- **Combinación con Regeneración** — Si el jugador ya tiene cualquier tier de Regeneración activo, el costo de desbloqueo de Control Celular se reduce (disponible desde Día 30 en lugar de Día 40).
- **Raza Namekiano / Majin** — Todas las pasivas de Control Corporal se activan desde el Día 1 sin requisitos de stats.

---

## 4. BFR (Battle Field Removal)

### Descripción de Diseño
BFR en Dragon Ascension es una categoría especial de mecánica de victoria alternativa. En lugar de reducir el HP del enemigo a 0, el usuario lo expulsa fuera del escenario de combate de forma que no puede regresar a tiempo. Mecánicamente, en el motor 2D, se representa como enviar al enemigo fuera de los límites del mapa con suficiente fuerza o sellarlo temporalmente. Es una condición de victoria alternativa disponible para builds especializadas.

**Condición de victoria BFR:** Si el enemigo es expulsado del mapa y no regresa en 5 segundos, la batalla se declara victoria para el usuario.

---

### Pasivas

**Precisión de Expulsión**
Las habilidades de lanzamiento y empuje del usuario (incluidas las de Telekinesis) tienen un +20 % de fuerza de desplazamiento. Esto hace que el enemigo vuele más lejos al ser golpeado.

**Cierre de Ruta**
Cuando el enemigo está dentro del 20 % del borde del mapa, el usuario detecta la oportunidad: +15 % de daño a ese enemigo y los cooldowns de habilidades de lanzamiento se reducen en 30 %.

**Sellado Parcial**
Si el usuario usa una habilidad de BFR y el enemigo resiste (no llega al borde), el enemigo queda con −10 % de Velocidad durante 8 s como residuo del intento.

**Expulsión Definitiva**
Una vez por combate, si el usuario logra una condición de victoria BFR, recupera un 30 % de HP y Ki como recompensa por la ejecución táctica.

---

### Habilidades Activas (SkillData)

**Lanzamiento Extremo** — STRIKE
Ki: 35 · Cooldown: 30 s
Golpea al enemigo con fuerza máxima en una dirección (elegible: izquierda/derecha/arriba). El desplazamiento es de 400 unidades. Si el enemigo choca contra el borde del mapa, queda aturdido 3 s y pierde 15 % del HP máximo por impacto. Si llega al límite y no hay tierra, victoria BFR.
*Requisito: Fuerza ≥ 60*

**Dimensión de Bolsillo** — SUPPORT
Ki: 50 · Cooldown: 60 s · Duración del sellado: 6 s
Abre un portal dimensional pequeño y empuja al enemigo hacia él: el enemigo queda sellado en una dimensión pocket durante 6 s (completamente incapacitado). Al regresar, pierde 20 % del HP máximo por el esfuerzo de regresar. Si el enemigo tiene menos del 30 % de HP al ser sellado, puede no regresar (victoria BFR inmediata con probabilidad del 40 %).
*Requisito: Poder Ki ≥ 80, Inteligencia ≥ 50, Día ≥ 35*

**Expulsión Orbital** — ULTIMATE
Ki: 80 · Cooldown: 90 s
Lanza al enemigo con fuerza tan extrema que sale del escenario hacia arriba. El enemigo tarda 8 s en regresar (tiempo de caída). Si la condición BFR aplica (8 s > umbral de 5 s), victoria inmediata. Si no aplica, el enemigo regresa con un 25 % de HP perdido por la caída. Solo usable si Fuerza ≥ 90 Y el enemigo tiene menos del 60 % de HP.
*Requisito: Fuerza ≥ 90, Velocidad ≥ 60, Día ≥ 50*

**Sellado Dimensional** — ULTIMATE
Ki: 100 · Cooldown: 120 s (1 uso/combate)
Abre un portal permanente a otra dimensión y sella al enemigo dentro. Victoria BFR instantánea si el enemigo no tiene capacidad de Viaje Dimensional ni Teletransportación Dimensional. Si el enemigo tiene esas habilidades, regresa en 10 s con −50 % de todos los stats permanentes durante el combate.
*Requisito: Creación de Portales o Viaje Dimensional desbloqueados, Día ≥ 60*

---

### Adquisición

- **Sinergia de Telekinesis** — Desbloquear Lanzamiento (de Telekinesis) automáticamente habilita Lanzamiento Extremo como upgrade disponible.
- **Evento: El Maestro del Exilio** — NPC especial en el Día 30–40. Le enseña al personaje el arte de expulsar oponentes. Desbloquea Dimensión de Bolsillo.
- **Checkpoint de Fuerza** — Alcanzar Fuerza ≥ 90 antes del Día 50 desbloquea Expulsión Orbital.
- **Combinación Portal + BFR** — Si el jugador tiene Creación de Portales Y cualquier habilidad BFR ya desbloqueada, Sellado Dimensional se desbloquea automáticamente al alcanzar el Día 60.

---

## 5. Manipulación Eléctrica

### Descripción de Diseño
La Manipulación Eléctrica otorga al usuario el control sobre descargas, campos electromagnéticos y corrientes. En combate funciona como daño continuo (DoT), stun, y potenciador de otros ataques. Tiene sinergia natural con Manipulación del Clima (Tormenta Eléctrica). El daño eléctrico tiene la particularidad de penetrar parcialmente la Resistencia física del enemigo (ya que viaja por el sistema nervioso).

**Regla especial del daño eléctrico:** Ignora el 20 % de la Resistencia del enemigo por defecto. Contra enemigos en agua o conductores, ignora el 40 %.

---

### Pasivas

**Carga Estática**
El usuario acumula carga eléctrica pasiva en combate: cada golpe físico recibido agrega 1 punto de carga (máx. 10). Cada punto de carga añade +2 % de daño eléctrico al próximo Ki Blast o ataque eléctrico. La carga se consume al disparar.

**Campo Electromagnético**
El usuario proyecta un campo EM pasivo: los proyectiles metálicos del enemigo (si existen) pierden un 10 % de velocidad y daño. El radio del campo escala con Poder Ki (1 unidad de radio por cada 5 de Poder Ki).

**Sobre-conductividad**
Si hay clima "Tormenta" activo en el escenario (propio o externo), el daño de todas las habilidades eléctricas del usuario aumenta un 35 % y el efecto de parálisis dura 0,5 s adicional.

**Retroalimentación Eléctrica**
Cuando el usuario absorbe o bloquea un ataque eléctrico enemigo, recupera Ki igual al 30 % del daño del ataque absorbido.

---

### Habilidades Activas (SkillData)

**Descarga Eléctrica** — KI_BLAST
Ki: 20 · Cooldown: 12 s
Lanza un rayo eléctrico que hace daño (Poder Ki × 1,3) y tiene un 35 % de probabilidad de paralizar al enemigo 1 s. Si el enemigo está mojado o en clima Tormenta, la probabilidad sube al 60 % y el daño al Poder Ki × 1,6.
*Requisito: Poder Ki ≥ 30*

**Jaula Electromagnética** — SUPPORT
Ki: 30 · Cooldown: 35 s · Duración: 8 s
Crea un campo eléctrico alrededor del usuario: todo enemigo que entre al rango de melee durante los 8 s recibe Poder Ki × 0,8 de daño eléctrico automático y queda lento (−20 % de Velocidad) durante 3 s adicionales. Funciona como represalia de corto alcance.
*Requisito: Poder Ki ≥ 50, Inteligencia ≥ 25*

**Rayo Encadenado** — KI_BLAST
Ki: 45 · Cooldown: 40 s
Lanza un rayo que rebota entre el usuario y el enemigo 4 veces, con cada rebote incrementando el daño un 15 %. Daño total: Poder Ki × (1,0 + 1,15 + 1,32 + 1,52) = Poder Ki × 4,99. Si el enemigo está paralizado al impactar, el daño base sube a Poder Ki × 1,3 por rebote.
*Requisito: Poder Ki ≥ 70, Día ≥ 25*

**Tormenta Neuronal** — ULTIMATE
Ki: 75 · Cooldown: 90 s
Dispara una sobrecarga eléctrica masiva directamente al sistema nervioso del enemigo: parálisis total durante 3 s, pérdida del 25 % de HP, y el enemigo queda con −20 % de todos los stats durante 15 s posteriores (sistema nervioso dañado). Durante la parálisis, el usuario puede atacar con daño aumentado un 50 %.
*Requisito: Poder Ki ≥ 100, Inteligencia ≥ 45, Día ≥ 40*

---

### Adquisición

- **Evento Natural: Rayo** — En el Día 5–12, evento de clima donde un rayo cae cerca del personaje. Investigarlo (acción de día) desbloquea Descarga Eléctrica.
- **Entrenamiento de Ki de Alta Frecuencia** — Minijuego de Ki con vibración (si existe variante) ×3 con rango A o superior desbloquea Jaula Electromagnética.
- **NPC: Inventor / Científico** — Relación ≥ 3 antes del Día 30. Explica la física de la electricidad y desbloquea Rayo Encadenado.
- **Sinergia Climática** — Haber activado Tormenta Eléctrica (de Manipulación del Clima) en al menos 5 combates desbloquea Tormenta Neuronal.
- **Absorción de Energía Eléctrica** — Si el jugador tiene Absorción desbloqueada, Retroalimentación Eléctrica se activa automáticamente sin adquisición adicional.

---

## 6. Manipulación de la Tierra

### Descripción de Diseño
La Manipulación de la Tierra es una habilidad de control de terreno: crea obstáculos, escudos y proyectiles de roca/metal, y modifica el suelo bajo el enemigo. En combate 2D, las formaciones de tierra afectan las posiciones de movimiento del enemigo. El daño es alto pero los cooldowns son largos: es una habilidad de setup y dominio del espacio más que de spam.

---

### Pasivas

**Arraigo Telúrico**
Mientras el usuario tiene ambos pies en el suelo (no en FlyState), recibe un +20 % de Resistencia pasiva. Si el suelo fue modificado por el usuario (escudo de tierra activo o terremoto), el bonus sube a +30 %.

**Peso de la Tierra**
Los ataques de Tierra del usuario reducen la Velocidad del enemigo en un 10 % acumulativo por impacto (máx. −40 %). El efecto se resetea al inicio de cada combate.

**Mineral Absorbido**
Si el usuario tiene la habilidad de Absorción desbloqueada, puede absorber los minerales del suelo durante combate: recupera 5 de Ki por segundo mientras no está en el aire.

**Fortaleza Natural**
El primer escudo de tierra creado en cada combate tiene un 20 % más de HP (más durable antes de romperse).

---

### Habilidades Activas (SkillData)

**Lanzamiento de Roca** — STRIKE
Ki: 15 · Cooldown: 10 s
El usuario levanta una roca del suelo y la lanza al enemigo: daño Fuerza × 1,5 + 50 unidades fijas. Aplica "Peso de la Tierra" (−10 % de Velocidad). El proyectil es físico, no de Ki, por lo que no puede ser absorbido por habilidades de Absorción de Energía.
*Requisito: Fuerza ≥ 25*

**Escudo Sísmico** — SUPPORT
Ki: 25 · Cooldown: 30 s
Levanta un muro de tierra frente al usuario: bloquea el próximo ataque físico y el próximo ataque de Ki recibidos (2 bloqueos). El muro dura hasta que sea destruido o 20 s. Cuando el muro se rompe, los fragmentos hacen daño al enemigo (Fuerza × 0,8).
*Requisito: Fuerza ≥ 40, Resistencia ≥ 30*

**Terremoto** — STRIKE
Ki: 40 · Cooldown: 45 s
El usuario golpea el suelo creando una onda sísmica que recorre el escenario: el enemigo recibe daño (Fuerza × 2,0) y queda aturdido 1,5 s si está en el suelo. Si el enemigo está en el aire (FlyState), solo recibe el 50 % del daño y no se aturde. Aplica "Peso de la Tierra" ×3 simultáneamente.
*Requisito: Fuerza ≥ 60, Día ≥ 20*

**Colisión Continental** — ULTIMATE
Ki: 80 · Cooldown: 100 s
Arranca un bloque masivo de tierra y lo lanza contra el enemigo a alta velocidad. Daño: Fuerza × 4,5. El impacto aplica aturdimiento 2,5 s y "aplastamiento": el enemigo queda bajo el peso de la roca con −30 % de todos los stats durante 10 s. Si el escenario tiene límites de mapa, el impacto con el borde añade +50 % de daño (potencial BFR por impacto de borde).
*Requisito: Fuerza ≥ 80, Vitalidad ≥ 50, Día ≥ 45*

---

### Adquisición

- **Entrenamiento en Montaña** — Acción de día "Entrenar en el Desierto / Montaña" ×3 desbloquea Lanzamiento de Roca.
- **Checkpoint de Fuerza/Resistencia** — Llegar al Día 20 con Fuerza + Resistencia como stats dominantes desbloquea Escudo Sísmico.
- **Evento: Terremoto** — Evento narrativo del Día 22–28 donde ocurre un terremoto en la zona del entrenamiento. El personaje aprende a canalizar la energía sísmica: desbloquea Terremoto.
- **NPC: Maestro de la Tierra** — Relación ≥ 4 antes del Día 40. Enseña Colisión Continental y activa el pasivo Arraigo Telúrico en combate aéreo (también funciona un 50 % a 1 metro del suelo).
- **Metal**: Personajes con Fuerza ≥ 100 desbloquean variante de Lanzamiento de Roca que lanza metal en lugar de roca: +30 % de daño base y el proyectil puede conducir electricidad (combo con Manipulación Eléctrica).

---

## 7. Influencia Social

### Descripción de Diseño
La Influencia Social no es una habilidad de combate directa — opera principalmente en el sistema de días (gestión de NPCs, negociación, eventos narrativos) y tiene efectos pasivos indirectos en el combate. En el sistema de 100 días, el jugador con alta Influencia Social puede desbloquear contenido exclusivo, reducir costos de entrenamiento, y acceder a aliados temporales. En combate, sus efectos son mayormente psicológicos: intimidación, liderazgo, y carisma que debilitan la resolución del enemigo.

**Nota de diseño:** Esta habilidad rompe el molde del formato habitual. Tiene más impacto en el meta-juego de días que en el combate puro. Sus "habilidades activas" son más eventos narrativos que SkillData de combate.

---

### Pasivas

**Reputación de Combatiente**
La reputación del usuario precede a sus peleas: en combates contra enemigos que el jugador ya ha derrotado antes (reencuentros), el enemigo empieza con −10 % de todos sus stats (ya conocen al usuario y le temen).

**Carisma Natural**
En el sistema de NPCs, todas las acciones sociales tienen +1 de puntuación de relación (efecto extracombate). Los NPCs ofrecen mejor precio en intercambios y son más fáciles de convencer para entrenar juntos.

**Liderazgo Táctico**
Cuando un NPC aliado participa en combate (evento especial), el usuario y el aliado ganan +15 % de daño simultáneamente mientras ambos están vivos en el escenario.

**Intimidación Pasiva**
Al inicio de cada combate, si la diferencia de poder (get_poder_total()) entre el usuario y el enemigo es de al menos 2 tiers, el enemigo empieza con −15 % de Velocidad (intimidado antes de pelear).

---

### Habilidades Activas (SkillData)

**Discurso Intimidante** — SUPPORT
Ki: 10 · Cooldown: 40 s (1 uso/combate)
El usuario interrumpe el combate brevemente con una declaración intimidante. El enemigo queda con −20 % de Fuerza durante 12 s. Si el enemigo tiene menos de 3 tiers de diferencia respecto al usuario, el efecto es −10 % en cambio. Contra jefes narrativos, el efecto es reducido a la mitad.
*Requisito: Inteligencia ≥ 20, Intel Combate ≥ 15*

**Provocación Calculada** — SUPPORT
Ki: 0 (sin costo) · Cooldown: 35 s · Duración: 8 s
El usuario provoca al enemigo estratégicamente: el enemigo ataca de forma más agresiva (+20 % de daño) pero también de forma más descuidada (−25 % de Velocidad de esquive, todos sus ataques son más predecibles: Lectura de Intenciones activa permanente durante 8 s). Riesgo/recompensa.
*Requisito: Intel Combate ≥ 30*

**Llamada de Aliados** — SUPPORT
Ki: 0 · Cooldown: (1 uso/combate, disponible solo si hay NPC aliado con relación ≥ 3)
Convoca a un NPC aliado para un ataque asistido: el aliado hace un ataque especial al enemigo (daño fijo según el nivel del NPC, entre Fuerza × 1,5 y Fuerza × 3,0) y luego se retira. Solo disponible si el jugador tiene al menos un NPC con relación ≥ 3 activo en esa etapa del run.
*Sin requisito de stat — requisito de relación social*

**Rendición Forzada** — ULTIMATE
Ki: 30 · Cooldown: 1 uso/combate
Solo usable si el enemigo tiene menos del 20 % de HP. El usuario ofrece condiciones de rendición al enemigo con tanta autoridad que el enemigo las acepta: victoria inmediata sin necesidad de reducir HP a 0. Contra jefes narrativos, esta habilidad falla y en cambio el jefe recupera un 5 % de HP (se niega a rendirse). El texto en HUD muestra el motivo del rechazo.
*Requisito: Inteligencia ≥ 40, Intel Combate ≥ 35, Día ≥ 25*

---

### Adquisición

- **Natural** — Rendición Forzada se desbloquea automáticamente al alcanzar Intel Combate ≥ 35 + Inteligencia ≥ 40 en cualquier día.
- **Construir Relaciones** — Tener ≥ 3 NPCs con relación ≥ 2 antes del Día 20 desbloquea Carisma Natural (pasiva) y Llamada de Aliados.
- **Victoria sin Daño** — Ganar un combate sin recibir daño desbloquea Intimidación Pasiva (pasiva) y Discurso Intimidante.
- **Evento: Negociación de Riesgo** — Evento de día en el que el jugador debe convencer a un grupo hostil sin pelear. Éxito desbloquea Provocación Calculada.

---

## 8. Fusionismo

### Descripción de Diseño
El Fusionismo es una habilidad endgame y posiblemente la más poderosa del juego. Permite al usuario fusionarse temporalmente con un objeto, un aliado NPC, o con un aspecto de sí mismo (sus propias habilidades). En el contexto de Dragon Ball, la fusión es siempre temporal y tiene un costo alto. En el juego, se plantea como un sistema de estado temporal de "modo fusión" con bonuses masivos pero consecuencias post-fusión.

**Nota de balance:** Fusionismo es una habilidad de NG+ en su forma completa. Las versiones tempranas son fusiones parciales con objetos o con el entorno.

---

### Pasivas

**Afinidad de Fusión**
El usuario tiene una resonancia natural con la energía de otros: cada vez que activa una Transformación del sistema principal, gana +5 % de todos los stats adicionales (bonus de fusión parcial con la energía de la transformación).

**Absorción Fusional**
Si el usuario tiene Absorción desbloqueada, las fusiones activas potencian el efecto de absorción: Robo de Poder absorbe un 5 % adicional mientras está activo.

**Estabilidad de Fusión**
La duración de todas las fusiones activas aumenta un 25 %. Los efectos post-fusión (debuffs después de que termina) se reducen en un 30 %.

**Memoria Fusional** *(NG+)*
En el New Game+, el usuario recuerda las fusiones del run anterior: empieza con +10 % de todos los stats permanentes durante el run (residuo de poder de fusiones pasadas).

---

### Habilidades Activas (SkillData)

**Fusión con el Entorno** — SUPPORT
Ki: 30 · Cooldown: 50 s · Duración: 15 s
El usuario absorbe temporalmente las propiedades del terreno circundante: si hay tierra → +30 % de Resistencia; si hay clima activo → +20 % al tipo de daño del clima; si el escenario es neutro → +15 % a todos los stats. Los efectos varían según el estado del escenario al activar.
*Requisito: Vitalidad ≥ 50, Día ≥ 30*

**Fusión de Habilidades** — SUPPORT
Ki: 40 · Cooldown: 60 s · Duración: 20 s
Fusiona temporalmente dos habilidades activas equipadas en una sola: el usuario activa ambas simultáneamente sin costo adicional de Ki. El efecto fusionado es la suma de ambas habilidades con un bonus del 20 % adicional. Al terminar, ambas habilidades entran en cooldown simultáneamente.
*Requisito: Inteligencia ≥ 60, Poder Ki ≥ 70, Día ≥ 40*

**Fusión con Aliado** — ULTIMATE
Ki: 60 · Cooldown: (1 vez/run o 1 vez/combate en NG+) · Duración: 30 s
Solo disponible si hay un NPC aliado con relación ≥ 5. El usuario se fusiona con el aliado: obtiene todos los stats del aliado sumados a los propios (no promediados, sino sumados), gana acceso a la habilidad signature del aliado, y el combo máximo aumenta +3. Al terminar, ambos quedan exhaustos: −20 % de todos los stats durante 15 s.
*Requisito: Inteligencia ≥ 80, Día ≥ 55, NPC aliado relación ≥ 5*

**Gran Fusión** *(NG+ exclusivo)* — ULTIMATE
Ki: 100 · Cooldown: 1 uso/run
El usuario se fusiona consigo mismo: integra todas sus transformaciones activas + todas sus habilidades activas en un estado de poder absoluto durante 40 s. Todos los stats se multiplican ×1,8, todos los cooldowns se resetean, y el usuario se vuelve inmune a efectos de estado. Al terminar: todos los stats caen a 1 durante 20 s (colapso total post-fusión). Si el combate no termina en esos 40 s, el usuario pierde automáticamente al llegar el colapso.
*Requisito: NG+, Día ≥ 10 del NG+, Transformación principal con ≥ 75 % de maestría*

---

### Adquisición

- **Checkpoint Narrativo** — En el Día 45, un evento especial de lore sobre el concepto de fusión desbloquea Fusión con el Entorno.
- **Maestría de Habilidades** — Tener ≥ 5 habilidades activas desbloqueadas y haber usado todas en combate al menos 3 veces desbloquea Fusión de Habilidades.
- **NPC de Máxima Relación** — Alcanzar relación 5 con cualquier NPC antes del Día 55 desbloquea Fusión con Aliado.
- **NG+ Exclusivo** — Gran Fusión está completamente bloqueada en el primer run. Se desbloquea automáticamente al iniciar NG+ si se completó el árbol de Fusionismo previo.

---

## 9. Creación de Portales

### Descripción de Diseño
La Creación de Portales otorga al usuario la capacidad de abrir conexiones entre puntos del espacio. En combate 2D, los portales tienen dos usos principales: reposicionamiento instantáneo (similar a Teletransportación pero diferente en que el portal persiste y otros pueden usarlo) y redirección de ataques (disparar a través de portales para atacar desde ángulos inesperados). Es la base del BFR dimensional.

**Mecánica de portal:** Un portal tiene una entrada y una salida. Cualquier proyectil (propio o enemigo) que entre por la entrada sale por la salida. Si el usuario dispara un Ki Blast al portal, sale desde el lado contrario al enemigo.

---

### Pasivas

**Espacio Conocido**
El usuario puede mantener activo un portal "de emergencia" pasivamente: si recibe daño fatal (caería a 0 HP), hay un 15 % de probabilidad de que el usuario salga automáticamente por un portal abierto en otro punto del mapa, absorbiendo solo el 50 % del daño. Cooldown interno: 1 vez/combate.

**Geometría Espacial**
Los ataques del usuario disparados a través de portales tienen un +25 % de daño bonus (ángulo de ataque inesperado). Los ataques enemigos redirigidos de vuelta al enemigo tienen un +15 % de daño bonus.

**Múltiples Aperturas**
El usuario puede mantener activos hasta 2 portales simultáneamente (normalmente solo 1 a la vez). El segundo portal reduce la duración del primero a la mitad.

**Portal de Escape**
Cuando el HP del usuario cae por debajo del 15 %, puede activar automáticamente un micro-portal de escape que lo aleja instantáneamente del enemigo sin usar una habilidad (una sola vez por combate).

---

### Habilidades Activas (SkillData)

**Apertura de Portal** — SUPPORT
Ki: 20 · Cooldown: 20 s · Duración del portal: 15 s
Abre un portal de entrada y uno de salida en el escenario (el usuario elige las posiciones). Durante 15 s, cualquier proyectil que entre por la entrada sale por la salida. El usuario puede usarlo para esquivar proyectiles enemigos redirigiendo sus propios ataques.
*Requisito: Poder Ki ≥ 50, Inteligencia ≥ 30*

**Ataque por Portal** — KI_BLAST
Ki: 35 · Cooldown: 25 s
Crea un portal frente al usuario y uno detrás del enemigo: dispara un Ki Blast que viaja por el portal y sale a la espalda del enemigo (ataque por sorpresa). El enemigo no puede bloquearlo a menos que tenga Precognición activa. Daño: Poder Ki × 2,0. No puede ser esquivado si la Velocidad del usuario ≥ 1,5× la Velocidad del enemigo.
*Requisito: Poder Ki ≥ 70, Inteligencia ≥ 45, Día ≥ 25*

**Portal de Combate** — SUPPORT
Ki: 45 · Cooldown: 50 s · Duración: 20 s
Abre dos portales estratégicos en el escenario: el usuario puede teletransportarse entre ellos a voluntad durante 20 s (sin costo adicional de Ki, 1 s de cooldown entre usos). Cada vez que el usuario cruza el portal, su siguiente ataque tiene un 30 % de daño bonus (sorpresa posicional).
*Requisito: Poder Ki ≥ 90, Velocidad ≥ 50, Día ≥ 35*

**Colapso Espacial** — ULTIMATE
Ki: 90 · Cooldown: 110 s
Abre múltiples portales alrededor del enemigo y colapsa el espacio: el enemigo recibe daño de múltiples ángulos simultáneamente (8 impactos, daño total Poder Ki × 6,0), queda desorientado 2 s (no puede moverse) y pierde un 20 % de Velocidad durante 15 s (espacio distorsionado alrededor de él). Los portales persisten 5 s post-ataque como peligros de escenario.
*Requisito: Poder Ki ≥ 120, Inteligencia ≥ 60, Día ≥ 50*

---

### Adquisición

- **Inteligencia y Ki** — Al alcanzar Poder Ki ≥ 50 + Inteligencia ≥ 30 simultáneamente, Apertura de Portal se desbloquea automáticamente.
- **Evento: La Grieta** — En el Día 22–30, aparece una anomalía espacial en el entorno. Investigarla (acción de día) desbloquea Ataque por Portal.
- **NPC: Viajero Dimensional** — Relación ≥ 3 antes del Día 35. Enseña Portal de Combate.
- **Maestría Portal** — Usar portales en al menos 10 combates distintos desbloquea Colapso Espacial y activa el pasivo Múltiples Aperturas.

---

## 10. Viaje Dimensional

### Descripción de Diseño
El Viaje Dimensional opera principalmente en el meta-juego de días: permite al personaje explorar dimensiones alternativas entre días para obtener entrenamiento especial, items únicos o aliados de otros planos. En combate, sus aplicaciones son más defensivas y de BFR. Es la habilidad más rara del juego — algunas variantes solo están disponibles en NG+.

---

### Pasivas

**Resonancia Multidimensional**
El usuario ha viajado entre planos: gana +10 % a todos los stats como residuo energético de diferentes dimensiones absorbidas. En NG+, el bonus sube a +20 %.

**Conocimiento del Vacío**
El usuario conoce la naturaleza del espacio entre dimensiones: es inmune a los efectos de BFR (no puede ser expulsado de dimensiones de bolsillo ni sellado permanentemente). Si el enemigo usa Sellado Dimensional, el usuario regresa en 3 s en lugar de 10 s.

**Acceso Dimensional**
Entre días, el usuario puede elegir "Explorar Dimensión" como acción especial (disponible cada 5 días). Cada exploración otorga un bonus aleatorio: stat +10 %, nueva habilidad fragmentaria, o encuentro con NPC dimensional.

**Eco Temporal** *(NG+)*
En NG+, el usuario trae memorias de la dimensión del run anterior: empieza con +5 % de todos los stats permanentes y las primeras 3 habilidades activas de la lista tienen sus cooldowns reducidos permanentemente en 20 %.

---

### Habilidades Activas (SkillData)

**Desvío Dimensional** — SUPPORT
Ki: 35 · Cooldown: 30 s
El usuario se desplaza brevemente a una dimensión paralela durante 1,5 s: invulnerable e invisible para el enemigo. Al regresar, aparece en la posición del enemigo y puede ejecutar un golpe garantizado (daño Fuerza × 2,0, no esquivable). Si el usuario elige no atacar, reaparece en su posición original con una barrera temporal de 2 s.
*Requisito: Poder Ki ≥ 60, Inteligencia ≥ 50, Día ≥ 35*

**Exilio Dimensional** — ULTIMATE
Ki: 70 · Cooldown: 80 s
Abre una brecha dimensional y empuja al enemigo hacia ella: BFR dimensional con 5 s de incapacitación. Si el enemigo no tiene Viaje Dimensional ni Teletransportación Dimensional, tarda 8 s en regresar (condición BFR si > 5 s). Al regresar, pierde un 30 % del HP máximo. Si el enemigo tiene las habilidades mencionadas, regresa en 3 s con −25 % de todos sus stats.
*Requisito: Poder Ki ≥ 90, Inteligencia ≥ 60, Creación de Portales desbloqueado, Día ≥ 50*

**Superposición Dimensional** *(NG+)* — ULTIMATE
Ki: 80 · Cooldown: 90 s · Duración: 25 s
El usuario superpone su posición con una dimensión de mayor poder: durante 25 s, el usuario proyecta una versión de sí mismo de una dimensión más avanzada. Todos sus stats aumentan un 40 % y sus ataques tienen un 20 % de probabilidad de dejar una "estela dimensional" (daño residual del 15 % del daño original por 2 s adicionales). Al terminar, el usuario vuelve a su dimensión base con normalidad (sin penalización).
*Requisito: NG+, Poder Ki ≥ 100, Inteligencia ≥ 80, Día ≥ 20 del NG+*

---

### Adquisición

- **Creación de Portales** — Tener Creación de Portales desbloqueado es prerequisito obligatorio para cualquier habilidad de Viaje Dimensional.
- **Evento Especial: Brecha** — En el Día 35–45, una brecha dimensional aparece durante un combate. Sobrevivir el encuentro desbloquea Desvío Dimensional.
- **NPC: El Viajero** — Un NPC único que aparece solo si el jugador tiene Creación de Portales con ≥ 10 usos. Relación ≥ 3 desbloquea Exilio Dimensional.
- **NG+ Progresión** — Superposición Dimensional solo disponible en NG+ con el árbol completo de Portales + Viaje Dimensional previo.

---

## Tabla de Sinergias Cruzadas

| Habilidad A | Habilidad B | Sinergia |
|---|---|---|
| Manipulación del Clima (Tormenta Eléctrica) | Manipulación Eléctrica (cualquier) | Todas las habilidades eléctricas ganan +35 % daño mientras Tormenta Eléctrica está activa |
| Teletransportación (Dominancia Espacial) | Creación de Portales (Ataque por Portal) | Atacar tras teleportarse Y a través de portal: +30 % + 25 % = +55 % daño total en ese ataque |
| BFR (Lanzamiento Extremo) | Manipulación de la Tierra (Terremoto) | Terremoto aturde → Lanzamiento Extremo inmediato: el enemigo no puede esquivar el lanzamiento |
| Control Corporal (Control Celular) | Regeneración (cualquier tier) | Regeneración activa se duplica mientras Control Celular está activo |
| Influencia Social (Intimidación Pasiva) | Poder de la Furia | El enemigo intimidado ataca con menor Velocidad, lo que aumenta los stacks de Furia Acumulada del usuario |
| Fusionismo (Fusión de Habilidades) | Amplificación (Pico de Rendimiento) + cualquier ULTIMATE | Fusionar Pico de Rendimiento con cualquier ULTIMATE aumenta el tiempo de ambos en la suma |
| Viaje Dimensional (Desvío Dimensional) | Teletransportación (Intercambio de Posición) | Ambos activos en un combate: el usuario puede combinar la invisibilidad del Desvío con el reposicionamiento del Intercambio en el mismo turno |
| Absorción (Robo de Poder) | Fusionismo (Fusión de Habilidades) | Fusionar Robo de Poder con Amplificación Máxima: los stats robados se amplifican con el x2 de Amplificación |
| Manipulación de la Tierra (Peso de la Tierra) | Telekinesis (Agarre Telekinético) | Enemigo ralentizado por Tierra + inmovilizado por Agarre: −40 % Vel + inmovilización = situación de daño máximo |
| Creación de Portales (Múltiples Aperturas) | BFR (Sellado Dimensional) | Dos portales activos + Sellado: el usuario puede enviar al enemigo por portal directamente al sellado sin necesidad de lanzarlo |
