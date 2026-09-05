extends FluxTestSuite


const PRESENTED_MODES: Array[int] = [
	PlayerState.MovementMode.HOP,
	PlayerState.MovementMode.WALL_KICK,
	PlayerState.MovementMode.DOUBLE_JUMP,
	PlayerState.MovementMode.SLIDE_JUMP,
	PlayerState.MovementMode.AIR_DODGE,
	PlayerState.MovementMode.VAULT,
	PlayerState.MovementMode.SUPERGLIDE,
]


func run() -> int:
	_test_ground_and_arc_contract()
	_test_reduced_motion_equivalent()
	_test_paid_height_range()
	_test_real_tap_and_hold()
	_test_supported_movement_modes()
	_test_120hz_phase_integrity()
	_test_sampler_does_not_mutate_authority()
	return finish("jump-presentation")


func _test_ground_and_arc_contract() -> void:
	var grounded := JumpPresentation.sample(PlayerState.new(), SimConfig.new(120))
	check(not grounded.active, "grounded presentation is inactive")
	equal(grounded.body_lift_pixels, 0, "grounded body has no lift")
	_near(grounded.shadow_scale.x, JumpPresentation.GROUND_SHADOW_SCALE.x, "grounded shadow uses baseline width")
	_near(grounded.shadow_opacity, JumpPresentation.GROUND_SHADOW_OPACITY, "grounded shadow uses baseline opacity")

	var start := _sample_at_phase(120, PlayerState.MovementMode.HOP, 0.0)
	var ascent := _sample_at_phase(120, PlayerState.MovementMode.HOP, 0.25)
	var apex := _sample_at_phase(120, PlayerState.MovementMode.HOP, 0.5)
	var descent := _sample_at_phase(120, PlayerState.MovementMode.HOP, 0.75)
	check(start.active, "jump presentation starts from authoritative timer")
	equal(start.body_lift_pixels, 0, "jump starts on the ground anchor")
	check(ascent.body_lift_pixels > start.body_lift_pixels, "body rises during ascent")
	check(apex.body_lift_pixels > ascent.body_lift_pixels, "body reaches maximum lift at apex")
	check(descent.body_lift_pixels < apex.body_lift_pixels, "body descends after apex")
	check(descent.body_lift_pixels > 0, "body remains lifted before landing")
	check(ascent.shadow_scale.x > start.shadow_scale.x, "shadow broadens during ascent")
	check(apex.shadow_scale.x > ascent.shadow_scale.x, "shadow is broadest at apex")
	check(descent.shadow_scale.x < apex.shadow_scale.x, "shadow contracts during descent")
	check(descent.shadow_scale.x > start.shadow_scale.x, "shadow remains broadened before landing")
	check(ascent.shadow_opacity > start.shadow_opacity, "shadow darkens during ascent")
	check(apex.shadow_opacity > ascent.shadow_opacity, "shadow is darkest at apex")
	check(descent.shadow_opacity < apex.shadow_opacity, "shadow lightens during descent")
	equal(apex.body_lift_pixels, JumpPresentation.NORMAL_MAXIMUM_LIFT_PIXELS, "normal apex uses full readable lift")


func _test_reduced_motion_equivalent() -> void:
	var normal := _sample_at_phase(120, PlayerState.MovementMode.HOP, 0.5)
	var reduced := _sample_at_phase(120, PlayerState.MovementMode.HOP, 0.5, true)
	check(reduced.active, "reduced-motion jump remains visibly active")
	check(reduced.body_lift_pixels > 0, "reduced-motion path retains a body-lift cue")
	check(reduced.body_lift_pixels < normal.body_lift_pixels, "reduced-motion path limits displacement")
	equal(reduced.body_lift_pixels, JumpPresentation.REDUCED_MAXIMUM_LIFT_PIXELS, "reduced apex uses bounded lift")
	check(reduced.shadow_scale.x > JumpPresentation.GROUND_SHADOW_SCALE.x, "reduced-motion shadow still broadens")
	check(reduced.shadow_opacity > JumpPresentation.GROUND_SHADOW_OPACITY, "reduced-motion shadow still darkens")


func _test_paid_height_range() -> void:
	var config := SimConfig.new(120)
	var state := PlayerState.new()
	state.hop_mode = PlayerState.MovementMode.HOP
	state.hop_ticks = config.milliseconds_to_ticks(MovementTuning.HOP_DURATION_MS) / 2
	var tap_apex := JumpPresentation.sample(state, config)
	equal(tap_apex.body_lift_pixels, JumpPresentation.NORMAL_MINIMUM_LIFT_PIXELS, "tap jump keeps the compact readable apex")
	state.jump_sustain_ticks = config.milliseconds_to_ticks(MovementTuning.HOP_DURATION_MS - MovementTuning.VARIABLE_JUMP_MINIMUM_MS)
	var held_apex := JumpPresentation.sample(state, config)
	equal(held_apex.body_lift_pixels, JumpPresentation.NORMAL_MAXIMUM_LIFT_PIXELS, "fully sustained jump reaches the much higher apex")
	check(held_apex.body_lift_pixels > tap_apex.body_lift_pixels, "paid sustain increases height, not only airtime")


func _test_real_tap_and_hold() -> void:
	var peaks: Array[int] = []
	for held: bool in [false, true]:
		var world := SimWorld.new(120)
		var peak := 0
		var protected_ticks := 0
		for index: int in range(90):
			var command := SimCommand.new(world.tick, 1, 0, 0,
				SimCommand.HELD_JUMP if held else 0,
				SimCommand.PRESSED_JUMP if index == 0 else 0)
			world.step([command])
			var sample := JumpPresentation.sample(world.player(), world.config)
			peak = maxi(peak, sample.body_lift_pixels)
			if MovementSystem.is_combat_intangible(world.player(), world.config):
				protected_ticks += 1
		peaks.append(peak)
		check(protected_ticks <= world.config.milliseconds_to_ticks(MovementTuning.JUMP_INVULNERABILITY_MS), "higher arc cannot extend protection")
		equal(JumpPresentation.sample(world.player(), world.config).body_lift_pixels, 0, "real jump returns to its ground anchor")
	check(peaks[1] >= 80, "ordinary held Jump reaches the new high arc")
	check(peaks[0] >= 32 and peaks[0] <= 35, "ordinary tap Jump retains a compact arc")
	check(peaks[1] > peaks[0] * 2, "real input path clearly separates held and tap height")


func _test_supported_movement_modes() -> void:
	for mode: int in PRESENTED_MODES:
		var presented := _sample_at_phase(120, mode, 0.5)
		check(presented.active, "movement mode %d has an active arc" % mode)
		check(presented.body_lift_pixels > 0, "movement mode %d lifts the body" % mode)
		check(presented.shadow_scale.x > JumpPresentation.GROUND_SHADOW_SCALE.x, "movement mode %d broadens the shadow" % mode)


func _test_120hz_phase_integrity() -> void:
	for mode: int in PRESENTED_MODES:
		for phase: float in [0.25, 0.5, 0.75]:
			var at_120 := _sample_at_phase(120, mode, phase)
			_near(at_120.normalized_phase, phase, "120 Hz mode %d reaches requested phase" % mode)
			check(at_120.body_lift_pixels > 0, "120 Hz mode %d keeps readable lift away from endpoints" % mode)
			check(at_120.shadow_scale.x > JumpPresentation.GROUND_SHADOW_SCALE.x, "120 Hz mode %d keeps its airborne shadow cue" % mode)


func _test_sampler_does_not_mutate_authority() -> void:
	var state := PlayerState.new()
	state.position_x = 417_000
	state.position_y = 293_000
	state.radius = 23_000
	state.hop_mode = PlayerState.MovementMode.SLIDE_JUMP
	state.hop_ticks = SimConfig.new(120).milliseconds_to_ticks(MovementTuning.SLIDE_JUMP_DURATION_MS)
	var before := state.canonical_values()
	JumpPresentation.sample(state, SimConfig.new(120), 0.5)
	equal(state.canonical_values(), before, "sampling never mutates canonical values")
	equal(state.position_x, 417_000, "sampling preserves collision anchor x")
	equal(state.position_y, 293_000, "sampling preserves collision anchor y")
	equal(state.radius, 23_000, "sampling preserves collision radius")


func _sample_at_phase(tick_rate: int, mode: int, phase: float, reduced_motion: bool = false) -> JumpPresentation.Sample:
	var config := SimConfig.new(tick_rate)
	var state := PlayerState.new()
	state.movement_mode = mode
	var duration_ms := _duration_ms(mode)
	var total_ticks := config.milliseconds_to_ticks(duration_ms)
	var remaining_fractional := float(total_ticks) * (1.0 - phase)
	var remaining_ticks := ceili(remaining_fractional)
	var interpolation_alpha := float(remaining_ticks) - remaining_fractional
	match mode:
		PlayerState.MovementMode.HOP, PlayerState.MovementMode.WALL_KICK, PlayerState.MovementMode.DOUBLE_JUMP, PlayerState.MovementMode.SLIDE_JUMP:
			state.hop_mode = mode
			state.hop_ticks = remaining_ticks
			state.jump_sustain_ticks = config.milliseconds_to_ticks(maxi(1, duration_ms - MovementTuning.VARIABLE_JUMP_MINIMUM_MS))
		PlayerState.MovementMode.AIR_DODGE:
			state.air_dodge_ticks = remaining_ticks
		PlayerState.MovementMode.VAULT:
			state.vault_ticks = remaining_ticks
		PlayerState.MovementMode.SUPERGLIDE:
			state.superglide_ticks = remaining_ticks
	return JumpPresentation.sample(state, config, interpolation_alpha, reduced_motion)


func _duration_ms(mode: int) -> int:
	match mode:
		PlayerState.MovementMode.DOUBLE_JUMP:
			return MovementTuning.DOUBLE_JUMP_DURATION_MS
		PlayerState.MovementMode.SLIDE_JUMP:
			return MovementTuning.SLIDE_JUMP_DURATION_MS
		PlayerState.MovementMode.AIR_DODGE:
			return MovementTuning.AIR_DODGE_DURATION_MS
		PlayerState.MovementMode.VAULT:
			return MovementTuning.VAULT_DURATION_MS
		PlayerState.MovementMode.SUPERGLIDE:
			return MovementTuning.SUPERGLIDE_DURATION_MS
		_:
			return MovementTuning.HOP_DURATION_MS


func _near(actual: float, expected: float, message: String) -> void:
	check(is_equal_approx(actual, expected), "%s (expected=%s actual=%s)" % [message, expected, actual])
