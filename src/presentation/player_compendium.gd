class_name PlayerCompendium
extends RefCounted


# This is a read-only projection: navigation cannot equip a spell, select a
# champion, pause the shared world or change any authoritative gameplay value.
const Guide = preload("res://src/presentation/movement_guide_model.gd")
const Overview = preload("res://src/app/character_overview_model.gd")
const ChemistryGuide = preload("res://src/presentation/chemistry_guide_model.gd")
const MOVEMENT := 0
const CHARACTERS := 1
const CHEMISTRY := 2
const ROWS_PER_PAGE := 10
const LINES_PER_PAGE := 14
const FONT_SIZE := 18
const LINE_HEIGHT := 25
const DETAIL_WIDTH := 770.0
const PANEL := Rect2(48, 44, 1184, 632)
const LIST_RECT := Rect2(72, 164, 298, 400)
const MOVEMENT_TAB := Rect2(72, 112, 230, 34)
const CHARACTERS_TAB := Rect2(312, 112, 230, 34)
const CHEMISTRY_TAB := Rect2(552, 112, 230, 34)
const CLOSE_RECT := Rect2(1116, 64, 92, 32)
const PREVIOUS_ROWS := Rect2(72, 572, 140, 34)
const NEXT_ROWS := Rect2(226, 572, 144, 34)
const PREVIOUS_DETAIL := Rect2(402, 572, 154, 34)
const NEXT_DETAIL := Rect2(1032, 572, 164, 34)
const INK := Color("141a17ee")
const PARCHMENT := Color("eee0b8")
const MUTED := Color("b7b69e")
const BRASS := Color("b79351")

var is_open := false
var tab := MOVEMENT
var selected_row := 0
var selected_character := 0
var detail_page := 0
var device := ControlBindingEditor.DEVICE_KEYBOARD
var movement_rows: Array[Dictionary] = []
var chemistry_rows: Array[Dictionary] = []
var overview: Dictionary = {}
var summary: Array[String] = []
var _wrapped_lines: Array[String] = []
var _cache_key := ""
var _summary_maximum := -1
var _summary_recovery := -1
var _summary_chain := -1


func configure(champions: ChampionCatalog, roster: ChampionRosterPlan) -> bool:
	overview = Overview.build(champions, roster)
	chemistry_rows = ChemistryGuide.entries()
	return bool(overview.get("valid", false))


func open_panel(selected_tab: int, preferences: PlayerPreferences, state: PlayerState = null, input_device: int = ControlBindingEditor.DEVICE_KEYBOARD) -> void:
	is_open = true
	device = input_device
	movement_rows = Guide.entries(preferences, device)
	summary = Guide.summary_lines(state)
	_summary_maximum = -1
	refresh_status(state)
	set_tab(selected_tab)


func refresh_status(state: PlayerState) -> void:
	if state == null:
		return
	var chain := mini(state.movement_chain_count, MovementTuning.MOVEMENT_CHAIN_MAXIMUM_STEPS) if state.movement_chain_reset_ticks > 0 else 0
	if _summary_maximum == state.stamina_maximum and _summary_recovery == state.stamina_recovery_per_second and _summary_chain == chain:
		return
	_summary_maximum = state.stamina_maximum
	_summary_recovery = state.stamina_recovery_per_second
	_summary_chain = chain
	summary = Guide.summary_lines(state)
	_cache_key = ""


func set_tab(value: int) -> void:
	tab = clampi(value, MOVEMENT, CHEMISTRY)
	selected_row = 0
	_reset_detail()


func close_panel() -> void:
	is_open = false


func row_count() -> int:
	if tab == CHEMISTRY:
		return chemistry_rows.size()
	return movement_rows.size() if tab == MOVEMENT else (overview.get("rows", []) as Array).size()


func move_row(delta: int) -> void:
	selected_row = clampi(selected_row + delta, 0, maxi(0, row_count() - 1))
	_reset_detail()


func move_character(delta: int) -> void:
	var entries := _characters()
	if entries.is_empty():
		return
	selected_character = posmod(selected_character + delta, entries.size())
	detail_page = 0
	_cache_key = ""


func visible_row_indices() -> Array[int]:
	var first := (selected_row / ROWS_PER_PAGE) * ROWS_PER_PAGE
	var result: Array[int] = []
	for index: int in range(first, mini(first + ROWS_PER_PAGE, row_count())):
		result.append(index)
	return result


func change_detail_page(delta: int, font: Font) -> void:
	var pages := detail_pages(font)
	detail_page = clampi(detail_page + delta, 0, maxi(0, pages - 1))


func detail_pages(font: Font) -> int:
	_ensure_wrapped(font)
	return maxi(1, ceili(float(_wrapped_lines.size()) / LINES_PER_PAGE))


func visible_detail_lines(font: Font) -> Array[String]:
	_ensure_wrapped(font)
	detail_page = clampi(detail_page, 0, detail_pages(font) - 1)
	return _wrapped_lines.slice(detail_page * LINES_PER_PAGE, (detail_page + 1) * LINES_PER_PAGE)


func detail_paragraphs() -> Array[String]:
	var result: Array[String] = []
	if tab == CHEMISTRY:
		if selected_row < chemistry_rows.size():
			for line: String in chemistry_rows[selected_row]["lines"]:
				result.append(line)
		return result
	if tab == MOVEMENT:
		if movement_rows.is_empty():
			return result
		result = Guide.detail_lines(movement_rows[selected_row])
		result.append("")
		result.append("SHARED MOVEMENT RULES")
		for line: String in summary:
			result.append("- " + line)
		return result
	var entries := _characters()
	if entries.is_empty():
		return ["No character is assigned to this race yet.", Overview.RACE_RULE_NOTE]
	var entry: Dictionary = entries[selected_character]
	result.append("Body: %s | %s affinities: %s" % [String(entry["body_type"]).capitalize(), String(entry["affinity_status"]), ", ".join(entry["affinities"])])
	var points: Dictionary = entry["affinity_points"]
	var point_labels: Array[String] = []
	for affinity: String in entry["affinities"]:
		point_labels.append("%s %s" % [affinity.capitalize(), str(points.get(affinity, 0))])
	result.append("Affinity points: " + "; ".join(point_labels))
	if bool(entry["stats_available"]):
		for line: String in entry["stat_lines"]:
			result.append("- " + line)
		result.append("Playstyle: " + String(entry["playstyle"]))
		var profile: Dictionary = entry["body_profile"]
		result.append("Body role: " + String(profile.get("role", "")).capitalize())
		result.append("Strengths: " + _human_list(profile.get("strengths", [])))
		result.append("Tradeoffs: " + _human_list(profile.get("tradeoffs", [])))
		result.append("All three body sizes share the same collision radius. No hidden reach, evasion or damage bonus.")
		var kit: Dictionary = entry["foundation_kit"]
		var kit_keys: Array = kit.keys()
		kit_keys.sort()
		for key: String in kit_keys:
			result.append("Starting %s: %s" % [key.replace("_", " "), str(kit[key]).replace("_", " ")])
		result.append("Change playable champion at the Champion Gallery; configure spells at the Spell Loom.")
	else:
		result.append(String(entry["note"]))
		result.append("This record cannot be selected or used in combat.")
	if not String(entry["reserved_future_affinity"]).is_empty():
		result.append("Future affinity (not active): " + String(entry["reserved_future_affinity"]))
	result.append(Overview.RACE_RULE_NOTE)
	return result


func handle_event(event: InputEvent, font: Font, pointer: Vector2 = Vector2(-1, -1)) -> bool:
	if not is_open:
		return false
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE, KEY_F4:
				close_panel()
			KEY_TAB:
				set_tab(posmod(tab + (-1 if event.shift_pressed else 1), 3))
			KEY_UP:
				move_row(-1)
			KEY_DOWN:
				move_row(1)
			KEY_HOME:
				move_row(-ROWS_PER_PAGE)
			KEY_END:
				move_row(ROWS_PER_PAGE)
			KEY_LEFT:
				move_character(-1)
			KEY_RIGHT:
				move_character(1)
			KEY_PAGEUP:
				change_detail_page(-1, font)
			KEY_PAGEDOWN:
				change_detail_page(1, font)
	elif event is InputEventJoypadButton and event.pressed:
		match event.button_index:
			JOY_BUTTON_BACK, JOY_BUTTON_B:
				close_panel()
			JOY_BUTTON_LEFT_SHOULDER:
				set_tab(posmod(tab - 1, 3))
			JOY_BUTTON_RIGHT_SHOULDER:
				set_tab(posmod(tab + 1, 3))
			JOY_BUTTON_DPAD_UP:
				move_row(-1)
			JOY_BUTTON_DPAD_DOWN:
				move_row(1)
			JOY_BUTTON_DPAD_LEFT:
				move_character(-1)
			JOY_BUTTON_DPAD_RIGHT:
				move_character(1)
			JOY_BUTTON_X:
				change_detail_page(-1, font)
			JOY_BUTTON_Y:
				change_detail_page(1, font)
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			move_row(-1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			move_row(1)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if CLOSE_RECT.has_point(pointer):
				close_panel()
			elif MOVEMENT_TAB.has_point(pointer):
				set_tab(MOVEMENT)
			elif CHARACTERS_TAB.has_point(pointer):
				set_tab(CHARACTERS)
			elif CHEMISTRY_TAB.has_point(pointer):
				set_tab(CHEMISTRY)
			elif PREVIOUS_ROWS.has_point(pointer):
				move_row(-ROWS_PER_PAGE)
			elif NEXT_ROWS.has_point(pointer):
				move_row(ROWS_PER_PAGE)
			elif PREVIOUS_DETAIL.has_point(pointer):
				change_detail_page(-1, font)
			elif NEXT_DETAIL.has_point(pointer):
				change_detail_page(1, font)
			elif Rect2(402, 151, 794, 37).has_point(pointer):
				move_character(1)
			elif LIST_RECT.has_point(pointer):
				var first := (selected_row / ROWS_PER_PAGE) * ROWS_PER_PAGE
				selected_row = mini(first + int((pointer.y - LIST_RECT.position.y) / 40.0), row_count() - 1)
				_reset_detail()
	# Swallow all gameplay key/mouse/controller events, including releases. The
	# integration sends neutral commands while this overlay is visible.
	return true


func draw(canvas: CanvasItem, font: Font) -> void:
	canvas.draw_rect(Rect2(0, 0, 1280, 720), Color("07110e88"))
	canvas.draw_rect(PANEL, INK)
	canvas.draw_rect(PANEL, BRASS, false, 2.0)
	_text(canvas, font, Vector2(72, 88), "TRAVELLER'S COMPENDIUM", 26, PARCHMENT)
	_button(canvas, font, CLOSE_RECT, "Close", false)
	_button(canvas, font, MOVEMENT_TAB, "MOVEMENT", tab == MOVEMENT)
	_button(canvas, font, CHARACTERS_TAB, "CHARACTERS", tab == CHARACTERS)
	_button(canvas, font, CHEMISTRY_TAB, "CHEMISTRY", tab == CHEMISTRY)
	_text(canvas, font, Vector2(802, 134), "Read. Try. Combine.", 16, MUTED)
	canvas.draw_line(Vector2(386, 164), Vector2(386, 607), Color(BRASS, 0.5))
	var indices := visible_row_indices()
	for offset: int in range(indices.size()):
		var index := indices[offset]
		var row_rect := Rect2(72, 164 + offset * 40, 298, 38)
		if index == selected_row:
			canvas.draw_rect(row_rect, Color("4c482bee"))
			canvas.draw_rect(row_rect, BRASS, false, 1.0)
		var label: String
		if tab == MOVEMENT:
			label = String(movement_rows[index]["title"])
		elif tab == CHEMISTRY:
			label = String(chemistry_rows[index]["title"])
		else:
			var race: Dictionary = overview["rows"][index]
			label = "%s  (%d)" % [race["race"], (race["champions"] as Array).size()]
		_text(canvas, font, row_rect.position + Vector2(10, 25), label, 17, PARCHMENT if index == selected_row else MUTED)
	var title := ""
	if tab == MOVEMENT and not movement_rows.is_empty():
		var row: Dictionary = movement_rows[selected_row]
		title = "%s  |  %s" % [row["title"], row["binding"]]
	elif tab == CHARACTERS:
		var entries := _characters()
		if not entries.is_empty():
			var entry: Dictionary = entries[selected_character]
			title = "%s  /  %s" % [entry["display_name"], String(entry["status"]).to_upper()]
			if entries.size() > 1:
				title += "  [%d/%d: Left / Right]" % [selected_character + 1, entries.size()]
			else:
				title = "Race awaiting a champion"
	elif tab == CHEMISTRY and not chemistry_rows.is_empty():
		title = String(chemistry_rows[selected_row]["title"]) + ("  /  8 interactions" if selected_row > 0 else "  /  the first-eight chemistry sandbox")
	_text(canvas, font, Vector2(402, 176), title, 19, PARCHMENT)
	var lines := visible_detail_lines(font)
	for index: int in range(lines.size()):
		_text(canvas, font, Vector2(402, 210 + index * LINE_HEIGHT), lines[index], FONT_SIZE, PARCHMENT)
	_button(canvas, font, PREVIOUS_ROWS, "< Rows", false)
	_button(canvas, font, NEXT_ROWS, "Rows >", false)
	_button(canvas, font, PREVIOUS_DETAIL, "< Details", false)
	_button(canvas, font, NEXT_DETAIL, "Details >", false)
	_text(canvas, font, Vector2(596, 595), "Detail page %d / %d" % [detail_page + 1, detail_pages(font)], 16, MUTED)
	_text(canvas, font, Vector2(72, 632), "Tab / LB RB: section    Up Down / wheel: rows    Left Right: character    PgUp PgDn / X Y: details", 16, MUTED)
	_text(canvas, font, Vector2(72, 658), "F4 / Back: close  |  Your controls are resting. The shared world does not pause.", 16, BRASS)


static func wrap_text(value: String, font: Font, width: float, size: int = FONT_SIZE) -> Array[String]:
	# Measure the actual loaded font, including a bounded split for a long bind
	# name or translated word. No paragraph is dropped when it spans a page.
	var lines: Array[String] = []
	var limit := maxf(1.0, width)
	for paragraph: String in value.split("\n", true):
		var line := ""
		for word: String in paragraph.split(" ", false):
			var candidate := word if line.is_empty() else line + " " + word
			if font.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x <= limit:
				line = candidate
				continue
			if not line.is_empty():
				lines.append(line)
			line = ""
			for character: String in word:
				if not line.is_empty() and font.get_string_size(line + character, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > limit:
					lines.append(line)
					line = ""
				line += character
		lines.append(line)
	return lines


func _ensure_wrapped(font: Font) -> void:
	var key := "%d/%d/%d/%d" % [tab, selected_row, selected_character, font.get_instance_id()]
	if key == _cache_key:
		return
	_cache_key = key
	_wrapped_lines.clear()
	for paragraph: String in detail_paragraphs():
		_wrapped_lines.append_array(wrap_text(paragraph, font, DETAIL_WIDTH))


func _reset_detail() -> void:
	selected_character = 0
	detail_page = 0
	_cache_key = ""


func _characters() -> Array:
	var rows: Array = overview.get("rows", [])
	return rows[selected_row]["champions"] if tab == CHARACTERS and selected_row >= 0 and selected_row < rows.size() else []


static func _human_list(values: Array) -> String:
	var labels: Array[String] = []
	for value: String in values:
		labels.append(value.replace("_", " "))
	return ", ".join(labels)


static func _text(canvas: CanvasItem, font: Font, position: Vector2, value: String, size: int, color: Color) -> void:
	canvas.draw_string(font, position, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


static func _button(canvas: CanvasItem, font: Font, rectangle: Rect2, label: String, active: bool) -> void:
	canvas.draw_rect(rectangle, Color("51472a") if active else Color("202a23"))
	canvas.draw_rect(rectangle, BRASS if active else Color(BRASS, 0.5), false, 1.0)
	_text(canvas, font, rectangle.position + Vector2(12, 23), label, 17, PARCHMENT)
