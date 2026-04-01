# Habilidades: Longevidad · Vuelo Espacial · Inmortalidad · Ficha de Referencia: Son Goku

> Documento de diseño — Dragon Ascension
> Formato: Pasivas | Habilidades Activas (SkillData) | Adquisición

---

## 1. Longevidad

### Descripción de Diseño
La Longevidad en un juego de 100 días no se traduce en "vivir más tiempo" de forma directa, sino en **ralentización del desgaste y mantenimiento del pico de rendimiento** durante más días consecutivos. Un personaje longevo no decae en estadísticas conforme el run avanza (mientras que un personaje normal acumula fatiga). Distinción clave con Inmortalidad: la Longevidad eventualmente puede terminar; la Inmortalidad tipo 1 no.

**Mecánica especial de Longevidad:** Introduce el sistema de "Fatiga de Run". Normalmente, a partir del Día 70, los entrenamientos dan un 10 % menos de ganancia de stats (el cuerpo llega a su límite natural). Con Longevidad, este umbral se desplaza al Día 85 o se elimina completamente en niveles altos.

---

### Pasivas

**Cuerpo Eterno**
El umbral de Fatiga de Run se desplaza del Día 70 al Día 85. Los entrenamientos mantienen el 100 % de eficiencia hasta ese punto.

**Reserva Vital**
El HP máximo del personaje aumenta un 5 % adicional por cada 10 días que hayan pasado desde el inicio del run (máx. +30 % al Día 60). Representa la vitalidad acumulada a lo largo del tiempo de vida extendido.

**Aura Longeva**
La recuperación de Ki entre combates (en días de descanso) se realiza en un 25 % más de velocidad. La vida extendida otorga una gestión más eficiente de la energía interior.

**Pico Sostenido** *(desbloqueable en carrera larga)*
Si el personaje llega al Día 80 sin haber recurrido a NG+ ni haber reiniciado, todos sus stats reciben un +8 % permanente para el resto del run. El cuerpo longevo alcanza su punto máximo real tarde pero de forma imponente.

---

### Habilidades Activas (SkillData)

**Ralentización Celular** — SUPPORT
Ki: 20 · Cooldown: 60 s · Duración: 30 s
El usuario reduce temporalmente el metabolismo de su cuerpo durante el combate: el daño con el tiempo (DoT) enemigo se reduce un 50 % durante 30 s y los efectos de envenenamiento o degeneración no pueden apilarse. También reduce el propio consumo de Ki en un 20 % durante la ventana.
*Requisito: Vitalidad ≥ 50*

**Resistencia del Tiempo** — SUPPORT
Ki: 35 · Cooldown: 80 s (1 uso/combate)
El usuario canaliza siglos de experiencia vital condensada: se vuelve inmune a efectos de envejecimiento/debilitamiento temporal durante 20 s y recupera un 20 % de HP. Si el combate lleva más de 3 minutos (combate largo), el bonus de recuperación sube al 35 %.
*Requisito: Vitalidad ≥ 70, Día ≥ 35*

**Legado de Siglos** — ULTIMATE
Ki: 60 · Cooldown: 120 s (1 uso/combate)
El usuario manifiesta el poder acumulado de su larga existencia: todos los stats aumentan un 20 % durante 25 s y el usuario regenera 2 % de HP por segundo durante el efecto. Al terminar, en lugar de debuff post-uso, el usuario mantiene un +5 % a todos los stats de forma permanente para ese combate (el legado permanece). Stackea consigo mismo si se usa en distintos combates del mismo run.
*Requisito: Vitalidad ≥ 90, Día ≥ 50*

---

### Adquisición

- **Raza** — Namekianos, Saiyajins puros, y razas con longevidad natural (según RaceDefinition) comienzan con el pasivo Cuerpo Eterno activo desde el Día 1.
- **Entrenamiento de Resistencia Extrema** — Completar 15 días totales de entrenamientos de Vitalidad/Resistencia desbloquea Ralentización Celular.
- **Evento: El Anciano Inmortal** — NPC especial del Día 30–45 que ha vivido siglos. Relación ≥ 3 enseña Resistencia del Tiempo.
- **Llegar al Día 50** — Solo completar el Día 50 desbloquea el acceso a Legado de Siglos en el panel de habilidades (la experiencia acumulada del propio run).
- **Checkpoint del Día 60** — Vitalidad dominante en el build + Longevidad activa → activa Pico Sostenido.

---

## 2. Vuelo Espacial

### Descripción de Diseño
El Vuelo Espacial es la extensión máxima del sistema de vuelo (FlyState) ya implementado en el motor de combate. En el juego de 100 días, el Vuelo Espacial tiene dos capas: en el **sistema de días** permite explorar locaciones fuera del planeta (misiones especiales, entrenamientos cósmicos), y en **combate** permite escalar la capacidad aérea hasta límites que modifican fundamentalmente la mecánica de pelea (inmunidad a ataques terrestres, velocidad extrema en el aire).

**Requisito base:** El personaje debe tener FlyState (Vuelo básico) desbloqueado antes de acceder a cualquier habilidad de Vuelo Espacial.

**Implementación futura:** El sistema de días podría mostrar opciones de acción "Viaje a [Localización Espacial]" una vez desbloqueado cierto nivel de Vuelo Espacial, dando acceso a entrenamientos únicos.

---

### Pasivas

**Adaptación al Vacío**
El usuario puede operar en el vacío del espacio sin penalizaciones. En combate, esto se traduce en inmunidad a efectos climáticos negativos (Tormenta, Nieve, Viento) mientras está en el aire (FlyState activo).

**Dominio Aéreo**
Cuando el usuario está en FlyState, su Velocidad aumenta un 20 % y sus proyectiles de Ki viajan un 25 % más rápido. El Vuelo Espacial eleva el dominio aéreo a otro nivel.

**Escudo Atmosférico**
Al entrar en FlyState durante combate, el usuario genera brevemente un escudo de fricción atmosférica: el primer ataque recibido dentro de los 2 s de haber comenzado a volar se reduce un 30 % en daño.

**Maniobra Orbital**
Si el usuario ha estado en FlyState por más de 5 s continuos, su siguiente ataque aéreo tiene +35 % de daño (velocidad orbital acumulada). El bonus se resetea si el usuario toca el suelo.

---

### Habilidades Activas (SkillData)

**Ascenso Rápido** — SUPPORT
Ki: 15 · Cooldown: 12 s
Impulso de despegue vertical: el usuario asciende instantáneamente a máxima altitud del escenario en 0,3 s, evadiendo cualquier ataque en trayectoria baja. Desde esa altitud, el siguiente ataque tiene un bonus de +20 % de daño (ventaja de altura). Si el enemigo está en el aire también, no se aplica el bonus pero tampoco el cooldown.
*Requisito: FlyState desbloqueado, Velocidad ≥ 40*

**Bombardeo Atmosférico** — KI_BLAST
Ki: 45 · Cooldown: 35 s
El usuario asciende, alcanza velocidad cuasi-orbital y desciende sobre el enemigo en picado: impacto de Fuerza × 2,0 + Poder Ki × 1,5, más onda de choque que hace daño de área (60 % del impacto principal). El descenso es imparable — solo puede evadirse si el enemigo tiene Teletransportación activa.
*Requisito: Velocidad ≥ 70, Poder Ki ≥ 50, FlyState desbloqueado, Día ≥ 25*

**Maniobra Evasiva Espacial** — SUPPORT
Ki: 30 · Cooldown: 30 s
El usuario traza una trayectoria de escape orbital en 1,5 s: esquiva automáticamente el próximo ataque (físico o ki) y reaparece en el otro extremo del escenario. A diferencia de Teletransportación, este movimiento sí es visible (se ve la estela) y puede ser predicho por enemigos con Precognición. Al reaparecer, el usuario mantiene el momento orbital: +15 % de Velocidad durante 5 s.
*Requisito: Velocidad ≥ 80, FlyState desbloqueado, Día ≥ 30*

**Descenso Meteorítico** — ULTIMATE
Ki: 80 · Cooldown: 100 s
El usuario abandona brevemente el escenario (sale del mapa por arriba), acumula velocidad de reentrada y regresa como un meteorito: daño Fuerza × 5,0, onda de choque que reduce todos los stats del enemigo un 15 % durante 12 s por la magnitud del impacto, y el escenario queda en estado "Escombros" (modifica levemente las posiciones de combate). Inutilizable si el HP del usuario es inferior al 30 % (requiere control total del cuerpo).
*Requisito: Velocidad ≥ 100, Poder Ki ≥ 80, Día ≥ 50*

---

### Adquisición

- **FlyState como prerequisito** — Cualquier habilidad de Vuelo Espacial requiere FlyState desbloqueado + Velocidad ≥ 40.
- **Entrenamiento en Altitud** — Acción de día "Entrenamiento en Cima de la Montaña" ×5 desbloquea Ascenso Rápido y el pasivo Dominio Aéreo.
- **NPC: Guerrero Cósmico** — Relación ≥ 3 antes del Día 30. Enseña Bombardeo Atmosférico y Maniobra Evasiva Espacial.
- **Checkpoint de Velocidad** — Al alcanzar Velocidad ≥ 100 antes del Día 50, se desbloquea Descenso Meteorítico.
- **Raza Saiyajin** — Los Saiyajins pueden volar instintivamente: Ascenso Rápido disponible desde el Día 1 sin requisito de Velocidad.

---

## 3. Inmortalidad

### Descripción de Diseño
La Inmortalidad en Dragon Ascension no se traduce como "el personaje nunca muere" — eso rompería el sistema de combate. En cambio, cada tipo de inmortalidad otorga un **mecanismo de supervivencia extrema**: reducir el daño letal, sobrevivir un hit fatal, regenerar de la destrucción, o transferir la conciencia antes de morir. Los tipos más altos (5, 7, 9) son exclusivos de NG+ o de narrativa endgame.

**Regla de balance:** Un personaje puede tener activo un máximo de **2 tipos de Inmortalidad simultáneamente**. Los tipos se desbloquean progresivamente y son mutuamente excluyentes en algunos pares (ver tabla).

---

### Pasivas

**Voluntad de Vivir**
El umbral de "muerte" del personaje se extiende: los ataques que llevarían el HP a 0 en lugar lo llevan a exactamente 1 HP la primera vez por combate. Esta es la forma más básica de Inmortalidad parcial — una reserva de vida mínima.

**Resistencia al Final**
Cuando el HP cae por debajo del 10 %, el personaje gana +30 % de Resistencia y +20 % de daño (el instinto de supervivencia extremo). Complementa Poder de la Furia.

**Memoria Inmortal** *(NG+)*
Al iniciar un NG+, el personaje trae consigo el recuerdo de haber sobrevivido antes: empieza con el pasivo Voluntad de Vivir mejorado (se activa 2 veces por combate en lugar de 1).

---

### Tipos de Inmortalidad como Habilidades Activas

> Cada tipo es una habilidad SUPPORT o ULTIMATE. El jugador desbloquea tipos progresivamente y puede equipar hasta 2 simultáneamente.

**[Tipo 1] Vida Eterna** — SUPPORT (pasivo de run)
Ki: 0 (sin costo en combate) · Efecto permanente de run
El personaje no puede morir por causas "naturales del run": las acciones de entrenamiento no tienen penalizaciones de HP permanente, los eventos de desgaste no reducen el HP máximo de forma irreversible. En combate, no otorga invulnerabilidad — solo bloquea la degradación de stats por fatiga acumulada en el run.
*Nota: Es esencialmente el sistema de Longevidad elevado. Si el jugador tiene Longevidad activa, este tipo está disponible como upgrade.*
*Requisito: Longevidad desbloqueada, Día ≥ 40*

**[Tipo 2] Inmortalidad Resiliente** — SUPPORT
Ki: 0 · Cooldown: 45 s (pasivo reactivo)
El personaje puede sobrevivir a lesiones que normalmente serían letales sin curación: la primera vez por combate que un ataque llevaría al HP a 0, el personaje sobrevive con 1 HP y gana inmunidad a daño durante 2 s (el cuerpo simplemente no cae). Diferente al pasivo Voluntad de Vivir: esta habilidad se activa activamente y tiene cooldown entre usos (3 usos máximo en combates de NG+).
*Requisito: Vitalidad ≥ 60, Resistencia ≥ 40*

**[Tipo 3] Inmortalidad por Regeneración** — ULTIMATE
Ki: 50 · Cooldown: 90 s (1 uso/combate)
Si el personaje cae a 0 HP, en lugar de morir entra en estado "Reconstrucción" durante 5 s: el cuerpo se regenera al 40 % del HP máximo. Durante esos 5 s es vulnerable pero no puede ser "rematado" (el HP no puede bajar de 1). Si durante la Reconstrucción el usuario es golpeado, el tiempo se extiende 1 s por golpe (máx. +3 s extra). Complementa directamente el sistema de Regeneración (documento 2) — si ambos están activos, la regeneración al activar sube al 60 %.
*Requisito: Regeneración Tier ≥ 5 desbloqueada, Vitalidad ≥ 80, Día ≥ 40*

**[Tipo 4] Resurrección** — ULTIMATE
Ki: 0 · (1 uso/run en primer run, 2 usos/run en NG+)
El personaje muere realmente pero regresa a la vida: al llegar a 0 HP, el combate no termina en derrota. En cambio, el personaje cae durante 3 s (inmóvil, completamente vulnerable) y luego resucita con 30 % de HP. El enemigo puede atacar durante esos 3 s — si recibe daño durante la resurrección, el HP recuperado se reduce proporcionalmente. Solo funciona 1 vez por run (2 en NG+). Si el personaje tiene Inmortalidad Tipo 3 también activa, ambas se activan en secuencia: Tipo 3 primero, luego Tipo 4 si Tipo 3 falló.
*Requisito: Inmortalidad Tipo 3 desbloqueada, Día ≥ 55*

**[Tipo 5] Amortalidad** *(NG+ exclusivo)* — ULTIMATE (pasivo permanente)
Ki: 0 · Permanente durante el run de NG+
El personaje trasciende la dicotomía vida/muerte: no puede ser eliminado por medios convencionales. En combate, los ataques que llevarían el HP a 0 lo llevan al 1 %, y el personaje no puede morir en combate excepto por ataques que específicamente "borren de la existencia" (identificados en el sistema como daño_existencial, reservado para jefes endgame). Fuera de combate, todas las penalizaciones de HP permanente son ignoradas.
*Requisito: NG+, Tipos 1, 2, 3 y 4 todos desbloqueados en el run previo*

**[Tipo 6] Parásito / Transferencia de Conciencia** — ULTIMATE
Ki: 70 · (1 uso/combate)
Antes de morir, el usuario transfiere su conciencia a un "cuerpo secundario" — en el contexto del juego, a su Ki proyectado. El personaje "muere" físicamente pero su Ki persiste: durante 8 s el jugador controla una versión etérea del personaje con el 20 % de los stats originales. Si logra tocar al enemigo durante esos 8 s, se "reposee" un fragmento corporal y regresa al 25 % de HP. Si los 8 s pasan sin contacto, derrota. Mecánicamente: segunda oportunidad de alto riesgo.
*Requisito: Poder Ki ≥ 100, Inteligencia ≥ 70, Día ≥ 45*

**[Tipo 7] No-Muertos** *(narrativo — acceso limitado)*
Ki: 0 · Efecto permanente (race-gated)
Solo disponible para personajes de raza "No-Muerto" (si se implementa como raza custom). El personaje ya está técnicamente muerto: inmune a venenos, sangrado, y efectos de estado biológicos. El HP funciona como "integridad estructural" en lugar de vida. No puede ser curado por habilidades de Curación convencionales (requiere Reparación en su lugar). En combate, el umbral de "muerte" se alcanza solo cuando el HP llega a 0 dos veces en el mismo combate (la primera vez el cuerpo se "fragmenta" y sigue combatiendo con penalizaciones).
*Requisito: Raza No-Muerto*

**[Tipo 8] Inmortalidad Dependiente** — ULTIMATE
Ki: 40 · Cooldown: (1 uso/run)
El personaje vincula su vida a un "objeto de poder" (un recurso del juego a elegir: el propio Ki máximo, un NPC aliado, o el contador de días restantes). Mientras ese objeto/vínculo exista, el personaje no puede morir. En práctica: durante un combate, el HP no puede llegar a 0 mientras el Ki del personaje sea mayor que 0. El personaje muere solo si el Ki llega a 0 antes que el HP. Obliga a gestionar Ki como segunda barra de vida.
*Requisito: Ki ≥ 150, Poder Ki ≥ 80, Día ≥ 50*

**[Tipo 9] Trascendental** *(NG+ narrativo, endgame absoluto)* — ULTIMATE
Ki: 0 · Activo permanente en NG+ Día ≥ 80
El verdadero ser del personaje existe en un plano superior: si el cuerpo físico muere en combate, la esencia trasciende. El combate no termina en derrota — el personaje manifiesta su forma trascendental con el 50 % de sus stats durante 30 s adicionales. Si derrota al enemigo en esos 30 s, victoria. Si no, derrota por agotamiento del ser. Esta es la forma final de inmortalidad disponible en el juego.
*Requisito: NG+, Día ≥ 80 del NG+, al menos 3 tipos de Inmortalidad previos desbloqueados*

---

### Compatibilidad entre Tipos

| Tipo | Compatible con |
|---|---|
| Tipo 1 | Tipo 2, 3, 8 |
| Tipo 2 | Tipo 1, 3, 4 |
| Tipo 3 | Tipo 1, 2, 4, 6 |
| Tipo 4 | Tipo 2, 3 |
| Tipo 5 *(NG+)* | Solo funciona solo (absorbe todos los beneficios anteriores) |
| Tipo 6 | Tipo 3 |
| Tipo 7 *(racial)* | Tipo 2 |
| Tipo 8 | Tipo 1, 3 |
| Tipo 9 *(NG+ endgame)* | Solo funciona solo |

---

### Adquisición

- **Tipo 1** — Upgrade de Longevidad, disponible Día 40+.
- **Tipo 2** — Vitalidad ≥ 60 + Resistencia ≥ 40. Disponible desde Día 20.
- **Tipo 3** — Requiere Regeneración Tier 5 activa. Disponible Día 40+.
- **Tipo 4** — Requiere Tipo 3. Disponible Día 55. Solo 1 uso/run.
- **Tipo 5** — NG+ exclusivo. Requiere Tipos 1–4 del run anterior.
- **Tipo 6** — Evento narrativo especial: "La Muerte del Guerrero" (Día 40–50). NPC que sobrevivió transfiriendo su esencia enseña la técnica.
- **Tipo 7** — Racial (No-Muerto). No tiene ruta de adquisición por entrenamiento.
- **Tipo 8** — Evento del Día 50: "El Pacto". El personaje hace un voto de poder con una entidad mayor. Requiere Ki ≥ 150.
- **Tipo 9** — NG+ endgame. Activo automáticamente si cumple condiciones en Día 80 del NG+.

---

## 4. Ficha de Referencia: Son Goku

> **Uso en el juego:** Esta ficha es el documento de referencia para implementar a Son Goku como personaje en Dragon Ascension, ya sea como jefe, NPC entrenador, aliado o personaje jugable desbloqueado. Las técnicas y habilidades se mapean al sistema de SkillData existente.

---

### Perfil de Stats Base (Referencia para EnemyData / CharacterData)

| Stat | Valor sugerido (Arco Z inicial) | Valor sugerido (Super) |
|---|---|---|
| Fuerza | 180 | 450 |
| Velocidad | 200 | 500 |
| Ki | 220 | 600 |
| Vitalidad | 150 | 400 |
| Resistencia | 120 | 350 |
| Poder Ki | 250 | 700 |
| Inteligencia | 60 | 80 |
| Intel Combate | 190 | 400 |

**Tier inicial:** Legendario → Divino (arcos progresivos)
**Raza:** Saiyajin
**Fisiología especial:** Todas las pasivas de Raza Saiyajin activas + Zenkai Boost (ver abajo)

---

### Kit de Habilidades de Goku (SkillData)

#### Ataques Básicos / Combos

**Jan-Ken Puño (Piedra, Tijeras y Papel)** — STRIKE
Ki: 0 · Cooldown: 0 (ataque básico mejorado)
Combo de 3 hits: golpe fuerte (Fuerza × 1,0), pinchazo en ojos (ignora 20 % de Resistencia), palmada abierta (empuja 40 unidades atrás). Cuando se activa como Goku base, es su ataque básico. En versión jugable, reemplaza el ataque básico estándar.

**Dragonthrow** — STRIKE
Ki: 10 · Cooldown: 12 s
Agarra al enemigo y lo lanza con giro: daño Fuerza × 1,8, desplazamiento de 200 unidades. Si el enemigo choca con el borde, aturdimiento 1,5 s. Puede interrumpirse si la Fuerza del enemigo supera en 50 puntos a la del usuario.

**Hasshuken** — SUPPORT
Ki: 15 · Cooldown: 18 s · Duración: 4 s
Mueve los brazos a velocidad extrema simulando 8 golpes simultáneos: el siguiente ataque físico golpea 4 veces (daño total Fuerza × 2,4) y es muy difícil de bloquear (−40 % de efectividad de bloqueo del enemigo).
*Nota: Goku la usa como respuesta a técnicas de múltiples brazos.*

---

#### Técnicas de Ki

**Kamehameha** — KI_BLAST
Ki: 40 · Cooldown: 20 s
El rayo de Ki signature. Carga 0,8 s y dispara un haz de alta potencia: daño Poder Ki × 3,0. Variantes:
- Pie: puede dispararse desde los pies para impulso o sorpresa (usable en FlyState sin cooldown adicional).
- Doblado: puede curvarse en vuelo para rodear obstáculos (Intel Combate ≥ 100 requerido para la variante).
*Escalada: a mayor Poder Ki, el Kamehameha no tiene límite de escala — su daño base crece linealmente.*

**Kiai** — KI_BLAST
Ki: 15 · Cooldown: 8 s
Onda de Ki invisible proyectada con las manos o la mirada: daño Poder Ki × 1,0 + empuje de 80 unidades. Especial: puede ejecutarse sin animación telegráfica larga (0,2 s de inicio). Útil como interrupción de combos del enemigo.

**Taiyoken** — SUPPORT
Ki: 20 · Cooldown: 30 s
Flash de luz cegador: el enemigo queda cegado (no puede atacar) durante 3 s. Durante el ceguera, todos los ataques del usuario son garantizados (no pueden ser esquivados). El enemigo con Sentidos Mejorados o Precognición reduce la duración a 1,5 s.

**Kienzan (Disco Destructor)** — KI_BLAST
Ki: 35 · Cooldown: 25 s
Disco de Ki afilado como navaja: daño Poder Ki × 2,5 con penetración — ignora el 40 % de la Resistencia del enemigo independientemente de su nivel de poder. No puede ser bloqueado físicamente. Si el enemigo tiene el doble de poder que Goku, el disco igual penetra (mecánica canónica).

**Genki-Dama (Esfera del Espíritu)** — ULTIMATE
Ki: 0 · Cooldown: 1 uso/combate · Carga: 5 s
Absorbe energía del entorno: durante la carga de 5 s el usuario es vulnerable. La esfera se forma progresivamente y su daño escala con el tiempo de carga. Daño base (carga completa): Poder Ki × 8,0. Puede usarse a la mitad de carga (2,5 s) por Poder Ki × 4,0. Condición especial: si el personaje tiene "Corazón Puro" (flag de run determinado por las elecciones narrativas), el daño base sube a ×12,0. Contra enemigos con "Corazón Maligno" (jefes narrativos), el multiplicador sube adicionalmente ×1,5.

---

#### Técnicas de Movimiento

**Shunkan Idō (Teletransportación Instantánea)** — SUPPORT
Ki: 10 · Cooldown: 8 s
La versión Goku de Teletransportación: se teletransporta a la posición de cualquier fuente de Ki detectable. En combate, se teletransporta a la posición del enemigo instantáneamente. Diferencia con Teletransportación estándar: requiere concentración de 0,3 s con dedos en la frente (animación corta, interrumpible si recibe daño en ese instante). Si el enemigo suprime su Ki (habilidad de Supresión de Ki), Shunkan Idō no puede localizarlo.

---

#### Transformaciones (Mapeo al Sistema Principal)

> Estas transformaciones se cargan como TransformationDefinition para Goku como NPC/jefe. Para uso jugable, se acceden a través del sistema de transformaciones normal.

**Super Saiyajin (SSJ)** — TransformationDefinition
- Multiplicador de stats: Fuerza ×2,5, Velocidad ×2,2, Ki ×2,0, Poder Ki ×2,8
- Aura: amarilla eléctrica
- Condición de desbloqueo (jugable): nivel de maestría ≥ 1, evento emocional de alto impacto
- Drain de Ki: 3 Ki/s (nivel base), 0 Ki/s (dominado / SSJ a máximo poder)
- Nota balance: SSJ sin dominar eleva agresividad del personaje; con dominio es estable.

**Super Saiyajin 2 (SSJ2)** — TransformationDefinition
- Multiplicador sobre SSJ: Fuerza ×1,6, Velocidad ×1,5, Poder Ki ×1,8
- Aura: amarilla con relámpagos
- Drain de Ki: 5 Ki/s
- Condición: SSJ maestría ≥ 75 %, Día ≥ 50

**Super Saiyajin 3 (SSJ3)** — TransformationDefinition
- Multiplicador sobre SSJ2: Fuerza ×1,8, Velocidad ×1,4, Poder Ki ×2,0
- Aura: amarilla intensa, sin cejas
- Drain de Ki: 12 Ki/s (muy ineficiente — solo viable en combates cortos)
- Condición: SSJ2 maestría ≥ 50 %, Día ≥ 65
- Nota balance: Solo mantenible ~3 minutos de combate real antes de colapso por Ki.

**Kaio-ken** — TransformationDefinition (stackeable sobre SSJ Blue)
- Multiplicadores variables: ×1 (base), ×2, ×4, ×10, ×20 (máximo sin SSJ)
- Drain: escala con el multiplicador (×1 = 1 Ki/s, ×20 = 20 Ki/s)
- Daño al cuerpo: por cada segundo de Kaio-ken ×10 o superior, el usuario recibe 1 % del HP máximo como daño propio
- Condición: Entrenamiento con NPC Kaio-sama (evento especial Día 30–40)

**Super Saiyajin Dios (SSJG)** — TransformationDefinition
- Multiplicador: todos los stats ×4,0
- Aura: roja, Ki divino (inmune a absorción de Ki normal)
- Requisito especial: Ritual de 6 Saiyajins justos O entrenamiento divino (evento de muy alta rareza)
- Efecto residual: al salir de SSJG, el usuario retiene +15 % de todos los stats en forma base

**Super Saiyajin Blue (SSJB)** — TransformationDefinition
- Multiplicador sobre SSJG: ×1,5 (todos los stats)
- Aura: azul cristalina
- Compatible con Kaio-ken: SSJB + Kaio-ken ×10 = stats ×6,0 total, drain extremo
- Condición: SSJG maestría ≥ 50 %, control de Ki perfecto (Poder Ki ≥ 400)

**Ultra Instinto -Señal-** — TransformationDefinition
- Multiplicador: Velocidad ×5,0, defensa automática (ver abajo)
- Mecánica especial: el personaje esquiva automáticamente los ataques (dodge pasivo del 40 % de los golpes recibidos). Las habilidades ilusorias/mentales no funcionan contra esta forma.
- Condición de activación: solo se activa cuando el HP cae por debajo del 10 % (no controlable voluntariamente en el primer run)
- Limitación: no puede usarse ofensivamente de manera óptima (ataques reducidos a ×0,8 base)

**Ultra Instinto (Dominado)** *(NG+ exclusivo)* — TransformationDefinition
- Multiplicador: todos los stats ×6,0
- Mecánica especial: dodge automático del 70 % de los ataques, ataques instintivos al máximo (daño ×1,5 sobre la forma señal)
- Condición: NG+, Ultra Instinto -Señal- maestría ≥ 100 %, Día ≥ 60 del NG+

---

#### Técnica de Sellado

**Mafuba (Ola de Contención del Mal)** — ULTIMATE
Ki: 60 · Cooldown: 1 uso/run · Solo funciona contra enemigos con flag "maligno"
Sella al enemigo en un recipiente dimensional durante el combate: victoria alternativa inmediata si tiene éxito (50 % de probabilidad base, +20 % por cada 50 puntos de Inteligencia sobre 60). Si falla, el enemigo rompe el sello, recupera un 15 % de HP y Goku pierde 20 % de su HP por el esfuerzo. Nota canónica: Goku necesita el sello ofuda correcto — en juego se representa como que el usuario debe tener el ítem "Ofuda de Contención" en el inventario.

---

### Zenkai Boost — Sistema Especial para Raza Saiyajin

> El Zenkai Boost es la mecánica más canónica de los Saiyajins: cada vez que un Saiyajin casi muere y se recupera, su poder aumenta permanentemente.

**Implementación en Dragon Ascension:**
- Cada vez que el personaje (raza Saiyajin) sobrevive a un combate con HP ≤ 15 % al finalizar, todos sus stats base suben un 5 % permanente para el resto del run (Zenkai menor).
- Si el personaje sobrevive con HP ≤ 5 %, el bonus es 10 % (Zenkai mayor).
- Máximo de Zenkai acumulable: +100 % de stats base totales (equivalente a 20 Zenkai menores o 10 Zenkai mayores).
- El Zenkai Boost no se aplica si el personaje utilizó habilidades de Inmortalidad tipo 3/4 para sobrevivir (la recuperación debe ser genuina — HP que llegó a casi 0 sin habilidades de sobrevivencia activadas).

---

### Notas de Implementación

**Como Jefe (EnemyData):**
- Cargar Goku como EnemyData con Behavior `AGGRESSIVE` en los primeros arcos (DB) y `DEFENSIVE_COUNTER` en arcos superiores (Z, Super).
- Sus transformaciones se activan automáticamente cuando su HP cae por debajo del 60 %, 40 %, y 20 % (secuencia de escalada).
- Shunkan Idō activo: si el jugador está a más de 300 unidades de distancia, Goku se teletransporta automáticamente.

**Como NPC Entrenador:**
- Relación ≥ 2: desbloquea Kamehameha y Kiai para el jugador.
- Relación ≥ 4: desbloquea Shunkan Idō y Kaio-ken (si el jugador pasó tiempo en el planeta de Kaio-sama).
- Relación ≥ 5 + Día ≥ 70: desbloquea SSJ para jugadores de raza Saiyajin.

**Como Personaje Jugable (desbloqueado):**
- Todo el kit anterior más el sistema de Zenkai Boost activo.
- La ruta de transformaciones sigue el árbol canónico: SSJ → SSJ2 → SSJ3 → SSJG → SSJB → UI Señal → UI Dominado (NG+).
