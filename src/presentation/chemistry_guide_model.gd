class_name ChemistryGuideModel
extends RefCounted

const Chemistry = preload("res://src/sim/chemistry/element_chemistry_system.gd")
const ELEMENTS: Array[String] = ["", "Earth", "Fire", "Water", "Wind", "Ice", "Charge", "Light", "Dark"]
# Player-facing meaning, not executable rules. Names, pairs and every lifecycle
# value are read from the live kernel; this text never grants a gameplay effect.
const EFFECTS: Array[String] = [
	"Breakable shot cover. Outlast it or attack the ridge.",
	"Moving hot lane damages grounded enemies; leave its front.",
	"Shallow mud slows grounded enemies; jump out or leave the patch.",
	"Drifting dust conceals at distance and nudges grounded enemies sideways.",
	"Brittle shot cover; fracture it with pressure.",
	"Breakable grounding node absorbs a finite amount of Charge.",
	"A perpendicular plane reflects Light; other shots damage the cover.",
	"Enemy Health, Flux and Stamina recovery stop inside; leave to recover.",
	"Pulsing fire ring; the centre hole and outside are escape spaces.",
	"Expanding Steam hides distant silhouettes, then thins. Threats stay visible.",
	"A moving flame lane pulses damage; cross its narrow side.",
	"Delayed fracture damages nearby temporary cover, not worldbone.",
	"An arc needs a separate Charge deposit to connect and deal damage.",
	"Briefly reveals actors in its area; leave before the pulse.",
	"Ember concealment starts hurting enemies who linger.",
	"Directional shallow water pushes grounded enemies along its flow.",
	"A drifting mist corridor hides distant silhouettes.",
	"A growing frost strip briefly slows grounded enemies on entry.",
	"Pulsed damage follows linked Water deposits; break the connection.",
	"Water reveals entry and movement; projectile crossings leave a marker.",
	"Dark water conceals still actors but reveals movement.",
	"An annular current pushes grounded enemies sideways; its centre is safe.",
	"One moving icy pulse crosses the lane every 450 ms; pass behind it.",
	"A drifting charged node pulses damage; keep outside its radius.",
	"Light shots and rays bend 15 degrees inside the region.",
	"Drifting shadow bands alternate concealment every 300 ms.",
	"Thicker, slower-forming shot cover; break it or wait for decay.",
	"A narrow damaging circuit needs a separate linked Ice deposit.",
	"Light splits into +/-15-degree paths without multiplying damage.",
	"Entry is marked; lingering grounded enemies receive a delayed slow.",
	"A charging node releases one outward push against grounded enemies.",
	"A short bright line reveals actors on its path.",
	"A concealing patch briefly reveals actors entering or leaving.",
	"Sustained Light reveals actors in the region.",
	"The boundary marks crossing actors and projectiles; no hidden damage bonus.",
	"Darkness conceals still actors; movement reveals and lingering enemies take damage.",
]

static func entries() -> Array[Dictionary]:
	var rows: Array[Dictionary] = [{"title":"Start here", "recipes":[], "lines": [
		"CAST -> LEAVE MATTER -> COMBINE -> COUNTER",
		"Use the Spell Loom to assign any first-eight element on any champion. Choose Bolt, Burst, Spray, Beam or Field; all attacks still cost Flux.",
		"Aim at the intended endpoint. Projectiles may end earlier on a target or cover. The mouse supplies a position; controller aim uses a direction and spell range.",
		"Terminal matter remains for 2-5 seconds, by element. It is separate from a spell's own Field duration. Put a second distinct cast in the same nearby space to form a pair.",
		"The two sources are consumed once. A reaction has a visible formation, active window, then decay. Reactions do not recursively create more reactions.",
		"Choose an element row for its eight-pair table and effect details. Both orders produce the same recipe, including same-element pairs: 36 unique results total.",
		"Worldbone stays solid. Close silhouettes remain readable through mist; projectiles and dangerous geometry are never hidden by chemistry concealment.",
		"Matter is bounded: %d total deposits, %d per owner and %d reactions. Practice reset clears transient matter." % [Chemistry.MAX_DEPOSITS,Chemistry.MAX_OWNER_DEPOSITS,Chemistry.MAX_REACTIONS],
	]}]
	for element: int in range(1,9):
		var recipes: Array[Dictionary] = []
		var lines: Array[String] = ["%s terminal deposit: %.1f seconds. A separate cast is required for a new source." % [ELEMENTS[element],float(Chemistry.ELEMENT_LIFE_MS[element])/1000.0], "PAIR TABLE / both orders are equivalent"]
		for other: int in range(1,9):
			var recipe := Chemistry.recipe(Chemistry.recipe_wire(element,other))
			recipes.append(recipe)
			lines.append("%s + %s = %s" % [ELEMENTS[element],ELEMENTS[other],recipe.name])
		lines.append("")
		lines.append("EFFECTS / formation -> active -> decay")
		for recipe: Dictionary in recipes:
			lines.append("%s: %s" % [recipe.name,EFFECTS[int(recipe.wire_id)-301]])
			lines.append("  %.2f s -> %.2f s -> %.2f s" % [float(recipe.formation_ms)/1000.0,float(recipe.active_ms)/1000.0,float(recipe.decay_ms)/1000.0])
		rows.append({"title":ELEMENTS[element],"recipes":recipes,"lines":lines})
	return rows
