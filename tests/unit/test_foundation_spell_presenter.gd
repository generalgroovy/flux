extends FluxTestSuite


func run() -> int:
	_test_repository_profiles()
	_test_fail_closed_catalog_alignment()
	return finish("foundation-spell-presenter")


func _test_repository_profiles() -> void:
	var language := VisualLanguage.new()
	check(language.load_from_file(), "visual language loads for spell presentation")
	var catalog := AbilityCatalog.new()
	check(catalog.load_from_file("res://content/abilities/foundation_abilities_v1.json"), "ability catalog loads for spell presentation")
	var presenter := FoundationSpellPresenter.new()
	check(presenter.configure(language, catalog), "foundation spell presentation validates: %s" % presenter.last_error)
	equal(presenter.profiles_by_id.size(), 5, "every playable foundation spell has one visual profile")
	equal(FoundationSpellPresenter.STARTUPS.size(), 5, "foundation spells own five distinct startup silhouettes")
	check(presenter.content_hash.length() == 64, "foundation spell presentation has a stable content hash")
	var observed_startups: Dictionary[String, bool] = {}
	for profile_id: String in FoundationSpellPresenter.REQUIRED_IDS:
		var profile: Dictionary = presenter.profiles_by_id[profile_id]
		var ability := catalog.ability(profile_id)
		equal(String(profile.get("shape")), String(ability.get("shape")), "%s visual shape matches simulation content" % profile_id)
		equal(String(profile.get("element")), String(ability.get("element")), "%s visual element matches simulation content" % profile_id)
		observed_startups[String(profile.get("startup"))] = true
	equal(observed_startups.size(), 5, "each live spell startup remains visually distinct")


func _test_fail_closed_catalog_alignment() -> void:
	var language := VisualLanguage.new()
	check(language.load_from_file(), "visual language loads before spell visual mutation")
	var catalog := AbilityCatalog.new()
	check(catalog.load_from_file("res://content/abilities/foundation_abilities_v1.json"), "ability catalog loads before spell visual mutation")
	var source := FoundationSpellPresenter.new()
	check(source.configure(language, catalog), "valid spell presentation loads before mutation")
	var presenter := FoundationSpellPresenter.new()
	presenter.language = language
	presenter.data = source.data.duplicate(true)
	((presenter.data["profiles"] as Array)[0] as Dictionary)["shape"] = "beam"
	check(not presenter.validate(catalog), "visual profile cannot contradict authoritative ability shape")
	check(not presenter.last_error.is_empty(), "spell visual refusal is actionable")
	presenter.data = source.data.duplicate(true)
	((presenter.data["profiles"] as Array)[1] as Dictionary)["startup"] = String(((presenter.data["profiles"] as Array)[0] as Dictionary)["startup"])
	check(not presenter.validate(catalog), "two spells cannot collapse onto one startup silhouette")
