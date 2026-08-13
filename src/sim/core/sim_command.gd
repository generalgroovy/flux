class_name SimCommand
extends RefCounted


const HELD_SPRINT: int = 1 << 0
const HELD_PRIMARY: int = 1 << 1
const HELD_JUMP: int = 1 << 2
const HELD_FAST_FALL: int = 1 << 3
const PRESSED_JUMP: int = 1 << 0
const PRESSED_TECHNIQUE: int = 1 << 1
const PRESSED_ACTIVE_1: int = 1 << 2
const PRESSED_SLIDE: int = 1 << 3
const PRESSED_SPELL_1: int = 1 << 4
const PRESSED_SPELL_2: int = 1 << 5
const PRESSED_SPELL_3: int = 1 << 6
const PRESSED_SPELL_4: int = 1 << 7
const PRESSED_SPELL_5: int = 1 << 8
const SPELL_PRESSED_BITS: Array[int] = [
	PRESSED_SPELL_1,
	PRESSED_SPELL_2,
	PRESSED_SPELL_3,
	PRESSED_SPELL_4,
	PRESSED_SPELL_5,
]

var tick: int
var entity_id: int
var move_x: int
var move_y: int
var held_actions: int
var pressed_actions: int
var aim_x: int
var aim_y: int


func _init(
	requested_tick: int = 0,
	requested_entity_id: int = 1,
	requested_move_x: int = 0,
	requested_move_y: int = 0,
	requested_held_actions: int = 0,
	requested_pressed_actions: int = 0,
	requested_aim_x: int = 1000,
	requested_aim_y: int = 0,
) -> void:
	tick = requested_tick
	entity_id = requested_entity_id
	move_x = clampi(requested_move_x, -1000, 1000)
	move_y = clampi(requested_move_y, -1000, 1000)
	held_actions = requested_held_actions
	pressed_actions = requested_pressed_actions
	var aim := _normalized_direction(requested_aim_x, requested_aim_y)
	aim_x = aim.x
	aim_y = aim.y


func has_held(action: int) -> bool:
	return (held_actions & action) != 0


func has_pressed(action: int) -> bool:
	return (pressed_actions & action) != 0


func first_pressed_spell_slot() -> int:
	for index: int in range(SPELL_PRESSED_BITS.size()):
		if has_pressed(SPELL_PRESSED_BITS[index]):
			return index + 1
	return 0


func canonical_bytes() -> PackedByteArray:
	var output := PackedByteArray()
	for value: int in [tick, entity_id, move_x, move_y, held_actions, pressed_actions, aim_x, aim_y]:
		CanonicalBytes.append_i64(output, value)
	return output


func copy() -> SimCommand:
	return SimCommand.new(tick, entity_id, move_x, move_y, held_actions, pressed_actions, aim_x, aim_y)


static func _normalized_direction(requested_x: int, requested_y: int) -> Vector2i:
	var clamped_x := clampi(requested_x, -1_000_000, 1_000_000)
	var clamped_y := clampi(requested_y, -1_000_000, 1_000_000)
	if clamped_x == 0 and clamped_y == 0:
		return Vector2i(1000, 0)
	var length := _integer_square_root(clamped_x * clamped_x + clamped_y * clamped_y)
	if length <= 0:
		return Vector2i(1000, 0)
	@warning_ignore("integer_division")
	return Vector2i(clamped_x * 1000 / length, clamped_y * 1000 / length)


static func _integer_square_root(value: int) -> int:
	if value <= 0:
		return 0
	var current: int = value
	var next: int = (current + 1) / 2
	while next < current:
		current = next
		next = (current + value / current) / 2
	return current
