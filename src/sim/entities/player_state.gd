class_name PlayerState
extends RefCounted


enum MovementMode {
	IDLE,
	WALK,
	SPRINT,
	HOP,
	DOUBLE_JUMP,
	SLIDE,
	SLIDE_JUMP,
	AIR_DODGE,
	WAVE_DASH,
	WALL_KICK,
	VAULT,
	SUPERGLIDE,
	LAUNCHED,
	GRAPPLED,
	CHARGING,
	STUNNED,
	ROOTED,
	SLOWED,
	FAST_FALL,
}

enum ControlState {
	FREE,
	LAUNCHED,
	GRAPPLED,
	CHARGING,
	STUNNED,
	ROOTED,
	SLOWED,
}

var entity_id: int = 1
var team_id: int = 1
var position_x: int = 160_000
var position_y: int = 360_000
var position_remainder_x: int = 0
var position_remainder_y: int = 0
var velocity_x: int = 0
var velocity_y: int = 0
var facing_x: int = 1000
var facing_y: int = 0
var aim_x: int = 1000
var aim_y: int = 0
var radius: int = MovementTuning.PLAYER_RADIUS
var movement_mode: int = MovementMode.IDLE
var primary_held: bool = false
var pending_cast_wire_id: int = 0
var pending_cast_ticks: int = 0
var pending_cast_aim_x: int = 1000
var pending_cast_aim_y: int = 0
var cast_recovery_ticks: int = 0
var primary_cooldown_ticks: int = 0
var active_1_cooldown_ticks: int = 0
var edgeweave_cooldown_ticks: int = 0

var health: int = PlayerTuning.HEALTH_MAXIMUM
var health_recovery_remainder: int = 0
var health_recovery_delay_ticks: int = 0
var flux: int = PlayerTuning.FLUX_MAXIMUM
var flux_recovery_remainder: int = 0
var flux_recovery_delay_ticks: int = 0
var stamina: int = MovementTuning.STAMINA_MAXIMUM
var stamina_remainder: int = 0
var stamina_recovery_delay_ticks: int = 0

var jump_buffer_ticks: int = 0
var technique_buffer_ticks: int = 0
var slide_buffer_ticks: int = 0
var fast_falling: bool = false
var variable_jump_grace_ticks: int = 0

var hop_ticks: int = 0
var hop_cooldown_ticks: int = 0
var hop_stage: int = 0
var hop_mode: int = MovementMode.HOP
var hop_speed: int = 0
var hop_x: int = 1000
var hop_y: int = 0
var air_redirects_remaining: int = 0

var air_dodge_ticks: int = 0
var air_dodge_cooldown_ticks: int = 0
var air_dodge_x: int = 1000
var air_dodge_y: int = 0
var wave_dash_queued: bool = false
var wave_dash_ticks: int = 0
var wave_dash_x: int = 1000
var wave_dash_y: int = 0

var slide_ticks: int = 0
var slide_cooldown_ticks: int = 0
var slide_x: int = 1000
var slide_y: int = 0

var vault_ticks: int = 0
var vault_cooldown_ticks: int = 0
var vault_x: int = 1000
var vault_y: int = 0
var superglide_ticks: int = 0
var superglide_x: int = 1000
var superglide_y: int = 0

var wall_memory_ticks: int = 0
var wall_x: int = 0
var wall_y: int = 0
var wall_contact_id: int = 0
var wall_lockout_id: int = 0
var wall_lockout_ticks: int = 0
var landing_ticks: int = 0
var sprinting: bool = false
var control_state: int = ControlState.FREE
var control_ticks: int = 0
var control_x: int = 1000
var control_y: int = 0
var control_speed: int = 0
var slow_ratio: int = 1000
var last_event: String = "spawn"


func _init(requested_entity_id: int = 1) -> void:
	entity_id = requested_entity_id


func is_airborne() -> bool:
	return hop_ticks > 0 or air_dodge_ticks > 0 or superglide_ticks > 0


func canonical_values() -> PackedInt64Array:
	return PackedInt64Array([
		entity_id, team_id,
		position_x, position_y, position_remainder_x, position_remainder_y,
		velocity_x, velocity_y, facing_x, facing_y, aim_x, aim_y, radius, movement_mode,
		int(primary_held),
		pending_cast_wire_id, pending_cast_ticks, pending_cast_aim_x, pending_cast_aim_y,
		cast_recovery_ticks, primary_cooldown_ticks, active_1_cooldown_ticks,
		edgeweave_cooldown_ticks,
		health, health_recovery_remainder, health_recovery_delay_ticks,
		flux, flux_recovery_remainder, flux_recovery_delay_ticks,
		stamina, stamina_remainder, stamina_recovery_delay_ticks,
		jump_buffer_ticks, technique_buffer_ticks, slide_buffer_ticks, int(fast_falling), variable_jump_grace_ticks,
		hop_ticks, hop_cooldown_ticks, hop_stage, hop_mode, hop_speed, hop_x, hop_y,
		air_redirects_remaining,
		air_dodge_ticks, air_dodge_cooldown_ticks, air_dodge_x, air_dodge_y,
		int(wave_dash_queued), wave_dash_ticks, wave_dash_x, wave_dash_y,
		slide_ticks, slide_cooldown_ticks, slide_x, slide_y,
		vault_ticks, vault_cooldown_ticks, vault_x, vault_y,
		superglide_ticks, superglide_x, superglide_y,
		wall_memory_ticks, wall_x, wall_y, wall_contact_id,
		wall_lockout_id, wall_lockout_ticks, landing_ticks, int(sprinting),
		control_state, control_ticks, control_x, control_y, control_speed, slow_ratio,
	])
