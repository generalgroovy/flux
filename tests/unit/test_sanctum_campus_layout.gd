extends FluxTestSuite


const CAMPUS_PATH: String = "res://content/maps/sanctum_campus_g2_v1.json"


func run() -> int:
	_test_repository_layout()
	_test_collision_compilation()
	_test_invalid_layouts_fail_closed()
	_test_disconnected_graph_fails_closed()
	_test_custom_world_identity()
	return finish("sanctum-campus-layout")


func _test_repository_layout() -> void:
	var layout := SanctumCampusLayout.new()
	check(layout.load_from_file(CAMPUS_PATH), "repository campus layout validates: %s" % layout.last_error)
	equal(String(layout.data.get("id")), "sanctum-campus-g2-v1", "campus layout id is stable")
	equal(layout.canvas_size, Vector2i(2560, 1440), "campus is larger than the gameplay viewport")
	equal(layout.viewport_size, Vector2i(1280, 720), "campus preserves the supported gameplay viewport")
	equal(layout.spawn, Vector2i(1280, 720), "campus spawn anchors the combined Nexus commons")
	check(layout.content_hash.length() == 64, "campus layout has a canonical content hash")
	equal(layout.districts_by_id.size(), 3, "related Sanctum functions are combined into three large quarters")
	for district_id: String in SanctumCampusLayout.REQUIRED_DISTRICTS:
		check(layout.districts_by_id.has(district_id), "required visible district exists: %s" % district_id)
	equal(layout.buildings_by_id.size(), 10, "authored buildings and low cover are registered")
	equal(layout.landmarks_by_id.size(), 6, "combined quarters retain multiple memorable landmarks")
	equal(layout.reset_zones_by_id.size(), 2, "movement and proving reset zones are explicit")
	equal(layout.stations_by_id.size(), 11, "play, controls, spell, Farflow and host-stewardship stations are explicit")
	equal(layout.practice_targets_by_id.size(), 1, "the Nexus sparring effigy is explicit")
	equal(String(layout.arena_definition.get("id", "")), "proving-court-v1", "the first bounded arena has a stable authored identity")
	equal((layout.arena_definition.get("spawns", []) as Array).size(), 8, "arena reserves eight ordered spawn anchors")
	var hearth_station: Dictionary = layout.stations_by_id["session-hearth"]
	equal((hearth_station.get("gather_spawns", []) as Array).size(), 8, "Hearth reserves one rematch gather spawn per supported traveller")
	var effigy: Dictionary = layout.practice_targets_by_id["nexus-sparring-effigy"]
	equal(int(effigy.get("entity_id", 0)), 900, "sparring effigy has a stable simulation entity id")
	equal(int(effigy.get("health", 0)), 80_000, "sparring effigy has authored Health")
	equal(layout.elevation_at(Vector2i(1280, 720)), 2, "Nexus elevation is queryable without rendering")
	equal(layout.elevation_at(Vector2i(300, 720)), 1, "Conservatory elevation is queryable without rendering")
	equal(layout.elevation_at(Vector2i(10, 200)), 0, "water outside districts has no ground elevation")
	var represented_sources: Dictionary[String, bool] = {}
	for district_id: String in layout.districts_by_id:
		for source_value: Variant in (layout.districts_by_id[district_id] as Dictionary).get("combines", []):
			represented_sources[String(source_value)] = true
	for source_district_id: String in SanctumCampusLayout.REQUIRED_SOURCE_DISTRICTS:
		check(represented_sources.has(source_district_id), "combined campus retains source function area: %s" % source_district_id)
	for building_id: int in layout.buildings_by_id:
		var building: Dictionary = layout.buildings_by_id[building_id]
		check(not String(building.get("occlusion_policy", "")).is_empty(), "building %d declares foreground occlusion behavior" % building_id)


func _test_collision_compilation() -> void:
	var layout := SanctumCampusLayout.new()
	check(layout.load_from_file(CAMPUS_PATH), "campus loads for collision compilation")
	var collision: CollisionWorld = layout.build_collision_world()
	equal(collision.width, 2_560_000, "campus collision width uses fixed-point units")
	equal(collision.height, 1_440_000, "campus collision height uses fixed-point units")
	equal(collision.obstacles.size(), 10, "every authored building compiles to ordered collision")
	for index: int in range(collision.obstacles.size() - 1):
		check(collision.obstacles[index].obstacle_id < collision.obstacles[index + 1].obstacle_id, "campus obstacle ids are canonical")
	check(collision.can_occupy(layout.spawn * SimConfig.FIXED_SCALE, MovementTuning.PLAYER_RADIUS), "authored spawn has player clearance")
	var target: Dictionary = layout.practice_targets_by_id["nexus-sparring-effigy"]
	check(collision.can_occupy(Vector2i(1_500_000, 720_000), int(target.get("radius", 0)) * SimConfig.FIXED_SCALE), "sparring effigy has authored collision clearance")
	check(collision.can_occupy(Vector2i(1_980_000, 800_000), MovementTuning.PLAYER_RADIUS), "Farflow host station has authored collision clearance")
	check(collision.can_occupy(Vector2i(2_180_000, 800_000), MovementTuning.PLAYER_RADIUS), "Farflow join station has authored collision clearance")
	check(collision.can_occupy(Vector2i(2_380_000, 800_000), MovementTuning.PLAYER_RADIUS), "Farflow Charter has authored collision clearance")
	check(collision.can_occupy(Vector2i(2_080_000, 620_000), MovementTuning.PLAYER_RADIUS), "Session Hearth has authored collision clearance")
	check(collision.can_occupy(Vector2i(2_300_000, 620_000), MovementTuning.PLAYER_RADIUS), "Company Ledger has authored collision clearance")
	check(collision.can_occupy(Vector2i(2_460_000, 620_000), MovementTuning.PLAYER_RADIUS), "Parting Bell has authored collision clearance")
	check(collision.can_occupy(Vector2i(1_080_000, 900_000), MovementTuning.PLAYER_RADIUS), "Controls Lectern has authored collision clearance")
	check(collision.can_occupy(Vector2i(1_480_000, 900_000), MovementTuning.PLAYER_RADIUS), "Spell Loom has authored collision clearance")
	for gather_value: Variant in (layout.stations_by_id["session-hearth"] as Dictionary).get("gather_spawns", []):
		var gather_values: Array = gather_value
		check(collision.can_occupy(Vector2i(int(gather_values[0]), int(gather_values[1])) * SimConfig.FIXED_SCALE, MovementTuning.PLAYER_RADIUS), "Hearth gather spawn has authored collision clearance")
	check(not collision.can_occupy(Vector2i(180_000, 360_000), MovementTuning.PLAYER_RADIUS), "routekeeper lodge collision matches presentation bounds")
	var vault: CollisionWorld.Obstacle = collision.find_vault_candidate(Vector2i(1_520_000, 720_000), Vector2i(1000, 0), MovementTuning.PLAYER_RADIUS)
	check(vault != null, "marked campus vault rail is discoverable")
	if vault != null:
		equal(vault.obstacle_id, 110, "marked campus vault rail preserves stable obstacle id")


func _test_invalid_layouts_fail_closed() -> void:
	var source := SanctumCampusLayout.new()
	check(source.load_from_file(CAMPUS_PATH), "campus loads as invalid-layout source")
	var mutations: Array[Callable] = [
		func(data: Dictionary) -> void: data["schema_version"] = 99,
		func(data: Dictionary) -> void: data["canvas_size"] = [1280, 720],
		func(data: Dictionary) -> void: data["required_districts"] = ["nexus-court"],
		func(data: Dictionary) -> void: (data["connections"][0] as Dictionary)["to"] = "missing-district",
		func(data: Dictionary) -> void: (data["routes"][0] as Dictionary)["points"] = [[-1, 200], [20, 200]],
		func(data: Dictionary) -> void: (data["routes"][0] as Dictionary)["kind"] = "teleport",
		func(data: Dictionary) -> void: (data["routes"][1] as Dictionary)["accessible"] = false,
		func(data: Dictionary) -> void: (data["routes"][1] as Dictionary)["points"] = [[82, 720], [1500, 720]],
		func(data: Dictionary) -> void: (data["reset_zones"][0] as Dictionary)["bounds"] = [800, 1200, 300, 300],
		func(data: Dictionary) -> void: (data["arena"] as Dictionary)["score_limit"] = 99,
		func(data: Dictionary) -> void: (data["arena"] as Dictionary)["spawns"] = [[1900, 860]],
		func(data: Dictionary) -> void: (data["arena"] as Dictionary)["bounds"] = [0, 0, 100, 100],
		func(data: Dictionary) -> void: (data["stations"][0] as Dictionary)["command"] = "open_detached_menu",
		func(data: Dictionary) -> void: (data["stations"][0] as Dictionary)["interaction_radius"] = 900,
		func(data: Dictionary) -> void: (data["stations"][0] as Dictionary)["lines"] = "too vague",
		func(data: Dictionary) -> void: (data["stations"][0] as Dictionary)["position"] = [1200, 500],
		func(data: Dictionary) -> void: (data["stations"][7] as Dictionary)["gather_spawns"] = [[2080, 620]],
		func(data: Dictionary) -> void: ((data["stations"][7] as Dictionary)["gather_spawns"] as Array)[0] = [2300, 620],
		func(data: Dictionary) -> void: ((data["stations"][7] as Dictionary)["gather_spawns"] as Array)[1] = [2144, 620],
		func(data: Dictionary) -> void: (data["practice_targets"][0] as Dictionary)["health"] = 0,
		func(data: Dictionary) -> void: (data["practice_targets"][0] as Dictionary)["entity_id"] = 1,
		func(data: Dictionary) -> void: (data["practice_targets"][0] as Dictionary)["position"] = [1200, 500],
		func(data: Dictionary) -> void: (data["buildings"][0] as Dictionary)["occlusion_policy"] = "always_xray",
		func(data: Dictionary) -> void: (data["buildings"][0] as Dictionary)["worldbone"] = false,
		func(data: Dictionary) -> void: (data["buildings"][9] as Dictionary)["vaultable"] = false,
		func(data: Dictionary) -> void: (data["landmarks"][0] as Dictionary)["position"] = [2550, 1430],
		func(data: Dictionary) -> void: (data["buildings"][4] as Dictionary)["bounds"] = [1250, 690, 60, 60],
	]
	for mutation: Callable in mutations:
		var candidate := SanctumCampusLayout.new()
		candidate.data = source.data.duplicate(true)
		mutation.call(candidate.data)
		check(not candidate.validate(), "invalid campus mutation fails closed")
		check(not candidate.last_error.is_empty(), "invalid campus mutation is diagnosable")


func _test_disconnected_graph_fails_closed() -> void:
	var source := SanctumCampusLayout.new()
	check(source.load_from_file(CAMPUS_PATH), "campus loads as disconnected-graph source")
	var candidate := SanctumCampusLayout.new()
	candidate.data = source.data.duplicate(true)
	var reverse_duplicate: Dictionary = candidate.data["connections"][1]
	reverse_duplicate["from"] = "nexus-commons"
	reverse_duplicate["to"] = "conservatory-gardens"
	reverse_duplicate["points"] = [[1020, 720], [880, 720]]
	check(not candidate.validate(), "duplicate bridge count cannot hide a disconnected district")
	check("connected district graph" in candidate.last_error, "disconnected district failure is actionable")


func _test_custom_world_identity() -> void:
	var layout := SanctumCampusLayout.new()
	check(layout.load_from_file(CAMPUS_PATH), "campus loads for world identity")
	var campus_world := SimWorld.new(120, 99, layout.build_collision_world(), String(layout.data.get("id")), layout.content_hash)
	var foundation_world := SimWorld.new(120, 99)
	equal(campus_world.map_id, "sanctum-campus-g2-v1", "world owns the authored map id")
	equal(campus_world.map_hash, layout.content_hash, "world owns the authored map hash")
	check(campus_world.state_hash() != foundation_world.state_hash(), "authored map identity changes canonical world state")
