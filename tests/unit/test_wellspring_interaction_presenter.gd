extends FluxTestSuite


func run() -> int:
	_test_repository_interaction_language()
	_test_prompt_copy_and_safe_area()
	_test_fail_closed_station_coverage()
	return finish("wellspring-interaction-presenter")


func _test_repository_interaction_language() -> void:
	var language := VisualLanguage.new()
	check(language.load_from_file(), "visual language loads for interaction presentation")
	var campus := SanctumCampusLayout.new()
	check(campus.load_from_file("res://content/maps/sanctum_campus_g2_v1.json"), "campus loads for interaction presentation")
	var presenter := WellspringInteractionPresenter.new()
	check(presenter.configure(language, campus), "Wellspring interaction language validates: %s" % presenter.last_error)
	equal(presenter.styles_by_kind.size(), 10, "every live station kind has one interaction style")
	equal(presenter.content_hash.length(), 64, "interaction presentation has a stable content hash")
	for station: Dictionary in campus.stations_by_id.values():
		check(presenter.styles_by_kind.has(String(station.get("kind", ""))), "%s has a validated prompt style" % String(station.get("id", "station")))


func _test_prompt_copy_and_safe_area() -> void:
	equal(WellspringInteractionPresenter.station_action_text({"prompt": "F  STUDY THE ROUTES"}), "Study The Routes", "compact prompt removes the stale hard-coded key")
	equal(WellspringInteractionPresenter.localized_interaction_line("F closes this field note", "Q"), "Q closes this field note", "expanded guidance follows the live interaction binding")
	equal(WellspringInteractionPresenter.localized_interaction_line("Everyone readies", "Q"), "Everyone readies", "non-input guidance stays unchanged")
	var clamped := WellspringInteractionPresenter.clamped_panel_rect(Rect2(-80, -40, 232, 52), Vector2(1280, 720), 16, 126)
	equal(clamped.position, Vector2(16, 58), "world prompt clamps below the compact top HUD")
	var lower := WellspringInteractionPresenter.clamped_panel_rect(Rect2(1200, 690, 232, 52), Vector2(1280, 720), 16, 126)
	equal(lower.position, Vector2(1032, 542), "world prompt clamps clear of bottom combat HUD lanes")


func _test_fail_closed_station_coverage() -> void:
	var language := VisualLanguage.new()
	check(language.load_from_file(), "visual language loads before interaction mutation")
	var campus := SanctumCampusLayout.new()
	check(campus.load_from_file("res://content/maps/sanctum_campus_g2_v1.json"), "campus loads before interaction mutation")
	var source := WellspringInteractionPresenter.new()
	check(source.configure(language, campus), "valid interaction presentation loads before mutation")
	var presenter := WellspringInteractionPresenter.new()
	presenter.language = language
	presenter.data = source.data.duplicate(true)
	(presenter.data["station_styles"] as Array).remove_at(0)
	check(not presenter.validate(campus), "missing station visual fails closed")
	check(not presenter.last_error.is_empty(), "interaction failure is actionable")
	presenter.data = source.data.duplicate(true)
	((presenter.data["station_styles"] as Array)[1] as Dictionary)["kind"] = String(((presenter.data["station_styles"] as Array)[0] as Dictionary)["kind"])
	check(not presenter.validate(campus), "duplicate station style fails closed")
