extends FluxTestSuite


const BootstrapScript: Script = preload("res://src/app/bootstrap.gd")


func run() -> int:
	InputRouter.ensure_input_map()
	for action: StringName in [
		&"move_left", &"move_right", &"move_up", &"move_down",
		&"aim_left", &"aim_right", &"aim_up", &"aim_down",
		&"sprint", &"jump", &"technique", &"primary", &"active_1",
		&"reset_match", &"toggle_debug_overlay", &"toggle_tick_rate",
		&"toggle_movement_reference", &"toggle_pov_mode",
		&"adjust_pov_angle", &"adjust_pov_range",
	]:
		check(InputMap.has_action(action), "input action exists: %s" % action)
		check(not InputMap.action_get_events(action).is_empty(), "input action has a default: %s" % action)
	check(InputMap.action_get_events(&"primary").size() >= 3, "primary supports mouse, keyboard, and controller trigger")
	check(InputMap.action_get_events(&"active_1").size() >= 3, "active one supports mouse, keyboard, and controller button")
	_test_capture_pointer_parser()
	return finish("input-router")


func _test_capture_pointer_parser() -> void:
	var canvas := Vector2i(2560, 1440)
	equal(BootstrapScript.parse_capture_pointer("--capture-pointer=1280,720", canvas), Vector2i(1280, 720), "capture pointer accepts an in-campus world point")
	equal(BootstrapScript.parse_capture_pointer("--other=1280,720", canvas), Vector2i(-1, -1), "unrelated arguments do not enable capture pointer")
	equal(BootstrapScript.parse_capture_pointer("--capture-pointer=bad,720", canvas), Vector2i(-1, -1), "capture pointer rejects malformed coordinates")
	equal(BootstrapScript.parse_capture_pointer("--capture-pointer=-1,720", canvas), Vector2i(-1, -1), "capture pointer rejects negative coordinates")
	equal(BootstrapScript.parse_capture_pointer("--capture-pointer=2560,720", canvas), Vector2i(-1, -1), "capture pointer rejects the exclusive canvas boundary")
