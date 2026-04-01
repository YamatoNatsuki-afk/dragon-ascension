# Goku — Dragon Ball Z: Todas las Sagas
**Predecesor:** `docs/goku_vs_raditz.md`
**Cobertura:** Saga Saiyajin (Arco Vegeta) → Saga Freezer → Saga Androides → Juegos de Cell → Saga Buu (vivo y muerto)

---

## ÍNDICE

| Sección | Tier base | Tier máximo |
|---|---|---|
| 1. Arco Vegeta | 5-C | 5-B con Kaio-ken ×4 |
| 2. Arco Ginyu (Namek) | 5-B | 5-B+ con Kaio-ken ×4 |
| 3. Arco Freezer (Post-Zenkai / SSJ) | 4-C Bajo | 4-C Alto como SSJ |
| 4. Arco Androides | 4-C Bajo | 4-C Alto como SSJ |
| 5. Juegos de Cell | 4-C Alto | 4-C Alto como SSJ Max |
| 6. Saga Buu — Vivo | 4-C Alto | mayor como SSJ3 |
| 7. Saga Buu — Muerto | 4-C Alto | mayor como SSJ3 + Inmortalidad |

---

---

# 1. SAGA SAIYAJIN — ARCO VEGETA

## 1.1 Changelog respecto a Era Raditz

| Cambio | Era Raditz | Arco Vegeta |
|---|---|---|
| Tier | 5-C Bajo | 5-C, 5-B con Kaio-ken |
| Potencia base | Nivel Lunar | Nivel Planeta Pequeño |
| Kaio-ken máximo disponible | ×4 | ×4 (confirmado vs Vegeta) |
| Nueva habilidad | — | Absorción limitada (Genki-Dama) |
| Nueva resistencia | — | Gravedad ×10 (sin problema) |

## 1.2 Stats (Arco Vegeta)

| Stat | Era Raditz | Arco Vegeta |
|---|---|---|
| Fuerza | 140 | 155 |
| Velocidad | 132 | 148 |
| Ki | 125 | 138 |
| Vitalidad | 118 | 130 |
| Resistencia | 140 | 155 |
| Poder Ki | 145 | 162 |
| Intel Combate | 118 | 122 |

## 1.3 Kaio-ken — Tabla de niveles (Arco Vegeta)

| Nivel | Mult. stats | Coste Vitalidad /s | Tier resultante |
|---|---|---|---|
| ×2 | ×2 todo | 5% | 5-B |
| ×3 | ×3 todo | 10% | 5-B (mayor) |
| ×4 | ×4 todo | 18% | 5-B (mayor, Goku supera a Vegeta momentáneamente) |

**Kaio-ken ×4 Kamehameha:** Combinación usada vs Vegeta. El Kaio-ken amplifica Poder Ki ×4 antes de disparar.

```gdscript
ComboSkill {
  nombre   = "Kaio-ken ×4 Kamehameha"
  efectos  = [
    Activar  { skill = &"kaio_ken", nivel = 4, duracion = 3.0 },
    Disparar { skill = &"kamehameha_experto", con_mult = 4.0 }
  ]
  coste_adicional_vitalidad = 18.0   # por segundo durante los 3 s de carga
}
```

## 1.4 Absorción Limitada — Genki-Dama (formalizado)

La Genki-Dama puede absorber Ki de seres vivos del entorno. Se actualiza la SkillData:

```gdscript
# Adición a genki_dama existente:
absorcion_activa = {
  radio_recoleccion      = "área de la escena de combate",
  porcentaje_ki_absorbido = 0.02,   # 2% del Ki máximo de cada ser vivo por segundo
  acelera_carga          = true,    # cada ser que aporta voluntariamente reduce 40% el tiempo
  requiere_pure_heart    = true
}
```

## 1.5 Resistencia a Gravedad ×10

Entrenamiento completado en el planeta de Kaio-sama. Sin penalización de combate en entornos hasta 10G. Mecánica ya detallada en `goku_vs_raditz.md § 6.1`.

---

---

# 2. SAGA FREEZER — ARCO GINYU (NAMEK)

## 2.1 Changelog respecto al Arco Vegeta

| Cambio | Arco Vegeta | Arco Ginyu |
|---|---|---|
| Tier | 5-C / 5-B Kaio-ken | **5-B** base |
| Potencia | Planeta Pequeño | **Planetario** (supera a Ginyu) |
| Fuerza física | Clase M | **Clase G** |
| Nueva habilidad | — | Telekinesis |
| Nueva habilidad | — | Telepatía mejorada (lee mente de Krillin) |
| Nueva habilidad | — | Manipulación Empática |
| Nueva resistencia | — | Gravedad ×100 |
| Nueva resistencia | — | Espacio Tipo 1 (puede sobrevivir en vacío) |
| Kaio-ken máximo | ×4 | ×4 (aún; ×10/×20 llegan con Freezer) |

## 2.2 Stats (Arco Ginyu)

| Stat | Arco Vegeta | Arco Ginyu |
|---|---|---|
| Fuerza | 155 | 185 |
| Velocidad | 148 | 178 |
| Ki | 138 | 168 |
| Vitalidad | 130 | 158 |
| Resistencia | 155 | 185 |
| Poder Ki | 162 | 195 |
| Intel Combate | 122 | 130 |

## 2.3 Telekinesis

```gdscript
SkillData {
  id               = &"telekinesis_goku"
  display_name     = "Telekinesis"
  skill_type       = SkillType.SUPPORT
  description      = "Goku puede mover objetos y personas con el poder de su mente, incluso estando inconsciente."
  ki_cost          = 12.0
  cooldown         = 8.0
  effect_tags      = [&"mental", &"telekinesis"]
  required_stats   = { &"ki": 158.0, &"intel_combate": 125.0 }
  # Efectos:
  # En combate: lanzar al rival (daño = fuerza × 0.8, Knockdown 1.5 s)
  # Detener proyectiles entrantes (costo 5 ki por proyectil bloqueado)
  # Escudo de telekinesis: radio 2 m, desvía ataques físicos al 40%
  # Pasiva especial: puede activarse mientras Goku está inconsciente
  #   → las capacidades telepáticas mantienen el escudo aunque el cuerpo no responda
}
```

## 2.4 Telepatía Mejorada — Lectura de Mente

```gdscript
# Actualización de telepatia_kaio:
# Nueva variante: mano en la frente → lee mente del objetivo completamente
# (no solo el próximo movimiento, sino planes, debilidades conocidas y estado emocional)
Telepathia_LecturaMente {
  requiere_contacto_fisico = true,
  revelaciones             = ["próximo_movimiento", "planes", "debilidades_propias", "estado_emocional"],
  costo_ki                 = 8.0,
  cooldown                 = 0.0    # puede leerse tantas veces como se quiera con contacto
}
```

## 2.5 Manipulación Empática

```gdscript
SkillData {
  id               = &"empatia_goku"
  display_name     = "Proyección Empática"
  skill_type       = SkillType.SUPPORT
  description      = "Goku puede recorrer la mente de los demás y proyectarse en sus corazones, transmitiendo emociones o recuerdos."
  ki_cost          = 18.0
  cooldown         = 20.0
  effect_tags      = [&"mental", &"empathy"]
  required_stats   = { &"ki": 160.0, &"intel_combate": 125.0 }
  # Efectos:
  # Objetivo neutral → puede volverse aliado temporal (si Intel Combate del objetivo < 120)
  # Objetivo hostil → reduce agresividad un 20% durante 6 s
  # Contribución a Genki-Dama: convence a seres vivos de aportar Ki conscientemente (+60% velocidad de carga)
}
```

## 2.6 Resistencia al Espacio Tipo 1

A diferencia del perfil anterior (debilidad al vacío espacial), en el Arco Ginyu Goku demuestra poder sobrevivir en el espacio.

```gdscript
ResistenciaEspacio {
  tipo = 1,   # Supervivencia sin atmósfera
  # Puede combatir en el vacío sin perder Vitalidad
  # No necesita respirar durante el combate
  # Aún es vulnerable a temperatura extrema del espacio si el combate se prolonga > 5 min
}
```

---

---

# 3. SAGA FREEZER — ARCO FREEZER (POST-ZENKAI + SSJ)

## 3.1 El mayor salto de poder individual de toda la progresión de Goku

| Cambio | Arco Ginyu | Arco Freezer |
|---|---|---|
| Tier base | 5-B | **4-C Bajo** (Post-Zenkai) |
| Tier con Kaio-ken ×20 | 5-B+ | **4-C** (daña a Freezer 50%) |
| Tier como SSJ | — | **4-C Alto** (supera a Freezer 100%) |
| Nueva transformación | — | **Super Saiyajin (SSJ)** |
| Nueva habilidad | — | Poder de la Furia (trigger de SSJ) |
| Nueva habilidad | — | Manipulación del Clima limitada |
| Kaio-ken máximo | ×4 | ×20 (dominado en esta saga) |

## 3.2 Stats (Post-Zenkai, base para Freezer)

| Stat | Arco Ginyu | Post-Zenkai |
|---|---|---|
| Fuerza | 185 | 240 |
| Velocidad | 178 | 230 |
| Ki | 168 | 218 |
| Vitalidad | 158 | 205 |
| Resistencia | 185 | 240 |
| Poder Ki | 195 | 252 |
| Intel Combate | 130 | 135 |

> El Zenkai es el mayor salto de stats de Goku hasta este punto — el casi-KO por Ginyu y la recuperación en la bacta multiplican el poder varias veces.

## 3.3 Kaio-ken ×20 — Dominio completo

```gdscript
# Actualización del sistema Kaio-ken:
Kaio_ken_20 {
  multiplicador     = 20,
  coste_vitalidad_s = 80.0,   # 80% /s — insostenible más de 1-2 s
  tier_resultante   = "4-C (Estelar+)",
  nota              = "Solo usado vs Freezer al 50%. Goku mismo dice que es su límite absoluto."
}
```

## 3.4 ★ Sistema Super Saiyajin (SSJ)

### 3.4.1 Trigger de primera transformación — Poder de la Furia

```gdscript
TriggerTransformacion {
  nombre          = "Primer SSJ — Furia por Krillin",
  condicion_base  = "HP_aliado_clave cae a 0 en presencia de Goku",
  condicion_alt   = "Goku acumula 5 stacks de 'Emoción del Combate' + el rival KO a un aliado",
  efecto          = "Transformación automática a SSJ — sin costo de Ki inicial",
  nota            = "Solo funciona una vez. Después, SSJ se activa voluntariamente."
}
```

### 3.4.2 Super Saiyajin — Estadísticas de transformación

```gdscript
TransformacionData {
  id               = &"ssj"
  display_name     = "Super Saiyajin"
  descripcion      = "La legendaria transformación Saiyajin. Ki ×50. Aura dorada. Mayor agresividad."

  multiplicadores  = {
    fuerza     : 50.0,
    velocidad  : 50.0,
    ki         : 50.0,
    poder_ki   : 50.0,
    resistencia: 50.0
  }

  costo_ki_s       = 8.0     # Ki por segundo — ineficiente hasta dominar el SSJ
  costo_ki_s_dominado = 0.0  # Una vez dominado (SSJ Full Power), sin drenaje
  dominio_req      = "Pasar 24 horas en la Cámara del Tiempo en SSJ continuo"

  efectos_secundarios = [
    "Agresividad +30% (modificador de comportamiento — Goku lo neutraliza con entrenamiento)",
    "Intel Combate −5 (adrenalina reduce sutilmente la lectura fina del combate)",
    "Precognición −10% efectividad (emociones elevan el ruido de Ki)"
  ]

  incompatible_con = [&"kaio_ken"]   # no se puede combinar en DBZ
  trigger_emocional = true           # primera activación requiere trauma emocional intenso
  efecto_visual    = "aura_dorada, cabello_dorado_erizado, ojos_azul_verdoso"

  manipulacion_clima = {
    descripcion = "La transformación genera una tormenta electromagnética local.",
    duracion    = 5.0,   # segundos del evento climático al transformarse
    efecto_mecanico = "Ceguera a enemigos en radio 10 m durante 1.5 s al transformarse"
  }
}
```

### 3.4.3 SSJ Full Power (versión dominada — Cámara del Tiempo)

```gdscript
TransformacionData {
  id               = &"ssj_full_power"
  display_name     = "Super Saiyajin al Máximo Poder"
  descripcion      = "SSJ completamente dominado. Sin drenaje de Ki. Sin penalización de agresividad."

  multiplicadores  = {
    fuerza     : 50.0,   # mismo poder que SSJ base
    velocidad  : 50.0,
    ki         : 50.0,
    poder_ki   : 50.0,
    resistencia: 50.0
  }

  costo_ki_s       = 0.0    # sin drenaje — puede mantenerse indefinidamente
  efectos_secundarios = []  # agresividad neutralizada, precognición sin penalización

  requisito_desbloqueo = "24h de entrenamiento en SSJ continuo (evento: Cámara del Tiempo)"
  nota = "Esta forma es técnicamente más eficiente que SSJ2 en combates largos."
}
```

---

---

# 4. SAGA ANDROIDES/CELL — ARCO ANDROIDES

## 4.1 Changelog respecto al Arco Freezer

| Cambio | Arco Freezer | Arco Androides |
|---|---|---|
| Tier | 4-C Bajo / 4-C Alto SSJ | 4-C Bajo / 4-C Alto SSJ |
| Velocidad | Hipersónico+ | **Masivamente Hipersónico+** |
| Nueva habilidad | — | Shunkan Ido disponible (★★ activo) |
| Nueva habilidad | — | Control Corporal (masa muscular) |
| Nueva habilidad | — | BFR (Shunkan Ido como deportación) |
| Alcance | Planetario con Ki | Planetario Ki + **Universal Shunkan Ido** |

## 4.2 Stats (Arco Androides)

| Stat | Post-Zenkai Freezer | Arco Androides |
|---|---|---|
| Fuerza | 240 | 265 |
| Velocidad | 230 | 260 |
| Ki | 218 | 242 |
| Vitalidad | 205 | 228 |
| Resistencia | 240 | 265 |
| Poder Ki | 252 | 278 |
| Intel Combate | 135 | 140 |

## 4.3 Control Corporal — Masa Muscular

```gdscript
SkillData {
  id               = &"control_muscular"
  display_name     = "Control Muscular"
  skill_type       = SkillType.SUPPORT
  description      = "Goku puede aumentar voluntariamente su masa muscular, incrementando Fuerza a costa de Velocidad."
  ki_cost          = 10.0
  cooldown         = 15.0
  effect_tags      = [&"body_control", &"muscle"]
  required_stats   = { &"intel_combate": 138.0 }
  # Modo activado (masa aumentada):
  # +25% Fuerza, −15% Velocidad, +10% Resistencia al daño físico
  # Duración: indefinida mientras se sostenga activo
  # Nota: La versión máxima (Ultra Super Saiyajin) es una forma separada
  #   que sacrifica demasiada velocidad — Goku la descarta conscientemente.
}
```

## 4.4 BFR — Shunkan Ido como deportación

```gdscript
# Extensión del Shunkan Ido documentado en goku_vs_raditz.md:
Shunkan_Ido_BFR {
  descripcion     = "Goku puede tomar contacto físico con el rival y Shunkan Ido-ar a un planeta lejano, dejándolo allí.",
  condicion       = "Toque físico con el objetivo",
  destino         = "Cualquier señal de Ki conocida por Goku (puede ser un planeta vacío)",
  efecto_combate  = "Si tiene éxito: victoria por BFR (objetivo no regresa en 5 s = victoria)",
  contramedida    = "Objetivo puede resistir el contacto físico (Fuerza ≥ Goku) o interrumpir la concentración (daño durante los 0.5 s de carga)"
}
```

---

---

# 5. JUEGOS DE CELL

## 5.1 Changelog respecto al Arco Androides

| Cambio | Arco Androides | Juegos de Cell |
|---|---|---|
| Tier | 4-C Bajo | **4-C Alto** |
| SSJ | 4-C Alto | 4-C Alto + SSJ Full Power |
| Nueva habilidad | — | Proyección Astral |
| Velocidad | M. Hipersónico+ | **Al menos Relativista** |

## 5.2 Stats (Juegos de Cell — base, post-Cámara del Tiempo)

| Stat | Arco Androides | Juegos de Cell |
|---|---|---|
| Fuerza | 265 | 310 |
| Velocidad | 260 | 305 |
| Ki | 242 | 285 |
| Vitalidad | 228 | 268 |
| Resistencia | 265 | 310 |
| Poder Ki | 278 | 328 |
| Intel Combate | 140 | 148 |

## 5.3 SSJ Full Power — Activo desde aquí

La Cámara del Tiempo eliminó el drenaje del SSJ. Ver sección 3.4.3. Desde los Juegos de Cell, `ssj_full_power` reemplaza a `ssj` como la transformación estándar de Goku.

## 5.4 Proyección Astral

```gdscript
SkillData {
  id               = &"proyeccion_astral"
  display_name     = "Proyección Astral"
  skill_type       = SkillType.SUPPORT
  description      = "Tras morir, Goku puede aparecer como un espíritu para guiar a aliados. En vida, puede proyectar su conciencia brevemente."
  ki_cost          = 35.0
  cooldown         = 120.0
  effect_tags      = [&"spirit", &"astral", &"mental"]
  required_stats   = { &"ki": 278.0 }
  # En vida: Goku proyecta su imagen a distancia para comunicarse con aliados
  #   → efecto de Telepatía visual, alcance ilimitado
  #   → duración: 30 s
  # Post-muerte (estado espiritual): Goku puede comunicarse con Gohan
  #   → puede prestar Ki al aliado: transferencia = ki_actual × 0.3
  #   → no puede combatir directamente
  nota = "Primer uso: guía a Gohan para derrotar a Cell. Es la forma de apoyo más poderosa de Goku."
}
```

---

---

# 6. SAGA BUU — GOKU VIVO

## 6.1 Changelog respecto a Juegos de Cell

| Cambio | Juegos de Cell | Saga Buu (vivo) |
|---|---|---|
| Tier base | 4-C Alto | 4-C Alto (superior) |
| Tier SSJ | 4-C Alto (Full Power) | **4-B** como SSJ |
| Tier SSJ2 | — | mayor que SSJ |
| Tier SSJ3 | — | mayor que SSJ2 |
| Potencia SSJ | Estrella Grande | **Sistema Solar** |
| Nueva habilidad | — | Manipulación Eléctrica (SSJ2) |
| Nueva habilidad | — | Creación de Terremotos |
| Nueva habilidad | — | Influencia Social (Genki-Dama universal) |
| Nueva habilidad | — | Fusionismo (Fusión + Potara) |
| Nueva habilidad | — | Creación de Portales / Viaje Dimensional (escalado Buu) |
| Nueva habilidad | — | Longevidad (1000 años de vida extra del Supremo Kaio) |
| Alcance | Planetario Ki | **Interplanetario** Ki (cubre Sistema Solar) |

## 6.2 Stats (Saga Buu — base)

| Stat | Juegos de Cell | Saga Buu (vivo) |
|---|---|---|
| Fuerza | 310 | 350 |
| Velocidad | 305 | 345 |
| Ki | 285 | 322 |
| Vitalidad | 268 | 305 |
| Resistencia | 310 | 350 |
| Poder Ki | 328 | 370 |
| Intel Combate | 148 | 158 |

## 6.3 Super Saiyajin 2 (SSJ2)

```gdscript
TransformacionData {
  id               = &"ssj2"
  display_name     = "Super Saiyajin 2"
  descripcion      = "Goku desbloquea SSJ2 para igualarse a Gohan de la saga Cell. Genera descargas eléctricas al activarse."

  multiplicadores  = {
    fuerza     : 100.0,
    velocidad  : 100.0,
    ki         : 100.0,
    poder_ki   : 100.0,
    resistencia: 100.0
  }

  costo_ki_s       = 15.0    # más caro que SSJ pero sostenible
  efectos_secundarios = [
    "Agresividad +20% (menor que SSJ base por mayor control de Goku)"
  ]

  efecto_visual    = "aura_dorada_más_intensa, descargas_electricas_azules, cabello_más_erizado"

  manipulacion_electrica = {
    descripcion = "SSJ2 genera descargas eléctricas al activarse y durante combate intenso.",
    al_transformarse = {
      daño_aoe    = poder_ki * 0.5,
      radio       = 4.0,
      efecto      = "Stagger 0.8 s a enemigos cercanos"
    },
    en_combate   = {
      chance_descarga_por_golpe = 0.15,
      daño_extra   = poder_ki * 0.2,
      effect_tags  = [&"electric"]
    }
  }
}
```

## 6.4 Super Saiyajin 3 (SSJ3)

```gdscript
TransformacionData {
  id               = &"ssj3"
  display_name     = "Super Saiyajin 3"
  descripcion      = "La forma más extrema disponible de Goku en DBZ. Poder masivo con costo insostenible. Solo puede mantenerse minutos."

  multiplicadores  = {
    fuerza     : 400.0,
    velocidad  : 400.0,
    ki         : 400.0,
    poder_ki   : 400.0,
    resistencia: 400.0
  }

  costo_ki_s       = 60.0    # drena el Ki muy rápidamente
  duracion_maxima  = 180.0   # 3 minutos máximos antes de colapso por agotamiento
  post_deactivacion = {
    penalizacion_stats = 0.50,   # −50% a todos los stats tras desactivar
    duracion_penalizacion = 120.0
  }

  efecto_visual    = "aura_dorada_enorme, cabello_dorado_muy_largo, sin_cejas, terremoto_al_transformar"

  creacion_terremotos = {
    descripcion = "Al transformarse, la liberación de energía agita el planeta.",
    al_transformarse = {
      duracion = 3.0,
      radio_efecto = "toda_la_arena",
      efecto       = "Knockdown a todos los enemigos en escena (1.5 s)"
    }
  }

  # Limitación temporal: siendo muerto en Otro Mundo, Goku tiene permiso limitado.
  # De vivo: puede usar SSJ3 pero se agota más rápido (120 s máx).
  # De muerto: sin límite de tiempo.
}
```

## 6.5 Fusionismo

```gdscript
SkillData {
  id               = &"fusion"
  display_name     = "Fusión"
  skill_type       = SkillType.ULTIMATE
  description      = "Técnica de Metamoru. Dos guerreros de Ki similar realizan una danza sincronizada para fusionarse en un ser combinado por 30 minutos."
  ki_cost          = 0.0
  cooldown         = 1800.0   # 30 minutos (duración de la fusión + espera)
  effect_tags      = [&"fusion", &"metamoru"]
  required_stats   = {}

  mecanica = {
    requiere_aliado             = true,
    ki_similar_del_aliado       = "±10% del Ki de Goku",
    duracion_fusion             = 1800.0,    # 30 minutos
    poder_resultante            = "(stats_goku + stats_aliado) × 1.4",
    falla_si_mal_sincronizado   = true       # la danza debe ser perfecta
  }
}
```

```gdscript
SkillData {
  id               = &"potara"
  display_name     = "Fusión Potara"
  skill_type       = SkillType.ULTIMATE
  description      = "Fusión mediante los aretes Potara. Más sencilla que la danza Metamoru y produce un guerrero más poderoso. Supuestamente permanente para mortales."
  ki_cost          = 0.0
  cooldown         = 0.0      # permanente (hasta que Buu lo absorba, en contexto narrativo)
  effect_tags      = [&"fusion", &"potara"]
  required_stats   = {}

  mecanica = {
    requiere_arete_potara   = true,
    poder_resultante        = "(stats_goku + stats_aliado) × 2.0",
    permanente_en_mortales  = true,
    nota                    = "En la Saga Buu resulta reversible porque Buu absorbe a Vegito — excepción narrativa."
  }
}
```

## 6.6 Influencia Social — Genki-Dama Universal

```gdscript
# Extensión de genki_dama:
Genki_Dama_Universal {
  descripcion     = "Goku puede apelar telepáticamente a todos los seres vivos del universo para que aporten Ki.",
  alcance         = "Universal",
  aceleracion     = 0.85,   # 85% de reducción del tiempo de carga con aportación masiva
  requiere        = "Goku en estado de vida o espiritual con señal de Ki activa",
  nota            = "Usado vs Kid Buu. La Genki-Dama resultante tiene potencia de Sistema Solar."
}
```

## 6.7 Longevidad

```gdscript
LongevidadData {
  descripcion = "Al fusionarse con el Supremo Kaio-sama (accidentalmente), Goku hereda su esperanza de vida restante.",
  años_adicionales = 1000,
  efecto_mecanico  = {
    "Fatiga de Run" : "El umbral de Fatiga de Run se extiende al Day 95 (era Day 85 con Longevidad base)",
    "Permanece en pico de poder" : "Sin penalización por envejecimiento en runs de hasta 100 días"
  }
}
```

---

---

# 7. SAGA BUU — GOKU MUERTO

## 7.1 Habilidades adicionales del estado espiritual

Durante la primera parte de la Saga Buu, Goku permanece muerto. Esto le otorga capacidades específicas del estado espiritual de Dragon Ball.

### 7.1.1 Inmortalidad Tipos 1 y 6

```gdscript
InmortalidadData {
  tipo_1 = {
    descripcion = "Estado espiritual: no puede ser matado de nuevo (ya está muerto).",
    efecto      = "Inmune a efectos de KO permanente mientras esté en forma espiritual.",
    nota        = "Al regresar a la vida, la Inmortalidad Tipo 1 desaparece."
  },
  tipo_6 = {
    descripcion = "Espíritu sin cuerpo físico: no puede ser dañado por ataques físicos.",
    efecto      = "Ataques físicos (STRIKE, proyectiles físicos) pasan a través de Goku en forma espiritual.",
    vulnerabilidades = ["ataques de Ki puro", "técnicas de manipulación del alma", "Interacción No-Física"]
  }
}
```

### 7.1.2 Auto-Sustento Tipos 1, 2 y 3

```gdscript
AutoSustentoData {
  tipo_1 = "No necesita comer. (En el juego: no consume recursos de hambre/energía en el meta-juego de día.)",
  tipo_2 = "No necesita dormir. (En el juego: no consume recursos de descanso; puede entrenar 24h sin penalización.)",
  tipo_3 = "No necesita respirar. (En el juego: puede combatir en entornos sin oxígeno sin limite de tiempo.)",
  nota   = "Goku conserva estos hábitos por placer propio, no por necesidad."
}
```

### 7.1.3 Interacción No-Física y Manipulación del Alma

```gdscript
SkillData {
  id               = &"interaccion_espiritual"
  display_name     = "Interacción Espiritual"
  skill_type       = SkillType.SUPPORT
  description      = "En forma espiritual, Goku puede interactuar con otros espíritus y manipular almas de similar naturaleza."
  ki_cost          = 0.0
  cooldown         = 0.0
  effect_tags      = [&"spirit", &"soul", &"non_physical"]
  # Puede tocar y afectar a otros espíritus
  # Puede transferir Ki a aliados vivos mediante contacto espiritual
  # Puede percibir y rastrear almas en el Otro Mundo
  nota = "Solo activo mientras Goku está en estado de muerte. Desaparece al revivir."
}
```

## 7.2 SSJ3 sin límite temporal (estado muerto)

Siendo un espíritu en el Otro Mundo, Goku puede usar SSJ3 indefinidamente (sin el agotamiento de los 3 minutos que tiene de vivo).

```gdscript
SSJ3_Muerto {
  duracion_maxima  = 0.0,      # sin límite
  costo_ki_s       = 60.0,     # mismo drenaje pero el cuerpo espiritual lo soporta
  post_deactivacion = {}        # sin penalización post-uso en estado espiritual
}
```

## 7.3 Creación de Portales / Viaje Dimensional (escalado Buu)

```gdscript
SkillData {
  id               = &"portal_dimensional"
  display_name     = "Portal Dimensional"
  skill_type       = SkillType.SUPPORT
  description      = "Escalando el poder de Buu Súper, Goku puede crear portales a otras dimensiones."
  ki_cost          = 50.0
  cooldown         = 45.0
  effect_tags      = [&"portal", &"dimensional"]
  required_stats   = { &"ki": 318.0 }
  # Efectos:
  # Crear portal de entrada/salida dentro de la arena
  # Proyectiles que entran por la entrada salen por la salida (redirect)
  # BFR dimensional: enviar al rival a una dimensión alternativa (alternativa al BFR de Shunkan Ido)
  nota = "Goku accede a esta habilidad por haber absorbido los conocimientos de seres que la poseen, no por haberla entrenado directamente."
}
```

---

---

# 8. TABLA RESUMEN — TODOS LOS TIERS DE GOKU EN DBZ

| Saga / Arco | Tier Base | Tier Máximo | Forma Máxima |
|---|---|---|---|
| Arco Raditz | 5-C Bajo | 5-C Bajo | Base |
| Arco Vegeta | 5-C | 5-B | Kaio-ken ×4 |
| Arco Ginyu | 5-B | 5-B+ | Kaio-ken ×4 |
| Arco Freezer (Post-Zenkai) | 4-C Bajo | **4-C Alto** | SSJ (debut) |
| Arco Androides | 4-C Bajo | 4-C Alto | SSJ |
| Juegos de Cell | 4-C Alto | 4-C Alto (mayor) | SSJ Full Power |
| Saga Buu (vivo) | 4-C Alto | mayor que SSJ3 | SSJ3 |
| Saga Buu (muerto) | 4-C Alto | mayor que SSJ3 | SSJ3 sin límite |

---

# 9. SISTEMA DE TRANSFORMACIONES — ÁRBOL COMPLETO

```
Base
 └── Kaio-ken ×2/×3/×4 (Saiyajin/Namek)
      └── Kaio-ken ×10/×20 (Freezer)
 └── SSJ (debut Freezer)
      └── SSJ Full Power (Cámara del Tiempo — sin drenaje)
           └── SSJ2 (Saga Buu)
                └── SSJ3 (Saga Buu — 3 min vivo / sin límite muerto)
 └── Fusión (Metamoru — aliado requerido)
 └── Potara (aretes — aliado requerido)
```

**Restricciones de combinación:**

| Forma A | Forma B | Combinable |
|---|---|---|
| Kaio-ken | SSJ | **NO** (DBZ) |
| Kaio-ken | SSJ | **SÍ** (Super — SSJ Blue; documentar en saga correspondiente) |
| SSJ | SSJ2 | SSJ2 reemplaza a SSJ |
| SSJ2 | SSJ3 | SSJ3 reemplaza a SSJ2 |
| Fusión | SSJ/SSJ2/SSJ3 | **SÍ** — el ser fusionado hereda capacidades de ambos |

---

# 10. ADQUISICIÓN — ÁRBOL DE HISTORIA

| Habilidad | Evento | Saga |
|---|---|---|
| Kaio-ken ×2/×3/×4 | Entrenamiento con Kaio post-Raditz | Saga Saiyajin |
| Genki-Dama | Igual | Saga Saiyajin |
| Telekinesis | Entrenamiento con Kaio / Namek | Saga Freezer (Ginyu) |
| Resistencia Gravedad ×100 | Entrenamiento camino a Namek | Saga Freezer (Ginyu) |
| Resistencia Espacio Tipo 1 | Combate en Namek | Saga Freezer (Ginyu) |
| Kaio-ken ×10/×20 | Dominio en Namek | Saga Freezer |
| SSJ (debut) | Evento "Muerte de Krillin" | Saga Freezer |
| Shunkan Ido | Regreso de Yardrat | Post-Freezer |
| SSJ Full Power | Cámara del Tiempo (24h en SSJ) | Saga Cell |
| Proyección Astral | Muerte y regreso en Saga Cell | Saga Cell |
| Control Muscular | Cámara del Tiempo | Saga Cell |
| SSJ2 | Entrenamiento post-Boo / revelado en Saga Buu | Saga Buu |
| SSJ3 | Entrenamiento en Otro Mundo | Saga Buu (muerto) |
| Fusión (Metamoru) | Evento narrativo con Vegeta | Saga Buu |
| Potara | Evento narrativo con Vegeta | Saga Buu |
| Genki-Dama Universal | Saga Buu (Kid Buu) | Saga Buu |
| Inmortalidad T1/T6 | Estado muerto | Saga Buu (muerto) |
| Auto-Sustento T1/T2/T3 | Estado muerto | Saga Buu (muerto) |
| Longevidad (1000 años) | Fusión accidental con Supremo Kaio | Saga Buu |

---

# 11. NOTAS DE DISEÑO

- **SSJ es el punto de inflexión del juego.** El ×50 en todos los stats hace que los enemigos pre-SSJ se vuelvan triviales de repente. El sistema debe compensar con enemigos que escalan agresivamente desde la Saga Freezer en adelante, y con el costo de drenaje de Ki como limitador real.
- **SSJ Full Power** es la respuesta correcta al problema del drenaje — no hacerse más fuerte, sino dominar lo que ya tienes. Esto debe transmitirse al jugador como una lección de diseño: a veces la eficiencia supera al poder bruto.
- **SSJ3 es un arma de un solo uso por combate** de facto: 3 minutos de vivo, penalización del −50% post-uso. El jugador debe guardarlo para el momento crítico. Mecánica de high-risk/high-reward perfecta para un jefe final de saga.
- **El Fusionismo** introduce un sistema de personaje combinado que necesita su propio árbol de habilidades. Vegito y Gogeta deben tener documentación separada cuando llegue la implementación.
- **Las habilidades del estado muerto** son exclusivas de la primera parte de la Saga Buu. Al revivir, Inmortalidad T1/T6 y Auto-Sustento desaparecen. El juego debe manejar este estado como un "modo espíritu" distinto con su propio HUD.
- **Kaio-ken ×20 + SSJ** es la combinación imposible de DBZ que se vuelve posible en Super (SSJ Blue). Dejar ese diseño preparado en el código (flag `incompatible_con_ssj_dbz = true` en lugar de una restricción hardcodeada) permite habilitarlo en sagas futuras sin refactorizar.
