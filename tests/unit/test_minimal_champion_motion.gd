extends FluxTestSuite


func run() -> int:
	_test_repository_motion()
	_test_complete_movement_mapping()
	_test_tick_rate_parity_and_reduced_motion()
	_test_locomotion_contact_phase()
	return finish("minimal-champion-motion")


func _test_repository_motion() -> void:
	var motion := MinimalChampionMotion.new()
	check(motion.load_from_file(), "minimal champion motion validates: %s" % motion.last_error)
	check(motion.content_hash.length() == 64, "minimal motion has a stable content hash")
	for profile_id: String in ["buoyant_keeper", "grounded_weaver", "iron_regent"]:
		check(motion.has_profile(profile_id), "%s is an editable motion profile" % profile_id)
		for motion_id: String in MinimalChampionMotion.REQUIRED_MOTIONS:
			var sample := motion.sample(profile_id, motion_id, 11.0)
			check(sample.offset.abs().x <= 4.0 and sample.offset.abs().y <= 4.0, "%s/%s stays within translation budget" % [profile_id, motion_id])
			equal(sample.scale, Vector2.ONE, "%s/%s cannot resize its body template" % [profile_id, motion_id])
	equal(motion.movement_accents.size(), MinimalChampionMotion.REQUIRED_ACCENTS.size(), "every declared movement-response family owns one bounded accent")
	equal(String(motion.accent_by_id("counter_strafe").get("kind", "")), "brake_ticks", "ordinary reversal owns an editable heel-plant accent")
	equal(String(motion.accent_by_id("impact_recovery").get("kind", "")), "recovery_brace", "impact recovery begins the reusable animation/environment slice with a readable brace accent")


func _test_complete_movement_mapping() -> void:
	var state := PlayerState.new()
	var expected := {
		PlayerState.MovementMode.IDLE: "idle",
		PlayerState.MovementMode.WALK: "walk",
		PlayerState.MovementMode.SPRINT: "sprint",
		PlayerState.MovementMode.HOP: "air",
		PlayerState.MovementMode.DOUBLE_JUMP: "air",
		PlayerState.MovementMode.SLIDE: "low",
		PlayerState.MovementMode.SLIDE_JUMP: "air",
		PlayerState.MovementMode.AIR_DODGE: "air",
		PlayerState.MovementMode.ROLL: "low",
		PlayerState.MovementMode.WAVE_DASH: "low",
		PlayerState.MovementMode.WALL_KICK: "air",
		PlayerState.MovementMode.VAULT: "air",
		PlayerState.MovementMode.SUPERGLIDE: "air",
		PlayerState.MovementMode.LAUNCHED: "hit",
		PlayerState.MovementMode.GRAPPLED: "hit",
		PlayerState.MovementMode.CHARGING: "cast",
		PlayerState.MovementMode.STUNNED: "hit",
		PlayerState.MovementMode.ROOTED: "idle",
		PlayerState.MovementMode.SLOWED: "walk",
		PlayerState.MovementMode.FAST_FALL: "air",
		PlayerState.MovementMode.WALL_SKIM: "low",
		PlayerState.MovementMode.IMPACT_RECOVERY: "hit",
	}
	for movement_mode: int in expected:
		state.movement_mode = movement_mode
		state.control_state = PlayerState.ControlState.FREE
		equal(MinimalChampionMotion.motion_id(state), expected[movement_mode], "%s owns a readable motion family" % PlayerState.MovementMode.keys()[movement_mode])
	state.movement_mode = PlayerState.MovementMode.IDLE
	state.pending_cast_wire_id = CombatTuning.PRIMARY_WIRE_ID
	equal(MinimalChampionMotion.motion_id(state), "cast", "authoritative startup state selects cast anticipation")


func _test_tick_rate_parity_and_reduced_motion() -> void:
	equal(MinimalChampionMotion.tick_at_visual_rate(120, 120), 60.0, "one canonical simulation second advances the 60 fps art clock once")
	equal(MinimalChampionMotion.tick_at_visual_rate(61, 120, 0.0), 30.5, "120 Hz half-ticks map exactly onto the art clock")
	var motion := MinimalChampionMotion.new()
	check(motion.load_from_file(), "motion loads for accessibility sample")
	var normal := motion.sample("buoyant_keeper", "sprint", 7.0, false)
	var reduced := motion.sample("buoyant_keeper", "sprint", 7.0, true)
	check(reduced.offset.length() < normal.offset.length(), "reduced motion damps translation")
	equal(normal.scale, Vector2.ONE, "ordinary motion keeps template scale invariant")
	equal(reduced.scale, Vector2.ONE, "reduced motion keeps template scale invariant")
	var state := PlayerState.new()
	var config := SimConfig.new(120)
	state.hop_mode = PlayerState.MovementMode.HOP
	state.hop_ticks = config.milliseconds_to_ticks(MovementTuning.HOP_DURATION_MS) / 2
	var elapsed_120 := MinimalChampionMotion.elapsed_for_state(state, "air", 0.0, config)
	var expected_half_phase := float(MovementTuning.HOP_DURATION_MS) * 60.0 / 2000.0
	check(absf(elapsed_120 - expected_half_phase) <= 0.5, "120 Hz airborne half-phase reaches the center of its 60 fps art duration")


func _test_locomotion_contact_phase() -> void:
	var motion := MinimalChampionMotion.new()
	check(motion.load_from_file(), "motion loads for locomotion contact phases")
	equal(motion.locomotion_contact_frame("buoyant_keeper", "walk", 0.0), 0, "walk begins on contact A")
	equal(motion.locomotion_contact_frame("buoyant_keeper", "walk", 10.9), 0, "contact A holds through the first half-cycle")
	equal(motion.locomotion_contact_frame("buoyant_keeper", "walk", 11.0), 1, "walk swaps legs at the half-cycle")
	equal(motion.locomotion_contact_frame("buoyant_keeper", "walk", 22.0), 0, "walk loops back to contact A")
	var phase_120 := motion.locomotion_contact_frame("grounded_weaver", "sprint", MinimalChampionMotion.tick_at_visual_rate(24, 120), 3)
	equal(phase_120, 1, "120 Hz contact-frame cadence reaches the authored opposite contact")
	equal(motion.locomotion_contact_frame("buoyant_keeper", "idle", 99.0), 0, "non-locomotion states cannot select an alternate contact")
