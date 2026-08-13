class_name LoadoutDefinition
extends RefCounted


const SUPPORTED_SCHEMA_VERSION: int = 2

var data: Dictionary = {}
var last_error: String = ""
var content_hash: String = ""
var active_points: int = 0
var spell_slot_ids: Array[String] = []


func load_from_file(path: String, catalog: AbilityCatalog) -> bool:
	last_error = ""
	if not FileAccess.file_exists(path):
		return _fail("loadout does not exist: %s" % path)
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _fail("loadout cannot be opened: %s" % path)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return _fail("loadout root must be an object")
	data = parsed
	return validate(catalog)


func validate(catalog: AbilityCatalog) -> bool:
	last_error = ""
	content_hash = ""
	active_points = 0
	spell_slot_ids = []
	if not catalog.last_error.is_empty() or catalog.content_hash.is_empty():
		return _fail("loadout requires a valid ability catalog")
	if int(data.get("schema_version", 0)) != SUPPORTED_SCHEMA_VERSION:
		return _fail("unsupported loadout schema")
	if String(data.get("id", "")).is_empty() or String(data.get("champion_id", "")).is_empty():
		return _fail("loadout and champion ids are required")
	var affinities: Array = data.get("affinities", [])
	if affinities.size() < 2 or affinities.size() > 3:
		return _fail("champion loadout requires two or three affinities")
	var affinity_set: Dictionary = {}
	for value: Variant in affinities:
		var affinity := String(value)
		if affinity_set.has(affinity) or not catalog.elements_by_id.has(affinity):
			return _fail("affinities must be known and unique: %s" % affinity)
		if not bool((catalog.elements_by_id[affinity] as Dictionary).get("runtime_enabled", false)):
			return _fail("loadout affinity is not runtime-enabled: %s" % affinity)
		affinity_set[affinity] = true

	var slots: Dictionary = data.get("slots", {})
	for slot_name: String in ["passive", "primary", "mobility", "ultimate"]:
		if not _validate_slot(catalog, String(slots.get(slot_name, "")), slot_name):
			return false
	var actives: Array = slots.get("actives", [])
	if actives.size() != 3:
		return _fail("loadout requires exactly three catalog actives")
	var active_ids: Dictionary = {}
	for value: Variant in actives:
		var ability_id := String(value)
		if active_ids.has(ability_id):
			return _fail("loadout actives must be unique: %s" % ability_id)
		if not _validate_slot(catalog, ability_id, "active"):
			return false
		active_ids[ability_id] = true
		var ability: Dictionary = catalog.ability(ability_id)
		var effective_points := int(ability.get("points", 0))
		if affinity_set.has(String(ability.get("element", ""))):
			effective_points = maxi(1, effective_points - int(ability.get("affinity_discount", 0)))
		active_points += effective_points
	var budget := int(data.get("active_budget", 0))
	if budget != 13:
		return _fail("standard competitive active budget must be 13")
	if active_points > budget:
		return _fail("loadout exceeds active budget: %d/%d" % [active_points, budget])
	var requested_spell_slots: Variant = data.get("spell_slots", [])
	if not requested_spell_slots is Array or requested_spell_slots.size() != 5:
		return _fail("loadout requires exactly five spell slots")
	var equipped_spell_ids: Dictionary = {}
	for raw_spell_id: Variant in requested_spell_slots:
		var spell_id := String(raw_spell_id)
		var spell: Dictionary = catalog.ability(spell_id)
		if spell.is_empty():
			return _fail("spell slot references unknown ability: %s" % spell_id)
		var slot_kind := String(spell.get("slot_kind", ""))
		if slot_kind not in ["primary", "active", "mobility"]:
			return _fail("ability %s cannot occupy a spell slot" % spell_id)
		if equipped_spell_ids.has(spell_id):
			return _fail("spell slots must be unique: %s" % spell_id)
		equipped_spell_ids[spell_id] = true
		spell_slot_ids.append(spell_id)
	content_hash = CanonicalContent.sha256({"catalog_hash": catalog.content_hash, "loadout": data})
	if content_hash.length() != 64:
		return _fail("loadout hash failed")
	return true


func _validate_slot(catalog: AbilityCatalog, ability_id: String, expected_kind: String) -> bool:
	var ability: Dictionary = catalog.ability(ability_id)
	if ability.is_empty():
		return _fail("loadout references unknown ability: %s" % ability_id)
	if String(ability.get("slot_kind", "")) != expected_kind:
		return _fail("ability %s cannot occupy %s" % [ability_id, expected_kind])
	return true


func _fail(message: String) -> bool:
	last_error = message
	return false
