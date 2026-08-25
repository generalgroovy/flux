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
	equal(String(first.data.get("affinity_rule", "")), "aligned_active_cost_discount_capped_by_affinity_strength", "ability catalog declares weighted affinity discount rule")
	equal(int(first.ability("arc-primary")["flux_cost"]), 0, "reliable primary is resource-free")
	equal(int(first.ability("arc-primary")["wire_id"]), CombatTuning.PRIMARY_WIRE_ID, "compiled primary wire matches catalog")
	equal(int(first.ability("arc-primary")["cooldown_ms"]), CombatTuning.PRIMARY_COOLDOWN_MS, "compiled primary cooldown matches catalog")
	equal(int(first.ability("vector-lance")["wire_id"]), CombatTuning.ACTIVE_1_WIRE_ID, "compiled active wire matches catalog")
	equal(int(first.ability("vector-lance")["flux_cost"]) * 1000, CombatTuning.ACTIVE_1_FLUX_COST, "compiled active Flux cost matches catalog")
	equal(int(first.ability("vector-lance")["startup_ms"]), CombatTuning.ACTIVE_1_STARTUP_MS, "compiled active startup matches catalog")
	equal(int(first.ability("rillshot")["wire_id"]), CombatTuning.RILLSHOT_WIRE_ID, "Rillshot wire matches compiled Oh Tipi kit")
	equal(int(first.ability("rillshot")["flux_cost"]), 0, "Oh Tipi primary remains resource-free")
	equal(int(first.ability("tideline")["wire_id"]), CombatTuning.TIDELINE_WIRE_ID, "Tideline wire matches compiled Oh Tipi kit")
	equal(int(first.ability("tideline")["flux_cost"]) * 1000, CombatTuning.TIDELINE_FLUX_COST, "Tideline Flux cost matches compiled behavior")
	equal(int(first.ability("tideline")["startup_ms"]), CombatTuning.TIDELINE_STARTUP_MS, "Tideline startup matches compiled behavior")
	equal(int(first.ability("eclipse-disc")["wire_id"]), CombatTuning.ECLIPSE_DISC_WIRE_ID, "Eclipse Disc wire matches compiled S. Wayne kit")
	equal(int(first.ability("eclipse-disc")["flux_cost"]), 0, "S. Wayne primary remains resource-free")
	equal(int(first.ability("pocket-eclipse")["wire_id"]), CombatTuning.POCKET_ECLIPSE_WIRE_ID, "Pocket Eclipse wire matches compiled S. Wayne kit")
	equal(int(first.ability("pocket-eclipse")["flux_cost"]) * 1000, CombatTuning.POCKET_ECLIPSE_FLUX_COST, "Pocket Eclipse Flux cost matches compiled behavior")
	equal(int(first.ability("pocket-eclipse")["startup_ms"]), CombatTuning.POCKET_ECLIPSE_STARTUP_MS, "Pocket Eclipse startup matches compiled behavior")
	for active_id: String in ["vector-lance", "prism-ward", "stone-channel", "tideline", "pocket-eclipse"]:
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
	equal(first.affinity_strength("charge"), 2, "foundation loadout exposes primary Charge strength 2")
	equal(first.affinity_strength("light"), 1, "foundation loadout exposes secondary Light strength 1")
	equal(first.affinity_strength("earth"), 0, "unaligned Earth has affinity strength 0")
	equal(first.active_points, 13, "current discount caps preserve the 13-point foundation budget")
	equal(first.content_hash.length(), 64, "loadout has a SHA-256 compatibility hash")
	equal(first.content_hash, second.content_hash, "loadout hash is stable across reloads")


func _test_invalid_content_fails_closed() -> void:
	var catalog: AbilityCatalog = _catalog()
	var invalid_duplicate := LoadoutDefinition.new()
	invalid_duplicate.data = JSON.parse_string(FileAccess.get_file_as_string(LOADOUT_PATH))
	invalid_duplicate.data["slots"]["actives"] = ["vector-lance", "vector-lance", "stone-channel"]
	check(not invalid_duplicate.validate(catalog), "duplicate active fails closed")
	check(invalid_duplicate.last_error.contains("unique"), "duplicate failure is diagnosable")

	var invalid_affinity_total := LoadoutDefinition.new()
	invalid_affinity_total.data = JSON.parse_string(FileAccess.get_file_as_string(LOADOUT_PATH))
	invalid_affinity_total.data["affinity_points"] = {"charge": 1, "light": 1}
	check(not invalid_affinity_total.validate(catalog), "loadout must spend exactly three affinity points")
	check(invalid_affinity_total.last_error.contains("must total"), "affinity-point failure is diagnosable")

	var invalid_affinity_strength := LoadoutDefinition.new()
	invalid_affinity_strength.data = JSON.parse_string(FileAccess.get_file_as_string(LOADOUT_PATH))
	invalid_affinity_strength.data["affinity_points"] = {"charge": 3, "light": 0}
	check(not invalid_affinity_strength.validate(catalog), "affinity strength outside 1..2 fails closed")
	check(invalid_affinity_strength.last_error.contains("strength"), "affinity-strength failure is diagnosable")

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
