extends FluxTestSuite


func run() -> int:
	_test_repository_kit()
	_test_live_coverage()
	_test_renderer_binding()
	_test_fail_closed_contract()
	return finish("wellspring-architecture-kit")


func _test_repository_kit() -> void:
	var language := VisualLanguage.new()
	check(language.load_from_file(), "visual language loads for architecture kit")
	var layout := SanctumCampusLayout.new()
	check(layout.load_from_file("res://content/maps/sanctum_campus_g2_v1.json"), "campus loads for architecture kit")
	var kit := WellspringArchitectureKit.new()
	check(kit.configure(language, layout), "architecture kit validates: %s" % kit.last_error)
	check(kit.content_hash.length() == 64, "architecture kit has a stable content hash")
	check(kit.runtime_kit != null and kit.runtime_kit.textures_by_id.size() == 8, "architecture reuses every approved pixel module through the validated runtime kit")
	equal(String((kit.data["court_profile"] as Dictionary).get("district_style")), "nexus", "source court is bound to the Nexus presentation profile")
	equal(kit.building_profiles.size(), WellspringArchitectureKit.BUILDING_STYLES.size(), "every architecture style has one reusable profile")
	equal(kit.station_profiles.size(), WellspringArchitectureKit.STATION_KINDS.size(), "every station kind has one furniture profile")
	equal(kit.landmark_profiles.size(), WellspringArchitectureKit.LANDMARK_KINDS.size(), "every landmark kind has one frame profile")


func _test_live_coverage() -> void:
	var language := VisualLanguage.new()
	check(language.load_from_file(), "visual language loads for live architecture coverage")
	var layout := SanctumCampusLayout.new()
	check(layout.load_from_file("res://content/maps/sanctum_campus_g2_v1.json"), "campus loads for live architecture coverage")
	var kit := WellspringArchitectureKit.new()
	check(kit.configure(language, layout), "architecture kit loads for live coverage")
	for building: Dictionary in layout.buildings_by_id.values():
		var style := String(building.get("style", ""))
		check(style == "vault_rail" or kit.building_profiles.has(style), "live building style %s has modular art" % style)
	for station: Dictionary in layout.stations_by_id.values():
		var kind := String(station.get("kind", ""))
		check(kit.station_profiles.has(kind), "live station kind %s has furniture" % kind)
	for landmark: Dictionary in layout.landmarks_by_id.values():
		var kind := String(landmark.get("kind", ""))
		check(kit.landmark_profiles.has(kind), "live landmark kind %s has a frame" % kind)


func _test_renderer_binding() -> void:
	var language := VisualLanguage.new()
	check(language.load_from_file(), "visual language loads for campus renderer binding")
	var layout := SanctumCampusLayout.new()
	check(layout.load_from_file("res://content/maps/sanctum_campus_g2_v1.json"), "campus loads for renderer binding")
	var renderer := SanctumCampusRenderer.new()
	check(renderer.configure(language), "campus renderer accepts the visual language")
	check(renderer.configure_campus(layout), "campus renderer binds architecture and wayfinding together")
	check(renderer.architecture_kit.content_hash.length() == 64, "renderer exposes the bound architecture identity")
	check(renderer.wayfinding.content_hash.length() == 64, "renderer keeps the bound wayfinding identity")


func _test_fail_closed_contract() -> void:
	var language := VisualLanguage.new()
	check(language.load_from_file(), "visual language loads before architecture mutation")
	var layout := SanctumCampusLayout.new()
	check(layout.load_from_file("res://content/maps/sanctum_campus_g2_v1.json"), "campus loads before architecture mutation")
	var source := WellspringArchitectureKit.new()
	check(source.configure(language, layout), "valid architecture kit loads before mutation")
	var kit := WellspringArchitectureKit.new()
	kit.language = language
	kit.data = source.data.duplicate(true)
	(kit.data["budgets"] as Dictionary)["maximum_facade_ratio"] = 0.90
	check(not kit.validate(layout), "facades that can steal the play footprint fail closed")
	check(not kit.last_error.is_empty(), "architecture refusal is actionable")
