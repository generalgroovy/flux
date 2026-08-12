class_name AbilityCatalog
extends RefCounted


const SUPPORTED_SCHEMA_VERSION: int = 1
const SLOT_KINDS: Array[String] = ["passive", "primary", "active", "mobility", "ultimate"]

var data: Dictionary = {}
var last_error: String = ""
var content_hash: String = ""
var elements_by_id: Dictionary = {}
var abilities_by_id: Dictionary = {}
var ability_ids_by_wire: Dictionary = {}


func load_from_file(path: String) -> bool:
	last_error = ""
	if not FileAccess.file_exists(path):
		return _fail("ability catalog does not exist: %s" % path)
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _fail("ability catalog cannot be opened: %s" % path)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return _fail("ability catalog root must be an object")
	data = parsed
	return validate()


func validate() -> bool:
	last_error = ""
	content_hash = ""
	elements_by_id = {}
	abilities_by_id = {}
	ability_ids_by_wire = {}
	if int(data.get("schema_version", 0)) != SUPPORTED_SCHEMA_VERSION:
		return _fail("unsupported ability catalog schema")
	if String(data.get("id", "")).is_empty():
		return _fail("ability catalog id is required")
	if String(data.get("affinity_rule", "")) != "aligned_active_cost_discount_only":
		return _fail("affinities may only discount aligned active build cost")

	var element_wires: Dictionary = {}
	for value: Variant in data.get("elements", []):
		if not value is Dictionary:
			return _fail("every element must be an object")
		var element: Dictionary = value
		var element_id := String(element.get("id", ""))
		var wire_id := int(element.get("wire_id", 0))
		if element_id.is_empty() or elements_by_id.has(element_id):
			return _fail("element ids must be non-empty and unique: %s" % element_id)
		if wire_id <= 0 or element_wires.has(wire_id):
			return _fail("element wire ids must be positive and unique: %d" % wire_id)
		elements_by_id[element_id] = element
		element_wires[wire_id] = element_id
	if elements_by_id.size() != 12:
		return _fail("the thematic catalog must declare exactly twelve element families")

	for value: Variant in data.get("abilities", []):
		if not value is Dictionary:
			return _fail("every ability must be an object")
		var ability: Dictionary = value
		var ability_id := String(ability.get("id", ""))
		var wire_id := int(ability.get("wire_id", 0))
		var slot_kind := String(ability.get("slot_kind", ""))
		var element_id := String(ability.get("element", ""))
		if ability_id.is_empty() or abilities_by_id.has(ability_id):
			return _fail("ability ids must be non-empty and unique: %s" % ability_id)
		if wire_id <= 0 or ability_ids_by_wire.has(wire_id):
			return _fail("ability wire ids must be positive and unique: %d" % wire_id)
		if not SLOT_KINDS.has(slot_kind):
			return _fail("ability has unknown slot kind: %s" % ability_id)
		if not element_id.is_empty() and not elements_by_id.has(element_id):
			return _fail("ability has unknown element: %s" % ability_id)
		if not element_id.is_empty() and not bool((elements_by_id[element_id] as Dictionary).get("runtime_enabled", false)):
			return _fail("ability uses a gated element family: %s" % ability_id)
		if String(ability.get("authority", "")) != "simulation":
			return _fail("ability must be simulation-authoritative: %s" % ability_id)
		if (ability.get("roles", []) as Array).is_empty():
			return _fail("ability needs at least one role: %s" % ability_id)
		if (ability.get("counterplay", []) as Array).is_empty():
			return _fail("ability needs explicit counterplay: %s" % ability_id)
		var points := int(ability.get("points", -1))
		var flux_cost := int(ability.get("flux_cost", -1))
		var cooldown_ms := int(ability.get("cooldown_ms", -1))
		var startup_ms := int(ability.get("startup_ms", -1))
		var recovery_ms := int(ability.get("recovery_ms", -1))
		if points < 0 or flux_cost < 0 or cooldown_ms < 0 or startup_ms < 0 or recovery_ms < 0:
			return _fail("ability timing and costs must be non-negative: %s" % ability_id)
		if slot_kind == "active" and (points <= 0 or flux_cost <= 0 or cooldown_ms <= 0 or startup_ms <= 0 or recovery_ms <= 0):
			return _fail("catalog actives require positive points, Flux, cooldown, startup, and recovery: %s" % ability_id)
		if slot_kind == "primary" and flux_cost != 0:
			return _fail("reliable primary must not spend Flux: %s" % ability_id)
		abilities_by_id[ability_id] = ability
		ability_ids_by_wire[wire_id] = ability_id
	if abilities_by_id.is_empty():
		return _fail("ability catalog must not be empty")
	content_hash = CanonicalContent.sha256(data)
	if content_hash.length() != 64:
		return _fail("ability catalog hash failed")
	return true


func ability(ability_id: String) -> Dictionary:
	return abilities_by_id.get(ability_id, {})


func active_element_ids() -> Array[String]:
	var result: Array[String] = []
	for element_id: String in elements_by_id:
		if bool((elements_by_id[element_id] as Dictionary).get("runtime_enabled", false)):
			result.append(element_id)
	result.sort()
	return result


func _fail(message: String) -> bool:
	last_error = message
	return false
