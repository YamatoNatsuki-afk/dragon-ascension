# res://entities/player/states/TransformState.gd
#
# Estado de activación/desactivación de transformaciones.
# Actúa como "toggle": si ya hay una transformación activa la desactiva,
# si no, activa la de mayor tier disponible para este personaje.
#
# FLUJO:
#   enter() → toggle transform → vuelve inmediatamente a Idle
#   La lógica real (multiplicadores, drenaje) vive en TransformationSystem.
#
# PRIORIDAD DE TRANSFORMACIONES:
#   SSJ1 > Kaioken×4 > Kaioken×3 > Kaioken > Oozaru > Forma Gigante
#   Solo se activa la primera que esté desbloqueada para la raza del personaje.
#
# FEEDBACK VISUAL:
#   Flash del color del aura de la transformación sobre el placeholder del jugador.
#   Reemplazar con animación/shader en Fase 4.
#
class_name TransformState
extends PlayerState

# Orden de prioridad — la primera disponible gana
const TRANSFORM_PRIORITY: Array[StringName] = [
	&"transform_ssj1",
	&"transform_kaioken_x4",
	&"transform_kaioken_x3",
	&"transform_kaioken",
	&"transform_oozaru",
	&"transform_giant",
]

func enter(_previous_state: PlayerState = null) -> void:
	player.velocity = Vector2.ZERO

	var ts_node := player.get_node_or_null("/root/TransformationSystem")
	if ts_node == null:
		push_warning("[TransformState] TransformationSystem no encontrado como autoload.")
		player.state_machine.change_state(&"IdleState")
		return

	# Toggle: si ya hay una activa, desactivar
	if ts_node.is_active():
		ts_node.deactivate()
		_flash_deactivate()
		player.state_machine.change_state(&"IdleState")
		return

	# Buscar la mejor transformación disponible
	var char_data = player.stats.character_data
	if char_data == null:
		player.state_machine.change_state(&"IdleState")
		return

	var ts: TransformationState = char_data.transformation_state
	if ts == null:
		player.state_machine.change_state(&"IdleState")
		return

	var target_id: StringName = &""
	for tr_id: StringName in TRANSFORM_PRIORITY:
		if ts.is_unlocked(tr_id):
			target_id = tr_id
			break

	if target_id == &"":
		_flash_no_transform()
		player.state_machine.change_state(&"IdleState")
		return

	var activated: bool = ts_node.try_activate(target_id)
	if activated:
		var reg_node := player.get_node_or_null("/root/TransformationRegistry")
		var def: TransformationDefinition = null
		if reg_node != null:
			def = reg_node.get_definition(target_id)
		_flash_activate(def.aura_color if def != null else Color(1.0, 0.9, 0.2))
	else:
		_flash_no_transform()

	player.state_machine.change_state(&"IdleState")

# ─────────────────────────────────────────────────────────────────────────────
# EFECTOS VISUALES
# ─────────────────────────────────────────────────────────────────────────────

func _flash_activate(aura_color: Color) -> void:
	# Flash expansivo del color del aura — placeholder hasta tener shaders
	for i in 3:
		var ring := ColorRect.new()
		ring.color    = Color(aura_color.r, aura_color.g, aura_color.b, 0.8)
		ring.size     = Vector2(48.0 + i * 24.0, 64.0 + i * 24.0)
		ring.position = player.global_position + Vector2(
			-(24.0 + i * 12.0), -(32.0 + i * 12.0)
		)
		player.get_parent().add_child(ring)

		var tween := ring.create_tween()
		tween.set_parallel(true)
		tween.tween_property(ring, "scale", Vector2(2.5, 2.5), 0.4)
		tween.tween_property(ring, "modulate:a", 0.0, 0.4)
		tween.tween_callback(ring.queue_free)

	# Colorear el placeholder del jugador con el color de la transformación
	_tint_player_body(aura_color)

func _flash_deactivate() -> void:
	_tint_player_body(Color(0.2, 0.5, 1.0))   # volver al azul base del placeholder

func _flash_no_transform() -> void:
	# Parpadeo gris — sin transformación disponible
	var label        := Label.new()
	label.text        = "Sin transformación"
	label.position    = player.global_position + Vector2(-50.0, -60.0)
	label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	label.add_theme_font_size_override("font_size", 12)
	player.get_parent().add_child(label)

	var tween := label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 25.0, 0.5)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(label.queue_free)

func _tint_player_body(color: Color) -> void:
	# Busca el ColorRect hijo del player (el placeholder cuadrado)
	for child in player.get_children():
		if child is ColorRect:
			var tw := child.create_tween()
			tw.tween_property(child, "color", color, 0.15)
			break
