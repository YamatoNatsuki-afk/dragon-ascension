# res://data/analysis/BuildProfile.gd
# Resource que describe un arquetipo de build (Striker, Ki User, Tank, etc.).
# BuildAnalyzer carga estos .tres desde data/analysis/profiles/ y los usa
# para calcular a qué arquetipo se parece más el personaje en cada momento.
#
# ESTE ARCHIVO FALTABA — causaba errores en BuildAnalyzer, CheckpointResult,
# ProgressTracker y EventBus (todos usan BuildProfile como tipo).
class_name BuildProfile
extends Resource

## Identificador único del perfil. Debe coincidir con el nombre del .tres.
@export var id: StringName       = &""
## Nombre visible en UI y logs.
@export var display_name: String = ""
## Descripción narrativa del arquetipo.
@export var description: String  = ""

# ── Criterios de clasificación ───────────────────────────────────────────────

## Stats que deben ser dominantes en este build.
## Ejemplo striker: [&"strength", &"speed"]
@export var required_high_stats: Array[StringName] = []

## Stats que no deberían dominar en este build.
## Ejemplo striker: [&"ki_max"] — un striker que entrena ki pierde identidad.
@export var penalized_stats: Array[StringName] = []

## Umbral de stat_priority_weight considerado "alto" para este build.
## BuildAnalyzer lo usa para normalizar el score de intención.
## Rango típico: 0.6 – 0.9
@export var threshold_high: float = 0.7

# ── Visual / UX ──────────────────────────────────────────────────────────────

## Color representativo del build para la UI (aura, iconos, etc.)
@export var profile_color: Color = Color.WHITE

## Icono o identificador de sprite para la UI (placeholder hasta tener assets)
@export var icon_id: StringName = &""
