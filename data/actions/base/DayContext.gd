# res://data/actions/base/DayContext.gd
# Objeto de solo lectura que se pasa a cada acción en execute().
# La acción NO modifica CharacterData directamente — devuelve un Result.
# Permite testear acciones sin un Player real en escena.
# ARCHIVO CANÓNICO — eliminar: res://data/characters/actions/DayContext.gd
class_name DayContext
extends RefCounted

var day_number: int
var character_data: CharacterData     # Lectura únicamente
var rng: RandomNumberGenerator        # RNG con semilla determinista por día

## Crea un contexto sellado para el día actual del personaje.
static func create(data: CharacterData) -> DayContext:
	var ctx            := DayContext.new()
	ctx.day_number     = data.current_day
	ctx.character_data = data
	ctx.rng            = RandomNumberGenerator.new()
	# Semilla determinista: mismo día + mismo nombre = mismos eventos.
	# Útil para reproducibilidad y debug.
	ctx.rng.seed       = hash(str(data.character_name) + str(data.current_day))
	return ctx
