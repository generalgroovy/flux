class_name SpellLoomPresenter
extends RefCounted

# One layout contract powers painting and hit testing; no gameplay mutation here.
static func draw_panel(canvas: CanvasItem, editor: SpellLoomEditor, state: PlayerState, catalog: AbilityCatalog, language: VisualLanguage) -> void:
	if state == null:
		return
	var ink := language.ui_color("text_primary")
	var muted := language.ui_color("text_secondary")
	var focus := language.ui_color("focus")
	canvas.draw_rect(Rect2(0, 0, 1280, 720), Color("050806b8"))
	canvas.draw_rect(SpellLoomEditor.PANEL_RECT, Color("111a19fa"))
	canvas.draw_rect(SpellLoomEditor.PANEL_RECT, Color("a58d5d"), false, 2)
	text(canvas, Vector2(72, 82), "SPELL LOOM", 26, ink)
	text(canvas, Vector2(72, 111), "Choose your spells. Every character can use the whole catalog.", 16, muted)
	text(canvas, Vector2(72, 151), "YOUR 12 SLOTS", 17, ink)
	text(canvas, Vector2(636, 151), "ALL SPELLS  /  %d" % editor.available_wire_ids.size(), 17, ink)
	canvas.draw_rect(SpellLoomEditor.CLOSE_RECT, Color("31433d"))
	text(canvas, SpellLoomEditor.CLOSE_RECT.position + Vector2(12, 24), "X", 18, ink)
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
		text(canvas, rect.position + Vector2(9, 70), element.capitalize(), 12, color)
	for index: int in editor.visible_spell_indices():
		var rect := editor.spell_rect(index)
		var ability := catalog.ability_from_wire(editor.available_wire_ids[index])
		var element := String(ability.get("element", ""))
		var color := language.element_color(element, "base")
		var selected := index == editor.selected_spell_index
		canvas.draw_rect(rect, Color(color, 0.22 if selected else 0.08))
		canvas.draw_rect(rect, focus if selected else Color(muted, 0.25), false, 2 if selected else 1)
		canvas.draw_rect(Rect2(rect.position, Vector2(4, rect.size.y)), color)
		text(canvas, rect.position + Vector2(10, 24), String(ability.get("display_name", "Spell")), 13, ink, rect.size.x - 16)
		text(canvas, rect.position + Vector2(10, 47), element.capitalize(), 12, color)
	var chosen := catalog.ability_from_wire(editor.selected_wire_id())
	canvas.draw_line(Vector2(72, 474), Vector2(1194, 474), Color(muted, 0.3))
	text(canvas, Vector2(72, 508), String(chosen.get("display_name", "Choose a spell")), 21, ink)
	text(canvas, Vector2(430, 508), "%s  /  %s  /  %d Flux  /  %.2fs cooldown" % [String(chosen.get("element", "")).capitalize(), String(chosen.get("shape", "")).capitalize(), int(chosen.get("flux_cost", 0)), float(chosen.get("cooldown_ms", 0)) / 1000.0], 16, muted)
	text(canvas, Vector2(72, 537), "One element per spell. Mixed-element attacks unlock after chemistry testing.", 14, muted)
	text(canvas, Vector2(72, 572), editor.status_message, 14, ink, 1110)
	text(canvas, Vector2(72, 615), "Drag to assign. Equipped spells swap slots; their cooldowns stay intact.", 14, muted, 870)
	canvas.draw_rect(SpellLoomEditor.ASSIGN_RECT, Color(focus, 0.18))
	canvas.draw_rect(SpellLoomEditor.ASSIGN_RECT, focus, false, 1)
	text(canvas, SpellLoomEditor.ASSIGN_RECT.position + Vector2(12, 26), "Assign to " + PlayerState.spell_slot_label(editor.selected_slot_index), 15, ink)
	text(canvas, Vector2(72, 655), "Up / Down: slot     Left / Right: spell     Enter / A: assign     Esc / B: close", 13, muted)
	if editor.dragging:
		var ghost := Rect2(editor.pointer_position + Vector2(14, 14), Vector2(176, 38))
		var dragged := catalog.ability_from_wire(editor.available_wire_ids[editor.drag_spell_index])
		canvas.draw_rect(ghost, Color("152a25ed"))
		canvas.draw_rect(ghost, focus, false, 2)
		text(canvas, ghost.position + Vector2(9, 25), String(dragged.get("display_name", "Spell")), 14, ink)


static func text(canvas: CanvasItem, at: Vector2, value: String, size: int, color: Color, width: float = -1.0) -> void:
	canvas.draw_string(ThemeDB.fallback_font, at, value, HORIZONTAL_ALIGNMENT_LEFT, width, size, color)
