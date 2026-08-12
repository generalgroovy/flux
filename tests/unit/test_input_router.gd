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
	check(BootstrapScript.has_reconnect_smoke_argument("--farflow-smoke-reconnect"), "diagnostic reconnect smoke switch parses exactly")
	check(not BootstrapScript.has_reconnect_smoke_argument("--farflow-smoke-reconnect=true"), "diagnostic reconnect smoke switch fails closed on alternate syntax")
	check(BootstrapScript.has_hearth_smoke_argument("--farflow-smoke-hearth"), "diagnostic Hearth smoke switch parses exactly")
	check(not BootstrapScript.has_hearth_smoke_argument("--farflow-smoke-hearth=true"), "diagnostic Hearth smoke switch fails closed on alternate syntax")
	check(BootstrapScript.has_round_smoke_argument("--farflow-smoke-round"), "diagnostic court smoke switch parses exactly")
	check(not BootstrapScript.has_round_smoke_argument("--farflow-smoke-round=true"), "diagnostic court smoke switch fails closed on alternate syntax")
	check(BootstrapScript.has_rematch_smoke_argument("--farflow-smoke-rematch"), "diagnostic rematch smoke switch parses exactly")
	check(not BootstrapScript.has_rematch_smoke_argument("--farflow-smoke-rematch=true"), "diagnostic rematch smoke switch fails closed on alternate syntax")
	check(BootstrapScript.has_steward_smoke_argument("--farflow-smoke-steward"), "diagnostic stewardship smoke switch parses exactly")
	check(not BootstrapScript.has_steward_smoke_argument("--farflow-smoke-steward=true"), "diagnostic stewardship smoke switch fails closed on alternate syntax")
	check(BootstrapScript.reconnect_smoke_prerequisites_met(false, false, false, false), "standalone reconnect smoke may begin after its first snapshot")
	check(not BootstrapScript.reconnect_smoke_prerequisites_met(true, false, true, true), "combined smoke waits until the reliable social request is sent")
	check(not BootstrapScript.reconnect_smoke_prerequisites_met(true, true, true, false), "combined smoke waits for authoritative movement confirmation")
	check(BootstrapScript.reconnect_smoke_prerequisites_met(true, true, true, true), "combined smoke leaves only after interaction is sent and movement passes")
	check(not BootstrapScript.reconnect_smoke_prerequisites_met(true, true, true, true, true, false), "combined smoke waits for shared Hearth start")
	check(BootstrapScript.reconnect_smoke_prerequisites_met(true, true, true, true, true, true), "combined smoke leaves after shared Hearth start is received")
	equal(BootstrapScript.parse_session_charter("--session-charter=SPARRING_CIRCLE"), "sparring_circle", "diagnostic charter override is case-insensitive")
	equal(BootstrapScript.parse_session_charter("--session-charter=unbounded"), "", "unknown diagnostic charter fails closed")
	equal(BootstrapScript.parse_session_charter("--other=duel_knot"), "", "unrelated argument cannot change the charter")
	equal(BootstrapScript.parse_capture_spawn("--capture-spawn=2380,800", canvas), Vector2i(2380, 800), "capture-only spawn accepts an in-campus station point")
	equal(BootstrapScript.parse_capture_spawn("--capture-spawn=2560,800", canvas), Vector2i(-1, -1), "capture-only spawn rejects the canvas boundary")
	equal(BootstrapScript.parse_capture_spawn("--other=2380,800", canvas), Vector2i(-1, -1), "unrelated argument cannot change capture spawn")
	var capture_stations := {"farflow-charter": {}}
	equal(BootstrapScript.parse_capture_expanded_station("--capture-expanded-station=farflow-charter", capture_stations), "farflow-charter", "capture-only station expansion accepts an authored station")
	equal(BootstrapScript.parse_capture_expanded_station("--capture-expanded-station=missing", capture_stations), "", "capture-only station expansion rejects unknown stations")
	equal(BootstrapScript.parse_capture_expanded_station("--other=farflow-charter", capture_stations), "", "unrelated argument cannot expand a station")
