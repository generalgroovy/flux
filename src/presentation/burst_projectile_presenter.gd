class_name BurstProjectilePresenter
extends RefCounted


const DEFAULT_PATH := "res://content/visual/burst_projectile_runtime_v3.json"
const ElementGlyphRendererScript = preload("res://src/presentation/element_glyph_renderer.gd")
const EXPECTED_ID := "burst-projectile-runtime-v3"
const REQUIRED_ELEMENTS := ["neutral", "fire", "water", "wind", "earth", "charge", "ice", "light", "dark"]
const DIRECTION_ORDER := ["north", "north_east", "east", "south_east", "south", "south_west", "west", "north_west"]
const PHASE_COLUMNS := {
	"spawn": [0, 1],
	"travel": [2, 3, 4, 5, 6, 7],
	"impact": [8, 9, 10, 11],
	"residue": [12, 13, 14],
	"reserved_blank": [15],
}
const CELL_SIZE := 32
const COLUMN_COUNT := 16
const ROW_COUNT := 8

var language: VisualLanguage
var catalog: AbilityCatalog
var data: Dictionary = {}
var direction_contract := SpellDeliveryDirectionContract.new()
var textures_by_element: Dictionary[String, Texture2D] = {}
var entries_by_element: Dictionary[String, Dictionary] = {}
var content_hash := ""
var direction_contract_hash := ""
var last_error := ""


func configure(visual_language: VisualLanguage, ability_catalog: AbilityCatalog, path: String = DEFAULT_PATH, load_textures: bool = true) -> bool:
	language = visual_language
	catalog = ability_catalog
	data = {}
	direction_contract = SpellDeliveryDirectionContract.new()
	textures_by_element = {}
	entries_by_element = {}
	content_hash = ""
	direction_contract_hash = ""
	last_error = ""
	if language == null or catalog == null or language.elements.is_empty() or catalog.elements_by_id.is_empty():
		return _fail("Burst presentation requires validated visual and ability catalogs")
	if not direction_contract.load_from_file():
		return _fail(direction_contract.last_error)
	direction_contract_hash = direction_contract.content_hash
	if not FileAccess.file_exists(path):
		return _fail("Burst presentation manifest does not exist: %s" % path)
	var source := FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(source)
	if not parsed is Dictionary:
		return _fail("Burst presentation manifest root must be an object")
	data = parsed
	if not validate(load_textures):
		data = {}
		return false
	content_hash = source.replace("\r\n", "\n").replace("\r", "\n").sha256_text()
	return true


func validate(load_textures: bool = true) -> bool:
	last_error = ""
	textures_by_element = {}
	entries_by_element = {}
	if int(data.get("schema_version", 0)) != 1 or String(data.get("id", "")) != EXPECTED_ID:
		return _fail("Burst presentation identity is unsupported")
	if String(data.get("status", "")) != "runtime-approved" or not bool(data.get("runtime_approved", false)) or bool(data.get("release_approved", true)):
		return _fail("Burst presentation approval state is invalid")
	if String(data.get("authority", "")) != "presentation-only":
		return _fail("Burst sprites cannot own simulation authority")
	if not direction_contract.is_valid():
		return _fail("Burst presentation requires the validated shared direction contract")
	if not _validate_provenance() or not _validate_contract():
		return false
	return _validate_assets(load_textures)


func draw_projectile(canvas: CanvasItem, projectile: ProjectileState, _tick: int, reduced_effects: bool, interpolation_alpha: float = 1.0) -> bool:
	if canvas == null or projectile == null or catalog == null:
		return false
	var ability := catalog.ability_from_wire(projectile.source_wire_id)
	if String(ability.get("shape", "")) != "projectile":
		return false
	var element := String(ability.get("element", "neutral"))
	if not entries_by_element.has(element):
		return false
	var position := ProjectilePresentationMotion.interpolated_position(projectile, interpolation_alpha)
	var direction := ProjectilePresentationMotion.travel_direction(projectile)
	var radius := float(projectile.radius) / SimConfig.FIXED_SCALE
	var color := language.element_color(element, "base")
	# One stable color, one bounded core, one short trail. The tiny dark rune
	# distinguishes elements without color; no orbiting dots or blended hues.
	if not reduced_effects:
		var length := minf(ProjectilePresentationMotion.trail_length(projectile, false), radius * 1.8)
		canvas.draw_line(position - direction * (radius + length), position, Color(color, 0.30), maxf(2.0, radius * 0.7), false)
	canvas.draw_circle(position, radius + 2.0, Color("101a22"))
	canvas.draw_circle(position, radius, color)
	canvas.draw_arc(position, radius - 1.0, PI * 1.1, PI * 1.65, 8, Color(color.lightened(0.45), 0.8), 2.0, false)
	if not ElementGlyphRendererScript.draw(canvas, language, position, element, maxf(3.0, radius * 0.50), Color("17202bdd")):
		canvas.draw_circle(position, 1.5, Color("17202bdd"))
	return true


func texture(element: String) -> Texture2D:
	return textures_by_element.get(element)


func entry(element: String) -> Dictionary:
	return entries_by_element.get(element, {})


static func direction_index(velocity: Vector2) -> int:
	var direction_id := SpellDeliveryDirectionContract.direction_id(velocity)
	return DIRECTION_ORDER.find(direction_id)


static func travel_column(tick: int, projectile_id: int, reduced_effects: bool) -> int:
	var divisor := 4 if reduced_effects else 2
	return 2 + posmod(tick / divisor + projectile_id, 6)


func _validate_provenance() -> bool:
	var provenance: Dictionary = data.get("provenance", {})
	if String(provenance.get("source_method", "")) != "built-in-image-generation-style-board" \
		or bool(provenance.get("third_party_pixel_inputs", true)) \
		or String(provenance.get("distribution_license", "")) != "pending-project-license" \
		or String(provenance.get("review", "")).is_empty():
		return _fail("Burst presentation provenance is incomplete")
	var source_path := String(provenance.get("source_path", ""))
	var source_hash := String(provenance.get("source_sha256", ""))
	var generator_path := String(provenance.get("generator_path", ""))
	var generator_hash := String(provenance.get("generator_sha256", ""))
	if source_path != "res://reference/art/projectiles/burst_v3/burst_element_style_board_v3.png" or generator_path != "res://tools/assets/prepare_burst_runtime_v3.py" \
		or source_hash.length() != 64 or generator_hash.length() != 64:
		return _fail("Burst presentation provenance paths or hashes are invalid")
	if OS.has_feature("editor"):
		if not FileAccess.file_exists(source_path) or FileAccess.get_sha256(source_path) != source_hash:
			return _fail("Burst style-board provenance changed")
		if not FileAccess.file_exists(generator_path) or canonical_text_sha256(generator_path) != generator_hash:
			return _fail("Burst runtime generator provenance changed")
	return true


func _validate_contract() -> bool:
	var contract: Dictionary = data.get("contract", {})
	if not _int_array_equals(contract.get("cell_size", []), [CELL_SIZE, CELL_SIZE]) or int(contract.get("columns", 0)) != COLUMN_COUNT \
		or int(contract.get("rows", 0)) != ROW_COUNT or not _int_array_equals(contract.get("pivot", []), [16, 16]):
		return _fail("Burst sprite grid or pivot changed")
	var raw_directions: Variant = contract.get("direction_order", [])
	if not raw_directions is Array or (raw_directions as Array).size() != DIRECTION_ORDER.size():
		return _fail("Burst direction or phase vocabulary changed")
	for index: int in range(DIRECTION_ORDER.size()):
		if String((raw_directions as Array)[index]) != DIRECTION_ORDER[index]:
			return _fail("Burst direction or phase vocabulary changed")
	var raw_phases: Variant = contract.get("phase_columns", {})
	if not raw_phases is Dictionary or (raw_phases as Dictionary).size() != PHASE_COLUMNS.size():
		return _fail("Burst direction or phase vocabulary changed")
	for phase_id: String in PHASE_COLUMNS:
		if not _int_array_equals((raw_phases as Dictionary).get(phase_id, []), PHASE_COLUMNS[phase_id]):
			return _fail("Burst direction or phase vocabulary changed")
	if String(contract.get("texture_filter", "")) != "nearest" or bool(contract.get("mipmaps", true)) \
		or String(contract.get("simulation_aim", "")) != "continuous-normalized-vector" \
		or String(contract.get("visual_orientation", "")) != "nearest-eight-direction" \
		or String(contract.get("collision_core", "")) != "simulation-owned":
		return _fail("Burst presentation crossed its sampling or authority contract")
	return true


static func _int_array_equals(raw_values: Variant, expected: Array) -> bool:
	if not raw_values is Array or (raw_values as Array).size() != expected.size():
		return false
	for index: int in range(expected.size()):
		if int((raw_values as Array)[index]) != int(expected[index]):
			return false
	return true


func _validate_assets(load_textures: bool) -> bool:
	var assets: Variant = data.get("assets", [])
	var budgets: Dictionary = data.get("budgets", {})
	if not assets is Array or (assets as Array).size() != REQUIRED_ELEMENTS.size() \
		or int(budgets.get("asset_count", 0)) != REQUIRED_ELEMENTS.size():
		return _fail("Burst presentation requires exactly nine elemental sheets")
	var disk_bytes := 0
	var decoded_bytes := 0
	for value: Variant in assets:
		if not value is Dictionary:
			return _fail("Burst asset entry must be an object")
		var asset: Dictionary = value
		var element := String(asset.get("element", ""))
		var path := String(asset.get("path", ""))
		var expected_path := "res://assets/effects/projectiles/burst_v3/burst_%s_runtime_32.png" % element
		var expected_hash := String(asset.get("sha256", ""))
		if element not in REQUIRED_ELEMENTS or entries_by_element.has(element) or not language.elements.has(element if element != "neutral" else "water"):
			return _fail("Burst asset element is invalid: %s" % element)
		if path != expected_path or expected_hash.length() != 64 or not ResourceLoader.exists(path, "Texture2D"):
			return _fail("Burst asset path or hash is invalid: %s" % element)
		if element != "neutral" and (not catalog.elements_by_id.has(element) or not bool((catalog.elements_by_id[element] as Dictionary).get("runtime_enabled", false))):
			return _fail("Burst asset does not match an active element: %s" % element)
		if OS.has_feature("editor"):
			if FileAccess.get_sha256(path) != expected_hash:
				return _fail("Burst asset hash changed: %s" % element)
			var image := Image.new()
			if image.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) != OK \
				or image.get_width() != COLUMN_COUNT * CELL_SIZE or image.get_height() != ROW_COUNT * CELL_SIZE \
				or image.get_format() != Image.FORMAT_RGBA8:
				return _fail("Burst asset PNG contract changed: %s" % element)
			if not _validate_sheet_pixels(image):
				return _fail("Burst asset symmetry or phase content changed: %s" % element)
			disk_bytes += FileAccess.get_file_as_bytes(path).size()
		decoded_bytes += COLUMN_COUNT * CELL_SIZE * ROW_COUNT * CELL_SIZE * 4
		entries_by_element[element] = asset
		if load_textures:
			var loaded := ResourceLoader.load(path, "Texture2D")
			if not loaded is Texture2D or loaded.get_width() != COLUMN_COUNT * CELL_SIZE or loaded.get_height() != ROW_COUNT * CELL_SIZE:
				return _fail("Burst texture import failed: %s" % element)
			textures_by_element[element] = loaded
	for element: String in REQUIRED_ELEMENTS:
		if not entries_by_element.has(element):
			return _fail("Burst asset is missing: %s" % element)
	if OS.has_feature("editor") and (disk_bytes != int(budgets.get("png_disk_bytes", -1)) or disk_bytes > int(budgets.get("maximum_png_disk_bytes", 0))):
		return _fail("Burst PNG disk budget changed")
	if decoded_bytes != int(budgets.get("decoded_rgba_bytes", -1)) or decoded_bytes > int(budgets.get("maximum_decoded_rgba_bytes", 0)):
		return _fail("Burst decoded-memory budget changed")
	return true


static func _validate_sheet_pixels(image: Image) -> bool:
	for column: int in range(COLUMN_COUNT):
		var north := image.get_region(Rect2i(column * CELL_SIZE, 0, CELL_SIZE, CELL_SIZE))
		var north_east := image.get_region(Rect2i(column * CELL_SIZE, CELL_SIZE, CELL_SIZE, CELL_SIZE))
		var east := image.get_region(Rect2i(column * CELL_SIZE, CELL_SIZE * 2, CELL_SIZE, CELL_SIZE))
		var south_east := image.get_region(Rect2i(column * CELL_SIZE, CELL_SIZE * 3, CELL_SIZE, CELL_SIZE))
		if not _equals_flipped(north, image.get_region(Rect2i(column * CELL_SIZE, CELL_SIZE * 4, CELL_SIZE, CELL_SIZE)), false) \
			or not _equals_flipped(south_east, image.get_region(Rect2i(column * CELL_SIZE, CELL_SIZE * 5, CELL_SIZE, CELL_SIZE)), true) \
			or not _equals_flipped(east, image.get_region(Rect2i(column * CELL_SIZE, CELL_SIZE * 6, CELL_SIZE, CELL_SIZE)), true) \
			or not _equals_flipped(north_east, image.get_region(Rect2i(column * CELL_SIZE, CELL_SIZE * 7, CELL_SIZE, CELL_SIZE)), true):
			return false
	var travel := image.get_region(Rect2i(2 * CELL_SIZE, 0, 6 * CELL_SIZE, ROW_COUNT * CELL_SIZE))
	var reserved := image.get_region(Rect2i(15 * CELL_SIZE, 0, CELL_SIZE, ROW_COUNT * CELL_SIZE))
	return not travel.is_invisible() and reserved.is_invisible()


static func _equals_flipped(source: Image, target: Image, horizontal: bool) -> bool:
	var expected := source.duplicate()
	if horizontal:
		expected.flip_x()
	else:
		expected.flip_y()
	return expected.get_data() == target.get_data()


static func canonical_text_sha256(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var source := FileAccess.get_file_as_string(path).replace("\r\n", "\n").replace("\r", "\n")
	return source.sha256_text()


func _fail(message: String) -> bool:
	last_error = message
	return false
