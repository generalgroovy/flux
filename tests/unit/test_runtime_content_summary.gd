extends FluxTestSuite


const SummaryScript = preload("res://src/app/runtime_content_summary.gd")
const BootstrapScript = preload("res://src/app/bootstrap.gd")
const CompendiumScript = preload("res://src/presentation/player_compendium.gd")


func run() -> int:
	var uninitialized = BootstrapScript.new()
	uninitialized._process(1.0 / 120.0)
	uninitialized._draw()
	uninitialized._unhandled_input(InputEventKey.new())
	check(uninitialized.world == null, "failed startup callbacks remain inert instead of cascading input/render errors")
	uninitialized.free()
	var abilities := AbilityCatalog.new()
	var champions := ChampionCatalog.new()
	var reactions := ReactionCatalog.new()
	check(SummaryScript.build(abilities, champions, reactions).is_empty(), "unloaded catalogs cannot produce a healthy summary")
	check(SummaryScript.build(null, null, null).is_empty(), "missing catalogs fail closed")
	check(abilities.load_from_file("res://content/abilities/foundation_abilities_v1.json"), "summary abilities load")
	check(champions.load_from_file("res://content/champions/foundation_champions_v1.json", abilities), "summary champions load")
	check(reactions.load_from_file("res://content/reactions/first_eight_element_reactions_v1.json"), "summary recipes load")
	var summary: Dictionary = SummaryScript.build(abilities, champions, reactions)
	equal(summary["runtime"]["simulation_hz"], 120, "summary exposes actual simulation rate")
	equal(summary["runtime"]["protocol"], SimConfig.PROTOCOL_VERSION, "summary follows protocol authority")
	equal(summary["content"]["abilities_authored"], 62, "effective authored inventory includes Heavy and Rapid matrix extensions")
	equal(summary["content"]["spells_runtime_selectable"], 57, "complete seven-family matrix and proven variant are advertised")
	equal(abilities.spell_matrix_wire_ids.size(), 56, "eight elements by seven families fill fifty-six distinct matrix cells")
	var variant_ids: Array[String] = []
	for wire_id: int in abilities.runtime_wire_ids:
		if wire_id not in abilities.spell_matrix_wire_ids:
			variant_ids.append(String(abilities.ability_ids_by_wire[wire_id]))
	equal(variant_ids, ["vector-lance"], "Vector Lance is the sole selectable variant beyond the matrix")
	equal(summary["content"]["spell_positions"], 12, "twelve positions are not twelve catalog spells")
	equal(summary["content"]["champions_playable"], 29, "all promoted named baselines are advertised without including the reserved Angel")
	equal(summary["content"]["reaction_mutation_enabled"], true, "bounded first-grade chemistry is active")
	equal(summary["content"]["reactions_defined"], 36, "all compiled definitions are counted")
	equal(SummaryScript.spell_loom_lines(summary), ["57 SPELLS / 12 POSITIONS", "29 PLAYABLE CHAMPIONS", "36 RECIPES / CHEMISTRY LIVE"], "compact player copy is honest and derived")
	var help := " ".join(CompendiumScript.spell_catalog_lines())
	check(help.contains("8 elements x 7 families = 56") and help.contains("57 selectable") and help.contains("Vector Lance"), "compendium distinguishes matrix cells from total available spells")
	check(help.contains("Bolt / Heavy / Rapid / Wave / Spray / Beam / Field"), "player help uses the actual seven-column order")
	check(help.contains("18 Flux; 18 damage in a 84 px-radius blast"), "Heavy help exposes compiled cost, terminal blast damage and radius")
	check(help.contains("configured spell-slot button") and help.contains("2 Flux per shot and 100 ms cooldown"), "Rapid help teaches held input without inventing a new fixed binding")
	check(help.contains("5 projectiles launch together") and help.contains("not a timed volley"), "Wave is the existing simultaneous pattern, not fake sequential fire")
	(summary["content"]["body_roles"] as Array).clear()
	equal(ChampionCatalog.SUPPORTED_BODY_TYPES.size(), 3, "report cannot mutate source vocabulary")
	return finish("runtime-content-summary")
