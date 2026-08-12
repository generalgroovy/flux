class_name LandingPresentation
extends RefCounted


const BASE_SHADOW_SCALE := Vector2(0.90, 0.32)
const MAXIMUM_SHADOW_SCALE := Vector2(1.28, 0.24)
const MINIMUM_RING_RADIUS: float = 7.0
const MAXIMUM_RING_RADIUS: float = 28.0
const NORMAL_MAXIMUM_OPACITY: float = 0.72
const REDUCED_MAXIMUM_OPACITY: float = 0.50
const NORMAL_RING_WIDTH: float = 2.0
const REDUCED_RING_WIDTH: float = 1.0


class Sample:
	extends RefCounted

	var active: bool = false
	var normalized_phase: float = 0.0
	var intensity_ratio: float = 0.0
	var ring_radius: float = MINIMUM_RING_RADIUS
	var ring_opacity: float = 0.0
	var ring_width: float = NORMAL_RING_WIDTH
	var shadow_scale: Vector2 = BASE_SHADOW_SCALE


static func sample(
	state: PlayerState,
	config: SimConfig,
	interpolation_alpha: float = 0.0,
	reduced_motion: bool = false,
) -> Sample:
	var result := Sample.new()
	if state.landing_ticks <= 0 or state.landing_intensity <= 0:
		return result
	var total_ticks: int = config.milliseconds_to_ticks(MovementTuning.LANDING_WINDOW_MS)
	if total_ticks <= 0:
		return result
	result.active = true
	var bounded_alpha := clampf(interpolation_alpha, 0.0, 1.0)
	var elapsed_ticks := float(total_ticks - state.landing_ticks) + bounded_alpha
	result.normalized_phase = clampf(elapsed_ticks / float(total_ticks), 0.0, 1.0)
	result.intensity_ratio = clampf(float(state.landing_intensity) / 1000.0, 0.0, 1.0)
	var motion_ratio: float = 0.55 if reduced_motion else 1.0
	var pulse: float = (1.0 - result.normalized_phase) * result.intensity_ratio * motion_ratio
	result.ring_radius = lerpf(
		MINIMUM_RING_RADIUS,
		MAXIMUM_RING_RADIUS,
		result.normalized_phase * result.intensity_ratio * motion_ratio,
	)
	var maximum_opacity := REDUCED_MAXIMUM_OPACITY if reduced_motion else NORMAL_MAXIMUM_OPACITY
	result.ring_opacity = maximum_opacity * result.intensity_ratio * (1.0 - result.normalized_phase)
	result.ring_width = REDUCED_RING_WIDTH if reduced_motion else NORMAL_RING_WIDTH
	result.shadow_scale = BASE_SHADOW_SCALE.lerp(MAXIMUM_SHADOW_SCALE, pulse)
	return result
