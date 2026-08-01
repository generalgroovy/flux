extends FluxTestSuite


func run() -> int:
	InputRouter.ensure_input_map()
	for action: StringName in [
		&"move_left", &"move_right", &"move_up", &"move_down",
		&"aim_left", &"aim_right", &"aim_up", &"aim_down",
		&"sprint", &"jump", &"technique", &"primary", &"active_1",
		&"reset_match", &"toggle_tick_rate",
	]:
		check(InputMap.has_action(action), "input action exists: %s" % action)
		check(not InputMap.action_get_events(action).is_empty(), "input action has a default: %s" % action)
	check(InputMap.action_get_events(&"primary").size() >= 3, "primary supports mouse, keyboard, and controller trigger")
	check(InputMap.action_get_events(&"active_1").size() >= 3, "active one supports mouse, keyboard, and controller button")
	return finish("input-router")
