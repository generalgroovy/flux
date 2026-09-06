extends FluxTestSuite


const Overview = preload("res://src/app/character_overview_model.gd")
const Roster = preload("res://src/content/champion_roster_plan.gd")


func run() -> int:
	var abilities := AbilityCatalog.new()
	check(abilities.load_from_file("res://content/abilities/foundation_abilities_v1.json"), "overview abilities validate")
	var champions := ChampionCatalog.new()
	check(champions.load_from_file("res://content/champions/foundation_champions_v1.json", abilities), "overview champions validate")
	var roster := Roster.new()
	check(roster.load_from_files(), "overview canonical roster validates")
	var model := Overview.build(champions, roster)
	check(bool(model["valid"]), "overview accepts validated catalogs: %s" % model["error"])
	if not bool(model["valid"]):
		return finish("character-overview-model")
	equal(model["champion_count"], 24, "overview includes all twenty-four identities")
	equal(model["playable_count"], 5, "overview exposes exactly five playable champions")
	equal(model["planned_count"], 18, "eighteen identities are honestly planned")
	equal(model["placeholder_count"], 1, "unnamed angel is a placeholder, not a promoted character")
	check(model.is_read_only(), "projection is immutable")
	check((model["rows"] as Array).is_read_only(), "row order is immutable")
	var seen: Dictionary = {}
	var previous_race := ""
	for row: Dictionary in model["rows"]:
		var race_id := String(row["race_id"])
		check(previous_race < race_id, "race rows sort alphabetically: " + race_id)
		previous_race = race_id
		var previous_name := ""
		for entry: Dictionary in row["champions"]:
			var champion_id := String(entry["id"])
			var display_name := String(entry["display_name"]).to_lower()
			check(previous_name <= display_name, "champions sort alphabetically within race")
			previous_name = display_name
			check(not seen.has(champion_id), "each canonical identity appears exactly once")
			seen[champion_id] = true
			equal(entry["race_id"], race_id, "champion appears in the correct race row")
			equal(entry["display_name"], roster.entry(champion_id)["display_name"], "canonical display names are used")
			check(entry.is_read_only(), "champion entry is immutable")
			check((entry["stats"] as Dictionary).is_read_only(), "nested stats are immutable")
			check((entry["affinities"] as Array).is_read_only(), "nested affinities are immutable")
			var playable := bool(entry["selectable"])
			equal(playable, not champions.champion(champion_id).is_empty(), "only actual promoted catalog entries are selectable")
			if playable:
				var source := champions.champion(champion_id)
				equal(entry["stats"], source["stats"], "all seven displayed stats derive exactly from playable authority")
				equal(entry["affinities"], source["affinities"], "playable affinities derive from playable authority")
				equal(entry["foundation_kit"], source["foundation_kit"], "starting spells remain actual catalog references")
				equal((entry["stat_lines"] as Array).size(), 4, "three resource lines and speed remain compact")
				equal(entry["wire_id"], source["wire_id"], "selector integration retains the real wire identity")
				check(not String(entry["playstyle"]).is_empty(), "actual playable role is available")
			else:
				check((entry["stats"] as Dictionary).is_empty(), "planned stats are not fabricated")
				check((entry["foundation_kit"] as Dictionary).is_empty(), "planned kit is not fabricated")
				check((entry["body_profile"] as Dictionary).is_empty(), "planned body does not pretend to have accepted stats")
				equal(entry["wire_id"], 0, "planned identity has no playable wire")
				equal(entry["affinity_status"], "planned", "planned affinities cannot be mistaken for active bonuses")
	for champion_id: String in roster.ordered_ids:
		check(seen.has(champion_id), "no canonical champion is omitted")
	equal(String(model["entries_by_id"]["nico_lai"]["display_name"]), "Waka Aren Si", "compatibility ID displays current identity")
	equal(String(model["entries_by_id"]["donnok"]["display_name"]), "Don Doko Don", "second compatibility ID displays current identity")
	equal(String(model["entries_by_id"]["grimm_bow"]["reserved_future_affinity"]), "chaos", "future element reservation is separate from active affinities")
	check(not champions.champion("oh_tipi").is_read_only(), "freezing presentation never freezes gameplay authority")
	check(not (champions.champion("oh_tipi")["stats"] as Dictionary).is_read_only(), "source nested dictionaries remain independent")
	var old_health: int = int(model["entries_by_id"]["oh_tipi"]["stats"]["health_maximum"])
	champions.champion("oh_tipi")["stats"]["health_maximum"] = old_health + 1000
	equal(model["entries_by_id"]["oh_tipi"]["stats"]["health_maximum"], old_health, "built view cannot be mutated through live catalog references")
	champions.champion("oh_tipi")["stats"]["health_maximum"] = old_health
	_test_failures(champions, roster)
	return finish("character-overview-model")


func _test_failures(champions: ChampionCatalog, roster: ChampionRosterPlan) -> void:
	var missing := Overview.build(null, roster)
	check(not bool(missing["valid"]), "missing playable catalog fails closed")
	check(not String(missing["error"]).is_empty(), "failure explains the missing input")
	check((missing["rows"] as Array).is_empty(), "failure never exposes partial rows")
	check(not bool(Overview.build(champions, Roster.new())["valid"]), "unloaded planning catalog fails closed")
	var duplicate := Roster.new()
	check(duplicate.load_from_files(), "negative roster fixture validates before mutation")
	duplicate.ordered_ids[1] = duplicate.ordered_ids[0]
	check(not bool(Overview.build(champions, duplicate)["valid"]), "duplicate identity is rejected even with stale validation hash")
	var divergent := Roster.new()
	check(divergent.load_from_files(), "cross-catalog fixture loads")
	divergent.champions_by_id["oh_tipi"]["availability"] = "planned"
	check(not bool(Overview.build(champions, divergent)["valid"]), "catalog promotion disagreement fails closed")
	var wrong_name := Roster.new()
	check(wrong_name.load_from_files(), "identity mismatch fixture loads")
	wrong_name.champions_by_id["oh_tipi"]["display_name"] = "Not Oh Tipi"
	check(not bool(Overview.build(champions, wrong_name)["valid"]), "stale playable identity cannot silently become a displayed rename")
