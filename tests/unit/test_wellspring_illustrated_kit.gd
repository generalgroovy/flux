extends FluxTestSuite


func run() -> int:
	var layout := SanctumCampusLayout.new()
	check(layout.load_from_file("res://content/maps/sanctum_campus_g2_v1.json"), "illustrated campus uses the live gameplay layout")
	var original := CanonicalContent.sha256(layout.data)
	var kit := WellspringIllustratedKit.new()
	check(not kit.configure(null), "illustrated campus refuses missing geometry")
	check(kit.configure(layout), "illustrated campus validates: " + kit.last_error)
	check(kit.content_hash.length() == 64, "presentation has a bounded content identity")
	equal(kit.ground.get_size(), Vector2(3072, 1728), "terrain matches the authoritative map envelope")
	equal(kit.cached_terrain_builds, 1, "terrain is composed once at setup")
	equal(kit.tiles.size(), 16, "sixteen reusable material tiles load")
	equal(kit.PROP_IDS.size(), 16, "sixteen reusable props load")
	check(kit.decorations.size() > 20 and kit.decorations.size() <= 340, "gardens are populated within the fixed decoration budget")
	equal(String(kit.data["camera"]["ground_axes"]), "screen_cardinal", "painted elevation never skews input or aim")
	equal(int(kit.data["camera"]["art_elevation_degrees"]), 55, "characters and environment share the elevated art camera")
	check(int(kit.data["camera"]["maximum_facade_pixels"]) <= 64, "facades cannot steal large sections of play space")
	var building := Rect2(100, 100, 200, 120)
	equal(kit.cover_opacity(building, Vector2(200, 90)), kit.cover_opacity(building, Vector2(90, 160)), "roof clearance is equal on cardinal approaches")
	check(is_equal_approx(kit.cover_opacity(building, Vector2(200, 100)), 0.30), "near roof reveals the player without a schematic replacement panel")
	check(is_equal_approx(kit.cover_opacity(building, Vector2(200, 72)), 0.65), "roof fade changes continuously across the approach band")
	equal(kit.cover_opacity(building, Vector2(200, 0)), 1.0, "distant architecture remains fully visible")
	check(kit.surface_at(Vector2(1536, 900)) in [0, 1], "source court reads as stone")
	equal(kit.surface_at(Vector2(10, 10)), 8, "outer shore reads as water")
	for decoration: Dictionary in kit.decorations:
		check(not kit._near_service_or_building(decoration["point"]), "plant placement preserves service and collision approaches")
	# Transparent borders prohibit paper/checkerboard backing in live cutouts.
	var props := kit.props.get_image()
	for index: int in range(16):
		var cell := props.get_region(Rect2i(index % 4 * 128, index / 4 * 128, 128, 128))
		check(cell.get_pixel(0, 0).a == 0 and cell.get_pixel(127, 127).a == 0, "prop %d has transparent cell corners" % index)
		check(cell.get_used_rect().get_area() > 100, "prop %d contains real artwork" % index)
		var occupied := 0
		for y: int in range(128):
			for x: int in range(128):
				if cell.get_pixel(x, y).a > 0.5:
					occupied += 1
		check(occupied < 128 * 128 * 0.78, "prop %d contains a cutout, not an opaque preview card" % index)
	equal(CanonicalContent.sha256(layout.data), original, "terrain preparation never mutates gameplay content")
	equal(kit.cached_terrain_builds, 1, "inspection does not rebuild the floor")
	print("ILLUSTRATED_SETUP: %d ms; %d props; one terrain texture" % [kit.ground_generation_ms, kit.decorations.size()])
	return finish("wellspring-illustrated-kit")
