extends SceneTree


# Standalone production-path diagnostic, deliberately outside the ordinary Full
# suite. Fixture injection is offline only; it does not raise Farflow capacity.
# --quick selects the legal eight-actor journey only.
# --require-network-clear turns observed legal-load transport gaps into failure.
const SEED: int = 608_120
const WARMUP_TICKS: int = 120
const LEGAL_TICKS: int = 720
const FIXTURE_TICKS: int = 120
const CLEANUP_LIMIT: int = 1_200
const TICK_BUDGET_US: int = 8_333

var failures: int = 0
var assertions: int = 0
var abilities := AbilityCatalog.new()
var champions := ChampionCatalog.new()
var legal_network_gaps: int = 0
var executed_scenarios: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if OS.get_cmdline_user_args().has("--collision-only"):
		var suite := preload("res://tests/unit/test_collision_broadphase.gd").new()
		quit(suite.run())
		return
	var abilities_loaded := abilities.load_from_file("res://content/abilities/foundation_abilities_v1.json")
	_check(abilities_loaded, "ability content loads: %s" % abilities.last_error)
	var champions_loaded := champions.load_from_file("res://content/champions/foundation_champions_v1.json", abilities)
	_check(champions_loaded, "champion content loads: %s" % champions.last_error)
	if failures > 0:
		quit(1)
		return
	print("RUNTIME_PROBE_META ", JSON.stringify({
		"version": 1, "engine": Engine.get_version_info()["string"],
		"protocol": SimConfig.PROTOCOL_VERSION, "snapshot_schema": SessionSnapshot.SCHEMA_VERSION,
		"seed": SEED, "tick_rate": 120, "cpu": OS.get_processor_name(),
		"ability_sha256": FileAccess.get_sha256("res://content/abilities/foundation_abilities_v1.json"),
		"champion_sha256": FileAccess.get_sha256("res://content/champions/foundation_champions_v1.json"),
		"measurement": "SimWorld.step only; snapshots timed separately; no rendered FPS or socket/network capacity claim",
	}))
	_run_pair("legal-eight-burst", 8, 0, 0, 0, true)
	if not OS.get_cmdline_user_args().has("--quick"):
		_run_pair("admitted-eight-envelope", 8, SimConfig.MAX_ACTIVE_PROJECTILES, SimConfig.MAX_ACTIVE_FIELDS, 64, false)
		_run_pair("eight-256-projectiles-open", 8, 256, 16, 0, false)
		_run_pair("eight-256-projectiles-16-fields", 8, 256, 16, 64, false)
		_run_pair("offline-32-256-projectiles", 32, 256, 16, 64, false)
		_run_pair("offline-64-1024-projectiles", 64, 1024, 32, 64, false)
	if OS.get_cmdline_user_args().has("--require-network-clear"):
		_check(legal_network_gaps == 0, "legal eight-player load has no omitted danger or rejected snapshot")
	_check(executed_scenarios > 0, "at least one known scenario was selected")
	print("%s: runtime-stress-probe; %d assertions; %d failures; legal network-gap samples=%d" % [
		"PASS" if failures == 0 else "FAIL", assertions, failures, legal_network_gaps,
	])
	if legal_network_gaps > 0:
		print("DIAGNOSTIC: legal eight-player network coverage is NOT accepted; use --require-network-clear as its fail-closed gate.")
	quit(0 if failures == 0 else 1)


func _run_pair(label: String, actor_count: int, projectile_count: int, field_count: int, obstacle_count: int, legal_casts: bool) -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--scenario=") and argument.trim_prefix("--scenario=") != label:
			return
	executed_scenarios += 1
	var reference: Dictionary = {}
	for repeat_index: int in range(2):
		var result := _run_scenario(label, actor_count, projectile_count, field_count, obstacle_count, legal_casts, repeat_index == 1)
		if repeat_index == 0:
			reference = result
		else:
			_check(result["checkpoints"] == reference["checkpoints"], "%s repeat hashes agree with reversed command order" % label)
			_check(result["final_hash"] == reference["final_hash"], "%s final clean-world hash agrees" % label)
			_check(result["expiry_events"] == reference["expiry_events"], "%s lifecycle event counts repeat" % label)
		result["repeat"] = repeat_index + 1
		print("RUNTIME_PROBE_RESULT ", JSON.stringify(result))


func _run_scenario(label: String, actor_count: int, projectile_count: int, field_count: int, obstacle_count: int, legal_casts: bool, reverse_commands: bool) -> Dictionary:
	var world := _make_world(actor_count, obstacle_count)
	_check(world.is_valid(), "%s world starts valid" % label)
	for _warmup: int in range(WARMUP_TICKS):
		_check(world.step(_commands(world, false, reverse_commands)), "%s warmup step" % label)
	if not legal_casts:
		_seed_load(world, projectile_count, field_count)
	var samples := PackedInt64Array()
	var snapshot_samples := PackedInt64Array()
	var checkpoints: Array[String] = []
	var peak_projectiles := world.projectiles.size()
	var peak_fields := world.fields.size()
	var peak_events := 0
	var peak_raw_bytes := 0
	var peak_wire_bytes := 0
	var peak_datagram_bytes := 0
	var peak_datagram_count := 0
	var rejected_packets := 0
	var snapshot_count := 0
	var overflow_samples := 0
	var maximum_overflow := PackedInt32Array([0, 0, 0, 0])
	var expiry_events := PackedInt32Array([0, 0])
	var over_budget_ticks := 0
	var sample_ticks := LEGAL_TICKS if legal_casts else FIXTURE_TICKS
	for sample_index: int in range(sample_ticks):
		# Match the production renderer's read-only obstacle access each frame;
		# this must not accidentally disable the optimized simulation path.
		world.collision.obstacle_view()
		var commands := _commands(world, legal_casts, reverse_commands)
		var started_us := Time.get_ticks_usec()
		var stepped := world.step(commands)
		var elapsed_us := Time.get_ticks_usec() - started_us
		samples.append(elapsed_us)
		if elapsed_us > TICK_BUDGET_US:
			over_budget_ticks += 1
		_check(stepped, "%s sample step" % label)
		peak_projectiles = maxi(peak_projectiles, world.projectiles.size())
		peak_fields = maxi(peak_fields, world.fields.size())
		peak_events = maxi(peak_events, world.combat_events.size())
		_count_expiry(world, expiry_events)
		if sample_index % 60 == 0:
			checkpoints.append(world.state_hash())
		if actor_count <= SessionSnapshot.MAX_PLAYERS and sample_index % 2 == 0:
			started_us = Time.get_ticks_usec()
			var snapshot := SessionSnapshot.capture(world, {}, world.combat_events)
			var packets := SessionTransport._snapshot_wire_packets(snapshot)
			snapshot_samples.append(Time.get_ticks_usec() - started_us)
			snapshot_count += 1
			_check(SessionSnapshot.validate(snapshot), "%s authoritative snapshot validates" % label)
			var overflow: PackedInt32Array = snapshot["overflow"]
			_check(overflow[0] == maxi(0, world.projectiles.size() - SessionSnapshot.MAX_PROJECTILES), "%s projectile overflow is exact" % label)
			_check(overflow[1] == maxi(0, world.fields.size() - SessionSnapshot.MAX_FIELDS), "%s field overflow is exact" % label)
			for overflow_index: int in range(4):
				maximum_overflow[overflow_index] = maxi(maximum_overflow[overflow_index], overflow[overflow_index])
			var missing_danger := overflow[0] > 0 or overflow[1] > 0
			if missing_danger:
				overflow_samples += 1
			peak_raw_bytes = maxi(peak_raw_bytes, var_to_bytes(snapshot).size())
			# Measure the rejected envelope too; an empty production packet must
			# never be mistaken for a zero-byte successful transmission.
			var raw := var_to_bytes(snapshot)
			var candidate := {"kind": SessionTransport.PACKET_SNAPSHOT, "raw_size": raw.size(), "payload": raw.compress(FileAccess.COMPRESSION_FASTLZ)}
			peak_wire_bytes = maxi(peak_wire_bytes, var_to_bytes(candidate).size())
			if packets.is_empty():
				rejected_packets += 1
			else:
				peak_datagram_count = maxi(peak_datagram_count, packets.size())
				var client := SessionTransport.new()
				client.mode = SessionTransport.Mode.CLIENT
				packets.reverse()
				for packet_index: int in range(packets.size()):
					var encoded := var_to_bytes(packets[packet_index])
					peak_datagram_bytes = maxi(peak_datagram_bytes, encoded.size())
					_check(encoded.size() <= SessionTransport.ENET_MTU_BYTES, "%s every fragment fits one MTU" % label)
					client._handle_packet(SessionTransport.SERVER_PEER_ID, encoded)
					if packet_index < packets.size() - 1:
						_check(client.incoming_snapshots.is_empty(), "%s incomplete reversed fragments publish no partial frame" % label)
				var received := client.take_snapshots()
				_check(received.size() == 1 and received[0] == snapshot, "%s accepted reversed fragments reconstruct exactly one complete snapshot" % label)
			if legal_casts and (missing_danger or packets.is_empty()):
				legal_network_gaps += 1
	_check(peak_projectiles >= (40 if legal_casts else projectile_count), "%s requested load was actually reached" % label)
	if not legal_casts:
		_check(world.projectiles.size() == projectile_count, "%s full projectile fixture survived the measurement window" % label)
		_check(world.fields.size() == field_count, "%s full field fixture survived the measurement window" % label)
	var cleanup_ticks := 0
	while cleanup_ticks < CLEANUP_LIMIT and (not world.projectiles.is_empty() or not world.fields.is_empty() or _has_pending_cast(world)):
		_check(world.step(_commands(world, false, reverse_commands)), "%s cleanup step" % label)
		peak_events = maxi(peak_events, world.combat_events.size())
		_count_expiry(world, expiry_events)
		cleanup_ticks += 1
	_check(world.projectiles.is_empty() and world.fields.is_empty() and not _has_pending_cast(world), "%s all projectiles/fields/pending casts expire without forced clearing" % label)
	if not legal_casts:
		_check(expiry_events[0] == projectile_count and expiry_events[1] == field_count, "%s every injected asset emits exactly one expiry" % label)
	_check(world.combat_events.size() <= projectile_count + field_count + actor_count * 5, "%s events remain tick-scoped during simultaneous expiry" % label)
	_check(world.step([]), "%s one idle step after cleanup" % label)
	_check(world.combat_events.is_empty(), "%s previous expiry event batch is released on next tick" % label)
	return {
		"scenario": label, "actor_count": actor_count, "obstacle_count": obstacle_count,
		"obstacle_path": "legacy linear" if OS.get_cmdline_user_args().has("--linear-obstacles") else "indexed with bounded/small-map fallback",
		"source": "ordinary paid spell commands" if legal_casts else "offline initial-state load fixture; ordinary authoritative updates",
		"sample_ticks": sample_ticks, "tick_us": _percentiles(samples), "ticks_over_8333_us": over_budget_ticks,
		"peak_projectiles": peak_projectiles, "peak_fields": peak_fields, "peak_events": peak_events,
		"snapshot_samples": snapshot_count, "snapshot_capture_and_pack_us": _percentiles(snapshot_samples),
		"peak_snapshot_raw_bytes": peak_raw_bytes, "peak_candidate_wire_bytes": peak_wire_bytes,
		"peak_datagram_bytes": peak_datagram_bytes, "peak_datagram_count": peak_datagram_count,
		"snapshot_rejections": rejected_packets, "danger_overflow_samples": overflow_samples,
		"maximum_overflow_projectiles_fields_events_targets": Array(maximum_overflow),
		"network_scope": "eight-player presentation envelope" if actor_count <= SessionSnapshot.MAX_PLAYERS else "not attempted; above supported lobby ceiling",
		"expiry_events": Array(expiry_events), "cleanup_ticks": cleanup_ticks,
		"checkpoints": checkpoints, "final_hash": world.state_hash(),
	}


func _make_world(actor_count: int, obstacle_count: int) -> SimWorld:
	var collision := CollisionWorld.new(12_000_000, 6_000_000)
	for index: int in range(obstacle_count):
		var x := 7_000_000 + (index % 8) * 400_000
		@warning_ignore("integer_division")
		var y := 3_000_000 + (index / 8) * 300_000
		collision.add_obstacle(CollisionWorld.Obstacle.new(index + 1, x, y, x + 160_000, y + 160_000))
	var world := SimWorld.new(120, SEED, collision, "runtime-stress-v1", "offline-fixture:12000x6000;obstacles:%d" % obstacle_count)
	world.players.clear()
	var champion_ids := champions.ordered_champion_ids()
	for index: int in range(actor_count):
		var state := PlayerState.new(index + 1)
		_check(champions.apply_to_player(state, champion_ids[index % champion_ids.size()]), "fixture uses validated champion stats")
		state.position_x = 1_000_000 + (index % 8) * 600_000
		@warning_ignore("integer_division")
		state.position_y = 2_000_000 + (index / 8) * 300_000
		state.team_id = index + 1
		_check(state.place_proven_spell(0, CombatTuning.ELEMENTAL_BURST_WIRE_IDS[index % 8]), "fixture equips a real elemental Burst")
		world.players.append(state)
	if OS.get_cmdline_user_args().has("--linear-obstacles"):
		var legacy_array := collision.obstacles
		_check(legacy_array.size() == obstacle_count, "explicit linear-reference benchmark preserves all obstacles")
	return world


func _commands(world: SimWorld, allow_casts: bool, reverse_order: bool) -> Array[SimCommand]:
	var commands: Array[SimCommand] = []
	for state: PlayerState in world.players:
		# Parallel lanes keep actors alive and exercise real geometric target
		# checks. No health refill, cooldown bypass or per-tick state rewrite.
		var direction := 1000 if world.tick % 240 < 120 else -1000
		var pressed := SimCommand.PRESSED_SPELL_1 if allow_casts and world.tick % 120 == 0 else 0
		commands.append(SimCommand.new(world.tick, state.entity_id, direction, 0, 0, pressed, 0, -1000))
	if reverse_order:
		commands.reverse()
	return commands


func _seed_load(world: SimWorld, projectile_count: int, field_count: int) -> void:
	var bolt := CombatTuning.cast_definition(CombatTuning.PRIMARY_WIRE_ID)
	var field_definition := CombatTuning.cast_definition(CombatTuning.RIMEWAKE_WIRE_ID)
	for index: int in range(projectile_count):
		var position := Vector2i(1_000_000 + (index % 64) * 4_000, 100_000 + (index % 31) * 9_000)
		world.projectiles.append(ProjectileState.new(world.next_projectile_id, 1, 1, CombatTuning.PRIMARY_WIRE_ID,
			int(bolt["element_wire_id"]), position, Vector2i(int(bolt["speed"]), 0), int(bolt["radius"]),
			int(bolt["damage"]), world.config.milliseconds_to_ticks(int(bolt["lifetime_ms"]))))
		world.next_projectile_id += 1
	for index: int in range(field_count):
		world.fields.append(FieldState.new(world.next_field_id, 1, 1, CombatTuning.RIMEWAKE_WIRE_ID,
			int(field_definition["element_wire_id"]), Vector2i(1_000_000 + index * 20_000, 900_000),
			int(field_definition["radius"]), world.config.milliseconds_to_ticks(int(field_definition["lifetime_ms"])),
			int(field_definition["hit_control_state"]), int(field_definition["hit_control_duration_ms"]),
			int(field_definition["hit_control_slow_ratio"])))
		world.next_field_id += 1


func _has_pending_cast(world: SimWorld) -> bool:
	for state: PlayerState in world.players:
		if state.pending_cast_wire_id != 0:
			return true
	return false


func _count_expiry(world: SimWorld, totals: PackedInt32Array) -> void:
	for event: Dictionary in world.combat_events:
		if event.get("type") == "projectile_expired":
			totals[0] += 1
		elif event.get("type") == "field_expired":
			totals[1] += 1


func _percentiles(values: PackedInt64Array) -> Dictionary:
	if values.is_empty():
		return {}
	var ordered := values.duplicate()
	ordered.sort()
	return {"median": ordered[ceili(ordered.size() * 0.5) - 1], "p95": ordered[ceili(ordered.size() * 0.95) - 1],
		"p99": ordered[ceili(ordered.size() * 0.99) - 1], "max": ordered[ordered.size() - 1]}


func _check(condition: bool, label: String) -> void:
	assertions += 1
	if not condition:
		failures += 1
		print("FAIL: ", label)
