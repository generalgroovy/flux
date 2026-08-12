extends FluxTestSuite


func run() -> int:
	_test_repository_catalog()
	_test_catalog_lookups()
	_test_status_boundaries()
	_test_invalid_catalog_fails_closed()
	return finish("complete-visual-catalog")


func _test_repository_catalog() -> void:
	var catalog := CompleteVisualCatalog.new()
	check(catalog.load_from_file(), "complete visual catalog validates: %s" % catalog.last_error)
	equal(catalog.ancestries.size(), 23, "all ancestry/body-plan slots are registered")
	equal(catalog.champions.size(), 24, "all champion visual slots are registered")
	equal(catalog.districts.size(), 9, "all Sanctum district visual packages are registered")
	equal((catalog.props.get("order", []) as Array).size(), 16, "all typed prop families are registered")
	equal((catalog.props.get("states", []) as Array).size(), 8, "all interaction presentation states are registered")
	equal((catalog.element_vfx.get("elements", []) as Array).size(), 8, "all enabled element VFX families are registered")
	equal((catalog.element_vfx.get("phases", []) as Array).size(), 6, "all element presentation phases are registered")


func _test_catalog_lookups() -> void:
	var catalog := CompleteVisualCatalog.new()
	check(catalog.load_from_file(), "catalog loads for lookup tests")
	check(not catalog.champion("oh_tipi").is_empty(), "Oh Tipi visual definition resolves")
	check(not catalog.champion("nico_lai").is_empty(), "Nico Lai visual definition resolves")
	check(not catalog.ancestry("weaverkin").is_empty(), "provisional Weaverkin body plan resolves")
	check(not catalog.district("movement_conservatory").is_empty(), "Movement Conservatory visual package resolves")
	check(catalog.champion("missing").is_empty(), "unknown champion fails closed")


func _test_status_boundaries() -> void:
	var catalog := CompleteVisualCatalog.new()
	check(catalog.load_from_file(), "catalog loads for status tests")
	equal(str(catalog.champion("unnamed_angel").get("status", "")), "placeholder_unapproved", "Angel slot remains explicitly unapproved")
	equal(str(catalog.ancestry("weaverkin").get("status", "")), "body_plan_candidate", "Weaverkin remains provisional")
	equal(str(catalog.ancestry("scorpionkin").get("status", "")), "body_plan_candidate", "Scorpionkin remains provisional")
	equal(str(catalog.ancestry("harvestkin").get("status", "")), "body_plan_candidate", "Harvestkin remains provisional")
	for district_id: String in catalog.districts:
		equal(str(catalog.district(district_id).get("status", "")), "presentation_only", "%s cannot claim map authority" % district_id)


func _test_invalid_catalog_fails_closed() -> void:
	var catalog := CompleteVisualCatalog.new()
	catalog.data = {
		"schema_version": 1,
		"character_contract": {"cell_size": [32, 32], "pivot": [16, 28], "directions": [], "animations": []},
		"ancestries": {},
		"champions": {},
		"districts": {},
	}
	check(not catalog.validate(), "incomplete visual catalog fails closed")
	check(not catalog.last_error.is_empty(), "complete catalog failure is diagnosable")
