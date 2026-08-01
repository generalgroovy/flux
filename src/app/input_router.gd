class_name InputRouter
extends RefCounted


const KEY_ACTIONS: Dictionary[StringName, int] = {
	&"move_left": KEY_A,
	&"move_right": KEY_D,
	&"move_up": KEY_W,
	&"move_down": KEY_S,
	&"sprint": KEY_ALT,
	&"jump": KEY_C,
	&"technique": KEY_V,
	&"reset_match": KEY_R,
	&"toggle_tick_rate": KEY_F6,
}
const PRIMARY_ACTION: StringName = &"primary"
const AIM_DEADZONE: float = 0.25

var entity_id: int
var jump_was_down: bool = false
var technique_was_down: bool = false


func _init(requested_entity_id: int = 1) -> void:
	entity_id = requested_entity_id
	ensure_input_map()


static func ensure_input_map() -> void:
	for action: StringName in KEY_ACTIONS:
		_ensure_action(action)
		_add_key(action, KEY_ACTIONS[action])
	_ensure_action(PRIMARY_ACTION)
	_add_key(PRIMARY_ACTION, KEY_SPACE)
	_add_mouse_button(PRIMARY_ACTION, MOUSE_BUTTON_LEFT)

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
	_add_joy_button(&"sprint", JOY_BUTTON_LEFT_SHOULDER)
	_add_joy_button(&"jump", JOY_BUTTON_RIGHT_SHOULDER)
	_add_joy_button(&"technique", JOY_BUTTON_B)


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
	var move_x := roundi((Input.get_action_strength(&"move_right") - Input.get_action_strength(&"move_left")) * 1000.0)
	var move_y := roundi((Input.get_action_strength(&"move_down") - Input.get_action_strength(&"move_up")) * 1000.0)
	var held: int = 0
	if Input.is_action_pressed(&"sprint"):
		held |= SimCommand.HELD_SPRINT
	if Input.is_action_pressed(PRIMARY_ACTION):
		held |= SimCommand.HELD_PRIMARY
	var jump_down: bool = Input.is_action_pressed(&"jump")
	var technique_down: bool = Input.is_action_pressed(&"technique")
	var pressed: int = 0
	if jump_down and not jump_was_down:
		pressed |= SimCommand.PRESSED_JUMP
	if technique_down and not technique_was_down:
		pressed |= SimCommand.PRESSED_TECHNIQUE
	jump_was_down = jump_down
	technique_was_down = technique_down

	var aim_delta: Vector2 = pointer_position - player_position
	var joy_aim := Vector2(
		Input.get_action_strength(&"aim_right") - Input.get_action_strength(&"aim_left"),
		Input.get_action_strength(&"aim_down") - Input.get_action_strength(&"aim_up"),
	)
	if joy_aim.length() >= AIM_DEADZONE:
		aim_delta = joy_aim
	var quantized_aim := Vector2i(1000, 0)
	if aim_delta.length_squared() > 0.01:
		var normalized_aim: Vector2 = aim_delta.normalized() * 1000.0
		quantized_aim = Vector2i(roundi(normalized_aim.x), roundi(normalized_aim.y))
	return SimCommand.new(
		tick,
		entity_id,
		move_x,
		move_y,
		held,
		pressed,
		quantized_aim.x,
		quantized_aim.y,
	)
