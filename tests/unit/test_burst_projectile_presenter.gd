extends FluxTestSuite


func run() -> int:
	_test_repository_atlas()
	_test_direction_and_animation_contract()
	_test_fail_closed_mutations()
	return finish("burst-projectile-presenter")


func _configured(load_textures: bool = true) -> BurstProjectilePresenter:
	var language := VisualLanguage.new()
	check(language.load_from_file(), "visual language loads for burst atlas")
	var catalog := AbilityCatalog.new()
	check(catalog.load_from_file("res://content/abilities/foundation_abilities_v1.json"), "ability catalog loads for burst atlas")
	var presenter := BurstProjectilePresenter.new()
	check(presenter.configure(language, catalog, BurstProjectilePresenter.DEFAULT_PATH, load_textures), "burst atlas validates: %s" % presenter.last_error)
	return presenter


func _test_repository_atlas() -> void:
	var presenter := _configured()
	equal(presenter.entries_by_element.size(), 9, "neutral plus first eight elements have runtime sheets")
	equal(presenter.textures_by_element.size(), 9, "all burst sheets import as textures")
	check(presenter.content_hash.length() == 64, "burst manifest owns a stable content hash")
	for element: String in BurstProjectilePresenter.REQUIRED_ELEMENTS:
		check(presenter.entry(element).has("sha256"), "burst sheet has provenance hash: %s" % element)
		check(presenter.texture(element) != null, "burst sheet texture is available: %s" % element)


func _test_direction_and_animation_contract() -> void:
	var velocities := [Vector2.UP, Vector2(1, -1), Vector2.RIGHT, Vector2(1, 1), Vector2.DOWN, Vector2(-1, 1), Vector2.LEFT, Vector2(-1, -1)]
	for index: int in range(velocities.size()):
		equal(BurstProjectilePresenter.direction_index(velocities[index]), index, "nearest-eight orientation keeps canonical row %d" % index)
	equal(BurstProjectilePresenter.direction_index(Vector2.ZERO), 2, "stationary fallback faces east")
	for projectile_id: int in range(6):
		var column := BurstProjectilePresenter.travel_column(0, projectile_id, false)
		check(column >= 2 and column <= 7, "normal travel frame stays inside authored phase")
		var reduced_column := BurstProjectilePresenter.travel_column(120, projectile_id, true)
		check(reduced_column >= 2 and reduced_column <= 7, "reduced travel frame stays inside authored phase")


func _test_fail_closed_mutations() -> void:
	var source := _configured(false)
	var mutations: Array[Callable] = [
		func(data: Dictionary) -> void: data["runtime_approved"] = false,
		func(data: Dictionary) -> void: data["release_approved"] = true,
		func(data: Dictionary) -> void: data["authority"] = "collision",
		func(data: Dictionary) -> void: (data["provenance"] as Dictionary)["third_party_pixel_inputs"] = true,
		func(data: Dictionary) -> void: (data["contract"] as Dictionary)["pivot"] = [0, 0],
		func(data: Dictionary) -> void: (data["contract"] as Dictionary)["simulation_aim"] = "eight-direction",
		func(data: Dictionary) -> void: (data["assets"][0] as Dictionary)["element"] = "fire",
		func(data: Dictionary) -> void: (data["assets"][0] as Dictionary)["sha256"] = "0".repeat(64),
		func(data: Dictionary) -> void: (data["budgets"] as Dictionary)["maximum_decoded_rgba_bytes"] = 1,
	]
	for mutation: Callable in mutations:
		var presenter := BurstProjectilePresenter.new()
		presenter.language = source.language
		presenter.catalog = source.catalog
		presenter.data = source.data.duplicate(true)
		mutation.call(presenter.data)
		check(not presenter.validate(false), "invalid burst atlas mutation fails closed")
		check(not presenter.last_error.is_empty(), "invalid burst atlas mutation explains refusal")
