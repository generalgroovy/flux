class_name SpellLoomEditor
extends RefCounted


const ROLE_PRIMARY: int = 0
const ROLE_ACTIVE: int = 1
const ROLE_COUNT: int = 2
const PANEL_RECT := Rect2(150, 104, 980, 516)
const FIRST_ROW_Y: float = 224.0
const ROW_HEIGHT: float = 50.0
const SLOT_X: float = 196.0
const SLOT_WIDTH: float = 592.0
const ROLE_X: float = 810.0
const ROLE_WIDTH: float = 128.0

var is_open: bool = false
var selected_slot_index: int = 0
var selected_role: int = ROLE_PRIMARY
var status_message: String = "Choose a slot and one proven kit spell."


func open_editor() -> void:
	is_open = true
	status_message = "Choose a slot and one proven kit spell."


func close_editor() -> void:
	is_open = false
	status_message = ""


func move_selection(slot_delta: int, role_delta: int) -> void:
	selected_slot_index = posmod(selected_slot_index + slot_delta, PlayerState.SPELL_SLOT_COUNT)
	selected_role = posmod(selected_role + role_delta, ROLE_COUNT)
	status_message = "Enter / A weaves the selected spell into slot %d." % (selected_slot_index + 1)


func select_at(position: Vector2) -> bool:
	if position.y >= FIRST_ROW_Y and position.y < FIRST_ROW_Y + ROW_HEIGHT * PlayerState.SPELL_SLOT_COUNT:
		if position.x >= SLOT_X and position.x < SLOT_X + SLOT_WIDTH:
			selected_slot_index = clampi(int((position.y - FIRST_ROW_Y) / ROW_HEIGHT), 0, PlayerState.SPELL_SLOT_COUNT - 1)
			return true
	if position.y >= FIRST_ROW_Y - 54.0 and position.y < FIRST_ROW_Y - 12.0:
		if position.x >= ROLE_X and position.x < ROLE_X + ROLE_WIDTH * ROLE_COUNT:
			selected_role = clampi(int((position.x - ROLE_X) / ROLE_WIDTH), 0, ROLE_COUNT - 1)
			return true
	return false


func request_value() -> int:
	return selected_slot_index * ROLE_COUNT + selected_role + 1


func selected_wire_id(state: PlayerState) -> int:
	if state == null:
		return 0
	return state.primary_wire_id if selected_role == ROLE_PRIMARY else state.active_1_wire_id


func apply_to_state(state: PlayerState) -> bool:
	if state == null or not state.place_kit_spell(selected_slot_index, selected_wire_id(state)):
		status_message = "That weave was refused; the current kit is unchanged."
		return false
	status_message = "Slot %d now carries the selected kit spell." % (selected_slot_index + 1)
	return true


static func decode_slot_index(value: int) -> int:
	return (value - 1) >> 1 if value >= 1 and value <= SessionTransport.MAX_SPELL_EQUIP_VALUE else -1


static func decode_role(value: int) -> int:
	return (value - 1) % ROLE_COUNT if value >= 1 and value <= SessionTransport.MAX_SPELL_EQUIP_VALUE else -1
