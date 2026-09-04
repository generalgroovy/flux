class_name SpellLoomPresenter
extends RefCounted

# One layout contract powers painting and hit testing; no gameplay mutation here.
static func draw_panel(canvas: CanvasItem, editor: SpellLoomEditor, state: PlayerState, catalog: AbilityCatalog, language: VisualLanguage) -> void:
	if state == null:
		return
	var ink := language.ui_color("text_primary")
	var muted := language.ui_color("text_secondary")
	var focus := language.ui_color("focus")
	canvas.draw_rect(Rect2(0, 0, 1280, 720), Color("050806c4"))
	canvas.draw_rect(SpellLoomEditor.PANEL_RECT, Color("111a19fc"))
	canvas.draw_rect(SpellLoomEditor.PANEL_RECT, Color("a58d5d"), false, 2)
	text(canvas, Vector2(48, 58), "SPELL LOOM", 24, ink)
	text(canvas, Vector2(48, 86), "Drag any spell into 1-4, Ctrl+1-4 or Alt+1-4. Every champion can weave the full catalog.", 14, muted)
	text(canvas, Vector2(48, 126), "YOUR 12 SLOTS", 16, ink)
	text(canvas, Vector2(644, 105), "ALL SPELLS  /  %d" % editor.available_wire_ids.size(), 16, ink)
	canvas.draw_rect(SpellLoomEditor.CLOSE_RECT, Color("31433d"))
	text(canvas, SpellLoomEditor.CLOSE_RECT.position + Vector2(10, 23), "X", 17, ink)
	for slot: int in range(PlayerState.SPELL_SLOT_COUNT):
		var rect := SpellLoomEditor.slot_rect(slot)
		var ability := catalog.ability_from_wire(state.spell_wire_id(slot + 1))
		var element := String(ability.get("element", ""))
		var color := language.element_color(element, "base") if not element.is_empty() else muted
		var selected := editor.selected_slot_index == slot
		var target := editor.dragging and SpellLoomEditor.slot_at(editor.pointer_position) == slot
		canvas.draw_rect(rect, Color(color, 0.18 if selected or target else 0.07))
		canvas.draw_rect(rect, focus if selected or target else Color(muted, 0.30), false, 2 if selected or target else 1)
		text(canvas, rect.position + Vector2(9, 22), PlayerState.spell_slot_label(slot), 15, focus)
		text(canvas, rect.position + Vector2(9, 47), String(ability.get("display_name", "Empty")), 13, ink, rect.size.x - 18)
		text(canvas, rect.position + Vector2(9, 68), element.capitalize(), 12, color)
	for column: int in range(AbilityCatalog.SPELL_MATRIX_FAMILIES.size()):
		text(canvas, Vector2(SpellLoomEditor.SPELL_PICKER_X + column * SpellLoomEditor.SPELL_PICKER_WIDTH + 5, 140), AbilityCatalog.SPELL_MATRIX_FAMILIES[column].to_upper(), 11, muted)
	for row: int in range(AbilityCatalog.FIRST_EIGHT_ELEMENTS.size()):
		var row_element := AbilityCatalog.FIRST_EIGHT_ELEMENTS[row]
		var row_color := language.element_color(row_element, "base")
		text(canvas, Vector2(SpellLoomEditor.MATRIX_LABEL_X, SpellLoomEditor.GRID_Y + row * SpellLoomEditor.SPELL_PICKER_HEIGHT + 24), row_element.to_upper(), 11, row_color, 62)
	for index: int in editor.visible_spell_indices():
		var rect := editor.spell_rect(index)
		var ability := catalog.ability_from_wire(editor.available_wire_ids[index])
		var element := String(ability.get("element", ""))
		var color := language.element_color(element, "base")
		var selected := index == editor.selected_spell_index
		canvas.draw_rect(rect, Color(color, 0.22 if selected else 0.08))
		canvas.draw_rect(rect, focus if selected else Color(muted, 0.25), false, 2 if selected else 1)
		canvas.draw_rect(Rect2(rect.position, Vector2(4, rect.size.y)), color)
		text(canvas, rect.position + Vector2(8, 23), String(ability.get("display_name", "Spell")), 11, ink, rect.size.x - 11)
		text(canvas, rect.position + Vector2(8, 35), "%dF" % int(ability.get("flux_cost", 0)), 9, color)
	text(canvas, Vector2(SpellLoomEditor.MATRIX_LABEL_X, 535), "VARIANT", 11, muted, 62)
	var chosen := catalog.ability_from_wire(editor.selected_wire_id())
	canvas.draw_line(Vector2(48, 565), Vector2(1228, 565), Color(muted, 0.3))
	text(canvas, Vector2(48, 594), String(chosen.get("display_name", "Choose a spell")), 19, ink)
	text(canvas, Vector2(330, 594), "%s  /  %s  /  %d Flux  /  %.2fs cooldown" % [String(chosen.get("element", "")).capitalize(), String(chosen.get("family", chosen.get("shape", ""))).capitalize(), int(chosen.get("flux_cost", 0)), float(chosen.get("cooldown_ms", 0)) / 1000.0], 14, muted)
	text(canvas, Vector2(48, 620), editor.status_message, 13, ink, 930)
	text(canvas, Vector2(48, 651), "One element per spell. Equipped spells swap slots; cooldowns stay with spell identity.", 12, muted, 940)
	canvas.draw_rect(SpellLoomEditor.ASSIGN_RECT, Color(focus, 0.18))
	canvas.draw_rect(SpellLoomEditor.ASSIGN_RECT, focus, false, 1)
	text(canvas, SpellLoomEditor.ASSIGN_RECT.position + Vector2(10, 25), "Assign to " + PlayerState.spell_slot_label(editor.selected_slot_index), 13, ink)
	text(canvas, Vector2(48, 682), "Up / Down: slot     Left / Right: spell     Enter / A: assign     Esc / B: close", 12, muted)
	if editor.dragging:
		var ghost := Rect2(editor.pointer_position + Vector2(14, 14), Vector2(176, 38))
		var dragged := catalog.ability_from_wire(editor.available_wire_ids[editor.drag_spell_index])
		canvas.draw_rect(ghost, Color("152a25ed"))
		canvas.draw_rect(ghost, focus, false, 2)
		text(canvas, ghost.position + Vector2(9, 25), String(dragged.get("display_name", "Spell")), 14, ink)


static func text(canvas: CanvasItem, at: Vector2, value: String, size: int, color: Color, width: float = -1.0) -> void:
	canvas.draw_string(ThemeDB.fallback_font, at, value, HORIZONTAL_ALIGNMENT_LEFT, width, size, color)
