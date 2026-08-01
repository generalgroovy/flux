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

const PROJECTILE_SPAWN_CLEARANCE: int = 4_000
const EDGEWEAVE_MARGIN: int = 16_000
const EDGEWEAVE_MINIMUM_SPEED: int = 260_000
const EDGEWEAVE_REWARD: int = 9_000
const EDGEWEAVE_COOLDOWN_MS: int = 220
