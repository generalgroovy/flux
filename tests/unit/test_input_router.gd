extends FluxTestSuite


const BootstrapScript: Script = preload("res://src/app/bootstrap.gd")


func run() -> int:
	for action: StringName in [&"jump", &"primary", &"sprint", &"slide", &"interact", &"emote"]:
		if InputMap.has_action(action):
			InputMap.erase_action(action)
	InputRouter.ensure_input_map()
	for action: StringName in [
		&"move_left", &"move_right", &"move_up", &"move_down",
		&"aim_left", &"aim_right", &"aim_up", &"aim_down",
		&"sprint", &"slide", &"jump", &"technique", &"interact", &"emote", &"primary", &"active_1",
		&"reset_match", &"toggle_debug_overlay", &"toggle_tick_rate",
		&"toggle_movement_reference", &"toggle_pov_mode",
		&"adjust_pov_angle", &"adjust_pov_range",
	]:
		check(InputMap.has_action(action), "input action exists: %s" % action)
		check(not InputMap.action_get_events(action).is_empty(), "input action has a default: %s" % action)
	equal(_keycodes(&"jump"), [KEY_SPACE], "jump defaults to Space exactly once")
	equal(_keycodes(&"sprint"), [KEY_SHIFT], "sprint defaults to Shift")
	equal(_keycodes(&"slide"), [KEY_CTRL, KEY_C], "slide defaults to Ctrl with a C alias")
	equal(_keycodes(&"interact"), [KEY_F], "walk-up interaction defaults to F")
	check(_has_joy_button(&"interact", JOY_BUTTON_Y), "walk-up interaction retains a controller face button")
	equal(_keycodes(&"emote"), [KEY_T], "social speech defaults to T")
	check(_has_joy_button(&"emote", JOY_BUTTON_DPAD_UP), "social speech retains a controller d-pad shortcut")
	check(not _keycodes(&"primary").has(KEY_SPACE), "primary has no Space keyboard alias")
	check(_has_mouse_button(&"primary", MOUSE_BUTTON_LEFT), "primary retains left mouse")
	check(InputMap.action_get_events(&"primary").size() >= 2, "primary supports mouse and controller trigger")
	check(InputMap.action_get_events(&"active_1").size() >= 3, "active one supports mouse, keyboard, and controller button")
	_test_capture_pointer_parser()
	return finish("input-router")


func _keycodes(action: StringName) -> Array[int]:
	var result: Array[int] = []
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey:
			result.append(event.physical_keycode)
	return result


func _has_mouse_button(action: StringName, button: int) -> bool:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventMouseButton and event.button_index == button:
			return true
	return false


func _has_joy_button(action: StringName, button: int) -> bool:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventJoypadButton and event.button_index == button:
			return true
	return false


func _test_capture_pointer_parser() -> void:
	var canvas := Vector2i(2560, 1440)
	equal(BootstrapScript.parse_capture_pointer("--capture-pointer=1280,720", canvas), Vector2i(1280, 720), "capture pointer accepts an in-campus world point")
	equal(BootstrapScript.parse_capture_pointer("--other=1280,720", canvas), Vector2i(-1, -1), "unrelated arguments do not enable capture pointer")
	equal(BootstrapScript.parse_capture_pointer("--capture-pointer=bad,720", canvas), Vector2i(-1, -1), "capture pointer rejects malformed coordinates")
	equal(BootstrapScript.parse_capture_pointer("--capture-pointer=-1,720", canvas), Vector2i(-1, -1), "capture pointer rejects negative coordinates")
	equal(BootstrapScript.parse_capture_pointer("--capture-pointer=2560,720", canvas), Vector2i(-1, -1), "capture pointer rejects the exclusive canvas boundary")
	equal(BootstrapScript.parse_farflow_mode("--farflow=host"), "host", "diagnostic Farflow host mode parses")
	equal(BootstrapScript.parse_farflow_mode("--farflow=JOIN"), "join", "diagnostic Farflow join mode is case-insensitive")
	equal(BootstrapScript.parse_farflow_mode("--farflow=relay"), "", "unknown Farflow mode fails closed")
	check(BootstrapScript.has_emote_smoke_argument("--farflow-smoke-emote"), "diagnostic social smoke switch parses exactly")
	check(not BootstrapScript.has_emote_smoke_argument("--farflow-smoke-emote=true"), "diagnostic social smoke switch fails closed on alternate syntax")
	check(BootstrapScript.has_prediction_smoke_argument("--farflow-smoke-prediction"), "diagnostic prediction smoke switch parses exactly")
	check(not BootstrapScript.has_prediction_smoke_argument("--farflow-smoke-prediction=true"), "diagnostic prediction smoke switch fails closed on alternate syntax")
	equal(BootstrapScript.snapshot_tick_interval(60), 1, "60 Hz match publishes 60 snapshots per second")
	equal(BootstrapScript.snapshot_tick_interval(120), 2, "120 Hz match publishes 60 snapshots per second")
	equal(BootstrapScript.snapshot_tick_interval(90), 0, "unsupported match cadence cannot derive a snapshot interval")
