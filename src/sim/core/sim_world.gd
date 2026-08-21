class_name SimWorld
extends RefCounted


const MAP_ID: String = "foundation-arena-v1"
const MAP_HASH: String = "worldbone:none;bounds:1280x720;rails:v1"

var config: SimConfig
var collision: CollisionWorld
var transition_policy: ActionTransitionPolicy
var tick: int = 0
var seed: int = 1
var map_id: String = MAP_ID
var map_hash: String = MAP_HASH
var players: Array[PlayerState] = []
var projectiles: Array[ProjectileState] = []
var fields: Array[FieldState] = []
var next_projectile_id: int = 1000
var next_field_id: int = 2000
var combat_events: Array[Dictionary] = []
var last_error: String = ""


func _init(
	requested_tick_rate: int = 60,
	requested_seed: int = 1,
	requested_collision: CollisionWorld = null,
	requested_map_id: String = MAP_ID,
	requested_map_hash: String = MAP_HASH,
) -> void:
	config = SimConfig.new(requested_tick_rate)
	seed = requested_seed
	map_id = requested_map_id
	map_hash = requested_map_hash
	collision = requested_collision if requested_collision != null else CollisionWorld.new()
	if config.is_valid():
		transition_policy = ActionTransitionPolicy.new()
		if not transition_policy.load_from_file():
			last_error = transition_policy.last_error
			return
		if requested_collision == null:
			collision.add_obstacle(CollisionWorld.Obstacle.new(1, 560_000, 250_000, 620_000, 470_000, false))
			collision.add_obstacle(CollisionWorld.Obstacle.new(2, 820_000, 300_000, 900_000, 380_000, true))
		players.append(PlayerState.new(1))
	else:
		last_error = "unsupported tick rate: %d; expected 60 or 120" % requested_tick_rate


func is_valid() -> bool:
	return config.is_valid() and transition_policy != null and transition_policy.content_hash.length() == 64 and last_error.is_empty()


func player(entity_id: int = 1) -> PlayerState:
	for candidate: PlayerState in players:
		if candidate.entity_id == entity_id:
			return candidate
	return null


func step(commands: Array[SimCommand]) -> bool:
	if not is_valid():
		return false
	var ordered: Array[SimCommand] = commands.duplicate()
	ordered.sort_custom(func(left: SimCommand, right: SimCommand) -> bool: return left.entity_id < right.entity_id)
	var seen: Dictionary[int, bool] = {}
	combat_events = []
	for command: SimCommand in ordered:
		if command.tick != tick:
			last_error = "command tick %d does not match world tick %d" % [command.tick, tick]
			return false
		if seen.has(command.entity_id):
			last_error = "duplicate command for entity %d at tick %d" % [command.entity_id, tick]
			return false
		seen[command.entity_id] = true
		var state: PlayerState = player(command.entity_id)
		if state == null:
			last_error = "unknown entity %d" % command.entity_id
			return false
		if state.health <= 0:
			_idle_defeated(state)
			continue
		state.aim_x = command.aim_x
		state.aim_y = command.aim_y
		state.primary_held = command.has_held(SimCommand.HELD_PRIMARY)
		PlayerResourcesSystem.step(state, config)
		MovementSystem.step(state, command, config, collision)
		var spawned: RefCounted = CombatSystem.step_player(
			state, command, config, next_projectile_id, next_field_id, collision, combat_events, transition_policy
		)
		if spawned is ProjectileState:
			projectiles.append(spawned)
			next_projectile_id += 1
		elif spawned is FieldState:
			fields.append(spawned)
			next_field_id += 1
	for state: PlayerState in players:
		if not seen.has(state.entity_id):
			if state.health <= 0:
				_idle_defeated(state)
				continue
			state.primary_held = false
			PlayerResourcesSystem.step(state, config)
			var idle_command := SimCommand.new(tick, state.entity_id, 0, 0, 0, 0, state.aim_x, state.aim_y)
			MovementSystem.step(state, idle_command, config, collision)
			var spawned: RefCounted = CombatSystem.step_player(
				state, idle_command, config, next_projectile_id, next_field_id, collision, combat_events, transition_policy
			)
			if spawned is ProjectileState:
				projectiles.append(spawned)
				next_projectile_id += 1
			elif spawned is FieldState:
				fields.append(spawned)
				next_field_id += 1
	CombatSystem.resolve_instant_casts(players, config, collision, combat_events)
	fields.sort_custom(func(left: FieldState, right: FieldState) -> bool: return left.entity_id < right.entity_id)
	fields = CombatSystem.advance_fields(fields, players, config, combat_events)
	projectiles.sort_custom(func(left: ProjectileState, right: ProjectileState) -> bool: return left.entity_id < right.entity_id)
	projectiles = CombatSystem.advance_projectiles(projectiles, players, config, collision, combat_events)
	tick += 1
	return true


static func _idle_defeated(state: PlayerState) -> void:
	state.velocity_x = 0
	state.velocity_y = 0
	state.primary_held = false
	state.pending_cast_wire_id = 0
	state.pending_cast_ticks = 0
	state.sprinting = false
	state.movement_mode = PlayerState.MovementMode.IDLE


func state_hash() -> String:
	var payload := PackedByteArray()
	for value: int in [SimConfig.PROTOCOL_VERSION, config.tick_rate, tick, seed, next_projectile_id, next_field_id]:
		CanonicalBytes.append_i64(payload, value)
	CanonicalBytes.append_string(payload, map_id)
	CanonicalBytes.append_string(payload, map_hash)
	CanonicalBytes.append_string(payload, transition_policy.content_hash)
	var ordered: Array[PlayerState] = players.duplicate()
	ordered.sort_custom(func(left: PlayerState, right: PlayerState) -> bool: return left.entity_id < right.entity_id)
	CanonicalBytes.append_i64(payload, ordered.size())
	for state: PlayerState in ordered:
		for value: int in state.canonical_values():
			CanonicalBytes.append_i64(payload, value)
	CanonicalBytes.append_i64(payload, projectiles.size())
	for projectile: ProjectileState in projectiles:
		for value: int in projectile.canonical_values():
			CanonicalBytes.append_i64(payload, value)
	CanonicalBytes.append_i64(payload, fields.size())
	for field: FieldState in fields:
		for value: int in field.canonical_values():
			CanonicalBytes.append_i64(payload, value)
	return CanonicalBytes.sha256_hex(payload)
