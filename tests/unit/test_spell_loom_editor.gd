extends FluxTestSuite


func run() -> int:
	_test_canonical_slot_weaving()
	_test_three_spell_kit_weaving()
	_test_editor_navigation_and_encoding()
	return finish("spell-loom-editor")


func _test_canonical_slot_weaving() -> void:
	var state := PlayerState.new()
	check(state.has_valid_spell_slots(), "new player begins with one primary and one active across twelve positions")
	equal(Array(state.spell_wire_ids), [state.primary_wire_id, state.active_1_wire_id, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], "default kit occupies Plain+1 and Plain+2")
	check(state.place_kit_spell(11, state.primary_wire_id), "primary can move to Alt+4")
	equal(Array(state.spell_wire_ids), [0, state.active_1_wire_id, 0, 0, 0, 0, 0, 0, 0, 0, 0, state.primary_wire_id], "moving a spell swaps with the selected position")
	check(state.place_kit_spell(11, state.active_1_wire_id), "active can swap into an occupied position")
	equal(Array(state.spell_wire_ids), [0, state.primary_wire_id, 0, 0, 0, 0, 0, 0, 0, 0, 0, state.active_1_wire_id], "occupied weave preserves both proven kit spells")
	check(not state.place_kit_spell(-1, state.primary_wire_id), "negative slot fails closed")
	check(not state.place_kit_spell(0, 65_000), "non-kit spell fails closed")
	check(state.has_valid_spell_slots(), "rejected weaves preserve canonical slot validity")


func _test_editor_navigation_and_encoding() -> void:
	var state := PlayerState.new()
	var editor := SpellLoomEditor.new()
	editor.open_editor()
	check(editor.is_open, "Spell Loom opens explicitly")
	editor.move_selection(-1, -1)
	equal(editor.selected_slot_index, 11, "weave-position navigation wraps")
	equal(editor.selected_role, SpellLoomEditor.ROLE_ACTIVE, "kit-spell navigation wraps")
	equal(editor.request_value(), 35, "Alt+4 active one has a bounded request encoding")
	equal(SpellLoomEditor.decode_slot_index(35), 11, "request decodes position deterministically")
	equal(SpellLoomEditor.decode_role(35), SpellLoomEditor.ROLE_ACTIVE_1, "request decodes role deterministically")
	equal(SpellLoomEditor.decode_slot_index(0), -1, "invalid request value fails closed")
	check(editor.apply_to_state(state), "offline editor applies through canonical state method")
	equal(state.spell_wire_id(12), state.active_1_wire_id, "selected active occupies Alt+4")
	check(editor.select_at(Vector2(SpellLoomEditor.GRID_X + SpellLoomEditor.GRID_CELL_WIDTH * 2 + 4, SpellLoomEditor.GRID_Y + SpellLoomEditor.GRID_CELL_HEIGHT + 4)), "mouse selects a visible weave cell")
	equal(editor.selected_slot_index, 6, "mouse grid selection resolves Ctrl+3")
	editor.close_editor()
	check(not editor.is_open, "Spell Loom closes explicitly")


func _test_three_spell_kit_weaving() -> void:
	var state := PlayerState.new()
	state.primary_wire_id = CombatTuning.RILLSHOT_WIRE_ID
	state.active_1_wire_id = CombatTuning.TIDELINE_WIRE_ID
	state.active_2_wire_id = CombatTuning.RIMEWAKE_WIRE_ID
	state.reset_spell_slots_to_kit()
	equal(Array(state.spell_wire_ids), [CombatTuning.RILLSHOT_WIRE_ID, CombatTuning.TIDELINE_WIRE_ID, CombatTuning.RIMEWAKE_WIRE_ID, 0, 0, 0, 0, 0, 0, 0, 0, 0], "three proven spells occupy the first three Plain positions")
	check(state.has_valid_spell_slots(), "three-spell kit validates canonically")
	check(state.place_kit_spell(11, state.active_2_wire_id), "third proven active can move to Alt+4")
	equal(Array(state.spell_wire_ids), [CombatTuning.RILLSHOT_WIRE_ID, CombatTuning.TIDELINE_WIRE_ID, 0, 0, 0, 0, 0, 0, 0, 0, 0, CombatTuning.RIMEWAKE_WIRE_ID], "third spell weaving preserves nine honest empty positions")
	var editor := SpellLoomEditor.new()
	editor.open_editor(state)
	equal(editor.available_role_count, 3, "Oh Tipi exposes three proven Loom roles")
	editor.move_selection(-1, -1)
	equal(editor.selected_role, SpellLoomEditor.ROLE_ACTIVE_2, "three-spell role navigation wraps to active two")
	equal(editor.request_value(), 36, "Alt+4 active two uses the final bounded request value")
	equal(SpellLoomEditor.decode_slot_index(36), 11, "final request value decodes Alt+4")
	equal(SpellLoomEditor.decode_role(36), SpellLoomEditor.ROLE_ACTIVE_2, "final request value decodes active two")
