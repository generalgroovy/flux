extends Node2D


const MAX_CATCH_UP_STEPS: int = 8
const HUB_DEFINITION_PATH: String = "res://content/maps/sanctum_hub_v1.json"
const ABILITY_CATALOG_PATH: String = "res://content/abilities/foundation_abilities_v1.json"
const LOADOUT_PATH: String = "res://content/loadouts/foundation_practitioner_v1.json"
const WATER_COLOR := Color("153c4a")
const WATER_HIGHLIGHT_COLOR := Color("28677a")
const FOREST_SHADOW_COLOR := Color("17261b")
const GRASS_COLOR := Color("304b27")
const MOSS_COLOR := Color("66834a")
const PATH_COLOR := Color("8b7045")
const PALE_STONE_COLOR := Color("b6a477")
const WORLDBONE_COLOR := Color("26282a")
const TIMBER_COLOR := Color("4b3226")
const BRASS_COLOR := Color("b88438")
const ATTUNEMENT_COLOR := Color("55dbe0")
const FLUX_COLOR := Color("9b65d9")
const FIRE_COLOR := Color("e58a38")
const PARCHMENT_COLOR := Color("e2d8b2")
const PANEL_COLOR := Color("11130ee6")
const PLAYER_COLOR := ATTUNEMENT_COLOR

var world: SimWorld
var input_router: InputRouter
var hub_definition: HubDefinition
var ability_catalog: AbilityCatalog
var loadout: LoadoutDefinition
var tick_rate: int = 120
var accumulator_seconds: float = 0.0
var previous_position := Vector2.ZERO
var current_position := Vector2.ZERO
var dropped_time_seconds: float = 0.0


func _ready() -> void:
	hub_definition = HubDefinition.new()
	if not hub_definition.load_from_file(HUB_DEFINITION_PATH):
		push_error(hub_definition.last_error)
		get_tree().quit(1)
		return
	ability_catalog = AbilityCatalog.new()
	if not ability_catalog.load_from_file(ABILITY_CATALOG_PATH):
		push_error(ability_catalog.last_error)
		get_tree().quit(1)
		return
	loadout = LoadoutDefinition.new()
	if not loadout.load_from_file(LOADOUT_PATH, ability_catalog):
		push_error(loadout.last_error)
		get_tree().quit(1)
		return
	tick_rate = _requested_tick_rate()
	_start_match(tick_rate)
	print(
		"FLUX2 bootstrap: %d Hz, protocol %d, Sanctum districts %d, travel nodes %d, ability catalog %s, build %d/13"
		% [
			tick_rate,
			SimConfig.PROTOCOL_VERSION,
			hub_definition.districts_by_id.size(),
			hub_definition.travel_nodes_by_id.size(),
			ability_catalog.content_hash.left(12),
			loadout.active_points,
		]
	)
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"reset_match"):
		_start_match(tick_rate)
	if Input.is_action_just_pressed(&"toggle_tick_rate"):
		_start_match(60 if tick_rate == 120 else 120)

	var fixed_delta: float = 1.0 / float(tick_rate)
	accumulator_seconds += minf(delta, 0.1)
	var steps: int = 0
	while accumulator_seconds >= fixed_delta and steps < MAX_CATCH_UP_STEPS:
		previous_position = current_position
		var command: SimCommand = input_router.sample(
			world.tick,
			current_position,
			get_viewport().get_mouse_position(),
		)
		if not world.step([command]):
			push_error(world.last_error)
			set_process(false)
			break
		current_position = _player_position()
		accumulator_seconds -= fixed_delta
		steps += 1
	if accumulator_seconds >= fixed_delta:
		dropped_time_seconds += accumulator_seconds - fmod(accumulator_seconds, fixed_delta)
		accumulator_seconds = fmod(accumulator_seconds, fixed_delta)
	queue_redraw()


func _draw() -> void:
	_draw_sanctum_training_court()
	for obstacle: CollisionWorld.Obstacle in world.collision.obstacles:
		var rectangle := Rect2(
			Vector2(float(obstacle.minimum_x) / 1000.0, float(obstacle.minimum_y) / 1000.0),
			Vector2(float(obstacle.maximum_x - obstacle.minimum_x) / 1000.0, float(obstacle.maximum_y - obstacle.minimum_y) / 1000.0),
		)
		draw_rect(rectangle, TIMBER_COLOR if obstacle.vaultable else WORLDBONE_COLOR, true)
		draw_rect(rectangle, BRASS_COLOR if obstacle.vaultable else PALE_STONE_COLOR.darkened(0.35), false, 3.0)
	var alpha: float = clampf(accumulator_seconds * float(tick_rate), 0.0, 1.0)
	var rendered_position: Vector2 = previous_position.lerp(current_position, alpha)
	var state: PlayerState = world.player()
	draw_circle(rendered_position, float(state.radius) / 1000.0 + 5.0, Color(ATTUNEMENT_COLOR, 0.18))
	draw_circle(rendered_position, float(state.radius) / 1000.0, PLAYER_COLOR)
	draw_arc(rendered_position, float(state.radius) / 1000.0 + 2.0, 0.0, TAU, 24, PARCHMENT_COLOR, 2.0)
	draw_line(rendered_position, rendered_position + Vector2(state.aim_x, state.aim_y) * 0.032, Color.WHITE, 3.0)
	var status := "%d HZ · TICK %d · HP %.0f · ST %.0f · FX %.0f · %s" % [
		tick_rate,
		world.tick,
		float(state.health) / 1000.0,
		float(state.stamina) / 1000.0,
		float(state.flux) / 1000.0,
		state.last_event,
	]
	draw_rect(Rect2(16, 14, 1248, 76), PANEL_COLOR, true)
	draw_rect(Rect2(16, 14, 1248, 76), BRASS_COLOR.darkened(0.3), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(32, 42), "THE SANCTUM · MOVEMENT CONSERVATORY · BUILD %d/13" % loadout.active_points, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 22, PARCHMENT_COLOR)
	draw_string(ThemeDB.fallback_font, Vector2(760, 40), status, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, ATTUNEMENT_COLOR)
	draw_string(ThemeDB.fallback_font, Vector2(32, 70), "WASD MOVE · MOUSE AIM · LMB/SPACE PRIMARY INPUT · ALT SPRINT · C CHAIN · V TECHNIQUE · F6 60/120 HZ", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, PALE_STONE_COLOR)
	if dropped_time_seconds > 0.0:
		draw_string(ThemeDB.fallback_font, Vector2(32, 112), "BOUNDED CATCH-UP DROPPED %.3fs" % dropped_time_seconds, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, FIRE_COLOR)


func _draw_sanctum_training_court() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), WATER_COLOR)
	for y: int in range(118, 720, 64):
		draw_line(Vector2(0, y), Vector2(1280, y - 18), Color(WATER_HIGHLIGHT_COLOR, 0.32), 2.0)
	draw_circle(Vector2(640, 390), 340.0, FOREST_SHADOW_COLOR)
	draw_circle(Vector2(640, 390), 314.0, GRASS_COLOR)
	draw_circle(Vector2(75, 360), 110.0, FOREST_SHADOW_COLOR)
	draw_circle(Vector2(1205, 360), 110.0, FOREST_SHADOW_COLOR)

	# Ordinary routes remain wide and calm; advanced routes sit along the edges.
	draw_rect(Rect2(0, 310, 1280, 100), PATH_COLOR)
	draw_rect(Rect2(590, 88, 100, 632), PATH_COLOR)
	draw_circle(Vector2(650, 380), 188.0, PATH_COLOR)
	draw_circle(Vector2(650, 380), 138.0, GRASS_COLOR)
	draw_arc(Vector2(650, 380), 224.0, 0.0, TAU, 96, PALE_STONE_COLOR.darkened(0.18), 16.0)
	draw_arc(Vector2(650, 380), 265.0, 0.0, TAU, 96, BRASS_COLOR.darkened(0.12), 5.0)

	# A central attunement fountain establishes the hub's travel language.
	draw_circle(Vector2(650, 380), 74.0, WORLDBONE_COLOR)
	draw_circle(Vector2(650, 380), 62.0, BRASS_COLOR)
	draw_circle(Vector2(650, 380), 51.0, WATER_HIGHLIGHT_COLOR)
	draw_circle(Vector2(650, 380), 28.0, Color(ATTUNEMENT_COLOR, 0.35))
	draw_circle(Vector2(650, 380), 12.0, ATTUNEMENT_COLOR)
	draw_line(Vector2(650, 376), Vector2(650, 322), ATTUNEMENT_COLOR, 6.0)
	draw_circle(Vector2(650, 316), 9.0, Color(ATTUNEMENT_COLOR, 0.55))

	# Elemental practice basins preview chemistry without making pixels authoritative.
	var basin_colors: Array[Color] = [WATER_HIGHLIGHT_COLOR, FIRE_COLOR, Color("b8dbe8"), Color("6fa84f"), FLUX_COLOR]
	for index: int in basin_colors.size():
		var basin_position := Vector2(382 + index * 134, 588)
		draw_circle(basin_position, 27.0, WORLDBONE_COLOR)
		draw_circle(basin_position, 21.0, BRASS_COLOR.darkened(0.18))
		draw_circle(basin_position, 15.0, basin_colors[index])

	# Distributed shrines communicate that the full campus is much larger.
	for shrine_position: Vector2 in [Vector2(85, 360), Vector2(1195, 360), Vector2(650, 116), Vector2(650, 660)]:
		draw_circle(shrine_position, 22.0, Color(FLUX_COLOR, 0.18))
		draw_circle(shrine_position, 13.0, WORLDBONE_COLOR)
		draw_circle(shrine_position, 8.0, FLUX_COLOR)
		draw_arc(shrine_position, 18.0, 0.0, TAU, 16, BRASS_COLOR, 2.0)

	# Garden detail is deterministic presentation and stays outside clear lanes.
	for flower_position: Vector2 in [Vector2(290, 220), Vector2(322, 238), Vector2(1000, 232), Vector2(1034, 215), Vector2(280, 510), Vector2(1015, 515)]:
		draw_circle(flower_position, 9.0, MOSS_COLOR)
		draw_circle(flower_position + Vector2(-4, -3), 3.0, FLUX_COLOR)
		draw_circle(flower_position + Vector2(4, 2), 3.0, PARCHMENT_COLOR)


func _start_match(requested_tick_rate: int) -> void:
	tick_rate = requested_tick_rate
	world = SimWorld.new(tick_rate, 8675309)
	input_router = InputRouter.new(1)
	accumulator_seconds = 0.0
	dropped_time_seconds = 0.0
	current_position = _player_position()
	previous_position = current_position
	print("FLUX2 match initialized at %d Hz" % tick_rate)


func _requested_tick_rate() -> int:
	var configured: int = int(ProjectSettings.get_setting("flux/simulation/default_tick_rate", 120))
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--tick-rate="):
			configured = argument.trim_prefix("--tick-rate=").to_int()
	if not SimConfig.is_supported_tick_rate(configured):
		push_warning("Unsupported tick rate %d; falling back to 120" % configured)
		return 120
	return configured


func _player_position() -> Vector2:
	var state: PlayerState = world.player()
	return Vector2(float(state.position_x) / 1000.0, float(state.position_y) / 1000.0)
