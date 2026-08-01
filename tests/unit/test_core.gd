extends FluxTestSuite


func run() -> int:
	_test_supported_tick_rates()
	_test_command_serialization()
	_test_command_validation()
	return finish("core")


func _test_supported_tick_rates() -> void:
	check(SimConfig.new(60).is_valid(), "60 Hz is supported")
	check(SimConfig.new(120).is_valid(), "120 Hz is supported")
	check(not SimConfig.new(90).is_valid(), "intermediate tick rates fail closed")
	equal(SimConfig.new(60).milliseconds_to_ticks(85), 6, "60 Hz duration rounds upward")
	equal(SimConfig.new(120).milliseconds_to_ticks(85), 11, "120 Hz duration rounds upward")


func _test_command_serialization() -> void:
	var command := SimCommand.new(7, 3, -1000, 1000, SimCommand.HELD_SPRINT, SimCommand.PRESSED_JUMP)
	var copy: SimCommand = command.copy()
	equal(command.canonical_bytes(), copy.canonical_bytes(), "command bytes are stable across copies")
	equal(command.canonical_bytes().size(), 48, "command wire payload has fixed width")


func _test_command_validation() -> void:
	var world := SimWorld.new(60)
	equal(world.state_hash().length(), 64, "world state uses a SHA-256 compatibility hash")
	check(not world.step([SimCommand.new(1, 1)]), "future command tick is rejected")
	check(world.last_error.contains("does not match"), "tick rejection is diagnosable")
