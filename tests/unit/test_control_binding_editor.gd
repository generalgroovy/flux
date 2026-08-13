extends FluxTestSuite


func run() -> int:
	_test_navigation_and_capture()
	_test_conflict_swap_unbind_and_reset()
	_test_device_filtering()
	return finish("control-binding-editor")


func _test_navigation_and_capture() -> void:
	var editor := ControlBindingEditor.new()
	var preferences := PlayerPreferences.new()
	editor.open_editor()
	check(editor.is_open, "editor opens explicitly")
	equal(editor.selected_action(), &"move_left", "editor begins on first gameplay action")
	editor.move_selection(-1, -1)
	equal(editor.selected_action(), &"spell_5", "row navigation wraps across all five spell slots")
	equal(editor.selected_device, ControlBindingEditor.DEVICE_CONTROLLER, "device navigation wraps")
	equal(editor.visible_action_indices().front(), 5, "wrapped spell selection scrolls the first visible row")
	equal(editor.visible_action_indices().back(), 16, "scrolled editor keeps the selected spell row visible")
	check(editor.select_cell(Vector2(ControlBindingEditor.DEVICE_X + 4, ControlBindingEditor.FIRST_ROW_Y + 4)), "visible scrolled cell can be selected")
	equal(editor.selected_action_index, 5, "mouse selection includes the scroll offset")
	editor.cancel_capture()
	editor.selected_action_index = ControlBindingEditor.ACTIONS.find(&"jump")
	editor.selected_device = ControlBindingEditor.DEVICE_KEYBOARD
	editor.begin_capture()
	var key := InputEventKey.new()
	key.physical_keycode = KEY_J
	key.pressed = true
	check(editor.capture_event(key, preferences), "keyboard capture applies")
	equal(preferences.keyboard_bindings[&"jump"], KEY_J, "captured physical key is stored")
	equal(editor.binding_label(&"jump", ControlBindingEditor.DEVICE_KEYBOARD, preferences), "J", "keyboard binding has a readable label")
	editor.close_editor()
	check(not editor.is_open and not editor.capturing, "closing editor cancels capture state")


func _test_conflict_swap_unbind_and_reset() -> void:
	var editor := ControlBindingEditor.new()
	var preferences := PlayerPreferences.new()
	editor.open_editor()
	editor.selected_action_index = ControlBindingEditor.ACTIONS.find(&"jump")
	editor.selected_device = ControlBindingEditor.DEVICE_KEYBOARD
	editor.begin_capture()
	var c_key := InputEventKey.new()
	c_key.physical_keycode = KEY_C
	c_key.pressed = true
	check(editor.capture_event(c_key, preferences), "capturing an occupied key performs a safe swap")
	equal(preferences.keyboard_bindings[&"jump"], KEY_C, "selected action receives occupied key")
	equal(preferences.keyboard_bindings[&"slide"], KEY_SPACE, "conflicting action receives selected action's previous key")
	check("SWAPPED" in editor.status_message.to_upper(), "swap is disclosed to the player")
	check(editor.unbind_selected(preferences), "selected keyboard lane can be unbound")
	equal(preferences.keyboard_bindings[&"jump"], 0, "unbind stores the explicit empty binding")
	editor.reset_bindings(preferences)
	equal(preferences.keyboard_bindings, PlayerPreferences.DEFAULT_KEYBOARD_BINDINGS, "reset restores keyboard defaults")
	equal(preferences.mouse_bindings, PlayerPreferences.DEFAULT_MOUSE_BINDINGS, "reset restores mouse defaults")
	equal(preferences.controller_bindings, PlayerPreferences.DEFAULT_CONTROLLER_BINDINGS, "reset restores controller defaults")
	editor.selected_action_index = ControlBindingEditor.ACTIONS.find(&"jump")
	editor.selected_device = ControlBindingEditor.DEVICE_KEYBOARD
	editor.begin_capture()
	var f_key := InputEventKey.new()
	f_key.physical_keycode = KEY_F
	f_key.pressed = true
	check(editor.capture_event(f_key, preferences), "gameplay and interaction actions share one conflict-safe namespace")
	equal(preferences.keyboard_bindings[&"interact"], KEY_SPACE, "occupying interact swaps its prior key instead of double-triggering")


func _test_device_filtering() -> void:
	var editor := ControlBindingEditor.new()
	var preferences := PlayerPreferences.new()
	editor.open_editor()
	editor.selected_action_index = ControlBindingEditor.ACTIONS.find(&"sprint")
	editor.selected_device = ControlBindingEditor.DEVICE_MOUSE
	editor.begin_capture()
	var key := InputEventKey.new()
	key.physical_keycode = KEY_Q
	key.pressed = true
	check(not editor.capture_event(key, preferences), "mouse capture ignores keyboard input")
	check(editor.capturing, "ignored device input leaves capture armed")
	var mouse := InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_XBUTTON1
	mouse.pressed = true
	check(editor.capture_event(mouse, preferences), "mouse capture accepts auxiliary buttons")
	equal(preferences.mouse_bindings[&"sprint"], MOUSE_BUTTON_XBUTTON1, "mouse binding is stored on the selected action")
	editor.selected_device = ControlBindingEditor.DEVICE_CONTROLLER
	editor.begin_capture()
	var axis := InputEventJoypadMotion.new()
	axis.axis = JOY_AXIS_RIGHT_X
	axis.axis_value = -0.9
	check(editor.capture_event(axis, preferences), "controller capture accepts a deliberate axis direction")
	var descriptor: Dictionary = preferences.controller_bindings[&"sprint"]
	equal(String(descriptor.get("kind")), "axis", "controller axis kind is stored")
	equal(int(descriptor.get("direction")), -1, "controller axis direction is stored")
