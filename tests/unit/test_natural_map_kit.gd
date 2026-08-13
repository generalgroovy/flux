extends FluxTestSuite


func run() -> int:
	_test_repository_kit()
	_test_surface_resolution()
	_test_fail_closed_budget()
	return finish("natural-map-kit")


func _test_repository_kit() -> void:
	var language := VisualLanguage.new()
	check(language.load_from_file(), "visual language loads for natural map kit")
	var kit := NaturalMapKit.new()
	check(kit.configure(language), "natural map kit validates: %s" % kit.last_error)
	check(kit.content_hash.length() == 64, "natural map kit has a stable content hash")
	equal(kit.profiles.size(), 3, "all live district styles own reusable natural recipes")
	for motion_id: String in ["walk", "sprint", "low", "air"]:
		check(kit.contact_profiles.has(motion_id), "%s has a surface-contact recipe" % motion_id)


func _test_surface_resolution() -> void:
	var language := VisualLanguage.new()
	check(language.load_from_file(), "visual language loads for surface test")
	var kit := NaturalMapKit.new()
	check(kit.configure(language), "natural map kit loads for surface test")
	var layout := SanctumCampusLayout.new()
	check(layout.load_from_file("res://content/maps/sanctum_campus_g2_v1.json"), "campus loads for surface test")
	equal(kit.surface_style_at(layout, Vector2(300, 720)), "garden", "conservatory resolves garden contact")
	equal(kit.surface_style_at(layout, Vector2(1280, 720)), "nexus", "commons resolves masonry contact")
	equal(kit.surface_style_at(layout, Vector2(2200, 720)), "proving", "wayfarer quarter resolves proving contact")
	equal(kit.surface_style_at(layout, Vector2(10, 10)), "nexus", "water/outside fails to conservative quiet contact")
	var open_path := PackedVector2Array([Vector2(0, 0), Vector2(20, 20), Vector2(40, 0)])
	var smoothed := NaturalMapKit.smoothed_path(open_path, 2)
	equal(smoothed[0], open_path[0], "smoothed route preserves its authored start")
	equal(smoothed[smoothed.size() - 1], open_path[open_path.size() - 1], "smoothed route preserves its authored finish")
	check(smoothed.size() > open_path.size(), "smoothed route adds bounded curve samples")


func _test_fail_closed_budget() -> void:
	var language := VisualLanguage.new()
	check(language.load_from_file(), "visual language loads for invalid kit test")
	var source := NaturalMapKit.new()
	check(source.configure(language), "valid natural kit loads before mutation")
	var kit := NaturalMapKit.new()
	kit.language = language
	kit.data = source.data.duplicate(true)
	(kit.data["budgets"] as Dictionary)["maximum_details_per_district"] = 1000
	check(not kit.validate(), "unbounded map detail density fails closed")
	check(not kit.last_error.is_empty(), "natural map budget refusal is actionable")
