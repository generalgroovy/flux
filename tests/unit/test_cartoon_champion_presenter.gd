extends FluxTestSuite


func run() -> int:
	_test_repository_recipes()
	_test_semantic_states()
	_test_semantic_aliases_fail_closed()
	_test_diagonal_contract_fails_closed()
	_test_diagonal_evasion_contract_and_direction()
	_test_relative_locomotion_gaits()
	_test_locomotion_contact_regions()
	return finish("cartoon-champion-presenter")


func _test_repository_recipes() -> void:
	var presenter := CartoonChampionPresenter.new()
	check(not presenter.configure(null), "presenter refuses an absent visual language")
	var language := VisualLanguage.new()
	check(language.load_from_file(), "visual language loads for champion recipes")
	check(presenter.configure(language), "foundation cartoon recipes validate: %s" % presenter.last_error)
	check(presenter.atlas != null, "reviewed foundation runtime atlas loads")
	check(presenter.motion != null and presenter.motion.content_hash.length() == 64, "editable minimal-motion recipes load with champion art")
	check(presenter.content_hash.length() == 64, "champion presentation content has a stable hash")
	equal(presenter.atlas_hash, "640abbf46c2442506e12a31542c9a0ad375d32f53062e433d0787b88e920bd38", "mature-proportion three-champion eight-way action atlas hash is pinned")
	equal(String(presenter.shared_style_contract.get("reference_champion", "")), "red_baron", "Red Baron defines the shared compact material and outline grammar")
	equal(int(presenter.shared_style_contract.get("outline_radius_pixels", 0)), 1, "shared character ink remains a bounded one-pixel treatment")
	equal(presenter.body_templates.keys(), ["small", "middle", "large"], "three reusable body-size templates load in canonical order")
	equal(String((presenter.body_templates["small"] as Dictionary).get("exemplar", "")), "s_wayne", "S. Wayne defines the reusable small template")
	equal(String((presenter.body_templates["middle"] as Dictionary).get("exemplar", "")), "oh_tipi", "Oh Tipi defines the reusable middle template")
	equal(String((presenter.body_templates["large"] as Dictionary).get("exemplar", "")), "red_baron", "The Red Baron defines the reusable large template")
	equal(presenter.cardinal_animation_contract.get("directions", []), ["south", "east", "north", "west"], "foundation animation contract covers four cardinal directions")
	equal(presenter.cardinal_animation_contract.get("states", []), ["grounded", "jump", "cast", "hit", "walk", "sprint", "slide", "roll"], "foundation animation contract covers core and movement actions")
	equal(presenter.diagonal_core_contract.get("directions", []), ["south_east", "north_east", "north_west", "south_west"], "foundation diagonal core covers four intercardinals")
	equal(presenter.diagonal_core_contract.get("states", []), ["grounded", "cast", "hit"], "foundation diagonal core is explicitly state-scoped")
	equal(presenter.diagonal_locomotion_contract.get("states", []), ["walk", "sprint"], "foundation diagonal locomotion is explicitly state-scoped")
	equal(presenter.diagonal_locomotion_contract.get("gaits", []), ["idle", "forward", "backward", "strafe_left", "strafe_right"], "relative gait catalog is exact")
	equal(presenter.diagonal_evasion_contract.get("states", []), ["jump", "slide", "roll"], "foundation diagonal evasion contract covers all three evasion states")
	equal(String(presenter.diagonal_evasion_contract.get("coverage", "")), "every_foundation_champion_has_every_diagonal_evasion_cell", "every evasion state owns native diagonal art")
	equal(presenter.locomotion_phase_contract.get("states", []), ["walk", "sprint"], "walk and sprint own alternating contact phases")
	equal(presenter.semantic_state_aliases.size(), CartoonChampionPresenter.EXPECTED_SEMANTIC_ACTIONS.size(), "every authoritative semantic action has an explicit atlas alias")
	for champion_id: String in ["oh_tipi", "s_wayne", "red_baron"]:
		check(presenter.can_present(champion_id), "%s has a promoted cartoon recipe" % champion_id)
		var recipe := presenter.recipe(champion_id)
		var height := int(recipe.get("height", 0))
		var ratio := float(recipe.get("head_ratio", 0.0))
		check(height >= 44 and height <= 76, "%s stays inside gameplay height" % champion_id)
		check(ratio >= 0.24 and ratio <= 0.30, "%s keeps the mature compact ordinary-head ratio" % champion_id)
		check((recipe.get("affinities", []) as Array).size() in [2, 3], "%s exposes only a bounded aura palette" % champion_id)
		equal(String(recipe.get("casting_origin", "")), "hands", "%s casts visibly through hands" % champion_id)
		equal(String(recipe.get("equipment", "")), "body_clothing_only", "%s keeps body and clothing separate from effects" % champion_id)
		check(String(recipe.get("body_type", "")) in ["small", "middle", "large"], "%s uses one of three body types" % champion_id)
		check(int(recipe.get("atlas_row", -1)) in [0, 1, 2], "%s uses a data-driven foundation atlas row" % champion_id)
		check("staff" not in String(recipe.get("equipment", "")).to_lower(), "%s has no staff casting focus" % champion_id)
		equal(String(recipe.get("silhouette_features", [])[-1]), "open_empty_hands", "%s has empty hands in the body recipe" % champion_id)
	equal(CartoonChampionPresenter.body_type_render_scale("small"), 1.0, "small body scale is baked once into its reusable atlas template")
	equal(CartoonChampionPresenter.body_type_render_scale("middle"), 1.0, "middle body scale is baked once into its reusable atlas template")
	equal(CartoonChampionPresenter.body_type_render_scale("large"), 1.0, "large body scale is baked once into its reusable atlas template")
	equal(CartoonChampionPresenter.body_type_render_scale("legacy"), 1.0, "unknown body types fail safe to the neutral render scale")
	equal(CartoonChampionPresenter.hand_cast_origin(Vector2.ZERO, Vector2.RIGHT), Vector2(4.0, -34.0), "casts originate from the authored forward hand lane")
	equal(CartoonChampionPresenter.hand_cast_origin(Vector2(10.0, 6.0), Vector2.ZERO), Vector2(17.0, -17.0), "zero aim uses a deterministic down-facing hand lane")
	for direction_id: String in EightDirectionResolver.DIRECTION_ORDER:
		var fixed := EightDirectionResolver.fixed_vector(direction_id)
		var continuous := Vector2(fixed.x, fixed.y).normalized()
		var expected_origin := Vector2(0.0, -27.0) + continuous * 4.0 + continuous.orthogonal() * 7.0
		check(CartoonChampionPresenter.hand_cast_origin(Vector2.ZERO, continuous).is_equal_approx(expected_origin), "hand origin preserves continuous aim through %s" % direction_id)
	var arbitrary_aim := Vector2(0.83, -0.41).normalized()
	var arbitrary_origin := Vector2(0.0, -27.0) + arbitrary_aim * 4.0 + arbitrary_aim.orthogonal() * 7.0
	check(CartoonChampionPresenter.hand_cast_origin(Vector2.ZERO, arbitrary_aim).is_equal_approx(arbitrary_origin), "hand origin does not quantize continuous cast geometry")
	check(not presenter.can_present("unreviewed"), "unreviewed champion fails closed")
	var state := PlayerState.new()
	state.facing_x = 0
	state.facing_y = 1000
	equal(presenter.source_region("oh_tipi", state), Rect2(0, 0, 96, 96), "Oh Tipi south grounded selects the first cell")
	state.facing_x = -1000
	state.facing_y = 0
	equal(presenter.source_region("oh_tipi", state), Rect2(576, 0, 96, 96), "Oh Tipi west grounded selects dedicated west art")
	state.pending_cast_wire_id = 1
	state.pending_cast_aim_x = -1000
	state.pending_cast_aim_y = 0
	equal(presenter.source_region("s_wayne", state), Rect2(576, 1152, 96, 96), "S. Wayne west cast selects dedicated cardinal action art")
	state.pending_cast_wire_id = 0
	state.facing_x = 1000
	state.facing_y = 0
	equal(presenter.source_region("red_baron", state), Rect2(192, 1920, 96, 96), "The Red Baron east grounded selects the large foundation row")
	equal(String(presenter.recipe("red_baron").get("body_type", "")), "large", "The Red Baron is the first promoted large body")
	var atlas_image := presenter.atlas.get_image()
	var template_height_contract := {
		"oh_tipi": [70, 70, 70, 70, 70, 70, 54, 46, 70, 70],
		"s_wayne": [60, 60, 60, 60, 60, 60, 44, 43, 60, 60],
		"red_baron": [78, 78, 78, 78, 78, 78, 78, 78, 78, 78],
	}
	for champion_index: int in range(CartoonChampionPresenter.REQUIRED_FOUNDATION.size()):
		var champion_id: String = CartoonChampionPresenter.REQUIRED_FOUNDATION[champion_index]
		var state_heights: Array = template_height_contract[champion_id]
		for state_index: int in range(CartoonChampionPresenter.EXPECTED_ATLAS_STATES.size()):
			for direction_index: int in range(CartoonChampionPresenter.EXPECTED_DIRECTIONS.size()):
				var region := Rect2i(direction_index * 96, (champion_index * 10 + state_index) * 96, 96, 96)
				var used := atlas_image.get_region(region).get_used_rect()
				equal(used.size.y, int(state_heights[state_index]), "%s template height is direction-invariant for %s/%s" % [champion_id, CartoonChampionPresenter.EXPECTED_ATLAS_STATES[state_index], CartoonChampionPresenter.EXPECTED_DIRECTIONS[direction_index]])
	var cardinal_cases := [
		{"facing": Vector2i(0, 1000), "state": "south", "column": 0},
		{"facing": Vector2i(1000, 0), "state": "east", "column": 2},
		{"facing": Vector2i(0, -1000), "state": "north", "column": 4},
		{"facing": Vector2i(-1000, 0), "state": "west", "column": 6},
	]
	for case: Dictionary in cardinal_cases:
		var directional_state := PlayerState.new()
		directional_state.facing_x = int((case["facing"] as Vector2i).x)
		directional_state.facing_y = int((case["facing"] as Vector2i).y)
		var expected_x := float(case["column"]) * 96.0
		equal(presenter.source_region("oh_tipi", directional_state), Rect2(expected_x, 0, 96, 96), "grounded %s animation selects dedicated cardinal art" % case["state"])
		directional_state.pending_cast_wire_id = 1
		directional_state.pending_cast_aim_x = directional_state.facing_x
		directional_state.pending_cast_aim_y = directional_state.facing_y
		equal(presenter.source_region("oh_tipi", directional_state), Rect2(expected_x, 192, 96, 96), "cast animation selects dedicated %s art" % case["state"])
		directional_state.pending_cast_wire_id = 0
		directional_state.movement_mode = PlayerState.MovementMode.HOP
		directional_state.hop_ticks = 2
		equal(presenter.source_region("oh_tipi", directional_state), Rect2(expected_x, 96, 96, 96), "jump animation selects dedicated %s art" % case["state"])
		directional_state.movement_mode = PlayerState.MovementMode.LAUNCHED
		directional_state.hop_ticks = 0
		equal(presenter.source_region("oh_tipi", directional_state), Rect2(expected_x, 288, 96, 96), "hit animation selects dedicated %s art" % case["state"])
		directional_state.control_state = PlayerState.ControlState.FREE
		var movement_cases := [
			{"mode": PlayerState.MovementMode.WALK, "state": "walk", "row": 4},
			{"mode": PlayerState.MovementMode.SPRINT, "state": "sprint", "row": 5},
			{"mode": PlayerState.MovementMode.SLIDE, "state": "slide", "row": 6},
			{"mode": PlayerState.MovementMode.ROLL, "state": "roll", "row": 7},
		]
		for movement_case: Dictionary in movement_cases:
			directional_state.movement_mode = int(movement_case["mode"])
			equal(presenter.source_region("oh_tipi", directional_state), Rect2(expected_x, float(movement_case["row"]) * 96.0, 96, 96), "%s animation selects dedicated %s art" % [movement_case["state"], case["state"]])
	var diagonal_cases := [
		{"facing": Vector2i(707, 707), "state": "south_east", "column": 1},
		{"facing": Vector2i(707, -707), "state": "north_east", "column": 3},
		{"facing": Vector2i(-707, -707), "state": "north_west", "column": 5},
		{"facing": Vector2i(-707, 707), "state": "south_west", "column": 7},
	]
	for case: Dictionary in diagonal_cases:
		var diagonal_state := PlayerState.new()
		diagonal_state.facing_x = int((case["facing"] as Vector2i).x)
		diagonal_state.facing_y = int((case["facing"] as Vector2i).y)
		var expected_x := float(case["column"]) * 96.0
		equal(presenter.source_region("oh_tipi", diagonal_state), Rect2(expected_x, 0, 96, 96), "grounded %s selects promoted diagonal art" % case["state"])
		diagonal_state.pending_cast_wire_id = 1
		diagonal_state.pending_cast_aim_x = diagonal_state.facing_x
		diagonal_state.pending_cast_aim_y = diagonal_state.facing_y
		equal(presenter.source_region("oh_tipi", diagonal_state), Rect2(expected_x, 192, 96, 96), "cast %s selects promoted diagonal art" % case["state"])
		diagonal_state.pending_cast_wire_id = 0
		diagonal_state.movement_mode = PlayerState.MovementMode.LAUNCHED
		equal(presenter.source_region("oh_tipi", diagonal_state), Rect2(expected_x, 288, 96, 96), "hit %s selects promoted diagonal art" % case["state"])
		diagonal_state.movement_mode = PlayerState.MovementMode.WALK
		diagonal_state.velocity_x = int((case["facing"] as Vector2i).x)
		diagonal_state.velocity_y = int((case["facing"] as Vector2i).y)
		equal(presenter.source_region("oh_tipi", diagonal_state), Rect2(expected_x, 384, 96, 96), "walk %s selects promoted diagonal art" % case["state"])
		diagonal_state.movement_mode = PlayerState.MovementMode.SPRINT
		equal(presenter.source_region("oh_tipi", diagonal_state), Rect2(expected_x, 480, 96, 96), "sprint %s selects promoted diagonal art" % case["state"])
		diagonal_state.movement_mode = PlayerState.MovementMode.HOP
		diagonal_state.hop_ticks = 2
		equal(presenter.source_region("oh_tipi", diagonal_state), Rect2(expected_x, 96, 96, 96), "jump %s selects native diagonal art" % case["state"])
		diagonal_state.hop_ticks = 0
		diagonal_state.movement_mode = PlayerState.MovementMode.SLIDE
		equal(presenter.source_region("oh_tipi", diagonal_state), Rect2(expected_x, 576, 96, 96), "slide %s selects native diagonal art" % case["state"])
		diagonal_state.movement_mode = PlayerState.MovementMode.ROLL
		equal(presenter.source_region("oh_tipi", diagonal_state), Rect2(expected_x, 672, 96, 96), "roll %s selects native diagonal art" % case["state"])
	check(presenter.source_region("unreviewed", state).has_area() == false, "unreviewed champion has no source region")


func _test_semantic_states() -> void:
	var language := VisualLanguage.new()
	check(language.load_from_file(), "visual language loads for semantic states")
	var presenter := CartoonChampionPresenter.new()
	check(presenter.configure(language), "foundation cartoon recipes load for semantic states")
	var state := PlayerState.new()
	equal(CartoonChampionPresenter.semantic_action(state), "idle", "idle resolves to a stable semantic action")
	equal(presenter.silhouette_state(state), "grounded", "idle state uses its declared grounded alias")
	state.movement_mode = PlayerState.MovementMode.HOP
	state.hop_ticks = 2
	equal(CartoonChampionPresenter.semantic_action(state), "jump", "hop resolves to a stable semantic action")
	equal(presenter.silhouette_state(state), "jump", "airborne state uses its declared jump alias")
	state.movement_mode = PlayerState.MovementMode.IDLE
	state.hop_ticks = 0
	state.hop_mode = PlayerState.MovementMode.ROLL
	state.air_dodge_ticks = 2
	state.movement_mode = PlayerState.MovementMode.ROLL
	equal(CartoonChampionPresenter.semantic_action(state), "roll", "roll retains a distinct semantic action")
	equal(presenter.silhouette_state(state), "roll", "roll uses the dedicated compact silhouette")
	state.air_dodge_ticks = 0
	state.movement_mode = PlayerState.MovementMode.IDLE
	state.pending_cast_wire_id = 1
	equal(CartoonChampionPresenter.semantic_action(state), "cast", "pending cast resolves to cast")
	equal(presenter.silhouette_state(state), "cast", "pending cast uses cast silhouette")
	state.pending_cast_wire_id = 0
	state.control_state = PlayerState.ControlState.STUNNED
	equal(CartoonChampionPresenter.semantic_action(state), "stunned", "stun retains its semantic identity")
	equal(presenter.silhouette_state(state), "hit", "stun explicitly aliases to the hit silhouette")
	state.control_state = PlayerState.ControlState.FREE
	state.movement_mode = PlayerState.MovementMode.WALK
	equal(presenter.silhouette_state(state), "walk", "walk uses the planted contact silhouette")
	state.movement_mode = PlayerState.MovementMode.SPRINT
	equal(presenter.silhouette_state(state), "sprint", "sprint uses the directional drive silhouette")
	state.movement_mode = PlayerState.MovementMode.SLIDE
	equal(presenter.silhouette_state(state), "slide", "slide uses the dedicated low silhouette")
	state.movement_mode = PlayerState.MovementMode.WAVE_DASH
	equal(CartoonChampionPresenter.semantic_action(state), "wave_dash", "wave dash retains its semantic identity")
	equal(presenter.silhouette_state(state), "slide", "wave dash explicitly aliases to the direction-complete low body row")
	var semantic_by_mode := {
		PlayerState.MovementMode.IDLE: "idle",
		PlayerState.MovementMode.WALK: "walk",
		PlayerState.MovementMode.SPRINT: "sprint",
		PlayerState.MovementMode.HOP: "jump",
		PlayerState.MovementMode.DOUBLE_JUMP: "double_jump",
		PlayerState.MovementMode.SLIDE: "slide",
		PlayerState.MovementMode.SLIDE_JUMP: "slide_jump",
		PlayerState.MovementMode.AIR_DODGE: "air_dodge",
		PlayerState.MovementMode.WAVE_DASH: "wave_dash",
		PlayerState.MovementMode.WALL_KICK: "wall_kick",
		PlayerState.MovementMode.VAULT: "vault",
		PlayerState.MovementMode.SUPERGLIDE: "superglide",
		PlayerState.MovementMode.LAUNCHED: "launched",
		PlayerState.MovementMode.GRAPPLED: "grappled",
		PlayerState.MovementMode.CHARGING: "charging",
		PlayerState.MovementMode.STUNNED: "stunned",
		PlayerState.MovementMode.ROOTED: "rooted",
		PlayerState.MovementMode.SLOWED: "slowed",
		PlayerState.MovementMode.FAST_FALL: "fast_fall",
		PlayerState.MovementMode.WALL_SKIM: "wall_skim",
		PlayerState.MovementMode.IMPACT_RECOVERY: "impact_recovery",
		PlayerState.MovementMode.ROLL: "roll",
	}
	for movement_mode: int in semantic_by_mode:
		var mode_state := PlayerState.new()
		mode_state.movement_mode = movement_mode
		equal(CartoonChampionPresenter.semantic_action(mode_state), semantic_by_mode[movement_mode], "%s resolves through the semantic visual contract" % PlayerState.MovementMode.keys()[movement_mode])
		check(presenter.silhouette_state(mode_state) in CartoonChampionPresenter.EXPECTED_CARDINAL_STATES, "%s aliases to a promoted atlas state" % PlayerState.MovementMode.keys()[movement_mode])
	state = PlayerState.new()
	state.cast_recovery_ticks = 2
	equal(CartoonChampionPresenter.semantic_action(state), "cast_recovery", "cast recovery retains a stable semantic action")
	equal(presenter.silhouette_state(state), "cast", "cast recovery explicitly holds the readable cast silhouette")
	state.aim_x = -707
	state.aim_y = -707
	equal(presenter.source_region("oh_tipi", state), Rect2(480, 192, 96, 96), "cast recovery retains nearest-eight north-west presentation")
	state.health = 0
	equal(CartoonChampionPresenter.semantic_action(state), "defeated", "defeat overrides every non-terminal action")
	equal(presenter.silhouette_state(state), "hit", "defeat explicitly aliases to the current recovery silhouette")
	for presentation_action: String in ["attack_primary", "defend", "interact", "taunt"]:
		check(presenter.atlas_state_for_action(presentation_action) in CartoonChampionPresenter.EXPECTED_CARDINAL_STATES, "%s has an explicit reusable alias before it gains an authoritative local state" % presentation_action)
	equal(presenter.atlas_state_for_action("unowned_action"), "", "unknown presentation actions fail closed instead of guessing a pose")
	equal(CartoonChampionPresenter.cardinal_direction(1000, 10), "east", "horizontal facing stays horizontal")
	equal(CartoonChampionPresenter.cardinal_direction(-1000, 10), "west", "negative horizontal facing stays horizontal")
	equal(CartoonChampionPresenter.cardinal_direction(0, -1000), "north", "negative vertical facing reads north")
	equal(CartoonChampionPresenter.cardinal_direction(0, 1000), "south", "positive vertical facing reads south")
	equal(CartoonChampionPresenter.direction_for_state("grounded", 707, -707), "north_east", "promoted grounded state resolves north-east")
	equal(CartoonChampionPresenter.direction_for_state("cast", -707, 707), "south_west", "promoted cast resolves south-west")
	equal(CartoonChampionPresenter.direction_for_state("walk", 707, -707), "north_east", "promoted walk resolves north-east")
	equal(CartoonChampionPresenter.direction_for_state("jump", 707, -707), "north_east", "jump resolves native north-east art")
	state.movement_mode = PlayerState.MovementMode.WALK
	state.movement_speed_ratio = 1000
	state.velocity_x = MovementTuning.BASE_SPEED / 10
	var starting_response := CartoonChampionPresenter.movement_response_scale(state)
	check(starting_response > 0.0 and starting_response < 0.1, "early acceleration uses a restrained body response")
	state.velocity_x = MovementTuning.BASE_SPEED
	equal(CartoonChampionPresenter.movement_response_scale(state), 1.0, "full ordinary speed reaches the complete walk response")


func _test_semantic_aliases_fail_closed() -> void:
	var language := VisualLanguage.new()
	check(language.load_from_file(), "visual language loads for adversarial alias tests")
	var valid := CartoonChampionPresenter.new()
	check(valid.configure(language), "valid semantic aliases load before adversarial mutations")
	var mutations: Array[Dictionary] = []
	var missing: Dictionary = valid.semantic_state_aliases.duplicate(true)
	missing.erase("roll")
	mutations.append(missing)
	var extra: Dictionary = valid.semantic_state_aliases.duplicate(true)
	extra["unowned_action"] = "grounded"
	mutations.append(extra)
	var bad_target: Dictionary = valid.semantic_state_aliases.duplicate(true)
	bad_target["rooted"] = "missing_row"
	mutations.append(bad_target)
	for mutation: Dictionary in mutations:
		var presenter := CartoonChampionPresenter.new()
		check(not presenter._validate_semantic_state_aliases(mutation), "incomplete or unsafe semantic aliases fail closed")
		check(not presenter.last_error.is_empty(), "semantic alias failure is actionable")
		equal(presenter.semantic_state_aliases, {}, "failed alias validation exposes no stale mapping")


func _test_diagonal_contract_fails_closed() -> void:
	var language := VisualLanguage.new()
	check(language.load_from_file(), "visual language loads for diagonal contract tests")
	var presenter := CartoonChampionPresenter.new()
	check(presenter.configure(language), "valid diagonal contract loads before mutation")
	var contract := presenter.diagonal_core_contract.duplicate(true)
	contract["states"] = ["grounded", "cast"]
	check(not presenter._validate_diagonal_core_contract(contract), "missing diagonal core state fails closed")
	check(not presenter.last_error.is_empty(), "diagonal contract failure is actionable")
	equal(presenter.diagonal_core_contract, {}, "failed diagonal validation exposes no stale contract")
	check(presenter.configure(language), "valid diagonal contracts reload before locomotion mutation")
	var locomotion_contract := presenter.diagonal_locomotion_contract.duplicate(true)
	locomotion_contract["gaits"] = ["forward", "backward"]
	check(not presenter._validate_diagonal_locomotion_contract(locomotion_contract), "incomplete gait catalog fails closed")
	equal(presenter.diagonal_locomotion_contract, {}, "failed locomotion validation exposes no stale contract")
	check(presenter.configure(language), "valid diagonal contracts reload before evasion mutation")
	var evasion_contract := presenter.diagonal_evasion_contract.duplicate(true)
	evasion_contract["states"] = ["jump", "roll"]
	check(not presenter._validate_diagonal_evasion_contract(evasion_contract), "missing diagonal evasion state fails closed")
	equal(presenter.diagonal_evasion_contract, {}, "failed evasion validation exposes no stale contract")
	check(presenter.configure(language), "valid contracts reload before locomotion phase mutation")
	var phase_contract := presenter.locomotion_phase_contract.duplicate(true)
	phase_contract["frame_states"] = {"walk": ["walk", "walk_b"], "sprint": ["sprint"]}
	check(not presenter._validate_locomotion_phase_contract(phase_contract), "missing alternate sprint contact fails closed")
	equal(presenter.locomotion_phase_contract, {}, "failed locomotion phase validation exposes no stale contract")


func _test_diagonal_evasion_contract_and_direction() -> void:
	var state := PlayerState.new()
	var directions := [
		{"vector": Vector2i(0, 1000), "id": "south"},
		{"vector": Vector2i(707, 707), "id": "south_east"},
		{"vector": Vector2i(1000, 0), "id": "east"},
		{"vector": Vector2i(707, -707), "id": "north_east"},
		{"vector": Vector2i(0, -1000), "id": "north"},
		{"vector": Vector2i(-707, -707), "id": "north_west"},
		{"vector": Vector2i(-1000, 0), "id": "west"},
		{"vector": Vector2i(-707, 707), "id": "south_west"},
	]
	for direction: Dictionary in directions:
		state.velocity_x = int((direction["vector"] as Vector2i).x)
		state.velocity_y = int((direction["vector"] as Vector2i).y)
		equal(CartoonChampionPresenter.evasion_direction(state), direction["id"], "evasion cue follows every eight-direction travel vector")
	state.velocity_x = 0
	state.velocity_y = 0
	state.facing_x = -707
	state.facing_y = 707
	equal(CartoonChampionPresenter.evasion_direction(state), "south_west", "stationary evasion cue follows authored facing")
	state.facing_x = 0
	state.facing_y = 0
	equal(CartoonChampionPresenter.evasion_direction(state), "south", "zero-vector evasion cue fails safe to south")


func _test_relative_locomotion_gaits() -> void:
	var state := PlayerState.new()
	state.movement_mode = PlayerState.MovementMode.WALK
	state.velocity_x = 707
	state.velocity_y = 707
	state.facing_x = 707
	state.facing_y = 707
	equal(CartoonChampionPresenter.presentation_facing_vector(state, "walk"), Vector2i(707, 707), "free locomotion faces physical travel")
	equal(CartoonChampionPresenter.locomotion_gait(state), "forward", "free locomotion uses forward gait")
	state.primary_held = true
	state.aim_x = -707
	state.aim_y = -707
	equal(CartoonChampionPresenter.presentation_facing_vector(state, "walk"), Vector2i(-707, -707), "combat intent faces independent aim")
	equal(CartoonChampionPresenter.locomotion_gait(state), "backward", "opposed aim and travel select backward gait")
	state.aim_x = -707
	state.aim_y = 707
	equal(CartoonChampionPresenter.locomotion_gait(state), "strafe_left", "quarter-turn combat travel selects left strafe")
	state.aim_x = 707
	state.aim_y = -707
	equal(CartoonChampionPresenter.locomotion_gait(state), "strafe_right", "opposite quarter-turn selects right strafe")
	var backward_sample := MinimalChampionMotion.Sample.new()
	backward_sample.offset = Vector2(2.0, -2.0)
	backward_sample.scale = Vector2(1.04, 0.96)
	backward_sample.aura_scale = 1.08
	CartoonChampionPresenter._apply_relative_gait_motion(backward_sample, "backward", false)
	equal(backward_sample.offset, Vector2(-2.0, -1.44), "backward cadence reverses lateral phase and restrains bounce")
	equal(backward_sample.scale, Vector2(1.04, 0.96), "relative gait never rescales the body template")
	var left_sample := MinimalChampionMotion.Sample.new()
	var right_sample := MinimalChampionMotion.Sample.new()
	CartoonChampionPresenter._apply_relative_gait_motion(left_sample, "strafe_left", false)
	CartoonChampionPresenter._apply_relative_gait_motion(right_sample, "strafe_right", false)
	equal(left_sample.offset.x, -right_sample.offset.x, "strafe cadence mirrors its lateral weight shift")


func _test_locomotion_contact_regions() -> void:
	var language := VisualLanguage.new()
	check(language.load_from_file(), "visual language loads for contact-frame regions")
	var presenter := CartoonChampionPresenter.new()
	check(presenter.configure(language), "foundation recipes load for contact-frame regions")
	var state := PlayerState.new()
	state.movement_mode = PlayerState.MovementMode.WALK
	state.velocity_x = 707
	state.velocity_y = -707
	state.facing_x = 707
	state.facing_y = -707
	equal(presenter.source_region_for_animation_state("oh_tipi", state, "walk"), Rect2(288, 384, 96, 96), "walk contact A owns north-east art")
	equal(presenter.source_region_for_animation_state("oh_tipi", state, "walk_b"), Rect2(288, 768, 96, 96), "walk contact B owns north-east art")
	state.movement_mode = PlayerState.MovementMode.SPRINT
	equal(presenter.source_region_for_animation_state("s_wayne", state, "sprint"), Rect2(288, 1440, 96, 96), "S. Wayne sprint contact A owns north-east art")
	equal(presenter.source_region_for_animation_state("s_wayne", state, "sprint_b"), Rect2(288, 1824, 96, 96), "S. Wayne sprint contact B owns north-east art")
