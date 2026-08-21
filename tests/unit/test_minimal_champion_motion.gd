extends FluxTestSuite


func run() -> int:
	_test_repository_motion()
	_test_complete_movement_mapping()
	_test_tick_rate_parity_and_reduced_motion()
	return finish("minimal-champion-motion")


func _test_repository_motion() -> void:
	var motion := MinimalChampionMotion.new()
	check(motion.load_from_file(), "minimal champion motion validates: %s" % motion.last_error)
	check(motion.content_hash.length() == 64, "minimal motion has a stable content hash")
	for profile_id: String in ["buoyant_keeper", "grounded_weaver"]:
		check(motion.has_profile(profile_id), "%s is an editable motion profile" % profile_id)
		for motion_id: String in MinimalChampionMotion.REQUIRED_MOTIONS:
			var sample := motion.sample(profile_id, motion_id, 11.0)
			check(sample.offset.abs().x <= 4.0 and sample.offset.abs().y <= 4.0, "%s/%s stays within translation budget" % [profile_id, motion_id])
			check(sample.scale.x >= 0.94 and sample.scale.x <= 1.06, "%s/%s stays within horizontal squash budget" % [profile_id, motion_id])
			check(sample.scale.y >= 0.94 and sample.scale.y <= 1.06, "%s/%s stays within vertical squash budget" % [profile_id, motion_id])
	equal(motion.movement_accents.size(), MinimalChampionMotion.REQUIRED_ACCENTS.size(), "every declared movement-response family owns one bounded accent")
	equal(String(motion.accent_by_id("counter_strafe").get("kind", "")), "brake_ticks", "ordinary reversal owns an editable heel-plant accent")


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
	}
	for movement_mode: int in expected:
		state.movement_mode = movement_mode
		state.control_state = PlayerState.ControlState.FREE
		equal(MinimalChampionMotion.motion_id(state), expected[movement_mode], "%s owns a readable motion family" % PlayerState.MovementMode.keys()[movement_mode])
	state.movement_mode = PlayerState.MovementMode.IDLE
	state.pending_cast_wire_id = CombatTuning.PRIMARY_WIRE_ID
	equal(MinimalChampionMotion.motion_id(state), "cast", "authoritative startup state selects cast anticipation")


func _test_tick_rate_parity_and_reduced_motion() -> void:
	equal(MinimalChampionMotion.tick_at_visual_rate(60, 60), MinimalChampionMotion.tick_at_visual_rate(120, 120), "one second has equal 60/120 visual time")
	equal(MinimalChampionMotion.tick_at_visual_rate(30, 60, 0.5), MinimalChampionMotion.tick_at_visual_rate(61, 120, 0.0), "interpolated visual time remains rate-independent")
	var motion := MinimalChampionMotion.new()
	check(motion.load_from_file(), "motion loads for accessibility sample")
	var normal := motion.sample("buoyant_keeper", "sprint", 7.0, false)
	var reduced := motion.sample("buoyant_keeper", "sprint", 7.0, true)
	check(reduced.offset.length() < normal.offset.length(), "reduced motion damps translation")
	check(reduced.scale.distance_to(Vector2.ONE) < normal.scale.distance_to(Vector2.ONE), "reduced motion damps squash/stretch")
	var state := PlayerState.new()
	var config := SimConfig.new(120)
	state.hop_mode = PlayerState.MovementMode.HOP
	state.hop_ticks = config.milliseconds_to_ticks(MovementTuning.HOP_DURATION_MS) / 2
	var elapsed_120 := MinimalChampionMotion.elapsed_for_state(state, "air", 0.0, config)
	var config_60 := SimConfig.new(60)
	state.hop_ticks = config_60.milliseconds_to_ticks(MovementTuning.HOP_DURATION_MS) / 2
	var elapsed_60 := MinimalChampionMotion.elapsed_for_state(state, "air", 0.0, config_60)
	check(absf(elapsed_60 - elapsed_120) <= 0.5, "airborne pose phase is equivalent at 60/120 Hz")
