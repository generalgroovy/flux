extends FluxTestSuite


func run() -> int:
	_test_repository_language()
	_test_pixel_presentation()
	_test_live_renderer_binding()
	_test_fail_closed_contract()
	return finish("visual-language")


func _test_repository_language() -> void:
	var language := VisualLanguage.new()
	check(language.load_from_file(), "visual language loads: %s" % language.last_error)
	equal(language.ramps.size(), 11, "visual language exposes eleven material/UI ramps")
	equal(language.elements.size(), 12, "all twelve element shape languages are present")
	equal(language.layer_index.size(), 17, "ordered render layers are explicit")
	equal(language.layer_index["actor_shadow"] + 1, language.layer_index["actor"], "actor shadow renders immediately before actor")
	equal(language.layer_index["cutaway"] + 1, language.layer_index["world_prompt"], "world prompts render after cutaways")
	check(language.ramp_color("warm_stone", 4).get_luminance() > language.ramp_color("warm_stone", 0).get_luminance(), "warm-stone ramp orders values dark to light")
	check(language.element_color("water", "bright").get_luminance() > language.element_color("water", "dark").get_luminance(), "element family exposes readable value separation")
	equal(language.ui_metric("combat_hud_maximum_height"), 104, "combat HUD height budget is canonical")
	var perspective: Dictionary = language.data.get("perspective_contract", {})
	equal(String(perspective.get("projection")), "top_down_cardinal_with_tilted_facades", "perspective preserves cardinal-friendly floors")
	check(bool(perspective.get("forbid_diamond_grid")), "misleading diamond navigation is explicitly forbidden")
	var character: Dictionary = language.data.get("character_contract", {})
	check(VisualLanguage._numeric_array_equals(character.get("head_height_ratio"), [0.4, 0.45]), "cartoon champions reserve a large expressive head read")
	equal(character.get("required_silhouette_states"), ["south", "east", "north", "jump", "cast", "hit"], "gameplay silhouette review is bounded")
	check(language.content_hash().length() == 64, "visual language exposes a stable content hash")


func _test_pixel_presentation() -> void:
	var camera := Vector2(100.25, 80.75)
	for zoom_percent: int in PixelPresentation.SUPPORTED_ZOOM:
		var origin := PixelPresentation.snapped_canvas_origin(camera, zoom_percent)
		equal(origin, origin.round(), "%d%% camera translation lands on output pixels" % zoom_percent)
		var screen := PixelPresentation.world_to_screen(Vector2(240.25, 180.75), camera, zoom_percent)
		equal(screen, screen.round(), "%d%% world presentation lands on output pixels" % zoom_percent)
		var snapped_world := PixelPresentation.snapped_world_anchor(Vector2(240.25, 180.75), camera, zoom_percent)
		equal(PixelPresentation.world_to_screen(snapped_world, camera, zoom_percent), screen, "%d%% snapped world anchor preserves screen location" % zoom_percent)


func _test_live_renderer_binding() -> void:
	var language := VisualLanguage.new()
	check(language.load_from_file(), "visual language loads before renderer binding")
	var renderer := SanctumCampusRenderer.new()
	check(not renderer.configure(null), "live renderer refuses an absent visual language")
	check(renderer.configure(language), "live renderer binds the validated language")
	check(renderer.natural_kit != null and renderer.natural_kit.content_hash.length() == 64, "live renderer binds the reusable natural-map kit")
	equal(renderer.WATER, language.ramp_color("deep_water", 1), "live water derives from the shared ramp")
	equal(renderer.STONE, language.ramp_color("warm_stone", 2), "live stone derives from the shared ramp")
	equal(renderer.BRASS, language.ramp_color("aged_brass", 2), "live brass derives from the shared ramp")
	equal(renderer.CYAN, language.ui_color("focus"), "live affordance focus derives from the shared UI token")
	var footprint := Rect2(100.0, 100.0, 80.0, 64.0)
	equal(renderer.cutaway_amount(footprint, Vector2(20.0, 20.0)), 0.0, "distant architecture stays intact")
	equal(renderer.cutaway_amount(footprint, Vector2(140.0, 100.0)), 1.0, "near architecture cuts to its cardinal footprint")
	check(renderer.cutaway_amount(footprint, Vector2(140.0, 58.0)) > 0.0, "cutaway eases predictably at its outer boundary")
	equal(renderer.cutaway_amount(Rect2(), Vector2.ZERO), 0.0, "empty footprint cannot create a cutaway")


func _test_fail_closed_contract() -> void:
	var mutations: Array[Callable] = [
		func(data: Dictionary) -> void: data["authority"] = "presentation owns collision",
		func(data: Dictionary) -> void: (data["pixel_contract"] as Dictionary)["nearest_neighbor"] = false,
		func(data: Dictionary) -> void: (data["pixel_contract"] as Dictionary)["supported_camera_percent"] = [75],
		func(data: Dictionary) -> void: (data["perspective_contract"] as Dictionary)["projection"] = "diamond_isometric",
		func(data: Dictionary) -> void: (data["perspective_contract"] as Dictionary)["maximum_facade_rise_to_footprint_ratio"] = 1.4,
		func(data: Dictionary) -> void: (data["character_contract"] as Dictionary)["style"] = "realistic",
		func(data: Dictionary) -> void: (data["character_contract"] as Dictionary)["head_height_ratio"] = [0.2, 0.25],
		func(data: Dictionary) -> void: (data["layers"] as Array).reverse(),
		func(data: Dictionary) -> void: ((data["ramps"] as Dictionary)["warm_stone"] as Array).pop_back(),
		func(data: Dictionary) -> void: ((data["elements"] as Dictionary)["ice"] as Dictionary)["shape"] = ((data["elements"] as Dictionary)["water"] as Dictionary)["shape"],
		func(data: Dictionary) -> void: (data["ui"] as Dictionary)["panel_fill"] = "not-a-color",
		func(data: Dictionary) -> void: (data["budgets"] as Dictionary)["maximum_combat_hud_coverage_percent"] = 80,
		func(data: Dictionary) -> void: (data["rubric"] as Dictionary)["minimum_mean"] = 3.0,
		func(data: Dictionary) -> void: (data["rubric"] as Dictionary)["automatic_acceptance"] = true,
	]
	for mutation: Callable in mutations:
		var language := VisualLanguage.new()
		check(language.load_from_file(), "valid language loads before adversarial mutation")
		language.data = language.data.duplicate(true)
		mutation.call(language.data)
		check(not language.validate(), "unsafe visual-language mutation fails closed")
		check(not language.last_error.is_empty(), "visual-language refusal is actionable")
		equal(language.ramps, {}, "failed validation exposes no ramp state")
