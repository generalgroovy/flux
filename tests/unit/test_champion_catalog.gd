extends FluxTestSuite


const ABILITY_PATH: String = "res://content/abilities/foundation_abilities_v1.json"
const CHAMPION_PATH: String = "res://content/champions/foundation_champions_v1.json"


func run() -> int:
	_test_repository_catalog()
	_test_profiles_are_authoritative()
	for tick_rate: int in [60, 120]:
		_test_profiles_execute_at_rate(tick_rate)
	_test_invalid_profiles_fail_closed()
	return finish("champion-catalog")


func _catalog() -> ChampionCatalog:
	var abilities := AbilityCatalog.new()
	check(abilities.load_from_file(ABILITY_PATH), "ability catalog loads for champions")
	var catalog := ChampionCatalog.new()
	check(catalog.load_from_file(CHAMPION_PATH, abilities), "champion catalog validates: %s" % catalog.last_error)
	return catalog


func _test_repository_catalog() -> void:
	var catalog := _catalog()
	equal(catalog.default_champion_id, "oh_tipi", "Oh Tipi is the safe first-run champion")
	equal(catalog.ordered_champion_ids(), ["oh_tipi", "s_wayne"], "wire order produces stable champion cycling")
	equal(catalog.next_champion_id("oh_tipi"), "s_wayne", "champion cycle advances")
	equal(catalog.next_champion_id("s_wayne"), "oh_tipi", "champion cycle wraps")
	equal(String(catalog.champion("oh_tipi").get("ancestry")), "seakin", "Oh Tipi is a Seakin")
	equal(String(catalog.champion("s_wayne").get("ancestry")), "hobbit", "S. Wayne is a Hobbit")
	equal((catalog.champion("s_wayne").get("affinities", []) as Array).size(), 2, "S. Wayne keeps two affinities")


func _test_profiles_are_authoritative() -> void:
	var catalog := _catalog()
	var state := PlayerState.new()
	check(catalog.apply_to_player(state, "oh_tipi"), "Oh Tipi profile applies")
	equal(state.champion_wire_id, 1, "Oh Tipi owns stable wire id 1")
	equal(state.primary_wire_id, CombatTuning.RILLSHOT_WIRE_ID, "Oh Tipi equips Rillshot")
	equal(state.active_1_wire_id, CombatTuning.TIDELINE_WIRE_ID, "Oh Tipi equips Tideline")
	equal(Array(state.spell_wire_ids), [CombatTuning.RILLSHOT_WIRE_ID, CombatTuning.TIDELINE_WIRE_ID, 0, 0, 0], "Oh Tipi resets to a valid five-slot kit")
	equal(state.health, 108_000, "Oh Tipi starts at authored maximum Health")
	equal(state.stamina_maximum, 108_000, "Oh Tipi has the larger Stamina reserve")
	state.health = 54_000
	state.flux = 52_000
	state.stamina = 54_000
	check(catalog.apply_to_player(state, "s_wayne", true), "S. Wayne profile applies with ratios preserved")
	equal(state.champion_wire_id, 2, "S. Wayne owns stable wire id 2")
	equal(state.primary_wire_id, CombatTuning.ECLIPSE_DISC_WIRE_ID, "S. Wayne equips Eclipse Disc")
	equal(state.active_1_wire_id, CombatTuning.POCKET_ECLIPSE_WIRE_ID, "S. Wayne equips Pocket Eclipse")
	equal(Array(state.spell_wire_ids), [CombatTuning.ECLIPSE_DISC_WIRE_ID, CombatTuning.POCKET_ECLIPSE_WIRE_ID, 0, 0, 0], "champion switch resets incompatible slot weaving")
	equal(state.health, 45_000, "Health ratio survives an in-world champion switch")
	equal(state.flux, 56_000, "Flux ratio survives an in-world champion switch")
	equal(state.stamina, 48_000, "Stamina ratio survives an in-world champion switch")
	equal(state.movement_speed_ratio, 1060, "S. Wayne owns the faster ground profile")


func _test_profiles_execute_at_rate(tick_rate: int) -> void:
	var catalog := _catalog()
	var roomy_collision := CollisionWorld.new(2_000_000, 2_000_000)
	var oh_world := SimWorld.new(tick_rate, 1, roomy_collision)
	var wayne_world := SimWorld.new(tick_rate, 1, roomy_collision)
	var oh_tipi: PlayerState = oh_world.player()
	var s_wayne: PlayerState = wayne_world.player()
	check(catalog.apply_to_player(oh_tipi, "oh_tipi"), "%d Hz Oh Tipi profile applies" % tick_rate)
	check(catalog.apply_to_player(s_wayne, "s_wayne"), "%d Hz S. Wayne profile applies" % tick_rate)
	for state: PlayerState in [oh_tipi, s_wayne]:
		state.position_x = 1_000_000
		state.position_y = 1_000_000
	for _index: int in range(tick_rate):
		check(oh_world.step([SimCommand.new(oh_world.tick, 1, 1000)]), "%d Hz Oh Tipi movement steps" % tick_rate)
		check(wayne_world.step([SimCommand.new(wayne_world.tick, 1, 1000)]), "%d Hz S. Wayne movement steps" % tick_rate)
	check(s_wayne.velocity_x > oh_tipi.velocity_x, "%d Hz S. Wayne reaches the higher authored ground speed" % tick_rate)
	check(s_wayne.position_x > oh_tipi.position_x, "%d Hz S. Wayne gains measurable ground over Oh Tipi" % tick_rate)
	oh_tipi.flux = 0
	s_wayne.flux = 0
	for _index: int in range(tick_rate):
		PlayerResourcesSystem.step(oh_tipi, oh_world.config)
		PlayerResourcesSystem.step(s_wayne, wayne_world.config)
	equal(oh_tipi.flux, oh_tipi.flux_recovery_per_second, "%d Hz Oh Tipi recovers the exact authored Flux rate" % tick_rate)
	equal(s_wayne.flux, s_wayne.flux_recovery_per_second, "%d Hz S. Wayne recovers the exact authored Flux rate" % tick_rate)
	check(oh_world.state_hash() != wayne_world.state_hash(), "%d Hz champion identity changes canonical world state" % tick_rate)


func _test_invalid_profiles_fail_closed() -> void:
	var abilities := AbilityCatalog.new()
	check(abilities.load_from_file(ABILITY_PATH), "ability catalog loads for invalid champion tests")
	var source := ChampionCatalog.new()
	check(source.load_from_file(CHAMPION_PATH, abilities), "champion source loads")
	for mutation: Callable in [
		func(data: Dictionary) -> void: data["schema_version"] = 99,
		func(data: Dictionary) -> void: (data["champions"][0] as Dictionary)["wire_id"] = 2,
		func(data: Dictionary) -> void: (data["champions"][0] as Dictionary)["affinities"] = ["water"],
		func(data: Dictionary) -> void: ((data["champions"][0] as Dictionary)["stats"] as Dictionary)["movement_speed_ratio"] = 5000,
		func(data: Dictionary) -> void: ((data["champions"][0] as Dictionary)["foundation_kit"] as Dictionary)["primary"] = "missing",
	]:
		var candidate := ChampionCatalog.new()
		candidate.data = source.data.duplicate(true)
		mutation.call(candidate.data)
		check(not candidate.validate(abilities), "invalid champion mutation fails closed")
		check(not candidate.last_error.is_empty(), "invalid champion failure is actionable")
