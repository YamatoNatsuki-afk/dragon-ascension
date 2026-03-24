# debug/ProgressTracker.gd
# RefCounted — sin nodo, sin escena, sin autoload.
# Responsabilidad única: acumular deltas de stats y XP entre checkpoints,
# y producir reportes legibles.
#
# Diseñado para ser reutilizable: la UI real puede instanciarlo igual que
# DebugDayLoop, conectarlo al EventBus, y mostrar los mismos datos.
class_name ProgressTracker
extends RefCounted

# Cada cuántos días emitir un reporte de milestone
var milestone_every: int = 5

# Acumuladores del período actual (se resetean en cada milestone)
var _period_stat_gains: Dictionary = {}   # StringName → float acumulado
var _period_xp: float = 0.0
var _period_start_day: int = 1
var _period_start_stats: Dictionary = {}  # Snapshot al inicio del período

# Histórico completo (nunca se resetea)
var _total_stat_gains: Dictionary = {}
var _total_xp: float = 0.0
var _days_tracked: int = 0

# Referencia para leer stats actuales (solo lectura)
var _character_data: CharacterData

# ─────────────────────────────────────────────
# Inicialización
# ─────────────────────────────────────────────

func initialize(data: CharacterData) -> void:
	_character_data  = data
	_period_start_day = data.current_day
	_snapshot_stats()
	EventBus.day_action_resolved.connect(_on_action_resolved)
	EventBus.day_ended.connect(_on_day_ended)

func _snapshot_stats() -> void:
	_period_start_stats = _character_data.base_stats.duplicate()

# ─────────────────────────────────────────────
# Acumulación
# ─────────────────────────────────────────────

func _on_action_resolved(_action: DayAction, result: DayActionResult) -> void:
	for stat_id: StringName in result.stat_changes.keys():
		var delta: float = result.stat_changes[stat_id]
		_period_stat_gains[stat_id] = _period_stat_gains.get(stat_id, 0.0) + delta
		_total_stat_gains[stat_id]  = _total_stat_gains.get(stat_id, 0.0) + delta

	_period_xp += result.xp_gained
	_total_xp  += result.xp_gained

func _on_day_ended(day_number: int, _result: DayActionResult) -> void:
	_days_tracked += 1

	if _days_tracked % milestone_every == 0:
		print_milestone_report(day_number)
		_reset_period(day_number + 1)

# ─────────────────────────────────────────────
# Reportes
# ─────────────────────────────────────────────

## Reporte de milestone — cada N días.
func print_milestone_report(day_number: int) -> void:
	var days_in_period := day_number - _period_start_day + 1
	print("\n")
	print("  ┌─────────────────────────────────────────┐")
	print("  │  REPORTE — Días %d a %d" % [_period_start_day, day_number] \
		+ " ".repeat(max(0, 24 - str(_period_start_day).length() - str(day_number).length())) + "│")
	print("  ├─────────────────────────────────────────┤")

	# Stats ganados en el período
	var has_changes := false
	for stat_id: StringName in _period_stat_gains.keys():
		var delta: float = _period_stat_gains[stat_id]
		if abs(delta) < 0.01:
			continue
		has_changes = true
		var sign    := "+" if delta >= 0.0 else ""
		var current := _character_data.base_stats.get(stat_id, 0.0)
		var start   := _period_start_stats.get(stat_id, current)
		var trend   := _trend_arrow(delta)
		print("  │  %-12s %s%-5.1f  (total: %.1f) %s" % [
			stat_id, sign, delta, current, trend
		] + " ".repeat(max(0, 3)) + "│")

	if not has_changes:
		print("  │  (sin cambios de stats en este período)  │")

	print("  ├─────────────────────────────────────────┤")

	# XP del período
	var xp_rate := _period_xp / max(1, days_in_period)
	print("  │  XP ganada:   %6.1f  (%.1f / día)" % [_period_xp, xp_rate] \
		+ " " * max(0, 9 - str(int(_period_xp)).length()) + "│")
	print("  │  XP total:    %6.1f" % _total_xp \
		+ " " * 18 + "│")

	# Proyección al día 100
	if _days_tracked > 0 and _total_xp > 0.0:
		var xp_per_day_avg := _total_xp / _days_tracked
		var days_left      := 100 - day_number
		var projected_xp   := _total_xp + xp_per_day_avg * days_left
		print("  │  Proyección D100: ~%.0f XP" % projected_xp \
			+ " " * max(0, 12 - str(int(projected_xp)).length()) + "│")

	print("  └─────────────────────────────────────────┘")

## Reporte final completo — llamado al terminar la simulación.
func print_final_report(days_completed: int) -> void:
	print("\n")
	print("  ╔═════════════════════════════════════════╗")
	print("  ║  RESUMEN FINAL — %d días" % days_completed \
		+ " " * max(0, 22 - str(days_completed).length()) + "║")
	print("  ╠═════════════════════════════════════════╣")
	print("  ║  GANANCIAS TOTALES DE STATS:             ║")

	for stat_id: StringName in _total_stat_gains.keys():
		var delta: float = _total_stat_gains[stat_id]
		if abs(delta) < 0.01:
			continue
		var sign    := "+" if delta >= 0.0 else ""
		var current := _character_data.base_stats.get(stat_id, 0.0)
		print("  ║    %-12s %s%-6.1f → total %.1f" % [
			stat_id, sign, delta, current
		] + " " * max(0, 3) + "║")

	var avg_xp := _total_xp / max(1, days_completed)
	print("  ╠═════════════════════════════════════════╣")
	print("  ║  XP total:    %7.1f  (%.1f / día)" % [_total_xp, avg_xp] \
		+ " " * max(0, 6 - str(int(_total_xp)).length()) + "║")
	print("  ╚═════════════════════════════════════════╝")

# ─────────────────────────────────────────────
# Utilidades internas
# ─────────────────────────────────────────────

func _reset_period(next_start_day: int) -> void:
	_period_stat_gains.clear()
	_period_xp         = 0.0
	_period_start_day  = next_start_day
	_snapshot_stats()

func _trend_arrow(delta: float) -> String:
	if delta > 3.0:  return "▲▲"
	if delta > 0.5:  return "▲"
	if delta > -0.5: return "─"
	if delta > -3.0: return "▼"
	return "▼▼"

# ─────────────────────────────────────────────
# Meta-progreso (añadido en Fase 4)
# ─────────────────────────────────────────────

var _last_build_id: StringName = &""
var _checkpoint_results: Array[CheckpointResult] = []

## Llama esto en initialize() para activar el seguimiento de meta-progreso.
func enable_meta_tracking() -> void:
	EventBus.checkpoint_reached.connect(_on_checkpoint_reached)
	EventBus.build_identity_changed.connect(_on_build_identity_changed)

func _on_checkpoint_reached(result: CheckpointResult) -> void:
	_checkpoint_results.append(result)
	print_checkpoint_report(result)

func _on_build_identity_changed(prev_id: StringName, new_profile: BuildProfile) -> void:
	print("\n  [BUILD] Identidad cambiada: %s → %s" % [prev_id, new_profile.display_name])
	_last_build_id = new_profile.id

func print_checkpoint_report(result: CheckpointResult) -> void:
	var cp    := result.checkpoint
	var grade := PerformanceEvaluator.grade_label(result.grade)
	var build := result.build_identity.display_name if result.build_identity else "Desconocido"

	print("\n")
	print("  ╔══════════════════════════════════════════════╗")
	print("  ║  CHECKPOINT — %s" % cp.display_name \
		+ " ".repeat(max(0, 32 - cp.display_name.length())) + "║")
	print("  ╠══════════════════════════════════════════════╣")
	print("  ║  Rendimiento:  %-29s║" % grade)
	print("  ║  Power score:  %-8.1f (esperado: %.1f)" % [
		result.power_score, result.expected_score
	] + " ".repeat(max(0, 7 - str(int(result.expected_score)).length())) + "║")
	print("  ║  Ratio:        %-6.0f%%" % (result.performance_ratio * 100.0) \
		+ " ".repeat(23) + "║")
	print("  ╠══════════════════════════════════════════════╣")
	print("  ║  Identidad:    %-29s║" % build)

	# Top 2 afinidades de build
	var scores: Array = result.all_build_scores
	for i in range(mini(2, scores.size())):
		var entry      : Dictionary  = scores[i]
		var p          : BuildProfile = entry.profile
		var s          : float        = entry.score
		var bar                       := _mini_bar(s, 1.0, 10)
		print("  ║    %-12s %s %.0f%%" % [p.display_name, bar, s * 100.0] \
			+ " ".repeat(max(0, 8)) + "║")

	print("  ╠══════════════════════════════════════════════╣")
	print("  ║  \"%s\"" % result.narrative_text \
		+ " ".repeat(max(0, 44 - result.narrative_text.length())) + "║")

	if not result.stat_delta.is_empty():
		print("  ╠══════════════════════════════════════════════╣")
		for stat_id: StringName in result.stat_delta.keys():
			var d: float = result.stat_delta[stat_id]
			var sign     := "+" if d >= 0.0 else ""
			print("  ║  Consecuencia: %-12s %s%.1f" % [stat_id, sign, d] \
				+ " ".repeat(max(0, 15)) + "║")

	print("  ╚══════════════════════════════════════════════╝")

func _mini_bar(value: float, max_v: float, width: int) -> String:
	var filled := clampi(int((value / max_v) * width), 0, width)
	return "[" + "█".repeat(filled) + "░".repeat(width - filled) + "]"
