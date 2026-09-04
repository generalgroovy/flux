class_name WellspringIllustratedKit
extends RefCounted

# One cached terrain texture plus shared object atlases. Map data remains the
# only authority for walkability, walls, targets and station commands.
const PATH := "res://content/visual/wellspring_illustrated_v1.json"
const PROP_IDS := ["oak", "small_tree", "flowers", "ferns", "wall_horizontal", "wall_vertical", "rocks", "planter", "fountain", "lectern", "target", "bell", "doorway", "bench", "lantern", "banner"]
var data: Dictionary = {}
var content_hash := ""
var last_error := ""
var ground: Texture2D
var surfaces: Texture2D
var props: Texture2D
var tiles: Array[Image] = []
var water_tiles: Array[Image] = []
var paths: Array[Dictionary] = []
var decorations: Array[Dictionary] = []
var campus: SanctumCampusLayout
var cached_terrain_builds := 0
var ground_generation_ms := 0


func configure(layout: SanctumCampusLayout, path: String = PATH) -> bool:
	last_error = ""
	ground = null
	tiles.clear()
	water_tiles.clear()
	paths.clear()
	decorations.clear()
	if layout == null or not FileAccess.file_exists(path):
		return _fail("Illustrated campus requires a layout and manifest")
	var source := FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(source)
	if not parsed is Dictionary:
		return _fail("Illustrated manifest must be an object")
	data = parsed
	if int(data.get("schema_version", 0)) != 1 or String(data.get("authority", "")) != "presentation_only":
		return _fail("Illustrated manifest cannot own gameplay")
	var camera: Dictionary = data.get("camera", {})
	var terrain: Dictionary = data.get("terrain", {})
	if String(camera.get("ground_axes", "")) != "screen_cardinal" or int(camera.get("art_elevation_degrees", 0)) != 55 or int(camera.get("maximum_facade_pixels", 0)) not in range(16, 65) or int(camera.get("canopy_clearance", 0)) not in range(64, 161):
		return _fail("Camera art must preserve readable cardinal navigation")
	if int(terrain.get("cell_pixels", 0)) != 32 or int(terrain.get("texture_cell_pixels", 0)) != 128 or int(terrain.get("maximum_decorations", 0)) not in range(1, 401):
		return _fail("Illustrated terrain budget is invalid")
	if data.get("prop_order", []) != PROP_IDS:
		return _fail("Illustrated prop order is invalid")
	surfaces = load(String(data.get("surfaces", ""))) as Texture2D
	props = load(String(data.get("props", ""))) as Texture2D
	if surfaces == null or props == null or surfaces.get_size() != Vector2(512, 512) or props.get_size() != Vector2(512, 512):
		return _fail("Illustrated atlases must be two 512px sheets")
	for key: String in ["surfaces", "props"]:
		var texture: Texture2D = surfaces if key == "surfaces" else props
		var pixels := texture.get_image()
		pixels.convert(Image.FORMAT_RGBA8)
		var hash := HashingContext.new()
		hash.start(HashingContext.HASH_SHA256)
		hash.update(pixels.get_data())
		if hash.finish().hex_encode() != String(data.get(key + "_rgba_sha256", "")):
			return _fail("Illustrated %s pixels differ from their manifest" % key)
	campus = layout
	var image := surfaces.get_image()
	image.convert(Image.FORMAT_RGBA8)
	for index: int in range(16):
		tiles.append(image.get_region(Rect2i(index % 4 * 128, index / 4 * 128, 128, 128)))
	# Mirror-repeat water without atlas-cell border ink or hard repeat seams.
	for variant: int in range(4):
		var water := tiles[8].get_region(Rect2i(4, 4, 120, 120))
		water.resize(128, 128, Image.INTERPOLATE_BILINEAR)
		if variant % 2 == 1:
			water.flip_x()
		if variant >= 2:
			water.flip_y()
		water_tiles.append(water)
	for value: Variant in (layout.data.get("routes", []) as Array) + (layout.data.get("connections", []) as Array):
		var definition: Dictionary = value
		var points := PackedVector2Array()
		for point: Array in definition["points"]:
			points.append(Vector2(point[0], point[1]))
		paths.append({"points": points, "width": float(definition["width"]), "advanced": String(definition.get("kind", "")) == "advanced"})
	var started := Time.get_ticks_msec()
	_compile_ground()
	_compile_decorations()
	ground_generation_ms = Time.get_ticks_msec() - started
	# Decoded pixel hashes also work in exported builds where PNGs are remapped.
	content_hash = (source + layout.content_hash).sha256_text()
	return true


func _compile_ground() -> void:
	var image := Image.create(campus.canvas_size.x, campus.canvas_size.y, false, Image.FORMAT_RGBA8)
	for y: int in range(0, campus.canvas_size.y, 32):
		for x: int in range(0, campus.canvas_size.x, 32):
			var material := surface_at(Vector2(x + 16, y + 16))
			var tile: Image = water_tiles[(x / 128) % 2 + ((y / 128) % 2) * 2] if material == 8 else tiles[material]
			image.blit_rect(tile, Rect2i(posmod(x, 128), posmod(y, 128), 32, 32), Vector2i(x, y))
	ground = ImageTexture.create_from_image(image)
	cached_terrain_builds += 1


func surface_at(point: Vector2) -> int:
	var cell := Vector2i(point / 32)
	var seed := absi(cell.x * 173 + cell.y * 389 + int(data["terrain"]["seed"]))
	# Presentation shoreline stays inside the existing map envelope. It grants
	# no new water collision or material behavior.
	var land := Rect2(64, 128, 2944, 1504)
	if not land.has_point(point):
		return 8
	var edge := minf(minf(point.x - land.position.x, land.end.x - point.x), minf(point.y - land.position.y, land.end.y - point.y))
	if edge < 28 + (seed % 3) * 8:
		return 14 if edge > 14 else 8
	var court := Rect2(1148, 568, 776, 568)
	if court.has_point(point):
		return 0
	for area: Dictionary in campus.data.get("activity_areas", []):
		if String(area["id"]) in ["pattern-range", "duel-court", "crucible"] and Rect2(SanctumCampusLayout._parse_bounds(area["bounds"])).grow(-16).has_point(point):
			return 2 if String(area["id"]) == "crucible" else 0
	for route: Dictionary in paths:
		var points: PackedVector2Array = route["points"]
		for index: int in range(points.size() - 1):
			var distance := point.distance_to(Geometry2D.get_closest_point_to_segment(point, points[index], points[index + 1]))
			if distance <= float(route["width"]) * 0.5:
				return 13 if bool(route["advanced"]) else (2 if distance > float(route["width"]) * 0.5 - 18 else 1)
	return 5 if seed % 5 == 0 else 4


func _compile_decorations() -> void:
	var maximum := int(data["terrain"]["maximum_decorations"])
	for y: int in range(190, 1610, 70):
		for x: int in range(105, 2980, 86):
			var seed := absi(x * 113 + y * 257 + int(data["terrain"]["seed"]))
			var point := Vector2(x + seed % 19 - 9, y + seed % 13 - 6)
			if decorations.size() >= maximum:
				return
			if surface_at(point) not in [4, 5, 14] or _near_service_or_building(point):
				continue
			var edge := x < 190 or x > 2870 or y < 240 or y > 1530
			if not edge and seed % 7 > 2:
				continue
			var kind := "oak" if edge and seed % 3 == 0 else ("small_tree" if edge else ("flowers" if seed % 2 == 0 else "ferns"))
			decorations.append({"kind": kind, "point": point, "size": 138.0 if kind == "oak" else (104.0 if kind == "small_tree" else 55.0)})
	decorations.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return (a["point"] as Vector2).y < (b["point"] as Vector2).y)


func _near_service_or_building(point: Vector2) -> bool:
	for building: Dictionary in campus.buildings_by_id.values():
		if Rect2(SanctumCampusLayout._parse_bounds(building["bounds"])).grow(50).has_point(point):
			return true
	for station: Dictionary in campus.stations_by_id.values():
		if point.distance_to(Vector2(station["position"][0], station["position"][1])) < 110:
			return true
	for target: Dictionary in campus.practice_targets_by_id.values():
		if point.distance_to(Vector2(target["position"][0], target["position"][1])) < 110:
			return true
	return false


func draw_ground(canvas: CanvasItem) -> void:
	canvas.draw_rect(Rect2(-4096, -4096, 12288, 12288), Color("103c45"))
	canvas.draw_texture(ground, Vector2.ZERO)


func draw_gardens(canvas: CanvasItem, focus: Vector2) -> void:
	for decoration: Dictionary in decorations:
		var point: Vector2 = decoration["point"]
		var alpha := cover_opacity(Rect2(point - Vector2(10, 10), Vector2(20, 20)), focus, float(data["camera"]["canopy_clearance"]))
		draw_prop(canvas, String(decoration["kind"]), point, float(decoration["size"]), Color(1, 1, 1, alpha))


func draw_prop(canvas: CanvasItem, kind: String, feet: Vector2, size: float, modulation: Color = Color.WHITE) -> void:
	var index := PROP_IDS.find(kind)
	if index < 0:
		return
	# A restrained ground contact ties every reusable cutout to the same plane.
	canvas.draw_line(feet - Vector2(size * 0.22, 1), feet + Vector2(size * 0.22, -1), Color(0.04, 0.07, 0.06, 0.20 * modulation.a), maxf(2, size * 0.06), true)
	canvas.draw_texture_rect_region(props, Rect2(feet - Vector2(size * 0.5, size * 124.0 / 128.0), Vector2(size, size)), Rect2(index % 4 * 128, index / 4 * 128, 128, 128), modulation)


func draw_surface(canvas: CanvasItem, bounds: Rect2, material: int, tint: Color = Color.WHITE) -> void:
	var origin := Vector2(material % 4 * 128, material / 4 * 128)
	for y: int in range(0, ceili(bounds.size.y), 128):
		for x: int in range(0, ceili(bounds.size.x), 128):
			var size := Vector2(minf(128, bounds.size.x - x), minf(128, bounds.size.y - y))
			canvas.draw_texture_rect_region(surfaces, Rect2(bounds.position + Vector2(x, y), size), Rect2(origin, size), tint)


func draw_building(canvas: CanvasItem, building: Dictionary, focus: Vector2) -> void:
	var bounds := Rect2(SanctumCampusLayout._parse_bounds(building["bounds"]))
	if String(building.get("style", "")) == "practice_wall":
		draw_surface(canvas, bounds, 14)
		canvas.draw_rect(Rect2(bounds.position, Vector2(bounds.size.x, 6)), Color("c0b28c"))
		canvas.draw_rect(bounds, Color("302d28"), false, 2)
		return
	var facade_height := minf(float(data["camera"]["maximum_facade_pixels"]), bounds.size.y * 0.42)
	var facade := Rect2(bounds.position.x, bounds.end.y - facade_height, bounds.size.x, facade_height)
	var roof := Rect2(bounds.position, Vector2(bounds.size.x, bounds.size.y - facade_height))
	canvas.draw_rect(Rect2(bounds.position + Vector2(5, 9), bounds.size), Color(0.06, 0.09, 0.07, 0.5))
	draw_surface(canvas, facade, 11)
	for x: int in range(int(bounds.position.x) + 8, int(bounds.end.x), 48):
		canvas.draw_rect(Rect2(x, facade.position.y, 5, facade.size.y), Color("493024"))
		if absf(x - bounds.get_center().x) > 50:
			canvas.draw_rect(Rect2(x + 15, facade.position.y + 12, 15, 21), Color("3d382d"))
			canvas.draw_rect(Rect2(x + 17, facade.position.y + 14, 11, 16), Color("b69754"))
	var fade := cover_opacity(bounds, focus)
	draw_surface(canvas, roof, 10, Color(1, 1, 1, fade))
	canvas.draw_rect(roof, Color(0.20, 0.15, 0.11, fade), false, 5)
	canvas.draw_line(roof.position + Vector2(0, roof.size.y * 0.32), roof.position + Vector2(roof.size.x, roof.size.y * 0.32), Color("aa8650"), 4)
	canvas.draw_line(Vector2(bounds.position.x, facade.position.y), Vector2(bounds.end.x, facade.position.y), Color("4b3025"), 6)
	draw_prop(canvas, "doorway", Vector2(bounds.get_center().x, bounds.end.y + 4), minf(110, bounds.size.y * 0.8))
	for side: float in [-1.0, 1.0]:
		draw_prop(canvas, "planter", Vector2(bounds.get_center().x + side * 82, bounds.end.y + 10), 45)
	canvas.draw_rect(bounds, Color(0.82, 0.71, 0.48, 0.3), false, 1)


static func cover_opacity(bounds: Rect2, focus: Vector2, clearance: float = 56.0) -> float:
	var nearest := focus.clamp(bounds.position, bounds.end)
	return lerpf(0.30, 1.0, clampf(focus.distance_to(nearest) / maxf(1.0, clearance), 0.0, 1.0))


func draw_landmark(canvas: CanvasItem, landmark: Dictionary, focus: Vector2 = Vector2(-1000000, -1000000)) -> void:
	var point := Vector2(landmark["position"][0], landmark["position"][1])
	var kind := String(landmark["kind"])
	if kind == "grand_fountain":
		for radius: int in [92, 104]:
			canvas.draw_arc(point, radius, 0, TAU, 64, Color("a28a59"), 3)
		var alpha := landmark_opacity(point, focus)
		draw_prop(canvas, "fountain", point + Vector2(0, 38), 154, Color(1, 1, 1, alpha))
	else:
		draw_prop(canvas, "banner" if kind == "portal_ring" else "lantern", point + Vector2(0, 14), 74)


static func landmark_opacity(point: Vector2, focus: Vector2) -> float:
	# Cosmetic landmark may overlap a legal route: reduce its visual density
	# around the player, never invent a collision obstacle to match the art.
	return cover_opacity(Rect2(point - Vector2(48, 84), Vector2(96, 122)), focus, 56)


func draw_station(canvas: CanvasItem, station: Dictionary) -> void:
	var point := Vector2(station["position"][0], station["position"][1])
	var kind := String(station["kind"])
	var prop := "bell" if kind in ["parting", "training"] else ("banner" if kind == "farflow" else "lectern")
	draw_prop(canvas, prop, point + Vector2(0, 14), 72)
	var title := String(station["title"])
	var font := ThemeDB.fallback_font
	var width := font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
	canvas.draw_rect(Rect2(point + Vector2(-width * 0.5 - 6, 20), Vector2(width + 12, 21)), Color(0.14, 0.13, 0.10, 0.82))
	canvas.draw_string(font, point + Vector2(-width * 0.5, 35), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("e9ddbc"))


func _fail(message: String) -> bool:
	last_error = message
	return false
