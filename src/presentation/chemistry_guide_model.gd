class_name ChemistryGuideModel
extends RefCounted

const Chemistry = preload("res://src/sim/chemistry/element_chemistry_system.gd")
const ELEMENTS: Array[String] = ["", "Earth", "Fire", "Water", "Wind", "Ice", "Charge", "Light", "Dark"]
# Player-facing meaning, not executable rules. Names, pairs and every lifecycle
# value are read from the live kernel; this text never grants a gameplay effect.
const EFFECTS: Array[String] = [
	"An active stone Rampart stops movement, projectiles and Beam/Spray rays. Wallrun or walljump from its faces; go around, break it or wait for decay. An actor inside as it forms can escape without teleporting.",
	"A moving hot lane pulses damage against grounded enemies. Jump across or leave its front; it does not apply a lingering burn.",
	"A shallow patch slows enemies only while grounded inside. Jump or leave it; this is not permanent terrain or a wet status.",
	"Drifting dust conceals distant silhouettes and nudges grounded enemies sideways. Close in to see, or jump clear of its shove.",
	"Brittle temporary cover stops projectiles and Beam/Spray rays. Attack the ridge or wait for decay; it does not freeze actors.",
	"A breakable node stops shots and rays. Its finite Charge reserve absorbs incoming Charge first; excess hits ordinary cover. Exhaust or destroy it.",
	"The perpendicular plane reflects ALL elements: projectiles and Beam/Spray rays, not only Light. Change your angle, go around it or wait for decay.",
	"Blocks enemy Health, Flux and Stamina recovery inside, without draining those resources. Leave to resume recovery; it does not permanently poison ground.",
	"A stationary fire ring pulses damage. Its centre hole and outside are safe from this ring; jumping alone does not avoid its damage.",
	"Expanding Steam conceals distant silhouettes, then stops concealing shortly before decay. It does not damage or wet actors; threats remain visible.",
	"A travelling flame corridor pulses damage through its active lane. Cross the narrow side between pulses; jumping alone does not avoid it.",
	"A delayed fracture damages active temporary constructs once, not actors or worldbone. Use it against reaction cover, not buildings or unformed cover.",
	"A single damaging arc requires one separate Charge deposit within link range. No extra Charge source means no damaging arc; leave the line or let its link expire.",
	"One reveal pulse marks actors inside, with no damage or healing. Leave during formation to avoid being marked; the mark briefly outlasts contact.",
	"Ember mist conceals distant silhouettes and damages enemies who stay for at least 0.5 seconds. Leave before the dwell threshold; no lingering burn follows.",
	"A shallow current pushes grounded enemies along its direction, without damage or wet status. Jump over its push or move out sideways.",
	"A travelling mist corridor conceals distant silhouettes without damage or forced movement. Close distance, reveal the actor or step outside its lane.",
	"A growing frost strip briefly slows grounded enemies on entry, not continuously while standing inside. Jump across or avoid the expanding strip.",
	"Pulsed damage covers a small origin area without links, or follows separate Water deposits when linked. A missing linked source disables the linked damage; leave the path.",
	"Reveals actors on entry and while moving; projectile crossings mark the surface. No healing, reflection or damage: pause movement or leave to stop refreshing the reveal.",
	"Conceals distant silhouettes but reveals actors while moving. Stay still for concealment after the reveal expires; it does not drain or poison actors.",
	"An annular current pushes grounded enemies tangentially, without damage. Its centre is outside the push zone; jump or cross the ring to escape.",
	"A repeating icy pulse travels down the lane and damages enemies it catches, including on entry. Pass behind the moving pulse; it does not freeze actors.",
	"A drifting charged disk pulses damage without stun or automatic chaining. Track its movement and leave its radius before the next pulse.",
	"Bends only Light projectiles and Beam/Spray rays by 15 degrees. Other elements pass unchanged; adjust aim or use a non-Light shot.",
	"A drifting corridor alternates concealment on and off. Its cadence below also gives each concealment interval; threats stay readable during both intervals.",
	"Durable, slow-forming cover stops projectiles and Beam/Spray rays, not walking. Pressure its health or reposition during formation; it does not freeze actors.",
	"A narrow pulsing damage path requires separate Ice deposits within link range. No extra Ice source means no damaging circuit; leave it or let any link expire.",
	"Splits Light projectiles and Beam/Spray rays into +/-15-degree paths with shared damage. Non-Light attacks hit it as cover; no projectile capacity means no projectile split.",
	"Entry briefly reveals actors; grounded enemies staying 0.35 seconds receive a slow. Leave or jump before that threshold; it does not add slippery movement.",
	"After charging, releases one outward push against grounded enemies, without damage. Jump during the release or leave the disk before activation.",
	"One reveal pulse along a short line marks actors, without damage or stun. Leave the lane during formation; the reveal briefly persists afterward.",
	"Conceals distant silhouettes but briefly reveals actors on entry or exit. Do not mistake crossing for invisibility; it does not stun or damage.",
	"Continuously reveals actors inside, without healing or damage. Leave its radius or put worldbone between yourself and its origin.",
	"Marks actors entering or leaving its region and marks projectile crossings. No concealment, damage or damage bonus; avoid crossing if you want to stay unmarked.",
	"Conceals distant silhouettes, reveals moving actors and damages enemies who stay at least 1 second. Leave before that threshold; standing still is not protection from damage.",
]

static func entries() -> Array[Dictionary]:
	var rows: Array[Dictionary] = [{"title":"Start here", "recipes":[], "lines": [
		"CAST -> LEAVE MATTER -> COMBINE -> COUNTER",
		"1. In the Spell Loom, equip Bolt or Wave. Cast twice at the same nearby endpoint within 3-5 seconds (by element), before the first deposit expires.",
		"2. Use two distinct casts: Wave siblings cannot react with each other. Their deposits must overlap with a clear path between them.",
		"3. Watch formation -> active -> decay: only the active window applies effects. Each cast supplies one chemistry reaction; all its remaining matter fragments are spent together.",
		"4. Choose an element row for its eight-pair table and counters. Practice reset clears transient matter.",
		"Use the Spell Loom to assign any first-eight element on any champion. Bolt, Heavy, Rapid, Wave, Spray, Beam and Field all cost Flux, but do not all leave matter.",
		"Bolt, Heavy and Wave can leave narrow trails for 0.8-1.5s; Rapid is too weak to leave a trail. Land a separate new impact on an older trail for a shorter sustained reaction. Trail + trail never reacts.",
		"SPELL IMPACT: uses that spell's damage and control rules. An impact animation or element colour does not automatically add burn, wet, healing or another status.",
		"FIELD SPELL: a separate timed control zone that can trigger once per enemy target. It is not a terminal deposit, does not deal impact damage and does not supply chemistry matter.",
		"Aim at the intended endpoint. Projectiles may end earlier on a target or cover. The mouse supplies a position; controller aim uses a direction and spell range.",
		"PLAIN TERMINAL MATTER: Bolt, Heavy, Rapid and Wave projectiles leave finite deposits when they stop. Beam, Spray and Field do not currently leave deposits. Plain matter itself causes no damage, healing, burn, wet, slow or other status.",
		"A deposit's lifetime is separate from a spell's own Field duration. The oldest deposit supplies the reaction's ownership and direction. Formation warns; decay is harmless.",
		"Reactions do not recursively create more reactions. Only one reaction origin is admitted per local cell until it expires; if space is occupied or capacity is full, the input deposits wait without being consumed.",
		"Damage, slows, pushes and recovery blocks target enemies; visibility and shot/ray interactions can affect either team. Jump avoids only explicitly grounded effects, not every chemistry hazard.",
		"Linked recipes choose separate, visible deposits when they form, not later: Plasma Arc needs extra Charge; Superconduct needs extra Ice. Conductive Flood can work locally without extra Water. Linked effects stop if any chosen link disappears.",
		"Both pair orders produce the same recipe, including same-element pairs: 36 unique results total.",
		"Worldbone stays solid. Close silhouettes remain readable through mist; projectiles and dangerous geometry are never hidden by chemistry concealment.",
		"Matter is bounded: %d total deposits, %d per owner and %d reactions." % [Chemistry.MAX_DEPOSITS,Chemistry.MAX_OWNER_DEPOSITS,Chemistry.MAX_REACTIONS],
	]}]
	for element: int in range(1,9):
		var recipes: Array[Dictionary] = []
		var lines: Array[String] = ["%s terminal deposit: %.1f seconds. Plain matter has no automatic status or damage; use a separate cast to create a reactive pair." % [ELEMENTS[element],float(Chemistry.ELEMENT_LIFE_MS[element])/1000.0], "PAIR TABLE / both orders are equivalent"]
		for other: int in range(1,9):
			var recipe := Chemistry.recipe(Chemistry.recipe_wire(element,other))
			recipes.append(recipe)
			lines.append("%s + %s = %s" % [ELEMENTS[element],ELEMENTS[other],recipe.name])
		lines.append("")
		lines.append("EFFECTS / formation -> active -> decay")
		for recipe: Dictionary in recipes:
			lines.append("%s: %s" % [recipe.name,EFFECTS[int(recipe.wire_id)-301]])
			lines.append("  %.2f s -> %.2f s -> %.2f s" % [float(recipe.formation_ms)/1000.0,float(recipe.active_ms)/1000.0,float(recipe.decay_ms)/1000.0])
			if int(recipe.pulse_ms) > 0:
				lines.append("  Cadence: %.2f s." % (float(recipe.pulse_ms)/1000.0))
			if int(recipe.wire_id) in [301,305,306,327,329]:
				lines.append("  Shot-cover health: %.0f." % (float(recipe.health)/1000.0))
			if int(recipe.wire_id) in [313,319,328]:
				lines.append("  Link reach: %.0f px per step; at most %d separate source(s)." % [float(recipe.length)/1000.0,1 if int(recipe.wire_id) == 313 else Chemistry.MAX_LINKS])
		rows.append({"title":ELEMENTS[element],"recipes":recipes,"lines":lines})
	return rows


static func matrix_cell(row: int, column: int) -> Dictionary:
	if row < 0 or row >= 8 or column < 0 or column >= 8:
		return {}
	var recipe := Chemistry.recipe(Chemistry.recipe_wire(row + 1, column + 1))
	if recipe.is_empty():
		return {}
	return {"first": ELEMENTS[row + 1], "second": ELEMENTS[column + 1], "name": String(recipe.name), "wire_id": int(recipe.wire_id), "effect": EFFECTS[int(recipe.wire_id) - 301], "formation_ms": int(recipe.formation_ms), "active_ms": int(recipe.active_ms), "decay_ms": int(recipe.decay_ms)}


static func pair_lines(row: int, column: int) -> Array[String]:
	var cell := matrix_cell(row, column)
	if cell.is_empty():
		return []
	var recipe := Chemistry.recipe(int(cell.wire_id))
	var lines: Array[String] = [
		String(cell.effect),
		"CREATE: overlap %s and %s matter from two distinct casts. Both pair orders match; each contributing cast spends its whole chemistry payload once." % [cell.first, cell.second],
		"Input matter lasts %.1f s (%s) / %.1f s (%s). Plain matter has no automatic damage or status." % [float(Chemistry.ELEMENT_LIFE_MS[row + 1]) / 1000.0, cell.first, float(Chemistry.ELEMENT_LIFE_MS[column + 1]) / 1000.0, cell.second],
		"Formation warns for %.2f s; effects are active for %.2f s; harmless decay lasts %.2f s." % [float(recipe.formation_ms) / 1000.0, float(recipe.active_ms) / 1000.0, float(recipe.decay_ms) / 1000.0],
	]
	if int(recipe.pulse_ms) > 0:
		lines.append("Cadence: %.2f s. This is the recipe's effect cadence, not another spell cost." % (float(recipe.pulse_ms) / 1000.0))
	if int(recipe.wire_id) in [301, 305, 306, 327, 329]:
		var cover_rule := "Non-Light attacks meet cover; Light paths split with shared damage. Walking is unchanged." if int(recipe.wire_id) == 329 else "Cover stops shots and rays, not walking."
		if int(recipe.wire_id) == 301:
			cover_rule = "Rampart blocks all teams' movement only while active and intact; its cardinal faces support normal paid wallrun/walljump. Warning and decay allow passage."
		lines.append("Shot-cover health: %.0f. %s" % [float(recipe.health) / 1000.0, cover_rule])
	if int(recipe.wire_id) == 301:
		var surface := Chemistry.movement_surface_policy()
		lines.append("Footprint: %.0f x %.0f px, aligned across the dominant cast direction. All sizes retain the same %.0f px wall clearance; standing inside at formation permits escape, not free re-entry." % [float(surface.length) / 1000.0, float(surface.thickness) / 1000.0, float(surface.wall_clearance) / 1000.0])
	if int(recipe.wire_id) in [313, 319, 328]:
		lines.append("Link reach: %.0f px per step; at most %d separate source(s)." % [float(recipe.length) / 1000.0, 1 if int(recipe.wire_id) == 313 else Chemistry.MAX_LINKS])
		lines.append("Links are chosen during formation, not added later; a chosen source expiring stops the linked effect.")
	lines.append("Start here contains the shared impact / Field / matter rules. Practice reset clears transient matter.")
	return lines
