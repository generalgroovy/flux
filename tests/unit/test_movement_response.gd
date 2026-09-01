extends FluxTestSuite


func run() -> int:
	equal(MovementTuning.BASE_SPEED, 324_000, "ordinary steady speed is the measured ten-percent-slower candidate")
	equal(MovementTuning.ACCELERATION, 1_980_000, "ordinary acceleration preserves immediate response")
	equal(MovementTuning.DECELERATION, 3_000_000, "ordinary braking is deliberately tighter")
	equal(MovementTuning.COUNTER_STRAFE_MULTIPLIER, 1900, "counter-strafe owns the crisp reversal profile")
	check(MovementTuning.compatibility_hash().length() == 64, "all movement tuning contributes a stable compatibility identity")
	var metrics_120 := _response_metrics(120)
	_test_bounds(metrics_120)
	return finish("movement-response")


func _test_bounds(metrics: Dictionary) -> void:
	var tick_rate := int(metrics["tick_rate"])
	check(int(metrics["walk_distance"]) >= 298_000 and int(metrics["walk_distance"]) <= 301_000, "%d Hz one-second walk is 8–12%% below the legacy baseline" % tick_rate)
	check(int(metrics["stop_distance"]) <= 17_000, "%d Hz release stops inside seventeen pixels" % tick_rate)
	check(int(metrics["stop_ms"]) <= 120, "%d Hz release reaches rest within 120 ms" % tick_rate)
	check(int(metrics["reverse_overshoot"]) <= 13_500, "%d Hz reversal drift stays inside 13.5 pixels" % tick_rate)
	check(int(metrics["reverse_ms"]) <= 105, "%d Hz reversal crosses zero within 105 ms" % tick_rate)
	equal(int(metrics["cruise_velocity"]), MovementTuning.BASE_SPEED, "%d Hz reaches exact ordinary steady speed" % tick_rate)
	check(bool(metrics["residual_mode_visible"]), "%d Hz braking keeps the walk response until physical rest" % tick_rate)
	check(bool(metrics["rest_mode_idle"]), "%d Hz physical rest returns to the idle response" % tick_rate)


func _response_metrics(tick_rate: int) -> Dictionary:
	var collision := CollisionWorld.new(10_000_000, 10_000_000)
	var world := SimWorld.new(tick_rate, 7, collision, "movement-response-fixture", "movement-response-v1")
	var state := world.player()
	state.position_x = 1_000_000
	state.position_y = 1_000_000
	var walk_start := state.position_x
	for _index: int in range(tick_rate):
		world.step([SimCommand.new(world.tick, state.entity_id, 1000, 0)])
	var walk_distance := state.position_x - walk_start
	var cruise_velocity := state.velocity_x
	var stop_start := state.position_x
	var stop_ticks := 0
	var residual_mode_visible := false
	while state.velocity_x != 0 and stop_ticks < tick_rate:
		world.step([SimCommand.new(world.tick, state.entity_id, 0, 0)])
		stop_ticks += 1
		if state.velocity_x != 0 and state.movement_mode == PlayerState.MovementMode.WALK:
			residual_mode_visible = true
	var stop_distance := state.position_x - stop_start
	var rest_mode_idle := state.velocity_x == 0 and state.movement_mode == PlayerState.MovementMode.IDLE
	for _index: int in range(tick_rate):
		world.step([SimCommand.new(world.tick, state.entity_id, 1000, 0)])
	var reverse_start := state.position_x
	var reverse_peak := reverse_start
	var reverse_ticks := 0
	while state.velocity_x >= 0 and reverse_ticks < tick_rate:
		world.step([SimCommand.new(world.tick, state.entity_id, -1000, 0)])
		reverse_peak = maxi(reverse_peak, state.position_x)
		reverse_ticks += 1
	return {
		"tick_rate": tick_rate,
		"walk_distance": walk_distance,
		"cruise_velocity": cruise_velocity,
		"stop_distance": stop_distance,
		"stop_ms": stop_ticks * 1000 / tick_rate,
		"reverse_overshoot": reverse_peak - reverse_start,
		"reverse_ms": reverse_ticks * 1000 / tick_rate,
		"residual_mode_visible": residual_mode_visible,
		"rest_mode_idle": rest_mode_idle,
	}
