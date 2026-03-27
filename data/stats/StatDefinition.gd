# res://data/stats/StatDefinition.gd
# Resource de solo datos. Define los metadatos de un stat del juego.
# Un .tres por stat, cargados por StatRegistry al iniciar.
#
# NUNCA contiene lógica — solo datos que el diseñador edita en el inspector.
#
class_name StatDefinition
extends Resource

## Identificador único del stat. Debe coincidir con las keys de CharacterData.base_stats.
## Ejemplo: &"strength", &"health_max"
@export var id: StringName = &""

## Nombre legible para UI y logs.
@export var display_name: String = ""

## Valor con el que nace un personaje antes de multiplicadores de raza.
@export var base_value: float = 0.0

## Límite inferior. StatRegistry.clamp_stat() nunca devuelve menos que esto.
@export var min_value: float = 0.0

## Límite superior. StatRegistry.clamp_stat() nunca devuelve más que esto.
@export var max_value: float = 9999.0

## Descripción para tooltips o documentación interna.
@export_multiline var description: String = ""
