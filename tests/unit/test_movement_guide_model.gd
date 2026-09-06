extends FluxTestSuite


const MovementGuideModelScript = preload("res://src/presentation/movement_guide_model.gd")


func run() -> int:
	var preferences := PlayerPreferences.new()
	var rows: Array[Dictionary] = MovementGuideModelScript.entries(preferences)
	equal(rows.size(), 16, "guide covers sixteen active movement techniques, not retired vault adapters")
	var ids: Dictionary = {}
	for row: Dictionary in rows:
		var id := String(row.get("id", ""))
		check(not id.is_empty() and not ids.has(id), "guide IDs are stable and unique")
		ids[id] = true
		check(String(row.get("category", "")) in ["travel", "escape", "expression"], "%s belongs to a learning group" % id)
		for key: String in ["title", "binding", "execution", "timing_note", "counter"]:
			check(not String(row.get(key, "")).is_empty(), "%s exposes %s" % [id, key])
		check(not String(row["execution"]).contains("{"), "%s execution resolves actual bindings" % id)
		check(not String(row["timing_note"]).contains("{"), "%s timing notes resolve actual bindings" % id)
		check(int(row.get("cost_milli", -1)) >= 0, "%s has an honest non-negative base cost" % id)
		var lines: Array[String] = MovementGuideModelScript.detail_lines(row)
		check(lines.size() >= 5 and lines.size() <= 6, "%s details fit a bounded bullet list before wrapping" % id)
		for line: String in lines:
			check(line.begins_with("- "), "%s detail is a structured readable bullet" % id)
	check(not ids.has("vault") and not ids.has("superglide"), "retired movement IDs cannot appear as usable skills")
	equal(int(MovementGuideModelScript.entry_by_id("jump")["cost_milli"]), MovementTuning.HOP_COST, "jump cost derives from runtime tuning")
	equal(int(MovementGuideModelScript.entry_by_id("jump")["sustain_milli_per_second"]), MovementTuning.JUMP_SUSTAIN_DRAIN_PER_SECOND, "held jump cost derives from runtime tuning")
	equal(int(MovementGuideModelScript.entry_by_id("slide")["duration_ms"]), MovementTuning.SLIDE_DURATION_MS, "slide duration derives from runtime tuning")
	equal(int(MovementGuideModelScript.entry_by_id("slide")["protection_ms"]), MovementTuning.SLIDE_INVULNERABILITY_MS, "slide protection cannot silently equal total duration")
	equal(int(MovementGuideModelScript.entry_by_id("roll")["protection_ms"]), MovementTuning.ROLL_INVULNERABILITY_MS, "roll protection derives from runtime tuning")
	equal(int(MovementGuideModelScript.entry_by_id("air_dodge")["protection_ms"]), MovementTuning.AIR_DODGE_INVULNERABILITY_MS, "air dodge protection derives from runtime tuning")
	equal(int(MovementGuideModelScript.entry_by_id("wave_dash")["protection_ms"]), 0, "wavedash landing does not promise new immunity")
	equal(int(MovementGuideModelScript.entry_by_id("slide_brake")["cost_milli"]), 0, "slide brake is described as a free cancel")
	equal(MovementGuideModelScript.category_for("jump"), "travel", "jump is taught as core travel")
	equal(MovementGuideModelScript.category_for("roll"), "escape", "roll belongs to defensive escape")
	equal(MovementGuideModelScript.category_for("wave_dash"), "expression", "wavedash belongs to expressive combinations")
	check(String(MovementGuideModelScript.entry_by_id("move")["execution"]).contains("release to coast"), "free aerial momentum is explained explicitly")
	check(String(MovementGuideModelScript.entry_by_id("fast_fall")["execution"]).contains("release and press again"), "carried Slide cannot be mistaken for fresh fast-fall intent")
	check(String(MovementGuideModelScript.entry_by_id("wave_dash")["timing_note"]).contains("No turn-angle requirement"), "guide cannot retain retired angle-gated wavedash instructions")
	check(String(MovementGuideModelScript.entry_by_id("slide_brake")["timing_note"]).contains("wheel notches"), "guide explains wheel gesture safety versus deliberate braking")
	equal(int(MovementGuideModelScript.entry_by_id("jump")["commitment_ms"]), MovementTuning.HOP_COMMITMENT_MS, "jump commitment derives from movement authority")
	equal(int(MovementGuideModelScript.entry_by_id("air_dodge")["commitment_ms"]), MovementTuning.AIR_DODGE_COMMITMENT_MS, "air-dodge commitment is not confused with total duration")
	equal(int(MovementGuideModelScript.entry_by_id("slide_brake")["commitment_ms"]), 0, "free slide brake cannot promise a fresh paid commitment")
	check(MovementGuideModelScript.entry_by_id("missing").is_empty(), "unknown technique fails closed")
	check(MovementGuideModelScript.detail_lines({}).is_empty(), "missing technique cannot fabricate details")
	preferences.keyboard_bindings[&"jump"] = KEY_J
	var rebound: Dictionary = MovementGuideModelScript.entry_by_id("jump", preferences)
	equal(String(rebound["binding"]), "J", "guide follows rebound keyboard actions")
	check(String(rebound["execution"]).contains("Tap J"), "execution instructions follow rebinding too")
	preferences.keyboard_bindings[&"jump"] = 0
	equal(String(MovementGuideModelScript.entry_by_id("jump", preferences)["binding"]), "UNBOUND", "missing keyboard action is explicit, not a false default")
	var controller_rows: Array[Dictionary] = MovementGuideModelScript.entries(preferences, ControlBindingEditor.DEVICE_CONTROLLER)
	equal(controller_rows.size(), rows.size(), "controller gets the same complete movement curriculum")
	var state := PlayerState.new(1)
	state.stamina_maximum = 123_000
	state.stamina_recovery_per_second = 31_000
	state.movement_chain_count = 3
	state.movement_chain_reset_ticks = 10
	var summary: Array[String] = MovementGuideModelScript.summary_lines(state)
	check(summary[0].contains("123 maximum") and summary[0].contains("31/s"), "summary uses the selected champion's real Stamina profile")
	check(summary[1].contains("Next premium: 30%"), "summary explains the actual next chain premium")
	check(summary[2].contains("%d ms" % MovementTuning.INPUT_BUFFER_MS) and summary[2].contains("newest"), "buffer explanation derives its timing and explicit intent replacement rule")
	check(" ".join(summary).contains("%d ms without another notch" % InputRouter.WHEEL_GESTURE_QUIET_MS), "wheel instruction follows actual quiet-gap tuning")
	state.movement_chain_reset_ticks = 0
	check(MovementGuideModelScript.summary_lines(state)[1].contains("Next premium: 0%"), "expired movement chain cannot remain expensive in the guide")
	return finish("movement-guide-model")
