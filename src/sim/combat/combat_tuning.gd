class_name CombatTuning
extends RefCounted


# These constants are the compiled foundation catalog values. The content test
# guards them against drift until the release compiler emits this table.
const PRIMARY_WIRE_ID: int = 101
const PRIMARY_ELEMENT_WIRE_ID: int = 6
const PRIMARY_FLUX_COST: int = 0
const PRIMARY_COOLDOWN_MS: int = 220
const PRIMARY_STARTUP_MS: int = 60
const PRIMARY_RECOVERY_MS: int = 80
const PRIMARY_SPEED: int = 1_120_000
const PRIMARY_RADIUS: int = 5_000
const PRIMARY_DAMAGE: int = 10_000
const PRIMARY_LIFETIME_MS: int = 1_200

const ACTIVE_1_WIRE_ID: int = 110
const ACTIVE_1_ELEMENT_WIRE_ID: int = 6
const ACTIVE_1_FLUX_COST: int = 24_000
const ACTIVE_1_COOLDOWN_MS: int = 1_400
const ACTIVE_1_STARTUP_MS: int = 180
const ACTIVE_1_RECOVERY_MS: int = 160
const ACTIVE_1_SPEED: int = 980_000
const ACTIVE_1_RADIUS: int = 7_000
const ACTIVE_1_DAMAGE: int = 25_000
const ACTIVE_1_LIFETIME_MS: int = 1_500

const RILLSHOT_WIRE_ID: int = 140
const RILLSHOT_ELEMENT_WIRE_ID: int = 3
const RILLSHOT_FLUX_COST: int = 0
const RILLSHOT_COOLDOWN_MS: int = 190
const RILLSHOT_STARTUP_MS: int = 55
const RILLSHOT_RECOVERY_MS: int = 70
const RILLSHOT_SPEED: int = 1_060_000
const RILLSHOT_RADIUS: int = 6_000
const RILLSHOT_DAMAGE: int = 9_000
const RILLSHOT_LIFETIME_MS: int = 1_150

const TIDELINE_WIRE_ID: int = 141
const TIDELINE_ELEMENT_WIRE_ID: int = 3
const TIDELINE_FLUX_COST: int = 22_000
const TIDELINE_COOLDOWN_MS: int = 1_600
const TIDELINE_STARTUP_MS: int = 170
const TIDELINE_RECOVERY_MS: int = 180
const TIDELINE_SPEED: int = 780_000
const TIDELINE_RADIUS: int = 11_000
const TIDELINE_DAMAGE: int = 14_000
const TIDELINE_LIFETIME_MS: int = 1_300
const TIDELINE_LAUNCH_DURATION_MS: int = 180
const TIDELINE_LAUNCH_SPEED: int = 420_000
const NO_HIT_CONTROL_STATE: int = 0
const LAUNCHED_HIT_CONTROL_STATE: int = 1

const PROJECTILE_SPAWN_CLEARANCE: int = 4_000
const EDGEWEAVE_MARGIN: int = 16_000
const EDGEWEAVE_MINIMUM_SPEED: int = 260_000
const EDGEWEAVE_REWARD: int = 9_000
const EDGEWEAVE_COOLDOWN_MS: int = 220


static func projectile_definition(wire_id: int) -> Dictionary:
	match wire_id:
		PRIMARY_WIRE_ID:
			return _definition(PRIMARY_ELEMENT_WIRE_ID, PRIMARY_FLUX_COST, PRIMARY_COOLDOWN_MS, PRIMARY_STARTUP_MS, PRIMARY_RECOVERY_MS, PRIMARY_SPEED, PRIMARY_RADIUS, PRIMARY_DAMAGE, PRIMARY_LIFETIME_MS)
		ACTIVE_1_WIRE_ID:
			return _definition(ACTIVE_1_ELEMENT_WIRE_ID, ACTIVE_1_FLUX_COST, ACTIVE_1_COOLDOWN_MS, ACTIVE_1_STARTUP_MS, ACTIVE_1_RECOVERY_MS, ACTIVE_1_SPEED, ACTIVE_1_RADIUS, ACTIVE_1_DAMAGE, ACTIVE_1_LIFETIME_MS)
		RILLSHOT_WIRE_ID:
			return _definition(RILLSHOT_ELEMENT_WIRE_ID, RILLSHOT_FLUX_COST, RILLSHOT_COOLDOWN_MS, RILLSHOT_STARTUP_MS, RILLSHOT_RECOVERY_MS, RILLSHOT_SPEED, RILLSHOT_RADIUS, RILLSHOT_DAMAGE, RILLSHOT_LIFETIME_MS)
		TIDELINE_WIRE_ID:
			var result := _definition(TIDELINE_ELEMENT_WIRE_ID, TIDELINE_FLUX_COST, TIDELINE_COOLDOWN_MS, TIDELINE_STARTUP_MS, TIDELINE_RECOVERY_MS, TIDELINE_SPEED, TIDELINE_RADIUS, TIDELINE_DAMAGE, TIDELINE_LIFETIME_MS)
			result["hit_control_state"] = LAUNCHED_HIT_CONTROL_STATE
			result["hit_control_duration_ms"] = TIDELINE_LAUNCH_DURATION_MS
			result["hit_control_speed"] = TIDELINE_LAUNCH_SPEED
			return result
	return {}


static func _definition(
	element_wire_id: int,
	flux_cost: int,
	cooldown_ms: int,
	startup_ms: int,
	recovery_ms: int,
	speed: int,
	radius: int,
	damage: int,
	lifetime_ms: int,
) -> Dictionary:
	return {
		"element_wire_id": element_wire_id,
		"flux_cost": flux_cost,
		"cooldown_ms": cooldown_ms,
		"startup_ms": startup_ms,
		"recovery_ms": recovery_ms,
		"speed": speed,
		"radius": radius,
		"damage": damage,
		"lifetime_ms": lifetime_ms,
		"hit_control_state": NO_HIT_CONTROL_STATE,
		"hit_control_duration_ms": 0,
		"hit_control_speed": 0,
	}
