# Goku — 21.° Torneo Mundial de Artes Marciales (Dragon Ball Clásico)
**Tier de referencia:** 8-C Alto base · 8-B como Oozaru
**Raza:** Saiyajin (cola presente)
**Predecesor:** `docs/goku_saga_pilaf.md` — este documento solo registra **deltas y adiciones**.

---

## 0. Changelog respecto a Saga Pilaf

| Cambio | Pilaf | 21.° Torneo |
|---|---|---|
| Tier base | 8-C | 8-C Alto |
| Tier Oozaru | 8-C Alto | 8-B |
| Potencia de ataque | Nivel Edificio | Nivel Edificio Grande |
| Velocidad | Supersónico | Hipersónico |
| Fuerza física | Clase 25 | Clase K |
| Resistencia | Nivel Edificio | Nivel Edificio Grande |
| Oozaru (PA) | City Block (base) | City Block (49 t confirmadas) |
| Nueva habilidad | — | Creación de Imágenes Residuales |
| Nueva resistencia | — | Fuego y Calor |

> Las habilidades no listadas aquí (Jan Ken, Kamehameha, Kiai, Taiyoken, Dragonthrow, Hasshuken, Kyō-ken, Nube Voladora, pasivas de raza) permanecen igual con valores de stat escalados.

---

## 1. Stats Actualizados

| Stat | Pilaf (Day 1) | 21.° Torneo (referencia) | Notas |
|---|---|---|---|
| Fuerza | 38 | 55 | Clase K confirmada (mover roca enorme) |
| Velocidad | 32 | 50 | Hipersónico; superior a Ñam |
| Ki | 22 | 35 | Mayor dominio tras entrenamiento con Roshi |
| Vitalidad | 35 | 48 | Durabilidad extrema documentada |
| Resistencia | 30 | 44 | Nivel Edificio Grande |
| Poder Ki | 20 | 34 | Kamehameha de mayor potencia |
| Inteligencia | 28 | 32 | Igual genio de combate |
| Intel Combate | 40 | 50 | Aprendió de Roshi, Korin y Kami |

> Estos valores representan el umbral de progresión en el meta-juego de días para alcanzar la versión del 21.° Torneo.

---

## 2. Nueva Habilidad — Creación de Imágenes Residuales

### 2.1 Pasiva: Velocidad de Imagen

**Requisito de desbloqueo:** Velocidad ≥ 46
**Descripción lore:** Goku se mueve con suficiente velocidad para dejar copias fantasmales de sí mismo en el aire, confundiendo al enemigo sobre su posición real.

**Efectos pasivos activos cuando Velocidad ≥ 46:**
- Cada vez que Goku esquiva un ataque, hay un 15% de probabilidad de que el atacante quede en estado "Confusión de Objetivo" durante 0.8 s (su próximo ataque apunta a la imagen, no a Goku).
- La probabilidad sube al 25% si el diferencial de Velocidad entre Goku y el enemigo es ≥ 10 puntos.

---

### 2.2 Activa: Imagen Residual

```gdscript
SkillData {
  nombre       = "Imagen Residual"
  tipo         = SkillType.SUPPORT
  descripcion  = "Goku se mueve tan rápido que deja una copia ilusoria estática en su posición anterior. El enemigo puede atacar la imagen en lugar de a Goku."
  requisitos   = { velocidad: 46, intel_combate: 40 }
  costo_ki     = 14
  cooldown     = 8.0
  duracion_imagen = 2.5  # segundos antes de que la imagen se disipe
  efectos = [
    Decoy {
      hp_decoy            = 1,          # la imagen no tiene resistencia real
      atrae_siguiente_ataque = true,    # el primer ataque enemigo va a la imagen
      probabilidad_engaño  = 0.80       # enemigos con Intel Combate ≥ 55 tienen 50% de ignorarla
    },
    Reposicionamiento {
      goku_se_mueve_libremente_durante = 2.5
    }
  ]
  notas = "Enemigos con Percepción Extrasensorial activa o Acción Instintiva son inmunes al engaño."
}
```

---

### 2.3 Activa Avanzada: Ráfaga de Imágenes

```gdscript
SkillData {
  nombre       = "Ráfaga de Imágenes"
  tipo         = SkillType.SUPPORT
  descripcion  = "Goku genera múltiples imágenes residuales simultáneas moviéndose en distintas direcciones, saturando la percepción del enemigo."
  requisitos   = { velocidad: 55, intel_combate: 48 }
  costo_ki     = 22
  cooldown     = 16.0
  duracion_imagen = 3.0
  efectos = [
    Decoy {
      cantidad_imagenes   = 4,
      atrae_ataques_enemigos = 3,       # los primeros 3 ataques golpean imágenes
      probabilidad_engaño  = 0.70       # más imágenes = más fácil de leer para enemigos listos
    },
    Bonus_Contraataque {
      si_enemigo_ataca_imagen = true,
      bonus_daño_goku         = 1.35,
      ventana                 = 2.0
    }
  ]
  notas = "Comba bien con Taiyoken: cegar + imágenes = el enemigo no puede distinguir ni por vista ni por Ki básico."
}
```

---

## 3. Nueva Resistencia — Fuego y Calor

**Base lore:** En la Saga de la Patrulla Roja, Goku no sufrió mucho daño al ser quemado.

**Efectos en juego:**

| Tipo de ataque | Reducción |
|---|---|
| Fuego (Manipulación del Fuego, tag `FIRE`) | −60% daño recibido |
| Calor (Manipulación del Calor, tag `HEAT`) | −40% daño recibido |
| Quemadura persistente (DoT de fuego) | Duración reducida a la mitad |

**Sinergia con Blindaje Saiyajin:** la resistencia física pasiva (−8%) y la resistencia al fuego son independientes y se aplican multiplicativamente.

---

## 4. Escalado de Habilidades Existentes

Las habilidades de la Saga Pilaf no cambian en mecánica pero escalan con los nuevos stats. A continuación los cambios numéricos relevantes.

### 4.1 Kamehameha (actualizado)

```gdscript
# Delta respecto a goku_saga_pilaf.md
SkillData {
  # Sin cambios en mecánica base
  costo_ki  = 28          # igual
  cooldown  = 6.0         # igual
  efectos = [
    Daño { base = poder_ki * 2.8 }   # con Poder Ki 34 → daño efectivo = 95.2 (vs 56 en Pilaf)
  ]
  variantes_desbloqueadas_en_este_tier = [
    "Kamehameha Aéreo",       # ya desbloqueada si Intel Combate ≥ 45 ✓
    "Kamehameha Curvado",     # ya desbloqueada ✓
    "Kamehameha desde Impulso"
  ]
}
```

### 4.2 Hasshuken (actualizado)

```gdscript
# Con Velocidad 50: los 8 golpes son más difíciles de interrumpir
# Nuevo efecto a Velocidad ≥ 48:
Hasshuken_Avanzado {
  hits           = 8,
  daño_por_hit   = fuerza * 0.55,    # +0.05 respecto a Pilaf
  Reflect_Melee  { probabilidad = 0.50 }  # +0.10 respecto a Pilaf
}
```

### 4.3 Potenciación de Ki (amplificación actualizada)

```gdscript
# Con Ki 35, los multiplicadores suben ligeramente:
StatBuff { stat = "fuerza",    multiplicador = 1.30 }   # era 1.25
StatBuff { stat = "velocidad", multiplicador = 1.25 }   # era 1.20
StatBuff { stat = "poder_ki",  multiplicador = 1.20 }   # era 1.15
```

---

## 5. Oozaru — Escalado a 8-B

### 5.1 Stats como Oozaru (21.° Torneo)

| Stat | Multiplicador | Valor efectivo |
|---|---|---|
| Fuerza | × 10 | 550 (Clase M confirmada; 49 toneladas) |
| Velocidad | × 5 | 250 (Hipersónico+) |
| Vitalidad | × 8 | 384 |
| Resistencia | × 6 | 264 (City Block) |
| Inteligencia | → 2 | Berserk |
| Intel Combate | → 5 | Pierde artes marciales finas |

### 5.2 Aliento de Energía (escalado)

```gdscript
SkillData {
  nombre  = "Aliento de Energía — 8-B"
  efectos = [
    Daño { base = poder_ki * 5.5, tipo = "ki_bruto", area_de_efecto = true, radio = 3.5 }
    # Era 4.5 en Pilaf; ahora 5.5 por el mayor control de Ki adquirido
  ]
}
```

---

## 6. Adquisición de Nuevas Habilidades

| Habilidad | Método |
|---|---|
| Imagen Residual | Entrenamiento con Korin (velocidad extrema); requiere Velocidad ≥ 46 + evento "Entrenamiento en la Torre de Korin" |
| Ráfaga de Imágenes | Versión avanzada; requiere Velocidad ≥ 55 + usar Imagen Residual ≥ 10 veces en combate |
| Resistencia al Fuego | Pasiva desbloqueada automáticamente al superar el evento "Saga Patrulla Roja" |

---

## 7. Sinergias Nuevas

| Habilidad A | Habilidad B | Sinergia |
|---|---|---|
| Imagen Residual | Taiyoken | Combo perfecto: Taiyoken ciega → Imagen Residual desvía el contraataque ciego |
| Ráfaga de Imágenes | Hasshuken | El enemigo ataca una imagen → Goku ejecuta Hasshuken en el frame de confusión (×8 golpes garantizados) |
| Imagen Residual | Kamehameha Curvado | Goku deja imagen → se desplaza → lanza Kamehameha curvado desde ángulo inesperado |
| Resistencia al Fuego | Desarrollo Acelerado | Goku puede aguantar ataques de fuego que normalmente forzarían la retirada, acumulando más stacks de Tipo 1 |

---

## 8. Notas de Diseño

- Esta versión representa el primer gran salto de poder del jugador si usa a Goku como personaje principal: los stats base del 21.° Torneo son alcanzables alrededor de Day 20–30 del meta-juego con entrenamiento consistente.
- **Imagen Residual** introduce la primera herramienta de engaño puro en el kit de Goku. Diferencia clave con Kyō-ken: Kyō-ken requiere que el enemigo sea vulnerable a la finta (Intel Combate baja), Imagen Residual depende del diferencial de Velocidad.
- La resistencia al fuego es notable porque en este tier Goku no tiene control sobre el fuego — solo lo aguanta. Esto lo diferencia de usuarios activos de Manipulación del Calor.
- **Oozaru 8-B** debe seguir siendo un evento de historia en este tier, no activable libremente. Su poder destructor contra aliados en Modo Berserk es un riesgo narrativo que el diseño debe preservar.
