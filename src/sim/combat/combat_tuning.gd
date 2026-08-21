class_name CombatTuning
extends RefCounted


# These constants are the compiled foundation catalog values. The content test
# guards them against drift until the release compiler emits this table.
const PRIMARY_WIRE_ID: int = 101
const PRIMARY_ELEMENT_WIRE_ID: int = 6
const PRIMARY_FLUX_COST: int = 7_000
const PRIMARY_COOLDOWN_MS: int = 200
const PRIMARY_STARTUP_MS: int = 60
const PRIMARY_RECOVERY_MS: int = 80
const PRIMARY_SPEED: int = 1_120_000
const PRIMARY_RADIUS: int = 5_000
const PRIMARY_DAMAGE: int = 10_000
const PRIMARY_LIFETIME_MS: int = 1_200

const ACTIVE_1_WIRE_ID: int = 110
const ACTIVE_1_ELEMENT_WIRE_ID: int = 6
const ACTIVE_1_FLUX_COST: int = 24_000
const ACTIVE_1_COOLDOWN_MS: int = 900
const ACTIVE_1_STARTUP_MS: int = 180
const ACTIVE_1_RECOVERY_MS: int = 160
const ACTIVE_1_SPEED: int = 980_000
const ACTIVE_1_RADIUS: int = 7_000
const ACTIVE_1_DAMAGE: int = 25_000
const ACTIVE_1_LIFETIME_MS: int = 1_500

const RILLSHOT_WIRE_ID: int = 140
const RILLSHOT_ELEMENT_WIRE_ID: int = 3
const RILLSHOT_FLUX_COST: int = 6_000
const RILLSHOT_COOLDOWN_MS: int = 180
const RILLSHOT_STARTUP_MS: int = 55
const RILLSHOT_RECOVERY_MS: int = 70
const RILLSHOT_SPEED: int = 1_060_000
const RILLSHOT_RADIUS: int = 6_000
const RILLSHOT_DAMAGE: int = 9_000
const RILLSHOT_LIFETIME_MS: int = 1_150

const TIDELINE_WIRE_ID: int = 141
const TIDELINE_ELEMENT_WIRE_ID: int = 3
const TIDELINE_FLUX_COST: int = 20_000
const TIDELINE_COOLDOWN_MS: int = 900
const TIDELINE_STARTUP_MS: int = 170
const TIDELINE_RECOVERY_MS: int = 180
const TIDELINE_RANGE: int = 280_000
const TIDELINE_RADIUS: int = 5_000
const TIDELINE_CONE_COSINE_SQUARED_PER_MILLION: int = 750_000
const TIDELINE_DAMAGE: int = 14_000
const TIDELINE_LAUNCH_DURATION_MS: int = 180
const TIDELINE_LAUNCH_SPEED: int = 420_000

const RIMEWAKE_WIRE_ID: int = 144
const RIMEWAKE_ELEMENT_WIRE_ID: int = 5
const RIMEWAKE_FLUX_COST: int = 24_000
const RIMEWAKE_COOLDOWN_MS: int = 1_800
const RIMEWAKE_STARTUP_MS: int = 240
const RIMEWAKE_RECOVERY_MS: int = 220
const RIMEWAKE_RANGE: int = 240_000
const RIMEWAKE_RADIUS: int = 72_000
const RIMEWAKE_LIFETIME_MS: int = 2_200
const RIMEWAKE_SLOW_DURATION_MS: int = 700
const RIMEWAKE_SLOW_RATIO: int = 650

const ECLIPSE_DISC_WIRE_ID: int = 142
const ECLIPSE_DISC_ELEMENT_WIRE_ID: int = 8
const ECLIPSE_DISC_FLUX_COST: int = 8_000
const ECLIPSE_DISC_COOLDOWN_MS: int = 230
const ECLIPSE_DISC_STARTUP_MS: int = 70
const ECLIPSE_DISC_RECOVERY_MS: int = 90
const ECLIPSE_DISC_SPEED: int = 900_000
const ECLIPSE_DISC_RADIUS: int = 9_000
const ECLIPSE_DISC_DAMAGE: int = 10_000
const ECLIPSE_DISC_LIFETIME_MS: int = 1_600
const ECLIPSE_DISC_BOUNCES: int = 1

const POCKET_ECLIPSE_WIRE_ID: int = 143
const POCKET_ECLIPSE_ELEMENT_WIRE_ID: int = 7
const POCKET_ECLIPSE_FLUX_COST: int = 18_000
const POCKET_ECLIPSE_COOLDOWN_MS: int = 1_000
const POCKET_ECLIPSE_STARTUP_MS: int = 190
const POCKET_ECLIPSE_RECOVERY_MS: int = 200
const POCKET_ECLIPSE_RANGE: int = 520_000
const POCKET_ECLIPSE_RADIUS: int = 8_000
const POCKET_ECLIPSE_DAMAGE: int = 8_000
const POCKET_ECLIPSE_SLOW_DURATION_MS: int = 600
const POCKET_ECLIPSE_SLOW_RATIO: int = 550
const NO_HIT_CONTROL_STATE: int = 0
const LAUNCHED_HIT_CONTROL_STATE: int = 1
const SLOWED_HIT_CONTROL_STATE: int = 6

const PROJECTILE_SPAWN_CLEARANCE: int = 4_000
const EDGEWEAVE_MARGIN: int = 16_000
const EDGEWEAVE_MINIMUM_SPEED: int = 260_000
const EDGEWEAVE_REWARD: int = 9_000
const EDGEWEAVE_COOLDOWN_MS: int = 220

# Stable runtime library order. Champion kit wires are moved to the front of a
# player's default weave, but every proven spell remains globally available.
const RUNTIME_WIRE_IDS: Array[int] = [
	PRIMARY_WIRE_ID,
	ACTIVE_1_WIRE_ID,
	RILLSHOT_WIRE_ID,
	TIDELINE_WIRE_ID,
	RIMEWAKE_WIRE_ID,
	ECLIPSE_DISC_WIRE_ID,
	POCKET_ECLIPSE_WIRE_ID,
]


static func is_runtime_wire_id(wire_id: int) -> bool:
	return RUNTIME_WIRE_IDS.has(wire_id)


static func projectile_definition(wire_id: int) -> Dictionary:
	var result := cast_definition(wire_id)
	return result if String(result.get("shape", "")) == "projectile" else {}


static func cast_definition(wire_id: int) -> Dictionary:
	match wire_id:
		PRIMARY_WIRE_ID:
			return _definition(PRIMARY_ELEMENT_WIRE_ID, PRIMARY_FLUX_COST, PRIMARY_COOLDOWN_MS, PRIMARY_STARTUP_MS, PRIMARY_RECOVERY_MS, PRIMARY_SPEED, PRIMARY_RADIUS, PRIMARY_DAMAGE, PRIMARY_LIFETIME_MS)
		ACTIVE_1_WIRE_ID:
			return _definition(ACTIVE_1_ELEMENT_WIRE_ID, ACTIVE_1_FLUX_COST, ACTIVE_1_COOLDOWN_MS, ACTIVE_1_STARTUP_MS, ACTIVE_1_RECOVERY_MS, ACTIVE_1_SPEED, ACTIVE_1_RADIUS, ACTIVE_1_DAMAGE, ACTIVE_1_LIFETIME_MS)
		RILLSHOT_WIRE_ID:
			return _definition(RILLSHOT_ELEMENT_WIRE_ID, RILLSHOT_FLUX_COST, RILLSHOT_COOLDOWN_MS, RILLSHOT_STARTUP_MS, RILLSHOT_RECOVERY_MS, RILLSHOT_SPEED, RILLSHOT_RADIUS, RILLSHOT_DAMAGE, RILLSHOT_LIFETIME_MS)
		TIDELINE_WIRE_ID:
			var result := _spray_definition(TIDELINE_ELEMENT_WIRE_ID, TIDELINE_FLUX_COST, TIDELINE_COOLDOWN_MS, TIDELINE_STARTUP_MS, TIDELINE_RECOVERY_MS, TIDELINE_RANGE, TIDELINE_RADIUS, TIDELINE_DAMAGE)
			result["hit_control_state"] = LAUNCHED_HIT_CONTROL_STATE
			result["hit_control_duration_ms"] = TIDELINE_LAUNCH_DURATION_MS
			result["hit_control_speed"] = TIDELINE_LAUNCH_SPEED
			return result
		RIMEWAKE_WIRE_ID:
			return _field_definition(
				RIMEWAKE_ELEMENT_WIRE_ID,
				RIMEWAKE_FLUX_COST,
				RIMEWAKE_COOLDOWN_MS,
				RIMEWAKE_STARTUP_MS,
				RIMEWAKE_RECOVERY_MS,
				RIMEWAKE_RANGE,
				RIMEWAKE_RADIUS,
				RIMEWAKE_LIFETIME_MS,
				RIMEWAKE_SLOW_DURATION_MS,
				RIMEWAKE_SLOW_RATIO,
			)
		ECLIPSE_DISC_WIRE_ID:
			var result := _definition(ECLIPSE_DISC_ELEMENT_WIRE_ID, ECLIPSE_DISC_FLUX_COST, ECLIPSE_DISC_COOLDOWN_MS, ECLIPSE_DISC_STARTUP_MS, ECLIPSE_DISC_RECOVERY_MS, ECLIPSE_DISC_SPEED, ECLIPSE_DISC_RADIUS, ECLIPSE_DISC_DAMAGE, ECLIPSE_DISC_LIFETIME_MS)
			result["remaining_bounces"] = ECLIPSE_DISC_BOUNCES
			return result
		POCKET_ECLIPSE_WIRE_ID:
			var result := _beam_definition(POCKET_ECLIPSE_ELEMENT_WIRE_ID, POCKET_ECLIPSE_FLUX_COST, POCKET_ECLIPSE_COOLDOWN_MS, POCKET_ECLIPSE_STARTUP_MS, POCKET_ECLIPSE_RECOVERY_MS, POCKET_ECLIPSE_RANGE, POCKET_ECLIPSE_RADIUS, POCKET_ECLIPSE_DAMAGE)
			result["hit_control_state"] = SLOWED_HIT_CONTROL_STATE
			result["hit_control_duration_ms"] = POCKET_ECLIPSE_SLOW_DURATION_MS
			result["hit_control_slow_ratio"] = POCKET_ECLIPSE_SLOW_RATIO
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
		"shape": "projectile",
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
		"hit_control_slow_ratio": 1000,
		"remaining_bounces": 0,
	}


static func _beam_definition(
	element_wire_id: int,
	flux_cost: int,
	cooldown_ms: int,
	startup_ms: int,
	recovery_ms: int,
	maximum_range: int,
	radius: int,
	damage: int,
) -> Dictionary:
	return {
		"shape": "beam",
		"element_wire_id": element_wire_id,
		"flux_cost": flux_cost,
		"cooldown_ms": cooldown_ms,
		"startup_ms": startup_ms,
		"recovery_ms": recovery_ms,
		"range": maximum_range,
		"radius": radius,
		"damage": damage,
		"hit_control_state": NO_HIT_CONTROL_STATE,
		"hit_control_duration_ms": 0,
		"hit_control_speed": 0,
		"hit_control_slow_ratio": 1000,
	}


static func _spray_definition(
	element_wire_id: int,
	flux_cost: int,
	cooldown_ms: int,
	startup_ms: int,
	recovery_ms: int,
	maximum_range: int,
	radius: int,
	damage: int,
) -> Dictionary:
	return {
		"shape": "spray",
		"element_wire_id": element_wire_id,
		"flux_cost": flux_cost,
		"cooldown_ms": cooldown_ms,
		"startup_ms": startup_ms,
		"recovery_ms": recovery_ms,
		"range": maximum_range,
		"radius": radius,
		"damage": damage,
		"cone_cosine_squared_per_million": TIDELINE_CONE_COSINE_SQUARED_PER_MILLION,
		"hit_control_state": NO_HIT_CONTROL_STATE,
		"hit_control_duration_ms": 0,
		"hit_control_speed": 0,
		"hit_control_slow_ratio": 1000,
	}


static func _field_definition(
	element_wire_id: int,
	flux_cost: int,
	cooldown_ms: int,
	startup_ms: int,
	recovery_ms: int,
	maximum_range: int,
	radius: int,
	lifetime_ms: int,
	hit_control_duration_ms: int,
	hit_control_slow_ratio: int,
) -> Dictionary:
	return {
		"shape": "field",
		"element_wire_id": element_wire_id,
		"flux_cost": flux_cost,
		"cooldown_ms": cooldown_ms,
		"startup_ms": startup_ms,
		"recovery_ms": recovery_ms,
		"range": maximum_range,
		"radius": radius,
		"lifetime_ms": lifetime_ms,
		"hit_control_state": SLOWED_HIT_CONTROL_STATE,
		"hit_control_duration_ms": hit_control_duration_ms,
		"hit_control_speed": 0,
		"hit_control_slow_ratio": hit_control_slow_ratio,
	}
