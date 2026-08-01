class_name InputRouter
extends RefCounted


const ACTIONS: Dictionary[StringName, int] = {
	&"move_left": KEY_A,
	&"move_right": KEY_D,
	&"move_up": KEY_W,
	&"move_down": KEY_S,
	&"sprint": KEY_SHIFT,
	&"jump": KEY_SPACE,
	&"technique": KEY_E,
	&"reset_match": KEY_R,
	&"toggle_tick_rate": KEY_F6,
}

var entity_id: int
var jump_was_down: bool = false
var technique_was_down: bool = false


func _init(requested_entity_id: int = 1) -> void:
	entity_id = requested_entity_id
	ensure_input_map()


static func ensure_input_map() -> void:
	for action: StringName in ACTIONS:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		var event := InputEventKey.new()
		event.physical_keycode = ACTIONS[action]
		InputMap.action_add_event(action, event)


func sample(tick: int) -> SimCommand:
	var move_x: int = int(Input.is_action_pressed(&"move_right")) - int(Input.is_action_pressed(&"move_left"))
	var move_y: int = int(Input.is_action_pressed(&"move_down")) - int(Input.is_action_pressed(&"move_up"))
	var held: int = SimCommand.HELD_SPRINT if Input.is_action_pressed(&"sprint") else 0
	var jump_down: bool = Input.is_action_pressed(&"jump")
	var technique_down: bool = Input.is_action_pressed(&"technique")
	var pressed: int = 0
	if jump_down and not jump_was_down:
		pressed |= SimCommand.PRESSED_JUMP
	if technique_down and not technique_was_down:
		pressed |= SimCommand.PRESSED_TECHNIQUE
	jump_was_down = jump_down
	technique_was_down = technique_down
	return SimCommand.new(tick, entity_id, move_x * 1000, move_y * 1000, held, pressed)
