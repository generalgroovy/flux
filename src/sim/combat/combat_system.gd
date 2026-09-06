class_name CombatSystem
extends RefCounted
@warning_ignore_start("integer_division")


static func step_player(
	state: PlayerState,
	command: SimCommand,
	config: SimConfig,
	projectile_id: int,
	field_id: int,
	world: CollisionWorld,
	events: Array[Dictionary],
	transition_policy: ActionTransitionPolicy,
	available_projectiles: int = -1,
	available_fields: int = -1,
) -> Variant:
	for property_name: StringName in [
		&"cast_recovery_ticks", &"edgeweave_cooldown_ticks",
	]:
		state.set(property_name, maxi(0, int(state.get(property_name)) - 1))
	state.advance_spell_cooldowns()

	var requested_spell_slot: int = command.first_pressed_spell_slot()
	var requested_spell_wire_id: int = state.spell_wire_id(requested_spell_slot)
	var pressed_cast_intent := requested_spell_slot > 0 or command.has_pressed(SimCommand.PRESSED_ACTIVE_1)
	var requested_wire_id := requested_spell_wire_id
	if requested_spell_slot == 0 and command.has_pressed(SimCommand.PRESSED_ACTIVE_1):
		requested_wire_id = state.active_1_wire_id
	var held_primary_intent := not pressed_cast_intent and command.has_held(SimCommand.HELD_PRIMARY)
	if held_primary_intent:
		requested_wire_id = state.primary_wire_id

	if state.pending_cast_wire_id != 0:
		if pressed_cast_intent:
			_refuse_cast(state, requested_wire_id, requested_spell_slot, transition_policy.cast_gate_reason(state), events)
		state.pending_cast_ticks = maxi(0, state.pending_cast_ticks - 1)
		if state.pending_cast_ticks == 0:
			return _release_cast(state, config, projectile_id, field_id, world, events)
		return null
	var gate_reason := transition_policy.cast_gate_reason(state)
	if not gate_reason.is_empty() and (pressed_cast_intent or held_primary_intent):
		if pressed_cast_intent:
			_refuse_cast(state, requested_wire_id, requested_spell_slot, gate_reason, events)
		return null

	if requested_spell_slot > 0 and requested_spell_wire_id == 0:
		_refuse_cast(state, 0, requested_spell_slot, "empty_slot", events)
		return null
	if not pressed_cast_intent and not held_primary_intent:
		return null
	if not CombatTuning.is_runtime_wire_id(requested_wire_id) or state.spell_slot_index_for_wire(requested_wire_id) < 0:
		_refuse_cast(state, requested_wire_id, requested_spell_slot, "kit", events)
		return null
	if state.spell_cooldown_for_wire(requested_wire_id) > 0:
		if pressed_cast_intent:
			_refuse_cast(state, requested_wire_id, requested_spell_slot, "cooldown", events)
		return null
	var definition := CombatTuning.cast_definition(requested_wire_id)
	if definition.is_empty():
		_refuse_cast(state, requested_wire_id, requested_spell_slot, "kit", events)
		return null
	var required_capacity := cast_capacity_requirement(requested_wire_id)
	if (available_projectiles >= 0 and required_capacity.x > available_projectiles) \
		or (available_fields >= 0 and required_capacity.y > available_fields):
		_refuse_cast(state, requested_wire_id, requested_spell_slot, "capacity", events)
		return null
	if not PlayerResourcesSystem.spend_flux(state, int(definition["flux_cost"]), config):
		if pressed_cast_intent:
			_refuse_cast(state, requested_wire_id, requested_spell_slot, "flux", events)
		return null
	_begin_cast(state, requested_wire_id, int(definition["startup_ms"]), config, command)
	events.append({"type": "cast_started", "entity_id": state.entity_id, "wire_id": requested_wire_id})
	return null


static func cast_capacity_requirement(wire_id: int) -> Vector2i:
	var definition := CombatTuning.cast_definition(wire_id)
	match String(definition.get("shape", "")):
		"projectile":
			return Vector2i((definition.get("projectile_rotations", [Vector2i(1000, 0)]) as Array).size(), 0)
		"field":
			return Vector2i(0, 1)
	return Vector2i.ZERO


static func _refuse_cast(
	state: PlayerState,
	wire_id: int,
	slot: int,
	reason: String,
	events: Array[Dictionary],
) -> void:
	events.append({
		"type": "cast_refused",
		"entity_id": state.entity_id,
		"wire_id": wire_id,
		"reason": reason,
		"slot": slot,
	})
	state.last_event = "cast_refused_%s_%d" % [reason, wire_id]


static func advance_projectiles(
	projectiles: Array[ProjectileState],
	players: Array[PlayerState],
	config: SimConfig,
	world: CollisionWorld,
	events: Array[Dictionary],
	reactions: Array[ElementReactionState] = [],
	current_tick: int = 0,
	available_chemistry_slots: int = 0,
	owner_material_slots: Dictionary = {},
) -> Array[ProjectileState]:
	var survivors: Array[ProjectileState] = []
	var ordered_players: Array[PlayerState] = players.duplicate()
	ordered_players.sort_custom(func(left: PlayerState, right: PlayerState) -> bool: return left.entity_id < right.entity_id)
	for projectile: ProjectileState in projectiles:
		projectile.previous_x = projectile.position_x
		projectile.previous_y = projectile.position_y
		var total_x: int = projectile.remainder_x + projectile.velocity_x
		var total_y: int = projectile.remainder_y + projectile.velocity_y
		@warning_ignore("integer_division")
		var delta := Vector2i(total_x / config.tick_rate, total_y / config.tick_rate)
		projectile.remainder_x = total_x - delta.x * config.tick_rate
		projectile.remainder_y = total_y - delta.y * config.tick_rate
		var step_distance := SimCommand._integer_square_root(delta.x * delta.x + delta.y * delta.y)
		if projectile.remaining_distance >= 0 and step_distance > projectile.remaining_distance:
			delta = Vector2i(delta.x * projectile.remaining_distance / maxi(1, step_distance), delta.y * projectile.remaining_distance / maxi(1, step_distance))
			step_distance = projectile.remaining_distance
		var result: CollisionWorld.MoveResult = world.move_box(
			Vector2i(projectile.position_x, projectile.position_y),
			delta,
			projectile.radius,
		)
		projectile.position_x = result.position.x
		projectile.position_y = result.position.y
		if projectile.remaining_distance >= 0:
			projectile.remaining_distance = maxi(0, projectile.remaining_distance - step_distance)
		if not reactions.is_empty():
			var split_capacity := mini(available_chemistry_slots, int(owner_material_slots.get(projectile.owner_id, 0)))
			var interaction := ElementChemistrySystem.projectile_interaction(projectile, reactions, world, config, current_tick, split_capacity)
			if bool(interaction.get("blocked", false)):
				_emit_terminal(projectile, events, "construct")
				continue
			if interaction.get("split_velocity", Vector2i.ZERO) != Vector2i.ZERO and split_capacity > 0:
				var child := ProjectileState.new(0, projectile.owner_id, projectile.team_id, projectile.source_wire_id, projectile.element_wire_id,
					Vector2i(projectile.position_x, projectile.position_y), interaction["split_velocity"], projectile.radius,
					int(interaction.get("split_damage", 0)), projectile.lifetime_ticks, projectile.hit_control_state,
					projectile.hit_control_duration_ms, projectile.hit_control_speed, projectile.hit_control_slow_ratio)
				child.remaining_distance = projectile.remaining_distance
				child.source_cast_id = projectile.source_cast_id
				child.material_strength = maxi(1, projectile.material_strength / 2)
				projectile.material_strength = maxi(1, projectile.material_strength - child.material_strength)
				child.chemistry_interaction_mask = projectile.chemistry_interaction_mask
				child.grazed_entity_ids = projectile.grazed_entity_ids.duplicate()
				events.append({"type": "chemistry_projectile_split", "projectile": child})
				available_chemistry_slots -= 1
				owner_material_slots[projectile.owner_id] = split_capacity - 1

		var hit_entity_id: int = 0
		for target: PlayerState in ordered_players:
			if target.entity_id == projectile.owner_id or target.team_id == projectile.team_id or target.health <= 0 or target.spawn_protection_ticks > 0:
				continue
			var hit_radius: int = target.radius + projectile.radius
			if _segment_circle_hit(projectile, target, hit_radius):
				if MovementSystem.is_combat_intangible(target, config) or target.air_height >= MovementTuning.GROUND_PROJECTILE_CLEARANCE_HEIGHT:
					target.last_event = "evaded_projectile"
					continue
				PlayerResourcesSystem.damage(target, projectile.damage, config)
				if target.health > 0 and projectile.hit_control_duration_ms > 0:
					MovementSystem.apply_control_state(
						target,
						projectile.hit_control_state,
						projectile.hit_control_duration_ms,
						SimCommand._normalized_direction(projectile.velocity_x, projectile.velocity_y),
						projectile.hit_control_speed,
						config,
						projectile.hit_control_slow_ratio,
					)
				hit_entity_id = target.entity_id
				events.append({
					"type": "projectile_hit",
					"projectile_id": projectile.entity_id,
					"source_wire_id": projectile.source_wire_id,
					"owner_id": projectile.owner_id,
					"target_id": target.entity_id,
					"damage": projectile.damage,
				})
				if target.actor_kind == PlayerState.ActorKind.CHAMPION and target.health == 0:
					events.append({
						"type": "champion_defeated",
						"projectile_id": projectile.entity_id,
						"owner_id": projectile.owner_id,
						"target_id": target.entity_id,
					})
				break

		_resolve_edgeweave(projectile, ordered_players, hit_entity_id, config, events)
		if hit_entity_id != 0:
			_emit_terminal(projectile, events, "actor")
			continue
		if result.wall_normal != Vector2i.ZERO:
			events.append({"type": "projectile_impact", "projectile_id": projectile.entity_id, "wall_id": result.wall_id})
			_emit_terminal(projectile, events, "obstacle")
			continue
		projectile.lifetime_ticks = maxi(0, projectile.lifetime_ticks - 1)
		if projectile.lifetime_ticks == 0 or projectile.remaining_distance == 0:
			events.append({"type": "projectile_expired", "projectile_id": projectile.entity_id})
			_emit_terminal(projectile, events, "range")
			continue
		survivors.append(projectile)
	return survivors


static func _emit_terminal(projectile: ProjectileState, events: Array[Dictionary], reason: String) -> void:
	events.append({
		"type": "projectile_terminal", "projectile_id": projectile.entity_id,
		"source_cast_id": projectile.source_cast_id if projectile.source_cast_id > 0 else projectile.entity_id,
		"source_wire_id": projectile.source_wire_id, "owner_id": projectile.owner_id, "team_id": projectile.team_id,
		"element_wire_id": projectile.element_wire_id, "position": Vector2i(projectile.position_x, projectile.position_y),
		"direction": SimCommand._normalized_direction(projectile.velocity_x, projectile.velocity_y),
		"strength": projectile.material_strength, "reason": reason,
	})


static func _begin_cast(state: PlayerState, wire_id: int, startup_ms: int, config: SimConfig, command: SimCommand = null) -> void:
	state.pending_cast_wire_id = wire_id
	state.pending_cast_ticks = config.milliseconds_to_ticks(startup_ms)
	state.pending_cast_aim_x = state.aim_x
	state.pending_cast_aim_y = state.aim_y
	state.pending_cast_target_x = command.aim_target_x if command != null else -1
	state.pending_cast_target_y = command.aim_target_y if command != null else -1
	state.last_event = "cast_start_%d" % wire_id


static func _release_cast(
	state: PlayerState,
	config: SimConfig,
	projectile_id: int,
	field_id: int,
	world: CollisionWorld,
	events: Array[Dictionary],
) -> Variant:
	var wire_id: int = state.pending_cast_wire_id
	var definition := CombatTuning.cast_definition(wire_id)
	if definition.is_empty():
		state.pending_cast_wire_id = 0
		state.pending_cast_ticks = 0
		return null
	if not state.set_spell_cooldown(wire_id, config.milliseconds_to_ticks(int(definition["cooldown_ms"]))):
		state.pending_cast_wire_id = 0
		state.pending_cast_ticks = 0
		return null
	state.cast_recovery_ticks = config.milliseconds_to_ticks(int(definition["recovery_ms"]))
	var shape := String(definition.get("shape", ""))
	if shape in ["beam", "spray"]:
		_queue_instant_cast(state, wire_id, shape, events)
		return null
	if shape == "field":
		return _release_field(state, wire_id, field_id, definition, config, world, events)
	return _release_projectiles(state, wire_id, projectile_id, definition, config, world, events)


static func _release_projectiles(
	state: PlayerState,
	wire_id: int,
	first_projectile_id: int,
	definition: Dictionary,
	config: SimConfig,
	world: CollisionWorld,
	events: Array[Dictionary],
) -> Array[ProjectileState]:
	var speed := int(definition["speed"])
	var radius := int(definition["radius"])
	var base_direction := Vector2i(state.pending_cast_aim_x, state.pending_cast_aim_y)
	var locked_distance := -1
	if state.pending_cast_target_x >= 0 and state.pending_cast_target_y >= 0:
		var locked_delta := Vector2i(state.pending_cast_target_x - state.position_x, state.pending_cast_target_y - state.position_y)
		locked_distance = SimCommand._integer_square_root(locked_delta.x * locked_delta.x + locked_delta.y * locked_delta.y)
		if locked_delta != Vector2i.ZERO:
			base_direction = SimCommand._normalized_direction(locked_delta.x, locked_delta.y)
	var rotations: Array = definition.get("projectile_rotations", [Vector2i(1000, 0)])
	var angles: Array = definition.get("projectile_angles_degrees", [0])
	@warning_ignore("integer_division")
	var spawn_distance: int = state.radius + radius + CombatTuning.PROJECTILE_SPAWN_CLEARANCE
	if locked_distance >= 0:
		spawn_distance = mini(spawn_distance, locked_distance)
	var directions: Array[Vector2i] = []
	var spawn_positions: Array[Vector2i] = []
	for rotation_value: Variant in rotations:
		var direction := _rotate_fixed_direction(base_direction, rotation_value as Vector2i)
		@warning_ignore("integer_division")
		var spawn_position := Vector2i(
			state.position_x + direction.x * spawn_distance / 1000,
			state.position_y + direction.y * spawn_distance / 1000,
		)
		directions.append(direction)
		spawn_positions.append(spawn_position)
	state.pending_cast_wire_id = 0
	state.pending_cast_ticks = 0
	for spawn_position: Vector2i in spawn_positions:
		if not world.can_occupy(spawn_position, radius):
			events.append({"type": "cast_blocked", "entity_id": state.entity_id, "wire_id": wire_id})
			state.last_event = "cast_blocked_%d" % wire_id
			return []
	var projectiles: Array[ProjectileState] = []
	for lane_index: int in range(directions.size()):
		var direction := directions[lane_index]
		@warning_ignore("integer_division")
		var velocity := Vector2i(direction.x * speed / 1000, direction.y * speed / 1000)
		var projectile_id := first_projectile_id + lane_index
		var projectile := ProjectileState.new(
			projectile_id,
			state.entity_id,
			state.team_id,
			wire_id,
			int(definition["element_wire_id"]),
			spawn_positions[lane_index],
			velocity,
			radius,
			int(definition["damage"]),
			config.milliseconds_to_ticks(int(definition["lifetime_ms"])),
			int(definition["hit_control_state"]),
			int(definition["hit_control_duration_ms"]),
			int(definition["hit_control_speed"]),
			int(definition["hit_control_slow_ratio"]),
			0,
		)
		projectile.source_cast_id = first_projectile_id
		projectile.material_strength = 1000 / maxi(1, directions.size())
		projectile.remaining_distance = maxi(0, locked_distance - spawn_distance) if locked_distance >= 0 else -1
		projectiles.append(projectile)
		events.append({
			"type": "projectile_spawned",
			"projectile_id": projectile_id,
			"owner_id": state.entity_id,
			"wire_id": wire_id,
			"lane_index": lane_index,
			"lane_angle_degrees": int(angles[lane_index]) if lane_index < angles.size() else 0,
			"lane_count": directions.size(),
		})
	state.last_event = "cast_release_%d" % wire_id
	return projectiles


static func _rotate_fixed_direction(direction: Vector2i, rotation: Vector2i) -> Vector2i:
	@warning_ignore("integer_division")
	var rotated := Vector2i(
		(direction.x * rotation.x - direction.y * rotation.y) / SimConfig.FIXED_SCALE,
		(direction.x * rotation.y + direction.y * rotation.x) / SimConfig.FIXED_SCALE,
	)
	return SimCommand._normalized_direction(rotated.x, rotated.y)


static func _release_field(
	state: PlayerState,
	wire_id: int,
	field_id: int,
	definition: Dictionary,
	config: SimConfig,
	world: CollisionWorld,
	events: Array[Dictionary],
) -> FieldState:
	var direction := Vector2i(state.pending_cast_aim_x, state.pending_cast_aim_y)
	var maximum_range := int(definition["range"])
	var field_radius := int(definition["radius"])
	var placement := _field_placement(state, direction, maximum_range, field_radius, world)
	state.pending_cast_wire_id = 0
	state.pending_cast_ticks = 0
	if placement == Vector2i.ZERO:
		events.append({"type": "cast_blocked", "entity_id": state.entity_id, "wire_id": wire_id})
		state.last_event = "cast_blocked_%d" % wire_id
		return null
	var field := FieldState.new(
		field_id,
		state.entity_id,
		state.team_id,
		wire_id,
		int(definition["element_wire_id"]),
		placement,
		field_radius,
		config.milliseconds_to_ticks(int(definition["lifetime_ms"])),
		int(definition["hit_control_state"]),
		int(definition["hit_control_duration_ms"]),
		int(definition["hit_control_slow_ratio"]),
	)
	events.append({
		"type": "field_spawned",
		"field_id": field_id,
		"owner_id": state.entity_id,
		"source_wire_id": wire_id,
		"position_x": placement.x,
		"position_y": placement.y,
		"radius": field.radius,
	})
	state.last_event = "cast_release_%d" % wire_id
	return field


static func _field_placement(state: PlayerState, direction: Vector2i, maximum_range: int, field_radius: int, world: CollisionWorld) -> Vector2i:
	const TRACE_STEP: int = 8_000
	var minimum_range := state.radius + field_radius
	var distance := maximum_range
	while distance >= minimum_range:
		@warning_ignore("integer_division")
		var candidate := Vector2i(
			state.position_x + direction.x * distance / SimConfig.FIXED_SCALE,
			state.position_y + direction.y * distance / SimConfig.FIXED_SCALE,
		)
		if world.can_occupy(candidate, field_radius):
			return candidate
		distance -= TRACE_STEP
	return Vector2i.ZERO


static func advance_fields(
	fields: Array[FieldState],
	players: Array[PlayerState],
	config: SimConfig,
	events: Array[Dictionary],
) -> Array[FieldState]:
	var survivors: Array[FieldState] = []
	var ordered_players: Array[PlayerState] = players.duplicate()
	ordered_players.sort_custom(func(left: PlayerState, right: PlayerState) -> bool: return left.entity_id < right.entity_id)
	for field: FieldState in fields:
		for target: PlayerState in ordered_players:
			if (
				target.entity_id == field.owner_id
				or target.team_id == field.team_id
				or target.health <= 0
				or target.spawn_protection_ticks > 0
				or MovementSystem.is_combat_intangible(target, config)
				or field.has_affected(target.entity_id)
			):
				continue
			var offset := Vector2i(target.position_x - field.position_x, target.position_y - field.position_y)
			var contact_radius := target.radius + field.radius
			if offset.length_squared() > contact_radius * contact_radius:
				continue
			MovementSystem.apply_control_state(
				target,
				field.hit_control_state,
				field.hit_control_duration_ms,
				Vector2i.ZERO,
				0,
				config,
				field.hit_control_slow_ratio,
			)
			field.record_affected(target.entity_id)
			events.append({
				"type": "field_triggered",
				"field_id": field.entity_id,
				"owner_id": field.owner_id,
				"source_wire_id": field.source_wire_id,
				"target_id": target.entity_id,
			})
		field.lifetime_ticks = maxi(0, field.lifetime_ticks - 1)
		if field.lifetime_ticks == 0:
			events.append({"type": "field_expired", "field_id": field.entity_id})
			continue
		survivors.append(field)
	return survivors


static func _queue_instant_cast(
	state: PlayerState,
	wire_id: int,
	shape: String,
	events: Array[Dictionary],
) -> void:
	events.append({
		"type": "%s_requested" % shape,
		"owner_id": state.entity_id,
		"source_wire_id": wire_id,
		"origin_x": state.position_x,
		"origin_y": state.position_y,
		"aim_x": state.pending_cast_aim_x,
		"aim_y": state.pending_cast_aim_y,
	})
	state.pending_cast_wire_id = 0
	state.pending_cast_ticks = 0
	state.last_event = "cast_release_%d" % wire_id


static func resolve_instant_casts(
	players: Array[PlayerState],
	config: SimConfig,
	world: CollisionWorld,
	events: Array[Dictionary],
	reactions: Array = [],
	current_tick: int = 0,
) -> void:
	var resolved_events: Array[Dictionary] = []
	for event: Dictionary in events:
		var request_type := String(event.get("type", ""))
		if request_type not in ["beam_requested", "spray_requested"]:
			resolved_events.append(event)
			continue
		var owner: PlayerState = null
		var owner_id := int(event.get("owner_id", 0))
		for candidate: PlayerState in players:
			if candidate.entity_id == owner_id:
				owner = candidate
				break
		if owner == null:
			continue
		var wire_id := int(event.get("source_wire_id", 0))
		var definition := CombatTuning.cast_definition(wire_id)
		var shape := request_type.trim_suffix("_requested")
		if String(definition.get("shape", "")) != shape:
			continue
		var origin := Vector2i(int(event.get("origin_x", 0)), int(event.get("origin_y", 0)))
		var direction := Vector2i(int(event.get("aim_x", 1000)), int(event.get("aim_y", 0)))
		var endpoint := _beam_clear_endpoint(
			origin,
			direction,
			int(definition["range"]),
			int(definition["radius"]),
			world,
		)
		if endpoint == origin:
			resolved_events.append({"type": "cast_blocked", "entity_id": owner.entity_id, "wire_id": wire_id})
			owner.last_event = "cast_blocked_%d" % wire_id
			continue

		if shape == "spray":
			_resolve_spray(owner, wire_id, definition, origin, direction, endpoint, players, config, world, resolved_events, reactions, current_tick)
			continue
		if not reactions.is_empty() and _resolve_chemistry_beam(owner, wire_id, definition, origin, endpoint, players, config, world, resolved_events, reactions, current_tick):
			continue
		var target: PlayerState = _first_beam_target(owner, origin, endpoint, int(definition["radius"]), players, config)
		if target != null:
			endpoint = Vector2i(target.position_x, target.position_y)
			PlayerResourcesSystem.damage(target, int(definition["damage"]), config)
			if target.health > 0 and int(definition["hit_control_duration_ms"]) > 0:
				MovementSystem.apply_control_state(
					target,
					int(definition["hit_control_state"]),
					int(definition["hit_control_duration_ms"]),
					direction,
					int(definition["hit_control_speed"]),
					config,
					int(definition["hit_control_slow_ratio"]),
				)
		resolved_events.append({
			"type": "beam_fired",
			"owner_id": owner.entity_id,
			"source_wire_id": wire_id,
			"target_id": target.entity_id if target != null else 0,
			"end_x": endpoint.x,
			"end_y": endpoint.y,
			"damage": int(definition["damage"]) if target != null else 0,
		})
		if target != null and target.actor_kind == PlayerState.ActorKind.CHAMPION and target.health == 0:
			resolved_events.append({
				"type": "champion_defeated",
				"projectile_id": 0,
				"owner_id": owner.entity_id,
				"target_id": target.entity_id,
			})
	events.clear()
	events.append_array(resolved_events)


static func _resolve_spray(
	owner: PlayerState,
	wire_id: int,
	definition: Dictionary,
	origin: Vector2i,
	direction: Vector2i,
	endpoint: Vector2i,
	players: Array[PlayerState],
	config: SimConfig,
	world: CollisionWorld,
	resolved_events: Array[Dictionary],
	reactions: Array = [],
	current_tick: int = 0,
) -> void:
	var hit_events: Array[Dictionary] = []
	var hit_count: int = 0
	var ordered_players: Array[PlayerState] = players.duplicate()
	ordered_players.sort_custom(func(left: PlayerState, right: PlayerState) -> bool: return left.entity_id < right.entity_id)
	var maximum_range := int(definition["range"])
	var maximum_range_squared := maximum_range * maximum_range
	var cone_threshold := int(definition["cone_cosine_squared_per_million"])
	for target: PlayerState in ordered_players:
		if target.entity_id == owner.entity_id or target.team_id == owner.team_id or target.health <= 0 or target.spawn_protection_ticks > 0:
			continue
		var offset := Vector2i(target.position_x, target.position_y) - origin
		var distance_squared := offset.length_squared()
		if distance_squared <= 0 or distance_squared > maximum_range_squared:
			continue
		var projection := offset.x * direction.x + offset.y * direction.y
		if projection <= 0 or projection * projection < distance_squared * cone_threshold:
			continue
		var distance := SimCommand._integer_square_root(distance_squared)
		var target_direction := SimCommand._normalized_direction(offset.x, offset.y)
		var clear_endpoint := _beam_clear_endpoint(origin, target_direction, distance, int(definition["radius"]), world)
		var remaining := Vector2i(target.position_x, target.position_y) - clear_endpoint
		var hit_radius: int = target.radius + int(definition["radius"])
		if remaining.length_squared() > hit_radius * hit_radius:
			continue
		if _spray_cover_intercepts(origin, Vector2i(target.position_x,target.position_y), int(definition["damage"]), reactions, current_tick, config):
			continue
		if MovementSystem.is_combat_intangible(target, config):
			target.last_event = "evaded_spray"
			continue
		PlayerResourcesSystem.damage(target, int(definition["damage"]), config)
		if target.health > 0 and int(definition["hit_control_duration_ms"]) > 0:
			MovementSystem.apply_control_state(
				target,
				int(definition["hit_control_state"]),
				int(definition["hit_control_duration_ms"]),
				target_direction,
				int(definition["hit_control_speed"]),
				config,
				int(definition["hit_control_slow_ratio"]),
			)
		hit_events.append({
			"type": "spray_hit",
			"owner_id": owner.entity_id,
			"source_wire_id": wire_id,
			"target_id": target.entity_id,
			"damage": int(definition["damage"]),
		})
		hit_count += 1
		if target.actor_kind == PlayerState.ActorKind.CHAMPION and target.health == 0:
			hit_events.append({
				"type": "champion_defeated",
				"projectile_id": 0,
				"owner_id": owner.entity_id,
				"target_id": target.entity_id,
			})
	resolved_events.append({
		"type": "spray_fired",
		"owner_id": owner.entity_id,
		"source_wire_id": wire_id,
		"end_x": endpoint.x,
		"end_y": endpoint.y,
		"hit_count": hit_count,
	})
	resolved_events.append_array(hit_events)


static func _resolve_chemistry_beam(owner: PlayerState, wire_id: int, definition: Dictionary, origin: Vector2i, endpoint: Vector2i, players: Array[PlayerState], config: SimConfig, world: CollisionWorld, events: Array[Dictionary], reactions: Array, tick: int) -> bool:
	var original_target := _first_beam_target(owner,origin,endpoint,int(definition["radius"]),players,config)
	var first_point := Vector2i(original_target.position_x,original_target.position_y) if original_target != null else Vector2i(-1,-1)
	var optical := ElementChemistrySystem.ray_interaction(origin,endpoint,int(definition["element_wire_id"]),int(definition["damage"]),reactions,tick,0,first_point)
	if not bool(optical["transformed"]):
		return false
	var entry: Vector2i = optical["entry_point"]
	if not bool(optical["blocked"]):
		events.append({"type":"beam_fired","owner_id":owner.entity_id,"source_wire_id":wire_id,"target_id":0,"origin_x":origin.x,"origin_y":origin.y,"end_x":entry.x,"end_y":entry.y,"damage":0})
	for ray: Dictionary in optical["rays"]:
		var ray_origin: Vector2i = ray["origin"]
		var requested_end: Vector2i = ray["end"]
		var ray_delta := requested_end-ray_origin
		var direction := SimCommand._normalized_direction(ray_delta.x,ray_delta.y)
		var distance := SimCommand._integer_square_root(ray_delta.length_squared())
		var ray_end := _beam_clear_endpoint(ray_origin,direction,distance,int(definition["radius"]),world)
		var target := _first_beam_target(owner,ray_origin,ray_end,int(definition["radius"]),players,config)
		var actual_damage := 0
		if target != null:
			ray_end = Vector2i(target.position_x,target.position_y)
			if PlayerResourcesSystem.damage(target,int(ray["damage"]),config):
				actual_damage = int(ray["damage"])
			if actual_damage > 0 and target.health > 0 and int(definition["hit_control_duration_ms"]) > 0:
				MovementSystem.apply_control_state(target,int(definition["hit_control_state"]),int(definition["hit_control_duration_ms"]),direction,int(definition["hit_control_speed"]),config,int(definition["hit_control_slow_ratio"]))
		events.append({"type":"beam_fired","owner_id":owner.entity_id,"source_wire_id":wire_id,"target_id":target.entity_id if target != null else 0,"origin_x":ray_origin.x,"origin_y":ray_origin.y,"end_x":ray_end.x,"end_y":ray_end.y,"damage":actual_damage})
		if target != null and target.health == 0 and target.actor_kind == PlayerState.ActorKind.CHAMPION:
			events.append({"type":"champion_defeated","projectile_id":0,"owner_id":owner.entity_id,"target_id":target.entity_id})
	return true


static func _spray_cover_intercepts(origin: Vector2i,endpoint: Vector2i,damage: int,reactions: Array,tick: int,config: SimConfig) -> bool:
	for result: ElementReactionState in reactions:
		if not result.active(tick) or result.health <= 0 or result.recipe_wire_id not in [301,305,306,307,327,329]:
			continue
		if not ElementChemistrySystem._segment_enters(result,origin,endpoint,tick,config):
			continue
		result.health = maxi(0,result.health-damage)
		if result.health == 0:
			result.decay_tick = mini(result.decay_tick,tick)
		return true
	return false


static func _beam_clear_endpoint(
	origin: Vector2i,
	direction: Vector2i,
	maximum_range: int,
	radius: int,
	world: CollisionWorld,
) -> Vector2i:
	const TRACE_STEP: int = 2_000
	var endpoint := origin
	var distance: int = TRACE_STEP
	while distance <= maximum_range + TRACE_STEP:
		var bounded_distance := mini(distance, maximum_range)
		@warning_ignore("integer_division")
		var candidate := Vector2i(
			origin.x + direction.x * bounded_distance / SimConfig.FIXED_SCALE,
			origin.y + direction.y * bounded_distance / SimConfig.FIXED_SCALE,
		)
		if not world.can_occupy(candidate, radius):
			break
		endpoint = candidate
		if bounded_distance == maximum_range:
			break
		distance += TRACE_STEP
	return endpoint


static func _first_beam_target(
	owner: PlayerState,
	origin: Vector2i,
	endpoint: Vector2i,
	beam_radius: int,
	players: Array[PlayerState],
	config: SimConfig,
) -> PlayerState:
	var delta := endpoint - origin
	var length_squared: int = delta.length_squared()
	var best: PlayerState = null
	var best_projection: int = length_squared + 1
	var ordered_players: Array[PlayerState] = players.duplicate()
	ordered_players.sort_custom(func(left: PlayerState, right: PlayerState) -> bool: return left.entity_id < right.entity_id)
	for target: PlayerState in ordered_players:
		if target.entity_id == owner.entity_id or target.team_id == owner.team_id or target.health <= 0 or target.spawn_protection_ticks > 0:
			continue
		var offset := Vector2i(target.position_x, target.position_y) - origin
		var projection: int = offset.x * delta.x + offset.y * delta.y
		if projection <= 0 or projection > length_squared or projection >= best_projection:
			continue
		@warning_ignore("integer_division")
		var closest := Vector2i(
			origin.x + delta.x * projection / length_squared,
			origin.y + delta.y * projection / length_squared,
		)
		var separation := Vector2i(target.position_x, target.position_y) - closest
		var hit_radius: int = target.radius + beam_radius
		if separation.length_squared() > hit_radius * hit_radius:
			continue
		if MovementSystem.is_combat_intangible(target, config):
			target.last_event = "evaded_beam"
			continue
		best = target
		best_projection = projection
	return best


static func _reflect_projectile(projectile: ProjectileState, wall_normal: Vector2i) -> void:
	if wall_normal.x != 0:
		projectile.velocity_x = -projectile.velocity_x
		projectile.remainder_x = -projectile.remainder_x
	if wall_normal.y != 0:
		projectile.velocity_y = -projectile.velocity_y
		projectile.remainder_y = -projectile.remainder_y


static func _resolve_edgeweave(
	projectile: ProjectileState,
	players: Array[PlayerState],
	hit_entity_id: int,
	config: SimConfig,
	events: Array[Dictionary],
) -> void:
	if CombatTuning.projectile_definition(projectile.source_wire_id).is_empty():
		return
	for target: PlayerState in players:
		if (
			target.entity_id == projectile.owner_id
			or target.entity_id == hit_entity_id
			or target.team_id == projectile.team_id
			or target.health <= 0
			or target.edgeweave_cooldown_ticks > 0
			or MovementSystem.is_combat_intangible(target, config)
			or target.stamina >= target.stamina_maximum
			or projectile.has_grazed(target.entity_id)
			or target.velocity_x * target.velocity_x + target.velocity_y * target.velocity_y < CombatTuning.EDGEWEAVE_MINIMUM_SPEED * CombatTuning.EDGEWEAVE_MINIMUM_SPEED
		):
			continue
		var hit_radius: int = target.radius + projectile.radius
		if _segment_circle_hit(projectile, target, hit_radius):
			continue
		if not _segment_circle_hit(projectile, target, hit_radius + CombatTuning.EDGEWEAVE_MARGIN):
			continue
		var reward: int = mini(CombatTuning.EDGEWEAVE_REWARD, target.stamina_maximum - target.stamina)
		target.stamina += reward
		target.stamina_remainder = 0
		target.stamina_recovery_delay_ticks = config.milliseconds_to_ticks(MovementTuning.STAMINA_RECOVERY_DELAY_MS)
		target.edgeweave_cooldown_ticks = config.milliseconds_to_ticks(CombatTuning.EDGEWEAVE_COOLDOWN_MS)
		target.last_event = "edgeweave"
		projectile.record_graze(target.entity_id)
		events.append({
			"type": "edgeweave",
			"entity_id": target.entity_id,
			"projectile_id": projectile.entity_id,
			"stamina": reward,
		})


static func _segment_circle_hit(projectile: ProjectileState, target: PlayerState, radius: int) -> bool:
	var delta_x: int = projectile.position_x - projectile.previous_x
	var delta_y: int = projectile.position_y - projectile.previous_y
	var offset_x: int = target.position_x - projectile.previous_x
	var offset_y: int = target.position_y - projectile.previous_y
	var length_squared: int = delta_x * delta_x + delta_y * delta_y
	if length_squared == 0:
		return offset_x * offset_x + offset_y * offset_y <= radius * radius
	var projection: int = clampi(offset_x * delta_x + offset_y * delta_y, 0, length_squared)
	@warning_ignore("integer_division")
	var closest_x: int = projectile.previous_x + delta_x * projection / length_squared
	@warning_ignore("integer_division")
	var closest_y: int = projectile.previous_y + delta_y * projection / length_squared
	var distance_x: int = target.position_x - closest_x
	var distance_y: int = target.position_y - closest_y
	return distance_x * distance_x + distance_y * distance_y <= radius * radius
