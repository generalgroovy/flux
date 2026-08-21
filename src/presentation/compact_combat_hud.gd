class_name CompactCombatHud
extends RefCounted


const DEFAULT_PATH := "res://content/visual/compact_hud_v1.json"
const EXPECTED_ID := "compact-combat-hud-v1"
const EXPECTED_AUTHORITY := "presentation only; simulation, input legality and resource ownership remain authoritative elsewhere"
const REQUIRED_LAYOUT_KEYS := [
	"margin", "header_width", "header_height", "session_width", "resource_width",
	"resource_height", "resource_bar_height", "spell_cell_width", "spell_cell_height",
	"spell_cell_gap", "spell_footer_height",
]

var language: VisualLanguage
var data: Dictionary = {}
var content_hash := ""
var last_error := ""


func configure(visual_language: VisualLanguage, path: String = DEFAULT_PATH) -> bool:
	language = visual_language
	data.clear()
	content_hash = ""
	last_error = ""
	if language == null or language.ramps.is_empty():
		return _fail("Compact HUD requires the validated visual language")
	if not FileAccess.file_exists(path):
		return _fail("Compact HUD layout does not exist: %s" % path)
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _fail("Compact HUD layout cannot be opened")
	var source := file.get_as_text()
	var parsed: Variant = JSON.parse_string(source)
	if not parsed is Dictionary:
		return _fail("Compact HUD layout root must be an object")
	data = parsed
	if not validate():
		data.clear()
		return false
	content_hash = source.sha256_text()
	return true


func validate() -> bool:
	last_error = ""
	if int(data.get("schema_version", -1)) != 1 or String(data.get("id", "")) != EXPECTED_ID:
		return _fail("Compact HUD identity is unsupported")
	if String(data.get("authority", "")) != EXPECTED_AUTHORITY:
		return _fail("Compact HUD must remain presentation-only")
	var layout_value: Variant = data.get("layout", {})
	if not layout_value is Dictionary:
		return _fail("Compact HUD layout must be an object")
	var layout: Dictionary = layout_value
	for key: String in REQUIRED_LAYOUT_KEYS:
		if int(layout.get(key, 0)) <= 0:
			return _fail("Compact HUD layout value is missing or invalid: %s" % key)
	if int(layout.get("margin", 0)) > 48 or int(layout.get("header_width", 0)) > 420 \
		or int(layout.get("session_width", 0)) > 360 or int(layout.get("resource_width", 0)) > 360 \
		or int(layout.get("resource_height", 0)) > 180 or int(layout.get("spell_cell_width", 0)) > 180 \
		or int(layout.get("spell_cell_height", 0)) > 96:
		return _fail("Compact HUD layout exceeds bounded presentation dimensions")
	var copy_value: Variant = data.get("copy", {})
	if not copy_value is Dictionary:
		return _fail("Compact HUD copy must be an object")
	for copy_key: String in ["plain", "ctrl", "alt", "ready", "loom"]:
		if String((copy_value as Dictionary).get(copy_key, "")).is_empty():
			return _fail("Compact HUD copy is incomplete: %s" % copy_key)
	var coverage := int(data.get("maximum_view_coverage_percent", 0))
	if coverage < 6 or coverage > int(language.data.get("budgets", {}).get("maximum_combat_hud_coverage_percent", 19)):
		return _fail("Compact HUD coverage is outside the visual budget")
	return true


func draw(
	canvas: CanvasItem,
	viewport_size: Vector2,
	state: PlayerState,
	ability_catalog: AbilityCatalog,
	champion_name: String,
	location_name: String,
	session_label: String,
	active_layer: int,
	tick_rate: int,
	spectating: bool,
) -> void:
	if canvas == null or state == null or ability_catalog == null or language == null:
		return
	var layout: Dictionary = data.get("layout", {})
	var copy: Dictionary = data.get("copy", {})
	var margin := float(layout.get("margin", 16))
	var header_height := float(layout.get("header_height", 34))
	var header := Rect2(margin, margin, float(layout.get("header_width", 312)), header_height)
	var session_width := float(layout.get("session_width", 248))
	var session := Rect2(viewport_size.x - margin - session_width, margin, session_width, header_height)
	_draw_panel(canvas, header, 1.0)
	_draw_panel(canvas, session, 0.82)
	var title := ("WATCHING " if spectating else "") + champion_name.to_upper()
	canvas.draw_string(ThemeDB.fallback_font, header.position + Vector2(10, 15), title, HORIZONTAL_ALIGNMENT_LEFT, header.size.x - 20.0, 12, language.ui_color("text_primary"))
	canvas.draw_string(ThemeDB.fallback_font, header.position + Vector2(10, 29), location_name.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, header.size.x - 20.0, 10, language.ui_color("text_secondary"))
	canvas.draw_string(ThemeDB.fallback_font, session.position + Vector2(10, 21), session_label.to_upper(), HORIZONTAL_ALIGNMENT_RIGHT, session.size.x - 20.0, 11, language.ui_color("focus"))

	var resource_width := float(layout.get("resource_width", 270))
	var resource_height := float(layout.get("resource_height", 118))
	var resources := Rect2(margin, viewport_size.y - margin - resource_height, resource_width, resource_height)
	_draw_resources(canvas, resources, state, champion_name, layout)

	var cell_width := float(layout.get("spell_cell_width", 142))
	var cell_height := float(layout.get("spell_cell_height", 70))
	var gap := float(layout.get("spell_cell_gap", 6))
	var spell_width := cell_width * float(PlayerState.SPELL_BUTTON_COUNT) + gap * float(PlayerState.SPELL_BUTTON_COUNT - 1)
	var spell_start := Vector2(viewport_size.x - margin - spell_width, viewport_size.y - margin - cell_height)
	var layer_label := _layer_label(active_layer, copy)
	canvas.draw_string(ThemeDB.fallback_font, spell_start + Vector2(0, -8), layer_label, HORIZONTAL_ALIGNMENT_LEFT, spell_width, 10, language.ui_color("text_secondary"))
	for button_index: int in range(PlayerState.SPELL_BUTTON_COUNT):
		var rectangle := Rect2(spell_start + Vector2(float(button_index) * (cell_width + gap), 0), Vector2(cell_width, cell_height))
		var slot_index := active_layer * PlayerState.SPELL_BUTTON_COUNT + button_index
		_draw_spell_cell(canvas, rectangle, state, ability_catalog, slot_index, button_index, tick_rate, copy)


func _draw_resources(canvas: CanvasItem, rectangle: Rect2, state: PlayerState, champion_name: String, layout: Dictionary) -> void:
	_draw_panel(canvas, rectangle, 0.94)
	var medallion := rectangle.position + Vector2(28, 34)
	canvas.draw_circle(medallion + Vector2(2, 3), 19.0, Color(language.ramp_color("worldbone", 0), 0.7))
	canvas.draw_circle(medallion, 18.0, language.ramp_color("aged_brass", 2))
	canvas.draw_circle(medallion, 14.0, language.element_color("water", "base"))
	var initials := champion_name.left(2).to_upper()
	canvas.draw_string(ThemeDB.fallback_font, medallion + Vector2(-9, 4), initials, HORIZONTAL_ALIGNMENT_LEFT, 20.0, 9, language.ui_color("text_primary"))
	canvas.draw_string(ThemeDB.fallback_font, rectangle.position + Vector2(54, 19), champion_name.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, rectangle.size.x - 64.0, 11, language.ui_color("text_primary"))
	var bar_x := rectangle.position.x + 54.0
	var bar_width := rectangle.size.x - 66.0
	var bar_height := float(layout.get("resource_bar_height", 20))
	_draw_resource_bar(canvas, Rect2(bar_x, rectangle.position.y + 29, bar_width, bar_height), "HEALTH", state.health, state.health_maximum, language.ramp_color("health", 3))
	_draw_resource_bar(canvas, Rect2(bar_x, rectangle.position.y + 56, bar_width, bar_height), "FLUX", state.flux, state.flux_maximum, language.ramp_color("flux", 3))
	_draw_resource_bar(canvas, Rect2(bar_x, rectangle.position.y + 83, bar_width, bar_height), "STAMINA", state.stamina, state.stamina_maximum, language.ramp_color("stamina", 3))


func _draw_resource_bar(canvas: CanvasItem, rectangle: Rect2, label: String, value: int, maximum: int, color: Color) -> void:
	var ratio := clampf(float(value) / float(maxi(maximum, 1)), 0.0, 1.0)
	canvas.draw_rect(rectangle, Color(language.ramp_color("worldbone", 0), 0.92), true)
	canvas.draw_rect(Rect2(rectangle.position + Vector2(2, 2), Vector2((rectangle.size.x - 4.0) * ratio, rectangle.size.y - 4.0)), color, true)
	canvas.draw_rect(rectangle, Color(language.ui_color("text_primary"), 0.52), false, 1.0)
	canvas.draw_string(ThemeDB.fallback_font, rectangle.position + Vector2(6, 14), "%s  %d/%d" % [label, value / 1000, maximum / 1000], HORIZONTAL_ALIGNMENT_LEFT, rectangle.size.x - 12.0, 10, language.ui_color("text_primary"))


func _draw_spell_cell(canvas: CanvasItem, rectangle: Rect2, state: PlayerState, ability_catalog: AbilityCatalog, slot_index: int, button_index: int, tick_rate: int, copy: Dictionary) -> void:
	var wire_id: int = state.spell_wire_id(slot_index + 1)
	var ability: Dictionary = ability_catalog.ability_from_wire(wire_id)
	var empty := ability.is_empty()
	var element := String(ability.get("element", "dark"))
	var accent := language.element_color(element, "bright") if not empty and language.elements.has(element) else language.ui_color("text_muted")
	_draw_panel(canvas, rectangle, 0.95)
	canvas.draw_rect(rectangle, Color(accent, 0.72), false, 2.0)
	canvas.draw_circle(rectangle.position + Vector2(18, 20), 9.0, Color(accent, 0.26))
	canvas.draw_circle(rectangle.position + Vector2(18, 20), 4.0, accent)
	canvas.draw_string(ThemeDB.fallback_font, rectangle.position + Vector2(34, 15), "%d  %s" % [button_index + 1, "EMPTY" if empty else String(ability.get("display_name", "SPELL")).to_upper()], HORIZONTAL_ALIGNMENT_LEFT, rectangle.size.x - 40.0, 10, language.ui_color("text_primary") if not empty else language.ui_color("text_muted"))
	if empty:
		canvas.draw_string(ThemeDB.fallback_font, rectangle.position + Vector2(10, 35), String(copy.get("loom", "WEAVE AT LOOM")), HORIZONTAL_ALIGNMENT_LEFT, rectangle.size.x - 20.0, 9, language.ui_color("text_muted"))
		return
	var cooldown_ticks := _cooldown_for_wire(state, wire_id)
	var flux_cost := int(ability.get("flux_cost", 0))
	var status := String(copy.get("ready", "READY")) if cooldown_ticks <= 0 else "%.1fs" % (float(cooldown_ticks) / float(maxi(tick_rate, 1)))
	var affordability := "FREE" if flux_cost == 0 else "%d F" % flux_cost
	canvas.draw_string(ThemeDB.fallback_font, rectangle.position + Vector2(10, 35), "%s · %s" % [String(ability.get("shape", "spell")).to_upper(), affordability], HORIZONTAL_ALIGNMENT_LEFT, rectangle.size.x - 20.0, 9, language.ui_color("text_secondary"))
	canvas.draw_string(ThemeDB.fallback_font, rectangle.position + Vector2(10, 55), status, HORIZONTAL_ALIGNMENT_LEFT, rectangle.size.x - 20.0, 10, accent if cooldown_ticks <= 0 else language.ui_color("pending"))


static func _cooldown_for_wire(state: PlayerState, wire_id: int) -> int:
	if wire_id == state.primary_wire_id:
		return state.primary_cooldown_ticks
	if wire_id == state.active_1_wire_id:
		return state.active_1_cooldown_ticks
	if wire_id == state.active_2_wire_id:
		return state.active_2_cooldown_ticks
	return 0


func _draw_panel(canvas: CanvasItem, rectangle: Rect2, opacity: float) -> void:
	canvas.draw_rect(rectangle, Color(language.ui_color("panel_fill"), opacity), true)
	canvas.draw_rect(rectangle, Color(language.ramp_color("aged_brass", 2), 0.72 * opacity), false, 1.0)


func _layer_label(active_layer: int, copy: Dictionary) -> String:
	match active_layer:
		1:
			return String(copy.get("ctrl", "CTRL SPELLS"))
		2:
			return String(copy.get("alt", "ALT SPELLS"))
		_:
			return String(copy.get("plain", "PLAIN SPELLS"))


func _fail(message: String) -> bool:
	last_error = message
	return false
