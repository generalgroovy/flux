class_name PixelPrimitives
extends RefCounted


static func stepped_rect(rectangle: Rect2, step: float) -> PackedVector2Array:
	var safe_step := minf(step, minf(rectangle.size.x, rectangle.size.y) * 0.25)
	return PackedVector2Array([
		rectangle.position + Vector2(safe_step, 0),
		Vector2(rectangle.end.x - safe_step, rectangle.position.y),
		Vector2(rectangle.end.x, rectangle.position.y + safe_step),
		Vector2(rectangle.end.x, rectangle.end.y - safe_step),
		Vector2(rectangle.end.x - safe_step, rectangle.end.y),
		Vector2(rectangle.position.x + safe_step, rectangle.end.y),
		Vector2(rectangle.position.x, rectangle.end.y - safe_step),
		Vector2(rectangle.position.x, rectangle.position.y + safe_step),
	])


static func closed(points: PackedVector2Array) -> PackedVector2Array:
	var output := points.duplicate()
	if not output.is_empty():
		output.append(output[0])
	return output


static func draw_panel(
	canvas: CanvasItem,
	rectangle: Rect2,
	language: VisualLanguage,
	emphasis: bool = false,
	focus: bool = false,
) -> void:
	var step := float(language.ui_metric("corner_step"))
	var points := stepped_rect(rectangle, step)
	var shadow := PackedVector2Array()
	for point: Vector2 in points:
		shadow.append(point + Vector2(0, 3))
	canvas.draw_colored_polygon(shadow, Color(language.ramp_color("worldbone", 0), 0.72))
	canvas.draw_colored_polygon(points, language.ui_color("panel_fill_strong") if emphasis else language.ui_color("panel_fill"))
	var outline := language.ui_color("focus") if focus else language.ramp_color("aged_brass", 2 if emphasis else 1)
	canvas.draw_polyline(closed(points), outline, float(language.ui_metric("outline_emphasis") if focus else language.ui_metric("outline_regular")))
	var inset := rectangle.grow(-4.0)
	canvas.draw_polyline(closed(stepped_rect(inset, maxf(2.0, step - 2.0))), Color(language.ramp_color("aged_brass", 3), 0.34), 1.0)


static func draw_divider(canvas: CanvasItem, start: Vector2, finish: Vector2, language: VisualLanguage) -> void:
	canvas.draw_line(start, finish, Color(language.ramp_color("aged_brass", 2), 0.62), 1.0)
	canvas.draw_line(start + Vector2(0, 1), finish + Vector2(0, 1), Color(language.ramp_color("worldbone", 0), 0.72), 1.0)


static func draw_rune_diamond(canvas: CanvasItem, center: Vector2, radius: float, color: Color, phase: float = 0.0) -> void:
	var pulse := 1.0 + 0.08 * sin(phase)
	var points := PackedVector2Array([
		center + Vector2(0, -radius * pulse),
		center + Vector2(radius, 0),
		center + Vector2(0, radius * pulse),
		center + Vector2(-radius, 0),
		center + Vector2(0, -radius * pulse),
	])
	canvas.draw_polyline(points, color, 2.0)
	canvas.draw_circle(center, maxf(1.0, radius * 0.22), color)


static func draw_element_glyph(canvas: CanvasItem, center: Vector2, radius: float, element_id: String, color: Color, phase: float = 0.0) -> void:
	var pulse := 1.0 + 0.06 * sin(phase)
	var r := radius * pulse
	match element_id:
		"earth":
			var block := Rect2(center - Vector2(r * 0.58, r * 0.45), Vector2(r * 1.16, r * 0.9))
			canvas.draw_rect(block, color, false, 2.0)
			canvas.draw_line(center + Vector2(-r * 0.15, -r * 0.42), center + Vector2(r * 0.08, r * 0.42), color, 1.0)
			canvas.draw_line(center + Vector2(r * 0.08, 0), center + Vector2(r * 0.43, -r * 0.23), color, 1.0)
		"fire":
			var flame := PackedVector2Array([center + Vector2(0, -r), center + Vector2(r * 0.56, -r * 0.06), center + Vector2(r * 0.22, r), center + Vector2(-r * 0.52, r * 0.38), center + Vector2(-r * 0.3, -r * 0.18), center + Vector2(0, -r)])
			canvas.draw_polyline(flame, color, 2.0)
		"water":
			canvas.draw_arc(center + Vector2(-r * 0.1, r * 0.08), r * 0.66, -2.7, 1.0, 12, color, 2.0)
			canvas.draw_arc(center + Vector2(r * 0.28, r * 0.2), r * 0.42, -2.8, 0.6, 10, color, 2.0)
			canvas.draw_line(center + Vector2(-r, r * 0.55), center + Vector2(r, r * 0.55), color, 1.0)
		"wind":
			canvas.draw_arc(center, r * 0.72, -2.5, 2.2, 16, color, 2.0)
			canvas.draw_arc(center + Vector2(r * 0.2, r * 0.1), r * 0.35, -2.2, 2.0, 10, color, 1.0)
		"ice":
			for index: int in 3:
				var angle := float(index) * PI / 3.0
				var direction := Vector2(cos(angle), sin(angle))
				canvas.draw_line(center - direction * r, center + direction * r, color, 1.5)
		"charge":
			var bolt := PackedVector2Array([center + Vector2(r * 0.2, -r), center + Vector2(-r * 0.42, r * 0.05), center + Vector2(r * 0.05, r * 0.05), center + Vector2(-r * 0.18, r), center + Vector2(r * 0.5, -r * 0.18), center + Vector2(r * 0.02, -r * 0.18)])
			canvas.draw_polyline(bolt, color, 2.0)
		"light":
			draw_rune_diamond(canvas, center, r * 0.58, color)
			canvas.draw_line(center + Vector2(0, -r), center + Vector2(0, r), color, 1.0)
			canvas.draw_line(center + Vector2(-r, 0), center + Vector2(r, 0), color, 1.0)
		"dark":
			canvas.draw_arc(center, r * 0.72, -1.75, 1.75, 16, color, 2.0)
			canvas.draw_arc(center + Vector2(r * 0.34, 0), r * 0.55, -1.8, 1.8, 14, color, 1.0)
		"spirit":
			canvas.draw_arc(center + Vector2(-r * 0.2, 0), r * 0.5, -2.2, 2.2, 12, color, 1.5)
			canvas.draw_arc(center + Vector2(r * 0.2, 0), r * 0.5, 0.95, 5.35, 12, color, 1.5)
		"chaos":
			canvas.draw_arc(center, r * 0.78, -2.8, -0.2, 9, color, 2.0)
			canvas.draw_arc(center, r * 0.78, 0.35, 2.5, 8, color, 2.0)
			canvas.draw_line(center + Vector2(-r * 0.75, -r * 0.1), center + Vector2(r * 0.68, r * 0.25), color, 1.0)
		"gravity":
			canvas.draw_arc(center, r * 0.82, 0.0, TAU, 18, color, 1.0)
			canvas.draw_arc(center, r * 0.48, 0.0, TAU, 14, color, 1.0)
			canvas.draw_circle(center, r * 0.18, color)
		"time":
			canvas.draw_arc(center, r * 0.78, 0.0, TAU, 18, color, 1.5)
			canvas.draw_line(center, center + Vector2(0, -r * 0.54), color, 2.0)
			canvas.draw_line(center, center + Vector2(r * 0.42, r * 0.16), color, 2.0)
		_:
			draw_rune_diamond(canvas, center, r * 0.65, color)


static func draw_material_tile(canvas: CanvasItem, rectangle: Rect2, ramp: Array[Color], pattern_seed: int) -> void:
	canvas.draw_rect(rectangle, ramp[1], true)
	canvas.draw_rect(rectangle, ramp[0], false, 2.0)
	canvas.draw_line(rectangle.position + Vector2(2, 2), Vector2(rectangle.end.x - 2, rectangle.position.y + 2), ramp[3], 2.0)
	var cell := 8
	for y: int in range(int(rectangle.position.y) + 6, int(rectangle.end.y) - 3, cell):
		for x: int in range(int(rectangle.position.x) + 5, int(rectangle.end.x) - 3, cell):
			var selector := (x / cell + y / cell + pattern_seed) % 4
			canvas.draw_rect(Rect2(x, y, 2 + selector % 2, 2), ramp[2 + selector % 2], true)


static func draw_resource_sample(canvas: CanvasItem, rectangle: Rect2, ramp: Array[Color], ratio: float) -> void:
	canvas.draw_rect(rectangle, ramp[0], true)
	canvas.draw_rect(Rect2(rectangle.position + Vector2(3, 3), Vector2((rectangle.size.x - 6) * clampf(ratio, 0.0, 1.0), rectangle.size.y - 6)), ramp[2], true)
	canvas.draw_line(rectangle.position + Vector2(3, 4), Vector2(rectangle.position.x + 3 + (rectangle.size.x - 6) * clampf(ratio, 0.0, 1.0), rectangle.position.y + 4), ramp[4], 1.0)
	canvas.draw_rect(rectangle, ramp[4], false, 1.0)
