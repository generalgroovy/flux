extends FluxTestSuite


func run() -> int:
	for tick_rate: int in [60, 120]:
		_test_advanced_route(tick_rate)
	return finish("conservatory-route")


func _step(world: SimWorld, move_x: int = 0, move_y: int = 0, held: int = 0, pressed: int = 0) -> bool:
	return world.step([SimCommand.new(world.tick, 1, move_x, move_y, held, pressed)])


func _test_advanced_route(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate, 424242)
	var state: PlayerState = world.player()
	var route_events := PackedStringArray()
	var all_steps_succeeded: bool = true

	for _index: int in range(tick_rate / 2):
		all_steps_succeeded = _step(world, 1000, 0, SimCommand.HELD_SPRINT) and all_steps_succeeded
	all_steps_succeeded = _step(world, 1000, 0, SimCommand.HELD_SPRINT, SimCommand.PRESSED_JUMP) and all_steps_succeeded
	route_events.append(state.last_event)
	var slide_jump_window: int = world.config.milliseconds_to_ticks(MovementTuning.SLIDE_JUMP_WINDOW_MS)
	while state.slide_ticks > slide_jump_window:
		all_steps_succeeded = _step(world, 1000, 0) and all_steps_succeeded
	all_steps_succeeded = _step(world, 1000, 0, 0, SimCommand.PRESSED_JUMP) and all_steps_succeeded
	route_events.append(state.last_event)
	all_steps_succeeded = _step(world, 0, -1000, 0, SimCommand.PRESSED_TECHNIQUE) and all_steps_succeeded
	route_events.append(state.last_event)

	# The training reset between marked route stations is an authored safe action.
	state.position_x = 760_000
	state.position_y = 340_000
	state.velocity_x = 0
	state.velocity_y = 0
	state.hop_ticks = 0
	state.slide_ticks = 0
	state.stamina = MovementTuning.STAMINA_MAXIMUM
	all_steps_succeeded = _step(world, 1000, 0, 0, SimCommand.PRESSED_TECHNIQUE) and all_steps_succeeded
	route_events.append(state.last_event)
	var crest_end: int = world.config.milliseconds_to_ticks(MovementTuning.VAULT_CREST_END_MS)
	while state.vault_ticks > crest_end:
		all_steps_succeeded = _step(world, 1000, 0) and all_steps_succeeded
	all_steps_succeeded = _step(world, 1000, 0, 0, SimCommand.PRESSED_JUMP) and all_steps_succeeded
	route_events.append(state.last_event)

	check(all_steps_succeeded, "%d Hz Conservatory route commands all step" % tick_rate)
	equal(route_events, PackedStringArray(["slide", "slide_jump", "air_redirect", "vault", "superglide"]), "%d Hz route reaches the same authored transitions" % tick_rate)
	check(world.collision.can_occupy(Vector2i(state.position_x, state.position_y), state.radius), "%d Hz route ends in valid collision space" % tick_rate)
	check(absi(state.velocity_x) <= MovementTuning.MAX_AUTHORED_SPEED and absi(state.velocity_y) <= MovementTuning.MAX_AUTHORED_SPEED, "%d Hz route remains under the speed ceiling" % tick_rate)
