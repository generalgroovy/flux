extends "res://tests/scenarios/runtime_stress_probe.gd"

# One bounded same-input investigation, not an optimization or FPS benchmark.
# Original world.step is timed separately; the observed world checks every state
# and event against it. Nested timings contain observation overhead.
const DrillSampler = preload("res://tests/scenarios/runtime_drill_sampler.gd")
const DrillChemistry = preload("res://tests/scenarios/runtime_drill_chemistry.gd")
const COPIED_COMBAT_SHA256 := "788cc518ef1b59ae042b58792b777cc45d26296425a4ecd5a5fcc1a907f6b874"
const BATCH_TRIAL_COMBAT_SHA256 := "cdce33b7ee0528c57870cd1a3f5ce8faa52bee9517ec56962bdf8551b6aebd1a"
const COPIED_CHEMISTRY_SHA256 := "b0596612896e2c475994894a99aff40ed2e047866d1ec536eec767bd66d8b28f"

func _run() -> void:
	# Copied observation bodies must be deliberately refreshed after source
	# changes; a passing old workload must never silently bless a stale mirror.
	if FileAccess.get_sha256("res://src/sim/combat/combat_system.gd") not in [COPIED_COMBAT_SHA256,BATCH_TRIAL_COMBAT_SHA256] or FileAccess.get_sha256("res://src/sim/chemistry/element_chemistry_system.gd") != COPIED_CHEMISTRY_SHA256:
		push_error("Projectile drill copied bodies are stale; review and refresh before measuring")
		quit(1)
		return
	_check(abilities.load_from_file("res://content/abilities/foundation_abilities_v1.json"),"abilities load")
	_check(champions.load_from_file("res://content/champions/foundation_champions_v1.json",abilities),"champions load")
	var source_paths := ["src/sim/combat/combat_system.gd","src/sim/chemistry/element_chemistry_system.gd","src/sim/core/sim_world.gd","src/sim/world/collision_world.gd","tests/scenarios/runtime_stress_probe.gd","tests/scenarios/runtime_projectile_drill.gd","tests/scenarios/runtime_drill_chemistry.gd","tests/scenarios/runtime_drill_combat.gd","tests/scenarios/runtime_drill_sampler.gd","content/abilities/foundation_abilities_v1.json","content/champions/foundation_champions_v1.json"]
	var hashes := {}
	for path: String in source_paths:
		hashes[path] = FileAccess.get_sha256("res://"+path)
	var field_opening := OS.get_cmdline_user_args().has("--fields")
	print("PROJECTILE_DRILL_META ",JSON.stringify({"engine":Engine.get_version_info()["string"],"cpu":OS.get_processor_name(),"seed":SEED,"source_sha256":hashes,"scenario":"legal-eight-field-opening" if field_opening else "legal-eight-mixed-deliveries","geometry":"fixed 12000000x6000000,zero obstacles,no live map JSON","timing_scope":"production step versus frozen pre-batch-list observer; nested observer timers include overhead"}))
	var world := _make_world(8,0,not field_opening,field_opening)
	var mirror := _make_world(8,0,not field_opening,field_opening)
	var trace := HashingContext.new()
	trace.start(HashingContext.HASH_SHA256)
	var samples := PackedInt64Array()
	var totals := {}
	var event_counts := {}
	var over_budget := 0
	for index: int in range(WARMUP_TICKS+LEGAL_TICKS):
		var commands := _commands(world,index >= WARMUP_TICKS,false,index >= WARMUP_TICKS and not field_opening,field_opening)
		world.collision.obstacle_view()
		mirror.collision.obstacle_view()
		var began := Time.get_ticks_usec()
		_check(world.step(commands),"production step")
		var production_us := Time.get_ticks_usec()-began
		DrillChemistry.reset()
		commands.reverse()
		var observed := DrillSampler.measured_step(mirror,commands)
		_check(bool(observed.ok),"observed step")
		_check(world.state_hash() == mirror.state_hash(),"observed canonical state equals real step")
		_check(world.combat_events == mirror.combat_events,"observed ordered events equal real step")
		_record_tick(world,trace,event_counts)
		if index < WARMUP_TICKS:
			continue
		samples.append(production_us)
		if production_us > TICK_BUDGET_US: over_budget += 1
		for key: String in DrillChemistry.counts:
			totals[key] = int(totals.get(key,0))+int(DrillChemistry.counts[key])
		var row := {"tick":world.tick,"production_us":production_us,"stages_us":observed.times,"chemistry_nested_us":DrillChemistry.times.duplicate(),"counts":DrillChemistry.counts.duplicate(),"eligible_queries_by_wire":DrillChemistry.wires.duplicate(),"projectiles_after":world.projectiles.size(),"reactions_after":world.reactions.size(),"deposits_after":world.deposits.size()}
		print("PROJECTILE_DRILL_TICK ",JSON.stringify(row))
	var cleanup_ticks := 0
	while cleanup_ticks < CLEANUP_LIMIT and (not world.projectiles.is_empty() or not world.fields.is_empty() or _has_pending_cast(world) or not world.deposits.is_empty() or not world.reactions.is_empty()):
		var commands := _commands(world,false,false,false,field_opening)
		_check(world.step(commands),"production natural cleanup")
		DrillChemistry.reset()
		_check(bool(DrillSampler.measured_step(mirror,commands).ok),"observed natural cleanup")
		_check(world.state_hash() == mirror.state_hash() and world.combat_events == mirror.combat_events,"cleanup canonical state/events equal")
		_record_tick(world,trace,event_counts)
		cleanup_ticks += 1
	_check(world.projectiles.is_empty() and world.fields.is_empty() and world.deposits.is_empty() and world.reactions.is_empty() and not _has_pending_cast(world),"all material naturally expires")
	_check(world.step([]),"production final idle")
	DrillChemistry.reset()
	_check(bool(DrillSampler.measured_step(mirror,[]).ok),"observed final idle")
	_check(world.state_hash() == mirror.state_hash() and world.combat_events == mirror.combat_events,"final canonical state/events equal")
	_record_tick(world,trace,event_counts)
	print("PROJECTILE_DRILL_RESULT ",JSON.stringify({"sample_ticks":samples.size(),"production_step_us":_percentiles(samples),"ticks_over_8333_us":over_budget,"measured_query_totals":totals,"cleanup_ticks":cleanup_ticks,"all_tick_state_event_trace_sha256":trace.finish().hex_encode(),"event_counts":event_counts,"final_hash":world.state_hash()}))
	print("%s: runtime-projectile-drill; %d assertions; %d failures" % ["PASS" if failures == 0 else "FAIL",assertions,failures])
	quit(0 if failures == 0 else 1)

func _record_tick(world: SimWorld,trace: HashingContext,counts: Dictionary) -> void:
	trace.update(world.state_hash().to_utf8_buffer())
	trace.update(var_to_bytes(world.combat_events))
	for event: Dictionary in world.combat_events:
		var kind := String(event.get("type",""))
		counts[kind] = int(counts.get(kind,0))+1
