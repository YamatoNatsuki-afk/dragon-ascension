# Dragon Ascension — Regeneración
> Sistema de progresión por niveles. Cada tier amplifica las pasivas y activas del anterior.
> Stats clave: vitalidad · resistencia · ki · poder_ki

---

## Visión General del Sistema

La Regeneración funciona como un árbol de niveles: desbloquear un tier superior mantiene todas las ventajas de los niveles inferiores y añade nuevas capacidades. El jugador empieza en Baja y puede progresar hasta Divina si cumple las condiciones extremas del run.

| Tier | Nombre | HP regenerado/s en combate | Requisito principal |
|------|--------|---------------------------|---------------------|
| 1 | Baja | 0.5% HP/s | vitalidad ≥ 60 |
| 2 | Baja-Media | 1.2% HP/s | vitalidad ≥ 100 |
| 3 | Baja-Alta | 2.0% HP/s | vitalidad ≥ 150 |
| 4 | Media-Baja | 3.5% HP/s | vitalidad ≥ 220 |
| 5 | Media | 5.5% HP/s | vitalidad ≥ 300 |
| 6 | Media-Alta | 8.0% HP/s | vitalidad ≥ 400 + ki ≥ 200 |
| 7 | Alta-Baja | 12% HP/s | vitalidad ≥ 500 + poder_ki ≥ 250 |
| 8 | Alta-Media | 18% HP/s | vitalidad ≥ 650 + ki ≥ 350 |
| 9 | Alta | 25% HP/s | vitalidad ≥ 800 + poder_ki ≥ 400 |
| 10 | Divina-Baja | Resurrección automática (1/run) | Tier 9 activo + día ≥ 80 |
| 11 | Divina-Media | Resurrección ilimitada | Solo por evento narrativo |

---

## Tier 1 — Regeneración Baja

> Curación acelerada de heridas normales. Lo que tardaría semanas, se cierra en segundos.
> *Referencia: Goku Xeno, Gon Freecss, Thanos (MCU)*

### Pasivas

| Nombre | Efecto |
|--------|--------|
| **Factor Curativo** | Regenera 0.5% del HP máximo por segundo durante el combate. |
| **Heridas Efímeras** | Los cortes y golpes menores se cierran al instante. El jugador no acumula penalizaciones de HP bajo hasta llegar al 40% HP. |
| **Recuperación Fuera de Combate** | Entre combates, el HP se recupera al 100% automáticamente (sin costo de acción). |

### Habilidades Activas

#### SEGUNDO VIENTO *(SUPPORT — Curación mínima)*
> Un impulso de voluntad que activa la regeneración a máxima velocidad por unos instantes.
- **Costo de Ki:** 10%
- **Efecto:** Recupera 15% del HP máximo instantáneamente.
- **Cooldown:** 18.0s
- **Requisito:** vitalidad ≥ 60

#### RESISTIR *(SUPPORT — Tanque)*
> El usuario ignora el dolor y sigue combatiendo por pura determinación.
- **Costo de Ki:** 8%
- **Efecto:** Durante 4 segundos, cualquier daño recibido se reduce en 40%. La regeneración pasiva triplica su velocidad durante ese tiempo.
- **Cooldown:** 14.0s
- **Requisito:** resistencia ≥ 80

### Cómo Obtenerlo
| Método | Condición |
|--------|-----------|
| **Acción de día:** "Entrenamiento de Resistencia" | Desde día 1. Subir vitalidad a ≥ 60 activa el Tier 1 automáticamente. |
| **Checkpoint Día 10** | Si vitalidad ≥ 60 + resistencia ≥ 50, se confirma el Tier 1 y se desbloquea "Segundo Viento". |
| **Raza: Saiyan / Namekiano** | Comienzan con Tier 1 activo desde el inicio del run. |
| **NPC: Médico / Curandero** | Relación básica (≥25%). Sube vitalidad +2 por visita sin riesgo de lesión. |

---

## Tier 2 — Regeneración Baja-Media

> Heridas que dejarían grandes cicatrices desaparecen en minutos. Quemaduras, laceraciones profundas.
> *Referencia: Johnny Joestar, Shinobu Oshino, Hiei*

### Pasivas *(acumulativas con Tier 1)*

| Nombre | Efecto |
|--------|--------|
| **Piel Endurecida** | Las quemaduras y el daño de Ki del enemigo reducen 15% su efectividad sobre el jugador. |
| **Sin Cicatrices** | La penalización de daño por HP bajo no comienza hasta el 25% HP (antes era 40%). |
| **Regeneración Fuera de Combate Mejorada** | El HP se recupera entre combates + un 10% adicional de los stats temporales perdidos. |

### Habilidades Activas

#### PULSO CURATIVO *(SUPPORT — Curación media)*
> Una ola de energía interna sella las heridas más profundas en segundos.
- **Costo de Ki:** 18%
- **Efecto:** Recupera 28% del HP máximo. Si el HP estaba por debajo del 30%, recupera un 40% adicional.
- **Cooldown:** 20.0s
- **Requisito:** vitalidad ≥ 100

#### CAPARAZÓN VITAL *(SUPPORT — Barrera)*
> El cuerpo genera una barrera biológica que absorbe el daño entrante y lo convierte en energía curativa.
- **Costo de Ki:** 22%
- **Efecto:** Durante 6 segundos, el 50% del daño recibido se convierte en HP recuperado en vez de perdido.
- **Cooldown:** 22.0s
- **Requisito:** vitalidad ≥ 100, resistencia ≥ 100

### Cómo Obtenerlo
| Método | Condición |
|--------|-----------|
| **Progresión automática** | Al superar vitalidad ≥ 100 con Tier 1 activo. |
| **Checkpoint Día 20** | Si Tier 1 activo + vitalidad ≥ 100, se confirma Tier 2 y se desbloquea "Pulso Curativo". |
| **Acción de día:** "Entrenamiento de Aguante" | Disponible día 12+. Alto riesgo de daño, alta ganancia de vitalidad. |

---

## Tier 3 — Regeneración Baja-Alta

> Regeneración de dedos, orejas, daño menor en órganos. La extremidad perdida puede volver a unirse.
> *Referencia: Wally West, Hercules (Marvel), Vilgax*

### Pasivas *(acumulativas)*

| Nombre | Efecto |
|--------|--------|
| **Integridad Corporal** | El jugador no puede ser aturdido permanentemente. Los aturidimientos duran máximo 1 segundo. |
| **Regeneración de Combate Mejorada** | La regeneración pasiva sube a 2.0% HP/s. En los primeros 3 segundos tras recibir un golpe crítico, regenera el doble. |
| **Umbral de Dolor Elevado** | La penalización de daño por HP bajo no existe hasta el 15% HP. |

### Habilidades Activas

#### REGENERACIÓN DE EMERGENCIA *(SUPPORT — Curación rápida bajo presión)*
> El cuerpo prioriza la supervivencia por encima de todo cuando el peligro es máximo.
- **Costo de Ki:** 25%
- **Efecto:** Si HP < 25%, recupera 45% del HP máximo instantáneamente. Si HP ≥ 25%, recupera solo 20%.
- **Cooldown:** 18.0s
- **Requisito:** vitalidad ≥ 150

#### REINTEGRACIÓN *(SUPPORT — Anti-debuff)*
> El cuerpo expulsa venenos, quemaduras y estados alterados regenerando el tejido dañado.
- **Costo de Ki:** 15%
- **Efecto:** Elimina todos los debuffs activos y recupera 10% del HP por cada debuff eliminado.
- **Cooldown:** 12.0s
- **Requisito:** vitalidad ≥ 150, resistencia ≥ 120

#### VOLUNTAD INQUEBRANTABLE *(ULTIMATE — Resistencia total)*
> El usuario se niega a caer. Incluso si el cuerpo falla, la mente sigue de pie.
- **Costo de Ki:** 40%
- **Efecto:** Durante 10 segundos, el HP del jugador no puede bajar por debajo de 1. Todo daño que debería eliminarlo queda suspendido. Al terminar el efecto, recupera 30% del HP.
- **Cooldown:** 35.0s
- **Requisito:** vitalidad ≥ 150, resistencia ≥ 150

### Cómo Obtenerlo
| Método | Condición |
|--------|-----------|
| **Progresión automática** | Superar vitalidad ≥ 150 con Tier 2 activo. |
| **Checkpoint Día 30** | Tier 2 activo + vitalidad ≥ 150 → se desbloquea "Voluntad Inquebrantable". |
| **NPC: Maestro de Resistencia** | Relación alta (≥70%). Desbloquea "Reintegración" con 3 sesiones de entrenamiento. |

---

## Tier 4 — Regeneración Media-Baja

> Regeneración de extremidades completas, desmembramiento, destrucción grave de órganos.
> *Referencia: Piccolo, Ichigo Kurosaki, Yoda*

### Pasivas *(acumulativas)*

| Nombre | Efecto |
|--------|--------|
| **Cuerpo que No Se Rinde** | Regenera 3.5% HP/s. Inmune a efectos de sangrado y veneno permanente. |
| **Resistencia Sobrehumana** | El daño mínimo por hit que puede recibir el jugador es 1. Ningún golpe puede hacer daño instantáneo letal directo. |
| **Ki Vital** | El Ki contribuye a la regeneración: cada 100 puntos de Ki máximo añaden +0.3% HP/s adicional a la regeneración. |

### Habilidades Activas

#### RECONSTRUCCIÓN ACELERADA *(SUPPORT — Curación masiva)*
> El cuerpo dedica toda su energía vital a reconstruirse a una velocidad imposible.
- **Costo de Ki:** 35%
- **Efecto:** Recupera 60% del HP máximo en 3 segundos (20% por segundo). Durante esos 3 segundos el jugador no puede atacar pero puede moverse.
- **Cooldown:** 25.0s
- **Requisito:** vitalidad ≥ 220, ki ≥ 120

#### DRENAJE VITAL *(STRIKE — Vampirismo)*
> El usuario golpea al enemigo y absorbe su energía vital directamente.
- **Costo de Ki:** 20%
- **Daño:** ×2.0 sobre fuerza
- **Hit Count:** 1
- **Efecto especial:** Recupera HP igual al 60% del daño infligido.
- **Cooldown:** 8.0s
- **Requisito:** vitalidad ≥ 220

### Cómo Obtenerlo
| Método | Condición |
|--------|-----------|
| **Progresión automática** | Superar vitalidad ≥ 220 con Tier 3 activo. |
| **Checkpoint Día 40** | Tier 3 activo + vitalidad ≥ 220 + haber sobrevivido con HP < 5% al menos 1 vez. |
| **Acción de día:** "Meditación de Ki Vital" | Disponible día 25+. Requiere ki ≥ 100. Sube vitalidad y ki simultáneamente. |
| **Raza: Namekiano** | Desbloquea Tier 4 desde el día 40 si vitalidad ≥ 180 (requisito reducido). |

---

## Tier 5 — Regeneración Media

> Regeneración desde decapitación, daño cerebral grave o aplastamiento total.
> *Referencia: Sayaka Miki, Mario, Mark Evans*

### Pasivas *(acumulativas)*

| Nombre | Efecto |
|--------|--------|
| **Inmortalidad Parcial** | Regenera 5.5% HP/s. El jugador no muere al llegar a 0 HP — en cambio, queda a 1 HP con un escudo de 2 segundos de invulnerabilidad. Esto puede ocurrir 1 vez por combate. |
| **Cerebro Indestructible** | Inmune a confusión, control mental y efectos de reducción de inteligencia o intel_combate. |
| **Adaptación Rápida** | Cada tipo de daño recibido más de 2 veces en un combate reduce su efectividad en 10% (máx. 40%). |

### Habilidades Activas

#### RESURGIR *(ULTIMATE — Pseudo-resurrección)*
> Justo en el límite de la muerte, el cuerpo se reconstruye con una ferocidad brutal.
- **Costo de Ki:** 0 (se activa automáticamente cuando HP llega a 0, si está equipada y no está en cooldown)
- **Efecto:** Al llegar a 0 HP, recupera 50% del HP máximo y entra en modo "Límite Roto" durante 6 segundos (daño ×1.8, invulnerabilidad parcial 30%).
- **Cooldown:** 40.0s (por combate)
- **Requisito:** vitalidad ≥ 300, resistencia ≥ 200

#### FLUJO VITAL *(SUPPORT — Regeneración activa masiva)*
> El usuario canaliza su Ki directamente hacia la regeneración de tejidos a velocidad extrema.
- **Costo de Ki:** 40%
- **Efecto:** Regenera 80% del HP máximo distribuido en 5 segundos. La velocidad de regeneración aumenta cada segundo (16% el primer segundo → 32% el quinto).
- **Cooldown:** 30.0s
- **Requisito:** vitalidad ≥ 300, ki ≥ 180

### Cómo Obtenerlo
| Método | Condición |
|--------|-----------|
| **Progresión automática** | Superar vitalidad ≥ 300 con Tier 4 activo. |
| **Checkpoint Día 50** | Tier 4 activo + vitalidad ≥ 300 + haber usado "Inmortalidad Parcial" al menos 3 veces en runs anteriores o el run actual. |
| **Flag: Superviviente** | Haber sobrevivido desde 0 HP (por la pasiva de Tier 4) 5 veces en total → confirma Tier 5 si los stats lo permiten. |

---

## Tier 6 — Regeneración Media-Alta

> Regeneración desde ser cortado a pedazos, o a partir de una pequeña parte como la cabeza o un solo dedo.
> *Referencia: Venom, Ryūko Matoi, Dio Brando*

### Pasivas *(acumulativas)*

| Nombre | Efecto |
|--------|--------|
| **Fragmentación Inútil** | Regenera 8.0% HP/s. Los ataques de daño múltiple (multi-hit) reducen su daño total en 25% contra el jugador. |
| **Ki Fusionado con el Cuerpo** | El Ki actúa como HP secundario: cuando el HP llega a 0, consume Ki para seguir vivo (1 Ki = 0.5 HP equivalente). |
| **Inmortalidad Reforzada** | La pasiva "Inmortalidad Parcial" del Tier 5 ahora puede activarse 2 veces por combate. |

### Habilidades Activas

#### DESINTEGRACIÓN CONTROLADA *(ULTIMATE — Transformación táctica)*
> El usuario se fragmenta voluntariamente para esquivar un ataque y se reintegra al instante.
- **Costo de Ki:** 45%
- **Efecto:** El jugador se vuelve intangible durante 1.5 segundos (esquiva garantizada cualquier ataque). Al reintegrarse, explota en un ataque de área que hace ×3.5 daño sobre poder_ki.
- **Cooldown:** 28.0s
- **Requisito:** vitalidad ≥ 400, ki ≥ 200, poder_ki ≥ 150

#### NÚCLEO VITAL *(SUPPORT — Punto de anclaje)*
> Mientras el núcleo del ser permanezca intacto, ningún daño es definitivo.
- **Costo de Ki:** 30%
- **Efecto:** Durante 8 segundos, el jugador no puede morir. Cualquier daño letal se convierte en daño reducido al 10%. Al terminar, se cura el 40% del HP.
- **Cooldown:** 35.0s
- **Requisito:** vitalidad ≥ 400, ki ≥ 200

### Cómo Obtenerlo
| Método | Condición |
|--------|-----------|
| **Progresión automática** | vitalidad ≥ 400 + ki ≥ 200 con Tier 5 activo. |
| **Checkpoint Día 60** | Tier 5 + stats cumplidos + haber ganado al menos 15 combates en el run. |
| **Acción de día:** "Fusión de Ki y Cuerpo" | Disponible día 45+. Requiere ki ≥ 180. Sube poder_ki y vitalidad conjuntamente. |

---

## Tier 7 — Regeneración Alta-Baja

> Regeneración desde una gota de sangre, una sola célula, o tras ser derretido completamente.
> *Referencia: Cell, Lobo, Ban (Nanatsu no Taizai)*

### Pasivas *(acumulativas)*

| Nombre | Efecto |
|--------|--------|
| **Factor Celular** | Regenera 12% HP/s. Inmune a daño de veneno, corrosión y cualquier efecto que dañe "por dentro". |
| **Reserva Celular** | Al llegar a 0 HP, hay un 60% de probabilidad de que el jugador se regenere con 25% HP sin gastar la "Inmortalidad Parcial". |
| **Ki Ilimitado** | La regeneración de Ki pasiva se duplica en combate. |
| **Adaptación Extrema** | Tras recibir el mismo tipo de daño 3 veces, el jugador se vuelve inmune a ese tipo durante el combate actual. |

### Habilidades Activas

#### CÉLULA PERFECTA *(ULTIMATE — Regeneración de combate total)*
> El cuerpo del usuario toca su potencial biológico máximo durante un instante.
- **Costo de Ki:** 60%
- **Efecto:** Recupera 100% del HP. Durante 8 segundos, la regeneración es de 20% HP/s y el daño de salida aumenta ×1.5.
- **Cooldown:** 45.0s
- **Requisito:** vitalidad ≥ 500, poder_ki ≥ 250

#### SANGRE QUE NO MUERE *(SUPPORT — Resiliencia extrema)*
> Incluso reducido a su componente más pequeño, el guerrero persiste.
- **Costo de Ki:** 50%
- **Efecto:** Durante 12 segundos, cualquier fuente de daño que llevaría al jugador a menos de 1 HP en su lugar lo deja a 1 HP. Al terminar, se recupera el 50% del HP.
- **Cooldown:** 40.0s
- **Requisito:** vitalidad ≥ 500, ki ≥ 300

### Cómo Obtenerlo
| Método | Condición |
|--------|-----------|
| **Progresión automática** | vitalidad ≥ 500 + poder_ki ≥ 250 con Tier 6 activo. |
| **Checkpoint Día 65** | Tier 6 + stats cumplidos + haber activado "Reserva Celular" al menos 2 veces en el run actual. |
| **Raza: Androide / Biológico** | Requisito de vitalidad reducido a ≥ 400 para alcanzar Tier 7. |

---

## Tier 8 — Regeneración Alta-Media

> Regeneración desde cenizas, polvo, humo o vapor.
> *Referencia: Majin Buu, Deadpool, Danny Phantom*

### Pasivas *(acumulativas)*

| Nombre | Efecto |
|--------|--------|
| **Cuerpo de Energía** | Regenera 18% HP/s. Los ataques de fuego, explosión y área hacen 50% menos daño. |
| **Humo y Polvo** | La primera vez que el jugador llegaría a 0 HP en cada combate, se dispersa y se reintegra con 30% HP. No cuenta como uso de "Inmortalidad Parcial". |
| **Pureza Vital** | El Ki del jugador no puede ser reducido por habilidades del enemigo. |

### Habilidades Activas

#### DISPERSIÓN Y REINTEGRACIÓN *(ULTIMATE — Esquiva total + Contraataque)*
> El usuario se convierte en vapor y reaparece detrás del enemigo en un instante.
- **Costo de Ki:** 55%
- **Efecto:** El jugador se vuelve intangible durante 2 segundos (esquiva absoluta). Al reintegrarse, golpea al enemigo desde todos los ángulos simultáneamente: 6 hits de ×1.2 daño sobre poder_ki + fuerza.
- **Cooldown:** 30.0s
- **Requisito:** vitalidad ≥ 650, ki ≥ 350

#### BURBUJA VITAL *(SUPPORT — Barrera máxima)*
> El usuario envuelve su esencia en una burbuja de energía pura. Nada puede destruirla.
- **Costo de Ki:** 60%
- **Efecto:** Por 10 segundos, cualquier daño recibido se reduce al 5% de su valor original. Si el efecto termina sin haber sido roto, el HP se recupera hasta el 80%.
- **Cooldown:** 50.0s
- **Requisito:** vitalidad ≥ 650, poder_ki ≥ 300

### Cómo Obtenerlo
| Método | Condición |
|--------|-----------|
| **Progresión automática** | vitalidad ≥ 650 + ki ≥ 350 con Tier 7 activo. |
| **Checkpoint Día 75** | Tier 7 + stats cumplidos + haber ganado el run al menos 1 vez (New Game+). |
| **Flag especial:** "El que No Puede Morir" | Activar "Reserva Celular" o "Humo y Polvo" 10 veces en el mismo run. |

---

## Tier 9 — Regeneración Alta

> Regeneración desde moléculas, átomos o partículas dispersas.
> *Referencia: The Sentry, La Bestia (InFAMOUS), Lucifer (Supernatural)*

### Pasivas *(acumulativas)*

| Nombre | Efecto |
|--------|--------|
| **Ser Molecular** | Regenera 25% HP/s. El daño no puede superar el 40% del HP máximo en un solo golpe. |
| **Existencia Persistente** | "Inmortalidad Parcial" ahora actúa 3 veces por combate. "Humo y Polvo" y "Reserva Celular" también se conservan. |
| **Fusión Total** | El Ki y el HP se comparten: si el Ki llega a 0, el HP alimenta al Ki y viceversa (conversión 2:1). |
| **Presencia Atómica** | El jugador emite un aura que reduce el daño de todos los enemigos cercanos en 15% pasivamente. |

### Habilidades Activas

#### EXTINCIÓN ATÓMICA *(ULTIMATE — El ataque definitivo)*
> El usuario libera la energía de sus propios átomos en una explosión de poder absoluto.
- **Costo de Ki:** 80%
- **Daño:** ×12.0 sobre poder_ki + ×4.0 sobre ki
- **Hit Count:** 1
- **Efecto especial:** Reduce el HP del enemigo al 10% si tenía más del 50% (no mata, pero lo deja crítico). No puede ser esquivado ni mitigado.
- **Cooldown:** 60.0s
- **Requisito:** vitalidad ≥ 800, poder_ki ≥ 400, ki ≥ 400

#### FORMA PURA *(SUPPORT — Estado trascendente)*
> El usuario abandona temporalmente su forma física para convertirse en energía pura.
- **Costo de Ki:** 70%
- **Efecto:** Por 15 segundos: invulnerabilidad total, regeneración de 30% HP/s, todos los ataques son ×2.0. Al terminar, el HP se estabiliza al 60% si estaba por debajo.
- **Cooldown:** 60.0s
- **Requisito:** vitalidad ≥ 800, ki ≥ 400, poder_ki ≥ 400

### Cómo Obtenerlo
| Método | Condición |
|--------|-----------|
| **Progresión automática** | vitalidad ≥ 800 + poder_ki ≥ 400 + ki ≥ 400 con Tier 8 activo. |
| **Solo en New Game+** | No disponible en el primer run. Requiere haber completado el juego al menos 1 vez. |
| **Checkpoint Día 90** | Tier 8 + todos los stats en umbral + haber desbloqueado al menos 5 habilidades activas de Regeneración. |

---

## Tier 10 — Regeneración Divina-Baja

> Regeneración tras la destrucción física completa del cuerpo. El alma, la mente o la conciencia reconstruye al ser.
> *Referencia: Mahito (JJK), Bill Cipher, El Señor de las Sombras (NieR)*

### Pasivas *(acumulativas + NUEVAS exclusivas)*

| Nombre | Efecto |
|--------|--------|
| **Resurrección Automática** | Una vez por run, si el jugador muere definitivamente en combate, regresa con 50% HP al inicio del siguiente combate. Los stats no se pierden. |
| **Alma Indestructible** | Inmune a cualquier efecto que reduzca stats de forma permanente. Los debuffs permanentes no tienen efecto. |
| **Consciencia Sin Cuerpo** | Si "Resurrección Automática" no ha sido usada, el jugador tiene un 30% de HP adicional de forma permanente. |

### Habilidades Activas

#### RENACIMIENTO *(ULTIMATE — Resurrección en combate)*
> Incluso después de caer, el guerrero vuelve. Porque lo que trasciende el cuerpo no puede ser destruido.
- **Costo de Ki:** 0 (se activa automáticamente al morir en combate si no está en cooldown)
- **Efecto:** Al llegar a 0 HP: el jugador revive con 70% HP, todos sus debuffs se eliminan, y entra en un estado de poder ×2.0 durante 10 segundos.
- **Cooldown:** 1 uso por combate (no recarga)
- **Requisito:** Tier 10 activo

#### TRASCENDENCIA *(ULTIMATE — Forma Final)*
> El ser abandona toda limitación física y se manifiesta como una fuerza de la naturaleza.
- **Costo de Ki:** 100% del Ki actual
- **Efecto:** El daño de salida escala con el Ki gastado: por cada 100 Ki gastado, el daño aumenta ×1.0 (máx. ×10.0 con 1000 Ki). El ataque no puede ser bloqueado, esquivado ni resistido.
- **Hit Count:** 3
- **Cooldown:** 1 uso por combate
- **Requisito:** Tier 10 activo, ki ≥ 500

### Cómo Obtenerlo
| Método | Condición |
|--------|-----------|
| **Evento narrativo del Día 80** | Solo disponible si Tier 9 está activo. Desencadena una cadena de eventos en el loop de días. |
| **New Game+ exclusivo** | Solo activable después de completar el juego al menos 2 veces. |
| **NPC: Dios / Entidad Suprema** | Relación máxima (100%) + haber completado su arco narrativo completo. |
| **Flag: "El Guerrero Eterno"** | Haber activado "Resurrección Automática" o "Inmortalidad Parcial" un total de 20 veces a lo largo de todos los runs. |

---

## Tier 11 — Regeneración Divina-Media

> Regeneración incluso tras ser borrado de la existencia. Destrucción del alma, de conceptos, del espacio-tiempo.
> *Referencia: Long Horse, Sonic the Hedgehog, Rimuru Tempest*

### Pasivas *(las definitivas)*

| Nombre | Efecto |
|--------|--------|
| **Más Allá de la Existencia** | La "Resurrección Automática" ahora es ilimitada por run (pero cooldown de 60s entre usos). |
| **Concepto Viviente** | Inmune a cualquier tipo de daño conceptual o instantáneo. Los ataques de muerte instantánea fallan siempre. |
| **Regeneración Cósmica** | Regenera 40% HP/s. El HP máximo se incrementa en +50% permanentemente. |
| **Existencia Permanente** | Al inicio de cada combate, el jugador empieza con todos los buffs activos del combate anterior. |

### Habilidades Activas

#### BORRADO Y RETORNO *(ULTIMATE — El poder más alto)*
> El usuario ha sido eliminado de la realidad antes. Ha vuelto. Siempre vuelve.
- **Costo de Ki:** 0 (pasiva automática de combate)
- **Efecto:** Cada vez que el jugador "moriría", vuelve automáticamente con 60% HP. Sin límite de usos. Cooldown de 60 segundos entre activaciones.
- **Requisito:** Tier 11 activo

#### REESCRITURA *(ULTIMATE — Control total)*
> El usuario reescribe las reglas del combate a su favor.
- **Costo de Ki:** 100%
- **Efecto:** Resetea todos los cooldowns del jugador. Recupera el 100% del HP y del Ki. El enemigo pierde todos sus buffs activos y sus debuffs se duplican.
- **Cooldown:** 1 uso por combate
- **Requisito:** Tier 11 activo

### Cómo Obtenerlo
| Método | Condición |
|--------|-----------|
| **Solo por evento narrativo** | No hay ruta de stats o entrenamiento. Requiere completar el evento "El Fin y el Inicio" del día 95+. |
| **New Game+ exclusivo** | Solo disponible en el 3er run o posterior. |
| **Flag: "El que Regresa Siempre"** | Acumular 50 resurrecciones a lo largo de todos los runs + haber completado el arco del Dios de la Destrucción. |
| **Modo Legado** | Sistema especial de herencia entre runs: si en el run anterior se alcanzó Tier 10, el siguiente run puede desbloquear Tier 11. |

---

## Resumen de Progresión

```
Día 1-10   → Tier 1 (vitalidad ≥ 60)
Día 10-20  → Tier 2 (vitalidad ≥ 100)
Día 20-30  → Tier 3 (vitalidad ≥ 150)
Día 30-40  → Tier 4 (vitalidad ≥ 220)
Día 40-50  → Tier 5 (vitalidad ≥ 300)
Día 50-60  → Tier 6 (vitalidad ≥ 400 + ki ≥ 200)
Día 60-65  → Tier 7 (vitalidad ≥ 500 + poder_ki ≥ 250)
Día 65-75  → Tier 8 (vitalidad ≥ 650 + ki ≥ 350)          [New Game+ recomendado]
Día 75-90  → Tier 9 (vitalidad ≥ 800 + poder_ki + ki ≥ 400) [New Game+ requerido]
Día 80-95  → Tier 10 (evento narrativo + Tier 9)           [New Game+ ×2]
Día 95-100 → Tier 11 (evento final + Tier 10)               [New Game+ ×3]
```

> **Nota de balance:** Los Tiers 1-6 son alcanzables en el primer run dedicando acciones de día a vitalidad, ki y resistencia. Los Tiers 7-9 requieren New Game+ para tener los stats necesarios. Los Tiers 10 y 11 son contenido de endgame narrativo.
