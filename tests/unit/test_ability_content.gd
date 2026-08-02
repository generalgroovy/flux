extends FluxTestSuite


const CATALOG_PATH: String = "res://content/abilities/foundation_abilities_v1.json"
const LOADOUT_PATH: String = "res://content/loadouts/foundation_practitioner_v1.json"


func run() -> int:
	_test_catalog()
	_test_loadout()
	_test_invalid_content_fails_closed()
	return finish("ability-content")


func _catalog() -> AbilityCatalog:
	var catalog := AbilityCatalog.new()
	check(catalog.load_from_file(CATALOG_PATH), "foundation ability catalog validates: %s" % catalog.last_error)
	return catalog


func _test_catalog() -> void:
	var first: AbilityCatalog = _catalog()
	var second: AbilityCatalog = _catalog()
	equal(first.content_hash.length(), 64, "catalog has a SHA-256 content hash")
	equal(first.content_hash, second.content_hash, "catalog hash is stable across reloads")
	equal(first.elements_by_id.size(), 12, "all twelve thematic element families are declared")
	equal(first.active_element_ids(), ["charge", "dark", "earth", "fire", "ice", "light", "water", "wind"], "only the first eight families are runtime-enabled")
	for gated_id: String in ["spirit", "chaos", "gravity", "time"]:
		check(not bool((first.elements_by_id[gated_id] as Dictionary)["runtime_enabled"]), "%s remains explicitly gated" % gated_id)
	equal(int(first.ability("arc-primary")["flux_cost"]), 0, "reliable primary is resource-free")
	equal(int(first.ability("arc-primary")["wire_id"]), CombatTuning.PRIMARY_WIRE_ID, "compiled primary wire matches catalog")
	equal(int(first.ability("arc-primary")["cooldown_ms"]), CombatTuning.PRIMARY_COOLDOWN_MS, "compiled primary cooldown matches catalog")
	equal(int(first.ability("vector-lance")["wire_id"]), CombatTuning.ACTIVE_1_WIRE_ID, "compiled active wire matches catalog")
	equal(int(first.ability("vector-lance")["flux_cost"]) * 1000, CombatTuning.ACTIVE_1_FLUX_COST, "compiled active Flux cost matches catalog")
	equal(int(first.ability("vector-lance")["startup_ms"]), CombatTuning.ACTIVE_1_STARTUP_MS, "compiled active startup matches catalog")
	for active_id: String in ["vector-lance", "prism-ward", "stone-channel"]:
		var active: Dictionary = first.ability(active_id)
		check(int(active["points"]) > 0, "%s has positive build cost" % active_id)
		check(int(active["flux_cost"]) > 0, "%s has positive Flux cost" % active_id)
		check(not (active["counterplay"] as Array).is_empty(), "%s declares counterplay" % active_id)


func _test_loadout() -> void:
	var catalog: AbilityCatalog = _catalog()
	var first := LoadoutDefinition.new()
	var second := LoadoutDefinition.new()
	check(first.load_from_file(LOADOUT_PATH, catalog), "foundation loadout validates: %s" % first.last_error)
	check(second.load_from_file(LOADOUT_PATH, catalog), "foundation loadout reload validates")
	equal(first.active_points, 13, "affinity-adjusted actives fill the 13-point budget exactly")
	equal(first.content_hash.length(), 64, "loadout has a SHA-256 compatibility hash")
	equal(first.content_hash, second.content_hash, "loadout hash is stable across reloads")


func _test_invalid_content_fails_closed() -> void:
	var catalog: AbilityCatalog = _catalog()
	var invalid_duplicate := LoadoutDefinition.new()
	invalid_duplicate.data = JSON.parse_string(FileAccess.get_file_as_string(LOADOUT_PATH))
	invalid_duplicate.data["slots"]["actives"] = ["vector-lance", "vector-lance", "stone-channel"]
	check(not invalid_duplicate.validate(catalog), "duplicate active fails closed")
	check(invalid_duplicate.last_error.contains("unique"), "duplicate failure is diagnosable")

	var invalid_budget := LoadoutDefinition.new()
	invalid_budget.data = JSON.parse_string(FileAccess.get_file_as_string(LOADOUT_PATH))
	invalid_budget.data["active_budget"] = 12
	check(not invalid_budget.validate(catalog), "nonstandard budget fails closed")
	check(invalid_budget.last_error.contains("13"), "budget failure is diagnosable")

	var invalid_catalog := AbilityCatalog.new()
	invalid_catalog.data = catalog.data.duplicate(true)
	for ability: Dictionary in invalid_catalog.data["abilities"]:
		if ability["id"] == "vector-lance":
			ability["flux_cost"] = 0
	check(not invalid_catalog.validate(), "zero-cost catalog active fails closed")
	check(invalid_catalog.last_error.contains("positive"), "active cost failure is diagnosable")
