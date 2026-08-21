extends FluxTestSuite


func run() -> int:
	_test_repository_hud()
	_test_fail_closed_contract()
	return finish("compact-combat-hud")


func _test_repository_hud() -> void:
	var language := VisualLanguage.new()
	check(language.load_from_file(), "visual language loads for compact HUD")
	var hud := CompactCombatHud.new()
	check(hud.configure(language), "compact HUD validates: %s" % hud.last_error)
	check(hud.content_hash.length() == 64, "compact HUD has a stable content hash")
	var layout: Dictionary = hud.data.get("layout", {})
	equal(int(layout.get("spell_cell_width", 0)) * PlayerState.SPELL_BUTTON_COUNT + int(layout.get("spell_cell_gap", 0)) * 3, 586, "HUD declares exactly four compact spell cells")
	equal(int(layout.get("panel_corner_step", 0)), language.ui_metric("corner_step"), "HUD framing follows the shared stepped-corner token")
	check(int(hud.data.get("maximum_view_coverage_percent", 0)) <= int((language.data.get("budgets", {}) as Dictionary).get("maximum_combat_hud_coverage_percent", 0)), "HUD coverage stays inside the visual budget")


func _test_fail_closed_contract() -> void:
	var language := VisualLanguage.new()
	check(language.load_from_file(), "visual language loads before compact HUD mutation")
	var source := CompactCombatHud.new()
	check(source.configure(language), "valid compact HUD loads before mutation")
	var hud := CompactCombatHud.new()
	hud.language = language
	hud.data = source.data.duplicate(true)
	(hud.data["layout"] as Dictionary)["spell_cell_width"] = 500
	check(not hud.validate(), "oversized compact HUD cell fails closed")
	check(not hud.last_error.is_empty(), "compact HUD failure is actionable")
