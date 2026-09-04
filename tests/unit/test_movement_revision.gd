extends FluxTestSuite


func run() -> int:
	_test_eight_way_windows_and_brake()
	_test_air_wall_budget()
	_test_explicit_intents_and_attachment()
	_test_snapshot_and_surface_seam()
	_test_controls_migration_and_landing_buffer()
	return finish("movement-revision")


func _state() -> PlayerState:
	var state := PlayerState.new(1)
	state.position_x = 2_000_000
	state.position_y = 2_000_000
	return state


func _test_eight_way_windows_and_brake() -> void:
	var config := SimConfig.new(120)
	var arena := CollisionWorld.new(4_000_000, 4_000_000)
	for direction: Vector2i in EightDirectionResolver.FIXED_VECTORS:
		for reserves: int in [96_000, 100_000, 108_000]:
			var slider := _state()
			slider.stamina = reserves
			slider.velocity_x = direction.x * MovementTuning.BASE_SPEED / 1000
			slider.velocity_y = direction.y * MovementTuning.BASE_SPEED / 1000
			MovementSystem.step(slider, SimCommand.new(0, 1, direction.x, direction.y, 0, SimCommand.PRESSED_SLIDE), config, arena)
			for age: int in range(8):
				equal(MovementSystem.is_combat_intangible(slider, config), age < 6, "slide has exactly six opening protected ticks")
				MovementSystem.step(slider, SimCommand.new(age + 1, 1, direction.x, direction.y), config, arena)
			var paid := slider.stamina
			var cooldown := slider.slide_cooldown_ticks
			MovementSystem.step(slider, SimCommand.new(9, 1, -direction.x, -direction.y, 0, SimCommand.PRESSED_SLIDE), config, arena)
			equal(slider.slide_ticks, 0, "second slide press brakes without extra button")
			check(not MovementSystem.is_combat_intangible(slider, config), "brake cannot preserve protection")
			equal(slider.stamina, paid, "brake neither refunds nor charges Stamina")
			equal(slider.slide_cooldown_ticks, cooldown - 1, "brake does not reset cooldown")
		for held: int in [0, SimCommand.HELD_JUMP, SimCommand.HELD_FAST_FALL]:
			var jumper := _state()
			MovementSystem.step(jumper, SimCommand.new(0, 1, direction.x, direction.y, SimCommand.HELD_SPRINT, SimCommand.PRESSED_JUMP), config, arena)
			equal(jumper.hop_mode, PlayerState.MovementMode.HOP, "Sprint + Jump remains directional Jump")
			for age: int in range(14):
				var protected := age < config.milliseconds_to_ticks(MovementTuning.JUMP_INVULNERABILITY_MS) and jumper.hop_ticks > 0
				equal(MovementSystem.is_combat_intangible(jumper, config), protected, "short hop / fast fall never refreshes or prematurely ages jump protection")
				MovementSystem.step(jumper, SimCommand.new(age + 1, 1, direction.x, direction.y, held), config, arena)


func _test_air_wall_budget() -> void:
	var config := SimConfig.new(120)
	var arena := CollisionWorld.new(4_000_000, 4_000_000)
	for normal: Vector2i in [Vector2i(1000, 0), Vector2i(-1000, 0), Vector2i(0, 1000), Vector2i(0, -1000)]:
		var state := _state()
		MovementSystem.step(state, SimCommand.new(0, 1, 1000, 0, SimCommand.HELD_JUMP, SimCommand.PRESSED_JUMP), config, arena)
		state.wall_memory_ticks = 12
		state.wall_contact_id = 3
		state.wall_x = normal.x
		state.wall_y = normal.y
		state.air_redirects_remaining = 0
		MovementSystem.step(state, SimCommand.new(1, 1, normal.x, normal.y, SimCommand.HELD_JUMP, SimCommand.PRESSED_JUMP), config, arena)
		equal(state.hop_mode, PlayerState.MovementMode.WALL_KICK, "outward airborne wall contact selects kick")
		equal(state.hop_stage, 2, "wall kick spends second air action")
		equal(state.air_redirects_remaining, 0, "wall kick cannot refresh spent redirect")
		var paid := state.stamina
		state.wall_memory_ticks = 12
		state.wall_contact_id = 4
		MovementSystem.step(state, SimCommand.new(2, 1, normal.x, normal.y, SimCommand.HELD_JUMP, SimCommand.PRESSED_JUMP), config, arena)
		equal(state.stamina, paid - config.per_tick(MovementTuning.JUMP_SUSTAIN_DRAIN_PER_SECOND), "opposite wall cannot grant a third air action; its held tick only sustains the current arc")
		equal(state.hop_stage, 2, "denied opposite-wall repeat preserves the spent air stage")


func _test_explicit_intents_and_attachment() -> void:
	var config := SimConfig.new(120)
	var arena := CollisionWorld.new(4_000_000, 4_000_000)
	arena.add_obstacle(CollisionWorld.Obstacle.new(7, 2_020_000, 1_800_000, 2_048_000, 2_200_000))
	var state := _state()
	state.position_x = 2_002_000
	state.wall_contact_id = 7
	state.wall_memory_ticks = 12
	state.wall_x = -1000
	MovementSystem.step(state, SimCommand.new(0, 1, 0, 1000, 0, SimCommand.PRESSED_EVADE), config, arena)
	check(state.is_rolling(), "nearby wall never hijacks explicit Evade")
	equal(state.wall_skim_ticks, 0, "Evade never starts wallrun")
	state = _state()
	state.position_x = 2_002_000
	state.wall_contact_id = 7
	state.wall_memory_ticks = 12
	state.wall_x = -1000
	MovementSystem.step(state, SimCommand.new(0, 1, 0, 1000, 0, SimCommand.PRESSED_TECHNIQUE), config, arena)
	check(state.wall_skim_ticks > 0, "tangent + wall intent starts contact run")
	check(not MovementSystem.is_combat_intangible(state, config), "wallrun has no protection")
	MovementSystem.step(state, SimCommand.new(1, 1, -1000, 0), config, arena)
	equal(state.wall_skim_ticks, 0, "outward input deliberately detaches")
	check(state.wall_skim_lockout_ticks > 0, "detach retains same-surface budget")
	state = _state()
	state.position_x = 2_002_000
	state.wall_contact_id = 7
	state.wall_memory_ticks = 12
	state.wall_x = -1000
	MovementSystem.step(state, SimCommand.new(0, 1, 0, 1000, 0, SimCommand.PRESSED_TECHNIQUE), config, arena)
	MovementSystem.step(state, SimCommand.new(1, 1, 0, 1000, SimCommand.HELD_JUMP, SimCommand.PRESSED_JUMP), config, arena)
	equal(state.hop_mode, PlayerState.MovementMode.WALL_KICK, "Jump exits attached wallrun as a wall kick")
	equal(state.wall_skim_ticks, 0, "wall jump cleanly ends wallrun")
	state = _state()
	state.velocity_x = MovementTuning.BASE_SPEED
	MovementSystem.step(state, SimCommand.new(0, 1, -1000, 0, 0, SimCommand.PRESSED_EVADE | SimCommand.PRESSED_SLIDE | SimCommand.PRESSED_TECHNIQUE), config, arena)
	check(state.is_rolling() and state.slide_ticks == 0 and state.wall_skim_ticks == 0, "simultaneous intents have one explicit evasion owner")
	equal(state.stamina, state.stamina_maximum - MovementTuning.ROLL_COST, "simultaneous intents cannot double-charge hidden actions")


func _test_controls_migration_and_landing_buffer() -> void:
	var preferences := PlayerPreferences.new()
	var old := preferences.to_dictionary()
	old["schema_version"] = 9
	(old["keyboard_bindings"] as Dictionary).erase("evade")
	old["keyboard_bindings"]["jump"] = KEY_Q
	(old["controller_bindings"] as Dictionary).erase("evade")
	old["controller_bindings"]["jump"] = {"kind": "axis", "index": JOY_AXIS_TRIGGER_LEFT, "direction": 1}
	check(preferences.apply_dictionary(old), "old custom bindings migrate")
	equal(preferences.keyboard_bindings[&"jump"], KEY_Q, "migration retains the player's Q binding")
	equal(preferences.keyboard_bindings[&"evade"], 0, "new Evade cannot steal a custom key")
	equal(preferences.controller_bindings[&"evade"]["kind"], "none", "new Evade cannot steal a custom trigger")
	var state := _state()
	var config := SimConfig.new(120)
	var arena := CollisionWorld.new(4_000_000, 4_000_000)
	state.hop_ticks = 2
	state.hop_stage = 1
	state.hop_x = 1000
	MovementSystem.step(state, SimCommand.new(0, 1, -1000, 0, SimCommand.HELD_JUMP), config, arena)
	var before := state.velocity_x
	MovementSystem.step(state, SimCommand.new(1, 1), config, arena)
	check(state.velocity_x < before, "remembered landing direction keeps reversal intent across one empty tick")
	equal(state.landing_input_ticks, 0, "landing input is consumed, not held forever")


func _test_snapshot_and_surface_seam() -> void:
	var world := SimWorld.new(120)
	world.player().champion_wire_id = 1
	world.player().jump_protection_ticks = 7
	var replica := SimWorld.new(120)
	check(SessionSnapshot.apply_to_world(SessionSnapshot.capture(world, {}), replica), "protection snapshot validates")
	equal(replica.player().jump_protection_ticks, 7, "remote presentation receives exact jump protection")
	var predicted := PlayerState.new(2)
	predicted.jump_protection_ticks = 7
	var packet := ClientPrediction.capture_packet(predicted, 10, 1)
	check(ClientPrediction.validate_packet(packet), "new prediction fields remain valid")
	for field: StringName in [&"jump_protection_ticks", &"evade_buffer_ticks", &"landing_input_ticks"]:
		var state_index := ClientPrediction.STATE_FIELDS.find(field)
		var values: PackedInt64Array = packet["values"].duplicate()
		values[state_index] = 7
		equal(ClientPrediction.restore_state(values).get(field), 7, "new movement timer round-trips in reconciliation")
		values[state_index] = -1
		check(not ClientPrediction.validate_values(values), "negative movement timer fails closed")
		values[state_index] = SessionSnapshot.MAX_TIMER_TICKS + 1
		check(not ClientPrediction.validate_values(values), "oversized movement timer fails closed")
	for material_id: int in range(32):
		equal(SurfaceMotionPolicy.acceleration_ratio(material_id, 255), 1000, "chemistry cannot alter acceleration yet")
		equal(SurfaceMotionPolicy.braking_ratio(material_id, 255), 1000, "chemistry cannot alter braking yet")
		equal(SurfaceMotionPolicy.steering_ratio(material_id, 255), 1000, "chemistry cannot alter steering yet")
