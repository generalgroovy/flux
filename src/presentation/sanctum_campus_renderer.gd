class_name SanctumCampusRenderer
extends RefCounted


const WATER := Color("102f3b")
const WATER_LIGHT := Color("1f596a")
const WATER_GLINT := Color("3a7d87")
const DEEP_FOREST := Color("111d15")
const CLIFF := Color("25272a")
const CLIFF_LIGHT := Color("4f4a3f")
const STONE := Color("a6956c")
const STONE_LIGHT := Color("c8b883")
const PATH := Color("80643f")
const PATH_LIGHT := Color("a58555")
const GRASS := Color("2c4725")
const GRASS_LIGHT := Color("5f7d43")
const MOSS := Color("718c4c")
const TIMBER := Color("452d23")
const TIMBER_LIGHT := Color("76503a")
const ROOF_BLUE := Color("263b49")
const ROOF_VIOLET := Color("3d3150")
const ROOF_GREEN := Color("2d473a")
const ROOF_RUST := Color("57372d")
const BRASS := Color("b98336")
const BRASS_LIGHT := Color("d9ad55")
const PARCHMENT := Color("e4d8ae")
const CYAN := Color("51d5dc")
const VIOLET := Color("9461d4")
const FIRE := Color("df8335")
const PANEL := Color("11140ee8")


func draw(canvas: CanvasItem, layout: SanctumCampusLayout, presentation_tick: int) -> void:
	_draw_water(canvas, layout.canvas_size, layout.reserved_ui_top, presentation_tick)
	_draw_distant_context(canvas)
	for connection_value: Variant in layout.data.get("connections", []):
		_draw_connection(canvas, connection_value as Dictionary)
	var district_index: int = 0
	for district_value: Variant in layout.data.get("districts", []):
		_draw_district(canvas, district_value as Dictionary, district_index)
		district_index += 1
	for route_value: Variant in layout.data.get("routes", []):
		_draw_route(canvas, route_value as Dictionary)
	for building_value: Variant in layout.data.get("buildings", []):
		_draw_building(canvas, building_value as Dictionary)
	for landmark_value: Variant in layout.data.get("landmarks", []):
		_draw_landmark(canvas, landmark_value as Dictionary, presentation_tick)
	for station_value: Variant in layout.data.get("stations", []):
		_draw_station(canvas, station_value as Dictionary, presentation_tick)
	for district_value: Variant in layout.data.get("districts", []):
		_draw_district_label(canvas, district_value as Dictionary)


func _draw_water(canvas: CanvasItem, size: Vector2i, top: int, tick: int) -> void:
	canvas.draw_rect(Rect2(0, top, size.x, size.y - top), WATER, true)
	var phase: int = (tick / 8) % 48
	for y: int in range(top + 14, size.y, 32):
		for x: int in range(-32, size.x + 32, 64):
			var glint_x: int = x + phase + ((y / 32) % 2) * 20
			canvas.draw_line(Vector2(glint_x, y), Vector2(glint_x + 14, y), Color(WATER_LIGHT, 0.58), 2.0)
			canvas.draw_line(Vector2(glint_x + 5, y + 4), Vector2(glint_x + 24, y + 4), Color(WATER_GLINT, 0.22), 1.0)


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

	# Small, regular pixel clusters make the ground feel authored without hiding lanes.
	for y: int in range(ground_rect.position.y + 18, ground_rect.end.y - 10, 32):
		for x: int in range(ground_rect.position.x + 20, ground_rect.end.x - 10, 40):
			if ((x / 8) + (y / 8) + index) % 3 == 0:
				canvas.draw_rect(Rect2(x, y, 3, 2), Color(MOSS, 0.32), true)
			else:
				canvas.draw_rect(Rect2(x, y, 2, 2), Color(STONE_LIGHT, 0.12), true)

	_draw_district_edge_garden(canvas, ground_rect, index)


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
	canvas.draw_polyline(points, Color(DEEP_FOREST, 0.7), width + 8.0, false)
	canvas.draw_polyline(points, edge_color, width + 4.0, false)
	canvas.draw_polyline(points, route_color, width, false)
	if kind == "advanced":
		canvas.draw_polyline(points, Color(BRASS_LIGHT, 0.7), 2.0, false)


func _draw_building(canvas: CanvasItem, building: Dictionary) -> void:
	var bounds := SanctumCampusLayout._parse_bounds(building.get("bounds", []))
	var style := String(building.get("style", "timber_hall"))
	if style == "vault_rail":
		_draw_vault_rail(canvas, bounds)
		return
	var roof_color := _roof_color(style)
	canvas.draw_rect(Rect2(bounds.position + Vector2i(5, 8), bounds.size), Color(DEEP_FOREST, 0.82), true)
	canvas.draw_rect(Rect2(bounds), TIMBER, true)
	canvas.draw_rect(Rect2(bounds.grow(-4)), TIMBER_LIGHT, false, 2.0)
	var roof := PackedVector2Array([
		Vector2(bounds.position.x - 5, bounds.position.y + 18),
		Vector2(bounds.position.x + 10, bounds.position.y - 6),
		Vector2(bounds.end.x - 10, bounds.position.y - 6),
		Vector2(bounds.end.x + 5, bounds.position.y + 18),
		Vector2(bounds.end.x - 2, bounds.position.y + bounds.size.y * 0.56),
		Vector2(bounds.position.x + 2, bounds.position.y + bounds.size.y * 0.56),
	])
	canvas.draw_colored_polygon(roof, Color(roof_color, 0.98))
	canvas.draw_polyline(_closed(roof), BRASS.darkened(0.25), 2.0, false)
	canvas.draw_line(Vector2(bounds.position.x + 8, bounds.position.y + 18), Vector2(bounds.end.x - 8, bounds.position.y + 18), Color(BRASS, 0.5), 2.0)
	var door_width: int = mini(22, bounds.size.x / 3)
	var door := Rect2(bounds.position.x + (bounds.size.x - door_width) / 2, bounds.end.y - 25, door_width, 25)
	canvas.draw_rect(door, Color("211d1b"), true)
	canvas.draw_rect(door, BRASS, false, 2.0)
	for window_x: int in range(bounds.position.x + 14, bounds.end.x - 12, 30):
		if Rect2(window_x, bounds.end.y - 42, 10, 12).intersects(door):
			continue
		canvas.draw_rect(Rect2(window_x, bounds.end.y - 42, 10, 12), Color(CYAN, 0.42), true)
		canvas.draw_rect(Rect2(window_x, bounds.end.y - 42, 10, 12), BRASS.darkened(0.25), false, 1.0)
	if style in ["portal_rotunda", "archive_hall", "spire"]:
		var crown := Vector2(bounds.get_center().x, bounds.position.y - 8)
		canvas.draw_line(crown, crown + Vector2(0, -18), BRASS, 2.0)
		canvas.draw_circle(crown + Vector2(0, -21), 4.0, CYAN if style != "portal_rotunda" else VIOLET)


func _draw_vault_rail(canvas: CanvasItem, bounds: Rect2i) -> void:
	canvas.draw_rect(Rect2(bounds.position + Vector2i(4, 6), bounds.size), Color(DEEP_FOREST, 0.75), true)
	canvas.draw_rect(Rect2(bounds), Color("554532"), true)
	canvas.draw_rect(Rect2(bounds), BRASS, false, 3.0)
	for x: int in range(bounds.position.x + 8, bounds.end.x, 16):
		canvas.draw_line(Vector2(x, bounds.position.y + 4), Vector2(x, bounds.end.y - 4), Color(BRASS_LIGHT, 0.65), 2.0)
	canvas.draw_string(ThemeDB.fallback_font, Vector2(bounds.position.x + 7, bounds.get_center().y + 4), "VAULT", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 10, PARCHMENT)


func _draw_landmark(canvas: CanvasItem, landmark: Dictionary, tick: int) -> void:
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


func _draw_station(canvas: CanvasItem, station: Dictionary, tick: int) -> void:
	var values: Array = station.get("position", [])
	var position := Vector2(float(values[0]), float(values[1]))
	var kind := String(station.get("kind", ""))
	var pulse: float = 0.12 + 0.06 * sin(float(tick) * 0.08)
	var accent: Color = CYAN if kind in ["guide", "farflow"] else (VIOLET if kind == "champion" else FIRE)
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
	elif kind == "farflow":
		canvas.draw_arc(position, 8.0, -2.45, 0.7, 12, PARCHMENT, 2.0)
		canvas.draw_arc(position, 8.0, 0.7, 3.85, 12, CYAN, 2.0)
		var direction: float = -1.0 if String(station.get("command", "")) == "host_session" else 1.0
		canvas.draw_line(position + Vector2(-6.0 * direction, 0), position + Vector2(6.0 * direction, 0), PARCHMENT, 2.0)
		canvas.draw_line(position + Vector2(6.0 * direction, 0), position + Vector2(2.0 * direction, -4), PARCHMENT, 2.0)
		canvas.draw_line(position + Vector2(6.0 * direction, 0), position + Vector2(2.0 * direction, 4), PARCHMENT, 2.0)
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


static func _roof_color(style: String) -> Color:
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
