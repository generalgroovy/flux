extends FluxTestSuite


var config := SimConfig.new(120)
var arena := CollisionWorld.new(10_000_000, 10_000_000)


func run() -> int:
	equal(MovementTuning.STAMINA_MAXIMUM, 560_000, "default Stamina reserve is exactly five times112000")
	equal(MovementTuning.STAMINA_RECOVERY_PER_SECOND, 27_000, "extra reserve does not silently increase recovery")
	_test_physical_arc_and_double_jump()
	_test_fresh_jump_edge()
	_test_dodge_decay_and_airtime_allowance()
	_test_contact_and_forced_control()
	_test_fast_fall_and_landing_windows()
	_test_landing_readiness()
	_test_replay_and_canonical_reset()
	return finish("movement-height")


func _state() -> PlayerState:
	var state := PlayerState.new(1)
	state.position_x = 5_000_000
	state.position_y = 5_000_000
	return state


func _step(state: PlayerState, move: Vector2i = Vector2i.ZERO, held: int = 0, pressed: int = 0, collision: CollisionWorld = null) -> void:
	MovementSystem.step(state, SimCommand.new(0, 1, move.x, move.y, held, pressed), config, arena if collision == null else collision)
	check(state.air_height >= 0 and state.air_height <= MovementTuning.AIR_MAX_HEIGHT, "physical height stays within shared bounds")
	check(state.air_vertical_velocity >= -MovementTuning.AIR_TERMINAL_FALL_SPEED and state.air_vertical_velocity <= MovementTuning.JUMP_VERTICAL_SPEED, "vertical speed stays bounded")
	check(absi(state.air_height_remainder) < 2 * config.tick_rate, "vertical integration remainder is canonical and bounded")


func _test_physical_arc_and_double_jump() -> void:
	for direction: Vector2i in EightDirectionResolver.FIXED_VECTORS:
		var full := _state()
		var tap := _state()
		var full_apex := 0
		var tap_apex := 0
		var full_land_tick := -1
		var tap_land_tick := -1
		for tick: int in range(75):
			var pressed := SimCommand.PRESSED_JUMP if tick == 0 else 0
			_step(full, direction, SimCommand.HELD_JUMP, pressed)
			_step(tap, direction, 0, pressed)
			full_apex = maxi(full_apex, full.air_height)
			tap_apex = maxi(tap_apex, tap.air_height)
			if full.air_height == 0 and full_land_tick < 0:
				full_land_tick = tick + 1
			if tap.air_height == 0 and tap_land_tick < 0:
				tap_land_tick = tick + 1
			if tick == 30:
				check(not MovementSystem.is_combat_intangible(full, config), "high held apex never extends jump protection")
		equal(full_apex, 90_000, "every direction reaches exact ninety-pixel full-hop apex")
		equal(full_land_tick, 60, "full hop lands in exactly500ms at120Hz")
		check(tap_apex >= 34_000 and tap_apex <= 36_000, "tap arc reaches approximately thirty-five pixels")
		check(tap_land_tick > 0 and tap_land_tick < full_land_tick, "short hop lands before held hop")
		check(full.stamina < tap.stamina, "additional held rise has a real sustain cost")
		var double := _state()
		_step(double, direction, SimCommand.HELD_JUMP, SimCommand.PRESSED_JUMP)
		for _tick: int in range(29):
			_step(double, direction, SimCommand.HELD_JUMP)
		equal(double.air_height, 90_000, "first apex is real shared height")
		_step(double, direction) # A real release before the next fresh press.
		var before_height := double.air_height
		var before_stamina := double.stamina
		_step(double, direction, SimCommand.HELD_JUMP, SimCommand.PRESSED_JUMP)
		equal(double.hop_stage, 2, "one fresh second press consumes the finite second jump")
		check(double.air_height > before_height, "double jump adds lift from current height without dropping to a new arc origin")
		check(double.stamina < before_stamina, "second lift pays its continuation cost")
		var double_apex := double.air_height
		for _tick: int in range(80):
			_step(double, direction, SimCommand.HELD_JUMP)
			double_apex = maxi(double_apex, double.air_height)
		check(double_apex >= 179_000 and double_apex <= 180_000, "second full jump adds approximately ninety pixels to the current apex")
		check(not double.is_airborne(), "double jump always returns to actual ground")
		print("height direction ", direction, " full=", full_apex, " tap=", tap_apex, " full_ticks=", full_land_tick, " tap_ticks=", tap_land_tick, " double=", double_apex)


func _test_fresh_jump_edge() -> void:
	var state := _state()
	_step(state, Vector2i.ZERO, SimCommand.HELD_JUMP, SimCommand.PRESSED_JUMP)
	for _index: int in range(20):
		_step(state, Vector2i.ZERO, SimCommand.HELD_JUMP, SimCommand.PRESSED_JUMP)
	equal(state.hop_stage, 1, "repeated held-key edges cannot automatically double jump")
	_step(state)
	_step(state, Vector2i.ZERO, SimCommand.HELD_JUMP, SimCommand.PRESSED_JUMP)
	equal(state.hop_stage, 2, "release and fresh press does double jump")
	_step(state)
	for _index: int in range(12):
		_step(state, Vector2i.ZERO, 0, SimCommand.PRESSED_JUMP)
	equal(state.hop_stage, 2, "third fresh presses cannot buy a third aerial lift")


func _test_dodge_decay_and_airtime_allowance() -> void:
	for direction: Vector2i in EightDirectionResolver.FIXED_VECTORS:
		var state := _state()
		state.air_height = 150_000
		state.air_vertical_velocity = 0
		state.hop_ticks = MovementSystem._remaining_air_ticks(state, config)
		state.hop_stage = 1
		var before_height := state.air_height
		_step(state, direction, 0, SimCommand.PRESSED_EVADE)
		check(state.air_dodge_used, "accepted dodge spends exactly one airtime allowance")
		check(state.air_height < before_height and state.air_height > before_height - 1000, "air dodge preserves the ongoing physical descent")
		var initial_speed := MovementSystem._planar_speed(state)
		var previous_speed := initial_speed
		for _index: int in range(10):
			_step(state)
			var speed := MovementSystem._planar_speed(state)
			check(speed < previous_speed, "directional air burst decays each committed tick")
			previous_speed = speed
		check(initial_speed > 850_000 and previous_speed < 680_000, "dodge has a clear burst then readable deceleration")
		for _index: int in range(5):
			_step(state)
		state.air_dodge_cooldown_ticks = 0 # Cooldown expiry cannot reset airtime budget.
		var before_cost := state.stamina
		_step(state, -direction, 0, SimCommand.PRESSED_EVADE)
		equal(state.stamina, before_cost, "repeated air dodge refuses without paying")
		check(state.air_dodge_used, "cooldown changes cannot manufacture a new aerial dodge")
		var before_turn := Vector2i(state.velocity_x, state.velocity_y)
		_step(state, -direction)
		check(Vector2i(state.velocity_x, state.velocity_y) != before_turn, "post-commit descent remains steerable, not helpless")
		state.evade_buffer_ticks = 0
		for _index: int in range(60):
			_step(state)
		check(not state.is_airborne() and not state.air_dodge_used, "only real landing restores the next airtime dodge")


func _test_contact_and_forced_control() -> void:
	var collision := CollisionWorld.new(10_000_000, 10_000_000)
	collision.add_obstacle(CollisionWorld.Obstacle.new(7, 5_020_000, 4_000_000, 5_048_000, 6_000_000))
	var state := _state()
	state.position_x = 5_001_000
	state.air_height = 90_000
	state.air_vertical_velocity = 0
	state.hop_ticks = MovementSystem._remaining_air_ticks(state, config)
	state.hop_stage = 2
	state.air_dodge_used = true
	state.air_velocity_x = 500_000
	_step(state, Vector2i(1000, 0), 0, 0, collision)
	check(state.position_x <= 5_020_000 - state.radius, "height does not bypass worldbone collision")
	check(state.air_height > 80_000 and state.air_dodge_used, "horizontal collision never resets height or aerial allowance")
	var before := state.air_height
	_step(state, Vector2i(0, 1000), 0, SimCommand.PRESSED_TECHNIQUE, collision)
	check(state.wall_skim_ticks > 0, "real airborne contact can attach wallrun")
	equal(state.air_height, before, "wall attachment holds the exact current height")
	equal(state.hop_stage, 2, "wall contact cannot restore second jump")
	check(state.air_dodge_used, "wall contact cannot restore air dodge")
	_step(state, Vector2i(-1000, 0), 0, 0, collision)
	check(state.wall_skim_ticks == 0 and state.air_height > 0, "wall detach continues the same finite fall")
	check(state.air_dodge_used, "wall detach retains spent airtime allowance")
	MovementSystem.apply_control_state(state, PlayerState.ControlState.LAUNCHED, 150, Vector2i(-1000, 0), 300_000, config)
	var launch_height := state.air_height
	_step(state, Vector2i.ZERO, SimCommand.HELD_JUMP, 0, collision)
	check(state.air_height > 0 and state.air_height < launch_height, "forced planar launch does not reset the independent vertical trajectory")
	check(state.air_dodge_used, "forced control cannot replenish aerial dodge before landing")
	equal(state.hop_stage, 2, "forced control cannot replenish second jump before landing")


func _test_fast_fall_and_landing_windows() -> void:
	var state := _state()
	_step(state, Vector2i.ZERO, SimCommand.HELD_JUMP, SimCommand.PRESSED_JUMP)
	for _index: int in range(15):
		_step(state, Vector2i.ZERO, SimCommand.HELD_JUMP)
	var height := state.air_height
	_step(state, Vector2i.ZERO, 0, SimCommand.PRESSED_SLIDE)
	check(state.air_height < height and state.air_vertical_velocity <= -MovementTuning.AIR_FAST_FALL_SPEED, "fresh airborne Slide commits actual fast descent")
	for _index: int in range(15):
		_step(state)
	equal(state.air_height, 0, "fast fall finishes at exact floor height")
	check(not state.fast_fall_armed and not state.fast_falling, "actual landing clears fast fall state")
	var low := _state()
	low.air_height = 15_000
	low.air_vertical_velocity = -300_000
	low.hop_ticks = MovementSystem._remaining_air_ticks(low, config)
	low.hop_stage = 1
	_step(low, Vector2i(1000, 0), 0, SimCommand.PRESSED_EVADE)
	check(low.wave_dash_queued and MovementSystem.is_combat_intangible(low, config), "low descending dodge queues landing conversion with truthful opening protection")
	for _index: int in range(15):
		_step(low, Vector2i(1000, 0))
		if low.air_height == 0:
			check(not MovementSystem.is_combat_intangible(low, config), "real ground contact ends dodge protection without landing refresh")
	check(low.wave_dash_ticks > 0, "near-ground directional dodge retains a useful wavedash")
	check(low.velocity_x <= MovementTuning.AIR_DODGE_SPEED, "landing conversion cannot create extra planar energy")


func _test_replay_and_canonical_reset() -> void:
	var first := SimWorld.new(120, 7, arena)
	var repeat := SimWorld.new(120, 7, arena)
	for world: SimWorld in [first, repeat]:
		world.player().position_x = 5_000_000
		world.player().position_y = 5_000_000
	for tick: int in range(160):
		var direction: Vector2i = EightDirectionResolver.FIXED_VECTORS[(tick / 10) % 8]
		var held := SimCommand.HELD_JUMP if tick != 29 and tick < 65 else 0
		var pressed := SimCommand.PRESSED_JUMP if tick == 0 or tick == 30 else SimCommand.PRESSED_EVADE if tick == 44 else SimCommand.PRESSED_SLIDE if tick == 75 else 0
		for world: SimWorld in [first, repeat]:
			check(world.step([SimCommand.new(tick, 1, direction.x, direction.y, held, pressed)]), "physical trajectory replay tick executes")
		equal(first.state_hash(), repeat.state_hash(), "complete canonical hash repeats through lift, double jump, dodge and fast fall")
		var prediction_values := PackedInt64Array()
		for field: StringName in ClientPrediction.STATE_FIELDS:
			prediction_values.append(int(first.player().get(field)))
		prediction_values[0] = 2 # Prediction packets belong to guests, never host entity1.
		check(ClientPrediction.validate_values(prediction_values), "physical state remains admissible for exact prediction")
	var state := first.player()
	state.air_height = 120_000
	state.air_vertical_velocity = -500_000
	state.air_height_remainder = -117
	state.air_dodge_used = true
	state.jump_held_last_tick = true
	state.reset_for_spawn(Vector2i(5_000_000, 5_000_000))
	equal(state.air_height + state.air_vertical_velocity + state.air_height_remainder, 0, "spawn resets all physical height integrator state")
	check(not state.air_dodge_used and not state.jump_held_last_tick, "spawn resets finite airtime and held-edge state")


func _test_landing_readiness() -> void:
	var state := _state()
	state.air_height = 12_000
	state.air_vertical_velocity = -300_000
	state.hop_ticks = MovementSystem._remaining_air_ticks(state, config)
	state.hop_stage = 2
	state.air_dodge_used = true
	state.hop_cooldown_ticks = 60
	state.air_dodge_cooldown_ticks = 74
	_step(state, Vector2i(1000, 0), 0, SimCommand.PRESSED_JUMP)
	check(state.jump_buffer_ticks > 0, "spent-air Jump buffers a meaningful upcoming landing")
	var saw_ground := false
	var saw_hop := false
	for _index: int in range(12):
		_step(state, Vector2i(1000, 0))
		if state.air_height == 0:
			saw_ground = true
			equal(state.hop_cooldown_ticks, 0, "real landing clears stale hop cooldown")
		if saw_ground and state.hop_stage == 1 and state.air_height > 0:
			saw_hop = true
			break
	check(saw_hop, "buffered landing Jump starts a new real airtime immediately")
	for _index: int in range(state.movement_commitment_ticks):
		_step(state, Vector2i(1000, 0), SimCommand.HELD_JUMP)
	check(state.air_dodge_cooldown_ticks > 0, "fixture still has old ground evade cooldown")
	_step(state, Vector2i(0, 1000), 0, SimCommand.PRESSED_EVADE)
	check(state.air_dodge_ticks > 0 and state.air_dodge_used, "new airtime dodge is ready without waiting old ground evade cooldown")
