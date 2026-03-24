# data/actions/base/DayContext.gd
# Objeto de solo lectura que se pasa a cada acción.
# La acción NO modifica CharacterData directamente — devuelve un Result.
# Esto permite testear acciones sin un Player real.
class_name DayContext
extends RefCounted

var day_number: int
var character_data: CharacterData      # Datos del personaje (lectura)
var rng: RandomNumberGenerator         # RNG con semilla determinista por día

## Crea un contexto sellado para el día N.
static func create(data: CharacterData) -> DayContext:
	var ctx := DayContext.new()
	ctx.day_number      = data.current_day
	ctx.character_data  = data
	ctx.rng             = RandomNumberGenerator.new()
	# Semilla determinista: mismo día + mismo personaje = mismos eventos.
	# Útil para reproducibilidad y debug. Cambiar la semilla base en el futuro
	# si se quiere variabilidad total.
	ctx.rng.seed = hash(str(data.character_name) + str(data.current_day))
	return ctx
