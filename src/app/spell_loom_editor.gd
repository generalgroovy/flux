class_name SpellLoomEditor
extends RefCounted


const LIBRARY_CAPACITY: int = SessionTransport.MAX_SPELL_LIBRARY_SIZE
const VISIBLE_SPELL_COUNT: int = 16
const PANEL_RECT := Rect2(42, 38, 1196, 644)
const GRID_X: float = 72.0
const GRID_Y: float = 178.0
const GRID_CELL_WIDTH: float = 132.0
const GRID_CELL_HEIGHT: float = 92.0
const SPELL_PICKER_X: float = 636.0
const SPELL_PICKER_WIDTH: float = 138.0
const SPELL_PICKER_HEIGHT: float = 70.0
const ASSIGN_RECT := Rect2(980, 590, 214, 40)
const CLOSE_RECT := Rect2(1178, 54, 38, 34)

var is_open: bool = false
var selected_slot_index: int = 0
var selected_spell_index: int = 0
var available_wire_ids := PackedInt32Array(CombatTuning.runtime_wire_ids())
var status_message: String = "Drag a spell onto a slot, or select both and choose Assign."
var drag_spell_index: int = -1
var drag_origin := Vector2.ZERO
var pointer_position := Vector2.ZERO
var dragging: bool = false


func open_editor(_state: PlayerState = null, catalog: AbilityCatalog = null) -> void:
	is_open = true
	configure_for_catalog(catalog)
	cancel_drag()
	status_message = "Drag a spell onto a slot, or select both and choose Assign."


func close_editor() -> void:
	is_open = false
	cancel_drag()
	status_message = ""


func move_selection(slot_delta: int, spell_delta: int) -> void:
	cancel_drag()
	selected_slot_index = posmod(selected_slot_index + slot_delta, PlayerState.SPELL_SLOT_COUNT)
	selected_spell_index = posmod(selected_spell_index + spell_delta, maxi(1, available_wire_ids.size()))
	status_message = "Assign to %s with Enter / A." % PlayerState.spell_slot_label(selected_slot_index)


func select_at(position: Vector2) -> bool:
	var slot := slot_at(position)
	if slot >= 0:
		selected_slot_index = slot
		return true
	for index: int in visible_spell_indices():
		if spell_rect(index).has_point(position):
			selected_spell_index = index
			return true
	return false


static func slot_rect(index: int) -> Rect2:
	return Rect2(GRID_X + (index % 4) * GRID_CELL_WIDTH, GRID_Y + (index / 4) * GRID_CELL_HEIGHT, GRID_CELL_WIDTH - 8, GRID_CELL_HEIGHT - 8)


func spell_rect(index: int) -> Rect2:
	var offset := visible_spell_indices().find(index)
	return Rect2(SPELL_PICKER_X + (offset % 4) * SPELL_PICKER_WIDTH, GRID_Y + (offset / 4) * SPELL_PICKER_HEIGHT, SPELL_PICKER_WIDTH - 8, SPELL_PICKER_HEIGHT - 8)


static func slot_at(position: Vector2) -> int:
	for index: int in range(PlayerState.SPELL_SLOT_COUNT):
		if slot_rect(index).has_point(position):
			return index
	return -1


func pointer_down(position: Vector2, state: PlayerState) -> void:
	cancel_drag()
	pointer_position = position
	drag_origin = position
	for index: int in visible_spell_indices():
		if spell_rect(index).has_point(position):
			selected_spell_index = index
			drag_spell_index = index
			return
	var slot := slot_at(position)
	if slot >= 0:
		selected_slot_index = slot
		if state != null:
			drag_spell_index = available_wire_ids.find(state.spell_wire_id(slot + 1))


func pointer_move(position: Vector2) -> void:
	pointer_position = position
	if drag_spell_index >= 0 and position.distance_squared_to(drag_origin) >= 36.0:
		dragging = true


func pointer_up(position: Vector2) -> bool:
	pointer_move(position)
	var target := slot_at(position)
	var assign := dragging and drag_spell_index >= 0 and target >= 0
	if assign:
		selected_slot_index = target
		selected_spell_index = drag_spell_index
	elif dragging:
		status_message = "Drop cancelled. Your spells are unchanged."
	cancel_drag()
	return assign


func cancel_drag() -> void:
	drag_spell_index = -1
	dragging = false


func request_value() -> int:
	# Wire requests always use the canonical library, never filtered UI positions.
	var library_index := CombatTuning.runtime_wire_ids().find(selected_wire_id())
	return selected_slot_index * LIBRARY_CAPACITY + library_index + 1 if library_index >= 0 else 0


func selected_wire_id(_state: PlayerState = null) -> int:
	return available_wire_ids[selected_spell_index] if selected_spell_index >= 0 and selected_spell_index < available_wire_ids.size() else 0


func configure_for_catalog(catalog: AbilityCatalog) -> void:
	var prior_wire_id := selected_wire_id()
	available_wire_ids = PackedInt32Array()
	for wire_id: int in CombatTuning.runtime_wire_ids():
		if catalog == null or not catalog.ability_from_wire(wire_id).is_empty():
			available_wire_ids.append(wire_id)
	selected_spell_index = available_wire_ids.find(prior_wire_id)
	if selected_spell_index < 0:
		selected_spell_index = 0


func visible_spell_indices() -> PackedInt32Array:
	var result := PackedInt32Array()
	var count := mini(VISIBLE_SPELL_COUNT, available_wire_ids.size())
	var start := (selected_spell_index / VISIBLE_SPELL_COUNT) * VISIBLE_SPELL_COUNT
	count = mini(count, available_wire_ids.size() - start)
	for index: int in range(start, start + count):
		result.append(index)
	return result


func apply_to_state(state: PlayerState) -> bool:
	if state == null or not state.place_proven_spell(selected_slot_index, selected_wire_id()):
		status_message = "Could not assign. Your spells are unchanged."
		return false
	status_message = "Assigned to %s. Equipped spells swap positions; cooldowns stay with the spell." % PlayerState.spell_slot_label(selected_slot_index)
	return true


static func decode_slot_index(value: int) -> int:
	return (value - 1) / LIBRARY_CAPACITY if value >= 1 and value <= SessionTransport.MAX_SPELL_EQUIP_VALUE else -1


static func decode_library_index(value: int) -> int:
	return (value - 1) % LIBRARY_CAPACITY if value >= 1 and value <= SessionTransport.MAX_SPELL_EQUIP_VALUE else -1


static func wire_id_for_library_index(library_index: int) -> int:
	var runtime_wire_ids := CombatTuning.runtime_wire_ids()
	return runtime_wire_ids[library_index] if library_index >= 0 and library_index < runtime_wire_ids.size() else 0
