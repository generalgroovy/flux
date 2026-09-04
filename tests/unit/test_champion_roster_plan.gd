extends FluxTestSuite


const ChampionRosterPlanScript = preload("res://src/content/champion_roster_plan.gd")


func run() -> int:
	var roster = ChampionRosterPlanScript.new()
	check(roster.load_from_files(), "canonical champion roster plan validates: %s" % roster.last_error)
	if roster.ordered_ids.is_empty():
		return finish("champion-roster-plan")
	equal(roster.ordered_ids.size(), 24, "roster plan contains exactly 24 identities")
	equal(roster.ids_by_availability("playable"), ["oh_tipi", "s_wayne", "red_baron"], "only the three foundation champions are promoted")
	equal(roster.ids_by_availability("placeholder"), ["unnamed_angel"], "the angel remains visibly non-selectable")
	equal(String(roster.entry("s_wayne").get("ancestry", "")), "hobbit", "S. Wayne remains a Hobbit")
	equal(String(roster.entry("haara").get("ancestry", "")), "nymph", "Haara remains a Nymph")
	equal(String(roster.entry("wa_bidi").get("ancestry", "")), "goblin", "Wa Bidi remains a Goblin")
	equal(String(roster.entry("spai_si").get("ancestry", "")), "demon", "Spai Si remains a Demon")
	equal(String(roster.entry("hesus_christo").get("ancestry", "")), "elf", "Hesus Christo remains an Elf")
	equal(String(roster.entry("djonah_thaan").get("ancestry", "")), "vampire", "Djonah Thaan remains a Vampire")
	equal(String(roster.entry("nico_lai").get("display_name", "")), "Waka Aren Si", "legacy Nico technical ID resolves to the canonical display name")
	equal(String(roster.entry("donnok").get("display_name", "")), "Don Doko Don", "legacy Donnok technical ID resolves to the canonical display name")
	var mutable_copy := roster.entry("oh_tipi")
	mutable_copy["display_name"] = "Mutated"
	equal(String(roster.entry("oh_tipi").get("display_name", "")), "Oh Tipi", "roster lookup returns a defensive copy")

	var duplicate = ChampionRosterPlanScript.new()
	duplicate.data = roster.data.duplicate(true)
	((duplicate.data["champions"] as Array)[1] as Dictionary)["id"] = "oh_tipi"
	check(not duplicate.validate(), "duplicate roster identities fail closed")
	check(not duplicate.last_error.is_empty(), "invalid roster identity reports one cause")

	var promoted_plan = ChampionRosterPlanScript.new()
	promoted_plan.data = roster.data.duplicate(true)
	((promoted_plan.data["champions"] as Array)[3] as Dictionary)["availability"] = "playable"
	check(not promoted_plan.validate(), "planned content cannot become playable without the promoted catalog")

	var stale_name = ChampionRosterPlanScript.new()
	stale_name.data = roster.data.duplicate(true)
	((stale_name.data["champions"] as Array)[9] as Dictionary)["display_name"] = "Nico Lai"
	check(not stale_name.validate(), "stale player-facing identity fails linked-catalog validation")
	check(stale_name.entry("oh_tipi").is_empty(), "failed validation never exposes a partially populated roster")
	var bad_shape = ChampionRosterPlanScript.new()
	bad_shape.data = roster.data.duplicate(true)
	bad_shape.data["champions"] = "not an array"
	check(not bad_shape.validate(), "malformed roster collection fails without a script error")
	var archived := {"ancestry": "sylph", "elements": ["wind"], "atlas": "old-art.png"}
	var adapted: Dictionary = roster.visual_metadata("wa_bidi", archived)
	equal(adapted["ancestry"], "goblin", "shared visual adapter uses current identity")
	equal(adapted["archive_ancestry"], "sylph", "shared adapter preserves asset provenance")
	equal(adapted["atlas"], "old-art.png", "identity adaptation never silently replaces asset paths")
	(adapted["archive_elements"] as Array).append("ice")
	equal(archived["elements"], ["wind"], "archive metadata is deeply copied")
	(adapted["elements"] as Array).clear()
	equal(roster.affinity_entry("wa_bidi")["affinities"], ["charge", "wind", "fire"], "adapter cannot mutate canonical affinities")
	check(roster.visual_metadata("missing", archived).is_empty(), "unknown visual identity fails closed")
	return finish("champion-roster-plan")
