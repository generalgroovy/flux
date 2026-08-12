extends FluxTestSuite


func run() -> int:
	_test_right_facing_shadow()
	_test_left_facing_shadow()
	_test_invalid_shadow_inputs()
	return finish("sight-occlusion")


func _test_right_facing_shadow() -> void:
	var shadow := SightOcclusion.shadow_polygon(Vector2.ZERO, Rect2(100, -20, 40, 40), 1000.0)
	equal(shadow.size(), 4, "right-side building produces one bounded shadow quad")
	var boundary := Rect2(100, -20, 40, 40).grow(0.1)
	check(boundary.has_point(shadow[0]), "first tangent belongs to the building boundary")
	check(boundary.has_point(shadow[3]), "second tangent belongs to the building boundary")
	check(shadow[1].x > shadow[0].x and shadow[2].x > shadow[3].x, "right-side shadow projects away from the viewer")
	check(is_equal_approx(shadow[1].length(), 1000.0), "first shadow ray reaches the bounded outer distance")
	check(is_equal_approx(shadow[2].length(), 1000.0), "second shadow ray reaches the bounded outer distance")


func _test_left_facing_shadow() -> void:
	var shadow := SightOcclusion.shadow_polygon(Vector2(300, 100), Rect2(100, 80, 40, 40), 800.0)
	equal(shadow.size(), 4, "left-side building produces one bounded shadow quad")
	check(shadow[1].x < shadow[0].x and shadow[2].x < shadow[3].x, "left-side shadow projects away from the viewer")


func _test_invalid_shadow_inputs() -> void:
	equal(SightOcclusion.shadow_polygon(Vector2(10, 10), Rect2(0, 0, 20, 20), 500.0).size(), 0, "viewer inside building produces no invalid polygon")
	equal(SightOcclusion.shadow_polygon(Vector2.ZERO, Rect2(20, 20, 0, 10), 500.0).size(), 0, "empty building produces no shadow")
	equal(SightOcclusion.shadow_polygon(Vector2.ZERO, Rect2(20, 20, 10, 10), 0.0).size(), 0, "non-positive range produces no shadow")
