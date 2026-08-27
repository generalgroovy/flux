extends FluxTestSuite


func run() -> int:
	_test_repository_recipes()
	_test_semantic_states()
	_test_semantic_aliases_fail_closed()
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
	equal(presenter.atlas_hash, "1bea3c7f8d35b331801a81cc63f54388671ec0df658ec8a16a18393ed6866680", "reviewed cardinal movement runtime atlas hash is pinned")
	equal(presenter.cardinal_animation_contract.get("directions", []), ["south", "east", "north", "west"], "foundation animation contract covers four cardinal directions")
	equal(presenter.cardinal_animation_contract.get("states", []), ["grounded", "jump", "cast", "hit", "walk", "sprint", "slide", "roll"], "foundation animation contract covers core and movement actions")
	equal(presenter.semantic_state_aliases.size(), CartoonChampionPresenter.EXPECTED_SEMANTIC_ACTIONS.size(), "every authoritative semantic action has an explicit atlas alias")
	for champion_id: String in ["oh_tipi", "s_wayne"]:
		check(presenter.can_present(champion_id), "%s has a promoted cartoon recipe" % champion_id)
		var recipe := presenter.recipe(champion_id)
		var height := int(recipe.get("height", 0))
		var ratio := float(recipe.get("head_ratio", 0.0))
		check(height >= 44 and height <= 68, "%s stays inside gameplay height" % champion_id)
		check(ratio >= 0.40 and ratio <= 0.45, "%s keeps the compact cartoon head ratio" % champion_id)
		check((recipe.get("affinities", []) as Array).size() in [2, 3], "%s exposes only a bounded aura palette" % champion_id)
		equal(String(recipe.get("casting_origin", "")), "hands", "%s casts visibly through hands" % champion_id)
		equal(String(recipe.get("equipment", "")), "body_clothing_only", "%s keeps body and clothing separate from effects" % champion_id)
		check(String(recipe.get("body_type", "")) in ["small", "middle", "large"], "%s uses one of three body types" % champion_id)
		check(int(recipe.get("atlas_row", -1)) in [0, 1], "%s uses a data-driven foundation atlas row" % champion_id)
		check("staff" not in String(recipe.get("equipment", "")).to_lower(), "%s has no staff casting focus" % champion_id)
		equal(String(recipe.get("silhouette_features", [])[-1]), "open_empty_hands", "%s has empty hands in the body recipe" % champion_id)
	equal(CartoonChampionPresenter.body_type_render_scale("small"), 0.90, "small body uses the bounded compact render scale")
	equal(CartoonChampionPresenter.body_type_render_scale("middle"), 1.0, "middle body uses the neutral render scale")
	equal(CartoonChampionPresenter.body_type_render_scale("large"), 1.10, "large body uses the bounded readable render scale")
	equal(CartoonChampionPresenter.body_type_render_scale("legacy"), 1.0, "unknown body types fail safe to the neutral render scale")
	equal(CartoonChampionPresenter.hand_cast_origin(Vector2.ZERO, Vector2.RIGHT), Vector2(4.0, -34.0), "casts originate from the authored forward hand lane")
	equal(CartoonChampionPresenter.hand_cast_origin(Vector2(10.0, 6.0), Vector2.ZERO), Vector2(17.0, -17.0), "zero aim uses a deterministic down-facing hand lane")
	check(not presenter.can_present("unreviewed"), "unreviewed champion fails closed")
	var state := PlayerState.new()
	state.facing_x = 0
	state.facing_y = 1000
	equal(presenter.source_region("oh_tipi", state), Rect2(0, 0, 96, 96), "Oh Tipi south grounded selects the first cell")
	state.facing_x = -1000
	state.facing_y = 0
	equal(presenter.source_region("oh_tipi", state), Rect2(288, 0, 96, 96), "Oh Tipi west grounded selects dedicated west art")
	state.pending_cast_wire_id = 1
	equal(presenter.source_region("s_wayne", state), Rect2(288, 960, 96, 96), "S. Wayne west cast selects dedicated cardinal action art")
	var cardinal_cases := [
		{"facing": Vector2i(0, 1000), "state": "south", "column": 0},
		{"facing": Vector2i(1000, 0), "state": "east", "column": 1},
		{"facing": Vector2i(0, -1000), "state": "north", "column": 2},
		{"facing": Vector2i(-1000, 0), "state": "west", "column": 3},
	]
	for case: Dictionary in cardinal_cases:
		var directional_state := PlayerState.new()
		directional_state.facing_x = int((case["facing"] as Vector2i).x)
		directional_state.facing_y = int((case["facing"] as Vector2i).y)
		var expected_x := float(case["column"]) * 96.0
		equal(presenter.source_region("oh_tipi", directional_state), Rect2(expected_x, 0, 96, 96), "grounded %s animation selects dedicated cardinal art" % case["state"])
		directional_state.pending_cast_wire_id = 1
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
