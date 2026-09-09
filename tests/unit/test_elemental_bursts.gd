extends FluxTestSuite


const ABILITY_PATH := "res://content/abilities/foundation_abilities_v1.json"
const CHAMPION_PATH := "res://content/champions/foundation_champions_v1.json"


func run() -> int:
	_test_shared_first_eight_contract()
	_test_global_weaving_for_every_foundation_champion()
	_test_geometry_and_snapshot_at_120_hz()
	_test_readable_projectile_travel_at_120_hz()
	return finish("elemental-bursts")


func _catalog() -> AbilityCatalog:
	var catalog := AbilityCatalog.new()
	check(catalog.load_from_file(ABILITY_PATH), "ability catalog loads for elemental Bursts: %s" % catalog.last_error)
	return catalog


func _test_shared_first_eight_contract() -> void:
	var catalog := _catalog()
	var expected_ids := ["cinder-fan", "rill-burst", "stone-burst", "gale-burst", "arc-burst", "rime-burst", "prism-burst", "eclipse-burst"]
	equal(CombatTuning.ELEMENTAL_BURST_WIRE_IDS.size(), 8, "first-eight Burst library has exactly eight stable wires")
	for index: int in range(AbilityCatalog.FIRST_EIGHT_ELEMENTS.size()):
		var element_id := AbilityCatalog.FIRST_EIGHT_ELEMENTS[index]
		var wire_id := CombatTuning.ELEMENTAL_BURST_WIRE_IDS[index]
		var ability: Dictionary = catalog.ability(expected_ids[index])
		var definition := CombatTuning.cast_definition(wire_id)
		equal(int(ability.get("wire_id", 0)), wire_id, "%s Burst content and compiled wire agree" % element_id)
		equal(String(ability.get("element", "")), element_id, "%s Burst owns the expected payload identity" % element_id)
		equal(int(definition.get("element_wire_id", 0)), int((catalog.elements_by_id[element_id] as Dictionary).get("wire_id", 0)), "%s Burst owns the expected element wire" % element_id)
		equal(String(definition.get("delivery_kernel", "")), "burst", "%s Burst resolves through the shared kernel" % element_id)
		equal(definition.get("projectile_angles_degrees", []), CombatTuning.cast_definition(CombatTuning.CINDERFAN_WIRE_ID)["projectile_angles_degrees"], "%s Burst keeps the common five-lane angles" % element_id)
		equal(int(definition.get("damage", 0)), int(CombatTuning.cast_definition(CombatTuning.CINDERFAN_WIRE_ID)["damage"]), "%s gains no hidden elemental damage advantage" % element_id)
		for shared_key: String in ["speed", "radius", "lifetime_ms", "startup_ms", "cooldown_ms", "recovery_ms"]:
			equal(int(definition.get(shared_key, 0)), int(CombatTuning.cast_definition(CombatTuning.CINDERFAN_WIRE_ID).get(shared_key, 0)), "%s Burst keeps the common %s" % [element_id, shared_key])
		equal(int(definition.get("flux_cost", 0)), int(CombatTuning.cast_definition(CombatTuning.CINDERFAN_WIRE_ID)["flux_cost"]), "%s pays the same positive Flux cost" % element_id)
		check(CombatTuning.is_runtime_wire_id(wire_id), "%s Burst is in the global runtime library" % element_id)


func _test_readable_projectile_travel_at_120_hz() -> void:
	var previous_tuning := {
		"arc-primary": [768_000, 1500, 7000], "vector-lance": [680_000, 1875, 9000],
		"rillshot": [720_000, 1440, 8000], "cinderbolt": [672_000, 1565, 9000],
		"eclipse-disc": [624_000, 2000, 11000],
	}
	var previous_families := {"burst": [560_000, 1375, 8000], "heavy": [400_000, 1800, 16000], "rapid": [760_000, 850, 5000]}
	var catalog := _catalog()
	var projectile_count := 0
	for wire_id: int in catalog.runtime_wire_ids:
		var definition := CombatTuning.projectile_definition(wire_id)
		if definition.is_empty():
			continue
		projectile_count += 1
		var ability := catalog.ability_from_wire(wire_id)
		var ability_id := String(ability.get("id", ""))
		var family := String(ability.get("family", definition.get("delivery_kernel", "")))
		var before: Array = previous_tuning.get(ability_id, previous_families.get(family, [576_000, 2000, 9000]))
		var speed := int(definition.get("speed", 0))
		var lifetime_ms := int(definition.get("lifetime_ms", 0))
		equal(speed * 5, int(before[0]) * 4, ability_id + " slows travel by exactly 20 percent")
		equal(int(definition.get("radius", 0)) * 5, int(before[2]) * 6, ability_id + " enlarges the actual collision radius by exactly 20 percent")
		check(int(ability.get("flux_cost", 0)) > 0, ability_id + " retains a paid attack")
		var baseline := _sample_projectile_travel(definition, int(before[0]), int(before[1]))
		var candidate := _sample_projectile_travel(definition, speed, lifetime_ms)
		check(bool(candidate["expired"]), ability_id + " expires on the actual authoritative flight path")
		check(int(candidate["reaction_ticks"]) > int(baseline["reaction_ticks"]), ability_id + " gives more simulation ticks to react across 300 world units")
		check(absi(int(candidate["travel"]) - int(baseline["travel"])) <= 5000, ability_id + " preserves terminal reach within five world units after tick rounding")
		print("PROJECTILE_TUNING %s: speed=%d->%d; flight_ticks=%d->%d; travel=%.3f->%.3f; 300u_ticks=%d->%d" % [ability_id, int(before[0]), speed, int(baseline["flight_ticks"]), int(candidate["flight_ticks"]), int(baseline["travel"]) / 1000.0, int(candidate["travel"]) / 1000.0, int(baseline["reaction_ticks"]), int(candidate["reaction_ticks"])])
	equal(projectile_count, 33, "all eight Bolts, eight Bursts, eight Heavies, eight Rapids and Vector Lance receive the same readability pass")


func _sample_projectile_travel(definition: Dictionary, speed: int, lifetime_ms: int) -> Dictionary:
	var config := SimConfig.new(120)
	var collision := CollisionWorld.new(3_000_000, 1_200_000)
	var projectile := ProjectileState.new(9900, 1, 1, int(definition.get("wire_id", 0)), int(definition.get("element_wire_id", 0)), Vector2i(500_000, 600_000), Vector2i(speed, 0), int(definition.get("radius", 0)), int(definition.get("damage", 0)), config.milliseconds_to_ticks(lifetime_ms))
	var active: Array[ProjectileState] = [projectile]
	var players: Array[PlayerState] = []
	var events: Array[Dictionary] = []
	var flight_ticks := 0
	var reaction_ticks := 0
	while not active.is_empty() and flight_ticks < 360:
		active = CombatSystem.advance_projectiles(active, players, config, collision, events)
		flight_ticks += 1
		if reaction_ticks == 0 and projectile.position_x - 500_000 >= 300_000:
			reaction_ticks = flight_ticks
	return {"flight_ticks": flight_ticks, "reaction_ticks": reaction_ticks, "travel": projectile.position_x - 500_000, "expired": events.any(func(event: Dictionary) -> bool: return event.get("type") == "projectile_expired")}


func _test_global_weaving_for_every_foundation_champion() -> void:
	var abilities := _catalog()
	var champions := ChampionCatalog.new()
	check(champions.load_from_file(CHAMPION_PATH, abilities), "champion catalog loads for global Burst weaving: %s" % champions.last_error)
	for champion_id: String in ["oh_tipi", "s_wayne", "red_baron"]:
		var state := PlayerState.new()
		check(champions.apply_to_player(state, champion_id), "%s applies before global Burst weaving" % champion_id)
		for wire_id: int in CombatTuning.ELEMENTAL_BURST_WIRE_IDS:
			check(state.place_proven_spell(11, wire_id), "%s can weave Burst wire %d regardless of affinity or body size" % [champion_id, wire_id])
			equal(state.spell_wire_id(12), wire_id, "%s equips Burst wire %d in Alt+4" % [champion_id, wire_id])


func _test_geometry_and_snapshot_at_120_hz() -> void:
	var abilities := _catalog()
	var champions := ChampionCatalog.new()
	check(champions.load_from_file(CHAMPION_PATH, abilities), "champion catalog loads for Burst geometry fixtures: %s" % champions.last_error)
	var baseline_signature: Array = []
	for wire_id: int in CombatTuning.ELEMENTAL_BURST_WIRE_IDS:
		var world := SimWorld.new(120, wire_id, CollisionWorld.new(2_000_000, 1_200_000))
		var caster: PlayerState = world.player()
		check(champions.apply_to_player(caster, "oh_tipi"), "Oh Tipi applies before Burst wire %d geometry test" % wire_id)
		check(caster.place_proven_spell(0, wire_id), "Burst wire %d enters the first weave position" % wire_id)
		var flux_before := caster.flux
		check(world.step([SimCommand.new(0, caster.entity_id, 0, 0, 0, SimCommand.PRESSED_SPELL_1, 1000, 0)]), "Burst wire %d begins at 120 Hz" % wire_id)
		equal(caster.pending_cast_wire_id, wire_id, "Burst wire %d owns its startup channel" % wire_id)
		equal(caster.flux, flux_before - int(CombatTuning.cast_definition(CombatTuning.CINDERFAN_WIRE_ID)["flux_cost"]), "Burst wire %d spends exactly one shared Flux cost" % wire_id)
		var spawn_events: Array[Dictionary] = []
		for _tick: int in range(60):
			check(world.step([SimCommand.new(world.tick, caster.entity_id, 0, 0, 0, 0, 1000, 0)]), "Burst wire %d advances to release" % wire_id)
			for event: Dictionary in world.combat_events:
				if event.get("type") == "projectile_spawned" and int(event.get("wire_id", 0)) == wire_id:
					spawn_events.append(event)
			if spawn_events.size() == 5:
				break
		equal(spawn_events.size(), 5, "Burst wire %d releases exactly five lanes" % wire_id)
		equal(world.projectiles.size(), 5, "Burst wire %d enters bounded projectile storage" % wire_id)
		var signature: Array = []
		var observed_angles: Array[int] = []
		for lane_index: int in range(world.projectiles.size()):
			var projectile: ProjectileState = world.projectiles[lane_index]
			signature.append([projectile.position_x, projectile.position_y, projectile.velocity_x, projectile.velocity_y, projectile.radius, projectile.damage, projectile.lifetime_ticks])
			observed_angles.append(int(spawn_events[lane_index].get("lane_angle_degrees", 999)))
		equal(observed_angles, CombatTuning.cast_definition(CombatTuning.CINDERFAN_WIRE_ID)["projectile_angles_degrees"], "Burst wire %d preserves stable left-to-right lane order" % wire_id)
		if baseline_signature.is_empty():
			baseline_signature = signature
		else:
			equal(signature, baseline_signature, "Burst wire %d changes payload identity without changing geometry" % wire_id)
		var snapshot := SessionSnapshot.capture(world, {caster.entity_id: "Burst Fixture"}, world.combat_events)
		check(SessionSnapshot.validate(snapshot), "Burst wire %d fits the authoritative snapshot contract" % wire_id)
		equal(int((snapshot["overflow"] as PackedInt32Array)[0]), 0, "Burst wire %d stays inside the projectile packet budget" % wire_id)
