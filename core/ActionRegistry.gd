# Añadir a core/ActionRegistry.gd

## Devuelve las acciones disponibles, incluyendo:
##   - acciones desbloqueadas por flag
##   - eventos inyectados activos
func get_available(ctx: DayContext) -> Array[DayAction]:
	var result: Array[DayAction] = []
	var current_day := ctx.day_number

	for action: DayAction in _all_actions:
		if not action.is_available(ctx):
			continue

		# Comprobar si la acción requiere desbloqueo por flag
		if action.requires_unlock_flag != &"":
			if not FlagSystem.has(action.requires_unlock_flag):
				continue  # Bloqueada hasta que un checkpoint la desbloquee

		result.append(action)

	# Añadir eventos inyectados temporalmente por consecuencias
	_inject_active_events(result, current_day)

	return result

func _inject_active_events(pool: Array[DayAction], current_day: int) -> void:
	for action: DayAction in _all_actions:
		if pool.has(action):
			continue  # Ya está en el pool
		if InjectEventConsequence.is_event_active(action.id, current_day):
			pool.append(action)
