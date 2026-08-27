extends FluxTestSuite


func run() -> int:
	_test_validation_fails_closed()
	_test_enet_loopback_handshake_and_input()
	_test_host_administration()
	_test_charter_assignment_and_capacity()
	_test_reconnect_identity_and_host_loss()
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
	check(SessionCharter.catalog_hash().length() == 64, "session charter catalog contributes a bounded compatibility identity")
	equal(_signature().length(), 64, "compatibility identity is a SHA-256 digest")
	check(not transport.start_host(80, _signature()), "privileged production host port is rejected")
	check(transport.last_error.contains("1024"), "invalid host port has an actionable error")
	check(not transport.start_join("bad address", SessionTransport.DEFAULT_PORT, _signature()), "address whitespace is rejected")
	check(not transport.start_join("127.0.0.1", 70000, _signature()), "out-of-range join port is rejected")
	check(not transport.start_host(0, "not-a-signature"), "malformed compatibility identity is rejected")
	check(not transport.start_host(0, _signature(), ""), "empty player name is rejected")
	check(not transport.start_host(0, _signature(), "Host", "forged"), "unknown host charter is rejected")
	check(not transport.start_join("127.0.0.1", SessionTransport.DEFAULT_PORT, _signature(), "Guest", "bad-hash"), "malformed join charter identity is rejected")
	check(not SessionTransport._valid_input_packet({"sequence": "0", "move_x": 0, "move_y": 0, "held": 0, "pressed": 0, "aim_x": 1000, "aim_y": 0}), "string-coerced input fields fail closed")
	check(SessionTransport._valid_request_packet({"sequence": 0, "action": SessionTransport.REQUEST_EMOTE, "value": 0}), "known typed interaction request validates")
	check(SessionTransport._valid_request_packet({"sequence": 1, "action": SessionTransport.REQUEST_READY_TOGGLE, "value": 0}), "typed Hearth readiness request validates")
	check(SessionTransport._valid_request_packet({"sequence": 2, "action": SessionTransport.REQUEST_PRACTICE_START, "value": 0}), "typed Hearth start request validates")
	check(SessionTransport._valid_request_packet({"sequence": 3, "action": SessionTransport.REQUEST_SPELL_EQUIP, "value": 576}), "typed final Spell Loom request validates")
	check(SessionTransport._valid_request_packet({"sequence": 4, "action": SessionTransport.REQUEST_IMPACT_PRACTICE, "value": 0}), "typed Momentum Chime request validates")
	check(not SessionTransport._valid_request_packet({"sequence": 0, "action": 99, "value": 0}), "unknown interaction request fails closed")
	check(not SessionTransport._valid_request_packet({"sequence": "0", "action": SessionTransport.REQUEST_EMOTE, "value": 0}), "coerced interaction sequence fails closed")
	check(not SessionTransport._valid_request_packet({"sequence": 4, "action": SessionTransport.REQUEST_EMOTE, "value": 1}), "unrelated request cannot smuggle a value")
	var prediction_state := PlayerState.new(2)
	var reconciliation := ClientPrediction.capture_packet(prediction_state, 4, -1)
	check(ClientPrediction.validate_packet(reconciliation), "typed reconciliation packet validates")
	var malformed_reconciliation := reconciliation.duplicate(true)
	malformed_reconciliation["sequence"] = "0"
	check(not ClientPrediction.validate_packet(malformed_reconciliation), "coerced reconciliation acknowledgement fails closed")
	equal(SessionTransport.MAX_PACKETS_PER_POLL, 64, "transport processing has a per-poll work budget")
	equal(SessionTransport.MAX_QUEUED_INPUTS, 28, "accepted input memory is bounded for seven remote peers")
	var return_token := SessionTransport._new_reconnect_token()
	check(SessionTransport._valid_reconnect_token(return_token), "host creates a typed 256-bit return token")
	check(not SessionTransport._valid_reconnect_token(return_token.to_upper()), "return token encoding fails closed on alternate case")
	check(not SessionTransport._valid_reconnect_token("a".repeat(62)), "short return token fails closed")
	equal(SessionTransport._validated_administration_reason("  Company closed  "), "Company closed", "administration reason is bounded and trimmed")
	equal(SessionTransport._validated_administration_reason(""), "", "empty administration reason fails closed")
	equal(SessionTransport._validated_administration_reason("x".repeat(SessionTransport.MAX_ADMIN_REASON_LENGTH + 1)), "", "oversized administration reason fails closed")
	equal(SessionTransport._validated_administration_reason("bad\nreason"), "", "control characters fail closed in administration reasons")


func _test_enet_loopback_handshake_and_input() -> void:
	var host := SessionTransport.new()
	var client := SessionTransport.new()
	check(host.start_host(0, _signature(), "Lantern Host"), "loopback host binds an automatic UDP port: %s" % host.last_error)
	check(host.bound_port >= 1024, "automatic host exposes its actual unprivileged port")
	check(client.start_join("127.0.0.1", host.bound_port, _signature(), "River Guest"), "loopback client begins joining: %s" % client.last_error)
	check(_poll_until(host, client, func() -> bool: return client.is_connected_client()), "compatible loopback client completes handshake")
	check(host.is_host(), "host remains authoritative after client handshake")
	equal(host.session_charter_id, SessionCharter.DEFAULT_ID, "host opens with the safe social charter")
	equal(client.session_charter_id, SessionCharter.DEFAULT_ID, "client receives the host charter during acceptance")
	equal(client.player_capacity(), 8, "client receives the charter capacity from host authority")
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
	for direction_index: int in range(EightDirectionResolver.DIRECTION_ORDER.size()):
		var fixed := EightDirectionResolver.FIXED_VECTORS[direction_index]
		var direction_command := SimCommand.new(0, 1, fixed.x, fixed.y, 0, 0, fixed.x, fixed.y)
		check(client.send_input(18 + direction_index, direction_command), "%s input enters Farflow" % EightDirectionResolver.DIRECTION_ORDER[direction_index])
	check(
		_poll_until(host, client, func() -> bool: return host.incoming_inputs.size() == EightDirectionResolver.DIRECTION_ORDER.size()),
		"host receives the complete eight-direction command matrix",
	)
	var direction_inputs := host.take_inputs()
	equal(direction_inputs.size(), EightDirectionResolver.DIRECTION_ORDER.size(), "Farflow drains exactly eight directional inputs")
	var direction_by_sequence := {}
	for packet: Dictionary in direction_inputs:
		direction_by_sequence[int(packet.get("sequence", -1))] = packet
	for direction_index: int in range(EightDirectionResolver.DIRECTION_ORDER.size()):
		var sequence := 18 + direction_index
		var fixed := EightDirectionResolver.FIXED_VECTORS[direction_index]
		var packet: Dictionary = direction_by_sequence.get(sequence, {})
		equal(Vector2i(int(packet.get("move_x", 0)), int(packet.get("move_y", 0))), fixed, "%s movement survives Farflow exactly" % EightDirectionResolver.DIRECTION_ORDER[direction_index])
		equal(Vector2i(int(packet.get("aim_x", 0)), int(packet.get("aim_y", 0))), fixed, "%s aim survives Farflow exactly" % EightDirectionResolver.DIRECTION_ORDER[direction_index])
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
	check(client.send_request(5, SessionTransport.REQUEST_READY_TOGGLE), "client sends a monotonic Hearth request")
	check(_poll_until(host, client, func() -> bool: return not host.incoming_requests.is_empty()), "host receives Hearth request through reliable ENet")
	var hearth_requests := host.take_requests()
	equal(int(hearth_requests[0].get("action", 0)) if not hearth_requests.is_empty() else 0, SessionTransport.REQUEST_READY_TOGGLE, "Hearth action survives trusted request stamping")
	check(client.send_request(6, SessionTransport.REQUEST_SPELL_EQUIP, 576), "client sends a bounded Spell Loom weave")
	check(_poll_until(host, client, func() -> bool: return not host.incoming_requests.is_empty()), "host receives Spell Loom weave through reliable ENet")
	var spell_requests := host.take_requests()
	equal(int(spell_requests[0].get("value", 0)) if not spell_requests.is_empty() else 0, 576, "host receives the bounded slot/library value")
	check(client.send_request(7, SessionTransport.REQUEST_IMPACT_PRACTICE), "client sends a bounded Momentum Chime intent")
	check(_poll_until(host, client, func() -> bool: return not host.incoming_requests.is_empty()), "host receives Momentum Chime intent through reliable ENet")
	var impact_requests := host.take_requests()
	equal(int(impact_requests[0].get("action", 0)) if not impact_requests.is_empty() else 0, SessionTransport.REQUEST_IMPACT_PRACTICE, "Momentum Chime action survives trusted request stamping")
	check(not client.send_request(8, SessionTransport.REQUEST_SPELL_EQUIP, 577), "out-of-range Spell Loom value fails before transport")

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
	var snapshot_packet := SessionTransport._snapshot_wire_packet(snapshot)
	check(not snapshot_packet.is_empty(), "normal snapshot packs into its bounded wire envelope")
	check(var_to_bytes(snapshot_packet).size() <= SessionTransport.ENET_MTU_BYTES, "normal two-player combat snapshot stays within one ENet MTU")
	var unpacked_snapshot := SessionTransport._snapshot_from_wire_packet(snapshot_packet)
	equal(int(unpacked_snapshot.get("tick", -1)), source.tick, "compressed snapshot wire envelope round-trips exactly")
	check(SessionTransport._snapshot_from_wire_packet({"raw_size": SessionTransport.MAX_SNAPSHOT_UNCOMPRESSED_BYTES + 1, "payload": PackedByteArray([1])}).is_empty(), "oversized snapshot expansion fails closed")
	var reconciliation := ClientPrediction.capture_packet(guest, source.tick, 17)
	check(var_to_bytes({"kind": SessionTransport.PACKET_RECONCILIATION, "reconciliation": reconciliation}).size() <= SessionTransport.ENET_MTU_BYTES, "movement reconciliation stays within its own ENet MTU")
	check(host.send_reconciliation(client.local_peer_id, reconciliation), "host sends scoped movement authority on a separate ordered channel")
	check(_poll_until(host, client, func() -> bool: return not client.incoming_reconciliations.is_empty()), "client receives movement reconciliation through ENet")
	var reconciliations := client.take_reconciliations()
	equal(reconciliations.size(), 1, "client drains one newest reconciliation")
	if not reconciliations.is_empty():
		equal(int(reconciliations[0].get("sequence", -1)), 17, "input acknowledgement survives reconciliation transport")
	var wrong_state := PlayerState.new(3)
	check(not host.send_reconciliation(client.local_peer_id, ClientPrediction.capture_packet(wrong_state, source.tick, 17)), "host refuses reconciliation for another entity")
	check(host.broadcast_snapshot(snapshot), "host broadcasts a validated authoritative snapshot")
	check(_poll_until(host, client, func() -> bool: return not client.incoming_snapshots.is_empty()), "client receives the snapshot through unreliable-ordered ENet")
	var snapshots := client.take_snapshots()
	equal(snapshots.size(), 1, "client drains one validated snapshot")
	if not snapshots.is_empty():
		equal(int(snapshots[0].get("tick", -1)), source.tick, "snapshot tick survives transport")
		equal((snapshots[0].get("projectiles", PackedInt64Array()) as PackedInt64Array).size() / SessionSnapshot.PROJECTILE_VALUE_COUNT, 1, "projectile lane survives unreliable-ordered transport")
		equal((snapshots[0].get("events", []) as Array).size(), 1, "semantic combat event survives unreliable-ordered transport")

	client.stop()
	check(_poll_until(host, client, func() -> bool: return host.player_count() == 1), "host removes a disconnected accepted peer")
	var disconnected := host.take_disconnected_peers()
	equal(disconnected.size(), 1, "host exposes one accepted disconnect event")
	if not disconnected.is_empty():
		equal(int(disconnected[0].get("entity_id", 0)), 2, "disconnect event preserves the released entity mapping")
	host.stop()
	check(not host.is_online() and not client.is_online(), "loopback peers close cleanly")


func _test_host_administration() -> void:
	var host := SessionTransport.new()
	var client := SessionTransport.new()
	var reason := "The host released you from the Farflow company."
	check(host.start_host(0, _signature(), "Steward Host"), "steward host binds")
	check(client.start_join("127.0.0.1", host.bound_port, _signature(), "River Guest"), "steward guest seeks host")
	check(_poll_until(host, client, func() -> bool: return client.is_connected_client()), "steward guest completes guarded acceptance")
	host.take_joined_peers()
	check(not client.host_remove_entity(2, reason), "client cannot call the host-only removal boundary")
	check(client._send_to(SessionTransport.SERVER_PEER_ID, {"kind": SessionTransport.PACKET_ADMIN_CLOSE, "reason": reason}), "forged administration packet reaches host packet boundary")
	for _index: int in range(20):
		host.poll()
		client.poll()
		OS.delay_msec(1)
	equal(host.player_count(), 2, "host ignores client-forged administration packet")
	check(host.take_disconnected_peers().is_empty(), "forged moderation emits no authoritative removal")
	check(not host.host_remove_entity(1, reason), "host cannot target its own entity through guest removal")
	check(not host.host_remove_entity(2, ""), "host cannot remove a guest without a readable reason")
	check(host.host_remove_entity(2, reason), "host begins graceful reason-bearing guest removal")
	check(_poll_until(host, client, func() -> bool: return host.player_count() == 1 and client.mode == SessionTransport.Mode.OFFLINE), "administrative removal reaches both peers")
	equal(client.last_error, reason, "removed guest receives the exact bounded reason")
	check(not client.can_reconnect(), "administratively removed guest loses the return capability")
	equal(host.reserved_count(), 0, "administrative removal creates no return reservation")
	var disconnected := host.take_disconnected_peers()
	equal(disconnected.size(), 1, "host exposes one administrative departure")
	if not disconnected.is_empty():
		check(bool(disconnected[0].get("administrative", false)), "departure is explicitly administrative")
		check(not bool(disconnected[0].get("reserved", true)), "administrative departure is final")
		equal(String(disconnected[0].get("reason", "")), reason, "authoritative departure retains the public reason")
	check(not host.host_remove_entity(2, reason), "removed entity cannot be targeted again")
	var stubborn := SessionTransport.new()
	var close_reason := "The host closed the Farflow company."
	check(stubborn.start_join("127.0.0.1", host.bound_port, _signature(), "Stubborn Guest"), "unresponsive-client fixture seeks host")
	check(_poll_until(host, stubborn, func() -> bool: return stubborn.is_connected_client()), "unresponsive-client fixture is accepted")
	host.take_joined_peers()
	check(host.host_remove_entity(2, close_reason), "host schedules bounded company-close notice")
	equal(host._force_due_administrative_disconnects(Time.get_ticks_msec() + SessionTransport.ADMIN_DISCONNECT_GRACE_MS + 1), 1, "ignored administration notice reaches forced deadline")
	var forced_removed := false
	for _index: int in range(2_000):
		host.poll()
		if host.player_count() == 1:
			forced_removed = true
			break
		OS.delay_msec(1)
	check(forced_removed, "modified client cannot outwait final host removal")
	equal(host.reserved_count(), 0, "forced administrative close also creates no reservation")
	var forced_events := host.take_disconnected_peers()
	check(not forced_events.is_empty() and bool(forced_events[0].get("administrative", false)) and String(forced_events[0].get("reason", "")) == close_reason, "forced departure preserves the company-close reason")
	stubborn.stop()
	host.stop()


func _test_reconnect_identity_and_host_loss() -> void:
	var host := SessionTransport.new()
	var client := SessionTransport.new()
	check(host.start_host(0, _signature(), "Lantern Host"), "reconnect host binds")
	check(client.start_join("127.0.0.1", host.bound_port, _signature(), "River Guest"), "reconnect client begins first join")
	check(_poll_until(host, client, func() -> bool: return client.is_connected_client()), "reconnect client receives first identity")
	equal(client.local_entity_id, 2, "first reconnect identity is entity two")
	var first_token := client.reconnect_token
	check(SessionTransport._valid_reconnect_token(first_token), "accepted client retains an in-memory return capability")
	check(not str(host.host_roster()).contains(first_token), "return capability is absent from public roster serialization")
	check(not host.status_detail.contains(first_token), "return capability is absent from host diagnostics")
	host.take_joined_peers()
	client.stop()
	check(_poll_until(host, client, func() -> bool: return host.reserved_count() == 1), "host reserves disconnected identity")
	equal(host.player_count(), 1, "return reservation is not reported as a connected player")
	equal(host.host_session_roster().size(), 1, "return reservation remains in session actor roster")
	var first_disconnect := host.take_disconnected_peers()
	check(not first_disconnect.is_empty() and bool(first_disconnect[0].get("reserved", false)), "disconnect event distinguishes a reserved return")
	var attacker := SessionTransport.new()
	attacker.reconnect_token = first_token
	attacker.reconnect_address = "127.0.0.1"
	attacker.reconnect_port = host.bound_port
	attacker.reconnect_signature = _signature()
	check(attacker.start_join("127.0.0.1", host.bound_port, _signature(), "False Guest"), "name-mismatch attacker reaches handshake")
	check(_poll_until(host, attacker, func() -> bool: return attacker.mode == SessionTransport.Mode.OFFLINE and not attacker.last_error.is_empty()), "name-mismatch return is rejected")
	check(attacker.last_error.contains("name"), "return name mismatch is explicit")
	equal(host.reserved_count(), 1, "failed token use does not consume reservation")
	check(client.start_join("127.0.0.1", host.bound_port, _signature(), "River Guest"), "original client begins return")
	check(_poll_until(host, client, func() -> bool: return client.is_connected_client()), "original client reclaims reserved identity")
	equal(client.local_entity_id, 2, "return reclaims exact entity two")
	check(client.reconnect_token != first_token and SessionTransport._valid_reconnect_token(client.reconnect_token), "successful return rotates the capability")
	var resumed := host.take_joined_peers()
	check(not resumed.is_empty() and bool(resumed[0].get("resumed", false)), "host presence event distinguishes resumed identity")
	client.stop()
	check(_poll_until(host, client, func() -> bool: return host.reserved_count() == 1), "second disconnect reserves rotated capability")
	host.take_disconnected_peers()
	var expiry_ms := Time.get_ticks_msec() + SessionTransport.RECONNECT_WINDOW_MS + 1
	equal(host._expire_reconnect_reservations(expiry_ms), 1, "bounded return window expires deterministically")
	equal(host.reserved_count(), 0, "expired reservation releases capacity")
	var expired := host.take_disconnected_peers()
	check(not expired.is_empty() and bool(expired[0].get("expired", false)) and not bool(expired[0].get("reserved", true)), "expiry event authorizes actor removal")
	var observer := SessionTransport.new()
	check(observer.start_join("127.0.0.1", host.bound_port, _signature(), "Observer"), "host-loss observer joins")
	check(_poll_until(host, observer, func() -> bool: return observer.is_connected_client()), "host-loss observer is accepted")
	host.stop()
	check(_poll_until(host, observer, func() -> bool: return observer.mode == SessionTransport.Mode.OFFLINE), "forced host loss closes observer")
	check(observer.last_error.contains("Host"), "forced host loss is explicit")
	check(observer.can_reconnect(), "host-loss client retains its endpoint-scoped return capability in memory")
	observer.stop()


func _test_charter_assignment_and_capacity() -> void:
	var host := SessionTransport.new()
	var first := SessionTransport.new()
	var excess := SessionTransport.new()
	var incompatible := SessionTransport.new()
	var charter_id := "duel_knot"
	check(host.start_host(0, _signature(), "Duel Host", charter_id, SessionCharter.profile_hash(charter_id)), "Duel Knot host binds")
	equal(host.player_capacity(), 2, "Duel Knot host enforces two places")
	check(first.start_join("127.0.0.1", host.bound_port, _signature(), "First Guest"), "first Duel guest seeks host")
	check(_poll_until(host, first, func() -> bool: return first.is_connected_client()), "first Duel guest is accepted")
	equal(first.session_charter_id, charter_id, "accepted guest learns the Duel Knot charter")
	equal(first.player_capacity(), 2, "accepted guest learns the authoritative capacity")
	check(excess.start_join("127.0.0.1", host.bound_port, _signature(), "Excess Guest"), "excess Duel guest reaches guarded hello")
	check(_poll_until(host, excess, func() -> bool: return excess.mode == SessionTransport.Mode.OFFLINE and not excess.last_error.is_empty()), "excess Duel guest receives an explicit refusal")
	check(excess.last_error.contains("full"), "charter capacity refusal is readable")
	check(incompatible.start_join("127.0.0.1", host.bound_port, _signature(), "Old Charter", "f".repeat(64)), "old charter catalog reaches guarded hello")
	check(_poll_until(host, incompatible, func() -> bool: return incompatible.mode == SessionTransport.Mode.OFFLINE and not incompatible.last_error.is_empty()), "old charter catalog is refused")
	check(incompatible.last_error.contains("charter"), "charter incompatibility refusal is explicit")
	equal(host.player_count(), 2, "refused travellers never enter Duel roster")
	first.stop()
	host.stop()


func _poll_until(host: SessionTransport, client: SessionTransport, predicate: Callable) -> bool:
	for _index: int in range(2_000):
		host.poll()
		client.poll()
		if predicate.call():
			return true
		OS.delay_msec(1)
	return false
