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
	check(SessionTransport._valid_request_packet({"sequence": 0, "action": SessionTransport.REQUEST_EMOTE}), "known typed interaction request validates")
	check(not SessionTransport._valid_request_packet({"sequence": 0, "action": 99}), "unknown interaction request fails closed")
	check(not SessionTransport._valid_request_packet({"sequence": "0", "action": SessionTransport.REQUEST_EMOTE}), "coerced interaction sequence fails closed")
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
	equal(client.local_entity_id, 2, "first guest receives stable session entity two")
	var joined := host.take_joined_peers()
	equal(joined.size(), 1, "host exposes one accepted presence event")
	if not joined.is_empty():
		equal(int(joined[0].get("entity_id", 0)), 2, "presence event owns the stable entity mapping")
		equal(String(joined[0].get("name", "")), "River Guest", "presence event carries the validated display name")

	var command := SimCommand.new(0, 1, 700, -300, SimCommand.HELD_SPRINT, SimCommand.PRESSED_JUMP, 1000, 0)
	check(client.send_input(17, command), "accepted client sends a bounded input packet")
	check(_poll_until(host, client, func() -> bool: return not host.incoming_inputs.is_empty()), "host receives client input through ENet")
	var inputs: Array[Dictionary] = host.take_inputs()
	equal(inputs.size(), 1, "host drains one validated input")
	if not inputs.is_empty():
		equal(int(inputs[0].get("sequence", -1)), 17, "input sequence survives transport")
		equal(int(inputs[0].get("move_x", 0)), 700, "input movement survives transport")
		equal(int(inputs[0].get("peer_id", 0)), client.local_peer_id, "host stamps trusted sender identity")
		equal(int(inputs[0].get("entity_id", 0)), client.local_entity_id, "host stamps the trusted simulation entity")
	check(host.take_inputs().is_empty(), "host input drain is single-consumer")
	check(client.send_input(17, command), "client can retransmit but cannot authorize a repeated sequence")
	for _index: int in range(20):
		host.poll()
		client.poll()
		OS.delay_msec(1)
	check(host.take_inputs().is_empty(), "host drops replayed input sequences")
	check(client.send_request(4, SessionTransport.REQUEST_EMOTE), "client sends a bounded reliable interaction intent")
	check(_poll_until(host, client, func() -> bool: return not host.incoming_requests.is_empty()), "host receives interaction intent through ENet")
	var requests := host.take_requests()
	equal(requests.size(), 1, "host drains one validated interaction intent")
	if not requests.is_empty():
		equal(int(requests[0].get("entity_id", 0)), client.local_entity_id, "host stamps trusted request entity")
		equal(int(requests[0].get("action", 0)), SessionTransport.REQUEST_EMOTE, "request action survives transport")
	check(client.send_request(4, SessionTransport.REQUEST_EMOTE), "client retransmit reaches replay boundary")
	for _index: int in range(20):
		host.poll()
		client.poll()
		OS.delay_msec(1)
	check(host.take_requests().is_empty(), "host drops replayed interaction sequence")

	var incompatible := SessionTransport.new()
	check(incompatible.start_join("127.0.0.1", host.bound_port, _signature(60), "Old Build"), "incompatible client reaches handshake boundary")
	check(_poll_until(host, incompatible, func() -> bool: return incompatible.mode == SessionTransport.Mode.OFFLINE and not incompatible.last_error.is_empty()), "incompatible session is rejected deterministically")
	check(incompatible.last_error.contains("Incompatible"), "compatibility refusal explains the mismatch")
	equal(host.player_count(), 2, "rejected client never enters authoritative roster")

	var source := SimWorld.new(120, 1, CollisionWorld.new())
	source.player().champion_wire_id = 1
	var guest := PlayerState.new(2)
	guest.champion_wire_id = 2
	source.players.append(guest)
	var target := PlayerState.new(900)
	target.actor_kind = PlayerState.ActorKind.TRAINING_TARGET
	target.position_x = 700_000
	target.position_y = 500_000
	target.radius = 18_000
	target.health_maximum = 80_000
	target.health = 80_000
	source.players.append(target)
	source.projectiles.append(ProjectileState.new(
		1000, 2, 2, CombatTuning.ECLIPSE_DISC_WIRE_ID, 8,
		Vector2i(500_000, 500_000), Vector2i(400_000, 0),
		14_000, 10_000, 90,
	))
	var snapshot := SessionSnapshot.capture(
		source,
		{1: "Lantern Host", 2: "River Guest"},
		[{"type": "projectile_spawned", "projectile_id": 1000, "owner_id": 2, "wire_id": CombatTuning.ECLIPSE_DISC_WIRE_ID}],
	)
	check(var_to_bytes({"kind": SessionTransport.PACKET_SNAPSHOT, "snapshot": snapshot}).size() <= 1_392, "normal two-player combat snapshot stays within one ENet MTU")
	check(host.broadcast_snapshot(snapshot), "host broadcasts a validated authoritative snapshot")
	check(_poll_until(host, client, func() -> bool: return not client.incoming_snapshots.is_empty()), "client receives the snapshot through unreliable-ordered ENet")
	var snapshots := client.take_snapshots()
	equal(snapshots.size(), 1, "client drains one validated snapshot")
	if not snapshots.is_empty():
		equal(int(snapshots[0].get("tick", -1)), source.tick, "snapshot tick survives transport")
		equal((snapshots[0].get("projectiles", []) as Array).size(), 1, "projectile lane survives unreliable-ordered transport")
		equal((snapshots[0].get("events", []) as Array).size(), 1, "semantic combat event survives unreliable-ordered transport")

	client.stop()
	check(_poll_until(host, client, func() -> bool: return host.player_count() == 1), "host removes a disconnected accepted peer")
	var disconnected := host.take_disconnected_peers()
	equal(disconnected.size(), 1, "host exposes one accepted disconnect event")
	if not disconnected.is_empty():
		equal(int(disconnected[0].get("entity_id", 0)), 2, "disconnect event preserves the released entity mapping")
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
