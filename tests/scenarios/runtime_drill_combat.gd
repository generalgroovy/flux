extends "res://src/sim/combat/combat_system.gd"
@warning_ignore_start("integer_division")

# TEST ONLY: unchanged source-derived loop, one observed interaction call.
# All movement/contact/edgeweave/terminal helpers remain production methods.
const DrillChemistry = preload("res://tests/scenarios/runtime_drill_chemistry.gd")

static func measured_advance_projectiles(
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
			var interaction := DrillChemistry.measured_interaction(projectile, reactions, world, config, current_tick, split_capacity)
			if bool(interaction.get("blocked", false)):
				_rewind_heavy_cover_contact(projectile, config, world, reactions, current_tick)
				_explode_projectile(projectile, ordered_players, config, world, reactions, current_tick, events)
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
			_explode_projectile(projectile, ordered_players, config, world, reactions, current_tick, events, hit_entity_id)
			_emit_terminal(projectile, events, "actor")
			continue
		if result.wall_normal != Vector2i.ZERO:
			events.append({"type": "projectile_impact", "projectile_id": projectile.entity_id, "wall_id": result.wall_id})
			_explode_projectile(projectile, ordered_players, config, world, reactions, current_tick, events)
			_emit_terminal(projectile, events, "obstacle")
			continue
		projectile.lifetime_ticks = maxi(0, projectile.lifetime_ticks - 1)
		if projectile.lifetime_ticks == 0 or projectile.remaining_distance == 0:
			events.append({"type": "projectile_expired", "projectile_id": projectile.entity_id})
			_explode_projectile(projectile, ordered_players, config, world, reactions, current_tick, events)
			_emit_terminal(projectile, events, "range")
			continue
		survivors.append(projectile)
	return survivors
