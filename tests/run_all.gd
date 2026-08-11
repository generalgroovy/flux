extends SceneTree


const SUITES: Array[Script] = [
	preload("res://tests/unit/test_authoritative_session.gd"),
	preload("res://tests/integration/test_conservatory_route.gd"),
	preload("res://tests/unit/test_ability_content.gd"),
	preload("res://tests/unit/test_champion_catalog.gd"),
	preload("res://tests/unit/test_combat.gd"),
	preload("res://tests/unit/test_core.gd"),
	preload("res://tests/unit/test_environment_kit_manifest.gd"),
	preload("res://tests/unit/test_visual_candidate_manifest.gd"),
	preload("res://tests/unit/test_visual_production_contract.gd"),
	preload("res://tests/unit/test_sprite_sheet_extractor.gd"),
	preload("res://tests/unit/test_hub_definition.gd"),
	preload("res://tests/unit/test_input_router.gd"),
	preload("res://tests/unit/test_jump_presentation.gd"),
	preload("res://tests/unit/test_landing_presentation.gd"),
	preload("res://tests/unit/test_material_content.gd"),
	preload("res://tests/unit/test_material_grid.gd"),
	preload("res://tests/unit/test_player_preferences.gd"),
	preload("res://tests/unit/test_sanctum_campus_layout.gd"),
	preload("res://tests/unit/test_sanctum_station_model.gd"),
	preload("res://tests/unit/test_session_transport.gd"),
	preload("res://tests/unit/test_session_snapshot.gd"),
	preload("res://tests/unit/test_session_request_policy.gd"),
	preload("res://tests/unit/test_sanctum_runtime_kit.gd"),
	preload("res://tests/unit/test_sight_occlusion.gd"),
	preload("res://tests/unit/test_movement.gd"),
	preload("res://tests/unit/test_player_resources.gd"),
	preload("res://tests/unit/test_skeleton_animation_library.gd"),
	preload("res://tests/unit/test_visual_asset_registry.gd"),
	preload("res://tests/unit/test_wellspring_character_sprite.gd"),
	preload("res://tests/unit/test_complete_visual_catalog.gd"),
	preload("res://tests/unit/test_wellspring_visual_catalog.gd"),
	preload("res://tests/replay/test_replay.gd"),
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var failures: int = 0
	for suite_script: Script in SUITES:
		if not suite_script.can_instantiate():
			failures += 1
			print("FAIL: test suite script cannot instantiate: ", suite_script.resource_path)
			continue
		var suite: FluxTestSuite = suite_script.new()
		if suite == null:
			failures += 1
			print("FAIL: test suite constructor returned null: ", suite_script.resource_path)
			continue
		failures += suite.run()
	if failures == 0:
		print("PASS: all FLUX2 headless suites")
		quit(0)
	else:
		print("FAIL: %d assertion(s) failed" % failures)
		quit(1)
