extends FluxTestSuite


func run() -> int:
	_test_snapshot_round_trip()
	_test_projectile_and_event_round_trip()
	_test_maximum_envelope_fits_transport()
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


func _test_projectile_and_event_round_trip() -> void:
	var source := SimWorld.new(120, 3, CollisionWorld.new(3_000_000, 2_000_000))
	source.player().champion_wire_id = 1
	source.player().last_event = "cast_release_140"
	var projectile := ProjectileState.new(
		1000, 1, 1, CombatTuning.RILLSHOT_WIRE_ID, 2,
		Vector2i(1_000_000, 700_000), Vector2i(480_000, 0),
		12_000, 9_000, 90,
	)
	projectile.previous_x = 996_000
	source.projectiles.append(projectile)
	var events: Array[Dictionary] = [
		{"type": "projectile_hit", "projectile_id": 1000, "source_wire_id": CombatTuning.RILLSHOT_WIRE_ID, "owner_id": 1, "target_id": 900, "damage": 9_000},
		{"type": "edgeweave", "entity_id": 1, "projectile_id": 1000, "stamina": 8_000},
	]
	var snapshot := SessionSnapshot.capture(source, {1: "Host"}, events)
	check(SessionSnapshot.validate(snapshot), "projectile/event snapshot validates")
	var replica := SimWorld.new(120, 3, CollisionWorld.new(3_000_000, 2_000_000))
	check(SessionSnapshot.apply_to_world(snapshot, replica), "projectile/event snapshot applies")
	equal(replica.projectiles.size(), 1, "one authoritative projectile is reconstructed for presentation")
	if not replica.projectiles.is_empty():
		equal(replica.projectiles[0].source_wire_id, CombatTuning.RILLSHOT_WIRE_ID, "projectile spell identity round-trips")
		equal(replica.projectiles[0].previous_x, 996_000, "projectile lane origin round-trips")
	equal(replica.combat_events.size(), 2, "semantic combat events round-trip")
	if replica.combat_events.size() == 2:
		equal(String(replica.combat_events[0].get("type", "")), "projectile_hit", "hit event decodes")
		equal(int(replica.combat_events[1].get("stamina", 0)), 8_000, "edgeweave reward decodes")
	equal(replica.player().last_event, "cast_release_140", "readable cast event round-trips")


func _test_maximum_envelope_fits_transport() -> void:
	var world := SimWorld.new(120, 5, CollisionWorld.new(20_000_000, 20_000_000))
	world.player().champion_wire_id = 1
	var names_by_entity: Dictionary[int, String] = {1: "Traveller01LongDisplayXX"}
	world.player().last_event = "cast_release_65535"
	for entity_id: int in range(2, SessionSnapshot.MAX_PLAYERS + 1):
		var state := PlayerState.new(entity_id)
		state.champion_wire_id = 1 if entity_id % 2 == 1 else 2
		world.players.append(state)
		state.last_event = "cast_release_65535"
		names_by_entity[entity_id] = "Traveller%02dLongDisplayXX" % entity_id
	for index: int in range(SessionSnapshot.MAX_PROJECTILES):
		world.projectiles.append(ProjectileState.new(
			1000 + index,
			1 + index % SessionSnapshot.MAX_PLAYERS,
			1,
			CombatTuning.RILLSHOT_WIRE_ID,
			2,
			Vector2i(500_000 + index * 10_000, 500_000),
			Vector2i(480_000, 0),
			12_000,
			9_000,
			90,
		))
	var events: Array[Dictionary] = []
	for index: int in range(SessionSnapshot.MAX_EVENTS):
		events.append({"type": "projectile_hit", "projectile_id": 1000 + index, "source_wire_id": CombatTuning.RILLSHOT_WIRE_ID, "owner_id": 1, "target_id": 2, "damage": 9_000})
	var snapshot := SessionSnapshot.capture(world, names_by_entity, events)
	check(SessionSnapshot.validate(snapshot), "maximum public snapshot envelope validates")
	var packet_size := var_to_bytes({"kind": SessionTransport.PACKET_SNAPSHOT, "snapshot": snapshot}).size()
	check(packet_size <= SessionTransport.MAX_PACKET_BYTES, "maximum snapshot fits one guarded packet (%d/%d bytes)" % [packet_size, SessionTransport.MAX_PACKET_BYTES])


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
		func(value: Dictionary) -> void: ((value["players"] as Array)[0] as Dictionary)["event"] = "BAD EVENT",
		func(value: Dictionary) -> void: ((value["players"] as Array)[0] as Dictionary)["values"] = PackedInt64Array([1]),
		func(value: Dictionary) -> void: value["projectile_overflow"] = -1,
		func(value: Dictionary) -> void: value["events"] = [PackedInt64Array([99, 0, 0, 0, 0, 0])],
	]:
		var malformed: Dictionary = valid.duplicate(true)
		mutation.call(malformed)
		check(not SessionSnapshot.validate(malformed), "malformed snapshot is rejected")
