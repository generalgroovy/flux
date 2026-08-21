class_name CompactCombatHud
extends RefCounted


const DEFAULT_PATH := "res://content/visual/compact_hud_v1.json"
const EXPECTED_ID := "compact-combat-hud-v1"
const EXPECTED_AUTHORITY := "presentation only; simulation, input legality and resource ownership remain authoritative elsewhere"
const REQUIRED_LAYOUT_KEYS := [
	"margin", "header_width", "header_height", "session_width", "resource_width",
	"resource_height", "resource_bar_height", "spell_cell_width", "spell_cell_height",
	"spell_cell_gap", "spell_footer_height", "panel_corner_step",
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
	champion_id: String,
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
	_draw_resources(canvas, resources, state, champion_id, champion_name, layout, tick_rate)

	var cell_width := float(layout.get("spell_cell_width", 142))
	var cell_height := float(layout.get("spell_cell_height", 70))
	var gap := float(layout.get("spell_cell_gap", 6))
	var spell_width := cell_width * float(PlayerState.SPELL_BUTTON_COUNT) + gap * float(PlayerState.SPELL_BUTTON_COUNT - 1)
	var spell_start := Vector2(viewport_size.x - margin - spell_width, viewport_size.y - margin - cell_height)
	var layer_label := _layer_label(active_layer, copy)
	var layer_tab := Rect2(spell_start + Vector2(0, -24), Vector2(112, 20))
	_draw_panel(canvas, layer_tab, 0.94)
	canvas.draw_rect(Rect2(layer_tab.position + Vector2(5, 5), Vector2(5, 10)), language.ui_color("focus"), true)
	canvas.draw_string(ThemeDB.fallback_font, layer_tab.position + Vector2(16, 14), layer_label, HORIZONTAL_ALIGNMENT_LEFT, layer_tab.size.x - 22.0, 9, language.ui_color("text_primary"))
	for button_index: int in range(PlayerState.SPELL_BUTTON_COUNT):
		var rectangle := Rect2(spell_start + Vector2(float(button_index) * (cell_width + gap), 0), Vector2(cell_width, cell_height))
		var slot_index := active_layer * PlayerState.SPELL_BUTTON_COUNT + button_index
		_draw_spell_cell(canvas, rectangle, state, ability_catalog, slot_index, button_index, tick_rate, copy)


func _draw_resources(canvas: CanvasItem, rectangle: Rect2, state: PlayerState, champion_id: String, champion_name: String, layout: Dictionary, tick_rate: int) -> void:
	_draw_panel(canvas, rectangle, 0.94)
	var medallion := rectangle.position + Vector2(28, 34)
	canvas.draw_circle(medallion + Vector2(2, 3), 19.0, Color(language.ramp_color("worldbone", 0), 0.7))
	canvas.draw_circle(medallion, 18.0, language.ramp_color("aged_brass", 2))
	_draw_portrait(canvas, medallion, champion_id)
	canvas.draw_string(ThemeDB.fallback_font, rectangle.position + Vector2(54, 19), champion_name.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, rectangle.size.x - 64.0, 11, language.ui_color("text_primary"))
	var bar_x := rectangle.position.x + 54.0
	var bar_width := rectangle.size.x - 66.0
	var bar_height := float(layout.get("resource_bar_height", 20))
	_draw_resource_bar(canvas, Rect2(bar_x, rectangle.position.y + 29, bar_width, bar_height), "HEALTH", state.health, state.health_maximum, language.ramp_color("health", 3))
	_draw_resource_bar(canvas, Rect2(bar_x, rectangle.position.y + 56, bar_width, bar_height), flux_status_label(state, tick_rate), state.flux, state.flux_maximum, language.ramp_color("flux", 3))
	_draw_resource_bar(canvas, Rect2(bar_x, rectangle.position.y + 83, bar_width, bar_height), "STAMINA", state.stamina, state.stamina_maximum, language.ramp_color("stamina", 3))


static func flux_status_label(state: PlayerState, tick_rate: int) -> String:
	if state == null or state.flux >= state.flux_maximum:
		return "FLUX"
	if state.flux_recovery_delay_ticks > 0:
		return "FLUX WAIT %.1fs" % (float(state.flux_recovery_delay_ticks) / float(maxi(1, tick_rate)))
	return "FLUX RISING"


func _draw_resource_bar(canvas: CanvasItem, rectangle: Rect2, label: String, value: int, maximum: int, color: Color) -> void:
	var ratio := clampf(float(value) / float(maxi(maximum, 1)), 0.0, 1.0)
	canvas.draw_rect(rectangle, Color(language.ramp_color("worldbone", 0), 0.92), true)
	canvas.draw_rect(Rect2(rectangle.position + Vector2(2, 2), Vector2((rectangle.size.x - 4.0) * ratio, rectangle.size.y - 4.0)), color, true)
	canvas.draw_rect(rectangle, Color(language.ui_color("text_primary"), 0.52), false, 1.0)
	for marker_index: int in range(1, 4):
		var marker_x := rectangle.position.x + rectangle.size.x * float(marker_index) / 4.0
		canvas.draw_line(Vector2(marker_x, rectangle.position.y + 2), Vector2(marker_x, rectangle.end.y - 2), Color(language.ramp_color("worldbone", 0), 0.36), 1.0)
	canvas.draw_string(ThemeDB.fallback_font, rectangle.position + Vector2(6, 14), "%s  %d/%d" % [label, value / 1000, maximum / 1000], HORIZONTAL_ALIGNMENT_LEFT, rectangle.size.x - 12.0, 10, language.ui_color("text_primary"))


func _draw_spell_cell(canvas: CanvasItem, rectangle: Rect2, state: PlayerState, ability_catalog: AbilityCatalog, slot_index: int, button_index: int, tick_rate: int, copy: Dictionary) -> void:
	var wire_id: int = state.spell_wire_id(slot_index + 1)
	var ability: Dictionary = ability_catalog.ability_from_wire(wire_id)
	var empty := ability.is_empty()
	var element := String(ability.get("element", "dark"))
	var accent := language.element_color(element, "bright") if not empty and language.elements.has(element) else language.ui_color("text_muted")
	_draw_panel(canvas, rectangle, 0.95)
	canvas.draw_rect(rectangle, Color(accent, 0.72), false, 2.0)
	_draw_element_glyph(canvas, rectangle.position + Vector2(18, 20), element, accent, empty)
	canvas.draw_string(ThemeDB.fallback_font, rectangle.position + Vector2(34, 15), "%d  %s" % [button_index + 1, "EMPTY" if empty else String(ability.get("display_name", "SPELL")).to_upper()], HORIZONTAL_ALIGNMENT_LEFT, rectangle.size.x - 40.0, 10, language.ui_color("text_primary") if not empty else language.ui_color("text_muted"))
	if empty:
		canvas.draw_string(ThemeDB.fallback_font, rectangle.position + Vector2(10, 35), String(copy.get("loom", "WEAVE AT LOOM")), HORIZONTAL_ALIGNMENT_LEFT, rectangle.size.x - 20.0, 9, language.ui_color("text_muted"))
		return
	var cooldown_ticks := _cooldown_for_wire(state, wire_id)
	var flux_cost_units := int(ability.get("flux_cost", 0))
	var affordable := spell_is_affordable(state, ability)
	var status := (String(copy.get("ready", "READY")) if affordable else "NEED %d F" % flux_cost_units) if cooldown_ticks <= 0 else "%.1fs" % (float(cooldown_ticks) / float(maxi(tick_rate, 1)))
	var affordability := "FREE" if flux_cost_units == 0 else "%d F" % flux_cost_units
	canvas.draw_string(ThemeDB.fallback_font, rectangle.position + Vector2(10, 35), "%s · %s" % [String(ability.get("shape", "spell")).to_upper(), affordability], HORIZONTAL_ALIGNMENT_LEFT, rectangle.size.x - 20.0, 9, language.ui_color("text_secondary"))
	canvas.draw_string(ThemeDB.fallback_font, rectangle.position + Vector2(10, 55), status, HORIZONTAL_ALIGNMENT_LEFT, rectangle.size.x - 20.0, 10, (accent if affordable else language.ui_color("danger")) if cooldown_ticks <= 0 else language.ui_color("pending"))


static func spell_is_affordable(state: PlayerState, ability: Dictionary) -> bool:
	return state != null and state.flux >= maxi(0, int(ability.get("flux_cost", 0))) * 1000


static func _cooldown_for_wire(state: PlayerState, wire_id: int) -> int:
	if wire_id == state.primary_wire_id:
		return state.primary_cooldown_ticks
	if wire_id == state.active_1_wire_id:
		return state.active_1_cooldown_ticks
	if wire_id == state.active_2_wire_id:
		return state.active_2_cooldown_ticks
	return 0


func _draw_panel(canvas: CanvasItem, rectangle: Rect2, opacity: float) -> void:
	var step := float((data.get("layout", {}) as Dictionary).get("panel_corner_step", 6))
	var points := PackedVector2Array([
		rectangle.position + Vector2(step, 0), rectangle.end - Vector2(step, rectangle.size.y),
		rectangle.end - Vector2(0, rectangle.size.y - step), rectangle.end - Vector2(0, step),
		rectangle.end - Vector2(step, 0), rectangle.position + Vector2(step, rectangle.size.y),
		rectangle.position + Vector2(0, rectangle.size.y - step), rectangle.position + Vector2(0, step),
	])
	canvas.draw_colored_polygon(points, Color(language.ui_color("panel_fill"), opacity))
	var outline := points.duplicate()
	outline.append(points[0])
	canvas.draw_polyline(outline, Color(language.ramp_color("aged_brass", 2), 0.72 * opacity), 1.0, false)


func _draw_portrait(canvas: CanvasItem, center: Vector2, champion_id: String) -> void:
	canvas.draw_circle(center, 14.0, language.ramp_color("worldbone", 0))
	if champion_id == "oh_tipi":
		var water := language.element_color("water", "base")
		var ice := language.element_color("ice", "bright")
		canvas.draw_colored_polygon(PackedVector2Array([center + Vector2(-13, -2), center + Vector2(-18, -9), center + Vector2(-17, 3)]), water)
		canvas.draw_colored_polygon(PackedVector2Array([center + Vector2(13, -2), center + Vector2(18, -9), center + Vector2(17, 3)]), water)
		canvas.draw_circle(center, 11.0, water)
		for crest_x: float in [-6.0, 0.0, 6.0]:
			canvas.draw_colored_polygon(PackedVector2Array([center + Vector2(crest_x - 3, -8), center + Vector2(crest_x, -17), center + Vector2(crest_x + 3, -8)]), ice)
		canvas.draw_circle(center + Vector2(-4, 0), 2.0, language.ramp_color("worldbone", 0))
		canvas.draw_circle(center + Vector2(4, 0), 2.0, language.ramp_color("worldbone", 0))
		canvas.draw_line(center + Vector2(-4, 7), center + Vector2(4, 7), ice, 1.0)
	elif champion_id == "s_wayne":
		var skin := language.ramp_color("warm_stone", 3)
		var hair := language.ramp_color("timber", 0)
		canvas.draw_circle(center, 11.0, skin)
		canvas.draw_colored_polygon(PackedVector2Array([center + Vector2(-12, -3), center + Vector2(-17, 0), center + Vector2(-11, 4)]), skin)
		canvas.draw_colored_polygon(PackedVector2Array([center + Vector2(12, -3), center + Vector2(17, 0), center + Vector2(11, 4)]), skin)
		canvas.draw_arc(center + Vector2(0, -2), 11.0, PI, TAU, 14, hair, 6.0)
		canvas.draw_circle(center + Vector2(-4, 1), 1.7, language.element_color("dark", "bright"))
		canvas.draw_circle(center + Vector2(4, 1), 1.7, language.element_color("light", "bright"))
		canvas.draw_arc(center + Vector2(0, 4), 5.0, 0.2, PI - 0.2, 8, hair, 1.0)
	else:
		canvas.draw_circle(center, 11.0, language.ramp_color("warm_stone", 3))
		canvas.draw_arc(center, 11.0, PI, TAU, 14, language.ramp_color("timber", 0), 5.0)


func _draw_element_glyph(canvas: CanvasItem, center: Vector2, element: String, accent: Color, empty: bool) -> void:
	canvas.draw_circle(center, 9.0, Color(accent, 0.14 if empty else 0.24))
	if empty:
		canvas.draw_arc(center, 5.0, 0.0, TAU, 12, accent, 1.0)
		return
	match element:
		"water":
			canvas.draw_arc(center + Vector2(-1, 1), 6.0, -2.6, 0.5, 12, accent, 2.0)
			canvas.draw_circle(center + Vector2(3, 2), 2.0, accent)
		"ice":
			for index: int in range(6):
				var ray := Vector2.from_angle(TAU * float(index) / 6.0)
				canvas.draw_line(center, center + ray * 7.0, accent, 1.0)
		"dark":
			canvas.draw_arc(center, 7.0, -2.4, 0.7, 12, accent, 2.0)
		"light":
			var diamond := PackedVector2Array([center + Vector2(0, -7), center + Vector2(7, 0), center + Vector2(0, 7), center + Vector2(-7, 0), center + Vector2(0, -7)])
			canvas.draw_polyline(diamond, accent, 2.0, false)
		_:
			canvas.draw_circle(center, 4.0, accent)


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
