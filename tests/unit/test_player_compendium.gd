extends FluxTestSuite


const Compendium = preload("res://src/presentation/player_compendium.gd")


func run() -> int:
	var abilities := AbilityCatalog.new()
	check(abilities.load_from_file("res://content/abilities/foundation_abilities_v1.json"), "compendium ability catalog loads")
	var champions := ChampionCatalog.new()
	check(champions.load_from_file("res://content/champions/foundation_champions_v1.json", abilities), "compendium champion catalog loads")
	var roster := ChampionRosterPlan.new()
	check(roster.load_from_files(), "compendium planned roster loads")
	var panel := Compendium.new()
	check(panel.configure(champions, roster), "compendium uses validated source models")
	var preferences := PlayerPreferences.new()
	preferences.keyboard_bindings[&"jump"] = KEY_J
	panel.open_panel(Compendium.MOVEMENT, preferences)
	check(panel.is_open, "open exposes reading state")
	equal(panel.row_count(), 16, "all active movement techniques are reachable")
	equal(panel.visible_row_indices().size(), 10, "row page stays comfortably bounded")
	panel.move_row(2)
	check(" ".join(panel.detail_paragraphs()).contains("Tap J"), "live guide resolves rebound controls")
	panel.move_row(100)
	equal(panel.selected_row, 15, "row selection cannot exceed catalog")
	equal(panel.visible_row_indices(), [10, 11, 12, 13, 14, 15], "last page exposes remaining techniques")
	panel.move_row(-100)
	equal(panel.selected_row, 0, "row selection cannot underflow")
	var live_state := PlayerState.new(1)
	live_state.movement_chain_count = 3
	live_state.movement_chain_reset_ticks = 1
	panel.refresh_status(live_state)
	check(" ".join(panel.summary).contains("Next premium: 30%"), "open guide explains current chain premium")
	live_state.movement_chain_reset_ticks = 0
	panel.refresh_status(live_state)
	check(" ".join(panel.summary).contains("Next premium: 0%"), "guide updates when shared-world chain expires while reading")
	var font := ThemeDB.fallback_font
	for row: int in range(panel.row_count()):
		panel.selected_row = row
		var all_lines: Array[String] = []
		for paragraph: String in panel.detail_paragraphs():
			all_lines.append_array(Compendium.wrap_text(paragraph, font, Compendium.DETAIL_WIDTH))
		var paged_lines: Array[String] = []
		for page: int in range(panel.detail_pages(font)):
			panel.detail_page = page
			var lines: Array[String] = panel.visible_detail_lines(font)
			check(lines.size() <= Compendium.LINES_PER_PAGE, "movement detail page never overflows vertically")
			paged_lines.append_array(lines)
			_assert_widths(lines, font, Compendium.DETAIL_WIDTH)
		equal(paged_lines, all_lines, "all skill paragraphs survive pagination in order")
	var stubborn := "VeryLongUnbrokenReboundControllerButtonName123456789"
	var split := Compendium.wrap_text(stubborn, font, 60)
	_assert_widths(split, font, 60)
	equal("".join(split), stubborn, "long bind names wrap without truncation or lost characters")
	panel.handle_event(_key(KEY_TAB), font)
	equal(panel.tab, Compendium.CHARACTERS, "Tab changes section")
	equal(panel.selected_row, 0, "tab starts with alphabetical first race")
	equal(panel.row_count(), 21, "all race rows are reachable")
	var seen := 0
	for row: int in range(panel.row_count()):
		panel.selected_row = row
		panel.selected_character = 0
		var entries: Array = panel.overview["rows"][row]["champions"]
		for character: int in range(entries.size()):
			panel.selected_character = character
			seen += 1
			var paragraphs := panel.detail_paragraphs()
			check(not paragraphs.is_empty(), "every character has a readable record")
			var combined := " ".join(paragraphs)
			if bool(entries[character]["stats_available"]):
				check(combined.contains("Health") and combined.contains("Flux") and combined.contains("Stamina") and combined.contains("Walk speed"), "playable record exposes every stat family")
			else:
				check(combined.contains("cannot be selected") and not combined.contains("Health "), "planned record cannot imply fabricated playable stats")
			for page: int in range(panel.detail_pages(font)):
				panel.detail_page = page
				_assert_widths(panel.visible_detail_lines(font), font, Compendium.DETAIL_WIDTH)
	equal(seen, 24, "all twenty-four identities are accessible, not five selectable clones")
	panel.set_tab(Compendium.CHARACTERS)
	panel.move_character(-1)
	check(panel.selected_character >= 0, "character cycle never underflows")
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
	wheel.pressed = true
	check(panel.handle_event(wheel, font), "wheel is consumed by reading overlay")
	equal(panel.selected_row, 1, "wheel navigates rows without a movement command")
	panel.handle_event(_key(KEY_PAGEDOWN), font)
	check(panel.detail_page < panel.detail_pages(font), "detail paging remains within content")
	panel.handle_event(_joy(JOY_BUTTON_LEFT_SHOULDER), font)
	equal(panel.tab, Compendium.MOVEMENT, "controller shoulder changes section")
	panel.handle_event(_joy(JOY_BUTTON_DPAD_DOWN), font)
	equal(panel.selected_row, 1, "controller d-pad moves row")
	panel.handle_event(_joy(JOY_BUTTON_BACK), font)
	check(not panel.is_open, "controller Back closes before any underlying action")
	check(not panel.handle_event(_key(KEY_DOWN), font), "closed overlay does not consume input")
	panel.open_panel(Compendium.MOVEMENT, preferences)
	panel.handle_event(_key(KEY_ESCAPE), font)
	check(not panel.is_open, "Escape closes overlay")
	_test_chemistry(panel, preferences, font)
	return finish("player-compendium")


func _test_chemistry(panel: RefCounted, preferences: PlayerPreferences, font: Font) -> void:
	panel.open_panel(Compendium.CHARACTERS, preferences)
	panel.handle_event(_key(KEY_TAB), font)
	equal(panel.tab, Compendium.CHEMISTRY, "Chemistry is reachable through the existing Tab navigation")
	equal(panel.row_count(), 9, "primer and eight element rows fit one readable list page")
	var primer := " ".join(panel.detail_paragraphs())
	check(primer.contains("2-5 seconds") and primer.contains("endpoint"), "primer explains paid terminal matter and aim endpoints")
	check(primer.contains("separate from a spell's own Field"), "deposit duration cannot be mistaken for spell Field duration")
	var seen := {}
	for row: int in range(panel.row_count()):
		panel.selected_row = row
		for recipe: Dictionary in panel.chemistry_rows[row]["recipes"]:
			seen[int(recipe.wire_id)] = true
		var all_lines: Array[String] = []
		for paragraph: String in panel.detail_paragraphs():
			all_lines.append_array(Compendium.wrap_text(paragraph,font,Compendium.DETAIL_WIDTH))
		var reached: Array[String] = []
		for page: int in range(panel.detail_pages(font)):
			panel.detail_page = page
			var lines: Array[String] = panel.visible_detail_lines(font)
			check(lines.size() <= Compendium.LINES_PER_PAGE, "chemistry page stays vertically bounded")
			_assert_widths(lines,font,Compendium.DETAIL_WIDTH)
			reached.append_array(lines)
		equal(reached,all_lines,"every pair and effect remains reachable through detail paging")
	equal(seen.size(),36,"all thirty-six unique pairs are accessible in the live compendium")
	panel.handle_event(_joy(JOY_BUTTON_RIGHT_SHOULDER),font)
	equal(panel.tab,Compendium.MOVEMENT,"controller cycles Chemistry back to Movement")
	panel.handle_event(_joy(JOY_BUTTON_LEFT_SHOULDER),font)
	equal(panel.tab,Compendium.CHEMISTRY,"controller can cycle backwards to Chemistry")
	panel.handle_event(_key(KEY_ESCAPE),font)
	check(not panel.is_open,"Chemistry closes through the same safe modal exit")


func _assert_widths(lines: Array[String], font: Font, width: float) -> void:
	for line: String in lines:
		check(font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, Compendium.FONT_SIZE).x <= width, "wrapped line fits the visible detail column")


func _key(key: int) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = key
	event.pressed = true
	return event


func _joy(button: int) -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.button_index = button
	event.pressed = true
	return event
