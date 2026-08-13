extends FluxTestSuite


func run() -> int:
	for tick_rate: int in [60, 120]:
		_test_sprint_and_hop(tick_rate)
		_test_double_jump(tick_rate)
		_test_slide_and_slide_jump(tick_rate)
		_test_action_buffers(tick_rate)
		_test_variable_jump_and_fast_fall(tick_rate)
		_test_air_dodge_and_wavedash(tick_rate)
		_test_wall_contact_and_wall_kick(tick_rate)
		_test_same_wall_lockout(tick_rate)
		_test_wall_skim(tick_rate)
		_test_vault_and_superglide(tick_rate)
		_test_control_states(tick_rate)
	return finish("movement")


func _step(world: SimWorld, move_x: int = 0, move_y: int = 0, held: int = 0, pressed: int = 0) -> void:
	check(world.step([SimCommand.new(world.tick, 1, move_x, move_y, held, pressed)]), "world step succeeds")


func _test_sprint_and_hop(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	for _index: int in range(tick_rate / 2):
		_step(world, 1000, 0, SimCommand.HELD_SPRINT)
	var state: PlayerState = world.player()
	check(state.position_x > 160_000, "%d Hz sprint advances" % tick_rate)
	check(state.stamina < MovementTuning.STAMINA_MAXIMUM, "%d Hz sprint drains Stamina" % tick_rate)
	var before_stamina: int = state.stamina
	_step(world, 1000, 0, 0, SimCommand.PRESSED_JUMP)
	equal(state.last_event, "hop", "%d Hz starts hop" % tick_rate)
	equal(state.stamina, before_stamina - MovementTuning.HOP_COST, "%d Hz hop Stamina cost is exact" % tick_rate)
	check(state.hop_ticks > 0, "%d Hz hop is airborne" % tick_rate)


func _test_double_jump(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var state: PlayerState = world.player()
	_step(world, 1000, 0, 0, SimCommand.PRESSED_JUMP)
	var after_hop: int = state.stamina
	_step(world, 0, -1000, 0, SimCommand.PRESSED_JUMP)
	equal(state.last_event, "double_jump", "%d Hz second edge triggers double jump" % tick_rate)
	equal(state.stamina, after_hop - MovementTuning.DOUBLE_JUMP_COST, "%d Hz double jump Stamina cost is exact" % tick_rate)
	equal(state.hop_stage, 2, "%d Hz double jump is bounded to stage two" % tick_rate)
	var after_double: int = state.stamina
	_step(world, -1000, 0, 0, SimCommand.PRESSED_JUMP)
	equal(state.stamina, after_double, "%d Hz third jump cannot stack" % tick_rate)


func _test_slide_and_slide_jump(tick_rate: int) -> void:
	var direct_world := SimWorld.new(tick_rate)
	var direct_state: PlayerState = direct_world.player()
	while direct_state.velocity_x < MovementTuning.SLIDE_ENTRY_SPEED:
		_step(direct_world, 1000, 0)
	_step(direct_world, 1000, 0, 0, SimCommand.PRESSED_SLIDE)
	equal(direct_state.last_event, "slide", "%d Hz dedicated slide enters slide directly" % tick_rate)
	equal(direct_state.stamina, MovementTuning.STAMINA_MAXIMUM - MovementTuning.SLIDE_COST, "%d Hz dedicated slide has the authored Stamina cost" % tick_rate)

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


func _test_action_buffers(tick_rate: int) -> void:
	var slide_world := SimWorld.new(tick_rate)
	var slider: PlayerState = slide_world.player()
	_step(slide_world, 1000, 0, 0, SimCommand.PRESSED_SLIDE)
	check(slider.slide_buffer_ticks > 0, "%d Hz early slide intent is buffered" % tick_rate)
	while slider.slide_ticks == 0 and slider.slide_buffer_ticks > 0:
		_step(slide_world, 1000, 0)
	equal(slider.last_event, "slide", "%d Hz buffered slide fires after reaching entry speed" % tick_rate)
	equal(slider.slide_buffer_ticks, 0, "%d Hz successful slide consumes its buffer" % tick_rate)

	var expiry_world := SimWorld.new(tick_rate)
	var expiry: PlayerState = expiry_world.player()
	_step(expiry_world, 0, 0, 0, SimCommand.PRESSED_SLIDE)
	for _index: int in range(expiry_world.config.milliseconds_to_ticks(MovementTuning.INPUT_BUFFER_MS) + 1):
		_step(expiry_world)
	equal(expiry.slide_buffer_ticks, 0, "%d Hz impossible slide intent expires" % tick_rate)
	equal(expiry.stamina, MovementTuning.STAMINA_MAXIMUM, "%d Hz expired slide spends no Stamina" % tick_rate)

	var chain_world := SimWorld.new(tick_rate)
	var chainer: PlayerState = chain_world.player()
	while chainer.velocity_x < MovementTuning.SLIDE_ENTRY_SPEED:
		_step(chain_world, 1000, 0)
	_step(chain_world, 1000, 0, 0, SimCommand.PRESSED_SLIDE)
	_step(chain_world, 1000, 0, 0, SimCommand.PRESSED_JUMP)
	check(chainer.jump_buffer_ticks > 0, "%d Hz early slide-jump intent is buffered" % tick_rate)
	while chainer.last_event != "slide_jump" and chainer.jump_buffer_ticks > 0:
		_step(chain_world, 1000, 0)
	equal(chainer.last_event, "slide_jump", "%d Hz buffered jump fires in the slide conversion window" % tick_rate)
	equal(chainer.jump_buffer_ticks, 0, "%d Hz slide jump consumes its buffer" % tick_rate)


func _test_wall_contact_and_wall_kick(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var state: PlayerState = world.player()
	state.position_x = state.radius + 1000
	state.velocity_x = -MovementTuning.BASE_SPEED
	_step(world, -1000, 0)
	check(state.wall_memory_ticks > 0, "%d Hz collision records wall memory" % tick_rate)
	state.hop_cooldown_ticks = 0
	state.stamina = MovementTuning.STAMINA_MAXIMUM
	_step(world, -1000, 1000, 0, SimCommand.PRESSED_JUMP)
	equal(state.last_event, "wall_kick", "%d Hz hop consumes wall memory" % tick_rate)
	equal(state.hop_speed, MovementTuning.WALL_KICK_SPEED, "%d Hz wall kick speed is authored" % tick_rate)
	equal(state.movement_mode, PlayerState.MovementMode.WALL_KICK, "%d Hz wall kick remains explicit state" % tick_rate)


func _test_variable_jump_and_fast_fall(tick_rate: int) -> void:
	var held_world := SimWorld.new(tick_rate)
	var held_state: PlayerState = held_world.player()
	_step(held_world, 1000, 0, SimCommand.HELD_JUMP, SimCommand.PRESSED_JUMP)
	for _index: int in range(3):
		_step(held_world, 1000, 0, SimCommand.HELD_JUMP)
	var held_remaining: int = held_state.hop_ticks

	var cut_world := SimWorld.new(tick_rate)
	var cut_state: PlayerState = cut_world.player()
	_step(cut_world, 1000, 0, SimCommand.HELD_JUMP, SimCommand.PRESSED_JUMP)
	_step(cut_world, 1000, 0)
	equal(cut_state.last_event, "jump_cut", "%d Hz releasing jump cuts the authored arc" % tick_rate)
	equal(cut_state.hop_ticks, cut_world.config.milliseconds_to_ticks(MovementTuning.VARIABLE_JUMP_MINIMUM_MS), "%d Hz release preserves the bounded minimum arc" % tick_rate)
	check(cut_state.hop_ticks < held_remaining, "%d Hz released jump lands before held jump" % tick_rate)

	var fall_world := SimWorld.new(tick_rate)
	var fall_state: PlayerState = fall_world.player()
	_step(fall_world, 1000, 0, SimCommand.HELD_JUMP, SimCommand.PRESSED_JUMP)
	_step(fall_world, 1000, 0, SimCommand.HELD_JUMP)
	var before_fall: int = fall_state.hop_ticks
	_step(fall_world, 1000, 0, SimCommand.HELD_FAST_FALL)
	equal(fall_state.last_event, "fast_fall", "%d Hz airborne slide input starts fast fall" % tick_rate)
	check(fall_state.fast_falling, "%d Hz fast fall is explicit canonical state" % tick_rate)
	equal(fall_state.hop_ticks, before_fall - 1 - MovementTuning.FAST_FALL_EXTRA_TICKS, "%d Hz fast fall advances the arc by its bounded extra rate" % tick_rate)
	equal(fall_state.movement_mode, PlayerState.MovementMode.FAST_FALL, "%d Hz fast fall has an explicit presentation mode" % tick_rate)
	var stamina_before: int = fall_state.stamina
	_step(fall_world, 1000, 0, SimCommand.HELD_FAST_FALL)
	equal(fall_state.stamina, stamina_before, "%d Hz fast fall is commitment rather than a Stamina purchase" % tick_rate)
	while fall_state.hop_ticks > 0:
		_step(fall_world, 1000, 0, SimCommand.HELD_FAST_FALL)
	equal(
		fall_state.landing_intensity,
		MovementTuning.LANDING_HOP_INTENSITY + MovementTuning.LANDING_FAST_FALL_BONUS,
		"%d Hz fast-fall commitment survives as authored landing intensity" % tick_rate,
	)
	while fall_state.landing_ticks > 0:
		_step(fall_world)
	equal(fall_state.landing_intensity, 0, "%d Hz landing intensity clears with its recovery window" % tick_rate)


func _test_same_wall_lockout(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var state: PlayerState = world.player()
	state.position_x = state.radius + 1000
	state.velocity_x = -MovementTuning.BASE_SPEED
	_step(world, -1000, 0)
	var contacted_wall: int = state.wall_contact_id
	_step(world, -1000, 0, 0, SimCommand.PRESSED_JUMP)
	equal(state.wall_lockout_id, contacted_wall, "%d Hz wall kick records wall identity" % tick_rate)
	check(state.wall_lockout_ticks > 0, "%d Hz same-wall lockout starts" % tick_rate)
	state.hop_ticks = 0
	state.hop_cooldown_ticks = 0
	state.wall_memory_ticks = 0
	state.position_x = state.radius + 1000
	state.velocity_x = -MovementTuning.BASE_SPEED
	_step(world, -1000, 0)
	equal(state.wall_memory_ticks, 0, "%d Hz same wall cannot immediately refresh a kick" % tick_rate)


func _test_wall_skim(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var state: PlayerState = world.player()
	state.position_x = 560_000 - state.radius - 1000
	state.position_y = 340_000
	state.velocity_x = MovementTuning.BASE_SPEED
	_step(world, 1000, 0)
	equal(state.wall_contact_id, 1, "%d Hz authored obstacle records a positive surface identity" % tick_rate)
	var before_stamina: int = state.stamina
	var start_y: int = state.position_y
	_step(world, 0, 1000, 0, SimCommand.PRESSED_TECHNIQUE)
	equal(state.last_event, "wall_skim", "%d Hz technique converts recent obstacle contact into wall skim" % tick_rate)
	equal(state.stamina, before_stamina - MovementTuning.WALL_SKIM_COST, "%d Hz wall skim Stamina cost is exact" % tick_rate)
	equal(state.movement_mode, PlayerState.MovementMode.WALL_SKIM, "%d Hz wall skim is explicit canonical state" % tick_rate)
	check(state.wall_skim_ticks > 0, "%d Hz wall skim has a bounded authored duration" % tick_rate)
	check(state.position_y > start_y, "%d Hz wall skim follows the requested wall tangent" % tick_rate)
	var skim_surface: int = state.wall_skim_surface_id
	while state.wall_skim_ticks > 0:
		_step(world, 0, 1000)
	equal(state.last_event, "wall_skim_end", "%d Hz wall skim emits an explicit recovery event" % tick_rate)
	check(state.landing_ticks > 0, "%d Hz wall skim exposes its readable recovery window" % tick_rate)
	equal(state.landing_intensity, MovementTuning.LANDING_WALL_SKIM_INTENSITY, "%d Hz wall skim exit uses its lighter authored pulse" % tick_rate)
	state.wall_memory_ticks = world.config.milliseconds_to_ticks(MovementTuning.WALL_MEMORY_MS)
	state.wall_contact_id = skim_surface
	state.wall_x = -1000
	state.wall_y = 0
	state.stamina_recovery_delay_ticks = world.config.milliseconds_to_ticks(MovementTuning.STAMINA_RECOVERY_DELAY_MS)
	var after_first_skim: int = state.stamina
	_step(world, 0, -1000, 0, SimCommand.PRESSED_TECHNIQUE)
	equal(state.wall_skim_ticks, 0, "%d Hz same surface cannot immediately chain another skim" % tick_rate)
	equal(state.stamina, after_first_skim, "%d Hz rejected same-surface skim spends no Stamina" % tick_rate)

	var boundary_world := SimWorld.new(tick_rate)
	var boundary: PlayerState = boundary_world.player()
	boundary.position_x = boundary.radius + 1000
	boundary.velocity_x = -MovementTuning.BASE_SPEED
	_step(boundary_world, -1000, 0)
	check(boundary.wall_contact_id < 0, "%d Hz world boundary keeps its reserved surface identity" % tick_rate)
	var boundary_stamina: int = boundary.stamina
	_step(boundary_world, 0, 1000, 0, SimCommand.PRESSED_TECHNIQUE)
	equal(boundary.wall_skim_ticks, 0, "%d Hz outer world boundary cannot be skimmed" % tick_rate)
	equal(boundary.stamina, boundary_stamina, "%d Hz rejected boundary skim spends no Stamina" % tick_rate)


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


func _test_control_states(tick_rate: int) -> void:
	var rooted_world := SimWorld.new(tick_rate)
	var rooted: PlayerState = rooted_world.player()
	var rooted_start := Vector2i(rooted.position_x, rooted.position_y)
	check(MovementSystem.apply_control_state(rooted, PlayerState.ControlState.ROOTED, 200, Vector2i.RIGHT, 0, rooted_world.config), "%d Hz root applies" % tick_rate)
	_step(rooted_world, 1000, 0, SimCommand.HELD_SPRINT, SimCommand.PRESSED_JUMP)
	equal(Vector2i(rooted.position_x, rooted.position_y), rooted_start, "%d Hz root blocks movement and movement actions" % tick_rate)
	equal(rooted.movement_mode, PlayerState.MovementMode.ROOTED, "%d Hz root is explicit presentation state" % tick_rate)

	var launch_world := SimWorld.new(tick_rate)
	var launched: PlayerState = launch_world.player()
	var launch_start: int = launched.position_x
	check(MovementSystem.apply_control_state(launched, PlayerState.ControlState.LAUNCHED, 200, Vector2i.RIGHT, 2_000_000, launch_world.config), "%d Hz launch applies" % tick_rate)
	_step(launch_world, -1000, 0, SimCommand.HELD_SPRINT, SimCommand.PRESSED_TECHNIQUE)
	check(launched.position_x > launch_start, "%d Hz launch overrides player steering" % tick_rate)
	check(launched.velocity_x <= MovementTuning.MAX_AUTHORED_SPEED, "%d Hz launch respects authored speed ceiling" % tick_rate)
	equal(launched.movement_mode, PlayerState.MovementMode.LAUNCHED, "%d Hz launch is explicit presentation state" % tick_rate)

	var slow_world := SimWorld.new(tick_rate)
	var slowed: PlayerState = slow_world.player()
	check(MovementSystem.apply_control_state(slowed, PlayerState.ControlState.SLOWED, 200, Vector2i.RIGHT, 0, slow_world.config, 500), "%d Hz slow applies" % tick_rate)
	_step(slow_world, 1000, 0)
	check(slowed.velocity_x > 0 and slowed.velocity_x < slow_world.config.per_tick(MovementTuning.ACCELERATION), "%d Hz slow scales ordinary acceleration" % tick_rate)
	equal(slowed.movement_mode, PlayerState.MovementMode.SLOWED, "%d Hz slow is explicit presentation state" % tick_rate)
	check(not MovementSystem.apply_control_state(slowed, 99, 200, Vector2i.RIGHT, 0, slow_world.config), "%d Hz unknown control state fails closed" % tick_rate)
