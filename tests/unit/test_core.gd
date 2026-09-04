extends FluxTestSuite


func run() -> int:
	_test_supported_tick_rates()
	_test_command_serialization()
	_test_independent_aim()
	_test_actor_kind_is_canonical()
	_test_command_validation()
	return finish("core")


func _test_supported_tick_rates() -> void:
	equal(SimConfig.PROTOCOL_VERSION, 36, "current 120 Hz host-authoritative protocol is explicit")
	check(not SimConfig.new(60).is_valid(), "retired 60 Hz cadence fails closed")
	check(SimConfig.new(120).is_valid(), "120 Hz is the sole supported cadence")
	check(not SimConfig.new(90).is_valid(), "intermediate tick rates fail closed")
	equal(SimConfig.new(120).milliseconds_to_ticks(85), 11, "120 Hz duration rounds upward")


func _test_command_serialization() -> void:
	var command := SimCommand.new(7, 3, -1000, 1000, SimCommand.HELD_SPRINT, SimCommand.PRESSED_JUMP, 300, -400)
	var copy: SimCommand = command.copy()
	equal(command.canonical_bytes(), copy.canonical_bytes(), "command bytes are stable across copies")
	equal(command.canonical_bytes().size(), 64, "protocol-v2 command wire payload has fixed width")
	equal(Vector2i(command.aim_x, command.aim_y), Vector2i(600, -800), "aim is deterministically quantized to scale 1000")
	var spell_command := SimCommand.new(8, 3, 0, 0, 0, SimCommand.PRESSED_SPELL_4 | SimCommand.PRESSED_SPELL_2)
	equal(spell_command.first_pressed_spell_slot(), 2, "lowest requested spell slot wins deterministically")
	equal(spell_command.copy().first_pressed_spell_slot(), 2, "spell slot bits survive command copies")
	equal(SimCommand.new(9, 3).first_pressed_spell_slot(), 0, "command with no spell slot reports none")
	equal(SimCommand.new(10, 3, 0, 0, 0, SimCommand.PRESSED_SPELL_12).first_pressed_spell_slot(), 12, "Alt+4 occupies the bounded final command bit")


func _test_independent_aim() -> void:
	var world := SimWorld.new(120)
	var command := SimCommand.new(0, 1, 1000, 0, SimCommand.HELD_PRIMARY, 0, 0, -1000)
	check(world.step([command]), "independent-aim command steps")
	var state: PlayerState = world.player()
	equal(Vector2i(state.facing_x, state.facing_y), Vector2i(1000, 0), "movement facing follows movement")
	equal(Vector2i(state.aim_x, state.aim_y), Vector2i(0, -1000), "aim remains independent from movement")
	check(state.primary_held, "primary action is represented in canonical player state")


func _test_command_validation() -> void:
	var world := SimWorld.new(120)
	equal(world.state_hash().length(), 64, "world state uses a SHA-256 compatibility hash")
	check(not world.step([SimCommand.new(1, 1)]), "future command tick is rejected")
	check(world.last_error.contains("does not match"), "tick rejection is diagnosable")


func _test_actor_kind_is_canonical() -> void:
	var champion_world := SimWorld.new(120)
	var target_world := SimWorld.new(120)
	target_world.player().actor_kind = PlayerState.ActorKind.TRAINING_TARGET
	check(champion_world.state_hash() != target_world.state_hash(), "champion and practice-target actor kinds hash differently")
