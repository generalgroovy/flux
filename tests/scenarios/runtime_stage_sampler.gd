extends RefCounted

# Diagnostic-only orchestration of SimWorld.step. All mechanics are calls to the
# production subsystem methods; the probe compares state/events to real step()
# after EVERY measured tick and rejects divergence. Never used by the game.
const Targets = preload("res://src/sim/combat/training_target_system.gd")
const STAGES := ["commands", "resources", "movement", "casts", "instant_casts", "fields", "capacity", "projectiles", "terminals", "chemistry", "targets"]

static func measured_step(world: SimWorld, commands: Array[SimCommand]) -> Dictionary:
	var times := {}
	for stage: String in STAGES:
		times[stage] = 0
	var started := Time.get_ticks_usec()
	if not world.is_valid():
		return {"ok": false, "times": times}
	var ordered: Array[SimCommand] = commands.duplicate()
	ordered.sort_custom(func(left: SimCommand, right: SimCommand) -> bool: return left.entity_id < right.entity_id)
	var by_entity: Dictionary[int, SimCommand] = {}
	world.combat_events = []
	for command: SimCommand in ordered:
		if command.tick != world.tick or by_entity.has(command.entity_id) or world.player(command.entity_id) == null:
			return {"ok": false, "times": times}
		by_entity[command.entity_id] = command
	var actors: Array[PlayerState] = world.players.duplicate()
	actors.sort_custom(func(left: PlayerState, right: PlayerState) -> bool: return left.entity_id < right.entity_id)
	times.commands = Time.get_ticks_usec() - started
	for state: PlayerState in actors:
		if state.health <= 0:
			world._idle_defeated(state)
			continue
		var command: SimCommand = by_entity.get(state.entity_id, null)
		if command == null:
			command = SimCommand.new(world.tick, state.entity_id, 0, 0, 0, 0, state.aim_x, state.aim_y)
		state.aim_x = command.aim_x
		state.aim_y = command.aim_y
		state.primary_held = command.has_held(SimCommand.HELD_PRIMARY)
		started = Time.get_ticks_usec()
		PlayerResourcesSystem.step(state, world.config)
		times.resources += Time.get_ticks_usec() - started
		started = Time.get_ticks_usec()
		MovementSystem.step(state, command, world.config, world.collision)
		times.movement += Time.get_ticks_usec() - started
		started = Time.get_ticks_usec()
		var capacity := Vector2i.ZERO
		if state.pending_cast_wire_id == 0 and (command.first_pressed_spell_slot() > 0 or command.first_held_spell_slot() > 0 or command.has_pressed(SimCommand.PRESSED_ACTIVE_1) or command.has_held(SimCommand.HELD_PRIMARY)):
			capacity = world.available_cast_capacity(state.entity_id)
		times.capacity += Time.get_ticks_usec() - started
		started = Time.get_ticks_usec()
		var spawned: Variant = CombatSystem.step_player(state, command, world.config, world.next_projectile_id, world.next_field_id, world.collision, world.combat_events, world.transition_policy, capacity.x, capacity.y)
		world._store_combat_result(spawned)
		times.casts += Time.get_ticks_usec() - started
	started = Time.get_ticks_usec()
	CombatSystem.resolve_instant_casts(world.players, world.config, world.collision, world.combat_events, world.reactions, world.tick)
	times.instant_casts = Time.get_ticks_usec() - started
	started = Time.get_ticks_usec()
	world.fields.sort_custom(func(left: FieldState, right: FieldState) -> bool: return left.entity_id < right.entity_id)
	world.fields = CombatSystem.advance_fields(world.fields, world.players, world.config, world.combat_events)
	times.fields = Time.get_ticks_usec() - started
	started = Time.get_ticks_usec()
	world.projectiles.sort_custom(func(left: ProjectileState, right: ProjectileState) -> bool: return left.entity_id < right.entity_id)
	var owner_slots := {}
	for state: PlayerState in world.players:
		owner_slots[state.entity_id] = world.available_cast_capacity(state.entity_id).x
	var free_slots := world._free_material_slots()
	times.capacity += Time.get_ticks_usec() - started
	started = Time.get_ticks_usec()
	world.projectiles = CombatSystem.advance_projectiles(world.projectiles, world.players, world.config, world.collision, world.combat_events, world.reactions, world.tick, free_slots, owner_slots)
	times.projectiles = Time.get_ticks_usec() - started
	started = Time.get_ticks_usec()
	world._consume_projectile_terminals()
	times.terminals = Time.get_ticks_usec() - started
	started = Time.get_ticks_usec()
	world.next_reaction_id = ElementChemistrySystem.step(world.deposits, world.reactions, world.players, world.collision, world.config, world.tick, world.next_reaction_id, world.combat_events)
	times.chemistry = Time.get_ticks_usec() - started
	started = Time.get_ticks_usec()
	for state: PlayerState in actors:
		Targets.step_target(state, world.config)
	times.targets = Time.get_ticks_usec() - started
	world.tick += 1
	return {"ok": true, "times": times}
