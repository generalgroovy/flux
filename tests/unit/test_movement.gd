extends FluxTestSuite


func run() -> int:
	for tick_rate: int in [60, 120]:
		_test_sprint_and_hop(tick_rate)
		_test_double_jump(tick_rate)
		_test_slide_and_slide_jump(tick_rate)
		_test_air_dodge_and_wavedash(tick_rate)
		_test_wall_contact_and_wall_kick(tick_rate)
		_test_vault_and_superglide(tick_rate)
	return finish("movement")


func _step(world: SimWorld, move_x: int = 0, move_y: int = 0, held: int = 0, pressed: int = 0) -> void:
	check(world.step([SimCommand.new(world.tick, 1, move_x, move_y, held, pressed)]), "world step succeeds")


func _test_sprint_and_hop(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	for _index: int in range(tick_rate / 2):
		_step(world, 1000, 0, SimCommand.HELD_SPRINT)
	var state: PlayerState = world.player()
	check(state.position_x > 160_000, "%d Hz sprint advances" % tick_rate)
	check(state.flow < MovementTuning.FLOW_MAXIMUM, "%d Hz sprint drains flow" % tick_rate)
	var before_flow: int = state.flow
	_step(world, 1000, 0, 0, SimCommand.PRESSED_JUMP)
	equal(state.last_event, "hop", "%d Hz starts hop" % tick_rate)
	equal(state.flow, before_flow - MovementTuning.HOP_COST, "%d Hz hop cost is exact" % tick_rate)
	check(state.hop_ticks > 0, "%d Hz hop is airborne" % tick_rate)


func _test_double_jump(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var state: PlayerState = world.player()
	_step(world, 1000, 0, 0, SimCommand.PRESSED_JUMP)
	var after_hop: int = state.flow
	_step(world, 0, -1000, 0, SimCommand.PRESSED_JUMP)
	equal(state.last_event, "double_jump", "%d Hz second edge triggers double jump" % tick_rate)
	equal(state.flow, after_hop - MovementTuning.DOUBLE_JUMP_COST, "%d Hz double jump cost is exact" % tick_rate)
	equal(state.hop_stage, 2, "%d Hz double jump is bounded to stage two" % tick_rate)
	var after_double: int = state.flow
	_step(world, -1000, 0, 0, SimCommand.PRESSED_JUMP)
	equal(state.flow, after_double, "%d Hz third jump cannot stack" % tick_rate)


func _test_slide_and_slide_jump(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var state: PlayerState = world.player()
	@warning_ignore("integer_division")
	for _index: int in range(tick_rate / 2):
		_step(world, 1000, 0, SimCommand.HELD_SPRINT)
	_step(world, 1000, 0, SimCommand.HELD_SPRINT, SimCommand.PRESSED_JUMP)
	equal(state.last_event, "slide", "%d Hz sprint+jump enters slide" % tick_rate)
	var late_window: int = world.config.milliseconds_to_ticks(MovementTuning.SLIDE_JUMP_WINDOW_MS)
	while state.slide_ticks > late_window:
		_step(world, 1000, 0)
	_step(world, 1000, 0, 0, SimCommand.PRESSED_JUMP)
	equal(state.last_event, "slide_jump", "%d Hz late slide converts" % tick_rate)
	check(state.hop_speed == MovementTuning.SLIDE_JUMP_SPEED, "%d Hz slide jump speed is authored" % tick_rate)


func _test_air_dodge_and_wavedash(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var state: PlayerState = world.player()
	_step(world, 1000, 0, 0, SimCommand.PRESSED_JUMP)
	var window: int = world.config.milliseconds_to_ticks(MovementTuning.WAVE_DASH_INPUT_WINDOW_MS)
	while state.hop_ticks > window:
		_step(world, 1000, 0)
	_step(world, 0, 1000, SimCommand.HELD_SPRINT, SimCommand.PRESSED_TECHNIQUE)
	equal(state.last_event, "air_dodge", "%d Hz late angled dodge starts" % tick_rate)
	check(state.wave_dash_queued, "%d Hz late angle queues wavedash" % tick_rate)
	while state.air_dodge_ticks > 0:
		_step(world, 0, 1000)
	equal(state.last_event, "wave_dash", "%d Hz queued wavedash starts once" % tick_rate)
	check(state.wave_dash_ticks > 0, "%d Hz wavedash remains bounded" % tick_rate)


func _test_wall_contact_and_wall_kick(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var state: PlayerState = world.player()
	state.position_x = state.radius + 1000
	state.velocity_x = -MovementTuning.BASE_SPEED
	_step(world, -1000, 0)
	check(state.wall_memory_ticks > 0, "%d Hz collision records wall memory" % tick_rate)
	state.hop_cooldown_ticks = 0
	state.flow = MovementTuning.FLOW_MAXIMUM
	_step(world, -1000, 1000, 0, SimCommand.PRESSED_JUMP)
	equal(state.last_event, "wall_kick", "%d Hz hop consumes wall memory" % tick_rate)
	equal(state.hop_speed, MovementTuning.WALL_KICK_SPEED, "%d Hz wall kick speed is authored" % tick_rate)
	equal(state.movement_mode, PlayerState.MovementMode.WALL_KICK, "%d Hz wall kick remains explicit state" % tick_rate)


func _test_vault_and_superglide(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var state: PlayerState = world.player()
	state.position_x = 760_000
	state.position_y = 340_000
	_step(world, 1000, 0, 0, SimCommand.PRESSED_TECHNIQUE)
	equal(state.last_event, "vault", "%d Hz marked rail vaults" % tick_rate)
	check(state.position_x > 900_000 + state.radius, "%d Hz vault lands fully beyond the rail" % tick_rate)
	var crest_end: int = world.config.milliseconds_to_ticks(MovementTuning.VAULT_CREST_END_MS)
	while state.vault_ticks > crest_end:
		_step(world, 1000, 0)
	_step(world, 1000, 0, 0, SimCommand.PRESSED_JUMP)
	equal(state.last_event, "superglide", "%d Hz crest jump converts" % tick_rate)
	check(state.superglide_ticks > 0, "%d Hz superglide is active" % tick_rate)
	check(absi(state.velocity_x) <= MovementTuning.MAX_AUTHORED_SPEED, "%d Hz speed stays bounded" % tick_rate)
