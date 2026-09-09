extends FluxTestSuite


func run() -> int:
	_test_canonical_slot_weaving()
	_test_three_spell_kit_weaving()
	_test_editor_navigation_and_encoding()
	_test_drag_and_drop()
	_test_catalog_layout_and_details()
	return finish("spell-loom-editor")


func _test_drag_and_drop() -> void:
	var editor := SpellLoomEditor.new()
	var state := PlayerState.new()
	editor.open_editor(state)
	equal(editor.visible_spell_indices().size(), 57, "complete seven-family matrix and proven variant fit at once")
	for index: int in range(editor.available_wire_ids.size()):
		for slot: int in range(PlayerState.SPELL_SLOT_COUNT):
			var before := Array(state.spell_wire_ids)
			editor.pointer_down(editor.spell_rect(index).get_center(), state)
			editor.pointer_move(SpellLoomEditor.slot_rect(slot).get_center())
			check(editor.dragging, "catalog drag starts after pointer threshold")
			check(editor.pointer_up(SpellLoomEditor.slot_rect(slot).get_center()), "each spell drops into every slot")
			equal(editor.selected_slot_index, slot, "drop selects exact destination")
			equal(editor.selected_wire_id(), editor.available_wire_ids[index], "drop retains source identity")
			equal(Array(state.spell_wire_ids), before, "pointer cannot bypass simulation authority")
			check(editor.apply_to_state(state), "canonical assignment accepts drop")
			equal(state.spell_wire_id(slot + 1), editor.available_wire_ids[index], "destination receives requested spell")
			check(state.has_valid_spell_slots(), "every drop preserves unique valid slots")
	var before := Array(state.spell_wire_ids)
	editor.pointer_down(editor.spell_rect(0).get_center(), state)
	check(not editor.pointer_up(Vector2.ZERO), "outside drop cancels")
	equal(Array(state.spell_wire_ids), before, "outside drop changes nothing")
	editor.pointer_down(editor.spell_rect(0).get_center(), state)
	check(not editor.pointer_up(editor.spell_rect(0).get_center()), "a click only selects")
	editor.pointer_down(SpellLoomEditor.slot_rect(3).get_center(), state)
	var source_wire := state.spell_wire_id(4)
	check(editor.pointer_up(SpellLoomEditor.slot_rect(9).get_center()), "equipped spell can drag between slots")
	equal(editor.selected_wire_id(), source_wire, "slot drag retains equipped identity")
	editor.pointer_down(editor.spell_rect(0).get_center(), state)
	editor.close_editor()
	check(not editor.pointer_up(SpellLoomEditor.slot_rect(0).get_center()), "closing cancels a pending drag")
	equal(SpellLoomEditor.slot_at(Vector2(SpellLoomEditor.GRID_X + SpellLoomEditor.GRID_CELL_WIDTH - 4, SpellLoomEditor.GRID_Y + 10)), -1, "gap is not a drop target")


func _test_canonical_slot_weaving() -> void:
	var state := PlayerState.new()
	check(state.has_valid_spell_slots(), "new player begins with a valid twelve-spell subset of the runtime library")
	equal(Array(state.spell_wire_ids), [101, 110, 145, 179, 180, 146, 154, 155, 156, 140, 181, 182], "champion kit leads a representative twelve-spell weave from the row-major library")
	check(state.set_spell_cooldown(CombatTuning.RILLSHOT_WIRE_ID, 17), "equipped global spell owns an independent cooldown")
	check(state.place_proven_spell(11, CombatTuning.RILLSHOT_WIRE_ID), "global spell can move to Alt+4")
	equal(Array(state.spell_wire_ids), [101, 110, 145, 179, 180, 146, 154, 155, 156, 182, 181, 140], "moving a global spell swaps with the selected position")
	equal(state.spell_cooldown_for_wire(CombatTuning.RILLSHOT_WIRE_ID), 17, "cooldown follows spell identity through a weave")
	check(state.place_proven_spell(11, state.active_1_wire_id), "champion spell can swap into an occupied global position")
	equal(Array(state.spell_wire_ids), [101, 140, 145, 179, 180, 146, 154, 155, 156, 182, 181, 110], "occupied weave preserves every equipped spell exactly once")
	equal(state.spell_cooldown_for_wire(CombatTuning.RILLSHOT_WIRE_ID), 17, "swapping does not transfer cooldown to the displaced spell")
	check(not state.place_proven_spell(-1, state.primary_wire_id), "negative slot fails closed")
	check(not state.place_proven_spell(0, 65_000), "unproven spell fails closed")
	check(state.has_valid_spell_slots(), "rejected weaves preserve canonical slot validity")
	var subset := PlayerState.new()
	check(subset.has_valid_spell_slots(), "a unique twelve-position subset remains valid as the global library grows past twelve")
	var displaced_wire := subset.spell_wire_id(4)
	check(subset.place_proven_spell(3, 159), "a proven spell outside the current weave can replace an occupied position")
	equal(subset.spell_wire_id(4), 159, "new global selection occupies the requested position")
	check(subset.spell_slot_index_for_wire(displaced_wire) < 0, "replaced spell leaves the selected twelve-position subset")


func _test_editor_navigation_and_encoding() -> void:
	var state := PlayerState.new()
	var editor := SpellLoomEditor.new()
	editor.open_editor()
	check(editor.is_open, "Spell Loom opens explicitly")
	editor.move_selection(-1, -1)
	equal(editor.selected_slot_index, 11, "weave-position navigation wraps")
	equal(editor.selected_spell_index, CombatTuning.runtime_wire_ids().size() - 1, "global spell navigation wraps")
	equal(editor.selected_wire_id(), CombatTuning.ACTIVE_1_WIRE_ID, "wrapped selection resolves through stable runtime order")
	equal(editor.request_value(), 761, "Alt+4 final variant has a bounded request encoding")
	equal(SpellLoomEditor.decode_slot_index(761), 11, "request decodes position deterministically")
	equal(SpellLoomEditor.decode_library_index(761), 56, "request decodes the final global library index deterministically")
	equal(SpellLoomEditor.wire_id_for_library_index(56), 110, "final cell resolves the canonical variant wire")
	equal(SpellLoomEditor.wire_id_for_library_index(57), 0, "unoccupied library capacity is not a playable spell")
	equal(SpellLoomEditor.decode_slot_index(769), -1, "request above twelve by sixty-four fails closed")
	equal(SpellLoomEditor.decode_slot_index(0), -1, "invalid request value fails closed")
	check(editor.apply_to_state(state), "offline editor applies through canonical state method")
	equal(state.spell_wire_id(12), CombatTuning.ACTIVE_1_WIRE_ID, "selected global spell occupies Alt+4")
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
	equal(Array(state.spell_wire_ids), [140, 141, 144, 145, 179, 180, 146, 154, 155, 156, 181, 182], "three champion spells lead a representative row-major twelve-spell weave")
	check(state.has_valid_spell_slots(), "twelve-position weave validates canonically")
	check(state.place_proven_spell(11, state.active_2_wire_id), "third champion spell can move to Alt+4")
	equal(Array(state.spell_wire_ids), [140, 141, 182, 145, 179, 180, 146, 154, 155, 156, 181, 144], "third spell weaving preserves every equipped spell exactly once")
	var editor := SpellLoomEditor.new()
	editor.open_editor(state)
	equal(editor.available_wire_ids.size(), 57, "Oh Tipi can weave every proven global spell")
	editor.move_selection(-1, -1)
	equal(editor.selected_wire_id(), CombatTuning.ACTIVE_1_WIRE_ID, "global navigation is independent of champion kit")
	equal(editor.request_value(), 761, "global weave uses the bounded catalog lane")
	equal(SpellLoomEditor.decode_slot_index(761), 11, "global request value decodes Alt+4")
	equal(SpellLoomEditor.decode_library_index(761), 56, "global request value decodes the final proven spell")


func _test_catalog_layout_and_details() -> void:
	var catalog := AbilityCatalog.new()
	check(catalog.load_from_file("res://content/abilities/foundation_abilities_v1.json"), "seven-family catalog loads for Loom layout")
	var editor := SpellLoomEditor.new()
	editor.open_editor(null, catalog)
	equal(SpellLoomEditor.matrix_columns(), 7, "column count derives from catalog family order")
	equal(SpellLoomEditor.matrix_cell_count(), 56, "matrix size derives from catalog elements and families")
	equal(SpellLoomEditor.VISIBLE_SPELL_COUNT, 64, "visible capacity matches the expanded bounded library")
	equal(editor.spell_rect(56).position, Vector2(564, 498), "variant follows the eighth row without an extra empty row")
	equal(SpellLoomEditor.variant_label_position(), Vector2(498, 520), "variant label shares its row, above the footer divider")
	for index: int in editor.visible_spell_indices():
		var rect := editor.spell_rect(index)
		check(SpellLoomEditor.PANEL_RECT.encloses(rect), "every spell target fits inside the 720p panel")
		check(rect.end.y < SpellLoomEditor.DETAIL_DIVIDER_Y, "all spells including final variant clear the detail footer")
		check(not rect.intersects(SpellLoomEditor.CLOSE_RECT) and not rect.intersects(SpellLoomEditor.ASSIGN_RECT), "spell targets never overlap action buttons")
		check(editor.select_at(rect.get_center()), "each displayed cell is selectable at its exact painted center")
		equal(editor.selected_spell_index, index, "each painted center resolves only its own spell")
		var ability := catalog.ability_from_wire(editor.available_wire_ids[index])
		if index < SpellLoomEditor.matrix_cell_count():
			equal(String(ability.element), AbilityCatalog.FIRST_EIGHT_ELEMENTS[index / SpellLoomEditor.matrix_columns()], "cell element agrees with row heading")
			equal(AbilityCatalog._spell_family(ability), AbilityCatalog.SPELL_MATRIX_FAMILIES[index % SpellLoomEditor.matrix_columns()], "cell delivery agrees with family heading")
		for other: int in range(index):
			check(not rect.intersects(editor.spell_rect(other)), "spell hit targets cannot overlap")
		for slot: int in range(PlayerState.SPELL_SLOT_COUNT):
			check(not rect.intersects(SpellLoomEditor.slot_rect(slot)), "picker and twelve-slot weave stay separate")
		var name := String(ability.display_name)
		for layout: Vector2 in [Vector2(rect.size.x - 11, 11), Vector2(SpellLoomEditor.slot_rect(0).size.x - 18, 13)]:
			var lines := SpellLoomPresenter.name_lines(name, layout.x, int(layout.y))
			check(lines.size() <= 2, "names use at most two lines without smaller fonts")
			equal(" ".join(lines), name, "every current spell name is retained, not silently abbreviated")
			for line: String in lines:
				check(ThemeDB.fallback_font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, int(layout.y)).x <= layout.x, "wrapped name fits within its target")
		check(ThemeDB.fallback_font.get_string_size(SpellLoomPresenter.family_detail(ability), HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x <= 930, "family behavior detail fits without smaller text")
	for slot: int in range(PlayerState.SPELL_SLOT_COUNT):
		var rect := SpellLoomEditor.slot_rect(slot)
		equal(rect.position, Vector2(48 + slot % 4 * 110, 154 + slot / 4 * 86), "four-by-three slot arrangement is preserved")
		check(rect.end.x < SpellLoomEditor.MATRIX_LABEL_X, "slot names and element row labels have separate space")
		for other: int in range(slot):
			check(not rect.intersects(SpellLoomEditor.slot_rect(other)), "weave hit targets cannot overlap")
	equal(editor.spell_rect(-1), Rect2(), "negative cell has no hit area")
	equal(editor.spell_rect(57), Rect2(), "unoccupied library position has no hit area")
	equal(SpellLoomPresenter.family_label("burst"), "Wave", "user label Wave preserves canonical burst identity")
	var heavy := catalog.ability_from_wire(179).duplicate(true)
	equal(SpellLoomPresenter.family_detail(heavy), "Heavy: 18 Flux / 84px splash radius. Slow shell; blast at impact or endpoint.", "Heavy detail teaches real cost and splash radius")
	heavy["blast_radius"] = 42000
	heavy["flux_cost"] = 21
	equal(SpellLoomPresenter.family_detail(heavy), "Heavy: 21 Flux / 42px splash radius. Slow shell; blast at impact or endpoint.", "Heavy teaching reads catalog values, not duplicated tuning")
	var rapid := catalog.ability_from_wire(180).duplicate(true)
	check(SpellLoomPresenter.family_detail(rapid).contains("hold the spell key / 2 Flux per shot"), "Rapid detail teaches held-key firing and per-shot payment")
	rapid["repeat_while_held"] = false
	rapid["flux_cost"] = 4
	check(SpellLoomPresenter.family_detail(rapid).contains("press the spell key / 4 Flux per shot"), "Rapid teaching follows catalog repeat and cost settings")
	var wave := catalog.ability_from_wire(146).duplicate(true)
	check(SpellLoomPresenter.family_detail(wave).contains("5 simultaneous projectiles"), "Wave teaching is simultaneous, not a sequence")
	wave["projectile_angles_degrees"] = [-12, 0, 12]
	check(SpellLoomPresenter.family_detail(wave).contains("3 simultaneous projectiles"), "Wave teaching derives lane count from catalog")
