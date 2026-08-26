class_name ChampionCatalog
extends RefCounted


const SUPPORTED_SCHEMA_VERSION: int = 1
const TREEVOR_CHAMPION_ID: String = "treevor_mason"
const AFFINITY_POINT_BUDGET: int = 3
const SUPPORTED_ANCESTRIES: Array[String] = [
	"human", "dwarf", "gnome", "hobbit", "elf", "orc", "troll", "minotaur",
	"seakin", "wyrmborn", "stoneborn", "treefolk", "sylph", "undead", "goblin",
	"nymph", "arachnoid", "vampire", "demon", "angel", "werewolf",
]
const SUPPORTED_SIZES: Array[String] = [
	"size_1_tiny", "size_2_small", "size_3_medium", "size_4_large", "size_5_huge",
]
const STAT_BOUNDS: Dictionary = {
	"health_maximum": Vector2i(60_000, 160_000),
	"health_recovery_per_second": Vector2i(0, 8_000),
	"flux_maximum": Vector2i(60_000, 160_000),
	"flux_recovery_per_second": Vector2i(5_000, 50_000),
	"stamina_maximum": Vector2i(60_000, 160_000),
	"stamina_recovery_per_second": Vector2i(10_000, 50_000),
	"movement_speed_ratio": Vector2i(850, 1150),
}

var data: Dictionary = {}
var last_error: String = ""
var content_hash: String = ""
var default_champion_id: String = ""
var champions_by_id: Dictionary[String, Dictionary] = {}
var champion_ids_by_wire: Dictionary[int, String] = {}
var kit_wires_by_champion: Dictionary[String, Dictionary] = {}


func load_from_file(path: String, abilities: AbilityCatalog) -> bool:
	last_error = ""
	data = {}
	if not FileAccess.file_exists(path):
		return _fail("champion catalog does not exist: %s" % path)
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _fail("champion catalog cannot be opened: %s" % path)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return _fail("champion catalog root must be an object")
	data = parsed
	return validate(abilities)


func validate(abilities: AbilityCatalog) -> bool:
	last_error = ""
	content_hash = ""
	default_champion_id = ""
	champions_by_id = {}
	champion_ids_by_wire = {}
	kit_wires_by_champion = {}
	if abilities == null or not abilities.last_error.is_empty() or abilities.content_hash.is_empty():
		return _fail("champion catalog requires a valid ability catalog")
	if int(data.get("schema_version", 0)) != SUPPORTED_SCHEMA_VERSION:
		return _fail("unsupported champion catalog schema")
	if String(data.get("id", "")).is_empty():
		return _fail("champion catalog id is required")
	var affinity_pair_owners: Dictionary = {}
	for value: Variant in data.get("champions", []):
		if not value is Dictionary:
			return _fail("every champion must be an object")
		var champion: Dictionary = value
		var champion_id := String(champion.get("id", ""))
		var wire_id := int(champion.get("wire_id", 0))
		if champion_id.is_empty() or champions_by_id.has(champion_id):
			return _fail("champion ids must be non-empty and unique: %s" % champion_id)
		if wire_id <= 0 or champion_ids_by_wire.has(wire_id):
			return _fail("champion wire ids must be positive and unique: %d" % wire_id)
		if String(champion.get("display_name", "")).is_empty():
			return _fail("champion display name is required: %s" % champion_id)
		if not SUPPORTED_ANCESTRIES.has(String(champion.get("ancestry", ""))):
			return _fail("champion ancestry is unsupported: %s" % champion_id)
		if not SUPPORTED_SIZES.has(String(champion.get("size", ""))):
			return _fail("champion size is unsupported: %s" % champion_id)
		if String(champion.get("playstyle", "")).is_empty():
			return _fail("champion needs a concise playstyle: %s" % champion_id)

		var affinities: Array = champion.get("affinities", [])
		var max_affinities := 3 if champion_id == TREEVOR_CHAMPION_ID else 2
		if affinities.size() < 2 or affinities.size() > max_affinities:
			return _fail("champion requires two affinities; Treevor may have three: %s" % champion_id)
		var affinity_set: Dictionary = {}
		for affinity_value: Variant in affinities:
			var affinity := String(affinity_value)
			if affinity_set.has(affinity) or not abilities.elements_by_id.has(affinity):
				return _fail("champion affinities must be known and unique: %s" % champion_id)
			if not bool((abilities.elements_by_id[affinity] as Dictionary).get("runtime_enabled", false)):
				return _fail("champion affinity is not runtime-enabled: %s" % affinity)
			affinity_set[affinity] = true

		var affinity_points: Dictionary = champion.get("affinity_points", {})
		if affinity_points.size() != affinities.size():
			return _fail("affinity_points must match champion affinities: %s" % champion_id)
		var affinity_point_total := 0
		for affinity: String in affinity_set:
			if not affinity_points.has(affinity):
				return _fail("affinity_points must include every champion affinity: %s/%s" % [champion_id, affinity])
			var strength := int(affinity_points[affinity])
			if strength < 1 or strength > 2:
				return _fail("affinity strength must be 1 or 2: %s/%s" % [champion_id, affinity])
			affinity_point_total += strength
		for point_key: Variant in affinity_points.keys():
			if not affinity_set.has(String(point_key)):
				return _fail("affinity_points cannot contain undeclared affinity: %s/%s" % [champion_id, String(point_key)])
		if affinity_point_total != AFFINITY_POINT_BUDGET:
			return _fail("champion affinity points must total %d: %s" % [AFFINITY_POINT_BUDGET, champion_id])

		if affinities.size() == 2:
			var affinity_pair: Array[String] = [String(affinities[0]), String(affinities[1])]
			affinity_pair.sort()
			var affinity_pair_key := "%s+%s" % [affinity_pair[0], affinity_pair[1]]
			if affinity_pair_owners.has(affinity_pair_key):
				return _fail("two-affinity combinations must be unique: %s conflicts with %s" % [champion_id, String(affinity_pair_owners[affinity_pair_key])])
			affinity_pair_owners[affinity_pair_key] = champion_id

		var stats: Dictionary = champion.get("stats", {})
		for stat_name: String in STAT_BOUNDS:
			if not stats.has(stat_name):
				return _fail("champion stat is missing: %s/%s" % [champion_id, stat_name])
			var bounds: Vector2i = STAT_BOUNDS[stat_name]
			var stat_value := int(stats[stat_name])
			if stat_value < bounds.x or stat_value > bounds.y:
				return _fail("champion stat is outside safe bounds: %s/%s" % [champion_id, stat_name])
		var kit: Dictionary = champion.get("foundation_kit", {})
		var kit_wires: Dictionary = {}
		for slot_name: String in ["primary", "active_1"]:
			var ability_id := String(kit.get(slot_name, ""))
			var ability: Dictionary = abilities.ability(ability_id)
			var expected_kind := "primary" if slot_name == "primary" else "active"
			if ability.is_empty() or String(ability.get("slot_kind", "")) != expected_kind:
				return _fail("champion kit slot is invalid: %s/%s" % [champion_id, slot_name])
			kit_wires[slot_name] = int(ability.get("wire_id", 0))
		kit_wires["active_2"] = 0
		var active_2_id := String(kit.get("active_2", ""))
		if not active_2_id.is_empty():
			var active_2: Dictionary = abilities.ability(active_2_id)
			if active_2.is_empty() or String(active_2.get("slot_kind", "")) != "active":
				return _fail("champion kit slot is invalid: %s/active_2" % champion_id)
			kit_wires["active_2"] = int(active_2.get("wire_id", 0))
			if kit_wires["active_2"] in [kit_wires["primary"], kit_wires["active_1"]]:
				return _fail("champion kit spells must be unique: %s" % champion_id)
		champions_by_id[champion_id] = champion
		champion_ids_by_wire[wire_id] = champion_id
		kit_wires_by_champion[champion_id] = kit_wires
	default_champion_id = String(data.get("default_champion_id", ""))
	if not champions_by_id.has(default_champion_id):
		return _fail("default champion must resolve")
	if champions_by_id.size() < 2:
		return _fail("foundation slice requires at least two champions")
	content_hash = CanonicalContent.sha256({"abilities": abilities.content_hash, "champions": data})
	return content_hash.length() == 64 or _fail("champion catalog hash failed")


func champion(champion_id: String) -> Dictionary:
	return champions_by_id.get(champion_id, {})


func affinity_strength(champion_id: String, element_id: String) -> int:
	var champion_data: Dictionary = champion(champion_id)
	if champion_data.is_empty():
		return 0
	var affinity_points: Dictionary = champion_data.get("affinity_points", {})
	return int(affinity_points.get(element_id, 0))


func champion_id_from_wire(wire_id: int) -> String:
	return champion_ids_by_wire.get(wire_id, "")


func ordered_champion_ids() -> Array[String]:
	var wire_ids: Array[int] = champion_ids_by_wire.keys()
	wire_ids.sort()
	var result: Array[String] = []
	for wire_id: int in wire_ids:
		result.append(champion_ids_by_wire[wire_id])
	return result


func next_champion_id(champion_id: String) -> String:
	var ordered := ordered_champion_ids()
	var current_index: int = ordered.find(champion_id)
	return ordered[(current_index + 1) % ordered.size()] if current_index >= 0 else default_champion_id


func apply_to_player(state: PlayerState, champion_id: String, preserve_resource_ratios: bool = false) -> bool:
	if state == null or not champions_by_id.has(champion_id):
		return false
	var champion_data: Dictionary = champions_by_id[champion_id]
	var stats: Dictionary = champion_data["stats"]
	var old_health_maximum := maxi(1, state.health_maximum)
	var old_flux_maximum := maxi(1, state.flux_maximum)
	var old_stamina_maximum := maxi(1, state.stamina_maximum)
	var old_health := state.health
	var old_flux := state.flux
	var old_stamina := state.stamina
	state.champion_wire_id = int(champion_data["wire_id"])
	state.health_maximum = int(stats["health_maximum"])
	state.health_recovery_per_second = int(stats["health_recovery_per_second"])
	state.flux_maximum = int(stats["flux_maximum"])
	state.flux_recovery_per_second = int(stats["flux_recovery_per_second"])
	state.stamina_maximum = int(stats["stamina_maximum"])
	state.stamina_recovery_per_second = int(stats["stamina_recovery_per_second"])
	state.movement_speed_ratio = int(stats["movement_speed_ratio"])
	var kit_wires: Dictionary = kit_wires_by_champion[champion_id]
	state.primary_wire_id = int(kit_wires["primary"])
	state.active_1_wire_id = int(kit_wires["active_1"])
	state.active_2_wire_id = int(kit_wires["active_2"])
	state.reset_spell_slots_to_kit()
	state.pending_cast_wire_id = 0
	state.pending_cast_ticks = 0
	state.cast_recovery_ticks = 0
	state.primary_cooldown_ticks = 0
	state.active_1_cooldown_ticks = 0
	state.active_2_cooldown_ticks = 0
	if preserve_resource_ratios:
		state.health = clampi(old_health * state.health_maximum / old_health_maximum, 0, state.health_maximum)
		state.flux = clampi(old_flux * state.flux_maximum / old_flux_maximum, 0, state.flux_maximum)
		state.stamina = clampi(old_stamina * state.stamina_maximum / old_stamina_maximum, 0, state.stamina_maximum)
	else:
		state.health = state.health_maximum
		state.flux = state.flux_maximum
		state.stamina = state.stamina_maximum
	state.health_recovery_remainder = 0
	state.flux_recovery_remainder = 0
	state.stamina_remainder = 0
	state.health_recovery_delay_ticks = 0
	state.flux_recovery_delay_ticks = 0
	state.stamina_recovery_delay_ticks = 0
	state.last_event = "champion_%s" % champion_id
	return true


func _fail(message: String) -> bool:
	last_error = message
	return false
