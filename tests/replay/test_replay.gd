extends FluxTestSuite


func run() -> int:
	for tick_rate: int in [60, 120]:
		_test_replay_at_rate(tick_rate)
	_test_rate_mismatch_rejected()
	return finish("replay")


func _test_replay_at_rate(tick_rate: int) -> void:
	var commands: Array[SimCommand] = []
	for tick: int in range(tick_rate * 2):
		var held: int = SimCommand.HELD_SPRINT if tick < tick_rate else 0
		if tick >= tick_rate / 2 and tick < tick_rate / 2 + tick_rate / 4:
			held |= SimCommand.HELD_PRIMARY
		var pressed: int = 0
		if tick == tick_rate / 3:
			pressed |= SimCommand.PRESSED_JUMP
		if tick == tick_rate / 3 + 2:
			pressed |= SimCommand.PRESSED_TECHNIQUE
		commands.append(SimCommand.new(tick, 1, 1000, 0, held, pressed, 0, -1000))
	var first: ReplayData = ReplayData.record(commands, tick_rate, 8675309)
	var second: ReplayData = ReplayData.record(commands, tick_rate, 8675309)
	equal(first.expected_hashes, second.expected_hashes, "%d Hz repeated recording has identical hashes" % tick_rate)
	var verification: Dictionary = first.verify()
	check(bool(verification["ok"]), "%d Hz replay verifies at every tick: %s" % [tick_rate, verification])
	check(first.expected_hashes.size() == tick_rate * 2, "%d Hz replay records every checkpoint" % tick_rate)
	var original_hash: String = first.expected_hashes[-1]
	first.expected_hashes[-1] = "0".repeat(64)
	check(not bool(first.verify()["ok"]), "%d Hz replay detects a tampered checkpoint" % tick_rate)
	first.expected_hashes[-1] = original_hash


func _test_rate_mismatch_rejected() -> void:
	var replay := ReplayData.new(90)
	var result: Dictionary = replay.verify()
	check(not bool(result["ok"]), "unsupported replay tick rate fails closed")
	check(String(result["error"]).contains("tick rate"), "rate failure is diagnosable")
