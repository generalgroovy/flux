class_name JumpPresentation
extends RefCounted


const NORMAL_MINIMUM_LIFT_PIXELS: int = 34
const NORMAL_MAXIMUM_LIFT_PIXELS: int = 84
const NORMAL_EVASION_LIFT_PIXELS: int = 54
const REDUCED_MINIMUM_LIFT_PIXELS: int = 7
const REDUCED_MAXIMUM_LIFT_PIXELS: int = 13
const GROUND_SHADOW_SCALE := Vector2(0.90, 0.32)
const NORMAL_APEX_SHADOW_SCALE := Vector2(1.50, 0.56)
const REDUCED_APEX_SHADOW_SCALE := Vector2(1.18, 0.42)
const GROUND_SHADOW_OPACITY: float = 0.22
const NORMAL_APEX_SHADOW_OPACITY: float = 0.52
const REDUCED_APEX_SHADOW_OPACITY: float = 0.48


class Sample:
	extends RefCounted

	var active: bool = false
	var normalized_phase: float = 0.0
	var arc_ratio: float = 0.0
	var body_lift_pixels: int = 0
	var shadow_scale: Vector2 = GROUND_SHADOW_SCALE
	var shadow_opacity: float = GROUND_SHADOW_OPACITY


static func sample(
	state: PlayerState,
	config: SimConfig,
	interpolation_alpha: float = 0.0,
	reduced_motion: bool = false,
) -> Sample:
	var result := Sample.new()
	var timer := _active_timer(state, config)
	if timer.y <= 0:
		return result

	result.active = true
	var bounded_alpha := clampf(interpolation_alpha, 0.0, 1.0)
	var elapsed_ticks := float(timer.y - timer.x) + bounded_alpha
	result.normalized_phase = clampf(elapsed_ticks / float(timer.y), 0.0, 1.0)
	result.arc_ratio = sin(PI * result.normalized_phase)
	var sustain_ratio := _sustain_ratio(state, config)
	var minimum_lift := REDUCED_MINIMUM_LIFT_PIXELS if reduced_motion else NORMAL_MINIMUM_LIFT_PIXELS
	var maximum_lift := REDUCED_MAXIMUM_LIFT_PIXELS if reduced_motion else NORMAL_MAXIMUM_LIFT_PIXELS
	if state.hop_ticks <= 0 and not reduced_motion:
		maximum_lift = NORMAL_EVASION_LIFT_PIXELS
	maximum_lift = roundi(lerpf(float(minimum_lift), float(maximum_lift), sustain_ratio))
	result.body_lift_pixels = roundi(float(maximum_lift) * result.arc_ratio)
	var apex_scale := REDUCED_APEX_SHADOW_SCALE if reduced_motion else NORMAL_APEX_SHADOW_SCALE
	var apex_opacity := REDUCED_APEX_SHADOW_OPACITY if reduced_motion else NORMAL_APEX_SHADOW_OPACITY
	result.shadow_scale = GROUND_SHADOW_SCALE.lerp(apex_scale, result.arc_ratio)
	result.shadow_opacity = lerpf(GROUND_SHADOW_OPACITY, apex_opacity, result.arc_ratio)
	return result


static func _sustain_ratio(state: PlayerState, config: SimConfig) -> float:
	if state.hop_ticks <= 0 or state.hop_mode not in [
		PlayerState.MovementMode.HOP,
		PlayerState.MovementMode.DOUBLE_JUMP,
		PlayerState.MovementMode.SLIDE_JUMP,
		PlayerState.MovementMode.WALL_KICK,
	]:
		return 1.0
	# The launch tick is free and the timer advances before paid sustain. Use
	# the attainable number of paid ticks, not independently rounded ms.
	var sustain_window_ticks := maxi(1,
		config.milliseconds_to_ticks(_hop_duration_ms(state.hop_mode))
		- config.milliseconds_to_ticks(MovementTuning.VARIABLE_JUMP_MINIMUM_MS) - 1)
	return clampf(float(state.jump_sustain_ticks) / float(sustain_window_ticks), 0.0, 1.0)


static func _active_timer(state: PlayerState, config: SimConfig) -> Vector2i:
	if state.hop_ticks > 0:
		return Vector2i(
			state.hop_ticks,
			config.milliseconds_to_ticks(_hop_duration_ms(state.hop_mode)),
		)
	if state.air_dodge_ticks > 0 and not state.is_rolling():
		return Vector2i(
			state.air_dodge_ticks,
			config.milliseconds_to_ticks(MovementTuning.AIR_DODGE_DURATION_MS),
		)
	if state.superglide_ticks > 0:
		return Vector2i(
			state.superglide_ticks,
			config.milliseconds_to_ticks(MovementTuning.SUPERGLIDE_DURATION_MS),
		)
	if state.vault_ticks > 0:
		return Vector2i(
			state.vault_ticks,
			config.milliseconds_to_ticks(MovementTuning.VAULT_DURATION_MS),
		)
	return Vector2i.ZERO


static func _hop_duration_ms(hop_mode: int) -> int:
	match hop_mode:
		PlayerState.MovementMode.DOUBLE_JUMP:
			return MovementTuning.DOUBLE_JUMP_DURATION_MS
		PlayerState.MovementMode.SLIDE_JUMP:
			return MovementTuning.SLIDE_JUMP_DURATION_MS
		_:
			return MovementTuning.HOP_DURATION_MS
