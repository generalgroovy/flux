class_name VisualLanguage
extends RefCounted


const DEFAULT_PATH := "res://content/visual/visual_language_v1.json"
const SUPPORTED_SCHEMA_VERSION := 1
const EXPECTED_ID := "flux-visual-language-v1"
const EXPECTED_AUTHORITY := "presentation only; simulation, collision, visibility and outcomes remain authoritative elsewhere"
const REQUIRED_RAMPS := [
	"deep_water", "worldbone", "warm_stone", "timber", "aged_brass",
	"garden", "indigo_roof", "parchment", "health", "flux", "stamina",
]
const REQUIRED_ELEMENTS := [
	"earth", "fire", "water", "wind", "ice", "charge",
	"light", "dark", "spirit", "chaos", "gravity", "time",
]
const REQUIRED_LAYERS := [
	"deep_water", "world_foundation", "traversable_surface", "surface_detail",
	"architecture", "props", "actor_shadow", "actor", "spell_underlay",
	"spell", "spell_impact", "cutaway", "world_prompt", "visibility_mask",
	"combat_hud", "station_overlay", "diagnostics",
]
const REQUIRED_RUBRIC := [
	"cohesion", "silhouette", "material_identity", "world_overview",
	"hud_clarity", "animation_response", "spell_readability",
]

var data: Dictionary = {}
var ramps: Dictionary = {}
var elements: Dictionary = {}
var ui: Dictionary = {}
var budgets: Dictionary = {}
var layer_index: Dictionary = {}
var last_error := ""


func load_from_file(path: String = DEFAULT_PATH) -> bool:
	_clear()
	if not FileAccess.file_exists(path):
		return _fail("Visual language does not exist: %s" % path)
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _fail("Visual language cannot be opened: %s" % path)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return _fail("Visual language root must be an object")
	data = parsed
	return validate()


func validate() -> bool:
	last_error = ""
	ramps.clear()
	elements.clear()
	ui.clear()
	budgets.clear()
	layer_index.clear()
	if int(data.get("schema_version", -1)) != SUPPORTED_SCHEMA_VERSION:
		return _fail("Unsupported visual language schema")
	if String(data.get("id", "")) != EXPECTED_ID:
		return _fail("Unexpected visual language id")
	if String(data.get("authority", "")) != EXPECTED_AUTHORITY:
		return _fail("Visual language must remain presentation-only")
	var pixel: Dictionary = data.get("pixel_contract", {})
	if _vector2i(pixel.get("design_viewport", [])) != Vector2i(640, 360):
		return _fail("Visual language design viewport must remain 640 x 360")
	if int(pixel.get("output_scale", 0)) != 2 or int(pixel.get("base_unit", 0)) != 2:
		return _fail("Visual language requires the two-pixel output grid")
	if not _numeric_array_equals(pixel.get("supported_camera_percent", []), [50.0, 75.0, 100.0]):
		return _fail("Visual language camera contract must remain 50/75/100")
	for flag: String in ["nearest_neighbor", "snap_translation_to_output_pixel", "subpixel_simulation_preserved"]:
		if not bool(pixel.get(flag, false)):
			return _fail("Visual language pixel flag is required: %s" % flag)
	var perspective: Dictionary = data.get("perspective_contract", {})
	if String(perspective.get("projection", "")) != "top_down_cardinal_with_tilted_facades":
		return _fail("Visual language requires the gameplay-safe cardinal projection")
	if perspective.get("floor_axes", []) != ["screen_horizontal", "screen_vertical"]:
		return _fail("Walkable floor axes must remain screen-cardinal")
	if not is_equal_approx(float(perspective.get("floor_tile_aspect_ratio", 0.0)), 1.0):
		return _fail("Walkable floor tiles must remain square in gameplay projection")
	var facade_ratio := float(perspective.get("maximum_facade_rise_to_footprint_ratio", 0.0))
	if facade_ratio <= 0.0 or facade_ratio > 0.85:
		return _fail("Facade rise exceeds the user-friendly perspective bound")
	for flag: String in ["cardinal_navigation_unambiguous", "collision_footprint_visible", "door_threshold_visible", "foreground_cutaway_required", "forbid_diamond_grid", "forbid_art_owned_collision"]:
		if not bool(perspective.get(flag, false)):
			return _fail("Perspective safety flag is required: %s" % flag)
	var character: Dictionary = data.get("character_contract", {})
	if String(character.get("style", "")) != "compact_expressive_cartoon_pixel":
		return _fail("Character style must remain compact expressive cartoon pixel art")
	if not _numeric_array_equals(character.get("head_height_ratio", []), [0.4, 0.45]):
		return _fail("Character head/body readability ratio changed")
	if _vector2i(character.get("grounded_cell", [])) != Vector2i(96, 96) or _vector2i(character.get("grounded_pivot", [])) != Vector2i(48, 84):
		return _fail("Character grounded cell/pivot changed outside migration")
	if not _numeric_array_equals(character.get("gameplay_height_pixels", []), [44.0, 68.0]) \
		or not _numeric_array_equals(character.get("outline_pixels", []), [1.0, 2.0]) \
		or not _numeric_array_equals(character.get("material_ramp_colors", []), [3.0, 5.0]):
		return _fail("Character gameplay-scale pixel budget changed")
	if character.get("required_silhouette_states", []) != ["south", "east", "north", "jump", "cast", "hit"]:
		return _fail("Character silhouette review states changed")
	for flag: String in ["separate_ground_shadow", "forbid_realistic_anatomy", "forbid_sexualized_design"]:
		if not bool(character.get(flag, false)):
			return _fail("Character readability/safety flag is required: %s" % flag)
	var layers: Array = data.get("layers", [])
	if layers != REQUIRED_LAYERS:
		return _fail("Visual layer order differs from the production contract")
	for index: int in layers.size():
		layer_index[String(layers[index])] = index
	ramps = data.get("ramps", {})
	if ramps.size() != REQUIRED_RAMPS.size():
		return _fail("Visual language ramp count changed")
	for ramp_id: String in REQUIRED_RAMPS:
		var ramp: Array = ramps.get(ramp_id, [])
		if ramp.size() != 5:
			return _fail("Visual ramp must expose five ordered values: %s" % ramp_id)
		for color_value: Variant in ramp:
			if not _valid_color(String(color_value)):
				return _fail("Visual ramp contains an invalid color: %s" % ramp_id)
	elements = data.get("elements", {})
	if elements.size() != REQUIRED_ELEMENTS.size():
		return _fail("Visual language must define all twelve element families")
	var shapes: Dictionary = {}
	for element_id: String in REQUIRED_ELEMENTS:
		var element: Dictionary = elements.get(element_id, {})
		for key: String in ["dark", "base", "bright"]:
			if not _valid_color(String(element.get(key, ""))):
				return _fail("Element color is invalid: %s/%s" % [element_id, key])
		var shape := String(element.get("shape", ""))
		var cadence := String(element.get("cadence", ""))
		if shape.is_empty() or cadence.is_empty() or shapes.has(shape):
			return _fail("Element shape/cadence must be present and shape-unique: %s" % element_id)
		shapes[shape] = true
	ui = data.get("ui", {})
	for key: String in ["panel_fill", "panel_fill_strong", "scrim", "text_primary", "text_secondary", "text_muted", "focus", "danger", "pending"]:
		if not _valid_color(String(ui.get(key, ""))):
			return _fail("UI color is invalid: %s" % key)
	for key: String in ["panel_padding", "cell_gap", "outline_thin", "outline_regular", "outline_emphasis", "corner_step", "prompt_maximum_width", "combat_hud_maximum_height"]:
		if int(ui.get(key, 0)) <= 0:
			return _fail("UI metric must be positive: %s" % key)
	budgets = data.get("budgets", {})
	for key: String in budgets:
		if int(budgets[key]) <= 0:
			return _fail("Visual budget must be positive: %s" % key)
	if int(budgets.get("maximum_combat_hud_coverage_percent", 100)) > 20:
		return _fail("Combat HUD coverage budget may not exceed 20 percent")
	var rubric: Dictionary = data.get("rubric", {})
	if rubric.get("categories", []) != REQUIRED_RUBRIC:
		return _fail("Visual rubric category order changed")
	if int(rubric.get("minimum_each", 0)) < 4 or float(rubric.get("minimum_mean", 0.0)) < 4.5:
		return _fail("Visual quality rubric cannot be weakened")
	if bool(rubric.get("automatic_acceptance", true)):
		return _fail("Visual candidates require human review")
	return true


func ramp(ramp_id: String) -> Array[Color]:
	var output: Array[Color] = []
	for value: Variant in ramps.get(ramp_id, []):
		output.append(Color(String(value)))
	return output


func ramp_color(ramp_id: String, index: int) -> Color:
	var values: Array = ramps.get(ramp_id, [])
	return Color(String(values[clampi(index, 0, values.size() - 1)])) if not values.is_empty() else Color.MAGENTA


func ui_color(key: String) -> Color:
	return Color(String(ui.get(key, "#ff00ff")))


func ui_metric(key: String) -> int:
	return int(ui.get(key, 0))


func element_color(element_id: String, value: String = "base") -> Color:
	var element: Dictionary = elements.get(element_id, {})
	return Color(String(element.get(value, "#ff00ff")))


func content_hash() -> String:
	var canonical := JSON.stringify(data, "", true)
	return canonical.sha256_text()


func _clear() -> void:
	data.clear()
	ramps.clear()
	elements.clear()
	ui.clear()
	budgets.clear()
	layer_index.clear()
	last_error = ""


func _fail(message: String) -> bool:
	ramps.clear()
	elements.clear()
	ui.clear()
	budgets.clear()
	layer_index.clear()
	last_error = message
	return false


static func _valid_color(value: String) -> bool:
	return value.length() in [7, 9] and value.begins_with("#") and Color.html_is_valid(value)


static func _vector2i(value: Variant) -> Vector2i:
	if not value is Array or (value as Array).size() != 2:
		return Vector2i(-1, -1)
	return Vector2i(int((value as Array)[0]), int((value as Array)[1]))


static func _numeric_array_equals(value: Variant, expected: Array[float]) -> bool:
	if not value is Array or (value as Array).size() != expected.size():
		return false
	for index: int in expected.size():
		var actual_value: Variant = (value as Array)[index]
		if typeof(actual_value) not in [TYPE_INT, TYPE_FLOAT] or not is_equal_approx(float(actual_value), expected[index]):
			return false
	return true
