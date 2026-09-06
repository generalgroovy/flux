class_name CharacterOverviewModel
extends RefCounted


# Presentation-only projection. Never use this model to authorize selection or
# apply statistics; ChampionCatalog remains the playable authority.
const RACE_RULE_NOTE := "Race identifies ancestry. Displayed stats belong to each champion; separate race bonuses are not active."
const PLANNED_NOTE := "Planned identity. Combat stats, kit and animation acceptance are not yet available."


static func build(champions: ChampionCatalog, roster: ChampionRosterPlan) -> Dictionary:
	if champions == null or roster == null:
		return _failure("Character overview requires both catalogs.")
	if champions.content_hash.length() != 64 or roster.content_hash.length() != 64 \
		or not champions.last_error.is_empty() or not roster.last_error.is_empty():
		return _failure("Character overview requires successfully validated catalogs.")
	if roster.ordered_ids.size() != ChampionRosterPlan.EXPECTED_CHAMPION_COUNT:
		return _failure("Character overview roster count disagrees with its contract.")
	var races: Dictionary = {}
	for race_value: Variant in roster.data.get("allowed_ancestries", []):
		var race_id := String(race_value)
		if race_id.is_empty() or races.has(race_id):
			return _failure("Character overview contains an invalid race row.")
		races[race_id] = {
			"race_id": race_id, "race": race_id.capitalize(), "champions": [],
			"playable_count": 0, "planned_count": 0, "placeholder_count": 0,
			"race_rules_note": RACE_RULE_NOTE,
		}
	var entries_by_id: Dictionary = {}
	var playable_count := 0
	for champion_id: String in roster.ordered_ids:
		var identity := roster.entry(champion_id)
		var affinity := roster.affinity_entry(champion_id)
		var race_id := String(identity.get("ancestry", ""))
		var availability := String(identity.get("availability", ""))
		if entries_by_id.has(champion_id) or identity.is_empty() or affinity.is_empty() \
			or not races.has(race_id) or availability not in ChampionRosterPlan.ALLOWED_AVAILABILITY:
			return _failure("Character overview identity is invalid: %s" % champion_id)
		var source := champions.champion(champion_id)
		var playable := availability == "playable"
		if playable != not source.is_empty():
			return _failure("Character overview availability disagrees with playable authority: %s" % champion_id)
		var entry := {
			"id": champion_id, "display_name": String(identity["display_name"]),
			"race_id": race_id, "race": race_id.capitalize(),
			"body_type": String(identity["body_role"]),
			"availability": availability, "status": availability.capitalize(),
			"selectable": playable, "stats_available": playable,
			"affinities": (affinity["affinities"] as Array).duplicate(true),
			"affinity_points": (affinity["affinity_points"] as Dictionary).duplicate(true),
			"affinity_status": "active" if playable else "planned",
			"reserved_future_affinity": String(identity.get("reserved_future_affinity", "")),
			"stats": {}, "stat_lines": [], "foundation_kit": {}, "body_profile": {},
			"wire_id": 0, "playstyle": "", "note": "" if playable else PLANNED_NOTE,
		}
		if playable:
			if String(source.get("display_name", "")) != String(identity["display_name"]) \
				or String(source.get("ancestry", "")) != race_id \
				or String(source.get("body_type", "")) != String(identity["body_role"]) \
				or source.get("affinities", []) != affinity["affinities"] \
				or source.get("affinity_points", {}) != affinity["affinity_points"]:
				return _failure("Character overview identity differs across catalogs: %s" % champion_id)
			var stats: Dictionary = source.get("stats", {})
			for stat_name: String in ChampionCatalog.STAT_BOUNDS:
				if not stats.has(stat_name):
					return _failure("Character overview lacks a playable stat: %s/%s" % [champion_id, stat_name])
			if not champions.body_type_profiles.accepts(String(entry["body_type"]), stats):
				return _failure("Character overview stats contradict body role: %s" % champion_id)
			entry["stats"] = stats.duplicate(true)
			entry["stat_lines"] = _stat_lines(stats)
			entry["foundation_kit"] = (source.get("foundation_kit", {}) as Dictionary).duplicate(true)
			entry["wire_id"] = int(source["wire_id"])
			entry["playstyle"] = String(source["playstyle"])
			# Only the validated body role is exposed, not stale shared movement prose.
			entry["body_profile"] = (champions.body_type_profiles.profiles[String(entry["body_type"])] as Dictionary).duplicate(true)
			playable_count += 1
		var row: Dictionary = races[race_id]
		(row["champions"] as Array).append(entry)
		row[availability + "_count"] = int(row[availability + "_count"]) + 1
		entries_by_id[champion_id] = entry
	if playable_count != champions.champions_by_id.size() \
		or playable_count != ChampionRosterPlan.EXPECTED_PLAYABLE_COUNT:
		return _failure("Character overview omits a promoted champion.")
	var race_ids: Array = races.keys()
	race_ids.sort()
	var rows: Array = []
	for race_id: String in race_ids:
		var row: Dictionary = races[race_id]
		(row["champions"] as Array).sort_custom(_name_before)
		rows.append(row)
	var result := {
		"schema_version": 1, "valid": true, "error": "", "rows": rows,
		"entries_by_id": entries_by_id, "champion_count": entries_by_id.size(),
		"playable_count": playable_count,
		"planned_count": roster.ids_by_availability("planned").size(),
		"placeholder_count": roster.ids_by_availability("placeholder").size(),
		"race_rules_note": RACE_RULE_NOTE,
		"stat_units": "Stats use fixed-point thousandths; displayed resources and regeneration are points and points/s. Speed is relative to base walk speed.",
		"source_hashes": {"champions": champions.content_hash, "roster": roster.content_hash},
	}
	_freeze(result)
	return result


static func _stat_lines(stats: Dictionary) -> Array[String]:
	return [
		"Health %s | recovery %s/s" % [_points(int(stats["health_maximum"])), _points(int(stats["health_recovery_per_second"]))],
		"Flux %s | recovery %s/s" % [_points(int(stats["flux_maximum"])), _points(int(stats["flux_recovery_per_second"]))],
		"Stamina %s | recovery %s/s" % [_points(int(stats["stamina_maximum"])), _points(int(stats["stamina_recovery_per_second"]))],
		"Walk speed %s%% of base" % String.num(float(stats["movement_speed_ratio"]) / 10.0, 1),
	]


static func _points(value: int) -> String:
	return String.num(float(value) / float(SimConfig.FIXED_SCALE), 2)


static func _name_before(left: Dictionary, right: Dictionary) -> bool:
	var left_name := String(left["display_name"]).to_lower()
	var right_name := String(right["display_name"]).to_lower()
	return String(left["id"]) < String(right["id"]) if left_name == right_name else left_name < right_name


static func _failure(message: String) -> Dictionary:
	var result := {"schema_version": 1, "valid": false, "error": message, "rows": [], "entries_by_id": {}, "champion_count": 0, "playable_count": 0}
	_freeze(result)
	return result


static func _freeze(value: Variant) -> void:
	if value is Dictionary:
		for child: Variant in (value as Dictionary).values():
			_freeze(child)
		(value as Dictionary).make_read_only()
	elif value is Array:
		for child: Variant in value:
			_freeze(child)
		(value as Array).make_read_only()
