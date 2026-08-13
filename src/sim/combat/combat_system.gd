class_name CombatSystem
extends RefCounted


static func step_player(
	state: PlayerState,
	command: SimCommand,
	config: SimConfig,
	projectile_id: int,
	world: CollisionWorld,
	events: Array[Dictionary],
) -> ProjectileState:
	for property_name: StringName in [
		&"cast_recovery_ticks", &"primary_cooldown_ticks",
		&"active_1_cooldown_ticks", &"edgeweave_cooldown_ticks",
	]:
		state.set(property_name, maxi(0, int(state.get(property_name)) - 1))

	if state.pending_cast_wire_id != 0:
		state.pending_cast_ticks = maxi(0, state.pending_cast_ticks - 1)
		if state.pending_cast_ticks == 0:
			return _release_cast(state, config, projectile_id, world, events)
		return null
	if state.cast_recovery_ticks > 0:
		return null

	var requested_spell_slot: int = command.first_pressed_spell_slot()
	if requested_spell_slot >= 3:
		events.append({
			"type": "cast_refused",
			"entity_id": state.entity_id,
			"wire_id": 0,
			"reason": "empty_slot",
			"slot": requested_spell_slot,
		})
		state.last_event = "cast_refused_slot_%d" % requested_spell_slot
		return null

	if command.has_pressed(SimCommand.PRESSED_ACTIVE_1) or requested_spell_slot == 2:
		if state.active_1_cooldown_ticks > 0:
			return null
		var active_definition := CombatTuning.projectile_definition(state.active_1_wire_id)
		if active_definition.is_empty():
			events.append({"type": "cast_refused", "entity_id": state.entity_id, "wire_id": state.active_1_wire_id, "reason": "kit"})
			return null
		if not PlayerResourcesSystem.spend_flux(state, int(active_definition["flux_cost"]), config):
			events.append({"type": "cast_refused", "entity_id": state.entity_id, "wire_id": state.active_1_wire_id, "reason": "flux"})
			return null
		_begin_cast(state, state.active_1_wire_id, int(active_definition["startup_ms"]), config)
		events.append({"type": "cast_started", "entity_id": state.entity_id, "wire_id": state.active_1_wire_id})
		return null
	if (command.has_held(SimCommand.HELD_PRIMARY) or requested_spell_slot == 1) and state.primary_cooldown_ticks == 0:
		var primary_definition := CombatTuning.projectile_definition(state.primary_wire_id)
		if primary_definition.is_empty():
			events.append({"type": "cast_refused", "entity_id": state.entity_id, "wire_id": state.primary_wire_id, "reason": "kit"})
			return null
		_begin_cast(state, state.primary_wire_id, int(primary_definition["startup_ms"]), config)
		events.append({"type": "cast_started", "entity_id": state.entity_id, "wire_id": state.primary_wire_id})
	return null


static func advance_projectiles(
	projectiles: Array[ProjectileState],
	players: Array[PlayerState],
	config: SimConfig,
	world: CollisionWorld,
	events: Array[Dictionary],
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
		var result: CollisionWorld.MoveResult = world.move_box(
			Vector2i(projectile.position_x, projectile.position_y),
			delta,
			projectile.radius,
		)
		projectile.position_x = result.position.x
		projectile.position_y = result.position.y

		var hit_entity_id: int = 0
		for target: PlayerState in ordered_players:
			if target.entity_id == projectile.owner_id or target.team_id == projectile.team_id or target.health <= 0 or target.spawn_protection_ticks > 0:
				continue
			var hit_radius: int = target.radius + projectile.radius
			if _segment_circle_hit(projectile, target, hit_radius):
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
			continue
		if result.wall_normal != Vector2i.ZERO:
			if projectile.remaining_bounces <= 0:
				events.append({"type": "projectile_impact", "projectile_id": projectile.entity_id, "wall_id": result.wall_id})
				continue
			_reflect_projectile(projectile, result.wall_normal)
			projectile.remaining_bounces -= 1
			events.append({
				"type": "projectile_bounced",
				"projectile_id": projectile.entity_id,
				"wall_id": result.wall_id,
				"remaining_bounces": projectile.remaining_bounces,
			})
		projectile.lifetime_ticks = maxi(0, projectile.lifetime_ticks - 1)
		if projectile.lifetime_ticks == 0:
			events.append({"type": "projectile_expired", "projectile_id": projectile.entity_id})
			continue
		survivors.append(projectile)
	return survivors


static func _begin_cast(state: PlayerState, wire_id: int, startup_ms: int, config: SimConfig) -> void:
	state.pending_cast_wire_id = wire_id
	state.pending_cast_ticks = config.milliseconds_to_ticks(startup_ms)
	state.pending_cast_aim_x = state.aim_x
	state.pending_cast_aim_y = state.aim_y
	state.last_event = "cast_start_%d" % wire_id


static func _release_cast(
	state: PlayerState,
	config: SimConfig,
	projectile_id: int,
	world: CollisionWorld,
	events: Array[Dictionary],
) -> ProjectileState:
	var wire_id: int = state.pending_cast_wire_id
	var definition := CombatTuning.projectile_definition(wire_id)
	if definition.is_empty():
		state.pending_cast_wire_id = 0
		state.pending_cast_ticks = 0
		return null
	if wire_id == state.primary_wire_id:
		state.primary_cooldown_ticks = config.milliseconds_to_ticks(int(definition["cooldown_ms"]))
	elif wire_id == state.active_1_wire_id:
		state.active_1_cooldown_ticks = config.milliseconds_to_ticks(int(definition["cooldown_ms"]))
	else:
		state.pending_cast_wire_id = 0
		state.pending_cast_ticks = 0
		return null
	state.cast_recovery_ticks = config.milliseconds_to_ticks(int(definition["recovery_ms"]))
	var speed := int(definition["speed"])
	var radius := int(definition["radius"])

	var direction := Vector2i(state.pending_cast_aim_x, state.pending_cast_aim_y)
	@warning_ignore("integer_division")
	var spawn_distance: int = state.radius + radius + CombatTuning.PROJECTILE_SPAWN_CLEARANCE
	@warning_ignore("integer_division")
	var spawn_position := Vector2i(
		state.position_x + direction.x * spawn_distance / 1000,
		state.position_y + direction.y * spawn_distance / 1000,
	)
	state.pending_cast_wire_id = 0
	state.pending_cast_ticks = 0
	if not world.can_occupy(spawn_position, radius):
		events.append({"type": "cast_blocked", "entity_id": state.entity_id, "wire_id": wire_id})
		state.last_event = "cast_blocked_%d" % wire_id
		return null
	@warning_ignore("integer_division")
	var velocity := Vector2i(direction.x * speed / 1000, direction.y * speed / 1000)
	var projectile := ProjectileState.new(
		projectile_id,
		state.entity_id,
		state.team_id,
		wire_id,
		int(definition["element_wire_id"]),
		spawn_position,
		velocity,
		radius,
		int(definition["damage"]),
		config.milliseconds_to_ticks(int(definition["lifetime_ms"])),
		int(definition["hit_control_state"]),
		int(definition["hit_control_duration_ms"]),
		int(definition["hit_control_speed"]),
		int(definition["hit_control_slow_ratio"]),
		int(definition["remaining_bounces"]),
	)
	events.append({"type": "projectile_spawned", "projectile_id": projectile_id, "owner_id": state.entity_id, "wire_id": wire_id})
	state.last_event = "cast_release_%d" % wire_id
	return projectile


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
