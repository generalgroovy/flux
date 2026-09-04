class_name InputRouter
extends RefCounted


const KEY_ACTIONS: Dictionary[StringName, int] = PlayerPreferences.DEFAULT_KEYBOARD_BINDINGS
const MOUSE_ACTIONS: Dictionary[StringName, int] = PlayerPreferences.DEFAULT_MOUSE_BINDINGS
const CONTROLLER_ACTIONS: Dictionary = PlayerPreferences.DEFAULT_CONTROLLER_BINDINGS
const PRIMARY_ACTION: StringName = &"primary"
const ACTIVE_1_ACTION: StringName = &"active_1"
const SLIDE_ACTION: StringName = &"slide"
const INTERACT_ACTION: StringName = &"interact"
const EMOTE_ACTION: StringName = &"emote"
const SPECTATE_NEXT_ACTION: StringName = &"spectate_next"
const SPELL_ACTIONS: Array[StringName] = [&"spell_1", &"spell_2", &"spell_3", &"spell_4"]
const SPELL_CTRL_LAYER_ACTION: StringName = &"spell_layer_ctrl"
const SPELL_ALT_LAYER_ACTION: StringName = &"spell_layer_alt"
const AIM_DEADZONE: float = 0.25

var entity_id: int
var evade_was_down: bool = false
var jump_was_down: bool = false
var technique_was_down: bool = false
var active_1_was_down: bool = false
var slide_was_down: bool = false
var spell_was_down: Array[bool] = [false, false, false, false]
var movement_reference: String = PlayerPreferences.MOVEMENT_WORLD_RELATIVE
var last_quantized_aim := Vector2i(1000, 0)
var consumed_engine_edge_frames: Dictionary[StringName, int] = {}


func _init(requested_entity_id: int = 1) -> void:
	entity_id = requested_entity_id
	ensure_input_map()


static func ensure_input_map() -> void:
	for action: StringName in KEY_ACTIONS:
		_ensure_action(action)
		var physical_keycode: int = KEY_ACTIONS[action]
		if physical_keycode != 0:
			_add_key(action, physical_keycode)
	_ensure_action(SPECTATE_NEXT_ACTION)
	_add_key(SPECTATE_NEXT_ACTION, KEY_TAB)
	_ensure_action(PRIMARY_ACTION)
	_ensure_action(ACTIVE_1_ACTION)
	_add_key(ACTIVE_1_ACTION, KEY_E)
	for action: StringName in MOUSE_ACTIONS:
		_ensure_action(action)
		var mouse_button: int = MOUSE_ACTIONS[action]
		if mouse_button != 0:
			_add_mouse_button(action, mouse_button)

	for action: StringName in CONTROLLER_ACTIONS:
		_ensure_action(action)
		_add_controller_binding(action, CONTROLLER_ACTIONS[action])
	_ensure_action(&"aim_left")
	_ensure_action(&"aim_right")
	_ensure_action(&"aim_up")
	_ensure_action(&"aim_down")
	_add_joy_axis(&"aim_left", JOY_AXIS_RIGHT_X, -1.0)
	_add_joy_axis(&"aim_right", JOY_AXIS_RIGHT_X, 1.0)
	_add_joy_axis(&"aim_up", JOY_AXIS_RIGHT_Y, -1.0)
	_add_joy_axis(&"aim_down", JOY_AXIS_RIGHT_Y, 1.0)
	_add_joy_button(SPECTATE_NEXT_ACTION, JOY_BUTTON_DPAD_RIGHT)


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


static func _add_controller_binding(action: StringName, descriptor: Dictionary) -> void:
	var kind := String(descriptor.get("kind", "none"))
	if kind == "button":
		_add_joy_button(action, int(descriptor.get("index", -1)))
	elif kind == "axis":
		_add_joy_axis(action, int(descriptor.get("index", -1)), float(descriptor.get("direction", 0)))


static func _add_event_once(action: StringName, event: InputEvent) -> void:
	for existing: InputEvent in InputMap.action_get_events(action):
		if existing.as_text() == event.as_text():
			return
	InputMap.action_add_event(action, event)


func sample(tick: int, player_position: Vector2, pointer_position: Vector2) -> SimCommand:
	var movement_input := Input.get_vector(
		&"move_left", &"move_right", &"move_up", &"move_down", AIM_DEADZONE,
	)
	var quantized_movement := quantize_movement_vector(movement_input)
	var raw_move_x := quantized_movement.x
	var raw_move_y := quantized_movement.y
	var held: int = 0
	if Input.is_action_pressed(&"sprint"):
		held |= SimCommand.HELD_SPRINT
	if Input.is_action_pressed(PRIMARY_ACTION):
		held |= SimCommand.HELD_PRIMARY
	var evade_down: bool = Input.is_action_pressed(&"evade")
	var evade_pressed: bool = _action_pressed_edge(&"evade", evade_down, evade_was_down)
	evade_was_down = evade_down
	var jump_down: bool = Input.is_action_pressed(&"jump")
	var technique_down: bool = Input.is_action_pressed(&"technique")
	var active_1_down: bool = Input.is_action_pressed(ACTIVE_1_ACTION)
	var slide_down: bool = Input.is_action_pressed(SLIDE_ACTION)
	var jump_pressed: bool = _action_pressed_edge(&"jump", jump_down, jump_was_down)
	var technique_pressed: bool = _action_pressed_edge(&"technique", technique_down, technique_was_down)
	var active_1_pressed: bool = _action_pressed_edge(ACTIVE_1_ACTION, active_1_down, active_1_was_down)
	var slide_pressed: bool = _action_pressed_edge(SLIDE_ACTION, slide_down, slide_was_down)
	if jump_down:
		held |= SimCommand.HELD_JUMP
	if slide_down:
		held |= SimCommand.HELD_FAST_FALL
	var pressed: int = SimCommand.PRESSED_EVADE if evade_pressed else 0
	if jump_pressed:
		pressed |= SimCommand.PRESSED_JUMP
	if technique_pressed:
		pressed |= SimCommand.PRESSED_TECHNIQUE
	if active_1_pressed:
		pressed |= SimCommand.PRESSED_ACTIVE_1
	if slide_pressed:
		pressed |= SimCommand.PRESSED_SLIDE
	var ctrl_layer: bool = Input.is_action_pressed(SPELL_CTRL_LAYER_ACTION)
	var alt_layer: bool = Input.is_action_pressed(SPELL_ALT_LAYER_ACTION)
	for button_index: int in range(SPELL_ACTIONS.size()):
		var spell_down: bool = Input.is_action_pressed(SPELL_ACTIONS[button_index])
		var spell_pressed: bool = pressed_edge(
			spell_down,
			spell_was_down[button_index],
			_consume_engine_edge(SPELL_ACTIONS[button_index]),
		)
		if spell_pressed:
			var spell_slot_index := selected_spell_slot_index(button_index, ctrl_layer, alt_layer)
			pressed |= SimCommand.SPELL_PRESSED_BITS[spell_slot_index]
		spell_was_down[button_index] = spell_down
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


static func pressed_edge(down: bool, was_down: bool, engine_just_pressed: bool) -> bool:
	# Godot retains a just-pressed transition across the render/physics boundary.
	# Combine it with the explicit held-state edge so short wheel/key taps and
	# keyboard chords cannot disappear between input polling and simulation.
	return engine_just_pressed or (down and not was_down)


func _action_pressed_edge(action: StringName, down: bool, was_down: bool) -> bool:
	return pressed_edge(down, was_down, _consume_engine_edge(action))


func _consume_engine_edge(action: StringName) -> bool:
	if not Input.is_action_just_pressed(action):
		return false
	var process_frame: int = Engine.get_process_frames()
	if int(consumed_engine_edge_frames.get(action, -1)) == process_frame:
		return false
	consumed_engine_edge_frames[action] = process_frame
	return true


static func selected_spell_slot_index(button_index: int, ctrl_layer: bool, alt_layer: bool) -> int:
	var safe_button_index := clampi(button_index, 0, PlayerState.SPELL_BUTTON_COUNT - 1)
	# Alt takes deterministic precedence if both modifier actions are held.
	var layer_index: int = 2 if alt_layer else (1 if ctrl_layer else 0)
	return layer_index * PlayerState.SPELL_BUTTON_COUNT + safe_button_index


static func quantize_movement_vector(value: Vector2) -> Vector2i:
	var bounded := value.limit_length(1.0)
	return Vector2i(roundi(bounded.x * 1000.0), roundi(bounded.y * 1000.0))


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
	return true


func configure_mouse_bindings(requested_bindings: Dictionary) -> bool:
	if not PlayerPreferences.validate_mouse_bindings(requested_bindings).is_empty():
		return false
	for action: StringName in PlayerPreferences.DEFAULT_MOUSE_BINDINGS:
		var retained_events: Array[InputEvent] = []
		for existing: InputEvent in InputMap.action_get_events(action):
			if not existing is InputEventMouseButton:
				retained_events.append(existing)
		InputMap.action_erase_events(action)
		for retained: InputEvent in retained_events:
			InputMap.action_add_event(action, retained)
		var mouse_button: int = int(requested_bindings.get(action, PlayerPreferences.DEFAULT_MOUSE_BINDINGS[action]))
		if mouse_button != 0:
			_add_mouse_button(action, mouse_button)
	return true


func configure_controller_bindings(requested_bindings: Dictionary) -> bool:
	if not PlayerPreferences.validate_controller_bindings(requested_bindings).is_empty():
		return false
	for action: StringName in PlayerPreferences.DEFAULT_CONTROLLER_BINDINGS:
		var retained_events: Array[InputEvent] = []
		for existing: InputEvent in InputMap.action_get_events(action):
			if not existing is InputEventJoypadButton and not existing is InputEventJoypadMotion:
				retained_events.append(existing)
		InputMap.action_erase_events(action)
		for retained: InputEvent in retained_events:
			InputMap.action_add_event(action, retained)
		var descriptor: Dictionary = requested_bindings.get(action, PlayerPreferences.DEFAULT_CONTROLLER_BINDINGS[action])
		_add_controller_binding(action, descriptor)
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
