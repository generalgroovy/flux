extends SceneTree


const SUITES: Array[Script] = [
	preload("res://tests/integration/test_conservatory_route.gd"),
	preload("res://tests/unit/test_ability_content.gd"),
	preload("res://tests/unit/test_combat.gd"),
	preload("res://tests/unit/test_core.gd"),
	preload("res://tests/unit/test_hub_definition.gd"),
	preload("res://tests/unit/test_input_router.gd"),
	preload("res://tests/unit/test_material_content.gd"),
	preload("res://tests/unit/test_material_grid.gd"),
	preload("res://tests/unit/test_player_preferences.gd"),
	preload("res://tests/unit/test_movement.gd"),
	preload("res://tests/unit/test_player_resources.gd"),
	preload("res://tests/replay/test_replay.gd"),
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var failures: int = 0
	for suite_script: Script in SUITES:
		var suite: FluxTestSuite = suite_script.new()
		failures += suite.run()
	if failures == 0:
		print("PASS: all FLUX2 headless suites")
		quit(0)
	else:
		print("FAIL: %d assertion(s) failed" % failures)
		quit(1)
