class_name ReactionDefinitionTable
extends RefCounted


const COMPILER_CONTRACT_VERSION: int = 1

var last_error: String = ""
var content_hash: String = ""
var runtime_bounds: Dictionary = {}
var _definitions_by_pair: Dictionary = {}
var _definitions_by_wire: Dictionary = {}


func compile(reactions: ReactionCatalog, abilities: AbilityCatalog) -> bool:
	last_error = ""
	content_hash = ""
	runtime_bounds = {}
	_definitions_by_pair = {}
	_definitions_by_wire = {}
	if reactions == null or reactions.content_hash.length() != 64:
		return _fail("reaction definitions require one validated reaction catalog")
	if abilities == null or abilities.content_hash.length() != 64:
		return _fail("reaction definitions require one validated ability catalog")
	if abilities.active_element_ids() != _sorted_copy(ReactionCatalog.FIRST_EIGHT_ELEMENTS):
		return _fail("reaction and ability catalogs disagree on enabled elements")
	runtime_bounds = reactions.runtime_bounds.duplicate(true)
	for wire_id: int in reactions.ordered_wire_ids():
		var reaction: Dictionary = reactions.reaction_from_wire(wire_id)
		var pair: Array[String] = ReactionCatalog._string_array(reaction.get("input_elements", []))
		var profile: Dictionary = reactions.runtime_profiles.get(String(reaction.get("runtime_profile", "")), {})
		var definition := _compile_definition(reaction, pair, profile, reactions, abilities)
		if definition.is_empty():
			return false
		var key := ReactionCatalog.pair_key(pair[0], pair[1])
		_definitions_by_pair[key] = definition
		_definitions_by_wire[wire_id] = definition
	content_hash = CanonicalContent.sha256({
		"compiler_contract_version": COMPILER_CONTRACT_VERSION,
		"reaction_catalog_hash": reactions.content_hash,
		"ability_catalog_hash": abilities.content_hash,
	})
	return content_hash.length() == 64 or _fail("reaction definition hash failed")


func definition(element_a: String, element_b: String) -> Dictionary:
	return (_definitions_by_pair.get(ReactionCatalog.pair_key(element_a, element_b), {}) as Dictionary).duplicate(true)


func definition_from_wire(wire_id: int) -> Dictionary:
	return (_definitions_by_wire.get(wire_id, {}) as Dictionary).duplicate(true)


func ordered_wire_ids() -> Array[int]:
	var result: Array[int] = []
	for wire_value: Variant in _definitions_by_wire.keys():
		result.append(int(wire_value))
	result.sort()
	return result


func mutation_enabled() -> bool:
	return false


func _compile_definition(
	reaction: Dictionary,
	pair: Array[String],
	profile: Dictionary,
	reactions: ReactionCatalog,
	abilities: AbilityCatalog,
) -> Dictionary:
	if pair.size() != 2 or profile.is_empty():
		_fail("reaction compiler received incomplete validated content")
		return {}
	var element_wires: Array[int] = []
	var channel_vector: Dictionary = {}
	for channel_id: String in ReactionCatalog.CHANNELS:
		channel_vector[channel_id] = 0
	for element_id: String in pair:
		var element: Dictionary = abilities.elements_by_id.get(element_id, {})
		if element.is_empty():
			_fail("reaction compiler cannot resolve element: %s" % element_id)
			return {}
		element_wires.append(int(element.get("wire_id", 0)))
		var vector: Dictionary = reactions.element_channel_vectors.get(element_id, {})
		for channel_id: String in ReactionCatalog.CHANNELS:
			channel_vector[channel_id] = clampi(
				int(channel_vector[channel_id]) + int(vector.get(channel_id, 0)),
				-SimConfig.FIXED_SCALE,
				SimConfig.FIXED_SCALE,
			)
	return {
		"id": String(reaction.get("id", "")),
		"name": String(reaction.get("name", "")),
		"wire_id": int(reaction.get("wire_id", 0)),
		"input_element_ids": pair.duplicate(),
		"input_element_wire_ids": element_wires,
		"primitive": String(profile.get("primitive", "")),
		"channel_vector": channel_vector,
		"formation_threshold": int(profile.get("formation_threshold", 0)),
		"formation_ms": int(profile.get("formation_ms", 0)),
		"active_ms": int(profile.get("active_ms", 0)),
		"residue_ms": int(profile.get("residue_ms", 0)),
		"maximum_area_cells": int(profile.get("maximum_area_cells", 0)),
		"maximum_propagation_depth": int(profile.get("maximum_propagation_depth", 0)),
		"work_units_per_tick": int(profile.get("work_units_per_tick", 0)),
		"maximum_owners": int(reactions.runtime_bounds.get("maximum_owners_per_reaction", 0)),
		"worldbone_policy": String((reactions.data.get("policy", {}) as Dictionary).get("worldbone_policy", "")),
		"telegraph": String(reaction.get("telegraph", "")),
		"residue": String(reaction.get("residue", "")),
		"counters": (reaction.get("counters", []) as Array).duplicate(true),
		"runtime_enabled": false,
	}


static func _sorted_copy(values: Array[String]) -> Array[String]:
	var result := values.duplicate()
	result.sort()
	return result


func _fail(message: String) -> bool:
	last_error = message
	return false
