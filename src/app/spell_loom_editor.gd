class_name SpellLoomEditor
extends RefCounted


const ROLE_PRIMARY: int = 0
const ROLE_ACTIVE_1: int = 1
const ROLE_ACTIVE: int = ROLE_ACTIVE_1
const ROLE_ACTIVE_2: int = 2
const ROLE_COUNT: int = 3
const PANEL_RECT := Rect2(150, 104, 980, 516)
const GRID_X: float = 196.0
const GRID_Y: float = 224.0
const GRID_CELL_WIDTH: float = 142.0
const GRID_CELL_HEIGHT: float = 72.0
const ROLE_X: float = 798.0
const ROLE_WIDTH: float = 98.0

var is_open: bool = false
var selected_slot_index: int = 0
var selected_role: int = ROLE_PRIMARY
var available_role_count: int = 2
var status_message: String = "Choose a slot and one proven kit spell."


func open_editor(state: PlayerState = null) -> void:
	is_open = true
	configure_for_state(state)
	status_message = "Choose a slot and one proven kit spell."


func close_editor() -> void:
	is_open = false
	status_message = ""


func move_selection(slot_delta: int, role_delta: int) -> void:
	selected_slot_index = posmod(selected_slot_index + slot_delta, PlayerState.SPELL_SLOT_COUNT)
	selected_role = posmod(selected_role + role_delta, available_role_count)
	status_message = "Enter / A weaves the selected spell into %s." % PlayerState.spell_slot_label(selected_slot_index)


func select_at(position: Vector2) -> bool:
	if position.x >= GRID_X and position.x < GRID_X + GRID_CELL_WIDTH * PlayerState.SPELL_BUTTON_COUNT:
		if position.y >= GRID_Y and position.y < GRID_Y + GRID_CELL_HEIGHT * PlayerState.SPELL_LAYER_COUNT:
			var button_index := clampi(int((position.x - GRID_X) / GRID_CELL_WIDTH), 0, PlayerState.SPELL_BUTTON_COUNT - 1)
			var layer_index := clampi(int((position.y - GRID_Y) / GRID_CELL_HEIGHT), 0, PlayerState.SPELL_LAYER_COUNT - 1)
			selected_slot_index = layer_index * PlayerState.SPELL_BUTTON_COUNT + button_index
			return true
	if position.y >= GRID_Y - 54.0 and position.y < GRID_Y - 12.0:
		if position.x >= ROLE_X and position.x < ROLE_X + ROLE_WIDTH * available_role_count:
			selected_role = clampi(int((position.x - ROLE_X) / ROLE_WIDTH), 0, available_role_count - 1)
			return true
	return false


func request_value() -> int:
	return selected_slot_index * ROLE_COUNT + selected_role + 1


func selected_wire_id(state: PlayerState) -> int:
	if state == null:
		return 0
	match selected_role:
		ROLE_PRIMARY:
			return state.primary_wire_id
		ROLE_ACTIVE_1:
			return state.active_1_wire_id
		ROLE_ACTIVE_2:
			return state.active_2_wire_id
	return 0


func configure_for_state(state: PlayerState) -> void:
	available_role_count = 3 if state != null and state.active_2_wire_id > 0 else 2
	selected_role = clampi(selected_role, 0, available_role_count - 1)


func apply_to_state(state: PlayerState) -> bool:
	if state == null or not state.place_kit_spell(selected_slot_index, selected_wire_id(state)):
		status_message = "That weave was refused; the current kit is unchanged."
		return false
	status_message = "%s now carries the selected kit spell." % PlayerState.spell_slot_label(selected_slot_index)
	return true


static func decode_slot_index(value: int) -> int:
	return (value - 1) / ROLE_COUNT if value >= 1 and value <= SessionTransport.MAX_SPELL_EQUIP_VALUE else -1


static func decode_role(value: int) -> int:
	return (value - 1) % ROLE_COUNT if value >= 1 and value <= SessionTransport.MAX_SPELL_EQUIP_VALUE else -1
