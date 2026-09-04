extends FluxTestSuite


const ABILITY_PATH: String = "res://content/abilities/foundation_abilities_v1.json"
const CHAMPION_PATH: String = "res://content/champions/foundation_champions_v1.json"


func run() -> int:
	_test_repository_catalog()
	_test_all_promoted_kits_execute()
	_test_affinity_point_budget_and_treevor_exception()
	_test_unique_affinity_pairs()
	_test_profiles_are_authoritative()
	for tick_rate: int in [120]:
		_test_profiles_execute_at_rate(tick_rate)
	_test_invalid_profiles_fail_closed()
	return finish("champion-catalog")


func _catalog() -> ChampionCatalog:
	var abilities := AbilityCatalog.new()
	check(abilities.load_from_file(ABILITY_PATH), "ability catalog loads for champions")
	var catalog := ChampionCatalog.new()
	check(catalog.load_from_file(CHAMPION_PATH, abilities), "champion catalog validates: %s" % catalog.last_error)
	return catalog


func _test_all_promoted_kits_execute() -> void:
	var catalog := _catalog()
	for champion_id: String in catalog.ordered_champion_ids():
		for slot: int in range(3):
			var world := SimWorld.new(120)
			check(catalog.apply_to_player(world.player(), champion_id), champion_id + " applies before casting")
			var state := world.player()
			var wire := state.spell_wire_id(slot + 1)
			check(CombatTuning.runtime_wire_ids().has(wire), champion_id + " starts with executable spells")
			var before_flux := state.flux
			var bits: int = [SimCommand.PRESSED_SPELL_1, SimCommand.PRESSED_SPELL_2, SimCommand.PRESSED_SPELL_3][slot]
			check(world.step([SimCommand.new(0, 1, 0, 0, 0, bits, 1000, 0)]), champion_id + " accepts configured spell input")
			check(state.flux < before_flux, champion_id + " pays positive Flux for every attack")
			for _tick: int in range(24):
				check(world.step([SimCommand.new(world.tick, 1, 0, 0, 0, 0, 1000, 0)]), "kit completes simulation without error")
			check(state.has_valid_spell_slots(), "kit casting preserves valid global slots")


func _test_repository_catalog() -> void:
	var catalog := _catalog()
	equal(catalog.default_champion_id, "oh_tipi", "Oh Tipi is the safe first-run champion")
	equal(catalog.ordered_champion_ids(), ["oh_tipi", "s_wayne", "red_baron", "grace_reava", "wa_bidi"], "wire order produces stable champion cycling")
	equal(catalog.next_champion_id("oh_tipi"), "s_wayne", "champion cycle advances")
	equal(catalog.next_champion_id("s_wayne"), "red_baron", "champion cycle reaches the large foundation champion")
	equal(catalog.next_champion_id("wa_bidi"), "oh_tipi", "champion cycle wraps")
	equal(String(catalog.champion("oh_tipi").get("ancestry")), "seakin", "Oh Tipi is a Seakin")
	equal(String(catalog.champion("s_wayne").get("ancestry")), "hobbit", "S. Wayne is a Hobbit")
	equal(String(catalog.champion("red_baron").get("ancestry")), "undead", "The Red Baron is Undead")
	equal(String(catalog.champion("oh_tipi").get("body_type")), "middle", "Oh Tipi uses the middle reusable body type")
	equal(String(catalog.champion("s_wayne").get("body_type")), "small", "S. Wayne uses the small reusable body type")
	equal(String(catalog.champion("red_baron").get("body_type")), "large", "The Red Baron uses the large reusable body type")
	equal(ChampionCatalog.SUPPORTED_BODY_TYPES, ["small", "middle", "large"], "runtime exposes exactly three body types")
	equal(catalog.champion("oh_tipi").get("affinities", []), ["water", "charge"], "Oh Tipi owns Water/Charge")
	equal(catalog.affinity_strength("oh_tipi", "water"), 2, "Oh Tipi has primary Water strength 2")
	equal(catalog.affinity_strength("oh_tipi", "charge"), 1, "Oh Tipi has secondary Charge strength 1")
	equal(catalog.affinity_strength("oh_tipi", "ice"), 0, "Oh Tipi has no innate Ice affinity")
	equal(catalog.champion("s_wayne").get("affinities", []), ["dark", "light"], "S. Wayne keeps Dark/Light")
	equal(catalog.affinity_strength("s_wayne", "dark"), 2, "S. Wayne has primary Dark strength 2")
	equal(catalog.affinity_strength("s_wayne", "light"), 1, "S. Wayne has secondary Light strength 1")
	equal(catalog.champion("red_baron").get("affinities", []), ["fire", "ice"], "The Red Baron owns Fire/Ice")
	equal(catalog.affinity_strength("red_baron", "fire"), 2, "The Red Baron has primary Fire strength 2")
	equal(catalog.affinity_strength("red_baron", "ice"), 1, "The Red Baron has secondary Ice strength 1")


func _test_affinity_point_budget_and_treevor_exception() -> void:
	var abilities := AbilityCatalog.new()
	check(abilities.load_from_file(ABILITY_PATH), "ability catalog loads for affinity budget")
	var source := ChampionCatalog.new()
	check(source.load_from_file(CHAMPION_PATH, abilities), "champion source loads for affinity budget")

	var ordinary := ChampionCatalog.new()
	ordinary.data = source.data.duplicate(true)
	(ordinary.data["champions"][0] as Dictionary)["affinities"] = ["water", "charge", "ice"]
	(ordinary.data["champions"][0] as Dictionary)["affinity_points"] = {"water": 1, "charge": 1, "ice": 1}
	check(ordinary.validate(abilities), "any champion may split the same three-point budget across three affinities")

	var bad_total := ChampionCatalog.new()
	bad_total.data = source.data.duplicate(true)
	(bad_total.data["champions"][0] as Dictionary)["affinity_points"] = {"water": 1, "charge": 1}
	check(not bad_total.validate(abilities), "ordinary champion must spend exactly three affinity points")
	check(bad_total.last_error.contains("must total"), "bad affinity-point total is diagnosable")

	var treevor_candidate := ChampionCatalog.new()
	treevor_candidate.data = source.data.duplicate(true)
	var treevor: Dictionary = (treevor_candidate.data["champions"][0] as Dictionary).duplicate(true)
	treevor["id"] = ChampionCatalog.TREEVOR_CHAMPION_ID
	treevor["wire_id"] = 99
	treevor["display_name"] = "Treevor the Mason"
	treevor["ancestry"] = "treefolk"
	treevor["body_type"] = "large"
	treevor["affinities"] = ["earth", "wind", "fire"]
	treevor["affinity_points"] = {"earth": 1, "wind": 1, "fire": 1}
	treevor["stats"] = (treevor_candidate.data["champions"][2] as Dictionary)["stats"].duplicate(true)
	(treevor_candidate.data["champions"] as Array).append(treevor)
	check(treevor_candidate.validate(abilities), "Treevor may split the same three-point budget 1+1+1: %s" % treevor_candidate.last_error)


func _test_unique_affinity_pairs() -> void:
	var abilities := AbilityCatalog.new()
	check(abilities.load_from_file(ABILITY_PATH), "ability catalog loads for pair uniqueness")
	var source := ChampionCatalog.new()
	check(source.load_from_file(CHAMPION_PATH, abilities), "champion source loads for pair uniqueness")

	var candidate := ChampionCatalog.new()
	candidate.data = source.data.duplicate(true)
	var duplicate_pair: Dictionary = (candidate.data["champions"][0] as Dictionary).duplicate(true)
	duplicate_pair["id"] = "duplicate_pair_fixture"
	duplicate_pair["wire_id"] = 98
	duplicate_pair["display_name"] = "Duplicate Pair Fixture"
	duplicate_pair["affinities"] = ["charge", "water"]
	duplicate_pair["affinity_points"] = {"charge": 2, "water": 1}
	(candidate.data["champions"] as Array).append(duplicate_pair)
	check(not candidate.validate(abilities), "reverse-order duplicate affinity pair fails closed even with opposite weighting")
	check(candidate.last_error.contains("combinations must be unique"), "duplicate pair failure explains the invariant")


func _test_profiles_are_authoritative() -> void:
	var catalog := _catalog()
	var state := PlayerState.new()
	check(catalog.apply_to_player(state, "oh_tipi"), "Oh Tipi profile applies")
	equal(state.champion_wire_id, 1, "Oh Tipi owns stable wire id 1")
	equal(state.primary_wire_id, CombatTuning.RILLSHOT_WIRE_ID, "Oh Tipi equips Rillshot")
	equal(state.active_1_wire_id, CombatTuning.TIDELINE_WIRE_ID, "Oh Tipi equips Tideline")
	equal(state.active_2_wire_id, CombatTuning.RIMEWAKE_WIRE_ID, "Oh Tipi equips Rimewake as the third proven spell")
	equal(Array(state.spell_wire_ids), [140, 141, 144, 145, 146, 154, 155, 156, 148, 157, 158, 159], "Oh Tipi leads a representative row-major twelve-spell weave with champion spells")
	equal(state.health, 108_000, "Oh Tipi starts at authored maximum Health")
	equal(state.stamina_maximum, 120_000, "Oh Tipi has the larger Stamina reserve")
	state.health = 54_000
	state.flux = 52_000
	state.stamina = 54_000
	check(catalog.apply_to_player(state, "s_wayne", true), "S. Wayne profile applies with ratios preserved")
	equal(state.champion_wire_id, 2, "S. Wayne owns stable wire id 2")
	equal(state.primary_wire_id, CombatTuning.ECLIPSE_DISC_WIRE_ID, "S. Wayne equips Eclipse Disc")
	equal(state.active_1_wire_id, CombatTuning.POCKET_ECLIPSE_WIRE_ID, "S. Wayne equips Pocket Eclipse")
	equal(state.active_2_wire_id, 0, "S. Wayne does not expose an unfinished third spell")
	equal(Array(state.spell_wire_ids), [142, 143, 145, 146, 154, 155, 156, 140, 148, 141, 157, 158], "champion switch keeps a representative row-major weave and leads with the new champion kit")
	equal(state.health, 45_000, "Health ratio survives an in-world champion switch")
	equal(state.flux, 56_000, "Flux ratio survives an in-world champion switch")
	equal(state.stamina, 48_600, "Stamina ratio survives an in-world champion switch")
	equal(state.movement_speed_ratio, 1060, "S. Wayne owns the faster ground profile")
	check(catalog.apply_to_player(state, "red_baron"), "The Red Baron profile applies")
	equal(state.champion_wire_id, 3, "The Red Baron owns stable wire id 3")
	equal(state.primary_wire_id, CombatTuning.CINDERBOLT_WIRE_ID, "The Red Baron equips Cinderbolt")
	equal(state.active_1_wire_id, CombatTuning.RIMEWAKE_WIRE_ID, "The Red Baron equips Rimewake")
	equal(state.active_2_wire_id, CombatTuning.CINDERFAN_WIRE_ID, "The Red Baron equips Cinder Fan as readable lane pressure")
	equal(Array(state.spell_wire_ids), [145, 144, 146, 154, 155, 156, 140, 148, 141, 157, 158, 159], "The Red Baron leads the row-major weave with Fire/Ice spells")
	equal(state.health_maximum, 132_000, "large body owns the deepest Health reserve")
	equal(state.stamina_maximum, 144_000, "large body owns the deepest Stamina reserve")
	equal(state.movement_speed_ratio, 910, "large body pays for staying power with deliberate ground speed")


func _test_profiles_execute_at_rate(tick_rate: int) -> void:
	var catalog := _catalog()
	var roomy_collision := CollisionWorld.new(2_000_000, 2_000_000)
	var oh_world := SimWorld.new(tick_rate, 1, roomy_collision)
	var wayne_world := SimWorld.new(tick_rate, 1, roomy_collision)
	var baron_world := SimWorld.new(tick_rate, 1, roomy_collision)
	var oh_tipi: PlayerState = oh_world.player()
	var s_wayne: PlayerState = wayne_world.player()
	var red_baron: PlayerState = baron_world.player()
	check(catalog.apply_to_player(oh_tipi, "oh_tipi"), "%d Hz Oh Tipi profile applies" % tick_rate)
	check(catalog.apply_to_player(s_wayne, "s_wayne"), "%d Hz S. Wayne profile applies" % tick_rate)
	check(catalog.apply_to_player(red_baron, "red_baron"), "%d Hz Red Baron profile applies" % tick_rate)
	for state: PlayerState in [oh_tipi, s_wayne, red_baron]:
		state.position_x = 1_000_000
		state.position_y = 1_000_000
	for _index: int in range(tick_rate):
		check(oh_world.step([SimCommand.new(oh_world.tick, 1, 1000)]), "%d Hz Oh Tipi movement steps" % tick_rate)
		check(wayne_world.step([SimCommand.new(wayne_world.tick, 1, 1000)]), "%d Hz S. Wayne movement steps" % tick_rate)
		check(baron_world.step([SimCommand.new(baron_world.tick, 1, 1000)]), "%d Hz Red Baron movement steps" % tick_rate)
	check(s_wayne.velocity_x > oh_tipi.velocity_x, "%d Hz S. Wayne reaches the higher authored ground speed" % tick_rate)
	check(s_wayne.position_x > oh_tipi.position_x, "%d Hz S. Wayne gains measurable ground over Oh Tipi" % tick_rate)
	check(oh_tipi.velocity_x > red_baron.velocity_x, "%d Hz the large anchor preserves its deliberate speed tradeoff" % tick_rate)
	check(red_baron.health_maximum > oh_tipi.health_maximum and red_baron.stamina_maximum > oh_tipi.stamina_maximum, "%d Hz the large anchor receives real reserve compensation" % tick_rate)
	oh_tipi.flux = 0
	s_wayne.flux = 0
	red_baron.flux = 0
	for _index: int in range(tick_rate):
		PlayerResourcesSystem.step(oh_tipi, oh_world.config)
		PlayerResourcesSystem.step(s_wayne, wayne_world.config)
		PlayerResourcesSystem.step(red_baron, baron_world.config)
	equal(oh_tipi.flux, oh_tipi.flux_recovery_per_second, "%d Hz Oh Tipi recovers the exact authored Flux rate" % tick_rate)
	equal(s_wayne.flux, s_wayne.flux_recovery_per_second, "%d Hz S. Wayne recovers the exact authored Flux rate" % tick_rate)
	equal(red_baron.flux, red_baron.flux_recovery_per_second, "%d Hz Red Baron recovers the exact authored Flux rate" % tick_rate)
	check(oh_world.state_hash() != wayne_world.state_hash(), "%d Hz champion identity changes canonical world state" % tick_rate)
	check(baron_world.state_hash() != oh_world.state_hash(), "%d Hz the large profile changes canonical world state" % tick_rate)


func _test_invalid_profiles_fail_closed() -> void:
	var abilities := AbilityCatalog.new()
	check(abilities.load_from_file(ABILITY_PATH), "ability catalog loads for invalid champion tests")
	var source := ChampionCatalog.new()
	check(source.load_from_file(CHAMPION_PATH, abilities), "champion source loads")
	for mutation: Callable in [
		func(data: Dictionary) -> void: data["schema_version"] = 99,
		func(data: Dictionary) -> void: (data["champions"][0] as Dictionary)["body_type"] = "size_3_medium",
		func(data: Dictionary) -> void: (data["champions"][0] as Dictionary)["wire_id"] = 2,
		func(data: Dictionary) -> void: (data["champions"][0] as Dictionary)["affinities"] = ["water"],
		func(data: Dictionary) -> void: (data["champions"][0] as Dictionary)["affinities"] = ["water", "charge", "ice"],
		func(data: Dictionary) -> void: ((data["champions"][0] as Dictionary)["affinity_points"] as Dictionary)["water"] = 3,
		func(data: Dictionary) -> void: (data["champions"][0] as Dictionary)["affinities"] = ["water", "spirit"],
		func(data: Dictionary) -> void: ((data["champions"][0] as Dictionary)["stats"] as Dictionary)["movement_speed_ratio"] = 5000,
		func(data: Dictionary) -> void: ((data["champions"][0] as Dictionary)["foundation_kit"] as Dictionary)["primary"] = "missing",
	]:
		var candidate := ChampionCatalog.new()
		candidate.data = source.data.duplicate(true)
		mutation.call(candidate.data)
		check(not candidate.validate(abilities), "invalid champion mutation fails closed")
		check(not candidate.last_error.is_empty(), "invalid champion failure is actionable")
