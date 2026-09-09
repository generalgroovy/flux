class_name MovementGuideModel
extends RefCounted


# Read-only guide data. Rules and costs remain owned by MovementSystem/Tuning;
# the overlay may paginate/wrap these rows without inventing gameplay state.
static func entries(preferences: PlayerPreferences = null, device: int = ControlBindingEditor.DEVICE_KEYBOARD) -> Array[Dictionary]:
	var current := preferences if preferences != null else PlayerPreferences.new()
	var editor := ControlBindingEditor.new()
	var bindings: Dictionary = {}
	for action: StringName in [&"jump", &"slide", &"sprint", &"evade", &"technique", &"move_up", &"move_left", &"move_down", &"move_right", &"practice_trace", &"practice_retry"]:
		var label := editor.binding_label(action, device, current)
		bindings[String(action)] = "UNBOUND" if label == "—" else label
	bindings["move"] = "%s / %s / %s / %s" % [bindings["move_up"], bindings["move_left"], bindings["move_down"], bindings["move_right"]]
	var rows: Array[Dictionary] = [
		_row("move", "Move / brake", "move", 0,
			"Hold {move}; combine directions for diagonals. On the ground release to brake. In air release to coast, steer to turn, or press against travel to brake.",
			"Ordinary movement stays available at zero Stamina. Aim remains independent of travel. Toggle practice trace with {practice_trace}; restart it with {practice_retry} to compare speed, Stamina and your next chain premium.",
			{}, "No protection; read and leave incoming projectile lanes."),
		_row("sprint", "Sprint", "sprint", 0,
			"Hold {sprint} while moving. Release it to stop paying the sprint drain.",
			"Drains Stamina only while moving; empty reserves return you to ordinary movement.",
			{"sustain_milli_per_second": MovementTuning.SPRINT_DRAIN_PER_SECOND}, "No protection; predict the longer travel lane."),
		_row("jump", "Jump / held jump", "jump", MovementTuning.HOP_COST,
			"Tap {jump} to lift; hold while rising for a higher paid jump. Momentum carries through takeoff; steer, coast or counter-steer in air. Jump alone adds no forward launch.",
			"Release caps remaining upward speed at %s units/s, not remaining flight time. Full hold reaches about %s units high from ground; only ascent pays sustain. Landing refreshes jump readiness." % [_units(MovementTuning.SHORT_HOP_VERTICAL_SPEED), _units(full_jump_height())],
			{"duration_ms": MovementTuning.HOP_DURATION_MS, "duration_note": "nominal full jump from ground", "protection_ms": MovementTuning.JUMP_INVULNERABILITY_MS, "sustain_milli_per_second": MovementTuning.JUMP_SUSTAIN_DRAIN_PER_SECOND},
			"Above %s units, low ground projectiles pass beneath you. This does not clear beams, areas or explosions; the later airborne arc has no general immunity." % _units(MovementTuning.GROUND_PROJECTILE_CLEARANCE_HEIGHT)),
		_row("double_jump", "Float / held air jump", "jump", MovementTuning.FLOAT_COST,
			"While airborne, release and press {jump} again, then hold. Float holds your current height; steer, coast or brake freely. Release to fall.",
			"One Float per airtime, independent of wall jump: wall jump -> Float -> air dodge is legal. Small %.1fs, middle %.1fs, large %.1fs maximum. Release, expiry, exhaustion or another movement action ends it." % [float(MovementTuning.FLOAT_SMALL_DURATION_MS) / 1000.0, float(MovementTuning.FLOAT_MIDDLE_DURATION_MS) / 1000.0, float(MovementTuning.FLOAT_LARGE_DURATION_MS) / 1000.0],
			{"sustain_milli_per_second": MovementTuning.FLOAT_DRAIN_PER_SECOND, "protection_note": "Protected only while Float is active and paid; ending Float ends its protection immediately."},
			"Continuous protection costs heavy Stamina. Wall contact does not refill Float. Predict your exit before release; there is no second upward launch."),
		_row("slide", "Slide / held slide", "slide", MovementTuning.SLIDE_COST,
			"Build ground speed, then press {slide}. Hold for the longer slide; release for the shorter remainder.",
			"Needs at least %s world units/s. Release limits the remainder to %d ms; holding never extends protection." % [_units(MovementTuning.SLIDE_ENTRY_SPEED), MovementTuning.SLIDE_MINIMUM_MS],
			{"duration_ms": MovementTuning.SLIDE_DURATION_MS, "cooldown_ms": MovementTuning.SLIDE_COOLDOWN_MS, "protection_ms": MovementTuning.SLIDE_INVULNERABILITY_MS, "sustain_milli_per_second": MovementTuning.SLIDE_SUSTAIN_DRAIN_PER_SECOND},
			"Only the opening is protected. The committed lane becomes punishable."),
		_row("slide_brake", "Slide brake", "slide", 0,
			"Release and press {slide} again during the slide to stop immediately.",
			"Free cancellation; does not refund cost or cooldown. Repeated wheel notches in one gesture do not count as deliberate second presses.", {},
			"Braking removes slide protection; choose a safe stopping point."),
		_row("slide_jump", "Slide jump", "jump", MovementTuning.SLIDE_JUMP_COST,
			"While sliding, press {jump} after the minimum commitment; choose the outgoing direction.",
			"Available after %d ms of accepted slide time, even while {slide} is held. Retains earned speed within the global cap." % MovementTuning.SLIDE_JUMP_MINIMUM_COMMITMENT_MS,
			{"duration_ms": MovementTuning.HOP_DURATION_MS, "duration_note": "nominal full jump from ground", "protection_ms": MovementTuning.JUMP_INVULNERABILITY_MS, "sustain_milli_per_second": MovementTuning.JUMP_SUSTAIN_DRAIN_PER_SECOND},
			"Costs another paid action and chain premium; later flight is vulnerable."),
		_row("roll", "Ground roll", "evade", MovementTuning.ROLL_COST,
			"On the ground, press {evade} with a direction. Use a neutral direction only when your facing is the intended escape.",
			"Ground roll has its own cooldown. Air dodge uses a separate once-per-airtime opportunity.",
			{"duration_ms": MovementTuning.ROLL_DURATION_MS, "cooldown_ms": MovementTuning.ROLL_COOLDOWN_MS, "protection_ms": MovementTuning.ROLL_INVULNERABILITY_MS},
			"The end of the roll is vulnerable; do not roll into the next projectile."),
		_row("air_dodge", "Air dodge", "evade", MovementTuning.AIR_DODGE_COST,
			"While airborne or wallrunning, press {evade} and choose a direction.",
			"One air dodge per airtime. The directional burst decays, preserving height and vertical motion, then returns to steerable flight. Landing refills it for your next jump without a cooldown wait; wall contact does not.",
			{"duration_ms": MovementTuning.AIR_DODGE_DURATION_MS, "protection_ms": MovementTuning.AIR_DODGE_INVULNERABILITY_MS},
			"Landing ends dodge protection immediately. The later burst and descent are vulnerable; watch the destination."),
		_row("wave_dash", "Wavedash", "evade", MovementTuning.AIR_DODGE_COST,
			"Near landing, press {evade} with the direction you want to travel; the dodge resolves into a low landing dash.",
			"While descending, accept the dodge within an estimated %d ms of landing. No turn-angle requirement or extra cost; it uses your one air dodge." % MovementTuning.WAVE_DASH_INPUT_WINDOW_MS,
			{"duration_ms": MovementTuning.WAVE_DASH_DURATION_MS},
			"The landing dash grants no new protection; an early input gives an ordinary air dodge."),
		_row("air_turn", "Air turn", "technique", MovementTuning.AIR_REDIRECT_COST,
			"During a jump, press {technique} with a changed direction for a stronger immediate turn. At a wall, along-wall input chooses a valid wallrun; an unavailable wallrun can fall back to a legal air turn.",
			"One redirect per jump stage. Ordinary air steering is free; this purchases a sharper correction. Continuing straight ahead does not spend a redirect.", {},
			"No new protection; predict the redirected path."),
		_row("wall_run", "Wallrun / detach", "technique", MovementTuning.WALL_SKIM_COST,
			"Touch a runnable wall, hold along its face and press {technique}. Press it again, steer away or reach the wall end to detach.",
			"Works from ground or air. Detaching returns to finite steerable descent, not a new protected jump. Wall contact does not refill the air dodge or Float. Same-surface lockout: %d ms." % MovementTuning.WALL_SKIM_SAME_SURFACE_LOCKOUT_MS,
			{"duration_ms": MovementTuning.WALL_SKIM_DURATION_MS, "cooldown_ms": MovementTuning.WALL_SKIM_COOLDOWN_MS},
			"No protection. Follow the exposed wall lane or threaten its exit."),
		_row("wall_jump", "Wall jump", "jump", MovementTuning.HOP_COST,
			"Press {jump} near a remembered wall contact. In the first air jump, steer away from that wall when pressing.",
			"Contact memory lasts %d ms; same-wall lockout %d ms. Wall jump leaves Float and the one air dodge available if not already spent." % [MovementTuning.WALL_MEMORY_MS, MovementTuning.SAME_WALL_LOCKOUT_MS],
			{"duration_ms": MovementTuning.HOP_DURATION_MS, "duration_note": "nominal lift cycle; landing depends on height", "protection_ms": MovementTuning.JUMP_INVULNERABILITY_MS, "sustain_milli_per_second": MovementTuning.JUMP_SUSTAIN_DRAIN_PER_SECOND},
			"Cannot climb indefinitely; anticipate the outward path and later vulnerable landing."),
		_row("fast_fall", "Fast fall", "slide", 0,
			"After takeoff, press {slide} afresh to commit to an earlier landing. If you were already holding Slide before jumping, release and press again first.",
			"An accepted wheel-down gesture also commits without a hold. Sets downward speed to at least %s units/s; ordinary gravity continues until real ground contact." % _units(MovementTuning.AIR_FAST_FALL_SPEED),
			{}, "No new protection; land earlier only if the floor lane is safe."),
		_row("landing_cut", "Landing reversal", "move", 0,
			"Press against your current travel immediately after landing for a firmer reversal.",
			"Landing window: %d ms; multiplies counter-steer acceleration by %.2f, not top speed." % [MovementTuning.LANDING_WINDOW_MS, float(MovementTuning.LANDING_CUT_MULTIPLIER) / 1000.0],
			{}, "Free braking response, not an attack cancel or invulnerability window."),
		_row("impact_tech", "Impact recovery tech", "technique", MovementTuning.IMPACT_RECOVERY_TECH_COST,
			"After an external launch, press {technique} near landing or during the recovery brace, with your exit direction.",
			"Cancels the %d ms recovery brace when legal. Holding direction during launch also bends its path for free." % MovementTuning.IMPACT_RECOVERY_DURATION_MS,
			{}, "No new protection. Without enough Stamina, expect the full recovery brace."),
	]
	for row: Dictionary in rows:
		row["category"] = category_for(String(row["id"]))
		row["binding"] = bindings[String(row["action"])]
		for key: String in ["execution", "timing_note"]:
			var value := String(row[key])
			for action: String in bindings:
				value = value.replace("{%s}" % action, String(bindings[action]))
			row[key] = value
	return rows


static func entry_by_id(id: String, preferences: PlayerPreferences = null, device: int = ControlBindingEditor.DEVICE_KEYBOARD) -> Dictionary:
	for row: Dictionary in entries(preferences, device):
		if String(row["id"]) == id:
			return row
	return {}


static func detail_lines(row: Dictionary) -> Array[String]:
	if row.is_empty():
		return []
	var result: Array[String] = ["- %s / Execute: %s" % [String(row.get("category", "travel")).capitalize(), String(row.get("execution", ""))]]
	var cost := _units(int(row.get("cost_milli", 0))) + " Stamina base"
	var sustain := int(row.get("sustain_milli_per_second", 0))
	if sustain > 0:
		cost += "; +%s/s while sustaining" % _units(sustain)
	result.append("- Cost: " + cost + ".")
	var timing: Array[String] = []
	if int(row.get("commitment_ms", 0)) > 0:
		timing.append("%d ms initial commitment" % int(row["commitment_ms"]))
	if int(row.get("duration_ms", 0)) > 0:
		var duration_note := String(row.get("duration_note", ""))
		timing.append("%d ms %s" % [int(row["duration_ms"]), duration_note] if not duration_note.is_empty() else "up to %d ms action" % int(row["duration_ms"]))
	if int(row.get("cooldown_ms", 0)) > 0:
		timing.append("%d ms cooldown" % int(row["cooldown_ms"]))
	if not timing.is_empty():
		result.append("- Timing: " + "; ".join(timing) + ".")
	result.append("- Rule: " + String(row.get("timing_note", "")))
	var protection := int(row.get("protection_ms", 0))
	var protection_note := String(row.get("protection_note", ""))
	if not protection_note.is_empty():
		result.append("- Protection: " + protection_note)
	else:
		result.append("- Protection: opening %d ms only; the rest is vulnerable." % protection if protection > 0 else "- Protection: no new immunity from this technique.")
	result.append("- Counter / caution: " + String(row.get("counter", "")))
	return result


static func compact_cells(row: Dictionary) -> Array[String]:
	if row.is_empty():
		return []
	var protection := "%d ms opening" % int(row.protection_ms) if int(row.protection_ms) > 0 else "None added"
	if not String(row.get("protection_note", "")).is_empty():
		protection = "While held + paid"
	var cooldown := "%d ms" % int(row.cooldown_ms) if int(row.cooldown_ms) > 0 else "See rule"
	return [String(row.title), String(row.binding), _units(int(row.cost_milli)), _units(int(row.sustain_milli_per_second)) + "/s", protection, cooldown]


static func summary_lines(state: PlayerState = null) -> Array[String]:
	var maximum := state.stamina_maximum if state != null else MovementTuning.STAMINA_MAXIMUM
	var recovery := state.stamina_recovery_per_second if state != null else MovementTuning.STAMINA_RECOVERY_PER_SECOND
	var steps := mini(state.movement_chain_count, MovementTuning.MOVEMENT_CHAIN_MAXIMUM_STEPS) if state != null and state.movement_chain_reset_ticks > 0 else 0
	var step_percent := roundi(float(MovementTuning.MOVEMENT_CHAIN_COST_STEP_RATIO) / 10.0)
	return [
		"Stamina %s maximum; base recovery %s/s, rising to %s/s after its %d ms spend delay when ordinary movement allows refill." % [_units(maximum), _units(recovery), _units(recovery * PlayerTuning.RESOURCE_RECOVERY_MAXIMUM_RATIO / 1000), MovementTuning.STAMINA_RECOVERY_DELAY_MS],
		"Costs shown are base. Each paid continuation adds %d%%, capped at %d%%; resets after %d ms. Next premium: %d%%." % [step_percent, step_percent * MovementTuning.MOVEMENT_CHAIN_MAXIMUM_STEPS, MovementTuning.MOVEMENT_CHAIN_RESET_MS, steps * step_percent],
		"The newest movement tap replaces older intent for up to %d ms; legal state, cooldown and Stamina are checked again. One paid action starts per tick; a refused move spends nothing." % MovementTuning.INPUT_BUFFER_MS,
		"For simultaneous movement presses, priority is Evade, then Jump, Slide, Technique. Initial commitment is the short interval before another action can replace the current one, not a new immunity window.",
		"Flux pays for spells; movement uses Stamina. Ordinary held jump and slide never extend opening immunity. Float is the explicit exception: protected only while held, paid and active.",
		"Learn Travel first: move, sprint, jump, slide. Then Escape: roll, air dodge, fast fall, impact recovery. Expression adds Float, wall routes, turns, wavedashes and landing reversals.",
		"Wheel movement is a short pulse, not a hold. Same-direction notches group until %d ms without another notch; use buttons for precise second presses or sustained height and distance." % InputRouter.WHEEL_GESTURE_QUIET_MS,
		"Hold drain and sprint cost are additional to base cost; the chain premium applies to paid starts. Float consumes Stamina continuously for its protected hold, not a fixed immunity window.",
		"Unused Flux and Stamina independently ramp recovery from 1x to %.0fx over %.1f seconds after their own delay. Any positive spend resets only that resource's ramp; failed and free actions do not. Health recovery is unchanged." % [float(PlayerTuning.RESOURCE_RECOVERY_MAXIMUM_RATIO) / 1000.0, float(PlayerTuning.RESOURCE_RECOVERY_RAMP_MS) / 1000.0],
		"Unbound action? Assign it at the Controls Lectern. Vault and crest-superglide are not active techniques.",
	]


static func category_for(id: String) -> String:
	if id in ["move", "sprint", "jump", "slide"]:
		return "travel"
	if id in ["roll", "air_dodge", "fast_fall", "impact_tech"]:
		return "escape"
	return "expression"


static func _row(id: String, title: String, action: String, cost: int, execution: String, timing_note: String, timing: Dictionary, counter: String) -> Dictionary:
	var result := {"id": id, "title": title, "action": action, "cost_milli": cost, "execution": execution, "timing_note": timing_note, "counter": counter, "duration_ms": 0, "cooldown_ms": 0, "protection_ms": 0, "sustain_milli_per_second": 0, "commitment_ms": commitment_ms_for(id)}
	result.merge(timing, true)
	return result


static func commitment_ms_for(id: String) -> int:
	match id:
		"jump", "double_jump", "slide_jump", "wall_jump", "air_turn", "impact_tech":
			return MovementTuning.HOP_COMMITMENT_MS
		"slide":
			return MovementTuning.SLIDE_JUMP_MINIMUM_COMMITMENT_MS
		"roll":
			return MovementTuning.ROLL_COMMITMENT_MS
		"air_dodge":
			return MovementTuning.AIR_DODGE_COMMITMENT_MS
		"wall_run":
			return MovementTuning.WALL_RUN_COMMITMENT_MS
		"wave_dash":
			return MovementTuning.WAVE_DASH_COMMITMENT_MS
	return 0


static func _units(value: int) -> String:
	return ("%.1f" % (float(value) / 1000.0)).trim_suffix(".0")


static func full_jump_height() -> int:
	# A guide estimate, not an alternative simulation; fixed ticks can differ slightly.
	return roundi(float(MovementTuning.JUMP_VERTICAL_SPEED) * float(MovementTuning.JUMP_VERTICAL_SPEED) / (2.0 * float(MovementTuning.VERTICAL_GRAVITY)))
