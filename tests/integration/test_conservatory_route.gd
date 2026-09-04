extends FluxTestSuite


func run() -> int:
	for tick_rate: int in [120]:
		_test_advanced_route(tick_rate)
		_test_momentum_chime_route(tick_rate)
	return finish("conservatory-route")


func _step(world: SimWorld, move_x: int = 0, move_y: int = 0, held: int = 0, pressed: int = 0) -> bool:
	return world.step([SimCommand.new(world.tick, 1, move_x, move_y, held, pressed)])


func _test_advanced_route(tick_rate: int) -> void:
	var layout := SanctumCampusLayout.new()
	check(layout.load_from_file("res://content/maps/sanctum_campus_g2_v1.json"), "movement route loads live campus")
	var world := SimWorld.new(tick_rate, 424242, layout.build_collision_world(), String(layout.data["id"]), layout.content_hash)
	world.player().position_x = 240_000
	world.player().position_y = 832_000
	var state: PlayerState = world.player()
	var route_events := PackedStringArray()
	var all_steps_succeeded: bool = true

	for _index: int in range(tick_rate / 2):
		all_steps_succeeded = _step(world, 1000, 0, SimCommand.HELD_SPRINT) and all_steps_succeeded
	all_steps_succeeded = _step(world, 1000, 0, SimCommand.HELD_SPRINT, SimCommand.PRESSED_SLIDE) and all_steps_succeeded
	route_events.append(state.last_event)
	var slide_jump_window: int = world.config.milliseconds_to_ticks(MovementTuning.SLIDE_JUMP_WINDOW_MS)
	while state.slide_ticks > slide_jump_window:
		all_steps_succeeded = _step(world, 1000, 0) and all_steps_succeeded
	all_steps_succeeded = _step(world, 1000, 0, 0, SimCommand.PRESSED_JUMP) and all_steps_succeeded
	route_events.append(state.last_event)
	all_steps_succeeded = _step(world, 0, -1000, 0, SimCommand.PRESSED_TECHNIQUE) and all_steps_succeeded
	route_events.append(state.last_event)

	# An explicit local trial reset starts the contact drill at the authored east wall.
	state.reset_for_spawn(Vector2i(700_000, 480_000))
	state.position_x = 736_000 - state.radius - 1000
	state.position_y = 480_000
	state.velocity_x = MovementTuning.BASE_SPEED
	state.stamina = MovementTuning.STAMINA_MAXIMUM
	all_steps_succeeded = _step(world, 1000, 0) and all_steps_succeeded
	all_steps_succeeded = _step(world, 0, 1000, 0, SimCommand.PRESSED_TECHNIQUE) and all_steps_succeeded
	route_events.append(state.last_event)
	all_steps_succeeded = _step(world, -1000, 0) and all_steps_succeeded
	route_events.append(state.last_event)

	check(all_steps_succeeded, "%d Hz Conservatory route commands all step" % tick_rate)
	equal(route_events, PackedStringArray(["slide", "slide_jump", "air_redirect", "wall_skim", "wall_detach"]), "%d Hz route reaches the same authored transitions" % tick_rate)
	check(world.collision.can_occupy(Vector2i(state.position_x, state.position_y), state.radius), "%d Hz route ends in valid collision space" % tick_rate)
	check(absi(state.velocity_x) <= MovementTuning.MAX_AUTHORED_SPEED and absi(state.velocity_y) <= MovementTuning.MAX_AUTHORED_SPEED, "%d Hz route remains under the speed ceiling" % tick_rate)


func _test_momentum_chime_route(tick_rate: int) -> void:
	var layout := SanctumCampusLayout.new()
	check(layout.load_from_file("res://content/maps/sanctum_campus_g2_v1.json"), "%d Hz Momentum Chime campus loads" % tick_rate)
	var world := SimWorld.new(tick_rate, 424243, layout.build_collision_world(), String(layout.data.get("id", "")), layout.content_hash)
	var state: PlayerState = world.player()
	var chime := SanctumCampusLayout._parse_point(layout.stations_by_id["momentum-chime"]["position"]) * SimConfig.FIXED_SCALE
	state.position_x = chime.x
	state.position_y = chime.y
	state.velocity_x = 0
	state.velocity_y = 0
	var origin := Vector2i(state.position_x, state.position_y)
	check(
		MovementSystem.apply_control_state(state, PlayerState.ControlState.LAUNCHED, 320, Vector2i.UP, 540_000, world.config),
		"%d Hz Momentum Chime launch applies" % tick_rate,
	)
	while state.control_state == PlayerState.ControlState.LAUNCHED:
		_step(world, 1000, 0)
	check(state.impact_recovery_ticks > 0, "%d Hz Chime route reaches the recovery decision" % tick_rate)
	check(state.position_y < origin.y - 100_000, "%d Hz Chime route grants a readable launch lane" % tick_rate)
	check(state.position_x > origin.x, "%d Hz Chime route exposes bounded steering" % tick_rate)
	check(world.collision.can_occupy(Vector2i(state.position_x, state.position_y), state.radius), "%d Hz Chime recovery remains in legal campus space" % tick_rate)
	var stamina_before: int = state.stamina
	_step(world, 1000, 0, 0, SimCommand.PRESSED_TECHNIQUE)
	equal(state.last_event, "impact_tech", "%d Hz Chime route accepts the taught impact tech" % tick_rate)
	equal(state.stamina, stamina_before - MovementTuning.IMPACT_RECOVERY_TECH_COST, "%d Hz Chime route pays the advertised Stamina" % tick_rate)
	check(world.collision.can_occupy(Vector2i(state.position_x, state.position_y), state.radius), "%d Hz Chime tech remains in legal campus space" % tick_rate)
