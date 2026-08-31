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
	equal(first.playable_spell_ids(), ["arc-primary", "cinderbolt", "eclipse-disc", "pocket-eclipse", "rillshot", "rimewake", "tideline", "vector-lance"], "only end-to-end spells enter the playable selector")
	for gated_id: String in ["spirit", "chaos", "gravity", "time"]:
		check(not bool((first.elements_by_id[gated_id] as Dictionary)["runtime_enabled"]), "%s remains explicitly gated" % gated_id)
	equal(String(first.data.get("affinity_rule", "")), "aligned_active_cost_discount_capped_by_affinity_strength", "ability catalog declares weighted affinity discount rule")
	equal(int(first.economy["recovery_delay_ms"]), PlayerTuning.FLUX_RECOVERY_DELAY_MS, "catalog owns the compiled Flux recovery delay")
	equal((first.economy["cadence_tiers_ms"] as Dictionary).keys().size(), 3, "economy declares exactly three cadence tiers")
	equal(int(first.ability("arc-primary")["flux_cost"]) * 1000, CombatTuning.PRIMARY_FLUX_COST, "foundation primary has exact positive Flux cost")
	equal(int(first.ability("arc-primary")["wire_id"]), CombatTuning.PRIMARY_WIRE_ID, "compiled primary wire matches catalog")
	equal(int(first.ability("arc-primary")["cooldown_ms"]), CombatTuning.PRIMARY_COOLDOWN_MS, "compiled primary cooldown matches catalog")
	equal(int(first.ability("vector-lance")["wire_id"]), CombatTuning.ACTIVE_1_WIRE_ID, "compiled active wire matches catalog")
	equal(int(first.ability("vector-lance")["flux_cost"]) * 1000, CombatTuning.ACTIVE_1_FLUX_COST, "compiled active Flux cost matches catalog")
	equal(int(first.ability("vector-lance")["startup_ms"]), CombatTuning.ACTIVE_1_STARTUP_MS, "compiled active startup matches catalog")
	equal(int(first.ability("rillshot")["wire_id"]), CombatTuning.RILLSHOT_WIRE_ID, "Rillshot wire matches compiled Oh Tipi kit")
	equal(int(first.ability("rillshot")["flux_cost"]) * 1000, CombatTuning.RILLSHOT_FLUX_COST, "Oh Tipi primary has exact positive Flux cost")
	equal(int(first.ability("cinderbolt")["wire_id"]), CombatTuning.CINDERBOLT_WIRE_ID, "Cinderbolt wire matches compiled Red Baron kit")
	equal(int(first.ability("cinderbolt")["flux_cost"]) * 1000, CombatTuning.CINDERBOLT_FLUX_COST, "Red Baron primary has exact positive Flux cost")
	equal(int(first.ability("cinderbolt")["cooldown_ms"]), CombatTuning.CINDERBOLT_COOLDOWN_MS, "Cinderbolt cadence matches compiled behavior")
	equal(int(first.ability("tideline")["wire_id"]), CombatTuning.TIDELINE_WIRE_ID, "Tideline wire matches compiled Oh Tipi kit")
	equal(int(first.ability("tideline")["flux_cost"]) * 1000, CombatTuning.TIDELINE_FLUX_COST, "Tideline Flux cost matches compiled behavior")
	equal(int(first.ability("tideline")["startup_ms"]), CombatTuning.TIDELINE_STARTUP_MS, "Tideline startup matches compiled behavior")
	equal(String(first.ability("tideline")["shape"]), "spray", "Tideline is the first promoted spray shape")
	equal(String(CombatTuning.cast_definition(CombatTuning.TIDELINE_WIRE_ID).get("shape")), "spray", "compiled Tideline uses the spray resolver")
	check(CombatTuning.projectile_definition(CombatTuning.TIDELINE_WIRE_ID).is_empty(), "Tideline cannot silently re-enter projectile simulation")
	equal(int(first.ability("rimewake")["wire_id"]), CombatTuning.RIMEWAKE_WIRE_ID, "Rimewake wire matches compiled Oh Tipi kit")
	equal(int(first.ability("rimewake")["flux_cost"]) * 1000, CombatTuning.RIMEWAKE_FLUX_COST, "Rimewake Flux cost matches compiled behavior")
	equal(int(first.ability("rimewake")["startup_ms"]), CombatTuning.RIMEWAKE_STARTUP_MS, "Rimewake startup matches compiled behavior")
	equal(String(first.ability("rimewake")["shape"]), "field", "Rimewake is the first promoted field shape")
	equal(String(CombatTuning.cast_definition(CombatTuning.RIMEWAKE_WIRE_ID).get("shape")), "field", "compiled Rimewake uses the field resolver")
	check(CombatTuning.projectile_definition(CombatTuning.RIMEWAKE_WIRE_ID).is_empty(), "Rimewake cannot silently re-enter projectile simulation")
	check(not bool(first.ability("rimewake")["material_runtime_enabled"]), "Rimewake keeps its planned cooling mutation sealed")
	equal(int(first.ability("eclipse-disc")["wire_id"]), CombatTuning.ECLIPSE_DISC_WIRE_ID, "Eclipse Disc wire matches compiled S. Wayne kit")
	equal(int(first.ability("eclipse-disc")["flux_cost"]) * 1000, CombatTuning.ECLIPSE_DISC_FLUX_COST, "S. Wayne primary has exact positive Flux cost")
	equal(int(first.ability("pocket-eclipse")["wire_id"]), CombatTuning.POCKET_ECLIPSE_WIRE_ID, "Pocket Eclipse wire matches compiled S. Wayne kit")
	equal(int(first.ability("pocket-eclipse")["flux_cost"]) * 1000, CombatTuning.POCKET_ECLIPSE_FLUX_COST, "Pocket Eclipse Flux cost matches compiled behavior")
	equal(int(first.ability("pocket-eclipse")["startup_ms"]), CombatTuning.POCKET_ECLIPSE_STARTUP_MS, "Pocket Eclipse startup matches compiled behavior")
	equal(String(first.ability("pocket-eclipse")["shape"]), "beam", "Pocket Eclipse is the first promoted non-projectile shape")
	equal(String(CombatTuning.cast_definition(CombatTuning.POCKET_ECLIPSE_WIRE_ID).get("shape")), "beam", "compiled Pocket Eclipse uses the beam resolver")
	check(CombatTuning.projectile_definition(CombatTuning.POCKET_ECLIPSE_WIRE_ID).is_empty(), "Pocket Eclipse cannot silently re-enter projectile simulation")
	for playable_id: String in first.playable_spell_ids():
		var playable: Dictionary = first.ability(playable_id)
		check(AbilityCatalog.SHAPES.has(String(playable.get("shape", ""))), "%s declares a legal spell shape" % playable_id)
		check(not bool(playable.get("material_runtime_enabled", true)), "%s keeps material mutation truthfully gated" % playable_id)
		check(int(playable.get("flux_cost", 0)) > 0, "%s cannot create free runtime pressure" % playable_id)
		check(AbilityCatalog.CADENCE_TIER_IDS.has(String(playable.get("cadence_tier", ""))), "%s declares a bounded cadence tier" % playable_id)
	equal(String(first.ability("prism-ward").get("shape")), "defense", "Prism Ward declares its future defense shape")
	equal(String(first.ability("stone-channel").get("residue")), "construct", "Stone Channel declares intended persistent geometry")
	for active_id: String in ["vector-lance", "prism-ward", "stone-channel", "tideline", "rimewake", "pocket-eclipse"]:
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
	equal(first.spell_slot_ids, ["arc-primary", "vector-lance", "prism-ward", "stone-channel", "phase-step", "", "", "", "", "", "", ""], "loadout exposes the stable 3x4 spell weave")
	equal(first.affinity_strength("charge"), 2, "foundation loadout exposes primary Charge strength 2")
	equal(first.affinity_strength("light"), 1, "foundation loadout exposes secondary Light strength 1")
	equal(first.affinity_strength("earth"), 0, "unaligned Earth has affinity strength 0")
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

	var invalid_spell_count := LoadoutDefinition.new()
	invalid_spell_count.data = JSON.parse_string(FileAccess.get_file_as_string(LOADOUT_PATH))
	invalid_spell_count.data["spell_slots"] = ["arc-primary"]
	check(not invalid_spell_count.validate(catalog), "non-twelve-position spell loadout fails closed")
	check(invalid_spell_count.last_error.contains("twelve"), "spell count failure is diagnosable")

	var invalid_duplicate_spell := LoadoutDefinition.new()
	invalid_duplicate_spell.data = JSON.parse_string(FileAccess.get_file_as_string(LOADOUT_PATH))
	invalid_duplicate_spell.data["spell_slots"][4] = "arc-primary"
	check(not invalid_duplicate_spell.validate(catalog), "duplicate equipped spell fails closed")
	check(invalid_duplicate_spell.last_error.contains("unique"), "duplicate spell failure is diagnosable")

	var invalid_catalog := AbilityCatalog.new()
	invalid_catalog.data = catalog.data.duplicate(true)
	for ability: Dictionary in invalid_catalog.data["abilities"]:
		if ability["id"] == "vector-lance":
			ability["flux_cost"] = 0
	check(not invalid_catalog.validate(), "zero-cost catalog active fails closed")
	check(invalid_catalog.last_error.contains("positive"), "active cost failure is diagnosable")

	var free_primary := AbilityCatalog.new()
	free_primary.data = catalog.data.duplicate(true)
	for ability: Dictionary in free_primary.data["abilities"]:
		if ability["id"] == "rillshot":
			ability["flux_cost"] = 0
	check(not free_primary.validate(), "zero-cost runtime primary fails closed")
	check(free_primary.last_error.contains("positive"), "primary cost failure is diagnosable")

	var invalid_shape := AbilityCatalog.new()
	invalid_shape.data = catalog.data.duplicate(true)
	(invalid_shape.data["abilities"][1] as Dictionary)["shape"] = "hitscan"
	check(not invalid_shape.validate(), "unknown shape contract fails closed")
	check(invalid_shape.last_error.contains("shape"), "shape failure is diagnosable")

	var false_material_gate := AbilityCatalog.new()
	false_material_gate.data = catalog.data.duplicate(true)
	var arc: Dictionary = false_material_gate.data["abilities"][1]
	arc["material_operation"] = "none"
	arc["material_runtime_enabled"] = true
	check(not false_material_gate.validate(), "enabled no-op material mutation fails closed")
	check(false_material_gate.last_error.contains("cannot be none"), "material gate failure is diagnosable")
