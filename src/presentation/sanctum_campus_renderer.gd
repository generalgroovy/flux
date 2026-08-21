class_name SanctumCampusRenderer
extends RefCounted


var WATER := Color("102f3b")
var WATER_LIGHT := Color("1f596a")
var WATER_GLINT := Color("3a7d87")
var DEEP_FOREST := Color("111d15")
var CLIFF := Color("25272a")
var CLIFF_LIGHT := Color("4f4a3f")
var STONE := Color("a6956c")
var STONE_LIGHT := Color("c8b883")
var PATH := Color("80643f")
var PATH_LIGHT := Color("a58555")
var GRASS := Color("2c4725")
var GRASS_LIGHT := Color("5f7d43")
var MOSS := Color("718c4c")
var TIMBER := Color("452d23")
var TIMBER_LIGHT := Color("76503a")
var ROOF_BLUE := Color("263b49")
var ROOF_VIOLET := Color("3d3150")
var ROOF_GREEN := Color("2d473a")
var ROOF_RUST := Color("57372d")
var BRASS := Color("b98336")
var BRASS_LIGHT := Color("d9ad55")
var PARCHMENT := Color("e4d8ae")
var CYAN := Color("51d5dc")
var VIOLET := Color("9461d4")
var FIRE := Color("df8335")
var PANEL := Color("11140ee8")
var language: VisualLanguage
var natural_kit: NaturalMapKit
var wayfinding: WellspringWayfinding
var architecture_kit: WellspringArchitectureKit


func configure(visual_language: VisualLanguage) -> bool:
	if visual_language == null or visual_language.ramps.is_empty():
		return false
	language = visual_language
	WATER = language.ramp_color("deep_water", 1)
	WATER_LIGHT = language.ramp_color("deep_water", 2)
	WATER_GLINT = language.ramp_color("deep_water", 4)
	DEEP_FOREST = language.ramp_color("garden", 0)
	CLIFF = language.ramp_color("worldbone", 1)
	CLIFF_LIGHT = language.ramp_color("worldbone", 3)
	STONE = language.ramp_color("warm_stone", 2)
	STONE_LIGHT = language.ramp_color("warm_stone", 4)
	PATH = language.ramp_color("warm_stone", 1)
	PATH_LIGHT = language.ramp_color("warm_stone", 3)
	GRASS = language.ramp_color("garden", 2)
	GRASS_LIGHT = language.ramp_color("garden", 3)
	MOSS = language.ramp_color("garden", 4)
	TIMBER = language.ramp_color("timber", 2)
	TIMBER_LIGHT = language.ramp_color("timber", 3)
	ROOF_BLUE = language.ramp_color("indigo_roof", 2)
	ROOF_VIOLET = language.element_color("dark", "dark")
	ROOF_GREEN = language.ramp_color("garden", 1)
	ROOF_RUST = language.ramp_color("timber", 3)
	BRASS = language.ramp_color("aged_brass", 2)
	BRASS_LIGHT = language.ramp_color("aged_brass", 4)
	PARCHMENT = language.ui_color("text_primary")
	CYAN = language.ui_color("focus")
	VIOLET = language.element_color("dark", "bright")
	FIRE = language.element_color("fire", "base")
	PANEL = language.ui_color("panel_fill")
	natural_kit = NaturalMapKit.new()
	if not natural_kit.configure(language):
		return false
	wayfinding = WellspringWayfinding.new()
	architecture_kit = WellspringArchitectureKit.new()
	return true


func configure_campus(layout: SanctumCampusLayout) -> bool:
	if wayfinding == null or architecture_kit == null:
		return false
	if not architecture_kit.configure(language, layout):
		return false
	return wayfinding.configure(language, layout)


func configure_wayfinding(layout: SanctumCampusLayout) -> bool:
	# Compatibility entry point for capture tools that predate the architecture kit.
	return configure_campus(layout)


func draw(
	canvas: CanvasItem,
	layout: SanctumCampusLayout,
	presentation_tick: int,
	focus_world_position: Vector2 = Vector2(-1000000.0, -1000000.0),
	reduced_effects: bool = false,
) -> void:
	_draw_water(canvas, layout.canvas_size, layout.reserved_ui_top, presentation_tick)
	_draw_distant_context(canvas)
	for connection_value: Variant in layout.data.get("connections", []):
		_draw_connection(canvas, connection_value as Dictionary)
	var district_index: int = 0
	for district_value: Variant in layout.data.get("districts", []):
		var district: Dictionary = district_value
		_draw_district(canvas, district, district_index)
		natural_kit.draw_district_details(canvas, district, district_index, presentation_tick, reduced_effects)
		_draw_district_identity(canvas, district, presentation_tick, reduced_effects)
		if architecture_kit != null:
			architecture_kit.draw_district_court(canvas, district, reduced_effects)
		district_index += 1
	for route_value: Variant in layout.data.get("routes", []):
		_draw_route(canvas, route_value as Dictionary)
	_draw_arena(canvas, layout.arena_definition)
	for building_value: Variant in layout.data.get("buildings", []):
		_draw_building(canvas, building_value as Dictionary, focus_world_position)
	for landmark_value: Variant in layout.data.get("landmarks", []):
		_draw_landmark(canvas, landmark_value as Dictionary, presentation_tick, reduced_effects)
	if wayfinding != null:
		wayfinding.draw(canvas, focus_world_position, presentation_tick, reduced_effects)
	for station_value: Variant in layout.data.get("stations", []):
		_draw_station(canvas, station_value as Dictionary, presentation_tick, reduced_effects)
	for district_value: Variant in layout.data.get("districts", []):
		_draw_district_label(canvas, district_value as Dictionary)


func _draw_arena(canvas: CanvasItem, definition: Dictionary) -> void:
	if definition.is_empty():
		return
	var bounds := SanctumCampusLayout._parse_bounds(definition.get("bounds", []))
	canvas.draw_rect(Rect2(bounds), Color(BRASS, 0.22), false, 4.0)
	canvas.draw_rect(Rect2(bounds.grow(-8)), Color(PARCHMENT, 0.16), false, 2.0)
	var court_label := "PROVING COURT · FIRST %d" % int(definition.get("score_limit", 0))
	var label_rect := Rect2(
		Vector2(bounds.position.x + (bounds.size.x - 218) / 2, bounds.position.y + 48),
		Vector2(218, 25),
	)
	canvas.draw_rect(label_rect, Color(PANEL, 0.76), true)
	canvas.draw_rect(label_rect, Color(BRASS, 0.5), false, 1.0)
	canvas.draw_string(ThemeDB.fallback_font, label_rect.position + Vector2(10, 17), court_label, HORIZONTAL_ALIGNMENT_LEFT, label_rect.size.x - 20.0, 12, PARCHMENT)
	for spawn_value: Variant in definition.get("spawns", []):
		var point_values: Array = spawn_value
		var point := Vector2(float(point_values[0]), float(point_values[1]))
		canvas.draw_circle(point, 14.0, Color(PANEL, 0.68))
		canvas.draw_arc(point, 14.0, 0.0, TAU, 16, Color(CYAN, 0.56), 2.0)
		canvas.draw_line(point + Vector2(-5, 0), point + Vector2(5, 0), Color(PARCHMENT, 0.48), 1.0)
		canvas.draw_line(point + Vector2(0, -5), point + Vector2(0, 5), Color(PARCHMENT, 0.48), 1.0)


func _draw_water(canvas: CanvasItem, size: Vector2i, _reserved_top: int, tick: int) -> void:
	# The reserved top band remains non-playable, but belongs visually to the
	# Wellspring now that the legacy full-width HUD has been removed.
	canvas.draw_rect(Rect2(0, 0, size.x, size.y), WATER, true)
	var phase: int = (tick / 8) % 64
	for y: int in range(14, size.y, 32):
		for x: int in range(-32, size.x + 32, 80):
			var glint_x: int = x + phase + ((y / 32) % 2) * 20
			canvas.draw_line(Vector2(glint_x, y), Vector2(glint_x + 12, y), Color(WATER_LIGHT, 0.64), 2.0)
			canvas.draw_line(Vector2(glint_x + 4, y + 4), Vector2(glint_x + 22, y + 4), Color(WATER_GLINT, 0.24), 1.0)
			canvas.draw_line(Vector2(glint_x + 12, y), Vector2(glint_x + 16, y - 2), Color(WATER_GLINT, 0.18), 1.0)


func _draw_distant_context(canvas: CanvasItem) -> void:
	for context: Rect2i in [
		Rect2i(-32, 124, 190, 72),
		Rect2i(1100, 110, 224, 58),
		Rect2i(-48, 644, 190, 92),
		Rect2i(1160, 630, 160, 106),
	]:
		var points := _stepped_rect(context)
		canvas.draw_colored_polygon(_offset_points(points, Vector2(0, 7)), Color(DEEP_FOREST, 0.9))
		canvas.draw_colored_polygon(points, Color(CLIFF, 0.92))
		var inner := context.grow(-8)
		canvas.draw_colored_polygon(_stepped_rect(inner), Color(GRASS, 0.68))
	for position: Vector2 in [Vector2(42, 152), Vector2(90, 166), Vector2(1180, 136), Vector2(1232, 142), Vector2(54, 676), Vector2(1208, 670)]:
		_draw_tree(canvas, position, 0.75)


func _draw_connection(canvas: CanvasItem, connection: Dictionary) -> void:
	var points := _packed_points(connection.get("points", []))
	var width: float = float(connection.get("width", 24))
	canvas.draw_polyline(points, Color(DEEP_FOREST, 0.9), width + 14.0, false)
	canvas.draw_polyline(points, CLIFF_LIGHT, width + 8.0, false)
	canvas.draw_polyline(points, PATH, width, false)
	canvas.draw_polyline(points, PATH_LIGHT, 3.0, false)
	var start: Vector2 = points[0]
	var finish: Vector2 = points[points.size() - 1]
	var direction: Vector2 = (finish - start).normalized()
	var side := Vector2(-direction.y, direction.x)
	canvas.draw_line(start + side * (width * 0.45), finish + side * (width * 0.45), BRASS, 2.0)
	canvas.draw_line(start - side * (width * 0.45), finish - side * (width * 0.45), BRASS, 2.0)


func _draw_district(canvas: CanvasItem, district: Dictionary, index: int) -> void:
	var bounds := SanctumCampusLayout._parse_bounds(district.get("bounds", []))
	var outer := _stepped_rect(bounds)
	canvas.draw_colored_polygon(_offset_points(outer, Vector2(0, 12)), Color(DEEP_FOREST, 0.96))
	canvas.draw_colored_polygon(outer, CLIFF)
	var rim_rect := bounds.grow(-7)
	canvas.draw_colored_polygon(_stepped_rect(rim_rect), CLIFF_LIGHT)
	var ground_rect := bounds.grow(-14)
	var style := String(district.get("style", "nexus"))
	var ground_color := _district_ground_color(style)
	canvas.draw_colored_polygon(_stepped_rect(ground_rect), ground_color)
	_draw_cardinal_floor(canvas, ground_rect, style, index)

	# Edge groves and ground variation come from the editable NaturalMapKit.


func _draw_cardinal_floor(canvas: CanvasItem, bounds: Rect2i, style: String, seed: int) -> void:
	# Square screen-cardinal cells communicate navigation. Lines stay under the
	# quiet-lane contrast budget and never become collision authority.
	var cell_size := 32
	var line_color := Color(STONE_LIGHT if style != "garden" else MOSS, 0.10)
	for x: int in range(bounds.position.x + cell_size, bounds.end.x, cell_size):
		canvas.draw_line(Vector2(x, bounds.position.y + 8), Vector2(x, bounds.end.y - 8), line_color, 1.0)
	for y: int in range(bounds.position.y + cell_size, bounds.end.y, cell_size):
		canvas.draw_line(Vector2(bounds.position.x + 8, y), Vector2(bounds.end.x - 8, y), line_color, 1.0)
	for y: int in range(bounds.position.y + 16, bounds.end.y - 8, 32):
		for x: int in range(bounds.position.x + 16, bounds.end.x - 8, 32):
			var selector := (x / 32 + y / 32 + seed) % 5
			if selector == 0:
				canvas.draw_rect(Rect2(x + 5, y + 5, 3, 2), Color(STONE_LIGHT, 0.15), true)
			elif selector == 3 and style == "garden":
				canvas.draw_rect(Rect2(x + 7, y + 4, 2, 3), Color(MOSS, 0.19), true)


func _draw_district_edge_garden(canvas: CanvasItem, bounds: Rect2i, index: int) -> void:
	for x: int in range(bounds.position.x + 24, bounds.end.x - 20, 42):
		if ((x / 42) + index) % 2 == 0:
			_draw_bush(canvas, Vector2(x, bounds.position.y + 9), 0.72)
		if ((x / 42) + index) % 3 == 0:
			_draw_bush(canvas, Vector2(x + 8, bounds.end.y - 8), 0.68)
	for y: int in range(bounds.position.y + 48, bounds.end.y - 30, 66):
		if ((y / 22) + index) % 2 == 0:
			_draw_tree(canvas, Vector2(bounds.position.x + 11, y), 0.62)
		else:
			_draw_tree(canvas, Vector2(bounds.end.x - 12, y), 0.62)


func _draw_district_identity(canvas: CanvasItem, district: Dictionary, tick: int, reduced_effects: bool) -> void:
	# These are low-contrast civic motifs, not tiles or collision. They let the
	# wide campus read as several intentional destinations before labels resolve.
	var bounds := SanctumCampusLayout._parse_bounds(district.get("bounds", []))
	var style := String(district.get("style", "nexus"))
	var anchor_values: Array = district.get("label_anchor", [])
	var anchor := Vector2(float(anchor_values[0]), float(anchor_values[1]))
	var shimmer := 0.0 if reduced_effects else sin(float(tick) * 0.035) * 0.04
	match style:
		"garden":
			var terrace := Rect2(bounds.position.x + 88, bounds.end.y - 194, 188, 54)
			canvas.draw_rect(terrace, Color(language.ramp_color("garden", 1), 0.33), true)
			canvas.draw_rect(terrace, Color(language.ramp_color("garden", 4), 0.34), false, 2.0)
			for index: int in range(5):
				var plot_center := terrace.position + Vector2(24 + index * 36, 27)
				canvas.draw_circle(plot_center, 10.0, Color(language.ramp_color("garden", 3), 0.44))
				canvas.draw_circle(plot_center + Vector2(0, -3), 4.0, Color(language.element_color("light", "bright"), 0.34 + shimmer))
			canvas.draw_line(Vector2(bounds.position.x + 170, bounds.position.y + 116), Vector2(bounds.position.x + 540, bounds.position.y + 116), Color(language.ramp_color("deep_water", 4), 0.20), 3.0)
		"nexus":
			var plaza_center := Vector2(bounds.get_center().x, bounds.get_center().y + 150)
			for radius: float in [92.0, 64.0, 34.0]:
				canvas.draw_arc(plaza_center, radius, 0.0, TAU, 32, Color(language.ramp_color("aged_brass", 3), 0.18 + shimmer), 2.0)
			for index: int in range(8):
				var direction := Vector2.from_angle(TAU * float(index) / 8.0)
				canvas.draw_line(plaza_center + direction * 38.0, plaza_center + direction * 88.0, Color(language.ramp_color("warm_stone", 4), 0.16), 2.0)
			canvas.draw_circle(anchor + Vector2(430, 720), 14.0, Color(language.ui_color("focus"), 0.12 + shimmer))
		"proving":
			var lane_start := Vector2(bounds.position.x + 112, bounds.position.y + 592)
			for index: int in range(4):
				var target_position := lane_start + Vector2(index * 104, 0)
				canvas.draw_circle(target_position, 16.0, Color(language.ramp_color("worldbone", 0), 0.42))
				canvas.draw_arc(target_position, 12.0, 0.0, TAU, 16, Color(language.element_color("fire", "bright"), 0.34 + shimmer), 2.0)
				canvas.draw_circle(target_position, 4.0, Color(language.element_color("charge", "bright"), 0.38))


func _draw_route(canvas: CanvasItem, route: Dictionary) -> void:
	var points := _packed_points(route.get("points", []))
	var width: float = float(route.get("width", 20))
	var kind := String(route.get("kind", "ordinary"))
	var route_color := PATH
	var edge_color := STONE
	if kind == "advanced":
		route_color = Color("5d5438")
		edge_color = BRASS
	elif kind == "garden":
		route_color = Color("6f6843")
		edge_color = MOSS
	points = NaturalMapKit.smoothed_path(points, 1 if kind == "ordinary" else 2)
	canvas.draw_polyline(points, Color(DEEP_FOREST, 0.7), width + 8.0, false)
	canvas.draw_polyline(points, edge_color, width + 4.0, false)
	canvas.draw_polyline(points, route_color, width, false)
	if kind == "advanced":
		canvas.draw_polyline(points, Color(BRASS_LIGHT, 0.7), 2.0, false)
	_draw_route_seams(canvas, points, width, kind)


func _draw_route_seams(canvas: CanvasItem, points: PackedVector2Array, width: float, kind: String) -> void:
	if points.size() < 2:
		return
	for segment_index: int in range(points.size() - 1):
		var start := points[segment_index]
		var finish := points[segment_index + 1]
		var delta := finish - start
		var length := delta.length()
		if length < 24.0:
			continue
		var direction := delta / length
		var side := Vector2(-direction.y, direction.x)
		var distance := 18.0
		while distance < length - 8.0:
			var center := start + direction * distance
			canvas.draw_line(center - side * width * 0.34, center + side * width * 0.34, Color(STONE_LIGHT if kind != "advanced" else BRASS_LIGHT, 0.16), 1.0)
			distance += 28.0


func _draw_building(canvas: CanvasItem, building: Dictionary, focus_world_position: Vector2) -> void:
	var bounds := SanctumCampusLayout._parse_bounds(building.get("bounds", []))
	var style := String(building.get("style", "timber_hall"))
	if style == "vault_rail":
		_draw_vault_rail(canvas, bounds)
		return
	var footprint := Rect2(bounds)
	if architecture_kit != null and architecture_kit.draw_building(canvas, building):
		_draw_building_cutaway(canvas, footprint, focus_world_position)
		return
	# Fail-soft fallback used only when a development capture bypasses campus setup.
	var roof_color := _roof_color(style)
	canvas.draw_rect(Rect2(footprint.position + Vector2(6, 8), footprint.size), Color(DEEP_FOREST, 0.82), true)
	# The full collision footprint remains visible below all decorative rise.
	canvas.draw_rect(footprint, language.ramp_color("worldbone", 2) if language != null else TIMBER, true)
	canvas.draw_rect(footprint, Color(STONE_LIGHT, 0.46), false, 2.0)
	var facade_height := clampi(int(round(float(bounds.size.y) * 0.36)), 24, 48)
	var facade := Rect2(bounds.position.x, bounds.end.y - facade_height, bounds.size.x, facade_height)
	canvas.draw_rect(facade, language.ramp_color("warm_stone", 1) if language != null else TIMBER, true)
	for x: int in range(bounds.position.x + 8, bounds.end.x - 4, 16):
		canvas.draw_line(Vector2(x, facade.position.y + 3), Vector2(x, facade.end.y - 2), Color(STONE, 0.20), 1.0)
	canvas.draw_line(facade.position + Vector2(0, 3), Vector2(facade.end.x, facade.position.y + 3), Color(STONE_LIGHT, 0.54), 2.0)
	var roof := PackedVector2Array([
		Vector2(bounds.position.x - 4, bounds.position.y + 14),
		Vector2(bounds.position.x + 10, bounds.position.y - 5),
		Vector2(bounds.end.x - 10, bounds.position.y - 5),
		Vector2(bounds.end.x + 4, bounds.position.y + 14),
		Vector2(bounds.end.x - 2, facade.position.y + 3),
		Vector2(bounds.position.x + 2, facade.position.y + 3),
	])
	canvas.draw_colored_polygon(roof, Color(roof_color, 0.98))
	canvas.draw_polyline(_closed(roof), BRASS.darkened(0.25), 2.0, false)
	for roof_y: int in range(bounds.position.y + 10, int(facade.position.y), 8):
		canvas.draw_line(Vector2(bounds.position.x + 5, roof_y), Vector2(bounds.end.x - 5, roof_y), Color(ROOF_BLUE.lightened(0.2), 0.22), 1.0)
	canvas.draw_line(Vector2(bounds.position.x + 8, bounds.position.y + 16), Vector2(bounds.end.x - 8, bounds.position.y + 16), Color(BRASS, 0.58), 2.0)
	var door_width: int = mini(22, bounds.size.x / 3)
	var door := Rect2(bounds.position.x + (bounds.size.x - door_width) / 2, bounds.end.y - 27, door_width, 27)
	canvas.draw_rect(door, Color("211d1b"), true)
	canvas.draw_rect(door, BRASS, false, 2.0)
	# Threshold is outside the art footprint so the entry direction is explicit.
	canvas.draw_rect(Rect2(door.position.x - 3, bounds.end.y, door.size.x + 6, 5), language.ramp_color("warm_stone", 3) if language != null else STONE, true)
	canvas.draw_line(Vector2(door.position.x - 3, bounds.end.y + 5), Vector2(door.end.x + 3, bounds.end.y + 5), Color(DEEP_FOREST, 0.7), 1.0)
	for window_x: int in range(bounds.position.x + 14, bounds.end.x - 12, 30):
		var window := Rect2(window_x, facade.position.y + 10, 10, 12)
		if window.intersects(door):
			continue
		canvas.draw_rect(window, Color(CYAN, 0.30), true)
		canvas.draw_rect(window, BRASS.darkened(0.25), false, 1.0)
		canvas.draw_line(window.position + Vector2(window.size.x * 0.5, 1), window.position + Vector2(window.size.x * 0.5, window.size.y - 1), Color(PARCHMENT, 0.28), 1.0)
	if style in ["portal_rotunda", "archive_hall", "spire"]:
		var crown := Vector2(bounds.get_center().x, bounds.position.y - 8)
		canvas.draw_line(crown, crown + Vector2(0, -18), BRASS, 2.0)
		canvas.draw_circle(crown + Vector2(0, -21), 4.0, CYAN if style != "portal_rotunda" else VIOLET)
	_draw_building_cutaway(canvas, footprint, focus_world_position)


func _draw_building_cutaway(canvas: CanvasItem, footprint: Rect2, focus_world_position: Vector2) -> void:
	var amount := cutaway_amount(footprint, focus_world_position)
	if amount <= 0.0:
		return
	# A cardinal footprint mask replaces decorative rise near the observed actor.
	# Collision remains authored by SanctumCampusLayout; this only exposes it.
	canvas.draw_rect(footprint.grow(-2.0), Color(language.ramp_color("worldbone", 1), 0.82 * amount), true)
	canvas.draw_rect(footprint.grow(-2.0), Color(STONE_LIGHT, 0.78 * amount), false, 2.0)
	var threshold := Rect2(footprint.get_center().x - 14.0, footprint.end.y, 28.0, 5.0)
	canvas.draw_rect(threshold, Color(PATH_LIGHT, 0.90 * amount), true)
	canvas.draw_line(threshold.position + Vector2(0.0, 5.0), threshold.end, Color(DEEP_FOREST, 0.72 * amount), 1.0)


static func cutaway_amount(footprint: Rect2, focus_world_position: Vector2) -> float:
	if footprint.size.x <= 0.0 or footprint.size.y <= 0.0:
		return 0.0
	var outer := footprint.grow(44.0)
	if not outer.has_point(focus_world_position):
		return 0.0
	var inner := footprint.grow(18.0)
	if inner.has_point(focus_world_position):
		return 1.0
	var nearest := Vector2(
		clampf(focus_world_position.x, inner.position.x, inner.end.x),
		clampf(focus_world_position.y, inner.position.y, inner.end.y),
	)
	return 1.0 - clampf(focus_world_position.distance_to(nearest) / 26.0, 0.0, 1.0)


func _draw_vault_rail(canvas: CanvasItem, bounds: Rect2i) -> void:
	canvas.draw_rect(Rect2(bounds.position + Vector2i(4, 6), bounds.size), Color(DEEP_FOREST, 0.75), true)
	canvas.draw_rect(Rect2(bounds), Color("554532"), true)
	canvas.draw_rect(Rect2(bounds), BRASS, false, 3.0)
	for x: int in range(bounds.position.x + 8, bounds.end.x, 16):
		canvas.draw_line(Vector2(x, bounds.position.y + 4), Vector2(x, bounds.end.y - 4), Color(BRASS_LIGHT, 0.65), 2.0)
	canvas.draw_string(ThemeDB.fallback_font, Vector2(bounds.position.x + 7, bounds.get_center().y + 4), "VAULT", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 10, PARCHMENT)


func _draw_landmark(canvas: CanvasItem, landmark: Dictionary, tick: int, reduced_effects: bool) -> void:
	if architecture_kit != null:
		architecture_kit.draw_landmark_frame(canvas, landmark, tick, reduced_effects)
	var values: Array = landmark.get("position", [])
	var position := Vector2(float(values[0]), float(values[1]))
	var kind := String(landmark.get("kind", ""))
	var pulse: float = float((tick / 5) % 24) / 24.0
	var glow_radius: float = 17.0 + (4.0 * pulse if pulse <= 0.5 else 4.0 * (1.0 - pulse))
	match kind:
		"grand_fountain":
			canvas.draw_circle(position, 42.0, CLIFF)
			canvas.draw_circle(position, 35.0, BRASS)
			canvas.draw_circle(position, 28.0, WATER_LIGHT)
			canvas.draw_circle(position, 18.0, Color(CYAN, 0.32))
			canvas.draw_circle(position, 7.0, CYAN)
			canvas.draw_line(position, position + Vector2(0, -34), CYAN, 4.0)
		"portal_ring":
			canvas.draw_circle(position, 35.0, CLIFF)
			canvas.draw_arc(position, 27.0, 0.0, TAU, 24, BRASS, 5.0)
			canvas.draw_circle(position, glow_radius, Color(VIOLET, 0.24))
			canvas.draw_circle(position, 8.0, VIOLET)
		"archive_orrey":
			canvas.draw_circle(position, 24.0, CLIFF)
			canvas.draw_arc(position, 18.0, 0.0, TAU, 20, BRASS, 2.0)
			canvas.draw_arc(position, 11.0, -0.7, 2.4, 14, CYAN, 2.0)
			canvas.draw_circle(position, 5.0, CYAN)
		"attunement_crucible":
			canvas.draw_circle(position, 26.0, CLIFF)
			canvas.draw_circle(position, 20.0, BRASS.darkened(0.2))
			canvas.draw_circle(position, 13.0, Color(FIRE, 0.7))
			canvas.draw_rect(Rect2(position.x - 3, position.y - 24, 6, 12), BRASS, true)
		_:
			canvas.draw_circle(position, glow_radius, Color(CYAN, 0.18))
			canvas.draw_circle(position, 13.0, CLIFF)
			canvas.draw_circle(position, 8.0, CYAN)
			canvas.draw_arc(position, 17.0, 0.0, TAU, 16, BRASS, 2.0)
	if bool(landmark.get("fast_travel", false)):
		canvas.draw_circle(position, glow_radius + 8.0, Color(CYAN, 0.12))


func _draw_station(canvas: CanvasItem, station: Dictionary, tick: int, reduced_effects: bool) -> void:
	if architecture_kit != null:
		architecture_kit.draw_station_frame(canvas, station, tick, reduced_effects)
	var values: Array = station.get("position", [])
	var position := Vector2(float(values[0]), float(values[1]))
	var kind := String(station.get("kind", ""))
	var pulse: float = 0.12 + 0.06 * sin(float(tick) * 0.08)
	var accent: Color = CYAN if kind in ["guide", "controls", "farflow"] else (VIOLET if kind in ["champion", "spell"] else (BRASS if kind in ["charter", "ledger"] else FIRE))
	canvas.draw_circle(position + Vector2(2, 5), 19.0, Color(DEEP_FOREST, 0.72))
	canvas.draw_circle(position, 17.0, CLIFF)
	canvas.draw_arc(position, 14.0, 0.0, TAU, 16, BRASS, 3.0)
	canvas.draw_circle(position, 10.0, Color(accent, 0.20 + pulse))
	if kind == "guide":
		canvas.draw_line(position + Vector2(-8, -5), position + Vector2(-1, -2), PARCHMENT, 2.0)
		canvas.draw_line(position + Vector2(8, -5), position + Vector2(1, -2), PARCHMENT, 2.0)
		canvas.draw_line(position + Vector2(-8, -5), position + Vector2(-8, 6), PARCHMENT, 2.0)
		canvas.draw_line(position + Vector2(8, -5), position + Vector2(8, 6), PARCHMENT, 2.0)
		canvas.draw_line(position + Vector2(-8, 6), position + Vector2(0, 8), PARCHMENT, 2.0)
		canvas.draw_line(position + Vector2(8, 6), position + Vector2(0, 8), PARCHMENT, 2.0)
	elif kind == "controls":
		canvas.draw_rect(Rect2(position + Vector2(-8, -7), Vector2(16, 12)), Color(PARCHMENT, 0.18), true)
		for key_position: Vector2 in [Vector2(-5, -4), Vector2(0, -4), Vector2(5, -4), Vector2(-5, 1), Vector2(0, 1), Vector2(5, 1)]:
			canvas.draw_rect(Rect2(position + key_position, Vector2(3, 3)), PARCHMENT, true)
		canvas.draw_line(position + Vector2(-10, 8), position + Vector2(10, 8), BRASS_LIGHT, 2.0)
	elif kind == "champion":
		var loom_points := PackedVector2Array([
			position + Vector2(0, -9),
			position + Vector2(8, 0),
			position + Vector2(0, 9),
			position + Vector2(-8, 0),
		])
		canvas.draw_polyline(loom_points, PARCHMENT, 2.0)
		canvas.draw_line(loom_points[-1], loom_points[0], PARCHMENT, 2.0)
		canvas.draw_circle(position, 3.0, VIOLET)
	elif kind == "spell":
		for index: int in range(PlayerState.SPELL_SLOT_COUNT):
			var angle: float = -PI * 0.5 + TAU * float(index) / float(PlayerState.SPELL_SLOT_COUNT)
			canvas.draw_circle(position + Vector2(cos(angle), sin(angle)) * 8.0, 2.5, PARCHMENT if index < 2 else Color(PARCHMENT, 0.42))
		canvas.draw_circle(position, 3.0, VIOLET)
	elif kind == "farflow":
		canvas.draw_arc(position, 8.0, -2.45, 0.7, 12, PARCHMENT, 2.0)
		canvas.draw_arc(position, 8.0, 0.7, 3.85, 12, CYAN, 2.0)
		var direction: float = -1.0 if String(station.get("command", "")) == "host_session" else 1.0
		canvas.draw_line(position + Vector2(-6.0 * direction, 0), position + Vector2(6.0 * direction, 0), PARCHMENT, 2.0)
		canvas.draw_line(position + Vector2(6.0 * direction, 0), position + Vector2(2.0 * direction, -4), PARCHMENT, 2.0)
		canvas.draw_line(position + Vector2(6.0 * direction, 0), position + Vector2(2.0 * direction, 4), PARCHMENT, 2.0)
	elif kind == "charter":
		canvas.draw_rect(Rect2(position + Vector2(-7, -9), Vector2(14, 18)), Color(PARCHMENT, 0.25), true)
		canvas.draw_line(position + Vector2(-6, -7), position + Vector2(6, -7), PARCHMENT, 2.0)
		canvas.draw_line(position + Vector2(-6, -2), position + Vector2(4, -2), PARCHMENT, 1.0)
		canvas.draw_line(position + Vector2(-6, 3), position + Vector2(5, 3), PARCHMENT, 1.0)
		canvas.draw_circle(position + Vector2(5, 7), 3.0, BRASS)
	elif kind == "hearth":
		var flame := PackedVector2Array([
			position + Vector2(0, -9), position + Vector2(6, -1),
			position + Vector2(3, 7), position + Vector2(-4, 6),
			position + Vector2(-7, 0),
		])
		canvas.draw_colored_polygon(flame, FIRE)
		canvas.draw_circle(position + Vector2(0, 2), 3.5, PARCHMENT)
		canvas.draw_line(position + Vector2(-9, 9), position + Vector2(9, 9), BRASS, 2.0)
	elif kind == "ledger":
		canvas.draw_rect(Rect2(position + Vector2(-8, -9), Vector2(16, 18)), Color(PARCHMENT, 0.22), true)
		canvas.draw_line(position + Vector2(-5, -6), position + Vector2(5, -6), PARCHMENT, 1.5)
		canvas.draw_line(position + Vector2(-5, -1), position + Vector2(5, -1), PARCHMENT, 1.5)
		canvas.draw_line(position + Vector2(-5, 4), position + Vector2(2, 4), PARCHMENT, 1.5)
		canvas.draw_circle(position + Vector2(6, 7), 2.5, BRASS)
	elif kind == "parting":
		canvas.draw_arc(position + Vector2(0, 1), 8.0, PI, TAU, 12, PARCHMENT, 2.0)
		canvas.draw_line(position + Vector2(-8, 1), position + Vector2(-5, -6), PARCHMENT, 2.0)
		canvas.draw_line(position + Vector2(8, 1), position + Vector2(5, -6), PARCHMENT, 2.0)
		canvas.draw_line(position + Vector2(-5, -6), position + Vector2(5, -6), PARCHMENT, 2.0)
		canvas.draw_circle(position + Vector2(0, 6), 2.5, FIRE)
	else:
		canvas.draw_arc(position, 7.0, -2.2, 2.0, 10, PARCHMENT, 2.0)
		canvas.draw_line(position + Vector2(-6, -6), position + Vector2(-10, -2), PARCHMENT, 2.0)
		canvas.draw_line(position + Vector2(-6, -6), position + Vector2(-2, -7), PARCHMENT, 2.0)
	var title := String(station.get("title", ""))
	var text_width: float = ThemeDB.fallback_font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
	canvas.draw_rect(Rect2(position.x - text_width * 0.5 - 5.0, position.y + 23.0, text_width + 10.0, 16.0), PANEL, true)
	canvas.draw_string(ThemeDB.fallback_font, Vector2(position.x - text_width * 0.5, position.y + 35.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 10, PARCHMENT)


func _draw_district_label(canvas: CanvasItem, district: Dictionary) -> void:
	var values: Array = district.get("label_anchor", [])
	var anchor := Vector2(float(values[0]), float(values[1]))
	var label := String(district.get("label", ""))
	var width: float = minf(250.0, 18.0 + ThemeDB.fallback_font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x)
	canvas.draw_rect(Rect2(anchor.x - 4, anchor.y - 14, width, 20), PANEL, true)
	canvas.draw_rect(Rect2(anchor.x - 4, anchor.y - 14, width, 20), Color(BRASS, 0.65), false, 1.0)
	canvas.draw_string(ThemeDB.fallback_font, anchor, label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 11, PARCHMENT)


func _draw_tree(canvas: CanvasItem, position: Vector2, scale: float = 1.0) -> void:
	canvas.draw_circle(position + Vector2(3, 8) * scale, 11.0 * scale, Color(DEEP_FOREST, 0.65))
	canvas.draw_rect(Rect2(position.x - 2 * scale, position.y, 4 * scale, 13 * scale), TIMBER, true)
	canvas.draw_circle(position + Vector2(-5, -3) * scale, 10.0 * scale, GRASS)
	canvas.draw_circle(position + Vector2(5, -4) * scale, 11.0 * scale, Color("365c2d"))
	canvas.draw_circle(position + Vector2(0, -10) * scale, 10.0 * scale, GRASS_LIGHT)
	canvas.draw_rect(Rect2(position.x - 2 * scale, position.y - 12 * scale, 3 * scale, 2 * scale), Color(MOSS, 0.7), true)


func _draw_bush(canvas: CanvasItem, position: Vector2, scale: float = 1.0) -> void:
	canvas.draw_circle(position + Vector2(3, 3) * scale, 7.0 * scale, Color(DEEP_FOREST, 0.55))
	canvas.draw_circle(position + Vector2(-4, 0) * scale, 6.0 * scale, GRASS)
	canvas.draw_circle(position + Vector2(4, -1) * scale, 7.0 * scale, GRASS_LIGHT)
	canvas.draw_circle(position + Vector2(0, -5) * scale, 5.0 * scale, MOSS)


static func _district_ground_color(style: String) -> Color:
	match style:
		"garden":
			return Color("34532b")
		"archive":
			return Color("48513c")
		"wayfarer":
			return Color("43503b")
		"proving":
			return Color("51462f")
		_:
			return Color("3b552f")


func _roof_color(style: String) -> Color:
	match style:
		"archive_hall", "service_tower":
			return ROOF_BLUE
		"portal_rotunda":
			return ROOF_VIOLET
		"garden_gate":
			return ROOF_GREEN
		"foundry_hall":
			return ROOF_RUST
		_:
			return Color("384438")


static func _packed_points(values: Variant) -> PackedVector2Array:
	var output := PackedVector2Array()
	for value: Variant in values:
		var point: Array = value
		output.append(Vector2(float(point[0]), float(point[1])))
	return output


static func _stepped_rect(rectangle: Rect2i) -> PackedVector2Array:
	var step_size: int = mini(14, mini(rectangle.size.x / 4, rectangle.size.y / 4))
	return PackedVector2Array([
		Vector2(rectangle.position.x + step_size, rectangle.position.y),
		Vector2(rectangle.end.x - step_size, rectangle.position.y),
		Vector2(rectangle.end.x, rectangle.position.y + step_size),
		Vector2(rectangle.end.x, rectangle.end.y - step_size),
		Vector2(rectangle.end.x - step_size, rectangle.end.y),
		Vector2(rectangle.position.x + step_size, rectangle.end.y),
		Vector2(rectangle.position.x, rectangle.end.y - step_size),
		Vector2(rectangle.position.x, rectangle.position.y + step_size),
	])


static func _offset_points(points: PackedVector2Array, offset: Vector2) -> PackedVector2Array:
	var output := PackedVector2Array()
	for point: Vector2 in points:
		output.append(point + offset)
	return output


static func _closed(points: PackedVector2Array) -> PackedVector2Array:
	var output := points.duplicate()
	if not points.is_empty():
		output.append(points[0])
	return output
