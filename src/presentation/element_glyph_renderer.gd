class_name ElementGlyphRenderer
extends RefCounted


const TOPOLOGY_BY_SHAPE := {
	"block_fracture": "square_crack",
	"forked_flame": "pointed_fork",
	"curling_wave": "curl_drop",
	"open_spiral": "open_coil",
	"six_point_crystal": "six_spokes",
	"broken_bolt": "offset_zigzag",
	"radiant_diamond": "diamond_cross",
	"inward_crescent": "paired_crescent",
	"double_echo": "twin_rings",
	"broken_orbit": "split_orbit",
	"concentric_weight": "weighted_rings",
	"offset_hour": "offset_hands",
}


static func contract(language: VisualLanguage, element_id: String) -> Dictionary:
	if language == null or not language.elements.has(element_id):
		return {}
	var shape := language.element_shape(element_id)
	if not TOPOLOGY_BY_SHAPE.has(shape):
		return {}
	return {
		"element": element_id,
		"shape": shape,
		"topology": String(TOPOLOGY_BY_SHAPE[shape]),
		"cadence": language.element_cadence(element_id),
	}


static func draw(canvas: CanvasItem, language: VisualLanguage, center: Vector2, element_id: String, radius: float, color: Color, direction: Vector2 = Vector2.UP) -> bool:
	var glyph := contract(language, element_id)
	if canvas == null or glyph.is_empty() or radius <= 0.0:
		return false
	var forward := direction.normalized() if direction.length_squared() > 0.0 else Vector2.UP
	var side := forward.orthogonal()
	match String(glyph["shape"]):
		"block_fracture":
			var square := PackedVector2Array([center - forward * radius - side * radius, center - forward * radius + side * radius, center + forward * radius + side * radius, center + forward * radius - side * radius])
			canvas.draw_polyline(_closed(square), color, 1.5, false)
			canvas.draw_polyline(PackedVector2Array([center - side * radius * 0.8, center + forward * radius * 0.15, center - forward * radius * 0.2 + side * radius * 0.8]), color, 1.5, false)
		"forked_flame":
			canvas.draw_polyline(PackedVector2Array([center + forward * radius, center - side * radius * 0.55, center - forward * radius * 0.25, center + side * radius * 0.55, center + forward * radius]), color, 1.5, false)
			canvas.draw_line(center - forward * radius * 0.15, center - forward * radius, color, 1.5)
		"curling_wave":
			canvas.draw_arc(center, radius, forward.angle() - 2.55, forward.angle() + 0.55, 10, color, 1.5)
			canvas.draw_circle(center + side * radius * 0.42, radius * 0.22, color)
		"open_spiral":
			canvas.draw_arc(center, radius, forward.angle() - 2.65, forward.angle() + 1.60, 12, color, 1.5)
			canvas.draw_line(center + forward * radius * 0.1, center + forward * radius, color, 1.5)
		"six_point_crystal":
			for index: int in range(6):
				var ray := Vector2.from_angle(forward.angle() + TAU * float(index) / 6.0)
				canvas.draw_line(center, center + ray * radius, color, 1.5)
		"broken_bolt":
			canvas.draw_polyline(PackedVector2Array([center - forward * radius, center - side * radius * 0.72, center + forward * radius * 0.12, center + side * radius * 0.72, center + forward * radius]), color, 1.5, false)
		"radiant_diamond":
			var diamond := PackedVector2Array([center + forward * radius, center + side * radius, center - forward * radius, center - side * radius])
			canvas.draw_polyline(_closed(diamond), color, 1.5, false)
			canvas.draw_line(center - forward * radius * 0.42, center + forward * radius * 0.42, color, 1.5)
			canvas.draw_line(center - side * radius * 0.42, center + side * radius * 0.42, color, 1.5)
		"inward_crescent":
			canvas.draw_arc(center - side * radius * 0.18, radius, forward.angle() - 2.30, forward.angle() + 0.85, 10, color, 1.5)
			canvas.draw_arc(center + side * radius * 0.34, radius * 0.72, forward.angle() - 2.30, forward.angle() + 0.85, 9, color, 1.0)
		"double_echo":
			canvas.draw_arc(center - side * radius * 0.35, radius * 0.65, 0.0, TAU, 10, color, 1.0)
			canvas.draw_arc(center + side * radius * 0.35, radius * 0.65, 0.0, TAU, 10, color, 1.5)
		"broken_orbit":
			canvas.draw_arc(center, radius, -2.6, -0.2, 8, color, 1.5)
			canvas.draw_arc(center, radius, 0.55, 2.3, 7, color, 1.5)
			canvas.draw_circle(center + forward * radius, radius * 0.18, color)
		"concentric_weight":
			canvas.draw_arc(center, radius, 0.0, TAU, 12, color, 1.5)
			canvas.draw_arc(center, radius * 0.48, 0.0, TAU, 10, color, 1.5)
			canvas.draw_line(center + side * radius, center + side * radius * 1.35, color, 2.0)
		"offset_hour":
			canvas.draw_arc(center, radius, 0.0, TAU, 12, color, 1.5)
			canvas.draw_line(center, center + forward * radius * 0.78, color, 1.5)
			canvas.draw_line(center, center + side * radius * 0.55, color, 1.5)
		_:
			return false
	return true


static func _closed(points: PackedVector2Array) -> PackedVector2Array:
	var result := points.duplicate()
	if not result.is_empty():
		result.append(result[0])
	return result
