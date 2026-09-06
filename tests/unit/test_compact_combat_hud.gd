extends FluxTestSuite


func run() -> int:
	_test_repository_hud()
	_test_fail_closed_contract()
	_test_recovery_and_float_status()
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
	var state := PlayerState.new()
	equal(CompactCombatHud.flux_status_label(state, 120), "FLUX", "full Flux keeps the quiet canonical label")
	state.flux -= 10_000
	state.flux_recovery_delay_ticks = 84
	equal(CompactCombatHud.flux_status_label(state, 120), "FLUX WAIT 0.7s", "combat delay is visible in the compact HUD")
	state.flux_recovery_delay_ticks = 0
	equal(CompactCombatHud.flux_status_label(state, 120), "FLUX +20/s", "active Flux recovery shows its current rate in the compact HUD")
	state.flux = 5_999
	check(not CompactCombatHud.spell_is_affordable(state, {"flux_cost": 6}), "HUD compares authored whole-Flux cost against milli-unit state")
	state.flux = 6_000
	check(CompactCombatHud.spell_is_affordable(state, {"flux_cost": 6}), "HUD affordability becomes ready at the exact milli-unit boundary")
	state = PlayerState.new()
	equal(CompactCombatHud.stamina_status_label(state, 120), "STAMINA", "neutral Stamina keeps the compact label")
	state.hop_ticks = SimConfig.new(120).milliseconds_to_ticks(MovementTuning.VARIABLE_JUMP_MINIMUM_MS) + 1
	state.air_height = 20_000
	state.air_vertical_velocity = 500_000
	state.jump_held_last_tick = true
	equal(CompactCombatHud.stamina_status_label(state, 120), "STAMINA  JUMP -80/s", "paid jump sustain is explicit without relying on color")
	state.jump_held_last_tick = false
	equal(CompactCombatHud.stamina_status_label(state, 120), "STAMINA", "tap jump does not claim a sustain drain")
	state.jump_held_last_tick = true
	state.air_vertical_velocity = -300_000
	equal(CompactCombatHud.stamina_status_label(state, 120), "STAMINA", "descent never advertises the retired timer-derived jump drain")
	state.air_vertical_velocity = 500_000
	state.air_dodge_ticks = 10
	equal(CompactCombatHud.stamina_status_label(state, 120), "STAMINA", "air dodge does not advertise jump sustain")
	state.air_dodge_ticks = 0
	state.wall_skim_ticks = 10
	equal(CompactCombatHud.stamina_status_label(state, 120), "STAMINA", "wall attachment does not advertise jump sustain")
	state.wall_skim_ticks = 0
	state.control_state = PlayerState.ControlState.STUNNED
	equal(CompactCombatHud.stamina_status_label(state, 120), "STAMINA", "forced control cannot claim optional sustain spending")
	state.control_state = PlayerState.ControlState.FREE
	state.stamina = 0
	equal(CompactCombatHud.stamina_status_label(state, 120), "STAMINA", "exhausted jump does not advertise an unaffordable drain")
	state.stamina = state.stamina_maximum
	state.air_height = 0
	state.air_vertical_velocity = 0
	state.hop_ticks = 0
	state.slide_ticks = SimConfig.new(120).milliseconds_to_ticks(MovementTuning.SLIDE_MINIMUM_MS) + 1
	state.slide_held_last_tick = true
	equal(CompactCombatHud.stamina_status_label(state, 120), "STAMINA  SLIDE -45/s", "paid slide sustain is explicit without relying on color")
	state.slide_ticks = 0
	state.movement_chain_count = 2
	state.movement_chain_reset_ticks = 20
	equal(CompactCombatHud.stamina_status_label(state, 120), "STAMINA  NEXT +20%", "active movement-chain escalation is explicit without relying on color")


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


func _test_recovery_and_float_status() -> void:
	var state := PlayerState.new()
	state.flux -= 10_000
	state.stamina -= 10_000
	state.flux_recovery_idle_ticks = 360
	state.stamina_recovery_idle_ticks = 180
	equal(CompactCombatHud.flux_status_label(state, 120), "FLUX +60/s", "Flux label displays its fully ramped independent rate")
	equal(CompactCombatHud.stamina_status_label(state, 120), "STAMINA +54/s", "Stamina label uses its own halfway-ramped rate")
	state.stamina_recovery_delay_ticks = 46
	equal(CompactCombatHud.stamina_status_label(state, 120), "STAMINA WAIT 0.4s", "Stamina spend delay is distinct from actual recovering")
	state.stamina_recovery_delay_ticks = 0
	state.air_height = 40_000
	state.hop_ticks = 25
	equal(CompactCombatHud.stamina_status_label(state, 120), "STAMINA", "quiet airborne state cannot falsely advertise active ground refill")
	state.air_floating = true
	equal(CompactCombatHud.stamina_status_label(state, 120), "STAMINA FLOAT -100/s", "paid Float drain overrides passive recovery information")
	state.air_floating = false
	equal(CompactCombatHud.stamina_status_label(state, 120), "STAMINA", "ending Float removes its paid status immediately")
	state.air_floating = true
	state.control_state = PlayerState.ControlState.STUNNED
	check(not CompactCombatHud.stamina_status_label(state, 120).contains("FLOAT"), "forced control cannot advertise an active Float")
	state.control_state = PlayerState.ControlState.FREE
	state.stamina = 0
	check(not CompactCombatHud.stamina_status_label(state, 120).contains("FLOAT"), "exhaustion cannot advertise protected Float spending")
	# Check the actual smallest resource-bar lane without changing the HUD layout.
	var labels: Array[String] = ["FLUX +150/s", "STAMINA +150/s", "STAMINA FLOAT -100/s", "STAMINA SPRINT -34/s", "STAMINA WAIT 0.4s", "STAMINA  NEXT +40%"]
	for label: String in labels:
		var rendered := "%s  792/792" % label
		var measured := ThemeDB.fallback_font.get_string_size(rendered, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
		check(measured <= 192.0, label + " fits the existing 204px resource bar without clipping")
