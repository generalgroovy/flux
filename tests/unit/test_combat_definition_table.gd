extends FluxTestSuite


const CATALOG_PATH: String = "res://content/abilities/foundation_abilities_v1.json"
const SHIPPED_DEFINITION_SIGNATURES: Dictionary = {
	101: "5c956e042c6b549de204bb9ec4d60f1f32f82183382ec8b471c7bec8c8ef80a6",
	110: "4e1a757935a2bb0ad33ee95c6ef7766d0f3f6b17991024c07b8011a247f33195",
	140: "da4388eabda5ccac09ac4eff46b09cd8c31430ab8edaa7b9bd0deba138007338",
	141: "d94cc312d3e1b5c5d2494dfdaa64920d7e15a6b06bcbb91a1e928c7c7afb4b0c",
	144: "10069e98045e5fb89c0bb5ff758f47a77a5b2517b43ac20670144bf5d943b407",
	142: "b2e4d388f3fce02eace7c4346c78fb0ee035f1740bd9f0fe948730c226d27c84",
	143: "14bb8db9663ed3dbbc7b30be7e0bb7a0bbd3fac6d156481ec07bf0bf97446195",
	145: "1442de4eac91be519e608f0598d1495083a736a53f288e11d2f1daa642221c5a",
	146: "7e10aaa4dedcb194276e5642ef1a2a0968a47b0a1a8aebfc1c2cb9fa3e210349",
	147: "ccfa71d5e6ae81f0340c295a1b4ea6980ffafd2626284833791723fa53f81fba",
	149: "61cece2dd40f2c8c280016cca906ad15f43ffdee0980bac05711e320cd0d7f93",
	148: "fdf4e36f05a26da745b7b8a49a4ba04dd6e579f24b00591aade037098e87eea9",
	150: "2caeba2fa3545cdcd3b9f5402484b54a847ded0defff963123bd6f310fbeaf34",
	151: "83c84f682e6cee12c128b4d25c57ea98219bf3b504d55e1d5955c9c973a887ab",
	152: "2fa77af185393f25f83224f9cb7402b25f2adc86cae7b4ce0f463e3cba4b4a69",
	153: "84b51156763216e09ce33cdb73335b48a7914c5761f5f554aac683b02cd5fd30",
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
		equal(_definition_signature(table.definition(wire_id)), SHIPPED_DEFINITION_SIGNATURES[wire_id], "wire %d matches the accepted resource-retune outcome fixture" % wire_id)
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
