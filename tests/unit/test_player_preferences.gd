extends FluxTestSuite


func run() -> int:
	_test_defaults_and_presets()
	_test_validation()
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
	check(preferences.apply_control_preset(PlayerPreferences.MOVEMENT_AIM_RELATIVE), "aim-relative preset is accepted")
	equal(preferences.movement_reference, PlayerPreferences.MOVEMENT_AIM_RELATIVE, "aim-relative preset applies")
	check(preferences.apply_control_preset(PlayerPreferences.MOVEMENT_WORLD_RELATIVE), "world-relative preset is accepted")
	check(not preferences.apply_control_preset("camera_relative"), "unknown movement preset fails closed")


func _test_validation() -> void:
	var valid := {
		"schema_version": 1,
		"movement_reference": "aim_relative",
		"pov_mode": "cone",
		"pov_angle_degrees": 360,
		"pov_range": 2048,
	}
	var preferences := PlayerPreferences.new()
	check(preferences.apply_dictionary(valid), "valid exact settings load")
	equal(preferences.pov_angle_degrees, 360, "360-degree ranged view is legal")
	equal(preferences.pov_range, 2048, "custom view length is legal")
	for mutation: Dictionary in [
		{"schema_version": 2},
		{"movement_reference": "camera_relative"},
		{"pov_mode": "wallhack"},
		{"pov_angle_degrees": 14},
		{"pov_angle_degrees": 361},
		{"pov_angle_degrees": 90.5},
		{"pov_range": 159},
		{"pov_range": 4097},
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


func _test_persistence_round_trip() -> void:
	var path := "user://flux2_player_preferences_test.json"
	var saved := PlayerPreferences.new()
	check(saved.apply_control_preset(PlayerPreferences.MOVEMENT_AIM_RELATIVE), "round-trip control preset applies")
	check(saved.set_pov_mode(PlayerPreferences.POV_CONE), "round-trip POV mode applies")
	saved.set_pov_angle_degrees(225)
	saved.set_pov_range(1360)
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
	var conflicting: Dictionary[StringName, int] = remapped.duplicate()
	conflicting[&"technique"] = KEY_J
	check(not PlayerPreferences.validate_keyboard_bindings(conflicting).is_empty(), "conflicting key bindings fail closed")
	var unknown: Dictionary = remapped.duplicate()
	unknown[&"developer_cheat"] = KEY_F12
	check(not PlayerPreferences.validate_keyboard_bindings(unknown).is_empty(), "unknown bindable action fails closed")
	remapped[&"jump"] = 0
	equal(PlayerPreferences.validate_keyboard_bindings(remapped), "", "zero explicitly unbinds one keyboard action")
	check(router.configure_keyboard_bindings(PlayerPreferences.DEFAULT_KEYBOARD_BINDINGS), "test restores keyboard defaults")


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
