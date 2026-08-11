class_name InputRouter
extends RefCounted


const KEY_ACTIONS: Dictionary[StringName, int] = PlayerPreferences.DEFAULT_KEYBOARD_BINDINGS
const PRIMARY_ACTION: StringName = &"primary"
const ACTIVE_1_ACTION: StringName = &"active_1"
const SLIDE_ACTION: StringName = &"slide"
const INTERACT_ACTION: StringName = &"interact"
const AIM_DEADZONE: float = 0.25

var entity_id: int
var jump_was_down: bool = false
var technique_was_down: bool = false
var active_1_was_down: bool = false
var slide_was_down: bool = false
var movement_reference: String = PlayerPreferences.MOVEMENT_WORLD_RELATIVE
var last_quantized_aim := Vector2i(1000, 0)


func _init(requested_entity_id: int = 1) -> void:
	entity_id = requested_entity_id
	ensure_input_map()


static func ensure_input_map() -> void:
	for action: StringName in KEY_ACTIONS:
		_ensure_action(action)
		var physical_keycode: int = KEY_ACTIONS[action]
		if physical_keycode != 0:
			_add_key(action, physical_keycode)
	_add_key(SLIDE_ACTION, KEY_C)
	_ensure_action(INTERACT_ACTION)
	_add_key(INTERACT_ACTION, KEY_F)
	_ensure_action(PRIMARY_ACTION)
	_add_mouse_button(PRIMARY_ACTION, MOUSE_BUTTON_LEFT)
	_ensure_action(ACTIVE_1_ACTION)
	_add_key(ACTIVE_1_ACTION, KEY_E)
	_add_mouse_button(ACTIVE_1_ACTION, MOUSE_BUTTON_RIGHT)

	_add_joy_axis(&"move_left", JOY_AXIS_LEFT_X, -1.0)
	_add_joy_axis(&"move_right", JOY_AXIS_LEFT_X, 1.0)
	_add_joy_axis(&"move_up", JOY_AXIS_LEFT_Y, -1.0)
	_add_joy_axis(&"move_down", JOY_AXIS_LEFT_Y, 1.0)
	_ensure_action(&"aim_left")
	_ensure_action(&"aim_right")
	_ensure_action(&"aim_up")
	_ensure_action(&"aim_down")
	_add_joy_axis(&"aim_left", JOY_AXIS_RIGHT_X, -1.0)
	_add_joy_axis(&"aim_right", JOY_AXIS_RIGHT_X, 1.0)
	_add_joy_axis(&"aim_up", JOY_AXIS_RIGHT_Y, -1.0)
	_add_joy_axis(&"aim_down", JOY_AXIS_RIGHT_Y, 1.0)
	_add_joy_axis(PRIMARY_ACTION, JOY_AXIS_TRIGGER_RIGHT, 1.0)
	_add_joy_button(ACTIVE_1_ACTION, JOY_BUTTON_X)
	_add_joy_button(&"sprint", JOY_BUTTON_LEFT_SHOULDER)
	_add_joy_button(&"jump", JOY_BUTTON_RIGHT_SHOULDER)
	_add_joy_button(&"technique", JOY_BUTTON_B)
	_add_joy_button(SLIDE_ACTION, JOY_BUTTON_A)
	_add_joy_button(INTERACT_ACTION, JOY_BUTTON_Y)


static func _ensure_action(action: StringName) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, AIM_DEADZONE)


static func _add_key(action: StringName, physical_keycode: int) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = physical_keycode
	_add_event_once(action, event)


static func _add_mouse_button(action: StringName, button_index: int) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = button_index
	_add_event_once(action, event)


static func _add_joy_axis(action: StringName, axis: int, axis_value: float) -> void:
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = axis_value
	_add_event_once(action, event)


static func _add_joy_button(action: StringName, button_index: int) -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = button_index
	_add_event_once(action, event)


static func _add_event_once(action: StringName, event: InputEvent) -> void:
	for existing: InputEvent in InputMap.action_get_events(action):
		if existing.as_text() == event.as_text():
			return
	InputMap.action_add_event(action, event)


func sample(tick: int, player_position: Vector2, pointer_position: Vector2) -> SimCommand:
	var raw_move_x := roundi((Input.get_action_strength(&"move_right") - Input.get_action_strength(&"move_left")) * 1000.0)
	var raw_move_y := roundi((Input.get_action_strength(&"move_down") - Input.get_action_strength(&"move_up")) * 1000.0)
	var held: int = 0
	if Input.is_action_pressed(&"sprint"):
		held |= SimCommand.HELD_SPRINT
	if Input.is_action_pressed(PRIMARY_ACTION):
		held |= SimCommand.HELD_PRIMARY
	var jump_down: bool = Input.is_action_pressed(&"jump")
	var technique_down: bool = Input.is_action_pressed(&"technique")
	var active_1_down: bool = Input.is_action_pressed(ACTIVE_1_ACTION)
	var slide_down: bool = Input.is_action_pressed(SLIDE_ACTION)
	if jump_down:
		held |= SimCommand.HELD_JUMP
	if slide_down:
		held |= SimCommand.HELD_FAST_FALL
	var pressed: int = 0
	if jump_down and not jump_was_down:
		pressed |= SimCommand.PRESSED_JUMP
	if technique_down and not technique_was_down:
		pressed |= SimCommand.PRESSED_TECHNIQUE
	if active_1_down and not active_1_was_down:
		pressed |= SimCommand.PRESSED_ACTIVE_1
	if slide_down and not slide_was_down:
		pressed |= SimCommand.PRESSED_SLIDE
	jump_was_down = jump_down
	technique_was_down = technique_down
	active_1_was_down = active_1_down
	slide_was_down = slide_down

	var aim_delta: Vector2 = pointer_position - player_position
	var joy_aim := Vector2(
		Input.get_action_strength(&"aim_right") - Input.get_action_strength(&"aim_left"),
		Input.get_action_strength(&"aim_down") - Input.get_action_strength(&"aim_up"),
	)
	if joy_aim.length() >= AIM_DEADZONE:
		aim_delta = joy_aim
	var quantized_aim := last_quantized_aim
	if aim_delta.length_squared() > 0.01:
		var normalized_aim: Vector2 = aim_delta.normalized() * 1000.0
		quantized_aim = Vector2i(roundi(normalized_aim.x), roundi(normalized_aim.y))
		last_quantized_aim = quantized_aim
	var transformed_move := transform_movement(
		raw_move_x,
		raw_move_y,
		quantized_aim.x,
		quantized_aim.y,
		movement_reference,
	)
	return SimCommand.new(
		tick,
		entity_id,
		transformed_move.x,
		transformed_move.y,
		held,
		pressed,
		quantized_aim.x,
		quantized_aim.y,
	)


func configure_movement_reference(requested_reference: String) -> bool:
	if not PlayerPreferences.is_valid_movement_reference(requested_reference):
		return false
	movement_reference = requested_reference
	return true


func configure_keyboard_bindings(requested_bindings: Dictionary) -> bool:
	if not PlayerPreferences.validate_keyboard_bindings(requested_bindings).is_empty():
		return false
	for action: StringName in PlayerPreferences.DEFAULT_KEYBOARD_BINDINGS:
		var retained_events: Array[InputEvent] = []
		for existing: InputEvent in InputMap.action_get_events(action):
			if not existing is InputEventKey:
				retained_events.append(existing)
		InputMap.action_erase_events(action)
		for retained: InputEvent in retained_events:
			InputMap.action_add_event(action, retained)
		var physical_keycode: int = int(requested_bindings.get(action, PlayerPreferences.DEFAULT_KEYBOARD_BINDINGS[action]))
		if physical_keycode != 0:
			_add_key(action, physical_keycode)
	if int(requested_bindings.get(SLIDE_ACTION, 0)) == PlayerPreferences.DEFAULT_KEYBOARD_BINDINGS[SLIDE_ACTION]:
		_add_key(SLIDE_ACTION, KEY_C)
	return true


static func transform_movement(
	raw_move_x: int,
	raw_move_y: int,
	aim_x: int,
	aim_y: int,
	reference: String,
) -> Vector2i:
	var clamped_x := clampi(raw_move_x, -1000, 1000)
	var clamped_y := clampi(raw_move_y, -1000, 1000)
	if reference != PlayerPreferences.MOVEMENT_AIM_RELATIVE:
		return Vector2i(clamped_x, clamped_y)
	var forward := SimCommand._normalized_direction(aim_x, aim_y)
	@warning_ignore("integer_division")
	var world_x: int = (forward.x * -clamped_y - forward.y * clamped_x) / 1000
	@warning_ignore("integer_division")
	var world_y: int = (forward.y * -clamped_y + forward.x * clamped_x) / 1000
	return Vector2i(clampi(world_x, -1000, 1000), clampi(world_y, -1000, 1000))
