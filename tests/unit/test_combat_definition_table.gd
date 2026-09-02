extends FluxTestSuite


const CATALOG_PATH: String = "res://content/abilities/foundation_abilities_v1.json"
const SHIPPED_DEFINITION_SIGNATURES: Dictionary = {
	101: "6bf92d9ba4fbe42fe39b3d6e360fd9f39dbf92be71511dda47d3af7e1130f215",
	110: "2ef3a3c60e9b77170f54e02e7b87c12f0bfc4e639e80f5b428734f61ff65f77f",
	140: "da4388eabda5ccac09ac4eff46b09cd8c31430ab8edaa7b9bd0deba138007338",
	141: "ecebb5905a7060740362f2b55cc3056a25a03510e0c3336a1ba96db79f315e23",
	144: "a603372f514f1a14182321480ab72e7648b48d775ef84b4ac1bde05864fb207e",
	142: "f4f9875885d52c3ecc1c898a9fe57404edb20d7a0d2538e3536ad0627ec539b5",
	143: "eadf31af5c8deababf4559e5e4e7fec4bb46f99b2ad0d137c64d22b1738e5c80",
	145: "741ecbea05e91489677f08685eebb8acb343b696002cba0b9044f22c92b048f3",
	146: "1ae5a6215f58645d5a274f4b4a064672a9d49d682328b32f071c41761df84995",
	147: "8df86b7def06ff7d76cb61ac628b9e2e630f66592caa6614984004e1f4e6c866",
	149: "1704ec056fecf54b79c4c299da2c9033c54b58ad54e6b2791cd068b68725bb53",
	148: "60908bcb5ae65b96c0d7f83d72d180d3b199dac4f2e7b39ad29f63c7a4630599",
	150: "8df96833135b56d55baca0710643faa001b6b5e7e3abe79d34cd502891b6a136",
	151: "2a5db5d4fd85188c4adcf2fe8c1e7dd191e95caddba3b93726b8701baa7ff6db",
	152: "32dd038dbdb3a1c07845638f5206d015f51b03cfe83228da84bf68cdcc803992",
	153: "84a5c6e9d4b5f34223fa74c7204c4ad826fd717fb6cdc81067b57241611a1d4b",
}


func run() -> int:
	_test_exact_legacy_parity()
	_test_authored_change_updates_definition_and_hash()
	_test_invalid_simulation_fields_fail_closed()
	return finish("combat-definition-table")


func _catalog() -> AbilityCatalog:
	var catalog := AbilityCatalog.new()
	check(catalog.load_from_file(CATALOG_PATH), "combat source catalog validates: %s" % catalog.last_error)
	return catalog


func _test_exact_legacy_parity() -> void:
	var catalog := _catalog()
	var table := CombatDefinitionTable.new()
	check(table.compile(catalog), "validated catalog compiles once: %s" % table.last_error)
	equal(table.runtime_wire_ids(), CombatTuning.runtime_wire_ids(), "authored runtime order preserves the shipped Loom and snapshot contract")
	equal(table.content_hash.length(), 64, "compiled table has a compatibility hash")
	for wire_id: int in CombatTuning.runtime_wire_ids():
		check(table.is_runtime_wire_id(wire_id), "compiled table contains live wire %d" % wire_id)
		equal(table.definition(wire_id), CombatTuning.cast_definition(wire_id), "wire %d compiles byte-for-byte equivalent simulation data" % wire_id)
		equal(_definition_signature(table.definition(wire_id)), SHIPPED_DEFINITION_SIGNATURES[wire_id], "wire %d preserves the pre-migration command outcome fixture" % wire_id)
	check(table.definition(65_535).is_empty(), "unknown wire fails closed")
	check(table.projectile_definition(CombatTuning.TIDELINE_WIRE_ID).is_empty(), "compiled spray cannot enter projectile simulation")


func _test_authored_change_updates_definition_and_hash() -> void:
	var source := _catalog()
	var baseline := CombatDefinitionTable.new()
	check(baseline.compile(source), "baseline table compiles")
	var changed_catalog := AbilityCatalog.new()
	changed_catalog.data = source.data.duplicate(true)
	for ability: Dictionary in changed_catalog.data["abilities"]:
		if String(ability.get("id", "")) == "arc-primary":
			ability["damage"] = int(ability["damage"]) + 1
	check(changed_catalog.validate(), "bounded authored tuning change validates: %s" % changed_catalog.last_error)
	var changed := CombatDefinitionTable.new()
	check(changed.compile(changed_catalog), "changed catalog compiles: %s" % changed.last_error)
	equal(int(changed.definition(CombatTuning.PRIMARY_WIRE_ID)["damage"]), int(CombatTuning.cast_definition(CombatTuning.PRIMARY_WIRE_ID)["damage"]) + 1, "compiled definition follows its only authored damage value")
	check(changed.content_hash != baseline.content_hash, "authored simulation change updates compatibility hash")


func _test_invalid_simulation_fields_fail_closed() -> void:
	var source := _catalog()
	var missing := AbilityCatalog.new()
	missing.data = source.data.duplicate(true)
	for ability: Dictionary in missing.data["abilities"]:
		if String(ability.get("id", "")) == "rillshot":
			ability.erase("speed")
	check(not missing.validate(), "missing runtime simulation field fails closed")
	check(missing.last_error.contains("rillshot/speed"), "missing field failure identifies ability and field")

	var fractional := AbilityCatalog.new()
	fractional.data = source.data.duplicate(true)
	for ability: Dictionary in fractional.data["abilities"]:
		if String(ability.get("id", "")) == "rillshot":
			ability["damage"] = 1.5
	check(not fractional.validate(), "fractional fixed-point damage fails closed")
	check(fractional.last_error.contains("rillshot/damage"), "fractional field failure is diagnosable")

	var incomplete_order := AbilityCatalog.new()
	incomplete_order.data = source.data.duplicate(true)
	incomplete_order.data["runtime_wire_ids"].pop_back()
	check(not incomplete_order.validate(), "runtime order cannot omit a playable wire")
	check(incomplete_order.last_error.contains("every playable spell"), "runtime order failure is diagnosable")

	var unsupported_rotation := AbilityCatalog.new()
	unsupported_rotation.data = source.data.duplicate(true)
	for ability: Dictionary in unsupported_rotation.data["abilities"]:
		if String(ability.get("id", "")) == "cinder-fan":
			ability["projectile_angles_degrees"] = [-30, 0, 30]
	check(not unsupported_rotation.validate(), "uncompiled symmetric projectile angle fails during content validation")
	check(unsupported_rotation.last_error.contains("deterministic rotation"), "unsupported angle failure is diagnosable before simulation")


func _definition_signature(definition: Dictionary) -> String:
	var normalized := definition.duplicate(true)
	if normalized.has("projectile_rotations"):
		var rotations: Array = []
		for rotation: Vector2i in normalized["projectile_rotations"]:
			rotations.append([rotation.x, rotation.y])
		normalized["projectile_rotations"] = rotations
	return CanonicalContent.sha256(normalized)
