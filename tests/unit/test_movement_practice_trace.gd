extends FluxTestSuite


func run() -> int:
	var trace := MovementPracticeTrace.new()
	trace.begin(0, Vector2(200, 200), 1)
	for tick: int in range(1, 17):
		trace.record(tick, Vector2(200 + tick, 200), SimCommand.new(tick, 1, 1000, 0))
	equal(trace.samples.size(), 5, "practice records a bounded thirty-Hz trail")
	trace.begin(20, Vector2(200, 200), 1)
	check(trace.compare_previous, "same champion and start permit comparison")
	trace.record(26, Vector2(209, 200), SimCommand.new())
	equal(trace.echo_position(), Vector2(206, 200), "previous-run echo interpolates smoothly")
	trace.begin(40, Vector2(1200, 200), 1)
	check(not trace.compare_previous, "different start never presents a misleading race")
	trace.begin(50, Vector2(1200, 200), 2)
	check(not trace.compare_previous, "different body role does not compare")
	for tick: int in range(51, 8000, 4):
		trace.record(tick, Vector2.ZERO, SimCommand.new())
	check(not trace.enabled and trace.samples.size() <= MovementPracticeTrace.MAX_SAMPLES, "practice recording stops at fixed memory cap")
	trace.begin(9000, Vector2.ZERO, 2)
	trace.record(0, Vector2.ZERO, SimCommand.new())
	check(not trace.enabled, "world restart safely clears active recording")
	return finish("movement-practice-trace")
