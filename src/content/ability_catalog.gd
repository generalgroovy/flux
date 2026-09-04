class_name AbilityCatalog
extends RefCounted


const SUPPORTED_SCHEMA_VERSION: int = 3
const SLOT_KINDS: Array[String] = ["passive", "primary", "active", "mobility", "ultimate"]
const SHAPES: Array[String] = ["passive", "projectile", "beam", "spray", "field", "defense", "movement", "ultimate"]
const DELIVERIES: Array[String] = ["self", "aimed", "placed"]
const IMPACTS: Array[String] = ["empower", "damage", "damage_interrupt", "barrier", "terrain_cover", "reposition", "area_control", "damage_launch", "damage_ricochet", "damage_slow", "control_slow"]
const RESIDUES: Array[String] = ["none", "trail", "field", "construct"]
const MATERIAL_OPERATIONS: Array[String] = ["none", "heat", "cool", "wet", "charge", "discharge", "fracture", "push", "reveal", "decay"]
const RUNTIME_STATUSES: Array[String] = ["playable", "catalog_only"]
const CADENCE_TIER_IDS: Array[String] = ["pressure", "tempo", "control"]
const MAX_PROJECTILE_PATTERN_LANES: int = 9
const FIRST_EIGHT_ELEMENTS: Array[String] = ["earth", "fire", "water", "wind", "ice", "charge", "light", "dark"]
const BURST_ANGLES: Array[int] = [-24, -12, 0, 12, 24]

var data: Dictionary = {}
var last_error: String = ""
var content_hash: String = ""
var elements_by_id: Dictionary = {}
var abilities_by_id: Dictionary = {}
var ability_ids_by_wire: Dictionary = {}
var economy: Dictionary = {}
var runtime_wire_ids: Array[int] = []


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
	economy = {}
	runtime_wire_ids = []
	if int(data.get("schema_version", 0)) != SUPPORTED_SCHEMA_VERSION:
		return _fail("unsupported ability catalog schema")
	if String(data.get("id", "")).is_empty():
		return _fail("ability catalog id is required")
	if String(data.get("affinity_rule", "")) != "aligned_active_cost_discount_capped_by_affinity_strength":
		return _fail("affinities may only discount aligned active build cost within authored affinity strength")
	var economy_value: Variant = data.get("economy", {})
	if not economy_value is Dictionary:
		return _fail("ability economy must be an object")
	economy = economy_value
	if String(economy.get("resource", "")) != "flux":
		return _fail("runtime spell economy must use Flux")
	if int(economy.get("recovery_delay_ms", 0)) != PlayerTuning.FLUX_RECOVERY_DELAY_MS:
		return _fail("ability economy recovery delay must match compiled Flux recovery")
	var minimum_runtime_spell_cost := int(economy.get("minimum_runtime_spell_cost", 0))
	if minimum_runtime_spell_cost <= 0:
		return _fail("runtime spell economy requires a positive minimum Flux cost")
	var cadence_tiers_value: Variant = economy.get("cadence_tiers_ms", {})
	if not cadence_tiers_value is Dictionary:
		return _fail("ability economy cadence tiers must be an object")
	var cadence_tiers: Dictionary = cadence_tiers_value
	if cadence_tiers.size() != CADENCE_TIER_IDS.size():
		return _fail("ability economy requires the exact cadence tiers")
	for cadence_tier_id: String in CADENCE_TIER_IDS:
		var tier_value: Variant = cadence_tiers.get(cadence_tier_id, {})
		if not tier_value is Dictionary:
			return _fail("ability economy cadence tier is missing: %s" % cadence_tier_id)
		var tier: Dictionary = tier_value
		var minimum_ms := int(tier.get("minimum", 0))
		var maximum_ms := int(tier.get("maximum", 0))
		if minimum_ms <= 0 or maximum_ms < minimum_ms or maximum_ms > 5_000:
			return _fail("ability economy cadence tier is invalid: %s" % cadence_tier_id)

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
		if not ability.get("element", "") is String:
			return _fail("ability must declare one element string: %s" % ability_id)
		for hybrid_key: String in ["elements", "secondary_element", "dual_element", "element_combination", "hybrid_elements"]:
			if ability.has(hybrid_key):
				return _fail("mixed-element attacks are gated until chemistry acceptance: %s" % ability_id)
		var wire_id := int(ability.get("wire_id", 0))
		var slot_kind := String(ability.get("slot_kind", ""))
		var element_id := String(ability.get("element", ""))
		var shape := String(ability.get("shape", ""))
		var delivery := String(ability.get("delivery", ""))
		var impact := String(ability.get("impact", ""))
		var residue := String(ability.get("residue", ""))
		var material_operation := String(ability.get("material_operation", ""))
		var runtime_status := String(ability.get("runtime_status", ""))
		if ability_id.is_empty() or abilities_by_id.has(ability_id):
			return _fail("ability ids must be non-empty and unique: %s" % ability_id)
		if wire_id <= 0 or ability_ids_by_wire.has(wire_id):
			return _fail("ability wire ids must be positive and unique: %d" % wire_id)
		if not SLOT_KINDS.has(slot_kind):
			return _fail("ability has unknown slot kind: %s" % ability_id)
		if not SHAPES.has(shape) or not DELIVERIES.has(delivery) or not IMPACTS.has(impact) or not RESIDUES.has(residue):
			return _fail("ability has invalid shape contract: %s" % ability_id)
		if not MATERIAL_OPERATIONS.has(material_operation):
			return _fail("ability has invalid material operation: %s" % ability_id)
		if not ability.get("material_runtime_enabled", false) is bool:
			return _fail("ability material runtime gate must be boolean: %s" % ability_id)
		if bool(ability.get("material_runtime_enabled", false)) and material_operation == "none":
			return _fail("enabled material operation cannot be none: %s" % ability_id)
		if not RUNTIME_STATUSES.has(runtime_status):
			return _fail("ability has invalid runtime status: %s" % ability_id)
		if slot_kind == "passive" and shape != "passive":
			return _fail("passive ability requires passive shape: %s" % ability_id)
		if slot_kind == "ultimate" and shape != "ultimate":
			return _fail("ultimate ability requires ultimate shape: %s" % ability_id)
		if slot_kind == "mobility" and shape != "movement":
			return _fail("mobility ability requires movement shape: %s" % ability_id)
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
		if runtime_status == "playable":
			if element_id.is_empty():
				return _fail("every playable spell requires exactly one element: %s" % ability_id)
			var cadence_tier_id := String(ability.get("cadence_tier", ""))
			if not CADENCE_TIER_IDS.has(cadence_tier_id):
				return _fail("runtime spell requires a cadence tier: %s" % ability_id)
			var cadence_tier: Dictionary = cadence_tiers[cadence_tier_id]
			if flux_cost < minimum_runtime_spell_cost:
				return _fail("runtime spell requires positive Flux cost: %s" % ability_id)
			if cooldown_ms < int(cadence_tier["minimum"]) or cooldown_ms > int(cadence_tier["maximum"]):
				return _fail("runtime spell cooldown is outside its cadence tier: %s" % ability_id)
			if startup_ms <= 0 or recovery_ms <= 0:
				return _fail("runtime spell requires positive startup and recovery: %s" % ability_id)
			if not _validate_playable_simulation(ability):
				return false
		if shape == "projectile" and not _valid_projectile_angles(ability.get("projectile_angles_degrees", [0])):
			return _fail("projectile angles must be ordered, odd, centered and symmetric: %s" % ability_id)
		if shape != "projectile" and ability.has("projectile_angles_degrees"):
			return _fail("only projectile spells may declare projectile angles: %s" % ability_id)
		abilities_by_id[ability_id] = ability
		ability_ids_by_wire[wire_id] = ability_id
	if abilities_by_id.is_empty():
		return _fail("ability catalog must not be empty")
	if not _validate_runtime_wire_order():
		return false
	if not _validate_first_eight_bursts():
		return false
	content_hash = CanonicalContent.sha256(data)
	if content_hash.length() != 64:
		return _fail("ability catalog hash failed")
	return true


static func _valid_projectile_angles(value: Variant) -> bool:
	if not value is Array:
		return false
	var angles: Array = value
	if angles.is_empty() or angles.size() > MAX_PROJECTILE_PATTERN_LANES or angles.size() % 2 == 0:
		return false
	var previous := -181
	for index: int in range(angles.size()):
		if typeof(angles[index]) not in [TYPE_INT, TYPE_FLOAT]:
			return false
		var angle := int(angles[index])
		if float(angles[index]) != float(angle):
			return false
		if angle < -60 or angle > 60 or angle <= previous:
			return false
		if angle != -int(angles[angles.size() - 1 - index]):
			return false
		previous = angle
	return int(angles[angles.size() / 2]) == 0


func _validate_playable_simulation(ability: Dictionary) -> bool:
	var ability_id := String(ability.get("id", ""))
	var shape := String(ability.get("shape", ""))
	var required_positive: Array[String] = ["radius"]
	match shape:
		"projectile":
			required_positive.append_array(["speed", "damage", "lifetime_ms"])
			for angle_value: Variant in ability.get("projectile_angles_degrees", [0]):
				if int(angle_value) not in BURST_ANGLES:
					return _fail("runtime projectile angles have no deterministic rotation: %s/%d" % [ability_id, int(angle_value)])
			if ability.has("remaining_bounces") and not _bounded_integer(ability["remaining_bounces"], 0, 8):
				return _fail("runtime projectile bounce count is invalid: %s" % ability_id)
		"beam", "spray":
			required_positive.append_array(["range", "damage"])
			if shape == "spray":
				required_positive.append("cone_cosine_squared_per_million")
			if not _valid_hit_control(ability):
				return _fail("runtime instant spell hit control is invalid: %s" % ability_id)
		"field":
			required_positive.append_array(["range", "lifetime_ms"])
			if not _valid_hit_control(ability):
				return _fail("runtime field hit control is invalid: %s" % ability_id)
		_:
			return _fail("playable spell has no compiled simulation shape: %s" % ability_id)
	for field: String in required_positive:
		if not _bounded_integer(ability.get(field), 1, 10_000_000):
			return _fail("runtime spell simulation field is invalid: %s/%s" % [ability_id, field])
	return true


func _valid_hit_control(ability: Dictionary) -> bool:
	if not _bounded_integer(ability.get("hit_control_state"), 0, 6) \
		or int(ability["hit_control_state"]) not in [0, 1, 6] \
		or not _bounded_integer(ability.get("hit_control_duration_ms"), 0, 5_000) \
		or not _bounded_integer(ability.get("hit_control_speed"), 0, 2_000_000) \
		or not _bounded_integer(ability.get("hit_control_slow_ratio"), 1, 1_000):
		return false
	return int(ability["hit_control_state"]) == 0 or int(ability["hit_control_duration_ms"]) > 0


static func _bounded_integer(value: Variant, minimum: int, maximum: int) -> bool:
	if typeof(value) not in [TYPE_INT, TYPE_FLOAT]:
		return false
	var integer := int(value)
	return float(value) == float(integer) and integer >= minimum and integer <= maximum


func _validate_runtime_wire_order() -> bool:
	var order_value: Variant = data.get("runtime_wire_ids", [])
	if not order_value is Array:
		return _fail("runtime wire order must be an array")
	var seen: Dictionary = {}
	for wire_value: Variant in order_value:
		if not _bounded_integer(wire_value, 1, 65_535):
			return _fail("runtime wire order contains an invalid wire")
		var wire_id := int(wire_value)
		if seen.has(wire_id) or not ability_ids_by_wire.has(wire_id):
			return _fail("runtime wire order must contain unique known wires: %d" % wire_id)
		var entry: Dictionary = ability_from_wire(wire_id)
		if String(entry.get("runtime_status", "")) != "playable":
			return _fail("runtime wire order contains a gated ability: %d" % wire_id)
		seen[wire_id] = true
		runtime_wire_ids.append(wire_id)
	if runtime_wire_ids.size() != playable_spell_ids().size():
		return _fail("runtime wire order must contain every playable spell exactly once")
	return true


func _validate_first_eight_bursts() -> bool:
	var bursts_by_element: Dictionary = {}
	for ability_id: String in abilities_by_id:
		var ability: Dictionary = abilities_by_id[ability_id]
		if not ability.has("delivery_kernel"):
			continue
		if String(ability.get("delivery_kernel", "")) != "burst":
			return _fail("ability declares an unsupported delivery kernel: %s" % ability_id)
		var element_id := String(ability.get("element", ""))
		if element_id not in FIRST_EIGHT_ELEMENTS or bursts_by_element.has(element_id):
			return _fail("first-eight Burst elements must be unique and complete: %s" % element_id)
		if String(ability.get("shape", "")) != "projectile" \
			or String(ability.get("delivery", "")) != "aimed" \
			or String(ability.get("impact", "")) != "damage" \
			or String(ability.get("residue", "")) != "none" \
			or String(ability.get("runtime_status", "")) != "playable" \
			or String(ability.get("slot_kind", "")) != "active" \
			or String(ability.get("cadence_tier", "")) != "tempo" \
			or bool(ability.get("material_runtime_enabled", true)):
			return _fail("first-eight Burst delivery contract drifted: %s" % ability_id)
		for field: String in ["points", "affinity_discount", "flux_cost", "cooldown_ms", "startup_ms", "recovery_ms"]:
			var expected: int = int({"points": 5, "affinity_discount": 1, "flux_cost": 16, "cooldown_ms": 900, "startup_ms": 150, "recovery_ms": 160}[field])
			if int(ability.get(field, -1)) != expected:
				return _fail("first-eight Burst economy must remain comparable: %s/%s" % [ability_id, field])
		var angles: Array[int] = []
		for angle: Variant in ability.get("projectile_angles_degrees", []):
			angles.append(int(angle))
		if angles != BURST_ANGLES:
			return _fail("first-eight Burst geometry must remain identical: %s" % ability_id)
		bursts_by_element[element_id] = ability_id
	if bursts_by_element.size() != FIRST_EIGHT_ELEMENTS.size():
		return _fail("ability catalog requires exactly one comparable Burst for every first-eight element")
	for element_id: String in FIRST_EIGHT_ELEMENTS:
		if not bursts_by_element.has(element_id):
			return _fail("ability catalog is missing the %s Burst" % element_id)
	return true


func ability(ability_id: String) -> Dictionary:
	return abilities_by_id.get(ability_id, {})


func ability_id_from_wire(wire_id: int) -> String:
	return String(ability_ids_by_wire.get(wire_id, ""))


func ability_from_wire(wire_id: int) -> Dictionary:
	return ability(ability_id_from_wire(wire_id))


func active_element_ids() -> Array[String]:
	var result: Array[String] = []
	for element_id: String in elements_by_id:
		if bool((elements_by_id[element_id] as Dictionary).get("runtime_enabled", false)):
			result.append(element_id)
	result.sort()
	return result


func playable_spell_ids() -> Array[String]:
	var result: Array[String] = []
	for ability_id: String in abilities_by_id:
		var entry: Dictionary = abilities_by_id[ability_id]
		if String(entry.get("runtime_status", "")) == "playable" and String(entry.get("slot_kind", "")) in ["primary", "active", "mobility"]:
			result.append(ability_id)
	result.sort()
	return result


func _fail(message: String) -> bool:
	last_error = message
	return false
