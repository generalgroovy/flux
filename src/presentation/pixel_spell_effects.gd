class_name PixelSpellEffects
extends RefCounted

# Rendering only. A material frame never determines attack admission or coverage.
const Library = preload("res://src/presentation/pixel_magic_library.gd")
const Geometry = preload("res://src/presentation/pixel_effect_geometry.gd")
const ELEMENTS := ["earth", "fire", "water", "wind", "ice", "charge", "light", "dark"]
const MAX_FIELD_STAMPS := 64
const MAX_SPRAY_STAMPS := 24
var library: RefCounted
var geometry := Geometry.new()
var collision: CollisionWorld


func _init(shared_library: RefCounted = null) -> void:
	library = shared_library if shared_library != null else Library.default_library()


func ready() -> bool:
	return library != null and library.asset_count() > 0


func begin_frame(_config: SimConfig, collision_world: CollisionWorld) -> void:
	collision = collision_world


static func asset_id(element: String, effect: String, reduced: bool) -> String:
	return Library.element_asset_id(ELEMENTS.find(element) + 1, effect, reduced)


static func lifetime_age(lifetime_ms: int, remaining_ticks: int) -> int:
	return maxi(0, ceili(float(lifetime_ms) * 0.12) - remaining_ticks)


static func accepted_release(event: Dictionary) -> Dictionary:
	var kind := String(event.get("type",""))
	if kind not in ["projectile_spawned","field_spawned","beam_fired","spray_fired"]:
		return {}
	if kind == "projectile_spawned" and int(event.get("lane_index",0)) != 0:
		return {} # One bare-hand release per real cast, not one per Burst lane.
	var owner_id := int(event.get("owner_id",0))
	var wire_id := int(event.get("source_wire_id",event.get("wire_id",0)))
	if owner_id <= 0 or wire_id <= 0:
		return {}
	# Optical continuations share this key; caller deduplicates within the same
	# accepted simulation tick and attaches to that owner's current hand anchor.
	return {"owner_id":owner_id,"wire_id":wire_id,"dedup_key":"%d:%d" % [owner_id,wire_id]}


func material_color(element: String, index: int = 3) -> Color:
	var entry: Dictionary = library.asset(asset_id(element,"field_tile",false))
	var palette: Array = entry.get("palette_rgba",[])
	return Color(String(palette[index])) if palette.size() > index else Color("cddbc9")


func flight(canvas: CanvasItem, element: String, position: Vector2, direction: Vector2, radius: float, age: int, reduced: bool) -> bool:
	if not ready() or element not in ELEMENTS or radius <= 0.0 or age < 0:
		return false
	var scale := radius / 8.0 # Authored core envelope is 16 px, not its 32 px gutter cell.
	if not reduced and direction.length_squared() > 0.0 and library.take_decoration(asset_id(element,"flight_tail",reduced)):
		library.draw_stamp(canvas, asset_id(element, "flight_tail", reduced), position - direction.normalized() * radius, age, direction.angle(), 0.32, scale)
	return library.draw_stamp(canvas, asset_id(element, "flight", reduced), position, age, 0.0, 1.0, scale)


func hand(canvas: CanvasItem, element: String, position: Vector2, age: int, reduced: bool, effect: String = "hand_prepare") -> bool:
	return ready() and library.draw_stamp(canvas, asset_id(element, effect, reduced), position, age)


func impact(canvas: CanvasItem, element: String, position: Vector2, age: int, reduced: bool) -> bool:
	if not ready() or element not in ELEMENTS or age < 0:
		return false
	# A completed cosmetic sequence is handled, not a request for a legacy halo.
	library.draw_stamp(canvas, asset_id(element, "impact", reduced), position, age)
	return true


static func spray_polygon(start: Vector2, endpoint: Vector2, cosine_squared: int) -> PackedVector2Array:
	var lane := endpoint - start
	var points := PackedVector2Array()
	if lane.length_squared() <= 0.0:
		return points
	var half_angle := acos(sqrt(clampf(float(cosine_squared) / 1000000.0, 0.0, 1.0)))
	points.append(start)
	for index: int in range(25):
		points.append(start + Vector2.from_angle(lane.angle() - half_angle + half_angle * 2.0 * float(index) / 24.0) * lane.length())
	return points


func beam(canvas: CanvasItem, element: String, start: Vector2, endpoint: Vector2, radius: float, age: int, reduced: bool, opacity: float) -> bool:
	if not ready() or element not in ELEMENTS:
		return false
	canvas.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var lane := endpoint - start
	if lane.length_squared() <= 0.0 or radius <= 0.0:
		return true
	var direction := lane.normalized()
	var side := direction.orthogonal() * radius
	var mask := PackedVector2Array([start-side, endpoint-side, endpoint+side, start+side])
	var frame: Dictionary = library.sample(asset_id(element, "beam_body", reduced), age)
	for index: int in range(ceili(lane.length() / 16.0)):
		Geometry.draw_clipped_frame(canvas, frame, start + direction * float(index * 16), [mask], opacity, lane.angle())
	for cap: String in ["beam_start", "beam_end"]:
		var cap_frame: Dictionary = library.sample(asset_id(element, cap, reduced), age)
		Geometry.draw_clipped_frame(canvas, cap_frame, start if cap == "beam_start" else endpoint, [mask], opacity)
	# These two one-pixel rails are information, not the magic material.
	canvas.draw_line(start-side, endpoint-side, Color(material_color(element), opacity * 0.85), 1.0, false)
	canvas.draw_line(start+side, endpoint+side, Color(material_color(element), opacity * 0.85), 1.0, false)
	return true


func spray(canvas: CanvasItem, element: String, start: Vector2, endpoint: Vector2, cosine_squared: int, age: int, reduced: bool, opacity: float, clearance_radius: float = 0.0) -> bool:
	if not ready() or element not in ELEMENTS:
		return false
	canvas.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var mask := spray_polygon(start, endpoint, cosine_squared)
	if mask.is_empty():
		return true
	var bounds := Rect2(start,Vector2.ZERO)
	for point: Vector2 in mask:
		bounds = bounds.expand(point)
	var clipped: Dictionary = geometry.clip_spell_mask([mask],start,bounds,collision,clearance_radius)
	var polygons: Array = clipped.get("polygons",[])
	if polygons.is_empty():
		return true
	var frame: Dictionary = library.sample(asset_id(element, "spray_grain", reduced), age)
	var lane := endpoint - start
	var half_angle := acos(sqrt(clampf(float(cosine_squared) / 1000000.0, 0.0, 1.0)))
	var count := 12 if reduced else MAX_SPRAY_STAMPS
	for index: int in range(count):
		if not library.take_decoration(asset_id(element,"spray_grain",reduced)):
			break
		# Stable sparse rays with continuous outward phase; no invented extra hits.
		var ray := -0.88 + float(index % 5) * 0.44
		var distance_ratio := fmod(float(index) * 0.381966 + float(age) / 36.0, 1.0)
		var anchor := start + lane.rotated(ray * half_angle) * distance_ratio
		Geometry.draw_clipped_frame(canvas, frame, anchor, polygons, opacity * 0.9)
	for boundary: PackedVector2Array in clipped.get("boundaries",[]):
		canvas.draw_polyline(boundary, Color(material_color(element), opacity * 0.65), 1.0, false)
	return true


func field(canvas: CanvasItem, element: String, center: Vector2, radius: float, age: int, reduced: bool) -> bool:
	if not ready() or element not in ELEMENTS or radius <= 0.0:
		return false
	canvas.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var mask := Geometry.circle_polygon(center, radius)
	var frame: Dictionary = library.sample(asset_id(element, "field_tile", reduced), age)
	var minimum := ((center - Vector2.ONE * radius) / 32.0).floor() * 32.0
	var maximum := center + Vector2.ONE * radius
	var count := 0
	for y: int in range(floori(minimum.y), ceili(maximum.y), 32):
		for x: int in range(floori(minimum.x), ceili(maximum.x), 32):
			if count >= MAX_FIELD_STAMPS or not library.take_decoration(asset_id(element,"field_tile",reduced)):
				break
			Geometry.draw_clipped_frame(canvas, frame, Vector2(x + 16, y + 16), [mask], 0.06 if reduced else 0.12)
			count += 1
	var boundary := mask.duplicate()
	boundary.append(mask[0])
	canvas.draw_polyline(boundary, Color("16212ae6"), 3.0, false)
	canvas.draw_polyline(boundary, Color(material_color(element),0.90), 1.0, false)
	return true
