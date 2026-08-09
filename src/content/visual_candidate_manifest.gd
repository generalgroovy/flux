class_name VisualCandidateManifest
extends RefCounted


const SUPPORTED_SCHEMA_VERSION: int = 1
const CANDIDATE_PREFIX: String = "res://assets/concept/champion_keypose_candidates/"
const QUARANTINE_MARKER: String = CANDIDATE_PREFIX + ".gdignore"
const REQUIRED_REFERENCE_ROLES: Array[String] = [
	"minimum visual quality and character identity reference",
	"action ordering and layout reference only",
]
const REQUIRED_POSES: Array[String] = [
	"idle",
	"walk",
	"sprint",
	"hop",
	"double_jump",
	"rise",
	"fall",
	"land",
	"wall_contact",
	"wall_kick",
	"air_dodge",
	"wavedash",
	"slide",
	"slide_jump",
	"vault",
	"superglide",
	"attack_primary",
	"cast",
	"defend",
	"hit",
	"stunned",
	"rooted",
	"defeated",
	"interact",
	"taunt",
]

var data: Dictionary = {}
var last_error: String = ""


func load_from_file(path: String) -> bool:
	last_error = ""
	data = {}
	var filesystem_path := _filesystem_path(path)
	if not FileAccess.file_exists(filesystem_path):
		return _fail("Visual candidate manifest does not exist: %s" % path)
	var file := FileAccess.open(filesystem_path, FileAccess.READ)
	if file == null:
		return _fail("Visual candidate manifest cannot be opened: %s" % path)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return _fail("Visual candidate manifest root must be an object")
	data = parsed
	return validate()


func validate() -> bool:
	last_error = ""
	if int(data.get("schema_version", 0)) != SUPPORTED_SCHEMA_VERSION:
		return _fail("Unsupported visual candidate manifest schema")
	var candidate_id := String(data.get("id", ""))
	var champion_id := String(data.get("champion_id", ""))
	if candidate_id.is_empty() or champion_id.is_empty():
		return _fail("Visual candidate id and champion id are required")
	if String(data.get("status", "")) != "quarantined_visual_candidate":
		return _fail("Generated visual must remain a quarantined candidate")
	if bool(data.get("runtime_approved", true)):
		return _fail("Quarantined visual candidate cannot be runtime approved")
	if String(data.get("authority", "")) != "presentation_only":
		return _fail("Visual candidate cannot own gameplay authority")
	if String(data.get("license_status", "")) != "not_assessed_for_runtime_distribution":
		return _fail("Candidate license status must remain explicit until review")
	if String(data.get("created_at", "")).is_empty():
		return _fail("Visual candidate creation time is required")
	var generator: Dictionary = data.get("generator", {})
	for field: String in ["provider", "model_version"]:
		if String(generator.get(field, "")).is_empty():
			return _fail("Visual candidate generator provenance is missing: %s" % field)
	if not FileAccess.file_exists(_filesystem_path(QUARANTINE_MARKER)):
		return _fail("Visual candidate quarantine marker is missing")

	var artifact_value: Variant = data.get("artifact", {})
	if not artifact_value is Dictionary:
		return _fail("Visual candidate artifact must be an object")
	var artifact: Dictionary = artifact_value
	var artifact_path := String(artifact.get("path", ""))
	var expected_path := "%s%s/%s.png" % [CANDIDATE_PREFIX, champion_id, candidate_id]
	if artifact_path != expected_path or ".." in artifact_path:
		return _fail("Visual candidate artifact path is outside its quarantine slot")
	if FileAccess.file_exists(_filesystem_path(artifact_path + ".import")):
		return _fail("Visual candidate unexpectedly has a Godot import sidecar")
	if not _validate_hash(artifact_path, String(artifact.get("sha256", "")), "artifact"):
		return false
	var image := _load_png(artifact_path, "artifact")
	if image == null:
		return false
	var width := int(artifact.get("width", 0))
	var height := int(artifact.get("height", 0))
	if width != image.get_width() or height != image.get_height() or width < 64 or height < 64:
		return _fail("Visual candidate dimensions do not match the PNG")

	var grid: Dictionary = data.get("grid", {})
	var columns := int(grid.get("columns", 0))
	var rows := int(grid.get("rows", 0))
	if columns != 5 or rows != 5:
		return _fail("Visual candidate must declare the canonical five-by-five pose grid")
	var has_exact_cells := width % columns == 0 and height % rows == 0
	if bool(grid.get("exact_cells", not has_exact_cells)) != has_exact_cells:
		return _fail("Visual candidate exact-cell claim does not match its dimensions")

	var poses: Array = data.get("intended_pose_order", [])
	if poses.size() != REQUIRED_POSES.size() or poses.size() != columns * rows:
		return _fail("Visual candidate must declare exactly 25 ordered poses")
	for index: int in REQUIRED_POSES.size():
		if String(poses[index]) != REQUIRED_POSES[index]:
			return _fail("Visual candidate pose order changed at index %d" % index)

	var references: Array = data.get("references", [])
	if references.size() < 2:
		return _fail("Visual candidate requires quality and layout references")
	var reference_paths: Dictionary[String, bool] = {}
	var reference_roles: Dictionary[String, bool] = {}
	for value: Variant in references:
		if not value is Dictionary:
			return _fail("Every visual candidate reference must be an object")
		var reference: Dictionary = value
		var role := String(reference.get("role", ""))
		var reference_path := String(reference.get("path", ""))
		if role.is_empty() or reference_roles.has(role):
			return _fail("Visual candidate reference roles must be non-empty and unique")
		if not reference_path.begins_with("res://assets/") or ".." in reference_path or reference_paths.has(reference_path):
			return _fail("Visual candidate reference paths must be safe and unique")
		if not _validate_hash(reference_path, String(reference.get("sha256", "")), "reference"):
			return false
		reference_paths[reference_path] = true
		reference_roles[role] = true
	for role: String in REQUIRED_REFERENCE_ROLES:
		if not reference_roles.has(role):
			return _fail("Visual candidate required reference role is missing: %s" % role)

	var strengths: Array = data.get("observed_strengths", [])
	var blockers: Array = data.get("promotion_blockers", [])
	if not _has_nonempty_strings(strengths):
		return _fail("Visual candidate requires recorded review strengths")
	if not _has_nonempty_strings(blockers):
		return _fail("Visual candidate cannot omit its promotion blockers")
	return true


func _validate_hash(path: String, expected_hash: String, label: String) -> bool:
	var filesystem_path := _filesystem_path(path)
	if not FileAccess.file_exists(filesystem_path):
		return _fail("Visual candidate %s does not exist: %s" % [label, path])
	if expected_hash.length() != 64 or FileAccess.get_sha256(filesystem_path) != expected_hash:
		return _fail("Visual candidate %s hash does not match provenance" % label)
	return true


func _load_png(path: String, label: String) -> Image:
	var image := Image.new()
	var filesystem_path := _filesystem_path(path)
	if image.load_png_from_buffer(FileAccess.get_file_as_bytes(filesystem_path)) != OK:
		_fail("Visual candidate %s is not a valid PNG" % label)
		return null
	return image


func _filesystem_path(path: String) -> String:
	if path.begins_with("res://"):
		return ProjectSettings.globalize_path(path)
	return path


func _has_nonempty_strings(values: Array) -> bool:
	if values.is_empty():
		return false
	for value: Variant in values:
		if String(value).strip_edges().is_empty():
			return false
	return true


func _fail(message: String) -> bool:
	last_error = message
	return false
