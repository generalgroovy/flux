extends FluxTestSuite


func run() -> int:
	for tick_rate: int in [120]:
		_test_deterministic_convergence(tick_rate)
		_test_eight_direction_parity(tick_rate)
	_test_soft_and_hard_correction()
	_test_history_and_validation_bounds()
	return finish("client-prediction")


func _test_deterministic_convergence(tick_rate: int) -> void:
	var config := SimConfig.new(tick_rate)
	var collision := CollisionWorld.new(2_000_000, 1_500_000)
	var authority := _state()
	var prediction := ClientPrediction.new()
	check(prediction.configure(config, collision, 2), "%d Hz prediction configures" % tick_rate)
	var initial := ClientPrediction.capture_packet(authority, 10, -1)
	check(ClientPrediction.validate_packet(initial), "%d Hz authoritative prediction state validates" % tick_rate)
	var packet_size := var_to_bytes({"kind": SessionTransport.PACKET_RECONCILIATION, "reconciliation": initial}).size()
	check(packet_size <= 1392, "%d Hz reconciliation stays within one ENet MTU (%d bytes)" % [tick_rate, packet_size])
	check(prediction.reconcile(initial, "farflow_arrival"), "%d Hz first authority initializes prediction" % tick_rate)
	var command := SimCommand.new(
		0, 2, 1000, 0,
		SimCommand.HELD_JUMP | SimCommand.HELD_PRIMARY,
		SimCommand.PRESSED_JUMP | SimCommand.PRESSED_ACTIVE_1,
		700, 700,
	)
	check(prediction.queue_input(1, command), "%d Hz local input enters bounded prediction" % tick_rate)
	check(prediction.predicted_state.position_x > authority.position_x, "%d Hz predicted traveller moves immediately" % tick_rate)
	check(prediction.predicted_state.hop_ticks > 0, "%d Hz jump grammar predicts immediately" % tick_rate)
	check(not prediction.predicted_state.primary_held, "%d Hz prediction never simulates held combat" % tick_rate)
	MovementSystem.step(authority, command, config, collision)
	var confirmed := ClientPrediction.capture_packet(authority, 11, 1)
	check(prediction.reconcile(confirmed, authority.last_event), "%d Hz acknowledgement reconciles" % tick_rate)
	equal(prediction.pending_count(), 0, "%d Hz acknowledged input leaves history" % tick_rate)
	equal(Vector2i(prediction.predicted_state.position_x, prediction.predicted_state.position_y), Vector2i(authority.position_x, authority.position_y), "%d Hz equal input converges exactly" % tick_rate)
	_near(prediction.last_correction_pixels, 0.0, 0.001, "%d Hz equal prediction needs no correction" % tick_rate)
	check(not prediction.reconcile(confirmed, authority.last_event), "%d Hz repeated authority tick fails closed" % tick_rate)


func _test_eight_direction_parity(tick_rate: int) -> void:
	var config := SimConfig.new(tick_rate)
	var collision := CollisionWorld.new(2_000_000, 1_500_000)
	for direction_index: int in range(EightDirectionResolver.DIRECTION_ORDER.size()):
		var direction_id := EightDirectionResolver.DIRECTION_ORDER[direction_index]
		var fixed := EightDirectionResolver.FIXED_VECTORS[direction_index]
		var authority := _state()
		var prediction := ClientPrediction.new()
		check(prediction.configure(config, collision, 2), "%d Hz %s prediction configures" % [tick_rate, direction_id])
		check(prediction.reconcile(ClientPrediction.capture_packet(authority, 20, -1)), "%d Hz %s authority initializes prediction" % [tick_rate, direction_id])
		var command := SimCommand.new(0, 2, fixed.x, fixed.y, 0, 0, fixed.x, fixed.y)
		check(prediction.queue_input(1, command), "%d Hz %s input enters prediction" % [tick_rate, direction_id])
		var queued: SimCommand = prediction.pending_inputs[0]["command"]
		equal(Vector2i(queued.move_x, queued.move_y), fixed, "%d Hz %s prediction preserves movement components" % [tick_rate, direction_id])
		equal(Vector2i(queued.aim_x, queued.aim_y), fixed, "%d Hz %s prediction preserves aim heading" % [tick_rate, direction_id])
		MovementSystem.step(authority, command, config, collision)
		check(prediction.reconcile(ClientPrediction.capture_packet(authority, 21, 1), authority.last_event), "%d Hz %s authority reconciles" % [tick_rate, direction_id])
		equal(
			Vector2i(prediction.predicted_state.position_x, prediction.predicted_state.position_y),
			Vector2i(authority.position_x, authority.position_y),
			"%d Hz %s prediction converges without directional drift" % [tick_rate, direction_id],
		)


func _test_soft_and_hard_correction() -> void:
	var config := SimConfig.new(120)
	var collision := CollisionWorld.new(2_000_000, 1_500_000)
	var prediction := ClientPrediction.new()
	check(prediction.configure(config, collision, 2), "correction fixture configures")
	var authority := _state()
	check(prediction.reconcile(ClientPrediction.capture_packet(authority, 1, -1)), "correction fixture initializes")
	authority.position_x += 10_000
	check(prediction.reconcile(ClientPrediction.capture_packet(authority, 2, -1)), "small divergence reconciles")
	_near(prediction.last_correction_pixels, 10.0, 0.001, "small correction is measured in pixels")
	check(prediction.visual_offset.length() > 0.0, "small correction preserves a decaying presentation offset")
	prediction.advance_visual(1.0)
	_near(prediction.visual_offset.length(), 0.0, 0.001, "presentation correction decays to zero")
	for tick: int in range(3, 11):
		authority.position_x += 10_000
		check(prediction.reconcile(ClientPrediction.capture_packet(authority, tick, -1)), "repeated small correction %d reconciles" % tick)
	check(prediction.visual_offset.length() <= ClientPrediction.SOFT_CORRECTION_LIMIT_PIXELS, "accumulated soft correction stays visibly bounded")
	authority.position_x += 200_000
	check(prediction.reconcile(ClientPrediction.capture_packet(authority, 11, -1)), "large divergence reconciles")
	check(prediction.last_correction_pixels > ClientPrediction.SOFT_CORRECTION_LIMIT_PIXELS, "large correction crosses the hard-snap threshold")
	equal(prediction.hard_snap_count, 1, "large correction is counted as one hard snap")
	_near(prediction.visual_offset.length(), 0.0, 0.001, "hard snap never carries a misleading visual offset")


func _test_history_and_validation_bounds() -> void:
	var prediction := ClientPrediction.new()
	check(prediction.configure(SimConfig.new(120), CollisionWorld.new(2_000_000, 1_500_000), 2), "history fixture configures at the canonical rate")
	var authority := _state()
	var initial := ClientPrediction.capture_packet(authority, 1, -1)
	check(prediction.reconcile(initial), "history fixture initializes")
	for sequence: int in range(1, ClientPrediction.MAX_PENDING_INPUTS + 9):
		check(prediction.queue_input(sequence, SimCommand.new(0, 2, 1000, 0)), "history accepts monotonic input %d" % sequence)
	equal(prediction.pending_count(), ClientPrediction.MAX_PENDING_INPUTS, "prediction input memory is strictly bounded")
	check(prediction.history_overflowed, "history overflow is explicit")
	check(not prediction.queue_input(ClientPrediction.MAX_PENDING_INPUTS + 8, SimCommand.new(0, 2)), "replayed local sequence fails closed")
	var newest := ClientPrediction.capture_packet(authority, 2, ClientPrediction.MAX_PENDING_INPUTS + 8)
	check(prediction.reconcile(newest), "overflowed history accepts newer authority")
	equal(prediction.pending_count(), 0, "new authority drains acknowledged bounded history")
	equal(prediction.hard_snap_count, 1, "history loss forces an explicit hard snap")
	var malformed := initial.duplicate(true)
	malformed["values"] = PackedInt64Array([2])
	check(not ClientPrediction.validate_packet(malformed), "short reconciliation state fails closed")
	malformed = initial.duplicate(true)
	var values: PackedInt64Array = malformed["values"]
	values[0] = 9
	malformed["values"] = values
	check(not ClientPrediction.validate_packet(malformed), "out-of-roster prediction entity fails closed")


func _state() -> PlayerState:
	var state := PlayerState.new(2)
	state.position_x = 600_000
	state.position_y = 500_000
	state.stamina_maximum = 96_000
	state.stamina = 96_000
	state.stamina_recovery_per_second = 17_000
	state.movement_speed_ratio = 1040
	return state


func _near(actual: float, expected: float, tolerance: float, message: String) -> void:
	check(absf(actual - expected) <= tolerance, "%s (expected=%s actual=%s)" % [message, expected, actual])
