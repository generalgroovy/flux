extends FluxTestSuite


const ABILITY_PATH := "res://content/abilities/foundation_abilities_v1.json"
const CHAMPION_PATH := "res://content/champions/foundation_champions_v1.json"


func run() -> int:
	_test_shared_first_eight_contract()
	_test_global_weaving_for_every_foundation_champion()
	_test_geometry_and_snapshot_at_120_hz()
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
		equal(int(definition.get("flux_cost", 0)), int(CombatTuning.cast_definition(CombatTuning.CINDERFAN_WIRE_ID)["flux_cost"]), "%s pays the same positive Flux cost" % element_id)
		check(CombatTuning.is_runtime_wire_id(wire_id), "%s Burst is in the global runtime library" % element_id)


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
