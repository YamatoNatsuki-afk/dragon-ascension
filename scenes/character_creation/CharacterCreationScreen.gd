# ============================================================
# res://scenes/character_creation/CharacterCreationScreen.gd
#
# Pantalla de creación de personaje — Dragon Ascension
#
# RESPONSABILIDADES DE ESTE SCRIPT:
#   1. Mostrar los controles de selección (nombre, raza, puntos)
#   2. Leer los valores ingresados por el jugador
#   3. Calcular el build dominante en tiempo real
#   4. Ensamblar CharacterData usando CharacterFactory
#   5. Guardar en disco y notificar a los sistemas globales
#
# DEPENDENCIAS (autoloads / clases del proyecto):
#   RaceRegistry    → provee las RaceDefinition cargadas desde .tres
#   CharacterFactory → construye y valida el CharacterData final
#   BuildAnalyzer   → calcula qué perfil domina según los pesos
#   SaveSystem      → persiste el CharacterData a disco
#   EventBus        → señal global run_started
#   DayManager      → recibe el CharacterData para iniciar el loop
# ============================================================
class_name CharacterCreationScreen
extends Control

# ──────────────────────────────────────────────────────────────
# SEÑAL DIRECTA
# GameManager conecta esta señal con CONNECT_ONE_SHOT.
# Se emite DESPUÉS de run_started para que GameManager
# arranque DayScreen solo cuando todos los sistemas globales
# ya hayan recibido el evento.
# ──────────────────────────────────────────────────────────────
signal character_confirmed(data)  # CharacterData

# ═══════════════════════════════════════════════════════════════
# SECCIÓN 1 — CONSTANTES Y CONFIGURACIÓN
#
# Centralizar aquí los límites del sistema de puntos permite
# ajustar el balance sin tocar la lógica.
# ═══════════════════════════════════════════════════════════════

# Total de puntos que el jugador puede repartir entre sus stats.
# Cada punto se traduce a 0.1 de stat_priority_weight (rango 0.0–1.0).
const TOTAL_POINTS: int = 10

# Máximo por stat individual. Limita a 0.8 de weight máximo,
# evitando builds completamente desequilibrados (ej: 10/0/0/0).
const MAX_PER_STAT: int = 8

# Stats que el jugador puede priorizar.
# health_max queda fuera porque lo determina la raza, no la intención.
const PRIORITY_STATS: Array[StringName] = [
	&"strength", &"ki_max", &"speed", &"defense"
]

# Nombres visibles en la UI para cada stat priorizable.
const STAT_LABELS: Dictionary = {
	&"strength": "Strength",
	&"ki_max":   "Ki",
	&"speed":    "Speed",
	&"defense":  "Defense",
}

# ═══════════════════════════════════════════════════════════════
# SECCIÓN 2 — ESTADO INTERNO DE LA PANTALLA
#
# Este estado representa las SELECCIONES ACTUALES del jugador.
# No se toca CharacterData hasta que el jugador pulsa Start.
# Separar UI-state de CharacterData garantiza que podemos
# cancelar o resetear sin corromper datos de partida.
# ═══════════════════════════════════════════════════════════════

# Raza actualmente seleccionada (cambia con los botones de raza).
var _selected_race: RaceDefinition = null

# Lista de razas disponibles — se puebla desde RaceRegistry en _ready().
# Ordenada alfabéticamente para display consistente.
var _all_races: Array[RaceDefinition] = []

# Puntos restantes por asignar. Empieza en TOTAL_POINTS y baja con cada "+".
var _points_remaining: int = TOTAL_POINTS

# Puntos asignados por stat. Cada valor aquí → weight = valor * 0.1 en BuildData.
var _allocation: Dictionary = {
	&"strength": 0,
	&"ki_max":   0,
	&"speed":    0,
	&"defense":  0,
}

# ═══════════════════════════════════════════════════════════════
# SECCIÓN 3 — REFERENCIAS A NODOS UI
#
# Guardamos referencias a los nodos que necesitamos leer/actualizar
# para no buscarlos con get_node() en cada frame.
# Los nodos se crean en _build_ui(), no en el .tscn.
# ═══════════════════════════════════════════════════════════════

# ── Paleta base — coherente con DayScreen ────────────────────────────────────
const C_BG        := Color(0.07, 0.07, 0.09)
const C_PANEL     := Color(0.12, 0.12, 0.16)
const C_PANEL_ALT := Color(0.17, 0.17, 0.22)
const C_ACCENT    := Color(1.00, 0.78, 0.10)
const C_TEXT      := Color(0.92, 0.90, 0.86)
const C_MUTED     := Color(0.50, 0.49, 0.47)
const C_NEGATIVE  := Color(0.90, 0.32, 0.28)

# ── Paleta extendida Dragon Ball ──────────────────────────────────────────────
# Gradiente de poder para las barras de stat: amarillo (bajo) → naranja → rojo (alto)
const C_POWER_LOW  := Color(1.00, 0.90, 0.10)   # Amarillo Ki
const C_POWER_MID  := Color(1.00, 0.50, 0.05)   # Naranja fuego
const C_POWER_HIGH := Color(0.95, 0.15, 0.10)   # Rojo combat

# Iconos de stat para los labels — da sensación de juego de rol
const STAT_ICONS: Dictionary = {
	&"strength": "⚔",
	&"ki_max":   "✦",
	&"speed":    "▶",
	&"defense":  "🛡",
}

# ── Textos de lore tipo Dragon Ball por raza ──────────────────────────────────
# Se muestran en el panel de info como descripción narrativa.
# Usan segunda persona para que el jugador se identifique con el guerrero.
const DB_RACE_FLAVOR: Dictionary = {
	&"saiyan":   "Un guerrero de sangre real nacido para la batalla.\nCada derrota forja en él un poder inimaginable.\n✦ Tu fuerza y velocidad no tienen límite.",
	&"human":    "La voluntad humana supera cualquier barrera.\nDonde otros se rinden, tú te levantas más fuerte.\n✦ Tu versatilidad es tu mayor arma.",
	&"namekian": "Maestro del Ki interno, guardián de la sabiduría.\nTu espíritu es tan sólido como la roca verde de Namek.\n✦ Tu Ki y defensa son inquebrantables.",
}

# Fallback si la raza no tiene texto de lore registrado
const DB_RACE_FLAVOR_DEFAULT := "Un guerrero de potencial desconocido.\nSu historia aún no ha sido escrita.\n✦ El poder duerme dentro de ti."

# ── Textos de lore por build ───────────────────────────────────────────────────
# Reemplazan la descripción técnica del BuildProfile con texto narrativo DB.
const DB_BUILD_FLAVOR: Dictionary = {
	&"striker":  "«El camino del guerrero de combate cuerpo a cuerpo.\nNi barreras ni distancias — solo el impacto directo.\nTu puño es tu argumento.»",
	&"ki_user":  "«El camino del maestro de la energía.\nLa distancia no existe cuando el Ki lo borra todo.\nTu voluntad se convierte en destrucción.»",
	&"tank":     "«El camino del bastión inamovible.\nCada golpe recibido es una prueba superada.\nNada te derrumba.»",
	&"balanced": "«El camino del guerrero completo.\nSin punto débil, sin especialización obvia.\nAdaptable a cualquier batalla.»",
}

const DB_BUILD_FLAVOR_DEFAULT := "«Asigna tus puntos para\ndescubrir tu verdadero\ncamino como guerrero.»"

# ── Sección: Nombre
var _name_input: LineEdit          # Fuente del nombre del personaje

# ── Sección: Raza
var _race_buttons:       Array[Button]       = []   # Un botón por RaceDefinition
var _race_styleboxes:    Array[StyleBoxFlat] = []   # StyleBox editable de cada botón (para borde de color)
var _race_desc_label:    Label                      # Descripción de la raza activa
var _race_traits_label:  Label                      # Rasgos raciales como texto inline
var _aura_preview:       ColorRect                  # Color del aura por defecto de la raza

# ── Sección: Stats
var _points_label:     Label                    # "X / 10 pts" — contador global
var _stat_value_labels: Dictionary = {}         # StringName → Label (valor numérico)
var _stat_bar_refs:     Dictionary = {}         # StringName → ProgressBar (barra visual)
var _stat_minus_btns:   Dictionary = {}         # StringName → Button (-)
var _stat_plus_btns:    Dictionary = {}         # StringName → Button (+)

# ── Sección: Build Preview
var _build_color_bar:        ColorRect          # Barra lateral de color del perfil
var _build_panel_sb:         StyleBoxFlat       # StyleBox del panel — se tinta al cambiar build
var _build_name_label:       Label              # "Striker", "Ki User", etc.
var _build_desc_label:       Label              # Descripción narrativa del build
var _build_flavor_label:     Label              # Texto lore tipo DB ("«El camino del...»")
var _build_scores_container: VBoxContainer      # Tabla con afinidad de todos los builds

# ── Footer
var _validation_label: Label                    # Mensaje de error (invisible si no hay errores)
var _start_button:     Button                   # Botón de confirmación final

# ═══════════════════════════════════════════════════════════════
# SECCIÓN 4 — ARRANQUE
# ═══════════════════════════════════════════════════════════════

func _ready() -> void:
	# FIX DE VISIBILIDAD: set_anchors_preset DEBE llamarse dentro de _ready()
	# (cuando el nodo ya está en el árbol), no antes. Si se llama desde fuera
	# antes de add_child(), el Control no conoce el tamaño del padre y
	# calcula anchors sobre Vector2(0,0) → pantalla invisible.
	set_anchors_preset(Control.PRESET_FULL_RECT)

	# Cargar todas las razas desde RaceRegistry y ordenar alfabéticamente.
	# Añadir una raza nueva = crear un .tres en data/races/definitions/. Sin tocar código.
	_all_races = RaceRegistry.get_all_races()
	_all_races.sort_custom(func(a: RaceDefinition, b: RaceDefinition) -> bool:
		return a.display_name < b.display_name
	)

	if _all_races.is_empty():
		push_error("CharacterCreationScreen: RaceRegistry vacío. ¿Faltan .tres en data/races/definitions/?")
		return

	# Selección inicial: primera raza de la lista ordenada.
	_selected_race = _all_races[0]

	_build_ui()    # Construir todos los nodos de la interfaz
	_update_all()  # Sincronizar UI con el estado inicial

# ═══════════════════════════════════════════════════════════════
# SECCIÓN 5 — LECTURA DE INPUTS DEL JUGADOR
#
# Estos métodos son la "capa de lectura" — transforman lo que
# el jugador seleccionó en datos del dominio del juego.
# Se llaman solo en _on_start_pressed(), tras validación.
# ═══════════════════════════════════════════════════════════════

## Lee el nombre del LineEdit y lo devuelve limpio.
##
## REGLA DE NOMBRE VACÍO:
##   Si el campo está vacío, retorna "Kakarot" como fallback.
##   El placeholder_text del LineEdit ya anuncia este comportamiento.
##   Esto convierte "campo vacío" en un estado VÁLIDO (no un error),
##   lo que simplifica la validación y la UX: el jugador puede
##   pulsar Start sin nombre y obtendrá a "Kakarot".
##
## _get_validation_errors() ya no chequea el nombre — este método
## es la única fuente de verdad sobre el nombre final.
func _read_character_name() -> String:
	var raw := _name_input.text.strip_edges()
	return raw if not raw.is_empty() else "Kakarot"

## Lee la raza seleccionada.
## _selected_race se actualiza en _on_race_selected() cada vez que
## el jugador pulsa un botón de raza.
func _read_selected_race() -> RaceDefinition:
	return _selected_race

## Lee la distribución de puntos y la convierte en BuildData.
##
## LÓGICA DE CONVERSIÓN:
##   _allocation[stat] = puntos (0–8, entero)
##   → stat_priority_weight = puntos * 0.1 (0.0–0.8, float)
##
## Este weight le dice al DayManager y al ActionSelector
## qué stats debe priorizar al sugerir entrenamientos.
## No modifica los stats base — eso lo hace CharacterFactory con los
## multiplicadores de raza.
func _read_build_data() -> BuildData:
	var build := BuildData.new()

	for stat_id: StringName in PRIORITY_STATS:
		# Cada punto = 10% de prioridad sobre ese stat durante el entrenamiento.
		# Un jugador con strength=8 entrena fuerza el 80% del tiempo (si el sistema lo respeta).
		build.stat_priority_weights[stat_id] = _allocation[stat_id] * 0.1

	# El combat_style se calcula desde BuildAnalyzer, no se hardcodea.
	# De este modo es consistente con la identidad que ya muestra la preview.
	var temp = _make_temp_character_data()
	var ident := BuildAnalyzer.get_build_identity(temp)
	build.combat_style = ident.id if ident != null else &"balanced"

	return build

## Lee los datos visuales del personaje desde la raza seleccionada.
## AppearanceData es solo estética — no afecta gameplay.
## En Fase 4 aquí se añadirán color de traje, escala corporal, etc.
func _read_appearance() -> AppearanceData:
	var ap       := AppearanceData.new()
	ap.aura_color = _selected_race.default_aura_color
	ap.body_scale = 1.0   # Neutral — la raza podrá modificarlo en el futuro
	return ap

# ═══════════════════════════════════════════════════════════════
# SECCIÓN 6 — CÁLCULO DEL BUILD DOMINANTE
#
# El build dominante no es un enum fijo — es el resultado de
# comparar los pesos de intención del jugador contra los perfiles
# definidos en data/analysis/profiles/*.tres.
#
# BuildAnalyzer es una clase estática pura (sin nodo, sin estado
# persistente entre instancias). Llamarla desde aquí es seguro
# y no produce efectos secundarios.
#
# Para la PREVIEW en tiempo real usamos _make_temp_character_data(),
# que construye un CharacterData mínimo con los pesos actuales
# SIN aplicar multiplicadores de raza. Esto es intencional:
# la preview muestra intención, no stats finales.
# ═══════════════════════════════════════════════════════════════

## Construye un CharacterData temporal solo para consultar BuildAnalyzer.
## NUNCA se guarda ni se pasa a otros sistemas.
## El objeto vive solo durante la actualización de la preview.
func _make_temp_character_data():  # → CharacterData
	var temp_build := BuildData.new()
	for stat_id: StringName in PRIORITY_STATS:
		temp_build.stat_priority_weights[stat_id] = _allocation[stat_id] * 0.1

	var temp = CharacterData.new()
	temp.build  = temp_build
	# base_stats usa los defaults de CharacterData.
	# BuildAnalyzer los normaliza como proporciones relativas,
	# así que con valores iguales la discriminación viene solo de los weights.
	return temp

## Devuelve el BuildProfile dominante para los pesos actuales.
## Usado por _update_build_preview() y _read_build_data().
func _calculate_dominant_build() -> BuildProfile:
	return BuildAnalyzer.get_build_identity(_make_temp_character_data())

# ═══════════════════════════════════════════════════════════════
# SECCIÓN 7 — VALIDACIÓN
#
# REGLAS ACTUALES:
#   • Nombre vacío → VÁLIDO (se usa "Kakarot" como fallback).
#     _read_character_name() garantiza que nunca devuelve vacío.
#   • Puntos sin asignar → INVÁLIDO. El jugador debe comprometerse
#     con su build antes de empezar. No hay puntos "en reserva".
#   • Puntos excedidos → INVÁLIDO. Nunca debería ocurrir si los
#     botones + están correctamente desactivados, pero lo chequeamos
#     como defensa en profundidad.
#   • Sin raza seleccionada → INVÁLIDO. Solo ocurre si RaceRegistry
#     está vacío (error de configuración del proyecto).
#
# Retornar Array[String] en vez de bool permite mostrar mensajes
# específicos y escala sin if/else anidados.
#
# _update_footer() es el único consumidor en tiempo real.
# _on_start_pressed() lo usa como segunda línea de defensa.
# ═══════════════════════════════════════════════════════════════

## Devuelve lista de mensajes de error.
## Lista vacía = el formulario está listo para crear el personaje.
## El botón Start se activa SOLO cuando esta lista está vacía.
func _get_validation_errors() -> Array[String]:
	var errors: Array[String] = []

	# Regla 1: debe haber una raza seleccionada.
	# Falla solo si RaceRegistry está vacío (error de configuración).
	if _selected_race == null:
		errors.append("⚠  No hay razas disponibles. Verifica data/races/definitions/.")
		return errors  # Sin raza no tiene sentido seguir chequeando

	# Regla 2: todos los puntos deben estar asignados.
	# "Faltan puntos" bloquea el Start — el jugador debe comprometerse.
	# El contador "X / 10" en la UI muestra cuántos faltan en todo momento.
	if _points_remaining > 0:
		errors.append("⚠  Faltan %d puntos por asignar." % _points_remaining)

	# Regla 3: guardia defensiva — los puntos nunca deben exceder el límite.
	# En condiciones normales los botones + desactivados lo previenen,
	# pero verificamos aquí por si hay manipulación externa del estado.
	var total_assigned := TOTAL_POINTS - _points_remaining
	if total_assigned > TOTAL_POINTS:
		errors.append("⚠  Error interno: puntos excedidos (%d > %d)." % [total_assigned, TOTAL_POINTS])

	# NOTA — Nombre vacío NO es un error:
	# _read_character_name() retorna "Kakarot" si el campo está vacío.
	# El placeholder_text del LineEdit ya informa al jugador de esto.

	return errors

# ═══════════════════════════════════════════════════════════════
# SECCIÓN 8 — CREACIÓN DEL PERSONAJE Y EMISIÓN DE SEÑALES
#
# Este es el punto de no retorno. Solo llega aquí si la
# validación pasa. El orden de operaciones importa:
#
#   1. CharacterFactory.create()  → ensambla CharacterData
#   2. SaveSystem.save_character() → persiste en disco
#   3. EventBus.run_started.emit() → notifica sistemas globales
#   4. character_confirmed.emit()  → notifica GameManager
#
# El save ocurre ANTES de las señales para garantizar que si
# algún receptor crashea, el save ya existe en disco.
# ═══════════════════════════════════════════════════════════════

func _on_start_pressed() -> void:
	# ── Paso 0: validación defensiva ──────────────────────────────────────
	# El botón debería estar desactivado si hay errores, pero es mejor
	# fallar explícitamente que llegar a CharacterFactory con datos inválidos.
	var errors := _get_validation_errors()
	if not errors.is_empty():
		push_warning("CharacterCreationScreen: Start presionado con errores: %s" % str(errors))
		return

	# ── Paso 1: leer inputs del jugador ───────────────────────────────────
	var char_name   := _read_character_name()
	var race_id     := _read_selected_race().id    # StringName: &"saiyan", &"human", etc.
	var appearance  := _read_appearance()
	var build       := _read_build_data()

	# ── Paso 2: construir CharacterData ───────────────────────────────────
	# CharacterFactory.create() es el ÚNICO punto de creación de CharacterData.
	# Aplica los multiplicadores de raza sobre base_stats, lo que significa
	# que un Saiyajin con strength=0.1 sigue teniendo más fuerza base que
	# un Humano con strength=0.0 (multiplicador 1.5 vs 1.0).
	# El jugador ve la INTENCIÓN con sus puntos; la EJECUCIÓN la da la raza.
	var data = CharacterFactory.create(char_name, race_id, appearance, build)

	if data == null:
		# CharacterFactory ya habrá emitido un push_error con el detalle.
		push_error("CharacterCreationScreen: CharacterFactory.create() devolvió null.")
		return

	# ── Paso 3: guardar en disco ───────────────────────────────────────────
	# Guardamos ANTES de emitir señales. Si algo falla después,
	# el jugador tiene su personaje guardado y puede retomar.
	# SaveSystem usa slot 0 (partida única por ahora).
	SaveSystem.save_character(data)
	print("[CharacterCreationScreen] Personaje '%s' guardado. Build: %s" % [
		data.character_name,
		data.build.combat_style
	])

	# ── Paso 4: notificar sistemas globales (EventBus) ─────────────────────
	# run_started es para sistemas que NO son GameManager:
	# MusicManager, AnalyticsSystem, TransitionManager, etc.
	# Cualquier autoload o nodo suscrito puede reaccionar aquí.
	EventBus.run_started.emit(data)

	# ── Paso 5: notificar GameManager (señal directa) ──────────────────────
	# GameManager conectó esta señal con CONNECT_ONE_SHOT.
	# Al recibirla, hará queue_free() de esta pantalla y lanzará DayScreen.
	# Emitimos DESPUÉS de EventBus.run_started para que todos los sistemas
	# globales estén listos antes de que DayScreen empiece a escuchar.
	character_confirmed.emit(data)

# ═══════════════════════════════════════════════════════════════
# SECCIÓN 9 — CALLBACKS DE UI
#
# Cada callback tiene una sola responsabilidad:
# actualizar el estado interno y llamar _update_all() o el
# sub-método específico que corresponde.
# ═══════════════════════════════════════════════════════════════

## Llamado en cada keystroke del LineEdit de nombre.
func _on_name_changed(_new_text: String) -> void:
	# Solo actualizamos el footer (validación + botón) porque el nombre
	# no afecta la raza ni el build preview.
	_update_footer()

## Llamado cuando el jugador pulsa un botón de raza.
## El índice corresponde al orden de _all_races (ordenado alfabéticamente).
func _on_race_selected(index: int) -> void:
	_selected_race = _all_races[index]
	# La raza cambia la descripción y el color de aura, pero NO afecta
	# el build preview (que depende de los weights, no de multiplicadores de raza).
	_update_race_display()

## Llamado cuando el jugador pulsa + o - en cualquier stat.
## delta = +1 (añadir punto) o -1 (quitar punto).
func _on_stat_changed(stat_id: StringName, delta: int) -> void:
	var new_val: int = _allocation[stat_id] + delta

	# Guardias: no salir del rango permitido
	if new_val < 0 or new_val > MAX_PER_STAT:
		return
	# No gastar puntos que no tenemos
	if delta > 0 and _points_remaining <= 0:
		return

	_allocation[stat_id]  = new_val
	_points_remaining    -= delta   # +1 punto al stat = -1 punto disponible

	# Los stats afectan tanto la barra de distribución como el build preview
	_update_stats_display()
	_update_build_preview()
	_update_footer()

# ═══════════════════════════════════════════════════════════════
# SECCIÓN 10 — ACTUALIZACIÓN DE UI
#
# _update_all() es el punto de entrada único y siempre seguro.
# Cada sub-método tiene exactamente una responsabilidad.
# No hay lógica de datos en estos métodos — solo lectura de
# estado y escritura a nodos UI.
# ═══════════════════════════════════════════════════════════════

## Sincroniza TODA la UI con el estado actual.
## Llamar esto en cualquier momento es idempotente y seguro.
func _update_all() -> void:
	_update_race_display()
	_update_stats_display()
	_update_build_preview()
	_update_footer()

## Actualiza botones de raza, panel de info y aplica flash visual al seleccionar.
func _update_race_display() -> void:
	for i: int in _race_buttons.size():
		var race      := _all_races[i]
		var is_active := (race == _selected_race)
		var sb        := _race_styleboxes[i]

		if is_active:
			# Fondo tintado + borde inferior grueso con el color de aura
			sb.bg_color             = race.default_aura_color.lerp(C_BG, 0.80)
			sb.border_color         = race.default_aura_color
			sb.border_width_bottom  = 4
			sb.border_width_top     = 0
			sb.border_width_left    = 0
			sb.border_width_right   = 0
		else:
			sb.bg_color             = C_PANEL_ALT
			sb.border_color         = Color.TRANSPARENT
			sb.border_width_bottom  = 0

		_race_buttons[i].add_theme_stylebox_override("normal",  sb)
		_race_buttons[i].add_theme_stylebox_override("hover",   sb)
		_race_buttons[i].add_theme_stylebox_override("pressed", sb)
		_race_buttons[i].add_theme_color_override(
			"font_color", race.default_aura_color if is_active else C_MUTED
		)
		_race_buttons[i].add_theme_font_size_override("font_size", 15 if is_active else 13)

	if _selected_race == null:
		return

	# ── Texto lore tipo DB ────────────────────────────────────────────────
	# Prioridad: DB_RACE_FLAVOR hardcodeado (lore narrativo) sobre la
	# description del .tres (técnica). Si la raza no tiene flavor, cae al .tres.
	var flavor: String = DB_RACE_FLAVOR.get(_selected_race.id, "")
	_race_desc_label.text = flavor if flavor != "" else _selected_race.description

	_aura_preview.color = _selected_race.default_aura_color

	# ── Rasgos raciales ───────────────────────────────────────────────────
	if _selected_race.racial_traits.is_empty():
		_race_traits_label.text = "Sin rasgos especiales"
	else:
		var names: Array[String] = []
		for trait_id: StringName in _selected_race.racial_traits:
			names.append(str(trait_id).replace("_", " ").capitalize())
		_race_traits_label.text = "  ·  ".join(names)

	# ── Flash visual: el panel de raza pulsa con el color de aura ─────────
	# Tween modulate: blanco → color de aura → blanco en 0.35s.
	# Da sensación de "poder activándose" sin mover nodos.
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(_race_desc_label, "modulate",
		_selected_race.default_aura_color.lerp(Color.WHITE, 0.3), 0.15)
	tween.tween_property(_race_desc_label, "modulate", Color.WHITE, 0.20)

## Actualiza los valores numéricos, barras y estado de botones de cada stat.
## Las barras usan gradiente de color amarillo → naranja → rojo según el nivel
## de puntos asignados, dando feedback visual inmediato de "poder acumulado".
func _update_stats_display() -> void:
	var used := TOTAL_POINTS - _points_remaining
	_points_label.text = "%d / %d pts" % [used, TOTAL_POINTS]

	for stat_id: StringName in PRIORITY_STATS:
		var pts: int = _allocation[stat_id]

		# Valor numérico central — color que refleja la intensidad
		var val_lbl := _stat_value_labels[stat_id] as Label
		val_lbl.text = str(pts)
		val_lbl.add_theme_color_override("font_color", _stat_power_color(pts, MAX_PER_STAT))

		# Barra de progreso con fill color dinámico (gradiente de poder)
		var bar     := _stat_bar_refs[stat_id] as ProgressBar
		bar.value    = pts
		# Actualizamos el StyleBox de fill con el color calculado
		var fill_sb := StyleBoxFlat.new()
		fill_sb.bg_color                   = _stat_power_color(pts, MAX_PER_STAT)
		fill_sb.corner_radius_top_left     = 3
		fill_sb.corner_radius_top_right    = 3
		fill_sb.corner_radius_bottom_left  = 3
		fill_sb.corner_radius_bottom_right = 3
		bar.add_theme_stylebox_override("fill", fill_sb)

		# Botones de control
		(_stat_minus_btns[stat_id] as Button).disabled = (pts <= 0)
		(_stat_plus_btns[stat_id]  as Button).disabled = (pts >= MAX_PER_STAT or _points_remaining <= 0)

## Calcula el color de "poder" para una barra de stat usando gradiente.
## 0 pts → C_POWER_LOW (amarillo)
## mitad → C_POWER_MID (naranja)
## máx   → C_POWER_HIGH (rojo)
## Interpolación en dos tramos para mayor control del gradiente.
func _stat_power_color(pts: int, max_pts: int) -> Color:
	if max_pts <= 0 or pts <= 0:
		return C_POWER_LOW
	var t := float(pts) / float(max_pts)     # 0.0 → 1.0
	if t <= 0.5:
		# Primer tramo: amarillo → naranja
		return C_POWER_LOW.lerp(C_POWER_MID, t * 2.0)
	else:
		# Segundo tramo: naranja → rojo
		return C_POWER_MID.lerp(C_POWER_HIGH, (t - 0.5) * 2.0)

## Calcula el build dominante y actualiza el panel de preview.
## Incluye texto lore estilo DB y animación de color del panel.
func _update_build_preview() -> void:
	var ident := _calculate_dominant_build()

	if ident == null:
		_build_name_label.text  = "—"
		_build_desc_label.text  = ""
		_build_flavor_label.text = DB_BUILD_FLAVOR_DEFAULT
		_build_color_bar.color  = C_PANEL
		# Panel vuelve a neutro
		_build_panel_sb.border_color = C_PANEL_ALT
		_build_panel_sb.bg_color     = C_PANEL_ALT
		for child in _build_scores_container.get_children():
			child.queue_free()
		return

	# ── Nombre y descripción técnica ─────────────────────────────────────
	_build_name_label.text = ident.display_name.to_upper()
	_build_desc_label.text = ident.description

	# ── Texto lore tipo DB ────────────────────────────────────────────────
	# Si hay texto registrado en DB_BUILD_FLAVOR lo usamos; si no, el genérico.
	_build_flavor_label.text = DB_BUILD_FLAVOR.get(ident.id, DB_BUILD_FLAVOR_DEFAULT)
	_build_flavor_label.add_theme_color_override("font_color", ident.profile_color.lerp(C_TEXT, 0.35))

	# ── Barra lateral e indicador de color ───────────────────────────────
	_build_color_bar.color = ident.profile_color

	# ── Panel tintado con el color del build (feedback visual fuerte) ─────
	# El fondo recibe un tinte muy suave del color del build.
	# El borde recibe el color completo para marcar la identidad.
	_build_panel_sb.bg_color     = ident.profile_color.lerp(C_PANEL_ALT, 0.88)
	_build_panel_sb.border_color = ident.profile_color
	_build_panel_sb.border_width_left   = 3
	_build_panel_sb.border_width_right  = 0
	_build_panel_sb.border_width_top    = 0
	_build_panel_sb.border_width_bottom = 0

	# ── Tabla de afinidades ───────────────────────────────────────────────
	for child in _build_scores_container.get_children():
		child.queue_free()

	var all_scores := BuildAnalyzer.get_all_scores(_make_temp_character_data())
	for entry: Dictionary in all_scores:
		var row := _build_score_row(entry.profile as BuildProfile, entry.score as float)
		_build_scores_container.add_child(row)

## Actualiza el mensaje de validación y el estado del botón Start.
##
## LÓGICA DEL BOTÓN START:
##   • Errores presentes  → disabled=true + texto de error en rojo
##   • Sin errores        → disabled=false + hint de nombre vacío si aplica
##
## HINT DE NOMBRE VACÍO:
##   Si el campo de nombre está vacío pero TODO lo demás es válido,
##   mostramos un mensaje informativo (no un error) indicando que
##   se usará "Kakarot". El botón Start sigue activo.
##   Esto evita confundir al jugador: el formulario ES válido,
##   solo le avisamos del comportamiento del fallback.
func _update_footer() -> void:
	var errors   := _get_validation_errors()
	var is_valid := errors.is_empty()

	# ── Botón Start: activo solo si no hay errores ────────────────────────
	_start_button.disabled = not is_valid

	# ── Estilo visual del botón según estado ─────────────────────────────
	# Cuando está desactivado Godot aplica su propia modulación gris,
	# pero reforzamos el alpha del texto para que sea más legible.
	_start_button.add_theme_color_override(
		"font_disabled_color", Color(C_BG.r, C_BG.g, C_BG.b, 0.4)
	)

	if not is_valid:
		# Hay errores: mostrar el primer mensaje en rojo y ocultar el hint
		_validation_label.modulate = Color.WHITE
		_validation_label.add_theme_color_override("font_color", C_NEGATIVE)
		_validation_label.text    = errors[0]
		_validation_label.visible = true
		return

	# Sin errores — chequear si hay hint de nombre vacío
	var name_is_empty := _name_input.text.strip_edges().is_empty()
	if name_is_empty:
		# Nombre vacío + todo lo demás válido → hint informativo (amarillo, no rojo)
		_validation_label.add_theme_color_override("font_color", C_ACCENT)
		_validation_label.text    = "ℹ  Nombre vacío: se usará \"Kakarot\""
		_validation_label.visible = true
	else:
		_validation_label.visible = false

# ═══════════════════════════════════════════════════════════════
# SECCIÓN 11 — CONSTRUCCIÓN DE UI (código de presentación puro)
#
# Separado en su propia sección para que las secciones de lógica
# (1–10) sean legibles sin scroll infinito.
# Ningún método aquí toma decisiones de gameplay.
# ═══════════════════════════════════════════════════════════════

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = C_BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(600, 0)
	panel.add_theme_stylebox_override("panel", _flat_style(C_PANEL))
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	panel.add_child(vbox)

	vbox.add_child(_spacer_v(24))
	vbox.add_child(_ui_title_bar())
	vbox.add_child(_spacer_v(20))
	vbox.add_child(_ui_name_section())
	vbox.add_child(_spacer_v(16))
	vbox.add_child(_ui_divider())
	vbox.add_child(_spacer_v(16))
	vbox.add_child(_ui_race_section())
	vbox.add_child(_spacer_v(16))
	vbox.add_child(_ui_divider())
	vbox.add_child(_spacer_v(16))
	vbox.add_child(_ui_stats_section())
	vbox.add_child(_spacer_v(16))
	vbox.add_child(_ui_divider())
	vbox.add_child(_spacer_v(16))
	vbox.add_child(_ui_build_preview_section())
	vbox.add_child(_spacer_v(20))
	vbox.add_child(_ui_footer_section())
	vbox.add_child(_spacer_v(24))

func _ui_title_bar() -> Control:
	# Panel de cabecera con fondo degradado hacia el color dorado
	var header_panel := PanelContainer.new()
	var header_sb    := StyleBoxFlat.new()
	header_sb.bg_color            = C_BG.lerp(Color(0.15, 0.12, 0.02), 0.6)
	header_sb.border_color        = C_ACCENT
	header_sb.border_width_bottom = 2
	header_panel.add_theme_stylebox_override("panel", header_sb)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   24)
	margin.add_theme_constant_override("margin_right",  24)
	margin.add_theme_constant_override("margin_top",    12)
	margin.add_theme_constant_override("margin_bottom", 12)
	header_panel.add_child(margin)

	var hbox := HBoxContainer.new()
	margin.add_child(hbox)

	# Decoración izquierda
	var deco_l := Label.new()
	deco_l.text = "✦ "
	deco_l.add_theme_color_override("font_color", C_ACCENT)
	deco_l.add_theme_font_size_override("font_size", 14)
	hbox.add_child(deco_l)

	var title := Label.new()
	title.text = "CREAR GUERRERO"
	title.add_theme_color_override("font_color", C_ACCENT)
	title.add_theme_font_size_override("font_size", 22)
	hbox.add_child(title)

	var deco_r := Label.new()
	deco_r.text = " ✦"
	deco_r.add_theme_color_override("font_color", C_ACCENT)
	deco_r.add_theme_font_size_override("font_size", 14)
	hbox.add_child(deco_r)

	hbox.add_child(_spacer_expand())

	var sub := Label.new()
	sub.text = "DRAGON ASCENSION"
	sub.add_theme_color_override("font_color", C_MUTED)
	sub.add_theme_font_size_override("font_size", 11)
	hbox.add_child(sub)

	return header_panel

func _ui_name_section() -> Control:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	hbox.add_child(_spacer_h(24))

	var lbl := Label.new()
	lbl.text                  = "NOMBRE"
	lbl.custom_minimum_size.x = 80
	lbl.add_theme_color_override("font_color", C_MUTED)
	lbl.add_theme_font_size_override("font_size", 11)
	hbox.add_child(lbl)

	_name_input = LineEdit.new()
	# placeholder_text informa explícitamente del fallback: si lo dejas vacío → Kakarot.
	# Así el jugador no se sorprende al ver "Kakarot" en el DayScreen.
	_name_input.placeholder_text      = "Vacío = Kakarot"
	_name_input.max_length            = 24
	_name_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_name_input.add_theme_color_override("font_color", C_TEXT)
	_name_input.text_changed.connect(_on_name_changed)
	hbox.add_child(_name_input)

	hbox.add_child(_spacer_h(24))
	return hbox

func _ui_race_section() -> Control:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)

	var h_row := HBoxContainer.new()
	h_row.add_child(_spacer_h(24))
	var header := Label.new()
	header.text = "RAZA"
	header.add_theme_color_override("font_color", C_MUTED)
	header.add_theme_font_size_override("font_size", 11)
	h_row.add_child(header)
	vbox.add_child(h_row)

	# Un botón por cada raza cargada desde RaceRegistry.
	# Cada botón recibe su propio StyleBoxFlat guardado en _race_styleboxes[i].
	# _update_race_display() modificará ese StyleBox directamente para cambiar
	# el color de fondo y borde sin necesidad de reemplazar el nodo.
	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 8)
	btn_row.add_child(_spacer_h(24))
	for i: int in _all_races.size():
		var btn := Button.new()
		btn.text                  = _all_races[i].display_name
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_race_selected.bind(i))

		# StyleBox mutable por botón — _update_race_display() lo edita en lugar
		# de crear uno nuevo cada vez, lo que es más eficiente.
		var sb := StyleBoxFlat.new()
		sb.bg_color                   = C_PANEL_ALT
		sb.corner_radius_top_left     = 4
		sb.corner_radius_top_right    = 4
		sb.corner_radius_bottom_left  = 4
		sb.corner_radius_bottom_right = 4
		sb.content_margin_top         = 8
		sb.content_margin_bottom      = 8
		btn.add_theme_stylebox_override("normal",  sb)
		btn.add_theme_stylebox_override("hover",   sb)
		btn.add_theme_stylebox_override("pressed", sb)

		btn_row.add_child(btn)
		_race_buttons.append(btn)
		_race_styleboxes.append(sb)

	btn_row.add_child(_spacer_h(24))
	vbox.add_child(btn_row)

	# Panel de descripción + rasgos + aura
	var m_row := HBoxContainer.new()
	m_row.add_child(_spacer_h(24))
	var info_panel := PanelContainer.new()
	info_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_panel.add_theme_stylebox_override("panel", _flat_style(C_PANEL_ALT))
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	info_panel.add_child(margin)
	var iv := VBoxContainer.new()
	iv.add_theme_constant_override("separation", 8)
	margin.add_child(iv)

	_race_desc_label = Label.new()
	_race_desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_race_desc_label.add_theme_color_override("font_color", C_TEXT)
	_race_desc_label.add_theme_font_size_override("font_size", 13)
	_race_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	iv.add_child(_race_desc_label)

	var traits_row := HBoxContainer.new()
	traits_row.add_theme_constant_override("separation", 10)
	iv.add_child(traits_row)

	_race_traits_label = Label.new()
	_race_traits_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_race_traits_label.add_theme_color_override("font_color", C_MUTED)
	_race_traits_label.add_theme_font_size_override("font_size", 11)
	traits_row.add_child(_race_traits_label)

	var aura_lbl := Label.new()
	aura_lbl.text = "Aura"
	aura_lbl.add_theme_color_override("font_color", C_MUTED)
	aura_lbl.add_theme_font_size_override("font_size", 11)
	traits_row.add_child(aura_lbl)

	_aura_preview = ColorRect.new()
	_aura_preview.custom_minimum_size = Vector2(44, 20)
	traits_row.add_child(_aura_preview)

	m_row.add_child(info_panel)
	m_row.add_child(_spacer_h(24))
	vbox.add_child(m_row)
	return vbox

func _ui_stats_section() -> Control:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)

	var h_row := HBoxContainer.new()
	h_row.add_child(_spacer_h(24))
	var header := Label.new()
	header.text                  = "PRIORIDADES DE ENTRENAMIENTO"
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_theme_color_override("font_color", C_MUTED)
	header.add_theme_font_size_override("font_size", 11)
	h_row.add_child(header)
	_points_label = Label.new()
	_points_label.add_theme_color_override("font_color", C_ACCENT)
	_points_label.add_theme_font_size_override("font_size", 13)
	h_row.add_child(_points_label)
	h_row.add_child(_spacer_h(24))
	vbox.add_child(h_row)

	var note_row := HBoxContainer.new()
	note_row.add_child(_spacer_h(24))
	var note := Label.new()
	note.text                  = "¿En qué entrenará más tu guerrero?  (1 pto = 10% de prioridad · máx. 8 por stat)"
	note.autowrap_mode         = TextServer.AUTOWRAP_WORD_SMART
	note.size_flags_horizontal = Control.SIZE_EXPAND_FILL   # ← sin esto el ancho es 0 → texto vertical
	note.add_theme_color_override("font_color", C_MUTED)
	note.add_theme_font_size_override("font_size", 11)
	note_row.add_child(note)
	note_row.add_child(_spacer_h(24))
	vbox.add_child(note_row)

	for stat_id: StringName in PRIORITY_STATS:
		vbox.add_child(_ui_stat_row(stat_id))

	return vbox

func _ui_stat_row(stat_id: StringName) -> Control:
	# Fila envuelta en un panel con fondo sutil para separar visualmente cada stat
	var outer_panel := PanelContainer.new()
	var outer_sb    := StyleBoxFlat.new()
	outer_sb.bg_color                   = C_BG.lerp(C_PANEL, 0.5)
	outer_sb.corner_radius_top_left     = 6
	outer_sb.corner_radius_top_right    = 6
	outer_sb.corner_radius_bottom_left  = 6
	outer_sb.corner_radius_bottom_right = 6
	outer_sb.content_margin_left   = 24
	outer_sb.content_margin_right  = 24
	outer_sb.content_margin_top    = 10
	outer_sb.content_margin_bottom = 10
	outer_panel.add_theme_stylebox_override("panel", outer_sb)

	var inner := HBoxContainer.new()
	inner.add_theme_constant_override("separation", 10)
	outer_panel.add_child(inner)

	# Icono + nombre del stat
	var icon_lbl := Label.new()
	icon_lbl.text = STAT_ICONS.get(stat_id, "·")
	icon_lbl.add_theme_color_override("font_color", C_ACCENT)
	icon_lbl.add_theme_font_size_override("font_size", 16)
	inner.add_child(icon_lbl)

	var name_lbl := Label.new()
	name_lbl.text                  = STAT_LABELS.get(stat_id, str(stat_id)).to_upper()
	name_lbl.custom_minimum_size.x = 80
	name_lbl.add_theme_color_override("font_color", C_TEXT)
	name_lbl.add_theme_font_size_override("font_size", 13)
	inner.add_child(name_lbl)

	# Botón − grande y estilizado
	var minus := Button.new()
	minus.text                = "−"
	minus.custom_minimum_size = Vector2(42, 42)
	minus.add_theme_font_size_override("font_size", 18)
	_style_control_button(minus, C_POWER_HIGH)
	minus.pressed.connect(_on_stat_changed.bind(stat_id, -1))
	inner.add_child(minus)
	_stat_minus_btns[stat_id] = minus

	# Valor numérico grande — cambia de color con el nivel
	var val_lbl := Label.new()
	val_lbl.text                  = "0"
	val_lbl.custom_minimum_size.x = 30
	val_lbl.horizontal_alignment  = HORIZONTAL_ALIGNMENT_CENTER
	val_lbl.add_theme_color_override("font_color", C_POWER_LOW)
	val_lbl.add_theme_font_size_override("font_size", 20)
	inner.add_child(val_lbl)
	_stat_value_labels[stat_id] = val_lbl

	# Botón + grande y estilizado
	var plus := Button.new()
	plus.text                = "+"
	plus.custom_minimum_size = Vector2(42, 42)
	plus.add_theme_font_size_override("font_size", 18)
	_style_control_button(plus, C_POWER_LOW)
	plus.pressed.connect(_on_stat_changed.bind(stat_id, +1))
	inner.add_child(plus)
	_stat_plus_btns[stat_id] = plus

	# Barra de poder — más alta (12px) para legibilidad
	var bar := ProgressBar.new()
	bar.min_value             = 0
	bar.max_value             = MAX_PER_STAT
	bar.value                 = 0
	bar.show_percentage       = false
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.custom_minimum_size.y = 12

	var fill := StyleBoxFlat.new()
	fill.bg_color                   = C_POWER_LOW
	fill.corner_radius_top_left     = 4
	fill.corner_radius_top_right    = 4
	fill.corner_radius_bottom_left  = 4
	fill.corner_radius_bottom_right = 4
	bar.add_theme_stylebox_override("fill", fill)

	var bg_sb := StyleBoxFlat.new()
	bg_sb.bg_color                   = C_BG
	bg_sb.corner_radius_top_left     = 4
	bg_sb.corner_radius_top_right    = 4
	bg_sb.corner_radius_bottom_left  = 4
	bg_sb.corner_radius_bottom_right = 4
	bar.add_theme_stylebox_override("background", bg_sb)

	inner.add_child(bar)
	_stat_bar_refs[stat_id] = bar

	return outer_panel

func _ui_build_preview_section() -> Control:
	var m_row := HBoxContainer.new()
	m_row.add_child(_spacer_h(24))

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# StyleBox mutable — _update_build_preview() cambia bg_color y border_color
	_build_panel_sb = StyleBoxFlat.new()
	_build_panel_sb.bg_color                   = C_PANEL_ALT
	_build_panel_sb.corner_radius_top_left     = 6
	_build_panel_sb.corner_radius_top_right    = 6
	_build_panel_sb.corner_radius_bottom_left  = 6
	_build_panel_sb.corner_radius_bottom_right = 6
	panel.add_theme_stylebox_override("panel", _build_panel_sb)

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 14)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	# Header de sección
	var header := Label.new()
	header.text = "BUILD ESTIMADO"
	header.add_theme_color_override("font_color", C_MUTED)
	header.add_theme_font_size_override("font_size", 11)
	vbox.add_child(header)

	# Fila principal: barra de color + nombre grande + descripción técnica
	var build_row := HBoxContainer.new()
	build_row.add_theme_constant_override("separation", 14)
	vbox.add_child(build_row)

	_build_color_bar = ColorRect.new()
	_build_color_bar.custom_minimum_size = Vector2(8, 0)
	_build_color_bar.size_flags_vertical = Control.SIZE_EXPAND_FILL
	build_row.add_child(_build_color_bar)

	var tv := VBoxContainer.new()
	tv.add_theme_constant_override("separation", 4)
	tv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	build_row.add_child(tv)

	_build_name_label = Label.new()
	_build_name_label.add_theme_color_override("font_color", C_TEXT)
	_build_name_label.add_theme_font_size_override("font_size", 20)
	tv.add_child(_build_name_label)

	_build_desc_label = Label.new()
	_build_desc_label.add_theme_color_override("font_color", C_MUTED)
	_build_desc_label.add_theme_font_size_override("font_size", 12)
	_build_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tv.add_child(_build_desc_label)

	# Separador ligero
	var sep := HSeparator.new()
	sep.add_theme_color_override("color", C_PANEL)
	vbox.add_child(sep)

	# Texto de lore tipo Dragon Ball — estilo cursiva narrativa
	_build_flavor_label = Label.new()
	_build_flavor_label.text            = DB_BUILD_FLAVOR_DEFAULT
	_build_flavor_label.autowrap_mode   = TextServer.AUTOWRAP_WORD_SMART
	_build_flavor_label.add_theme_color_override("font_color", C_MUTED)
	_build_flavor_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(_build_flavor_label)

	# Separador antes de la tabla de scores
	var sep2 := HSeparator.new()
	sep2.add_theme_color_override("color", C_PANEL)
	vbox.add_child(sep2)

	# Tabla de afinidades
	_build_scores_container = VBoxContainer.new()
	_build_scores_container.add_theme_constant_override("separation", 4)
	vbox.add_child(_build_scores_container)

	m_row.add_child(panel)
	m_row.add_child(_spacer_h(24))
	return m_row

func _ui_footer_section() -> Control:
	var m_row := HBoxContainer.new()
	m_row.add_child(_spacer_h(24))
	var inner := VBoxContainer.new()
	inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner.add_theme_constant_override("separation", 12)
	m_row.add_child(inner)
	m_row.add_child(_spacer_h(24))

	_validation_label = Label.new()
	_validation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_validation_label.add_theme_color_override("font_color", C_NEGATIVE)
	_validation_label.add_theme_font_size_override("font_size", 13)
	_validation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_validation_label.visible = false
	inner.add_child(_validation_label)

	_start_button = Button.new()
	_start_button.text                = "▶▶  INICIAR LOS 100 DÍAS  ◀◀"
	_start_button.custom_minimum_size = Vector2(0, 62)
	_start_button.add_theme_font_size_override("font_size", 17)
	_style_start_button(_start_button)
	_start_button.pressed.connect(_on_start_pressed)
	inner.add_child(_start_button)

	return m_row

# ═══════════════════════════════════════════════════════════════
# SECCIÓN 12 — HELPERS DE PRESENTACIÓN (sin lógica de gameplay)
# ═══════════════════════════════════════════════════════════════

## Fila de afinidad para la tabla de Build Preview.
func _build_score_row(profile: BuildProfile, score: float) -> Control:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)

	var dot := ColorRect.new()
	dot.color               = profile.profile_color
	dot.custom_minimum_size = Vector2(8, 8)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(dot)

	var name_lbl := Label.new()
	name_lbl.text                  = profile.display_name
	name_lbl.custom_minimum_size.x = 80
	name_lbl.add_theme_color_override("font_color", C_MUTED)
	name_lbl.add_theme_font_size_override("font_size", 11)
	hbox.add_child(name_lbl)

	var bar := ProgressBar.new()
	bar.min_value = 0.0; bar.max_value = 1.0; bar.value = score
	bar.show_percentage = false
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.custom_minimum_size.y = 5
	var f := StyleBoxFlat.new(); f.bg_color = profile.profile_color
	bar.add_theme_stylebox_override("fill", f)
	var b := StyleBoxFlat.new(); b.bg_color = C_PANEL
	bar.add_theme_stylebox_override("background", b)
	hbox.add_child(bar)

	var pct := Label.new()
	pct.text = "%.0f%%" % (score * 100.0)
	pct.custom_minimum_size.x = 36
	pct.horizontal_alignment  = HORIZONTAL_ALIGNMENT_RIGHT
	pct.add_theme_color_override("font_color", C_MUTED)
	pct.add_theme_font_size_override("font_size", 11)
	hbox.add_child(pct)
	return hbox

func _flat_style(color: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new(); s.bg_color = color; return s

## Estilo del botón Start — el más dramático de la pantalla.
## Fondo degradado dorado con borde brillante y esquinas redondeadas.
func _style_start_button(btn: Button) -> void:
	# Normal: dorado DB con borde naranja
	var normal := StyleBoxFlat.new()
	normal.bg_color                   = C_ACCENT
	normal.border_color               = C_POWER_MID
	normal.border_width_top           = 0
	normal.border_width_bottom        = 3
	normal.border_width_left          = 0
	normal.border_width_right         = 0
	normal.corner_radius_top_left     = 8
	normal.corner_radius_top_right    = 8
	normal.corner_radius_bottom_left  = 8
	normal.corner_radius_bottom_right = 8
	normal.content_margin_top         = 14
	normal.content_margin_bottom      = 14
	btn.add_theme_stylebox_override("normal", normal)

	# Hover: más brillante
	var hover := StyleBoxFlat.new()
	hover.bg_color                   = Color(C_ACCENT.r + 0.08, C_ACCENT.g + 0.04, C_ACCENT.b)
	hover.border_color               = C_POWER_HIGH
	hover.border_width_bottom        = 4
	hover.corner_radius_top_left     = 8; hover.corner_radius_top_right    = 8
	hover.corner_radius_bottom_left  = 8; hover.corner_radius_bottom_right = 8
	hover.content_margin_top         = 14; hover.content_margin_bottom      = 14
	btn.add_theme_stylebox_override("hover", hover)

	# Pressed: se hunde
	var pressed := StyleBoxFlat.new()
	pressed.bg_color                   = Color(C_ACCENT.r - 0.12, C_ACCENT.g - 0.06, C_ACCENT.b)
	pressed.corner_radius_top_left     = 8; pressed.corner_radius_top_right    = 8
	pressed.corner_radius_bottom_left  = 8; pressed.corner_radius_bottom_right = 8
	pressed.content_margin_top         = 16; pressed.content_margin_bottom      = 12
	btn.add_theme_stylebox_override("pressed", pressed)

	# Disabled: apagado
	var disabled := StyleBoxFlat.new()
	disabled.bg_color                   = Color(0.25, 0.23, 0.15)
	disabled.border_color               = Color(0.35, 0.33, 0.20)
	disabled.border_width_bottom        = 2
	disabled.corner_radius_top_left     = 8; disabled.corner_radius_top_right    = 8
	disabled.corner_radius_bottom_left  = 8; disabled.corner_radius_bottom_right = 8
	disabled.content_margin_top         = 14; disabled.content_margin_bottom      = 14
	btn.add_theme_stylebox_override("disabled", disabled)

	btn.add_theme_color_override("font_color",          C_BG)
	btn.add_theme_color_override("font_hover_color",    C_BG)
	btn.add_theme_color_override("font_pressed_color",  C_BG)
	btn.add_theme_color_override("font_disabled_color", Color(0.5, 0.48, 0.35))

## Estilo para los botones de control de stats (+ y −).
## Color tintado según el tipo: rojo para −, amarillo para +.
func _style_control_button(btn: Button, accent_color: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color                   = accent_color.lerp(C_BG, 0.80)
	normal.border_color               = accent_color.lerp(C_BG, 0.50)
	normal.border_width_bottom        = 2
	normal.corner_radius_top_left     = 6
	normal.corner_radius_top_right    = 6
	normal.corner_radius_bottom_left  = 6
	normal.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("normal", normal)

	var hover := StyleBoxFlat.new()
	hover.bg_color                   = accent_color.lerp(C_BG, 0.60)
	hover.border_color               = accent_color
	hover.border_width_bottom        = 2
	hover.corner_radius_top_left     = 6; hover.corner_radius_top_right    = 6
	hover.corner_radius_bottom_left  = 6; hover.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("hover", hover)

	var pressed := StyleBoxFlat.new()
	pressed.bg_color                   = accent_color.lerp(C_BG, 0.40)
	pressed.corner_radius_top_left     = 6; pressed.corner_radius_top_right    = 6
	pressed.corner_radius_bottom_left  = 6; pressed.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("pressed", pressed)

	btn.add_theme_color_override("font_color",       accent_color.lerp(C_TEXT, 0.6))
	btn.add_theme_color_override("font_hover_color", accent_color.lerp(Color.WHITE, 0.3))

## Estilo genérico para botones secundarios.
func _style_accent(btn: Button) -> void:
	var colors: Array[Color] = [
		C_ACCENT,
		Color(C_ACCENT.r + 0.08, C_ACCENT.g, C_ACCENT.b),
		Color(C_ACCENT.r - 0.1,  C_ACCENT.g - 0.05, C_ACCENT.b),
	]
	var states: Array[String] = ["normal", "hover", "pressed"]
	for i: int in states.size():
		var s := StyleBoxFlat.new()
		s.bg_color                   = colors[i]
		s.corner_radius_top_left     = 4; s.corner_radius_top_right    = 4
		s.corner_radius_bottom_left  = 4; s.corner_radius_bottom_right = 4
		s.content_margin_top = 12;  s.content_margin_bottom = 12
		btn.add_theme_stylebox_override(states[i], s)
	btn.add_theme_color_override("font_color",         C_BG)
	btn.add_theme_color_override("font_hover_color",   C_BG)
	btn.add_theme_color_override("font_pressed_color", C_BG)

func _ui_divider() -> Control:
	var row := HBoxContainer.new()
	row.add_child(_spacer_h(24))
	var sep := HSeparator.new()
	sep.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sep.add_theme_color_override("color", C_PANEL_ALT)
	row.add_child(sep)
	row.add_child(_spacer_h(24))
	return row

func _spacer_h(w: int) -> Control:
	var s := Control.new(); s.custom_minimum_size.x = w; return s

func _spacer_v(h: int) -> Control:
	var s := Control.new(); s.custom_minimum_size.y = h; return s

func _spacer_expand() -> Control:
	var s := Control.new(); s.size_flags_horizontal = Control.SIZE_EXPAND_FILL; return s
