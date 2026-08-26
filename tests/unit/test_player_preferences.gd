extends FluxTestSuite


func run() -> int:
	_test_defaults_and_presets()
	_test_validation()
	_test_schema_v1_migration_and_reduced_motion()
	_test_keyboard_bindings()
	_test_persistence_round_trip()
	_test_movement_transforms()
	return finish("player-preferences")


func _test_defaults_and_presets() -> void:
	var preferences := PlayerPreferences.new()
	equal(preferences.movement_reference, PlayerPreferences.MOVEMENT_WORLD_RELATIVE, "world-relative movement is the safe default")
	equal(preferences.pov_mode, PlayerPreferences.POV_FULL, "full view is the safe default")
	equal(preferences.pov_angle_degrees, 120, "cone angle remains ready when cone view is selected")
	equal(preferences.pov_range, 720, "cone range remains ready when cone view is selected")
	equal(preferences.camera_zoom_percent, 75, "the default camera exposes more connected movement space")
	equal(PlayerPreferences.SCHEMA_VERSION, 9, "player preferences save schema v9")
	equal(preferences.farflow_join_address, "127.0.0.1", "local Farflow is the safe address default")
	equal(preferences.keyboard_bindings[&"sprint"], KEY_SHIFT, "Shift is the production-default sprint key")
	equal(preferences.keyboard_bindings[&"slide"], KEY_C, "C is the persisted slide key")
	equal(preferences.keyboard_bindings[&"jump"], KEY_SPACE, "Space is the production-default jump key")
	equal(preferences.keyboard_bindings[&"primary"], 0, "primary has no default keyboard alias")
	equal(preferences.keyboard_bindings[&"interact"], KEY_F, "interact participates in conflict-safe persistence")
	for button_index: int in range(PlayerState.SPELL_BUTTON_COUNT):
		equal(preferences.keyboard_bindings[StringName("spell_%d" % (button_index + 1))], KEY_1 + button_index, "spell button %d defaults to its number key" % (button_index + 1))
	equal(preferences.keyboard_bindings[&"spell_layer_ctrl"], KEY_CTRL, "Ctrl defaults to the middle four-position layer")
	equal(preferences.keyboard_bindings[&"spell_layer_alt"], KEY_ALT, "Alt defaults to the final four-position layer")
	equal(preferences.mouse_bindings[&"jump"], MOUSE_BUTTON_WHEEL_UP, "wheel up is the alternate jump input")
	equal(preferences.mouse_bindings[&"slide"], MOUSE_BUTTON_WHEEL_DOWN, "wheel down is the alternate slide and fast-fall input")
	equal(String((preferences.controller_bindings[&"jump"] as Dictionary).get("kind")), "button", "controller jump defaults to a button")
	check(not preferences.reduced_motion, "reduced motion defaults off")
	check(not preferences.high_contrast, "high contrast defaults off")
	check(preferences.apply_control_preset(PlayerPreferences.MOVEMENT_AIM_RELATIVE), "aim-relative preset is accepted")
	equal(preferences.movement_reference, PlayerPreferences.MOVEMENT_AIM_RELATIVE, "aim-relative preset applies")
	check(preferences.apply_control_preset(PlayerPreferences.MOVEMENT_WORLD_RELATIVE), "world-relative preset is accepted")
	check(not preferences.apply_control_preset("camera_relative"), "unknown movement preset fails closed")


func _test_validation() -> void:
	var valid := {
		"schema_version": 9,
		"movement_reference": "aim_relative",
		"pov_mode": "cone",
		"pov_angle_degrees": 360,
		"pov_range": 2048,
		"camera_zoom_percent": 50,
		"reduced_motion": false,
		"high_contrast": false,
		"farflow_join_address": "friend.example.test",
	}
	var preferences := PlayerPreferences.new()
	check(preferences.apply_dictionary(valid), "valid exact settings load")
	equal(preferences.pov_angle_degrees, 360, "360-degree ranged view is legal")
	equal(preferences.pov_range, 2048, "custom view length is legal")
	equal(preferences.farflow_join_address, "friend.example.test", "valid Farflow address loads")
	for mutation: Dictionary in [
		{"schema_version": 10},
		{"movement_reference": "camera_relative"},
		{"pov_mode": "wallhack"},
		{"pov_angle_degrees": 14},
		{"pov_angle_degrees": 361},
		{"pov_angle_degrees": 90.5},
		{"pov_range": 159},
		{"pov_range": 4097},
		{"camera_zoom_percent": 49},
		{"camera_zoom_percent": 101},
		{"camera_zoom_percent": 75.5},
		{"reduced_motion": "false"},
		{"high_contrast": "false"},
		{"farflow_join_address": ""},
		{"farflow_join_address": "bad address"},
		{"farflow_join_address": "https://friend.example"},
	]:
		var candidate: Dictionary = valid.duplicate(true)
		for key: Variant in mutation:
			candidate[key] = mutation[key]
		var rejected := PlayerPreferences.new()
		check(not rejected.apply_dictionary(candidate), "invalid preference mutation fails closed: %s" % mutation)
	check(preferences.set_pov_mode(PlayerPreferences.POV_FULL), "full POV is accepted")
	check(preferences.set_pov_mode(PlayerPreferences.POV_CONE), "cone POV is accepted")
	check(not preferences.set_pov_mode("omniscient"), "unknown POV mode fails closed")
	preferences.set_pov_angle_degrees(-500)
	equal(preferences.pov_angle_degrees, PlayerPreferences.MIN_POV_ANGLE_DEGREES, "runtime angle clamps to minimum")
	preferences.set_pov_angle_degrees(500)
	equal(preferences.pov_angle_degrees, PlayerPreferences.MAX_POV_ANGLE_DEGREES, "runtime angle clamps to 360")
	preferences.set_pov_range(1)
	equal(preferences.pov_range, PlayerPreferences.MIN_POV_RANGE, "runtime range clamps to minimum")
	preferences.set_pov_range(99999)
	equal(preferences.pov_range, PlayerPreferences.MAX_POV_RANGE, "runtime range clamps to maximum")
	preferences.set_camera_zoom_percent(1)
	equal(preferences.camera_zoom_percent, PlayerPreferences.MIN_CAMERA_ZOOM_PERCENT, "runtime camera zoom clamps to its widest view")
	preferences.set_camera_zoom_percent(999)
	equal(preferences.camera_zoom_percent, PlayerPreferences.MAX_CAMERA_ZOOM_PERCENT, "runtime camera zoom clamps to its closest view")


func _base_preferences(schema_version: int, bindings: Dictionary) -> Dictionary:
	var result := {
		"schema_version": schema_version,
		"movement_reference": PlayerPreferences.MOVEMENT_WORLD_RELATIVE,
		"pov_mode": PlayerPreferences.POV_FULL,
		"pov_angle_degrees": PlayerPreferences.DEFAULT_POV_ANGLE_DEGREES,
		"pov_range": PlayerPreferences.DEFAULT_POV_RANGE,
		"keyboard_bindings": bindings,
	}
	if schema_version >= 7:
		result["camera_zoom_percent"] = PlayerPreferences.DEFAULT_CAMERA_ZOOM_PERCENT
	if schema_version >= 8:
		result["high_contrast"] = false
	if schema_version >= 9:
		result["farflow_join_address"] = PlayerPreferences.DEFAULT_FARFLOW_JOIN_ADDRESS
	return result


func _test_schema_v1_migration_and_reduced_motion() -> void:
	var legacy_defaults: Dictionary = PlayerPreferences.LEGACY_DEFAULT_KEYBOARD_BINDINGS.duplicate()
	var migrated := PlayerPreferences.new()
	check(migrated.apply_dictionary(_base_preferences(1, legacy_defaults)), "schema-v1 defaults migrate")
	equal(migrated.keyboard_bindings[&"jump"], KEY_SPACE, "schema-v1 default C migrates to Space jump")
	equal(migrated.keyboard_bindings[&"primary"], 0, "schema-v1 default Space primary alias is removed")
	equal(migrated.keyboard_bindings[&"sprint"], KEY_SHIFT, "schema-v1 Alt sprint migrates to Shift")
	equal(migrated.keyboard_bindings[&"slide"], KEY_C, "schema-v1 gains the C slide action")
	equal(migrated.keyboard_bindings[&"interact"], KEY_F, "schema-v1 gains conflict-safe interact binding")
	check(not migrated.reduced_motion, "schema-v1 reduced_motion defaults false")
	var schema_two := PlayerPreferences.new()
	check(schema_two.apply_dictionary(_base_preferences(2, PlayerPreferences.SCHEMA_V2_DEFAULT_KEYBOARD_BINDINGS)), "schema-v2 defaults migrate")
	equal(schema_two.keyboard_bindings[&"sprint"], KEY_SHIFT, "schema-v2 Alt sprint migrates to Shift")
	equal(schema_two.keyboard_bindings[&"slide"], KEY_C, "schema-v2 gains the C slide action")
	var schema_three := PlayerPreferences.new()
	check(schema_three.apply_dictionary(_base_preferences(3, PlayerPreferences.SCHEMA_V3_DEFAULT_KEYBOARD_BINDINGS)), "schema-v3 defaults migrate")
	equal(schema_three.keyboard_bindings[&"slide"], KEY_C, "schema-v3 Ctrl slide migrates to C")
	equal(schema_three.mouse_bindings, PlayerPreferences.DEFAULT_MOUSE_BINDINGS, "schema-v3 gains safe mouse and wheel defaults")
	var schema_four_data := _base_preferences(4, PlayerPreferences.DEFAULT_KEYBOARD_BINDINGS)
	schema_four_data["mouse_bindings"] = PlayerPreferences.SCHEMA_V4_DEFAULT_MOUSE_BINDINGS
	var schema_four := PlayerPreferences.new()
	check(schema_four.apply_dictionary(schema_four_data), "schema-v4 mouse defaults migrate")
	equal(schema_four.mouse_bindings[&"jump"], MOUSE_BUTTON_WHEEL_UP, "schema-v4 retains wheel-up jump")
	equal(schema_four.controller_bindings, PlayerPreferences.DEFAULT_CONTROLLER_BINDINGS, "schema-v4 gains safe controller defaults")
	var schema_five_data := _base_preferences(5, {
		&"jump": KEY_SPACE,
		&"slide": KEY_C,
	})
	var schema_five := PlayerPreferences.new()
	check(schema_five.apply_dictionary(schema_five_data), "schema-v5 bindings migrate")
	equal(schema_five.keyboard_bindings[&"spell_1"], KEY_1, "schema-v5 gains spell button 1")
	equal(schema_five.keyboard_bindings[&"spell_layer_ctrl"], KEY_CTRL, "schema-v5 gains the Ctrl weave layer")
	equal(schema_five.camera_zoom_percent, PlayerPreferences.DEFAULT_CAMERA_ZOOM_PERCENT, "schema-v5 gains the wider camera default")
	var schema_six := PlayerPreferences.new()
	check(schema_six.apply_dictionary(_base_preferences(6, {&"spell_1": KEY_CTRL, &"spell_5": KEY_5})), "schema-v6 spell bindings migrate")
	equal(schema_six.keyboard_bindings[&"spell_1"], KEY_CTRL, "schema-v6 custom Ctrl binding is preserved")
	equal(schema_six.keyboard_bindings[&"spell_layer_ctrl"], 0, "new Ctrl layer stays unbound when a legacy action already owns Ctrl")
	check(not schema_six.keyboard_bindings.has(&"spell_5"), "retired fifth physical button is removed during migration")

	var explicit: Dictionary = legacy_defaults.duplicate()
	explicit[&"jump"] = KEY_J
	explicit[&"primary"] = KEY_P
	var preserved := PlayerPreferences.new()
	check(preserved.apply_dictionary(_base_preferences(1, explicit)), "schema-v1 explicit bindings migrate")
	equal(preserved.keyboard_bindings[&"jump"], KEY_J, "explicit jump override is preserved")
	equal(preserved.keyboard_bindings[&"primary"], KEY_P, "explicit primary override is preserved")

	var current: Dictionary = migrated.to_dictionary()
	current["reduced_motion"] = true
	var loaded := PlayerPreferences.new()
	check(loaded.apply_dictionary(current), "schema-v9 preferences load")
	check(loaded.reduced_motion, "schema-v9 reduced_motion loads")
	check(not loaded.high_contrast, "schema-v9 high contrast defaults off")
	current["high_contrast"] = true
	check(loaded.apply_dictionary(current), "schema-v9 high contrast loads")
	check(loaded.high_contrast, "schema-v9 high contrast is retained")
	var before: Dictionary = loaded.to_dictionary().duplicate(true)
	var malformed: Dictionary = current.duplicate(true)
	malformed["reduced_motion"] = "false"
	check(not loaded.apply_dictionary(malformed), "non-boolean reduced_motion fails closed")
	equal(loaded.to_dictionary(), before, "invalid reduced_motion never partially mutates preferences")
	malformed = current.duplicate(true)
	malformed["high_contrast"] = "true"
	check(not loaded.apply_dictionary(malformed), "non-boolean high_contrast fails closed")
	equal(loaded.to_dictionary(), before, "invalid high_contrast never partially mutates preferences")
	var schema_seven := PlayerPreferences.new()
	check(schema_seven.apply_dictionary(_base_preferences(7, PlayerPreferences.DEFAULT_KEYBOARD_BINDINGS)), "schema-v7 preferences migrate")
	check(not schema_seven.high_contrast, "schema-v7 migration gains safe standard contrast")
	var schema_eight := PlayerPreferences.new()
	check(schema_eight.apply_dictionary(_base_preferences(8, PlayerPreferences.DEFAULT_KEYBOARD_BINDINGS)), "schema-v8 preferences migrate")
	equal(schema_eight.farflow_join_address, PlayerPreferences.DEFAULT_FARFLOW_JOIN_ADDRESS, "schema-v8 gains the local Farflow address default")


func _test_persistence_round_trip() -> void:
	var path := "user://flux2_player_preferences_test.json"
	var saved := PlayerPreferences.new()
	check(saved.apply_control_preset(PlayerPreferences.MOVEMENT_AIM_RELATIVE), "round-trip control preset applies")
	check(saved.set_pov_mode(PlayerPreferences.POV_CONE), "round-trip POV mode applies")
	saved.set_pov_angle_degrees(225)
	saved.set_pov_range(1360)
	saved.set_camera_zoom_percent(50)
	saved.reduced_motion = true
	saved.high_contrast = true
	saved.farflow_join_address = "192.0.2.44"
	check(saved.save_to_file(path), "preferences save offline")
	var loaded := PlayerPreferences.new()
	check(loaded.load_from_file(path), "preferences load offline")
	equal(loaded.to_dictionary(), saved.to_dictionary(), "saved preferences round-trip exactly")
	var absolute_path: String = ProjectSettings.globalize_path(path)
	check(DirAccess.remove_absolute(absolute_path) == OK, "preference test file is cleaned")


func _test_keyboard_bindings() -> void:
	var remapped: Dictionary[StringName, int] = PlayerPreferences.DEFAULT_KEYBOARD_BINDINGS.duplicate()
	remapped[&"jump"] = KEY_J
	equal(PlayerPreferences.validate_keyboard_bindings(remapped), "", "unique remapped keyboard bindings validate")
	var router := InputRouter.new()
	check(router.configure_keyboard_bindings(remapped), "router applies a valid keyboard remap")
	var jump_keycodes: Array[int] = []
	for event: InputEvent in InputMap.action_get_events(&"jump"):
		if event is InputEventKey:
			jump_keycodes.append(event.physical_keycode)
	equal(jump_keycodes, [KEY_J], "jump keyboard default is replaced without removing controller input")
	check(_mouse_buttons(&"jump").has(MOUSE_BUTTON_WHEEL_UP), "keyboard remap retains wheel-up jump")
	var conflicting: Dictionary[StringName, int] = remapped.duplicate()
	conflicting[&"technique"] = KEY_J
	check(not PlayerPreferences.validate_keyboard_bindings(conflicting).is_empty(), "conflicting key bindings fail closed")
	var unknown: Dictionary = remapped.duplicate()
	unknown[&"developer_cheat"] = KEY_F12
	check(not PlayerPreferences.validate_keyboard_bindings(unknown).is_empty(), "unknown bindable action fails closed")
	remapped[&"jump"] = 0
	equal(PlayerPreferences.validate_keyboard_bindings(remapped), "", "zero explicitly unbinds one keyboard action")
	check(router.configure_keyboard_bindings(PlayerPreferences.DEFAULT_KEYBOARD_BINDINGS), "test restores keyboard defaults")
	var remapped_mouse: Dictionary[StringName, int] = PlayerPreferences.DEFAULT_MOUSE_BINDINGS.duplicate()
	remapped_mouse[&"jump"] = MOUSE_BUTTON_MIDDLE
	check(router.configure_mouse_bindings(remapped_mouse), "router applies a valid mouse remap")
	equal(_mouse_buttons(&"jump"), [MOUSE_BUTTON_MIDDLE], "jump mouse binding is replaced without removing keyboard/controller input")
	var conflicting_mouse: Dictionary[StringName, int] = remapped_mouse.duplicate()
	conflicting_mouse[&"slide"] = MOUSE_BUTTON_MIDDLE
	check(not PlayerPreferences.validate_mouse_bindings(conflicting_mouse).is_empty(), "conflicting mouse bindings fail closed")
	var unknown_mouse: Dictionary = remapped_mouse.duplicate()
	unknown_mouse[&"developer_cheat"] = MOUSE_BUTTON_XBUTTON1
	check(not PlayerPreferences.validate_mouse_bindings(unknown_mouse).is_empty(), "unknown mouse action fails closed")
	remapped_mouse[&"jump"] = 0
	equal(PlayerPreferences.validate_mouse_bindings(remapped_mouse), "", "zero explicitly unbinds one mouse action")
	check(router.configure_mouse_bindings(PlayerPreferences.DEFAULT_MOUSE_BINDINGS), "test restores mouse defaults")
	var remapped_controller: Dictionary = PlayerPreferences.DEFAULT_CONTROLLER_BINDINGS.duplicate(true)
	remapped_controller[&"jump"] = {"kind": "button", "index": JOY_BUTTON_START, "direction": 0}
	check(router.configure_controller_bindings(remapped_controller), "router applies a valid controller remap")
	check(_controller_buttons(&"jump").has(JOY_BUTTON_START), "jump controller binding is replaced without removing keyboard or mouse")
	var conflicting_controller: Dictionary = remapped_controller.duplicate(true)
	conflicting_controller[&"slide"] = remapped_controller[&"jump"]
	check(not PlayerPreferences.validate_controller_bindings(conflicting_controller).is_empty(), "conflicting controller bindings fail closed")
	var malformed_controller: Dictionary = remapped_controller.duplicate(true)
	malformed_controller[&"jump"] = {"kind": "axis", "index": 99, "direction": 1}
	check(not PlayerPreferences.validate_controller_bindings(malformed_controller).is_empty(), "out-of-range controller axis fails closed")
	remapped_controller[&"jump"] = PlayerPreferences.unbound_controller_binding()
	equal(PlayerPreferences.validate_controller_bindings(remapped_controller), "", "controller action can be explicitly unbound")
	check(router.configure_controller_bindings(PlayerPreferences.DEFAULT_CONTROLLER_BINDINGS), "test restores controller defaults")


func _mouse_buttons(action: StringName) -> Array[int]:
	var buttons: Array[int] = []
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventMouseButton:
			buttons.append(event.button_index)
	return buttons


func _controller_buttons(action: StringName) -> Array[int]:
	var buttons: Array[int] = []
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventJoypadButton:
			buttons.append(event.button_index)
	return buttons


func _test_movement_transforms() -> void:
	equal(
		InputRouter.transform_movement(250, -700, 0, 1000, PlayerPreferences.MOVEMENT_WORLD_RELATIVE),
		Vector2i(250, -700),
		"world-relative movement ignores aim",
	)
	equal(
		InputRouter.transform_movement(0, -1000, 1000, 0, PlayerPreferences.MOVEMENT_AIM_RELATIVE),
		Vector2i(1000, 0),
		"aim-relative W follows a right-facing aim",
	)
	equal(
		InputRouter.transform_movement(0, -1000, 0, 1000, PlayerPreferences.MOVEMENT_AIM_RELATIVE),
		Vector2i(0, 1000),
		"aim-relative W follows a downward aim",
	)
	equal(
		InputRouter.transform_movement(1000, 0, 0, -1000, PlayerPreferences.MOVEMENT_AIM_RELATIVE),
		Vector2i(1000, 0),
		"aim-relative D strafes right from an upward aim",
	)
	equal(
		InputRouter.transform_movement(-1000, 0, 1000, 0, PlayerPreferences.MOVEMENT_AIM_RELATIVE),
		Vector2i(0, -1000),
		"aim-relative A strafes above a right-facing aim",
	)
	var router := InputRouter.new()
	check(router.configure_movement_reference(PlayerPreferences.MOVEMENT_AIM_RELATIVE), "router accepts aim-relative configuration")
	check(not router.configure_movement_reference("invalid"), "router rejects invalid movement reference")
