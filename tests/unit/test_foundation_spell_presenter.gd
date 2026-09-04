extends FluxTestSuite


func run() -> int:
	_test_repository_profiles()
	_test_shared_direction_contract()
	_test_startup_readability_geometry()
	_test_projectile_presentation_motion()
	_test_fail_closed_catalog_alignment()
	return finish("foundation-spell-presenter")


func _test_repository_profiles() -> void:
	var language := VisualLanguage.new()
	check(language.load_from_file(), "visual language loads for spell presentation")
	var catalog := AbilityCatalog.new()
	check(catalog.load_from_file("res://content/abilities/foundation_abilities_v1.json"), "ability catalog loads for spell presentation")
	var presenter := FoundationSpellPresenter.new()
	check(presenter.configure(language, catalog), "foundation spell presentation validates: %s" % presenter.last_error)
	equal(presenter.profiles_by_id.size(), 41, "every runtime spell has an authored or reusable family visual profile")
	equal(presenter.profiles_by_wire.size(), catalog.runtime_wire_ids.size(), "no runtime spell can fall through to invisible presentation")
	equal(presenter.animation_skeletons.skeletons.size(), 4, "foundation spells share four reusable delivery skeletons")
	check(presenter.animation_skeleton_hash.length() == 64, "foundation spell presentation exposes the skeleton content hash")
	check(presenter.direction_contract_hash.length() == 64, "foundation spell presentation exposes the shared direction content hash")
	equal(String(presenter.animation_skeletons.phase_for("projectile", 0.10).get("cue", "")), "origin_ring", "projectile startup exposes the shared hand-gather cue")
	equal(String(presenter.animation_skeletons.phase_for("projectile", 0.25).get("cue", "")), "release_flash", "projectile release exposes the shared forward-snap cue")
	equal(FoundationSpellPresenter.STARTUPS.size(), 7, "foundation spells own seven delivery-readable startup silhouettes")
	check(presenter.content_hash.length() == 64, "foundation spell presentation has a stable content hash")
	var observed_startups: Dictionary[String, bool] = {}
	for profile_id: String in FoundationSpellPresenter.REQUIRED_IDS:
		var profile: Dictionary = presenter.profiles_by_id[profile_id]
		var ability := catalog.ability(profile_id)
		equal(String(profile.get("shape")), String(ability.get("shape")), "%s visual shape matches simulation content" % profile_id)
		equal(String(profile.get("element")), String(ability.get("element")), "%s visual element matches simulation content" % profile_id)
		equal(String((presenter.animation_skeletons.skeletons[String(profile.get("skeleton_id", ""))] as Dictionary).get("shape", "")), String(profile.get("shape", "")), "%s uses the matching delivery skeleton" % profile_id)
		observed_startups[String(profile.get("startup"))] = true
	equal(observed_startups.size(), 7, "Burst variants share one shape-first startup while other deliveries stay distinct")
	for burst_id: String in FoundationSpellPresenter.BURST_IDS:
		var burst_profile: Dictionary = presenter.profiles_by_id[burst_id]
		equal(String(burst_profile.get("startup", "")), "elemental_burst", "%s reuses the same five-lane startup geometry" % burst_id)
		equal(String(burst_profile.get("silhouette", "")), "burst_mote", "%s reuses the same Burst silhouette contract" % burst_id)
	for wire_id: int in catalog.runtime_wire_ids:
		check(presenter.profiles_by_wire.has(wire_id), "runtime wire %d has a presentation profile" % wire_id)
	var generated: Dictionary = presenter.profiles_by_id["flintshot"]
	equal(String(generated.get("generated_from_family", "")), "bolt", "new spells reuse their attack-family presentation skeleton")
	equal(String(generated.get("element", "")), "earth", "reused family visuals retain distinct element coding")


func _test_shared_direction_contract() -> void:
	var contract := SpellDeliveryDirectionContract.new()
	check(contract.load_from_file(), "shared spell direction contract validates: %s" % contract.last_error)
	equal(contract.data.get("direction_order", []), EightDirectionResolver.DIRECTION_ORDER, "spell delivery uses the canonical S/SE/E/NE/N/NW/W/SW order")
	var cases := [
		{"vector": Vector2(0, 1000), "id": "south"},
		{"vector": Vector2(707, 707), "id": "south_east"},
		{"vector": Vector2(1000, 0), "id": "east"},
		{"vector": Vector2(707, -707), "id": "north_east"},
		{"vector": Vector2(0, -1000), "id": "north"},
		{"vector": Vector2(-707, -707), "id": "north_west"},
		{"vector": Vector2(-1000, 0), "id": "west"},
		{"vector": Vector2(-707, 707), "id": "south_west"},
	]
	for case: Dictionary in cases:
		var vector: Vector2 = case["vector"]
		equal(SpellDeliveryDirectionContract.direction_id(vector), case["id"], "spell delivery classifies %s deterministically" % case["id"])
		var expected_fixed := EightDirectionResolver.fixed_vector(String(case["id"]))
		var expected := Vector2(expected_fixed.x, expected_fixed.y).normalized()
		check(SpellDeliveryDirectionContract.visual_vector(vector).is_equal_approx(expected), "spell delivery exposes the fixed %s visual vector" % case["id"])
	equal(SpellDeliveryDirectionContract.direction_id(Vector2.ZERO), "south", "zero spell aim fails safe to south")
	check(SpellDeliveryDirectionContract.visual_vector(Vector2.ZERO).is_equal_approx(Vector2.DOWN), "zero spell aim exposes a stable down visual vector")
	equal(SpellDeliveryDirectionContract.direction_id(Vector2(0.001, -0.001)), "north_east", "small non-zero continuous aim keeps its diagonal sector")
	var invalid := SpellDeliveryDirectionContract.new()
	invalid.data = contract.data.duplicate(true)
	invalid.data["zero_vector_fallback"] = "east"
	check(not invalid.validate(), "non-canonical spell direction fallback fails closed")
	check(not invalid.last_error.is_empty(), "spell direction contract refusal is actionable")


func _test_startup_readability_geometry() -> void:
	for direction_id: String in EightDirectionResolver.DIRECTION_ORDER:
		var fixed := EightDirectionResolver.fixed_vector(direction_id)
		var geometry := FoundationSpellPresenter.startup_readability_geometry(Vector2(fixed.x, fixed.y), 0.5)
		var focus: Vector2 = geometry["focus"]
		var side: Vector2 = geometry["side"]
		check(focus.length() >= 10.0 and focus.length() <= 18.0, "%s startup focus remains in the bounded hand lane" % direction_id)
		check(absf(focus.normalized().dot(side)) < 0.001, "%s startup brace remains perpendicular to release" % direction_id)
		equal(float(geometry.get("half_width", 0.0)), 5.25, "%s startup fork uses the same color-independent width" % direction_id)
	var fallback := FoundationSpellPresenter.startup_readability_geometry(Vector2.ZERO, -2.0)
	check((fallback["focus"] as Vector2).normalized().is_equal_approx(Vector2.DOWN), "zero aim startup fails safe to south")
	equal(float(fallback.get("half_width", 0.0)), 6.0, "startup progress clamps before geometry is emitted")


func _test_projectile_presentation_motion() -> void:
	var projectile := ProjectileState.new(7, 1, 1, 146, 2, Vector2i(200_000, 80_000), Vector2i(700_000, 0), 8_000, 4_000, 120)
	projectile.previous_x = 100_000
	projectile.previous_y = 40_000
	equal(ProjectilePresentationMotion.interpolated_position(projectile, -1.0), Vector2(100.0, 40.0), "projectile interpolation clamps to the previous authoritative sample")
	equal(ProjectilePresentationMotion.interpolated_position(projectile, 0.5), Vector2(150.0, 60.0), "projectile interpolation fills the visual half-step smoothly")
	equal(ProjectilePresentationMotion.interpolated_position(projectile, 2.0), Vector2(200.0, 80.0), "projectile interpolation clamps to the current authoritative sample")
	check(ProjectilePresentationMotion.travel_direction(projectile).is_equal_approx(Vector2.RIGHT), "projectile direction remains stable from canonical velocity")
	var full_trail := ProjectilePresentationMotion.trail_length(projectile, false)
	check(full_trail > 18.0 and full_trail < 19.0, "readable projectile owns a bounded continuous motion trail")
	check(ProjectilePresentationMotion.trail_length(projectile, true) < full_trail, "reduced effects shortens rather than removes the readability trail")
	equal(ProjectilePresentationMotion.visual_diameter(projectile), 28.0, "projectile art remains larger than its collision core at gameplay zoom")
	equal(ProjectilePresentationMotion.leading_point(projectile), Vector2(11.0, 0.0), "projectile leading point exposes travel without relying on color")
	var large_projectile := ProjectileState.new(8, 1, 1, 142, 8, Vector2i.ZERO, Vector2i(780_000, 0), 20_000, 4_000, 120)
	equal(ProjectilePresentationMotion.visual_diameter(large_projectile), 46.0, "projectile art diameter stays inside the presentation budget")


func _test_fail_closed_catalog_alignment() -> void:
	var language := VisualLanguage.new()
	check(language.load_from_file(), "visual language loads before spell visual mutation")
	var catalog := AbilityCatalog.new()
	check(catalog.load_from_file("res://content/abilities/foundation_abilities_v1.json"), "ability catalog loads before spell visual mutation")
	var source := FoundationSpellPresenter.new()
	check(source.configure(language, catalog), "valid spell presentation loads before mutation")
	var presenter := FoundationSpellPresenter.new()
	presenter.language = language
	presenter.direction_contract = source.direction_contract
	presenter.animation_skeletons = source.animation_skeletons
	presenter.data = source.data.duplicate(true)
	((presenter.data["profiles"] as Array)[0] as Dictionary)["shape"] = "beam"
	check(not presenter.validate(catalog), "visual profile cannot contradict authoritative ability shape")
	check(not presenter.last_error.is_empty(), "spell visual refusal is actionable")
	presenter.data = source.data.duplicate(true)
	((presenter.data["profiles"] as Array)[1] as Dictionary)["startup"] = String(((presenter.data["profiles"] as Array)[0] as Dictionary)["startup"])
	check(not presenter.validate(catalog), "two spells cannot collapse onto one startup silhouette")
	presenter.data = source.data.duplicate(true)
	((presenter.data["profiles"] as Array)[0] as Dictionary)["skeleton_id"] = "beam"
	check(not presenter.validate(catalog), "spell delivery cannot use a mismatched animation skeleton")
