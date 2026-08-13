extends FluxTestSuite


func run() -> int:
	_test_canonical_slot_weaving()
	_test_editor_navigation_and_encoding()
	return finish("spell-loom-editor")


func _test_canonical_slot_weaving() -> void:
	var state := PlayerState.new()
	check(state.has_valid_spell_slots(), "new player begins with one primary and one active across five slots")
	equal(Array(state.spell_wire_ids), [state.primary_wire_id, state.active_1_wire_id, 0, 0, 0], "default kit occupies slots 1 and 2")
	check(state.place_kit_spell(4, state.primary_wire_id), "primary can move to slot 5")
	equal(Array(state.spell_wire_ids), [0, state.active_1_wire_id, 0, 0, state.primary_wire_id], "moving a spell swaps with the selected slot")
	check(state.place_kit_spell(4, state.active_1_wire_id), "active can swap into an occupied slot")
	equal(Array(state.spell_wire_ids), [0, state.primary_wire_id, 0, 0, state.active_1_wire_id], "occupied weave preserves both proven kit spells")
	check(not state.place_kit_spell(-1, state.primary_wire_id), "negative slot fails closed")
	check(not state.place_kit_spell(0, 65_000), "non-kit spell fails closed")
	check(state.has_valid_spell_slots(), "rejected weaves preserve canonical slot validity")


func _test_editor_navigation_and_encoding() -> void:
	var state := PlayerState.new()
	var editor := SpellLoomEditor.new()
	editor.open_editor()
	check(editor.is_open, "Spell Loom opens explicitly")
	editor.move_selection(-1, -1)
	equal(editor.selected_slot_index, 4, "slot navigation wraps")
	equal(editor.selected_role, SpellLoomEditor.ROLE_ACTIVE, "kit-spell navigation wraps")
	equal(editor.request_value(), 10, "slot 5 active has a bounded request encoding")
	equal(SpellLoomEditor.decode_slot_index(10), 4, "request decodes slot deterministically")
	equal(SpellLoomEditor.decode_role(10), SpellLoomEditor.ROLE_ACTIVE, "request decodes role deterministically")
	equal(SpellLoomEditor.decode_slot_index(0), -1, "invalid request value fails closed")
	check(editor.apply_to_state(state), "offline editor applies through canonical state method")
	equal(state.spell_wire_id(5), state.active_1_wire_id, "selected active occupies slot 5")
	check(editor.select_at(Vector2(SpellLoomEditor.SLOT_X + 4, SpellLoomEditor.FIRST_ROW_Y + SpellLoomEditor.ROW_HEIGHT * 2 + 4)), "mouse selects a visible slot row")
	equal(editor.selected_slot_index, 2, "mouse row selection resolves slot 3")
	editor.close_editor()
	check(not editor.is_open, "Spell Loom closes explicitly")
