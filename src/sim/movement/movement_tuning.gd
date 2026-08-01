class_name MovementTuning
extends RefCounted


# Authoritative values are fixed-point world units, resource milli-units,
# milliseconds, or scale-1000 ratios. They preserve the proven FLUX grammar.
const PLAYER_RADIUS: int = 18_000
const BASE_SPEED: int = 360_000
const ACCELERATION: int = 1_800_000
const DECELERATION: int = 2_400_000
const SPRINT_MULTIPLIER: int = 1280
const COUNTER_STRAFE_MULTIPLIER: int = 1700

const FLOW_MAXIMUM: int = 100_000
const SPRINT_DRAIN_PER_SECOND: int = 34_000
const FLOW_RECOVERY_PER_SECOND: int = 27_000
const FLOW_RECOVERY_DELAY_MS: int = 380

const HOP_COST: int = 28_000
const HOP_SPEED: int = 650_000
const HOP_DURATION_MS: int = 160
const HOP_COOLDOWN_MS: int = 500
const WALL_KICK_SPEED: int = 780_000
const WALL_MEMORY_MS: int = 160

const DOUBLE_JUMP_COST: int = 24_000
const DOUBLE_JUMP_SPEED: int = 700_000
const DOUBLE_JUMP_DURATION_MS: int = 200
const AIR_REDIRECT_COST: int = 10_000
const AIR_REDIRECT_BLEND: int = 720

const AIR_DODGE_COST: int = 28_000
const AIR_DODGE_SPEED: int = 860_000
const AIR_DODGE_DURATION_MS: int = 180
const AIR_DODGE_COOLDOWN_MS: int = 620
const WAVE_DASH_INPUT_WINDOW_MS: int = 85
const WAVE_DASH_MINIMUM_TURN: int = 280_000
const WAVE_DASH_SPEED: int = 740_000
const WAVE_DASH_DURATION_MS: int = 240
const WAVE_DASH_STEERING: int = 200

const LANDING_WINDOW_MS: int = 110
const LANDING_CUT_MULTIPLIER: int = 1180
const SLIDE_COST: int = 22_000
const SLIDE_ENTRY_SPEED: int = 250_000
const SLIDE_SPEED: int = 720_000
const SLIDE_DURATION_MS: int = 300
const SLIDE_COOLDOWN_MS: int = 780
const SLIDE_STEERING: int = 320
const SLIDE_JUMP_COST: int = 20_000
const SLIDE_JUMP_SPEED: int = 790_000
const SLIDE_JUMP_DURATION_MS: int = 230
const SLIDE_JUMP_WINDOW_MS: int = 140

const VAULT_COST: int = 14_000
const VAULT_APPROACH: int = 42_000
const VAULT_LANDING: int = 22_000
const VAULT_MAXIMUM_DEPTH: int = 96_000
const VAULT_DURATION_MS: int = 300
const VAULT_COOLDOWN_MS: int = 500
const VAULT_CREST_START_MS: int = 100
const VAULT_CREST_END_MS: int = 230
const SUPERGLIDE_COST: int = 26_000
const SUPERGLIDE_SPEED: int = 900_000
const SUPERGLIDE_DURATION_MS: int = 220

const MAX_AUTHORED_SPEED: int = SUPERGLIDE_SPEED
