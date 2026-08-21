class_name SpellLoomEditor
extends RefCounted


const LIBRARY_CAPACITY: int = SessionTransport.MAX_SPELL_LIBRARY_SIZE
const VISIBLE_SPELL_COUNT: int = 3
const PANEL_RECT := Rect2(150, 104, 980, 516)
const GRID_X: float = 196.0
const GRID_Y: float = 224.0
const GRID_CELL_WIDTH: float = 142.0
const GRID_CELL_HEIGHT: float = 72.0
const SPELL_PICKER_X: float = 798.0
const SPELL_PICKER_WIDTH: float = 98.0

var is_open: bool = false
var selected_slot_index: int = 0
var selected_spell_index: int = 0
var available_wire_ids := PackedInt32Array(CombatTuning.RUNTIME_WIRE_IDS)
var status_message: String = "Choose a slot and one proven global spell."


func open_editor(_state: PlayerState = null, catalog: AbilityCatalog = null) -> void:
	is_open = true
	configure_for_catalog(catalog)
	status_message = "Choose a slot and one proven global spell."


func close_editor() -> void:
	is_open = false
	status_message = ""


func move_selection(slot_delta: int, spell_delta: int) -> void:
	selected_slot_index = posmod(selected_slot_index + slot_delta, PlayerState.SPELL_SLOT_COUNT)
	selected_spell_index = posmod(selected_spell_index + spell_delta, maxi(1, available_wire_ids.size()))
	status_message = "Enter / A weaves the selected spell into %s." % PlayerState.spell_slot_label(selected_slot_index)


func select_at(position: Vector2) -> bool:
	if position.x >= GRID_X and position.x < GRID_X + GRID_CELL_WIDTH * PlayerState.SPELL_BUTTON_COUNT:
		if position.y >= GRID_Y and position.y < GRID_Y + GRID_CELL_HEIGHT * PlayerState.SPELL_LAYER_COUNT:
			var button_index := clampi(int((position.x - GRID_X) / GRID_CELL_WIDTH), 0, PlayerState.SPELL_BUTTON_COUNT - 1)
			var layer_index := clampi(int((position.y - GRID_Y) / GRID_CELL_HEIGHT), 0, PlayerState.SPELL_LAYER_COUNT - 1)
			selected_slot_index = layer_index * PlayerState.SPELL_BUTTON_COUNT + button_index
			return true
	if position.y >= GRID_Y - 54.0 and position.y < GRID_Y - 12.0:
		var visible_indices := visible_spell_indices()
		if position.x >= SPELL_PICKER_X and position.x < SPELL_PICKER_X + SPELL_PICKER_WIDTH * visible_indices.size():
			var visible_index := clampi(int((position.x - SPELL_PICKER_X) / SPELL_PICKER_WIDTH), 0, visible_indices.size() - 1)
			selected_spell_index = visible_indices[visible_index]
			return true
	return false


func request_value() -> int:
	return selected_slot_index * LIBRARY_CAPACITY + selected_spell_index + 1


func selected_wire_id(_state: PlayerState = null) -> int:
	return available_wire_ids[selected_spell_index] if selected_spell_index >= 0 and selected_spell_index < available_wire_ids.size() else 0


func configure_for_catalog(catalog: AbilityCatalog) -> void:
	var prior_wire_id := selected_wire_id()
	available_wire_ids = PackedInt32Array()
	for wire_id: int in CombatTuning.RUNTIME_WIRE_IDS:
		if catalog == null or not catalog.ability_from_wire(wire_id).is_empty():
			available_wire_ids.append(wire_id)
	selected_spell_index = available_wire_ids.find(prior_wire_id)
	if selected_spell_index < 0:
		selected_spell_index = 0


func visible_spell_indices() -> PackedInt32Array:
	var result := PackedInt32Array()
	var count := mini(VISIBLE_SPELL_COUNT, available_wire_ids.size())
	var start := clampi(selected_spell_index - 1, 0, maxi(0, available_wire_ids.size() - count))
	for index: int in range(start, start + count):
		result.append(index)
	return result


func apply_to_state(state: PlayerState) -> bool:
	if state == null or not state.place_proven_spell(selected_slot_index, selected_wire_id()):
		status_message = "That weave was refused; the current library is unchanged."
		return false
	status_message = "%s now carries the selected global spell." % PlayerState.spell_slot_label(selected_slot_index)
	return true


static func decode_slot_index(value: int) -> int:
	return (value - 1) / LIBRARY_CAPACITY if value >= 1 and value <= SessionTransport.MAX_SPELL_EQUIP_VALUE else -1


static func decode_library_index(value: int) -> int:
	return (value - 1) % LIBRARY_CAPACITY if value >= 1 and value <= SessionTransport.MAX_SPELL_EQUIP_VALUE else -1


static func wire_id_for_library_index(library_index: int) -> int:
	return CombatTuning.RUNTIME_WIRE_IDS[library_index] if library_index >= 0 and library_index < CombatTuning.RUNTIME_WIRE_IDS.size() else 0
