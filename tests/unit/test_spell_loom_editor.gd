extends FluxTestSuite


func run() -> int:
	_test_canonical_slot_weaving()
	_test_three_spell_kit_weaving()
	_test_editor_navigation_and_encoding()
	return finish("spell-loom-editor")


func _test_canonical_slot_weaving() -> void:
	var state := PlayerState.new()
	check(state.has_valid_spell_slots(), "new player begins with every proven runtime spell across twelve positions")
	equal(Array(state.spell_wire_ids), [101, 110, 140, 141, 144, 142, 143, 145, 0, 0, 0, 0], "champion kit leads the stable global spell library")
	check(state.set_spell_cooldown(CombatTuning.POCKET_ECLIPSE_WIRE_ID, 17), "global spell owns an independent cooldown")
	check(state.place_proven_spell(11, CombatTuning.POCKET_ECLIPSE_WIRE_ID), "global spell can move to Alt+4")
	equal(Array(state.spell_wire_ids), [101, 110, 140, 141, 144, 142, 0, 145, 0, 0, 0, 143], "moving a global spell swaps with the selected position")
	equal(state.spell_cooldown_for_wire(CombatTuning.POCKET_ECLIPSE_WIRE_ID), 17, "cooldown follows spell identity through a weave")
	check(state.place_proven_spell(11, state.active_1_wire_id), "champion spell can swap into an occupied global position")
	equal(Array(state.spell_wire_ids), [101, 143, 140, 141, 144, 142, 0, 145, 0, 0, 0, 110], "occupied weave preserves every proven spell exactly once")
	equal(state.spell_cooldown_for_wire(CombatTuning.POCKET_ECLIPSE_WIRE_ID), 17, "swapping does not transfer cooldown to the displaced spell")
	check(not state.place_proven_spell(-1, state.primary_wire_id), "negative slot fails closed")
	check(not state.place_proven_spell(0, 65_000), "unproven spell fails closed")
	check(state.has_valid_spell_slots(), "rejected weaves preserve canonical slot validity")
	var subset := PlayerState.new()
	var pocket_index := subset.spell_slot_index_for_wire(CombatTuning.POCKET_ECLIPSE_WIRE_ID)
	subset.spell_wire_ids[pocket_index] = 0
	subset.spell_cooldown_ticks[pocket_index] = 0
	subset._sync_legacy_spell_cooldowns()
	check(subset.has_valid_spell_slots(), "a unique twelve-position subset remains valid as the global library grows past twelve")
	check(subset.place_proven_spell(3, CombatTuning.POCKET_ECLIPSE_WIRE_ID), "a proven spell outside the current weave can replace an occupied position")
	equal(subset.spell_wire_id(4), CombatTuning.POCKET_ECLIPSE_WIRE_ID, "new global selection occupies the requested position")
	check(subset.spell_slot_index_for_wire(CombatTuning.TIDELINE_WIRE_ID) < 0, "replaced spell leaves the selected twelve-position subset")


func _test_editor_navigation_and_encoding() -> void:
	var state := PlayerState.new()
	var editor := SpellLoomEditor.new()
	editor.open_editor()
	check(editor.is_open, "Spell Loom opens explicitly")
	editor.move_selection(-1, -1)
	equal(editor.selected_slot_index, 11, "weave-position navigation wraps")
	equal(editor.selected_spell_index, CombatTuning.RUNTIME_WIRE_IDS.size() - 1, "global spell navigation wraps")
	equal(editor.selected_wire_id(), CombatTuning.CINDERBOLT_WIRE_ID, "wrapped selection resolves through stable runtime order")
	equal(editor.request_value(), 536, "Alt+4 global spell has a bounded request encoding")
	equal(SpellLoomEditor.decode_slot_index(536), 11, "request decodes position deterministically")
	equal(SpellLoomEditor.decode_library_index(536), 7, "request decodes the global library index deterministically")
	equal(SpellLoomEditor.decode_slot_index(0), -1, "invalid request value fails closed")
	check(editor.apply_to_state(state), "offline editor applies through canonical state method")
	equal(state.spell_wire_id(12), CombatTuning.CINDERBOLT_WIRE_ID, "selected global spell occupies Alt+4")
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
	equal(Array(state.spell_wire_ids), [140, 141, 144, 101, 110, 142, 143, 145, 0, 0, 0, 0], "three champion spells lead the stable global library")
	check(state.has_valid_spell_slots(), "global seven-spell weave validates canonically")
	check(state.place_proven_spell(11, state.active_2_wire_id), "third champion spell can move to Alt+4")
	equal(Array(state.spell_wire_ids), [140, 141, 0, 101, 110, 142, 143, 145, 0, 0, 0, 144], "third spell weaving preserves all global spells and honest empty positions")
	var editor := SpellLoomEditor.new()
	editor.open_editor(state)
	equal(editor.available_wire_ids.size(), 8, "Oh Tipi can weave every proven global spell")
	editor.move_selection(-1, -1)
	equal(editor.selected_wire_id(), CombatTuning.CINDERBOLT_WIRE_ID, "global navigation is independent of champion kit")
	equal(editor.request_value(), 536, "global weave uses the bounded catalog lane")
	equal(SpellLoomEditor.decode_slot_index(536), 11, "global request value decodes Alt+4")
	equal(SpellLoomEditor.decode_library_index(536), 7, "global request value decodes the final proven spell")
