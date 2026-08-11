extends Node2D


const MAX_CATCH_UP_STEPS: int = 8
const HUB_DEFINITION_PATH: String = "res://content/maps/sanctum_hub_v1.json"
const CAMPUS_LAYOUT_PATH: String = "res://content/maps/sanctum_campus_g2_v1.json"
const ABILITY_CATALOG_PATH: String = "res://content/abilities/foundation_abilities_v1.json"
const LOADOUT_PATH: String = "res://content/loadouts/foundation_practitioner_v1.json"
const MATERIAL_CATALOG_PATH: String = "res://content/materials/foundation_materials_v1.json"
const MATERIAL_YARD_PATH: String = "res://content/maps/sanctum_material_yard_v1.json"
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
const POV_MASK_COLOR := Color("090d0be8")
const POV_EDGE_COLOR := Color("6f8c72a8")

var world: SimWorld
var input_router: InputRouter
var hub_definition: HubDefinition
var campus_layout: SanctumCampusLayout
var campus_renderer: SanctumCampusRenderer
var ability_catalog: AbilityCatalog
var loadout: LoadoutDefinition
var material_registry: MaterialRegistry
var material_yard: MaterialYardDefinition
var material_grid: MaterialGrid
var material_preview_texture: ImageTexture
var player_preferences: PlayerPreferences
var player_sprite: WellspringCharacterSprite
var tick_rate: int = 120
var accumulator_seconds: float = 0.0
var previous_position := Vector2.ZERO
var current_position := Vector2.ZERO
var dropped_time_seconds: float = 0.0
var show_debug_overlay: bool = false
var capture_pointer_world := Vector2i(-1, -1)


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	player_preferences = PlayerPreferences.new()
	var preferences_existed: bool = FileAccess.file_exists(PlayerPreferences.DEFAULT_PATH)
	if not player_preferences.load_from_file():
		push_warning("%s; using safe defaults" % player_preferences.last_error)
		player_preferences.reset_to_defaults()
	if not preferences_existed and not player_preferences.save_to_file():
		push_warning(player_preferences.last_error)
	_apply_preference_overrides()
	_load_player_sprite_candidate()
	hub_definition = HubDefinition.new()
	if not hub_definition.load_from_file(HUB_DEFINITION_PATH):
		push_error(hub_definition.last_error)
		get_tree().quit(1)
		return
	campus_layout = SanctumCampusLayout.new()
	if not campus_layout.load_from_file(CAMPUS_LAYOUT_PATH):
		push_error(campus_layout.last_error)
		get_tree().quit(1)
		return
	campus_renderer = SanctumCampusRenderer.new()
	capture_pointer_world = _requested_capture_pointer()
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
	material_registry = MaterialRegistry.new()
	if not material_registry.load_from_file(MATERIAL_CATALOG_PATH):
		push_error(material_registry.last_error)
		get_tree().quit(1)
		return
	material_yard = MaterialYardDefinition.new()
	if not material_yard.load_from_file(MATERIAL_YARD_PATH, material_registry):
		push_error(material_yard.last_error)
		get_tree().quit(1)
		return
	tick_rate = _requested_tick_rate()
	if not _start_match(tick_rate):
		get_tree().quit(1)
		return
	print(
		"FLUX2 bootstrap: %d Hz, protocol %d, controls %s, POV %s/%d/%d, Sanctum districts %d, travel nodes %d, campus %s, ability catalog %s, build %d/13, materials %s, yard %s"
		% [
			tick_rate,
			SimConfig.PROTOCOL_VERSION,
			player_preferences.movement_reference,
			player_preferences.pov_mode,
			player_preferences.pov_angle_degrees,
			player_preferences.pov_range,
			hub_definition.districts_by_id.size(),
			hub_definition.travel_nodes_by_id.size(),
			campus_layout.content_hash.left(12),
			ability_catalog.content_hash.left(12),
			loadout.active_points,
			material_registry.content_hash.left(12),
			material_yard.content_hash.left(12),
		]
	)
	set_process(true)
	queue_redraw()


func _exit_tree() -> void:
	_clear_player_sprite_candidate()


func _process(delta: float) -> void:
	_handle_preference_actions()
	if Input.is_action_just_pressed(&"toggle_debug_overlay"):
		show_debug_overlay = not show_debug_overlay
	if Input.is_action_just_pressed(&"reset_match"):
		if not _start_match(tick_rate):
			set_process(false)
			return
	if Input.is_action_just_pressed(&"toggle_tick_rate"):
		if not _start_match(60 if tick_rate == 120 else 120):
			set_process(false)
			return

	var fixed_delta: float = 1.0 / float(tick_rate)
	accumulator_seconds += minf(delta, 0.1)
	var steps: int = 0
	while accumulator_seconds >= fixed_delta and steps < MAX_CATCH_UP_STEPS:
		previous_position = current_position
		var pointer_world_position := Vector2(capture_pointer_world) if capture_pointer_world.x >= 0 else get_viewport().get_mouse_position() + _camera_origin(current_position)
		var command: SimCommand = input_router.sample(
			world.tick,
			current_position,
			pointer_world_position,
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
	var alpha: float = clampf(accumulator_seconds * float(tick_rate), 0.0, 1.0)
	var rendered_position: Vector2 = previous_position.lerp(current_position, alpha)
	var camera_origin: Vector2 = _camera_origin(rendered_position)
	draw_set_transform(-camera_origin)
	campus_renderer.draw(self, campus_layout, world.tick)
	if show_debug_overlay:
		for obstacle: CollisionWorld.Obstacle in world.collision.obstacles:
			var rectangle := Rect2(
				Vector2(float(obstacle.minimum_x) / 1000.0, float(obstacle.minimum_y) / 1000.0),
				Vector2(float(obstacle.maximum_x - obstacle.minimum_x) / 1000.0, float(obstacle.maximum_y - obstacle.minimum_y) / 1000.0),
			)
			draw_rect(rectangle, Color(BRASS_COLOR if obstacle.vaultable else ATTUNEMENT_COLOR, 0.18), true)
			draw_rect(rectangle, BRASS_COLOR if obstacle.vaultable else ATTUNEMENT_COLOR, false, 2.0)
	for projectile: ProjectileState in world.projectiles:
		var projectile_position := Vector2(float(projectile.position_x) / 1000.0, float(projectile.position_y) / 1000.0)
		var projectile_color: Color = ATTUNEMENT_COLOR if projectile.source_wire_id == CombatTuning.PRIMARY_WIRE_ID else FLUX_COLOR
		draw_circle(projectile_position, float(projectile.radius) / 1000.0 + 7.0, Color(projectile_color, 0.18))
		draw_circle(projectile_position, float(projectile.radius) / 1000.0, projectile_color)
	var state: PlayerState = world.player()
	var presentation := JumpPresentation.sample(state, world.config, alpha, player_preferences.reduced_motion)
	var player_radius: float = float(state.radius) / 1000.0
	var shadow_center := rendered_position + Vector2(0.0, player_radius * 0.58)
	draw_set_transform(
		shadow_center - camera_origin,
		0.0,
		Vector2(player_radius * presentation.shadow_scale.x, player_radius * presentation.shadow_scale.y),
	)
	draw_circle(Vector2.ZERO, 1.0, Color(FOREST_SHADOW_COLOR, presentation.shadow_opacity))
	draw_set_transform(-camera_origin)
	var body_position := rendered_position + Vector2(0.0, -float(presentation.body_lift_pixels))
	var sprite_drawn: bool = false
	if player_sprite != null:
		if player_sprite.sync_from_player(state, world.config, world.tick, alpha):
			var sprite_anchor := shadow_center + Vector2(0.0, -float(presentation.body_lift_pixels))
			draw_texture_rect_region(
				player_sprite.texture,
				WellspringCharacterSprite.destination_rect(sprite_anchor),
				player_sprite.region_rect,
			)
			sprite_drawn = true
		else:
			push_warning("Oh Tipi presentation candidate disabled: %s" % player_sprite.last_error)
			_clear_player_sprite_candidate()
	if not sprite_drawn:
		draw_circle(body_position, player_radius + 5.0, Color(ATTUNEMENT_COLOR, 0.18))
		draw_circle(body_position, player_radius, PLAYER_COLOR)
		draw_arc(body_position, player_radius + 2.0, 0.0, TAU, 24, PARCHMENT_COLOR, 2.0)
	draw_line(body_position, body_position + Vector2(state.aim_x, state.aim_y) * 0.032, Color.WHITE, 3.0)
	draw_set_transform(Vector2.ZERO)
	var rendered_screen_position: Vector2 = rendered_position - camera_origin
	_draw_pov_mask(rendered_screen_position, Vector2(state.aim_x, state.aim_y), camera_origin)
	draw_rect(Rect2(16, 14, 1248, 96), PANEL_COLOR, true)
	draw_rect(Rect2(16, 14, 1248, 96), BRASS_COLOR.darkened(0.3), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(32, 42), "THE WELLSPRING · BUILD %d/13" % loadout.active_points, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 22, PARCHMENT_COLOR)
	var movement_name: String = String(PlayerState.MovementMode.keys()[state.movement_mode]).replace("_", " ")
	draw_string(ThemeDB.fallback_font, Vector2(400, 40), "%s · %s" % [movement_name, state.last_event.to_upper()], HORIZONTAL_ALIGNMENT_RIGHT, 280.0, 13, ATTUNEMENT_COLOR)
	_draw_resource_bar(Rect2(700, 24, 168, 20), "HEALTH", state.health, PlayerTuning.HEALTH_MAXIMUM, Color("d9634f"))
	_draw_resource_bar(Rect2(884, 24, 168, 20), "FLUX", state.flux, PlayerTuning.FLUX_MAXIMUM, FLUX_COLOR)
	_draw_resource_bar(Rect2(1068, 24, 168, 20), "STAMINA", state.stamina, MovementTuning.STAMINA_MAXIMUM, ATTUNEMENT_COLOR)
	draw_string(ThemeDB.fallback_font, Vector2(32, 70), "WASD MOVE · SHIFT SPRINT · CTRL/C SLIDE · SPACE JUMP · V VAULT/AIR TURN", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, PALE_STONE_COLOR)
	var view_description := "FULL" if player_preferences.pov_mode == PlayerPreferences.POV_FULL else "CONE %d°/%d" % [player_preferences.pov_angle_degrees, player_preferences.pov_range]
	draw_string(
		ThemeDB.fallback_font,
		Vector2(32, 96),
		"F1 DEBUG · F6 RATE · F7 MOVE %s · F8 VIEW %s · F9 ANGLE ±15° · F10 RANGE ±80 (Shift reduces)"
		% [player_preferences.movement_reference.to_upper(), view_description],
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		13,
		ATTUNEMENT_COLOR,
	)
	if show_debug_overlay and dropped_time_seconds > 0.0:
		draw_string(ThemeDB.fallback_font, Vector2(32, 132), "BOUNDED CATCH-UP DROPPED %.3fs" % dropped_time_seconds, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, FIRE_COLOR)
	if show_debug_overlay:
		_draw_material_yard_preview()


func _draw_resource_bar(rectangle: Rect2, label: String, value: int, maximum: int, color: Color) -> void:
	var ratio: float = clampf(float(value) / float(maximum), 0.0, 1.0)
	draw_rect(rectangle, Color(FOREST_SHADOW_COLOR, 0.92), true)
	draw_rect(Rect2(rectangle.position + Vector2(2, 2), Vector2((rectangle.size.x - 4.0) * ratio, rectangle.size.y - 4.0)), color, true)
	draw_rect(rectangle, Color(PARCHMENT_COLOR, 0.65), false, 1.0)
	draw_string(ThemeDB.fallback_font, rectangle.position + Vector2(7, 15), "%s %d" % [label, value / 1000], HORIZONTAL_ALIGNMENT_LEFT, rectangle.size.x - 12.0, 12, Color.WHITE)


func _draw_pov_mask(origin: Vector2, aim: Vector2, camera_origin: Vector2) -> void:
	if player_preferences.pov_mode != PlayerPreferences.POV_CONE:
		return
	var sight_range: float = float(player_preferences.pov_range)
	var viewport_size: Vector2 = get_viewport_rect().size
	var outer_radius: float = maxf(viewport_size.x, viewport_size.y) * 2.25
	var segment_count: int = 96
	for segment: int in range(segment_count):
		var angle_a: float = TAU * float(segment) / float(segment_count)
		var angle_b: float = TAU * float(segment + 1) / float(segment_count)
		_draw_mask_quad(origin, sight_range, outer_radius, angle_a, angle_b)

	var visible_radians: float = deg_to_rad(float(player_preferences.pov_angle_degrees))
	var aim_angle: float = aim.angle() if aim.length_squared() > 0.01 else 0.0
	var half_visible: float = visible_radians * 0.5
	if player_preferences.pov_angle_degrees < PlayerPreferences.MAX_POV_ANGLE_DEGREES:
		var hidden_span: float = TAU - visible_radians
		var hidden_segments: int = maxi(1, ceili(float(segment_count) * hidden_span / TAU))
		var hidden_start: float = aim_angle + half_visible
		var player_safe_radius: float = 30.0
		for segment: int in range(hidden_segments):
			var angle_a: float = hidden_start + hidden_span * float(segment) / float(hidden_segments)
			var angle_b: float = hidden_start + hidden_span * float(segment + 1) / float(hidden_segments)
			_draw_mask_quad(origin, player_safe_radius, sight_range, angle_a, angle_b)
		draw_line(origin + Vector2.from_angle(aim_angle - half_visible) * player_safe_radius, origin + Vector2.from_angle(aim_angle - half_visible) * sight_range, POV_EDGE_COLOR, 1.5)
		draw_line(origin + Vector2.from_angle(aim_angle + half_visible) * player_safe_radius, origin + Vector2.from_angle(aim_angle + half_visible) * sight_range, POV_EDGE_COLOR, 1.5)
	_draw_building_occlusion_shadows(origin, camera_origin, outer_radius)
	draw_arc(origin, sight_range, aim_angle - half_visible, aim_angle + half_visible, maxi(12, ceili(48.0 * visible_radians / TAU)), POV_EDGE_COLOR, 1.5)


func _draw_building_occlusion_shadows(origin: Vector2, camera_origin: Vector2, outer_distance: float) -> void:
	for building_value: Variant in campus_layout.data.get("buildings", []):
		var building: Dictionary = building_value
		if String(building.get("occlusion_policy", "")) != "los_cutaway":
			continue
		var world_bounds := SanctumCampusLayout._parse_bounds(building.get("bounds", []))
		var screen_bounds := Rect2(Vector2(world_bounds.position) - camera_origin, Vector2(world_bounds.size))
		var shadow := SightOcclusion.shadow_polygon(origin, screen_bounds, outer_distance)
		if shadow.size() != 4:
			continue
		draw_colored_polygon(shadow, POV_MASK_COLOR)
		draw_line(shadow[0], shadow[1], POV_EDGE_COLOR, 1.0)
		draw_line(shadow[3], shadow[2], POV_EDGE_COLOR, 1.0)


func _draw_mask_quad(origin: Vector2, inner_radius: float, outer_radius: float, angle_a: float, angle_b: float) -> void:
	var points := PackedVector2Array([
		origin + Vector2.from_angle(angle_a) * inner_radius,
		origin + Vector2.from_angle(angle_a) * outer_radius,
		origin + Vector2.from_angle(angle_b) * outer_radius,
		origin + Vector2.from_angle(angle_b) * inner_radius,
	])
	draw_colored_polygon(points, POV_MASK_COLOR)


func _draw_material_yard_preview() -> void:
	if material_preview_texture == null or material_grid == null:
		return
	var panel := Rect2(1082, 492, 174, 194)
	draw_rect(panel, PANEL_COLOR, true)
	draw_rect(panel, BRASS_COLOR.darkened(0.25), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(1094, 515), "MATERIAL YARD F1", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, PARCHMENT_COLOR)
	draw_texture_rect(material_preview_texture, Rect2(1105, 526, 128, 128), false)
	draw_rect(Rect2(1105, 526, 128, 128), PALE_STONE_COLOR.darkened(0.2), false, 2.0)
	draw_string(
		ThemeDB.fallback_font,
		Vector2(1094, 675),
		"SEED %s · WB %s" % [material_grid.seed_state_hash.left(6), material_grid.seed_worldbone_hash.left(6)],
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		11,
		ATTUNEMENT_COLOR,
	)


func _start_match(requested_tick_rate: int) -> bool:
	tick_rate = requested_tick_rate
	world = SimWorld.new(
		tick_rate,
		8675309,
		campus_layout.build_collision_world(),
		String(campus_layout.data.get("id", "")),
		campus_layout.content_hash,
	)
	var player_state: PlayerState = world.player()
	player_state.position_x = campus_layout.spawn.x * SimConfig.FIXED_SCALE
	player_state.position_y = campus_layout.spawn.y * SimConfig.FIXED_SCALE
	material_grid = MaterialGrid.new()
	if not material_grid.initialize(material_yard, material_registry, world.config):
		push_error(material_grid.last_error)
		return false
	_refresh_material_preview()
	input_router = InputRouter.new(1)
	if not input_router.configure_movement_reference(player_preferences.movement_reference):
		push_error("Invalid movement reference reached match startup")
		return false
	if not input_router.configure_keyboard_bindings(player_preferences.keyboard_bindings):
		push_error("Invalid keyboard bindings reached match startup")
		return false
	accumulator_seconds = 0.0
	dropped_time_seconds = 0.0
	current_position = _player_position()
	previous_position = current_position
	print("FLUX2 match initialized at %d Hz" % tick_rate)
	return true


func _refresh_material_preview() -> void:
	var image := Image.create(material_grid.width, material_grid.height, false, Image.FORMAT_RGBA8)
	for cell_y: int in range(material_grid.height):
		for cell_x: int in range(material_grid.width):
			var cell_index := cell_y * material_grid.width + cell_x
			var material_id := material_registry.material_id(material_grid.material_wire_ids[cell_index])
			var color := _material_color(material_id)
			var charge_ratio := float(material_grid.charges[cell_index]) / float(SimConfig.FIXED_SCALE)
			if charge_ratio > 0.0:
				color = color.lerp(ATTUNEMENT_COLOR, charge_ratio * 0.7)
			image.set_pixel(cell_x, cell_y, color)
	material_preview_texture = ImageTexture.create_from_image(image)


func _load_player_sprite_candidate() -> void:
	_clear_player_sprite_candidate()
	player_sprite = WellspringCharacterSprite.new()
	player_sprite.source_kind = "champion"
	player_sprite.source_id = "oh_tipi"
	player_sprite.playing = false
	if not player_sprite.load_source():
		push_warning("Oh Tipi presentation candidate unavailable: %s; using procedural fallback" % player_sprite.last_error)
		_clear_player_sprite_candidate()


func _clear_player_sprite_candidate() -> void:
	if player_sprite == null:
		return
	player_sprite.texture = null
	player_sprite.free()
	player_sprite = null


func _material_color(material_id: String) -> Color:
	match material_id:
		"worldbone":
			return WORLDBONE_COLOR
		"stone":
			return PALE_STONE_COLOR.darkened(0.28)
		"brick":
			return Color("8f5745")
		"wood":
			return TIMBER_COLOR
		"water":
			return WATER_HIGHLIGHT_COLOR
		"oil":
			return Color("342f42")
		"fire":
			return FIRE_COLOR
		"steam":
			return Color("b8c8c6")
		"ice":
			return Color("9bc7d9")
		"rubble":
			return Color("685e54")
		_:
			return Color("151711")


func _requested_tick_rate() -> int:
	var configured: int = int(ProjectSettings.get_setting("flux/simulation/default_tick_rate", 120))
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--tick-rate="):
			configured = argument.trim_prefix("--tick-rate=").to_int()
	if not SimConfig.is_supported_tick_rate(configured):
		push_warning("Unsupported tick rate %d; falling back to 120" % configured)
		return 120
	return configured


func _requested_capture_pointer() -> Vector2i:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-pointer="):
			var parsed := parse_capture_pointer(argument, campus_layout.canvas_size)
			if parsed.x < 0:
				push_warning("Invalid capture pointer; expected --capture-pointer=X,Y inside the campus")
			return parsed
	return Vector2i(-1, -1)


static func parse_capture_pointer(argument: String, canvas_size: Vector2i) -> Vector2i:
	if not argument.begins_with("--capture-pointer="):
		return Vector2i(-1, -1)
	var components := argument.trim_prefix("--capture-pointer=").split(",", false)
	if components.size() != 2 or not components[0].is_valid_int() or not components[1].is_valid_int():
		return Vector2i(-1, -1)
	var point := Vector2i(components[0].to_int(), components[1].to_int())
	if point.x < 0 or point.y < 0 or point.x >= canvas_size.x or point.y >= canvas_size.y:
		return Vector2i(-1, -1)
	return point


func _apply_preference_overrides() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--movement-reference="):
			var requested_reference: String = argument.trim_prefix("--movement-reference=")
			if not player_preferences.apply_control_preset(requested_reference):
				push_warning(player_preferences.last_error)
		elif argument.begins_with("--pov-mode="):
			var requested_mode: String = argument.trim_prefix("--pov-mode=")
			if not player_preferences.set_pov_mode(requested_mode):
				push_warning(player_preferences.last_error)
		elif argument.begins_with("--pov-angle="):
			var angle_text: String = argument.trim_prefix("--pov-angle=")
			if angle_text.is_valid_int():
				player_preferences.set_pov_angle_degrees(angle_text.to_int())
			else:
				push_warning("Invalid --pov-angle value: %s" % angle_text)
		elif argument.begins_with("--pov-range="):
			var range_text: String = argument.trim_prefix("--pov-range=")
			if range_text.is_valid_int():
				player_preferences.set_pov_range(range_text.to_int())
			else:
				push_warning("Invalid --pov-range value: %s" % range_text)


func _handle_preference_actions() -> void:
	var changed: bool = false
	if Input.is_action_just_pressed(&"toggle_movement_reference"):
		var next_reference := PlayerPreferences.MOVEMENT_AIM_RELATIVE if player_preferences.movement_reference == PlayerPreferences.MOVEMENT_WORLD_RELATIVE else PlayerPreferences.MOVEMENT_WORLD_RELATIVE
		changed = player_preferences.apply_control_preset(next_reference)
		if changed and input_router != null:
			input_router.configure_movement_reference(next_reference)
	if Input.is_action_just_pressed(&"toggle_pov_mode"):
		var next_mode := PlayerPreferences.POV_CONE if player_preferences.pov_mode == PlayerPreferences.POV_FULL else PlayerPreferences.POV_FULL
		changed = player_preferences.set_pov_mode(next_mode) or changed
	if Input.is_action_just_pressed(&"adjust_pov_angle"):
		var angle_delta: int = -15 if Input.is_key_pressed(KEY_SHIFT) else 15
		player_preferences.set_pov_angle_degrees(player_preferences.pov_angle_degrees + angle_delta)
		changed = true
	if Input.is_action_just_pressed(&"adjust_pov_range"):
		var range_delta: int = -80 if Input.is_key_pressed(KEY_SHIFT) else 80
		player_preferences.set_pov_range(player_preferences.pov_range + range_delta)
		changed = true
	if changed and not player_preferences.save_to_file():
		push_warning(player_preferences.last_error)


func _player_position() -> Vector2:
	var state: PlayerState = world.player()
	return Vector2(float(state.position_x) / 1000.0, float(state.position_y) / 1000.0)


func _camera_origin(focus_position: Vector2) -> Vector2:
	if campus_layout == null:
		return Vector2.ZERO
	var viewport_size := Vector2(campus_layout.viewport_size)
	var focus_screen := Vector2(viewport_size.x * 0.5, (float(campus_layout.reserved_ui_top) + viewport_size.y) * 0.5)
	var maximum_origin := Vector2(campus_layout.canvas_size - campus_layout.viewport_size)
	return Vector2(
		clampf(focus_position.x - focus_screen.x, 0.0, maximum_origin.x),
		clampf(focus_position.y - focus_screen.y, 0.0, maximum_origin.y),
	)
