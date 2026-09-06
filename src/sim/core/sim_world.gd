class_name SimWorld
extends RefCounted


const MAP_ID: String = "foundation-arena-v1"
const MAP_HASH: String = "worldbone:none;bounds:1280x720;rails:v1"
const TrainingTargetSystemScript = preload("res://src/sim/combat/training_target_system.gd")

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
var deposits: Array[ElementDepositState] = []
var reactions: Array[ElementReactionState] = []
var next_deposit_id: int = 3000
var next_reaction_id: int = 4000
var next_projectile_id: int = 1000
var next_field_id: int = 2000
var combat_events: Array[Dictionary] = []
var last_error: String = ""


func _init(
	requested_tick_rate: int = SimConfig.TICK_RATE,
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
		last_error = "unsupported tick rate: %d; FLUX requires 120 Hz" % requested_tick_rate


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
	var commands_by_entity: Dictionary[int, SimCommand] = {}
	combat_events = []
	for command: SimCommand in ordered:
		if command.tick != tick:
			last_error = "command tick %d does not match world tick %d" % [command.tick, tick]
			return false
		if commands_by_entity.has(command.entity_id):
			last_error = "duplicate command for entity %d at tick %d" % [command.entity_id, tick]
			return false
		if player(command.entity_id) == null:
			last_error = "unknown entity %d" % command.entity_id
			return false
		commands_by_entity[command.entity_id] = command
	var ordered_players: Array[PlayerState] = players.duplicate()
	ordered_players.sort_custom(func(left: PlayerState, right: PlayerState) -> bool: return left.entity_id < right.entity_id)
	for state: PlayerState in ordered_players:
		if state.health <= 0:
			_idle_defeated(state)
			continue
		var command: SimCommand = commands_by_entity.get(state.entity_id, null)
		if command == null:
			command = SimCommand.new(tick, state.entity_id, 0, 0, 0, 0, state.aim_x, state.aim_y)
		state.aim_x = command.aim_x
		state.aim_y = command.aim_y
		state.primary_held = command.has_held(SimCommand.HELD_PRIMARY)
		PlayerResourcesSystem.step(state, config)
		MovementSystem.step(state, command, config, collision)
		var capacity := Vector2i.ZERO
		if state.pending_cast_wire_id == 0 and (command.first_pressed_spell_slot() > 0 or command.has_pressed(SimCommand.PRESSED_ACTIVE_1) or command.has_held(SimCommand.HELD_PRIMARY)):
			capacity = available_cast_capacity(state.entity_id)
		var spawned: Variant = CombatSystem.step_player(
			state, command, config, next_projectile_id, next_field_id, collision, combat_events, transition_policy, capacity.x, capacity.y
		)
		_store_combat_result(spawned)
	CombatSystem.resolve_instant_casts(players, config, collision, combat_events, reactions, tick)
	fields.sort_custom(func(left: FieldState, right: FieldState) -> bool: return left.entity_id < right.entity_id)
	fields = CombatSystem.advance_fields(fields, players, config, combat_events)
	projectiles.sort_custom(func(left: ProjectileState, right: ProjectileState) -> bool: return left.entity_id < right.entity_id)
	var owner_material_slots := {}
	for state: PlayerState in players:
		owner_material_slots[state.entity_id] = available_cast_capacity(state.entity_id).x
	projectiles = CombatSystem.advance_projectiles(projectiles, players, config, collision, combat_events, reactions, tick, _free_material_slots(), owner_material_slots)
	_consume_projectile_terminals()
	next_reaction_id = ElementChemistrySystem.step(deposits, reactions, players, collision, config, tick, next_reaction_id, combat_events)
	for state: PlayerState in ordered_players:
		TrainingTargetSystemScript.step_target(state, config)
	tick += 1
	return true


func available_cast_capacity(owner_id: int) -> Vector2i:
	var reserved_projectiles := projectiles.size()
	var reserved_fields := fields.size()
	var owner_projectiles := 0
	var owner_fields := 0
	var owner_deposits := 0
	for deposit: ElementDepositState in deposits:
		if deposit.owner_id == owner_id:
			owner_deposits += 1
	for projectile: ProjectileState in projectiles:
		if projectile.owner_id == owner_id:
			owner_projectiles += 1
	for field: FieldState in fields:
		if field.owner_id == owner_id:
			owner_fields += 1
	for state: PlayerState in players:
		if state.health <= 0 or state.pending_cast_wire_id == 0:
			continue
		var requirement := CombatSystem.cast_capacity_requirement(state.pending_cast_wire_id)
		reserved_projectiles += requirement.x
		reserved_fields += requirement.y
		if state.entity_id == owner_id:
			owner_projectiles += requirement.x
			owner_fields += requirement.y
	return Vector2i(
		maxi(0, mini(mini(SimConfig.MAX_ACTIVE_PROJECTILES - reserved_projectiles, SimConfig.MAX_PROJECTILES_PER_PLAYER - owner_projectiles), mini(ElementChemistrySystem.MAX_DEPOSITS - deposits.size() - reserved_projectiles, ElementChemistrySystem.MAX_OWNER_DEPOSITS - owner_deposits - owner_projectiles))),
		maxi(0, mini(SimConfig.MAX_ACTIVE_FIELDS - reserved_fields, SimConfig.MAX_FIELDS_PER_PLAYER - owner_fields)),
	)


func _free_material_slots() -> int:
	var reserved := projectiles.size() + deposits.size()
	for state: PlayerState in players:
		if state.health > 0 and state.pending_cast_wire_id != 0:
			reserved += CombatSystem.cast_capacity_requirement(state.pending_cast_wire_id).x
	return maxi(0, mini(ElementChemistrySystem.MAX_DEPOSITS - reserved, SimConfig.MAX_ACTIVE_PROJECTILES - projectiles.size()))


func _consume_projectile_terminals() -> void:
	var public_events: Array[Dictionary] = []
	for event: Dictionary in combat_events:
		match String(event.get("type", "")):
			"projectile_terminal":
				var admitted := ElementChemistrySystem.deposit_terminal(deposits, next_deposit_id, int(event["source_cast_id"]), int(event["source_wire_id"]), int(event["owner_id"]), int(event["team_id"]), int(event["element_wire_id"]), event["position"], tick, config, event["direction"], int(event["strength"]))
				if admitted > 0:
					next_deposit_id += 1
				elif admitted < 0:
					# Admitted casts reserve this slot before payment; refusal is an invariant failure.
					last_error = "reserved terminal material slot unavailable"
			"chemistry_projectile_split":
				var child: ProjectileState = event["projectile"]
				child.entity_id = next_projectile_id
				next_projectile_id += 1
				projectiles.append(child)
			_:
				public_events.append(event)
	combat_events = public_events


func _store_combat_result(spawned: Variant) -> void:
	if spawned is ProjectileState:
		projectiles.append(spawned)
		next_projectile_id += 1
	elif spawned is Array:
		var stored_count := 0
		for value: Variant in spawned:
			if value is ProjectileState:
				projectiles.append(value)
				stored_count += 1
		next_projectile_id += stored_count
	elif spawned is FieldState:
		fields.append(spawned)
		next_field_id += 1


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
	for value: int in [SimConfig.PROTOCOL_VERSION, config.tick_rate, tick, seed, next_projectile_id, next_field_id, next_deposit_id, next_reaction_id]:
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
	CanonicalBytes.append_i64(payload, deposits.size())
	for deposit: ElementDepositState in deposits:
		for value: int in deposit.canonical_values():
			CanonicalBytes.append_i64(payload, value)
	CanonicalBytes.append_i64(payload, reactions.size())
	for reaction: ElementReactionState in reactions:
		for value: int in reaction.canonical_values():
			CanonicalBytes.append_i64(payload, value)
	return CanonicalBytes.sha256_hex(payload)
