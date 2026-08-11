extends FluxTestSuite


func run() -> int:
	_test_validation_fails_closed()
	_test_enet_loopback_handshake_and_input()
	return finish("session-transport")


func _signature(tick_rate: int = 120) -> String:
	return SessionTransport.compatibility_signature(
		SimConfig.PROTOCOL_VERSION,
		tick_rate,
		"a".repeat(64),
		"b".repeat(64),
		"c".repeat(64),
	)


func _test_validation_fails_closed() -> void:
	var transport := SessionTransport.new()
	equal(SessionTransport.MAX_PLAYERS, 8, "public session cap is eight players")
	equal(_signature().length(), 64, "compatibility identity is a SHA-256 digest")
	check(not transport.start_host(80, _signature()), "privileged production host port is rejected")
	check(transport.last_error.contains("1024"), "invalid host port has an actionable error")
	check(not transport.start_join("bad address", SessionTransport.DEFAULT_PORT, _signature()), "address whitespace is rejected")
	check(not transport.start_join("127.0.0.1", 70000, _signature()), "out-of-range join port is rejected")
	check(not transport.start_host(0, "not-a-signature"), "malformed compatibility identity is rejected")
	check(not transport.start_host(0, _signature(), ""), "empty player name is rejected")
	check(not SessionTransport._valid_input_packet({"sequence": "0", "move_x": 0, "move_y": 0, "held": 0, "pressed": 0, "aim_x": 1000, "aim_y": 0}), "string-coerced input fields fail closed")
	equal(SessionTransport.MAX_PACKETS_PER_POLL, 64, "transport processing has a per-poll work budget")
	equal(SessionTransport.MAX_QUEUED_INPUTS, 28, "accepted input memory is bounded for seven remote peers")


func _test_enet_loopback_handshake_and_input() -> void:
	var host := SessionTransport.new()
	var client := SessionTransport.new()
	check(host.start_host(0, _signature(), "Lantern Host"), "loopback host binds an automatic UDP port: %s" % host.last_error)
	check(host.bound_port >= 1024, "automatic host exposes its actual unprivileged port")
	check(client.start_join("127.0.0.1", host.bound_port, _signature(), "River Guest"), "loopback client begins joining: %s" % client.last_error)
	check(_poll_until(host, client, func() -> bool: return client.is_connected_client()), "compatible loopback client completes handshake")
	check(host.is_host(), "host remains authoritative after client handshake")
	equal(host.player_count(), 2, "host counts itself plus accepted client")
	check(client.local_peer_id > SessionTransport.SERVER_PEER_ID, "client receives a positive non-host peer id")

	var command := SimCommand.new(0, 1, 700, -300, SimCommand.HELD_SPRINT, SimCommand.PRESSED_JUMP, 1000, 0)
	check(client.send_input(17, command), "accepted client sends a bounded input packet")
	check(_poll_until(host, client, func() -> bool: return not host.incoming_inputs.is_empty()), "host receives client input through ENet")
	var inputs: Array[Dictionary] = host.take_inputs()
	equal(inputs.size(), 1, "host drains one validated input")
	if not inputs.is_empty():
		equal(int(inputs[0].get("sequence", -1)), 17, "input sequence survives transport")
		equal(int(inputs[0].get("move_x", 0)), 700, "input movement survives transport")
		equal(int(inputs[0].get("peer_id", 0)), client.local_peer_id, "host stamps trusted sender identity")
	check(host.take_inputs().is_empty(), "host input drain is single-consumer")
	check(client.send_input(17, command), "client can retransmit but cannot authorize a repeated sequence")
	for _index: int in range(20):
		host.poll()
		client.poll()
		OS.delay_msec(1)
	check(host.take_inputs().is_empty(), "host drops replayed input sequences")

	var incompatible := SessionTransport.new()
	check(incompatible.start_join("127.0.0.1", host.bound_port, _signature(60), "Old Build"), "incompatible client reaches handshake boundary")
	check(_poll_until(host, incompatible, func() -> bool: return incompatible.mode == SessionTransport.Mode.OFFLINE and not incompatible.last_error.is_empty()), "incompatible session is rejected deterministically")
	check(incompatible.last_error.contains("Incompatible"), "compatibility refusal explains the mismatch")
	equal(host.player_count(), 2, "rejected client never enters authoritative roster")

	client.stop()
	check(_poll_until(host, client, func() -> bool: return host.player_count() == 1), "host removes a disconnected accepted peer")
	host.stop()
	check(not host.is_online() and not client.is_online(), "loopback peers close cleanly")


func _poll_until(host: SessionTransport, client: SessionTransport, predicate: Callable) -> bool:
	for _index: int in range(2_000):
		host.poll()
		client.poll()
		if predicate.call():
			return true
		OS.delay_msec(1)
	return false
