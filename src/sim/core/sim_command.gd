class_name SimCommand
extends RefCounted


const HELD_SPRINT: int = 1 << 0
const PRESSED_JUMP: int = 1 << 0
const PRESSED_TECHNIQUE: int = 1 << 1

var tick: int
var entity_id: int
var move_x: int
var move_y: int
var held_actions: int
var pressed_actions: int


func _init(
	requested_tick: int = 0,
	requested_entity_id: int = 1,
	requested_move_x: int = 0,
	requested_move_y: int = 0,
	requested_held_actions: int = 0,
	requested_pressed_actions: int = 0,
) -> void:
	tick = requested_tick
	entity_id = requested_entity_id
	move_x = clampi(requested_move_x, -1000, 1000)
	move_y = clampi(requested_move_y, -1000, 1000)
	held_actions = requested_held_actions
	pressed_actions = requested_pressed_actions


func has_held(action: int) -> bool:
	return (held_actions & action) != 0


func has_pressed(action: int) -> bool:
	return (pressed_actions & action) != 0


func canonical_bytes() -> PackedByteArray:
	var output := PackedByteArray()
	for value: int in [tick, entity_id, move_x, move_y, held_actions, pressed_actions]:
		CanonicalBytes.append_i64(output, value)
	return output


func copy() -> SimCommand:
	return SimCommand.new(tick, entity_id, move_x, move_y, held_actions, pressed_actions)
