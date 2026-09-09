extends FluxTestSuite


const CATALOG_PATH: String = "res://content/abilities/foundation_abilities_v1.json"
# Local readability candidate: 20% slower and 20% larger projectiles.
# Independent production A/B traces in test_elemental_bursts constrain
# speed, actual collision radius, timing, preserved reach and expiry.
const CANDIDATE_DEFINITION_SIGNATURES: Dictionary = {
	101: "5f0485be6169c4621f9f2c4b9b7b57ba966e42814c1a1c1ad33c426d48546011",
	110: "75ebd63e86007701558ec3f008638bf7540da89b3041be76fdfee75849251395",
	140: "32693d70069c7083b26c36666cb5ad48864691476da0188a1d7e8b6203b5476e",
	141: "d94cc312d3e1b5c5d2494dfdaa64920d7e15a6b06bcbb91a1e928c7c7afb4b0c",
	144: "6bbdb77fb4e2356adf7a6cb222f2b787642c9ac32c90f60aaa092475c4fc4751",
	142: "6558f49079d8993f7472f1d02e11ccede7a7cdc84b67a34454f85e58536062d9",
	143: "14bb8db9663ed3dbbc7b30be7e0bb7a0bbd3fac6d156481ec07bf0bf97446195",
	145: "339e9eed3be4962b07a29404a740aeecb09112ac27475c9d82f033527511aba8",
	146: "b9b0f79041c8797da4bfb9677af9c23986658b12b2d87d13b70e6fad7a3a97f6",
	147: "fe50719aab228ccd860791a50d778aec8310092f54a3db807731bd5cbfe2c623",
	149: "1f26860d5e648dbdf5aba02638edfe6d17350983c11d84d1899a220afcb52664",
	148: "e6756f3fb733de6875723bbc121479f1d9815ed2b8d81e2921565f939b04943e",
	150: "d7e72e3f17e781fcc613fc705ae8f37f1636645ac3a770ea95157abeb5715b45",
	151: "e5e391e231d7cd21fb1d9bc9c4db78ac426cb22e8fe0a81b8a3bda760135ecbb",
	152: "6951b4bce13498a966dc105dc09e8564a9ae201cac0b75fda0e825d119b297b0",
	153: "2290e06b8f44d905eaa5269ab816665dd2972f47878e312a53fcbe20ecbdde1d",
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
		if CANDIDATE_DEFINITION_SIGNATURES.has(wire_id):
			equal(_definition_signature(table.definition(wire_id)), CANDIDATE_DEFINITION_SIGNATURES[wire_id], "wire %d preserves its local readability candidate fixture" % wire_id)
		else:
			check(wire_id >= 154 and wire_id <= 194, "new compiled wire stays inside the reserved matrix range")
			equal(_definition_signature(table.definition(wire_id)).length(), 64, "new matrix wire %d has a deterministic definition signature" % wire_id)
	check(table.definition(65_535).is_empty(), "unknown wire fails closed")
	check(table.projectile_definition(CombatTuning.TIDELINE_WIRE_ID).is_empty(), "compiled spray cannot enter projectile simulation")
	var eclipse_definition := table.definition(142)
	equal(int(eclipse_definition["remaining_bounces"]), 0, "Eclipse deposits its material at the first terminal instead of intrinsically ricocheting")
	eclipse_definition["remaining_bounces"] = 1
	equal(_definition_signature(eclipse_definition), "4d2c13d8121a220082f114fa3fa5dfa4f922c98e3fe0bc6f444864b55aa1a979", "readability candidate Eclipse definition changes only its intrinsic bounce count")


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
