class_name SightOcclusion
extends RefCounted


static func shadow_polygon(origin: Vector2, occluder: Rect2, outer_distance: float) -> PackedVector2Array:
	if outer_distance <= 0.0 or occluder.size.x <= 0.0 or occluder.size.y <= 0.0 or occluder.has_point(origin):
		return PackedVector2Array()
	var corners := PackedVector2Array([
		occluder.position,
		Vector2(occluder.end.x, occluder.position.y),
		occluder.end,
		Vector2(occluder.position.x, occluder.end.y),
	])
	var center_angle: float = (occluder.get_center() - origin).angle()
	var minimum_delta := INF
	var maximum_delta := -INF
	var minimum_corner := Vector2.ZERO
	var maximum_corner := Vector2.ZERO
	for corner: Vector2 in corners:
		var delta: float = wrapf((corner - origin).angle() - center_angle, -PI, PI)
		if delta < minimum_delta:
			minimum_delta = delta
			minimum_corner = corner
		if delta > maximum_delta:
			maximum_delta = delta
			maximum_corner = corner
	var minimum_ray := minimum_corner - origin
	var maximum_ray := maximum_corner - origin
	if minimum_ray.length_squared() <= 0.01 or maximum_ray.length_squared() <= 0.01:
		return PackedVector2Array()
	return PackedVector2Array([
		minimum_corner,
		origin + minimum_ray.normalized() * outer_distance,
		origin + maximum_ray.normalized() * outer_distance,
		maximum_corner,
	])
