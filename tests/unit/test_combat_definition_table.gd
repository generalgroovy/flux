extends FluxTestSuite


const CATALOG_PATH: String = "res://content/abilities/foundation_abilities_v1.json"
# Protocol 39's reviewed slowdown. Independent production A/B traces in
# test_elemental_bursts constrain speed, timing, preserved reach and expiry.
const SHIPPED_DEFINITION_SIGNATURES: Dictionary = {
	101: "a2c968a00f1026537d2f9bc3322dbe53cf30f2b6960570f928c6deef4a847ea5",
	110: "e5b953b9b15f0b3a0db0008869c5ab465169a10fab75b729839af1de886734b8",
	140: "c7d02ddccee191c7267b0ee19fc99640da5c6f0cb526d546b94a8630472c0ba3",
	141: "d94cc312d3e1b5c5d2494dfdaa64920d7e15a6b06bcbb91a1e928c7c7afb4b0c",
	144: "10069e98045e5fb89c0bb5ff758f47a77a5b2517b43ac20670144bf5d943b407",
	142: "db69dcd64edaf6991b938b5bd8f6448a3ead12cc493bd1a232cd3f4033e13694",
	143: "14bb8db9663ed3dbbc7b30be7e0bb7a0bbd3fac6d156481ec07bf0bf97446195",
	145: "f9b716b0b6cc1a515acdc40a284d2bc4e8ad6665533cb033bb538a70fe17921a",
	146: "4c24e416cb181da539a25dc08a1302e155c51fe6f747e5f7c22fa64f9f6aed4a",
	147: "739336b3730d05ed90ec2c513921da1279333ba0d415fca658981ed1eddcbaac",
	149: "bcaa05209caed3ed9c05b42b878b27037e5a5055d11168580cafc51fd2f32c5b",
	148: "3f13fa336f24b230ad49a5d90272289c3964e76b7272e38895000bd247492745",
	150: "ca16b5479b275becc7b014ae203c379f3173e0661528bd23e49b594458a21274",
	151: "b869bf61a01d397ee579d2426a4e695182e4e8f91e8f974c0186c7fbe95bc60f",
	152: "c92000fb61abdf01925734e41a1ca4600ced8f2b23e3cc4076d01456e4f86111",
	153: "97d238250e5e15f1ba96077f861caa72d0b3b8160bdaafbb3e8edfed47da6f51",
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
		if SHIPPED_DEFINITION_SIGNATURES.has(wire_id):
			equal(_definition_signature(table.definition(wire_id)), SHIPPED_DEFINITION_SIGNATURES[wire_id], "wire %d preserves its accepted resource-retune outcome fixture" % wire_id)
		else:
			check(wire_id >= 154 and wire_id <= 178, "new compiled wire stays inside the reserved matrix range")
			equal(_definition_signature(table.definition(wire_id)).length(), 64, "new matrix wire %d has a deterministic definition signature" % wire_id)
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
