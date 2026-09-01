class_name VisualProductionContract
extends RefCounted


const PRODUCTION_PATH: String = "res://content/visual/visual_iteration_manifest_v3.json"
const RUNTIME_PATH: String = "res://content/visual/wellspring_visual_catalog_v2.json"
const FRONT_REFERENCE_PATH: String = "res://content/visual/reference_style_front_catalog_v3.json"
const EXPECTED_AUTHORITY: String = "visual-production manifest; gameplay simulation remains authoritative elsewhere"
const EXPECTED_CELL: Vector2i = Vector2i(96, 96)
const EXPECTED_PIVOT: Vector2i = Vector2i(48, 84)
const EXPECTED_RUNTIME_CELL: Vector2i = Vector2i(64, 64)
const EXPECTED_RUNTIME_PIVOT: Vector2i = Vector2i(32, 56)
const EXPECTED_DIRECTIONS: Array[String] = [
	"south", "south_east", "east", "north_east",
	"north", "north_west", "west", "south_west",
]
const EXPECTED_AUTHORED_DIRECTIONS: Array[String] = [
	"south", "south_east", "east", "north_east", "north",
]
const EXPECTED_MIRRORS := {
	"south_west": "south_east",
	"west": "east",
	"north_west": "north_east",
}
const ALLOWED_ANIMATION_STATUSES: Array[String] = ["planned", "candidate", "reviewed"]
const ALLOWED_PLANNED_FRONT_STATUSES: Array[String] = [
	"planned_reference_exact_or_corrected",
	"planned_reference_style_derived",
	"planned_reference_style_derived_unapproved",
]

var data: Dictionary = {}
var runtime_data: Dictionary = {}
var front_reference_data: Dictionary = {}
var derived_directions: Array[String] = []
var animations: Dictionary = {}
var last_error: String = ""


func load_from_files(
	production_path: String = PRODUCTION_PATH,
	runtime_path: String = RUNTIME_PATH,
	front_reference_path: String = FRONT_REFERENCE_PATH,
) -> bool:
	last_error = ""
	data.clear()
	runtime_data.clear()
	front_reference_data.clear()
	derived_directions.clear()
	animations.clear()
	data = _load_json(production_path, "v3 visual production manifest")
	if data.is_empty():
		return false
	runtime_data = _load_json(runtime_path, "v2 runtime visual catalog")
	if runtime_data.is_empty():
		return false
	front_reference_data = _load_json(front_reference_path, "v3 front-reference catalog")
	if front_reference_data.is_empty():
		return false
	return validate()


func validate() -> bool:
	last_error = ""
	derived_directions.clear()
	animations.clear()
	if int(data.get("schema_version", 0)) != 3:
		return _fail("Visual production manifest schema must be 3")
	if String(data.get("authority", "")) != EXPECTED_AUTHORITY:
		return _fail("Visual production authority must remain presentation-only and simulation-external")
	if bool(data.get("runtime_approved", false)):
		return _fail("Visual production planning cannot grant runtime approval")

	var baseline: Dictionary = data.get("reference_baseline", {})
	var baseline_path := String(baseline.get("path", ""))
	if baseline_path.is_empty() or not FileAccess.file_exists(_resource_path(baseline_path)):
		return _fail("Visual production reference baseline is missing")
	if bool(baseline.get("content_authority", true)):
		return _fail("Visual reference pixels and labels cannot own content authority")

	var render: Dictionary = data.get("render_contract", {})
	if _vector2i(render.get("virtual_viewport", [])) != Vector2i(640, 360):
		return _fail("Visual production viewport must remain 640 x 360")
	if _vector2i(render.get("runtime_cell", [])) != EXPECTED_CELL:
		return _fail("Visual production cell must remain 96 x 96")
	if _vector2i(render.get("pivot", [])) != EXPECTED_PIVOT:
		return _fail("Visual production pivot must remain (48, 84)")
	if not bool(render.get("nearest_neighbor", false)):
		return _fail("Visual production requires nearest-neighbor sampling")
	if render.get("unique_generated_directions", []) != EXPECTED_AUTHORED_DIRECTIONS:
		return _fail("Visual production must author the canonical five ordered directions")
	var mirrors: Dictionary = render.get("mirrored_directions", {})
	if mirrors.size() != EXPECTED_MIRRORS.size():
		return _fail("Visual production requires exactly three mirrored directions")
	for direction: String in EXPECTED_MIRRORS:
		if String(mirrors.get(direction, "")) != String(EXPECTED_MIRRORS[direction]):
			return _fail("Visual production mirror is invalid: %s" % direction)

	var runtime_contract: Dictionary = runtime_data.get("character_contract", {})
	if _vector2i(runtime_contract.get("cell_size", [])) != EXPECTED_RUNTIME_CELL:
		return _fail("Runtime visual cell changed outside the v3 migration boundary")
	if _vector2i(runtime_contract.get("pivot", [])) != EXPECTED_RUNTIME_PIVOT:
		return _fail("Runtime visual pivot changed outside the v3 migration boundary")
	if EXPECTED_PIVOT.x * EXPECTED_RUNTIME_CELL.x != EXPECTED_RUNTIME_PIVOT.x * EXPECTED_CELL.x \
		or EXPECTED_PIVOT.y * EXPECTED_RUNTIME_CELL.y != EXPECTED_RUNTIME_PIVOT.y * EXPECTED_CELL.y:
		return _fail("V3 pivot does not preserve the normalized v2 foot anchor")
	var runtime_directions: Array = runtime_contract.get("directions", [])
	if runtime_directions != EXPECTED_DIRECTIONS:
		return _fail("Runtime visual direction order is incompatible with v3 production")
	for direction_value: Variant in runtime_directions:
		var direction := String(direction_value)
		if EXPECTED_AUTHORED_DIRECTIONS.has(direction):
			derived_directions.append(direction)
		elif mirrors.has(direction) and EXPECTED_AUTHORED_DIRECTIONS.has(String(mirrors[direction])):
			derived_directions.append(direction)
		else:
			return _fail("Runtime direction cannot be derived from v3 production: %s" % direction)
	if derived_directions != EXPECTED_DIRECTIONS:
		return _fail("V3 authored and mirrored directions do not derive the runtime order")

	var production_animations: Dictionary = data.get("animations", {})
	var runtime_animations: Array = runtime_contract.get("animations", [])
	if production_animations.size() != 25 or runtime_animations.size() != 25:
		return _fail("Visual production and runtime must expose exactly 25 animations")
	var production_ids: Array = production_animations.keys()
	for index: int in runtime_animations.size():
		var runtime_animation: Dictionary = runtime_animations[index]
		var animation_id := String(runtime_animation.get("id", ""))
		if animation_id.is_empty() or not production_animations.has(animation_id):
			return _fail("V3 production is missing runtime animation: %s" % animation_id)
		if String(production_ids[index]) != animation_id:
			return _fail("V3 animation order differs from the runtime semantic order")
		var production_animation: Dictionary = production_animations[animation_id]
		if not _exact_integer_match(production_animation.get("frames"), runtime_animation.get("frames")):
			return _fail("V3 animation frame count differs from runtime: %s" % animation_id)
		if not _exact_integer_match(production_animation.get("fps"), runtime_animation.get("fps")):
			return _fail("V3 animation FPS differs from runtime: %s" % animation_id)
		if typeof(production_animation.get("loop")) != TYPE_BOOL \
			or typeof(runtime_animation.get("loop")) != TYPE_BOOL \
			or bool(production_animation.get("loop")) != bool(runtime_animation.get("loop", false)):
			return _fail("V3 animation loop contract differs from runtime: %s" % animation_id)
		if String(production_animation.get("status", "")) not in ALLOWED_ANIMATION_STATUSES:
			return _fail("V3 animation status is invalid: %s" % animation_id)
		animations[animation_id] = production_animation

	var quality: Dictionary = data.get("quality_gate", {})
	if not bool(quality.get("reference_is_minimum", false)):
		return _fail("Visual quality gate must treat the supplied reference as the minimum")
	if float(quality.get("minimum_structural_score", 0.0)) < 0.82:
		return _fail("Visual structural quality threshold cannot be weakened")
	if int(quality.get("minimum_visual_rubric_each", 0)) < 4 \
		or float(quality.get("minimum_visual_rubric_mean", 0.0)) < 4.5:
		return _fail("Visual review rubric cannot be weakened")
	if not bool(quality.get("requires_contact_sheet", false)) \
		or not bool(quality.get("requires_native_and_4x_review", false)):
		return _fail("Visual production requires contact-sheet and gameplay-scale review")
	if bool(quality.get("auto_finalization", true)):
		return _fail("Visual production cannot auto-finalize candidates")

	if String(front_reference_data.get("schema", "")) != "flux2.reference_style_front_sprites.v3":
		return _fail("V3 front-reference catalog schema is invalid")
	if String(front_reference_data.get("source_reference", "")) != baseline_path:
		return _fail("V3 front-reference catalog uses a different baseline")
	if _vector2i(front_reference_data.get("runtime_cell_recommendation", [])) != EXPECTED_CELL:
		return _fail("V3 front-reference cell recommendation differs from production")
	if _vector2i(front_reference_data.get("pivot", [])) != EXPECTED_PIVOT:
		return _fail("V3 front-reference pivot differs from production")
	var front_champions: Dictionary = front_reference_data.get("champions", {})
	var production_characters: Array = data.get("characters", [])
	if front_champions.size() != 24 or production_characters.size() != 24:
		return _fail("V3 front-reference catalog must account for all 24 production characters")
	for character_value: Variant in production_characters:
		var character: Dictionary = character_value
		var champion_id := String(character.get("id", ""))
		if champion_id.is_empty() or not front_champions.has(champion_id):
			return _fail("V3 front-reference catalog is missing character: %s" % champion_id)
		var entry: Dictionary = front_champions[champion_id]
		var expected_path := "res://assets/sprites/champions_v3/%s/front_sprite_256.png" % champion_id
		match String(entry.get("availability", "")):
			"planned_missing":
				if String(entry.get("status", "")) not in ALLOWED_PLANNED_FRONT_STATUSES:
					return _fail("Planned v3 front reference has invalid status: %s" % champion_id)
				if String(entry.get("planned_front_sprite", "")) != expected_path:
					return _fail("Planned v3 front reference path is invalid: %s" % champion_id)
				if entry.has("front_sprite"):
					return _fail("Missing v3 front reference cannot claim a front_sprite: %s" % champion_id)
				if FileAccess.file_exists(expected_path):
					return _fail("V3 front reference availability is stale; file is present: %s" % champion_id)
			"candidate_present":
				if String(entry.get("status", "")) != "candidate_needs_visual_review":
					return _fail("Present v3 front reference must remain a review candidate: %s" % champion_id)
				if entry.has("planned_front_sprite") or String(entry.get("front_sprite", "")) != expected_path:
					return _fail("Present v3 front reference path is invalid: %s" % champion_id)
				if not _validate_present_front_reference(entry, expected_path, champion_id):
					return false
			_:
				return _fail("V3 front reference availability is invalid: %s" % champion_id)
	return true


func _load_json(path: String, label: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		_fail("%s does not exist: %s" % [label, path])
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_fail("%s cannot be opened: %s" % [label, path])
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		_fail("%s root must be an object" % label)
		return {}
	return parsed


func _resource_path(path: String) -> String:
	return path if path.begins_with("res://") else "res://%s" % path


func _validate_present_front_reference(entry: Dictionary, path: String, label: String) -> bool:
	if not FileAccess.file_exists(path):
		return _fail("Present v3 front reference is missing: %s" % label)
	var expected_hash := String(entry.get("sha256", ""))
	if expected_hash.length() != 64 or expected_hash != _sha256(path):
		return _fail("Present v3 front reference hash is invalid: %s" % label)
	var image := ImageAssetInspector.load_image(path)
	if image == null or image.is_empty():
		return _fail("Present v3 front reference cannot be decoded: %s" % label)
	if image.get_size() != Vector2i(256, 256) or image.get_format() != Image.FORMAT_RGBA8:
		return _fail("Present v3 front reference must be a 256 x 256 RGBA PNG: %s" % label)
	var visible_pixels: int = 0
	var transparent_pixels: int = 0
	for y: int in image.get_height():
		for x: int in image.get_width():
			if image.get_pixel(x, y).a <= 1.0 / 255.0:
				transparent_pixels += 1
			else:
				visible_pixels += 1
	if visible_pixels == 0 or transparent_pixels == 0:
		return _fail("Present v3 front reference requires visible art and transparent background: %s" % label)
	return true


func _sha256(path: String) -> String:
	var context := HashingContext.new()
	if context.start(HashingContext.HASH_SHA256) != OK:
		return ""
	if context.update(FileAccess.get_file_as_bytes(path)) != OK:
		return ""
	return context.finish().hex_encode()


func _vector2i(value: Variant) -> Vector2i:
	if not value is Array or (value as Array).size() != 2:
		return Vector2i(-1, -1)
	return Vector2i(int((value as Array)[0]), int((value as Array)[1]))


func _exact_integer_match(first: Variant, second: Variant) -> bool:
	if typeof(first) not in [TYPE_INT, TYPE_FLOAT] or typeof(second) not in [TYPE_INT, TYPE_FLOAT]:
		return false
	var first_value := float(first)
	var second_value := float(second)
	return first_value > 0.0 \
		and second_value > 0.0 \
		and first_value == floor(first_value) \
		and second_value == floor(second_value) \
		and int(first_value) == int(second_value)


func _fail(message: String) -> bool:
	derived_directions.clear()
	animations.clear()
	last_error = message
	return false
