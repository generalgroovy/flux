extends FluxTestSuite


func run() -> int:
	_test_repository_contract()
	_test_contract_fails_closed()
	_test_present_front_reference_file_contract()
	_test_failed_reload_clears_state()
	return finish("visual-production-contract")


func _test_repository_contract() -> void:
	var contract := VisualProductionContract.new()
	check(contract.load_from_files(), "repository v3 visual production contract validates: %s" % contract.last_error)
	equal(contract.derived_directions, VisualProductionContract.EXPECTED_DIRECTIONS, "five authored directions plus mirrors derive the runtime order")
	equal(contract.animations.size(), 25, "all 25 runtime semantic animations are bound")
	equal(_vector2i((contract.data.get("render_contract", {}) as Dictionary).get("pivot", [])), Vector2i(48, 84), "v3 production uses the normalized foot pivot")
	equal(_vector2i(contract.front_reference_data.get("pivot", [])), Vector2i(48, 84), "front-reference catalog uses the production pivot")
	equal(SpriteSheetExtractor.PIVOT, Vector2i(48, 84), "extractor uses the production pivot")
	var idle: Dictionary = contract.animations.get("idle", {})
	var hop: Dictionary = contract.animations.get("hop", {})
	var fall: Dictionary = contract.animations.get("fall", {})
	equal([int(idle.get("frames")), int(idle.get("fps")), bool(idle.get("loop"))], [4, 6, true], "idle timing matches runtime")
	equal([int(hop.get("frames")), int(hop.get("fps")), bool(hop.get("loop"))], [4, 12, false], "hop timing matches runtime")
	equal([int(fall.get("frames")), int(fall.get("fps")), bool(fall.get("loop"))], [2, 10, true], "fall timing matches runtime")
	check(not bool(contract.data.get("runtime_approved", false)), "production contract cannot approve runtime art")
	var oh_tipi: Dictionary = {}
	for character_value: Variant in contract.data.get("characters", []):
		var character: Dictionary = character_value
		if String(character.get("id", "")) == "oh_tipi":
			oh_tipi = character
			break
	equal(String(oh_tipi.get("status", "")), "concept_candidate_quarantined", "Oh Tipi progress is truthful without claiming animation approval")
	var front_champions: Dictionary = contract.front_reference_data.get("champions", {})
	equal(front_champions.size(), 24, "front-reference catalog accounts for every production character")
	var front_oh_tipi: Dictionary = front_champions.get("oh_tipi", {})
	equal(String(front_oh_tipi.get("availability", "")), "planned_missing", "absent Oh Tipi front sprite is explicit")
	equal(String(front_oh_tipi.get("planned_front_sprite", "")), "res://assets/sprites/champions_v3/oh_tipi/front_sprite_256.png", "planned Oh Tipi path is canonical")
	check(not front_oh_tipi.has("front_sprite"), "missing Oh Tipi art cannot claim a present sprite")


func _test_contract_fails_closed() -> void:
	var mutations: Array[Callable] = [
		func(contract: VisualProductionContract) -> void: contract.data["schema_version"] = 4,
		func(contract: VisualProductionContract) -> void: contract.data["authority"] = "visual owns collision",
		func(contract: VisualProductionContract) -> void: contract.data["runtime_approved"] = true,
		func(contract: VisualProductionContract) -> void: (contract.data["reference_baseline"] as Dictionary)["content_authority"] = true,
		func(contract: VisualProductionContract) -> void: (contract.data["render_contract"] as Dictionary)["runtime_cell"] = [64, 64],
		func(contract: VisualProductionContract) -> void: (contract.data["render_contract"] as Dictionary)["pivot"] = [48, 88],
		func(contract: VisualProductionContract) -> void: ((contract.data["render_contract"] as Dictionary)["unique_generated_directions"] as Array).pop_back(),
		func(contract: VisualProductionContract) -> void: ((contract.data["render_contract"] as Dictionary)["mirrored_directions"] as Dictionary)["west"] = "south_east",
		func(contract: VisualProductionContract) -> void: (contract.data["quality_gate"] as Dictionary)["minimum_structural_score"] = 0.2,
		func(contract: VisualProductionContract) -> void: (contract.data["quality_gate"] as Dictionary)["auto_finalization"] = true,
		func(contract: VisualProductionContract) -> void: contract.front_reference_data["pivot"] = [48, 92],
		func(contract: VisualProductionContract) -> void: (contract.front_reference_data["champions"] as Dictionary).erase("oh_tipi"),
		func(contract: VisualProductionContract) -> void: ((contract.front_reference_data["champions"] as Dictionary)["oh_tipi"] as Dictionary)["availability"] = "candidate_present",
		func(contract: VisualProductionContract) -> void: ((contract.front_reference_data["champions"] as Dictionary)["oh_tipi"] as Dictionary)["front_sprite"] = "res://assets/sprites/champions_v3/oh_tipi/front_sprite_256.png",
		func(contract: VisualProductionContract) -> void: ((contract.front_reference_data["champions"] as Dictionary)["oh_tipi"] as Dictionary)["planned_front_sprite"] = "res://assets/sprites/champions_v3/wrong.png",
		func(contract: VisualProductionContract) -> void: ((contract.front_reference_data["champions"] as Dictionary)["oh_tipi"] as Dictionary)["status"] = "reference_exact_or_corrected_candidate",
		func(contract: VisualProductionContract) -> void: ((contract.front_reference_data["champions"] as Dictionary)["oh_tipi"] as Dictionary)["availability"] = "unknown",
		func(contract: VisualProductionContract) -> void: ((contract.runtime_data["character_contract"] as Dictionary)["pivot"] as Array)[1] = 57,
		func(contract: VisualProductionContract) -> void: (contract.data["animations"] as Dictionary).erase("idle"),
		func(contract: VisualProductionContract) -> void: ((contract.data["animations"] as Dictionary)["idle"] as Dictionary)["frames"] = 5,
		func(contract: VisualProductionContract) -> void: ((contract.data["animations"] as Dictionary)["idle"] as Dictionary)["frames"] = 4.5,
		func(contract: VisualProductionContract) -> void: ((contract.data["animations"] as Dictionary)["idle"] as Dictionary)["fps"] = 7,
		func(contract: VisualProductionContract) -> void: ((contract.data["animations"] as Dictionary)["idle"] as Dictionary)["fps"] = 6.5,
		func(contract: VisualProductionContract) -> void: ((contract.data["animations"] as Dictionary)["idle"] as Dictionary)["loop"] = false,
		func(contract: VisualProductionContract) -> void: ((contract.runtime_data["character_contract"] as Dictionary)["animations"] as Array)[0]["loop"] = "true",
		func(contract: VisualProductionContract) -> void: ((contract.data["animations"] as Dictionary)["idle"] as Dictionary)["status"] = "accepted",
	]
	for mutation: Callable in mutations:
		var contract := VisualProductionContract.new()
		check(contract.load_from_files(), "repository contract loads as adversarial source")
		contract.data = contract.data.duplicate(true)
		contract.runtime_data = contract.runtime_data.duplicate(true)
		contract.front_reference_data = contract.front_reference_data.duplicate(true)
		mutation.call(contract)
		check(not contract.validate(), "unsafe v3 contract mutation fails closed")
		check(not contract.last_error.is_empty(), "unsafe v3 contract mutation is actionable")
		equal(contract.derived_directions, [], "failed contract exposes no derived directions")
		equal(contract.animations, {}, "failed contract exposes no animation outputs")


func _test_present_front_reference_file_contract() -> void:
	var path := "user://visual-production-front-reference-fixture.png"
	var image := Image.create(256, 256, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	for y: int in range(80, 200):
		for x: int in range(96, 160):
			image.set_pixel(x, y, Color(0.1, 0.45, 0.9, 1.0))
	equal(image.save_png(path), OK, "temporary front-reference fixture writes")
	var contract := VisualProductionContract.new()
	var entry := {"sha256": contract._sha256(path)}
	check(contract._validate_present_front_reference(entry, path, "fixture"), "valid 256px RGBA alpha candidate passes file contract: %s" % contract.last_error)
	entry["sha256"] = "0".repeat(64)
	check(not contract._validate_present_front_reference(entry, path, "fixture"), "stale front-reference hash fails closed")
	entry["sha256"] = contract._sha256(path)
	var opaque := Image.create(256, 256, false, Image.FORMAT_RGBA8)
	opaque.fill(Color.WHITE)
	equal(opaque.save_png(path), OK, "opaque adversarial fixture writes")
	entry["sha256"] = contract._sha256(path)
	check(not contract._validate_present_front_reference(entry, path, "fixture"), "opaque front reference fails alpha contract")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _test_failed_reload_clears_state() -> void:
	var contract := VisualProductionContract.new()
	check(contract.load_from_files(), "contract loads before failed-reuse test")
	check(not contract.derived_directions.is_empty(), "successful load exposes derived directions")
	check(not contract.animations.is_empty(), "successful load exposes animation definitions")
	check(not contract.load_from_files("res://content/visual/missing-production-contract.json"), "missing production manifest fails closed")
	equal(contract.data, {}, "failed reload clears the previous production manifest")
	equal(contract.runtime_data, {}, "failed reload clears the previous runtime catalog")
	equal(contract.front_reference_data, {}, "failed reload clears the previous front-reference catalog")
	equal(contract.derived_directions, [], "failed reload clears derived directions")
	equal(contract.animations, {}, "failed reload clears animation outputs")
	check("does not exist" in contract.last_error, "failed reload retains actionable evidence")


func _vector2i(value: Variant) -> Vector2i:
	var values: Array = value
	return Vector2i(int(values[0]), int(values[1]))
