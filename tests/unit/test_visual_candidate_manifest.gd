extends FluxTestSuite


const MANIFEST_PATH: String = "res://assets/concept/champion_keypose_candidates/oh_tipi/oh_tipi_keypose_imagegen_v1.provenance.json"


func run() -> int:
	_test_repository_candidate()
	_test_candidate_fails_closed()
	return finish("visual-candidate-manifest")


func _test_repository_candidate() -> void:
	var manifest := VisualCandidateManifest.new()
	check(manifest.load_from_file(MANIFEST_PATH), "Oh Tipi visual candidate validates: %s" % manifest.last_error)
	equal(String(manifest.data.get("status")), "quarantined_visual_candidate", "visual remains quarantined")
	check(not bool(manifest.data.get("runtime_approved", true)), "visual is not runtime approved")
	equal(String(manifest.data.get("authority")), "presentation_only", "visual cannot define gameplay")
	equal((manifest.data.get("intended_pose_order", []) as Array).size(), 25, "visual declares 25 ordered poses")
	var grid: Dictionary = manifest.data.get("grid", {})
	equal(int(grid.get("columns", 0)), 5, "visual declares five pose columns")
	equal(int(grid.get("rows", 0)), 5, "visual declares five pose rows")
	check(not bool(grid.get("exact_cells", true)), "raw unequal grid remains explicit")
	check(not (manifest.data.get("promotion_blockers", []) as Array).is_empty(), "visual retains promotion blockers")


func _test_candidate_fails_closed() -> void:
	var source := VisualCandidateManifest.new()
	check(source.load_from_file(MANIFEST_PATH), "visual candidate loads as invalid-manifest source")
	var mutations: Array[Callable] = [
		func(data: Dictionary) -> void: data["schema_version"] = 2,
		func(data: Dictionary) -> void: data["status"] = "approved",
		func(data: Dictionary) -> void: data["runtime_approved"] = true,
		func(data: Dictionary) -> void: data["authority"] = "collision",
		func(data: Dictionary) -> void: data["license_status"] = "approved",
		func(data: Dictionary) -> void: (data["generator"] as Dictionary)["provider"] = "",
		func(data: Dictionary) -> void: (data["artifact"] as Dictionary)["path"] = "res://assets/sprites/champions_v2/oh_tipi/atlas.png",
		func(data: Dictionary) -> void: (data["artifact"] as Dictionary)["sha256"] = "0".repeat(64),
		func(data: Dictionary) -> void: (data["artifact"] as Dictionary)["width"] = 1255,
		func(data: Dictionary) -> void: (data["grid"] as Dictionary)["columns"] = 4,
		func(data: Dictionary) -> void: (data["grid"] as Dictionary)["exact_cells"] = true,
		func(data: Dictionary) -> void: (data["intended_pose_order"] as Array)[1] = "idle",
		func(data: Dictionary) -> void: (data["intended_pose_order"] as Array).pop_back(),
		func(data: Dictionary) -> void: ((data["references"] as Array)[0] as Dictionary)["role"] = "",
		func(data: Dictionary) -> void: ((data["references"] as Array)[0] as Dictionary)["role"] = String(((data["references"] as Array)[1] as Dictionary)["role"]),
		func(data: Dictionary) -> void: ((data["references"] as Array)[0] as Dictionary)["sha256"] = "0".repeat(64),
		func(data: Dictionary) -> void: data["observed_strengths"] = [""],
		func(data: Dictionary) -> void: data["promotion_blockers"] = [],
	]
	for mutation: Callable in mutations:
		var candidate := VisualCandidateManifest.new()
		candidate.data = source.data.duplicate(true)
		mutation.call(candidate.data)
		check(not candidate.validate(), "unsafe visual candidate mutation fails closed")
		check(not candidate.last_error.is_empty(), "unsafe visual candidate mutation is diagnosable")
