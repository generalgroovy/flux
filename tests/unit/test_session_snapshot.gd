extends FluxTestSuite


func run() -> int:
	_test_snapshot_round_trip()
	_test_snapshot_validation_fails_closed()
	return finish("session-snapshot")


func _test_snapshot_round_trip() -> void:
	var source := SimWorld.new(120, 7, CollisionWorld.new(3_000_000, 2_000_000))
	var host: PlayerState = source.player()
	host.champion_wire_id = 1
	host.position_x = 1_280_000
	host.position_y = 720_000
	host.health = 87_000
	host.primary_wire_id = CombatTuning.RILLSHOT_WIRE_ID
	host.active_1_wire_id = CombatTuning.TIDELINE_WIRE_ID
	var guest := PlayerState.new(2)
	guest.champion_wire_id = 2
	guest.position_x = 1_352_000
	guest.position_y = 720_000
	guest.movement_mode = PlayerState.MovementMode.SPRINT
	guest.sprinting = true
	guest.health_maximum = 90_000
	guest.health = 72_000
	guest.flux_maximum = 112_000
	guest.flux = 54_000
	guest.stamina_maximum = 96_000
	guest.stamina = 33_000
	guest.primary_wire_id = CombatTuning.ECLIPSE_DISC_WIRE_ID
	guest.active_1_wire_id = CombatTuning.POCKET_ECLIPSE_WIRE_ID
	source.players.append(guest)
	check(source.step([SimCommand.new(0, 1), SimCommand.new(0, 2, 1000, 0, SimCommand.HELD_SPRINT)]), "authoritative source advances before capture")
	var snapshot := SessionSnapshot.capture(source, {1: "Lantern Host", 2: "River Guest"})
	check(SessionSnapshot.validate(snapshot), "bounded two-player snapshot validates")
	equal(int(snapshot.get("tick", -1)), source.tick, "snapshot owns the authoritative post-step tick")
	var encoded := var_to_bytes(snapshot)
	check(encoded.size() < SessionTransport.MAX_PACKET_BYTES, "two-player snapshot fits the transport packet budget")

	var replica := SimWorld.new(120, 7, CollisionWorld.new(3_000_000, 2_000_000))
	var target := PlayerState.new(900)
	target.actor_kind = PlayerState.ActorKind.TRAINING_TARGET
	replica.players.append(target)
	check(SessionSnapshot.apply_to_world(snapshot, replica), "validated snapshot applies to a replica")
	equal(replica.tick, source.tick, "replica adopts host tick")
	equal(replica.player(2).position_x, source.player(2).position_x, "guest authoritative position round-trips")
	equal(replica.player(2).movement_mode, PlayerState.MovementMode.SPRINT, "guest movement mode round-trips")
	equal(replica.player(2).primary_wire_id, CombatTuning.ECLIPSE_DISC_WIRE_ID, "guest kit identity round-trips")
	check(replica.player(900) != null, "local practice actors survive champion snapshot replacement")
	equal(SessionSnapshot.names(snapshot), {1: "Lantern Host", 2: "River Guest"}, "display names round-trip separately from simulation state")


func _test_snapshot_validation_fails_closed() -> void:
	var world := SimWorld.new(120, 1, CollisionWorld.new())
	world.player().champion_wire_id = 1
	var valid := SessionSnapshot.capture(world, {1: "Host"})
	for mutation: Callable in [
		func(value: Dictionary) -> void: value["schema"] = 99,
		func(value: Dictionary) -> void: value["tick"] = -1,
		func(value: Dictionary) -> void: value["state_hash"] = "forged",
		func(value: Dictionary) -> void: (value["players"] as Array).append((value["players"] as Array)[0].duplicate(true)),
		func(value: Dictionary) -> void: ((value["players"] as Array)[0] as Dictionary)["entity_id"] = 9,
		func(value: Dictionary) -> void: ((value["players"] as Array)[0] as Dictionary)["name"] = "",
		func(value: Dictionary) -> void: ((value["players"] as Array)[0] as Dictionary)["values"] = PackedInt64Array([1]),
	]:
		var malformed: Dictionary = valid.duplicate(true)
		mutation.call(malformed)
		check(not SessionSnapshot.validate(malformed), "malformed snapshot is rejected")
