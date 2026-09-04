extends FluxTestSuite


func run() -> int:
	_test_snapshot_round_trip()
	_test_projectile_and_event_round_trip()
	_test_field_round_trip()
	_test_event_inbox_deduplicates_redundancy()
	_test_maximum_envelope_fits_transport()
	_test_snapshot_validation_fails_closed()
	return finish("session-snapshot")


func _test_snapshot_round_trip() -> void:
	equal(SessionSnapshot.SCHEMA_VERSION, 13, "movement chain snapshot schema is explicit")
	var source := SimWorld.new(120, 7, CollisionWorld.new(3_000_000, 2_000_000))
	var host: PlayerState = source.player()
	host.champion_wire_id = 1
	host.position_x = 1_280_000
	host.position_y = 720_000
	host.health = 87_000
	host.primary_wire_id = CombatTuning.RILLSHOT_WIRE_ID
	host.active_1_wire_id = CombatTuning.TIDELINE_WIRE_ID
	host.active_2_wire_id = CombatTuning.RIMEWAKE_WIRE_ID
	host.reset_spell_slots_to_kit()
	check(host.place_proven_spell(11, host.primary_wire_id), "host rewoves primary to Alt+4 before snapshot")
	check(host.set_spell_cooldown(CombatTuning.ECLIPSE_DISC_WIRE_ID, 17), "host owns a cooldown for a non-champion global spell")
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
	guest.jump_sustain_ticks = 12
	guest.movement_chain_count = 3
	guest.movement_chain_reset_ticks = 31
	guest.movement_action_speed = 777_000
	guest.spawn_protection_ticks = 77
	guest.primary_wire_id = CombatTuning.ECLIPSE_DISC_WIRE_ID
	guest.active_1_wire_id = CombatTuning.POCKET_ECLIPSE_WIRE_ID
	guest.reset_spell_slots_to_kit()
	source.players.append(guest)
	var source_target := PlayerState.new(900)
	source_target.actor_kind = PlayerState.ActorKind.TRAINING_TARGET
	source_target.position_x = 1_500_000
	source_target.position_y = 720_000
	source_target.radius = 18_000
	source_target.health_maximum = 80_000
	source_target.health = 51_000
	source_target.health_recovery_per_second = 0
	source.players.append(source_target)
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
	equal(Array(replica.player().spell_wire_ids), Array(source.player().spell_wire_ids), "host ordered spell slots round-trip")
	equal(Array(replica.player().spell_cooldown_ticks), Array(source.player().spell_cooldown_ticks), "all independent spell cooldowns round-trip")
	equal(replica.player().spell_cooldown_for_wire(CombatTuning.ECLIPSE_DISC_WIRE_ID), 16, "non-champion global cooldown survives one source tick and replication")
	equal(replica.player().active_2_wire_id, CombatTuning.RIMEWAKE_WIRE_ID, "host third proven spell identity round-trips")
	equal(replica.player(2).spawn_protection_ticks, source.player(2).spawn_protection_ticks, "guest spawn protection round-trips")
	equal(replica.player(2).jump_sustain_ticks, source.player(2).jump_sustain_ticks, "paid jump height context round-trips")
	equal(replica.player(2).movement_chain_count, source.player(2).movement_chain_count, "movement chain count round-trips")
	equal(replica.player(2).movement_chain_reset_ticks, source.player(2).movement_chain_reset_ticks, "movement chain reset round-trips")
	equal(replica.player(2).movement_action_speed, MovementSystem._planar_speed(replica.player(2)), "action momentum is reconstructed from authoritative velocity")
	check(replica.player(900) != null, "authoritative practice actor is reconstructed")
	equal(replica.player(900).health, 51_000, "practice actor health round-trips")
	equal(replica.player(900).team_id, 900, "practice actor has a distinct non-champion team after replication")
	equal(SessionSnapshot.names(snapshot), {1: "Lantern Host", 2: "River Guest"}, "display names round-trip separately from simulation state")
	var hearth_state := SessionSnapshot.hearth(snapshot)
	equal(int(hearth_state.get("maximum_players", 0)), 8, "snapshot carries Hearth capacity")
	equal((hearth_state.get("entries", []) as Array).size(), 2, "snapshot carries sorted Hearth roster")
	equal(int(SessionSnapshot.round_state(snapshot).get("phase", -1)), SessionRound.Phase.HEARTH, "snapshot carries explicit Hearth round phase")


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
		{"type": "projectile_hit", "event_id": 41, "projectile_id": 1000, "source_wire_id": CombatTuning.RILLSHOT_WIRE_ID, "owner_id": 1, "target_id": 900, "damage": 9_000},
		{"type": "edgeweave", "event_id": 42, "entity_id": 1, "projectile_id": 1000, "stamina": 8_000},
		{"type": "social_emote", "event_id": 43, "entity_id": 1, "emote_id": 1},
		{"type": "ready_changed", "event_id": 44, "entity_id": 1, "ready": true},
		{"type": "beam_fired", "event_id": 45, "owner_id": 1, "source_wire_id": CombatTuning.POCKET_ECLIPSE_WIRE_ID, "target_id": 900, "end_x": 1_500_000, "end_y": 720_000},
		{"type": "spray_fired", "event_id": 46, "owner_id": 1, "source_wire_id": CombatTuning.TIDELINE_WIRE_ID, "end_x": 1_520_000, "end_y": 720_000, "hit_count": 1},
		{"type": "spray_hit", "event_id": 47, "owner_id": 1, "source_wire_id": CombatTuning.TIDELINE_WIRE_ID, "target_id": 900, "damage": int(CombatTuning.cast_definition(CombatTuning.TIDELINE_WIRE_ID)["damage"])},
	]
	var impact_station_event := SessionSnapshot.encode_event({"type": "station_confirmed", "event_id": 48, "entity_id": 1, "action": SessionTransport.REQUEST_IMPACT_PRACTICE})
	check(not impact_station_event.is_empty() and SessionSnapshot._valid_event_values(impact_station_event), "Momentum Chime confirmation uses the bounded semantic event lane")
	equal(int(SessionSnapshot.decode_event(impact_station_event).get("action", 0)), SessionTransport.REQUEST_IMPACT_PRACTICE, "Momentum Chime confirmation round-trips its stable action")
	var snapshot := SessionSnapshot.capture(source, {1: "Host"}, events)
	check(SessionSnapshot.validate(snapshot), "projectile/event snapshot validates")
	var replica := SimWorld.new(120, 3, CollisionWorld.new(3_000_000, 2_000_000))
	check(SessionSnapshot.apply_to_world(snapshot, replica), "projectile/event snapshot applies")
	equal(replica.projectiles.size(), 1, "one authoritative projectile is reconstructed for presentation")
	if not replica.projectiles.is_empty():
		equal(replica.projectiles[0].source_wire_id, CombatTuning.RILLSHOT_WIRE_ID, "projectile spell identity round-trips")
		equal(replica.projectiles[0].previous_x, 996_000, "projectile lane origin round-trips")
	equal(replica.combat_events.size(), 7, "projectile, beam, spray, social and Hearth events round-trip")
	if replica.combat_events.size() == 7:
		equal(String(replica.combat_events[0].get("type", "")), "projectile_hit", "hit event decodes")
		equal(int(replica.combat_events[1].get("stamina", 0)), 8_000, "edgeweave reward decodes")
		equal(String(replica.combat_events[2].get("type", "")), "social_emote", "social emote decodes")
		equal(int(replica.combat_events[2].get("event_id", 0)), 43, "semantic event identity round-trips inside the fixed header")
		check(bool(replica.combat_events[3].get("ready", false)), "Hearth readiness event decodes")
		equal(String(replica.combat_events[4].get("type", "")), "beam_fired", "beam cue decodes distinctly from a projectile")
		equal(Vector2i(int(replica.combat_events[4].get("end_x", 0)), int(replica.combat_events[4].get("end_y", 0))), Vector2i(1_500_000, 720_000), "beam endpoint round-trips exactly")
		equal(String(replica.combat_events[5].get("type", "")), "spray_fired", "spray fan cue decodes distinctly")
		equal(int(replica.combat_events[5].get("hit_count", 0)), 1, "spray affected count round-trips")
		equal(String(replica.combat_events[6].get("type", "")), "spray_hit", "spray target cue decodes distinctly")
		equal(int(replica.combat_events[6].get("damage", 0)), int(CombatTuning.cast_definition(CombatTuning.TIDELINE_WIRE_ID)["damage"]), "spray hit damage round-trips")
	equal(replica.player().last_event, "cast_release_140", "readable cast event round-trips")


func _test_event_inbox_deduplicates_redundancy() -> void:
	var inbox := SessionEventInbox.new()
	var first: Array[Dictionary] = [{"type": "social_emote", "event_id": 7, "entity_id": 2, "emote_id": 1}]
	equal(inbox.take_unseen(first).size(), 1, "first semantic event reaches presentation")
	equal(inbox.take_unseen(first).size(), 0, "redundant snapshot event is deduplicated")
	var repeated_action: Array[Dictionary] = [{"type": "social_emote", "event_id": 8, "entity_id": 2, "emote_id": 1}]
	equal(inbox.take_unseen(repeated_action).size(), 1, "same action with a new identity remains a real event")
	for event_id: int in range(9, 80):
		inbox.take_unseen([{"type": "projectile_expired", "event_id": event_id, "projectile_id": event_id}])
	equal(inbox.seen_event_ids.size(), SessionEventInbox.MAX_SEEN_EVENT_IDS, "event deduplication memory is bounded")
	inbox.reset()
	equal(inbox.seen_event_ids.size(), 0, "event deduplication resets at session boundary")


func _test_field_round_trip() -> void:
	var source := SimWorld.new(120, 4, CollisionWorld.new(3_000_000, 2_000_000))
	source.player().champion_wire_id = 1
	var guest := PlayerState.new(2)
	guest.champion_wire_id = 2
	source.players.append(guest)
	var field := FieldState.new(
		2000, 1, 1, CombatTuning.RIMEWAKE_WIRE_ID, int(CombatTuning.cast_definition(CombatTuning.RIMEWAKE_WIRE_ID)["element_wire_id"]),
		Vector2i(1_400_000, 720_000), int(CombatTuning.cast_definition(CombatTuning.RIMEWAKE_WIRE_ID)["radius"]), 180,
		PlayerState.ControlState.SLOWED, int(CombatTuning.cast_definition(CombatTuning.RIMEWAKE_WIRE_ID)["hit_control_duration_ms"]), int(CombatTuning.cast_definition(CombatTuning.RIMEWAKE_WIRE_ID)["hit_control_slow_ratio"]),
	)
	field.record_affected(2)
	source.fields.append(field)
	var events: Array[Dictionary] = [{
		"type": "field_triggered", "event_id": 48, "field_id": 2000,
		"owner_id": 1, "source_wire_id": CombatTuning.RIMEWAKE_WIRE_ID, "target_id": 2,
	}]
	var snapshot := SessionSnapshot.capture(source, {1: "Host", 2: "Guest"}, events)
	check(SessionSnapshot.validate(snapshot), "persistent field snapshot validates")
	var replica := SimWorld.new(120, 4, CollisionWorld.new(3_000_000, 2_000_000))
	check(SessionSnapshot.apply_to_world(snapshot, replica), "persistent field snapshot applies")
	equal(replica.fields.size(), 1, "one authoritative field reconstructs for presentation")
	if not replica.fields.is_empty():
		equal(replica.fields[0].source_wire_id, CombatTuning.RIMEWAKE_WIRE_ID, "field spell identity round-trips")
		equal(Vector2i(replica.fields[0].position_x, replica.fields[0].position_y), Vector2i(1_400_000, 720_000), "field placement round-trips exactly")
		check(replica.fields[0].has_affected(2), "bounded champion trigger history round-trips")
	equal(replica.combat_events.size(), 1, "field trigger semantic event round-trips")
	if not replica.combat_events.is_empty():
		equal(String(replica.combat_events[0].get("type", "")), "field_triggered", "field trigger decodes distinctly")
		equal(int(replica.combat_events[0].get("field_id", 0)), 2000, "field event identity round-trips")


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
	for index: int in range(SessionSnapshot.MAX_FIELDS):
		var field := FieldState.new(
			2000 + index,
			1 + index % SessionSnapshot.MAX_PLAYERS,
			1 + index % SessionSnapshot.MAX_PLAYERS,
			CombatTuning.RIMEWAKE_WIRE_ID,
			int(CombatTuning.cast_definition(CombatTuning.RIMEWAKE_WIRE_ID)["element_wire_id"]),
			Vector2i(600_000 + index * 20_000, 650_000),
			int(CombatTuning.cast_definition(CombatTuning.RIMEWAKE_WIRE_ID)["radius"]),
			180,
			PlayerState.ControlState.SLOWED,
			int(CombatTuning.cast_definition(CombatTuning.RIMEWAKE_WIRE_ID)["hit_control_duration_ms"]),
			int(CombatTuning.cast_definition(CombatTuning.RIMEWAKE_WIRE_ID)["hit_control_slow_ratio"]),
		)
		field.record_affected(1 + (index + 1) % SessionSnapshot.MAX_PLAYERS)
		world.fields.append(field)
	var events: Array[Dictionary] = []
	for index: int in range(SessionSnapshot.MAX_EVENTS):
		events.append({"type": "projectile_hit", "projectile_id": 1000 + index, "source_wire_id": CombatTuning.RILLSHOT_WIRE_ID, "owner_id": 1, "target_id": 2, "damage": 9_000})
	for index: int in range(SessionSnapshot.MAX_TARGETS):
		var target := PlayerState.new(900 + index)
		target.actor_kind = PlayerState.ActorKind.TRAINING_TARGET
		target.position_x = 900_000 + index * 40_000
		target.position_y = 800_000
		target.radius = 18_000
		target.health_maximum = 80_000
		target.health = 40_000
		world.players.append(target)
	var snapshot := SessionSnapshot.capture(world, names_by_entity, events)
	check(SessionSnapshot.validate(snapshot), "maximum public snapshot envelope validates")
	var raw_snapshot := var_to_bytes(snapshot)
	var unconstrained_packet := {
		"kind": SessionTransport.PACKET_SNAPSHOT,
		"raw_size": raw_snapshot.size(),
		"payload": raw_snapshot.compress(FileAccess.COMPRESSION_FASTLZ),
	}
	var unconstrained_packet_size := var_to_bytes(unconstrained_packet).size()
	var wire_packet := SessionTransport._snapshot_wire_packet(snapshot)
	check(not wire_packet.is_empty(), "maximum public snapshot packs into a guarded wire envelope (%d/%d bytes)" % [unconstrained_packet_size, SessionTransport.ENET_MTU_BYTES])
	check(unconstrained_packet_size <= SessionTransport.ENET_MTU_BYTES, "maximum snapshot fits one ENet MTU (%d/%d bytes)" % [unconstrained_packet_size, SessionTransport.ENET_MTU_BYTES])
	check(SessionTransport._snapshot_from_wire_packet(wire_packet) == snapshot, "maximum compressed snapshot round-trips exactly")


func _test_snapshot_validation_fails_closed() -> void:
	var world := SimWorld.new(120, 1, CollisionWorld.new())
	world.player().champion_wire_id = 1
	var valid := SessionSnapshot.capture(world, {1: "Host"})
	for mutation: Callable in [
		func(value: Dictionary) -> void: value["schema"] = 99,
		func(value: Dictionary) -> void: value["tick"] = -1,
		func(value: Dictionary) -> void: value["state_hash"] = "forged",
		func(value: Dictionary) -> void: (value["players"] as Array).append((value["players"] as Array)[0].duplicate(true)),
		func(value: Dictionary) -> void: ((value["players"] as Array)[0] as Array)[0] = 9,
		func(value: Dictionary) -> void: ((value["players"] as Array)[0] as Array)[1] = "",
		func(value: Dictionary) -> void: ((value["players"] as Array)[0] as Array)[2] = "BAD EVENT",
		func(value: Dictionary) -> void: ((value["players"] as Array)[0] as Array)[3] = PackedInt32Array([1]),
		func(value: Dictionary) -> void: value["overflow"] = PackedInt32Array([-1, 0, 0, 0]),
		func(value: Dictionary) -> void: value["fields"] = PackedInt32Array([2000, 1, CombatTuning.RIMEWAKE_WIRE_ID, 0, 0, 0, 0]),
		func(value: Dictionary) -> void: value["events"] = [PackedInt64Array([99, 0, 0, 0, 0, 0])],
		func(value: Dictionary) -> void: value["hearth"] = PackedInt32Array([1, 8, 0, 8]),
		func(value: Dictionary) -> void: value["round"] = PackedInt32Array([1, 9, 0, 0, 0, 3, 0]),
	]:
		var malformed: Dictionary = valid.duplicate(true)
		mutation.call(malformed)
		check(not SessionSnapshot.validate(malformed), "malformed snapshot is rejected")
