class_name CartoonChampionPresenter
extends RefCounted


const DEFAULT_PATH := "res://content/visual/foundation_champion_visuals_v1.json"
const PixelMovement = preload("res://src/presentation/pixel_movement_effects.gd")
const EXPECTED_ID := "foundation-champion-visuals-v15-motion-facing"
const EXPECTED_AUTHORITY := "presentation only; hitboxes, movement, casts and outcomes remain authoritative elsewhere"
const REQUIRED_FOUNDATION := ["oh_tipi", "s_wayne", "red_baron"]
const ATLAS_PATH := "res://assets/sprites/champions_v3/foundation/runtime_atlas_eight_v15.png"
const PROPORTION_REFERENCE_PATH := "res://assets/concept/foundation-proportion-reference-small-to-large-v3.png"
const EXPECTED_BODY_TYPES: Array[String] = ["small", "middle", "large"]
const EXPECTED_CARDINAL_DIRECTIONS: Array[String] = ["south", "east", "north", "west"]
const EXPECTED_DIRECTIONS: Array[String] = [
	"south", "south_east", "east", "north_east",
	"north", "north_west", "west", "south_west",
]
const EXPECTED_DIAGONAL_DIRECTIONS: Array[String] = ["south_east", "north_east", "north_west", "south_west"]
const EXPECTED_DIAGONAL_CORE_STATES: Array[String] = ["grounded", "cast", "hit"]
const EXPECTED_DIAGONAL_LOCOMOTION_STATES: Array[String] = ["walk", "sprint"]
const EXPECTED_DIAGONAL_STATES: Array[String] = ["grounded", "jump", "cast", "hit", "walk", "sprint", "slide", "roll", "walk_b", "sprint_b"]
const EXPECTED_RELATIVE_GAITS: Array[String] = ["idle", "forward", "backward", "strafe_left", "strafe_right"]
const EXPECTED_DIAGONAL_EVASION_STATES: Array[String] = ["jump", "slide", "roll"]
const EXPECTED_CARDINAL_STATES: Array[String] = ["grounded", "jump", "cast", "hit", "walk", "sprint", "slide", "roll"]
const EXPECTED_ATLAS_STATES: Array[String] = ["grounded", "jump", "cast", "hit", "walk", "sprint", "slide", "roll", "walk_b", "sprint_b"]
const EXPECTED_PHASE_STATES: Array[String] = ["walk", "sprint"]
const EXPECTED_SEMANTIC_ACTIONS: Array[String] = [
	"idle", "walk", "sprint", "jump", "double_jump", "slide", "slide_jump", "air_dodge",
	"wave_dash", "wall_kick", "vault", "superglide", "launched", "grappled", "charging",
	"stunned", "rooted", "slowed", "fast_fall", "wall_skim", "impact_recovery", "roll",
	"cast", "cast_recovery", "attack_primary", "defend", "interact", "taunt", "defeated",
]
const EXPECTED_EXCLUDED_LAYERS: Array[String] = ["spell", "element", "projectile", "aura", "shadow", "environment", "equipment", "focus"]
const CELL_SIZE := Vector2(96.0, 96.0)
const PIVOT := Vector2(48.0, 84.0)
const BODY_TYPE_RENDER_SCALE := {
	"small": 1.00,
	"middle": 1.00,
	"large": 1.00,
}
const HAND_CAST_HEIGHT := 27.0
const HAND_CAST_FORWARD := 4.0
const HAND_CAST_SIDE := 7.0

var language: VisualLanguage
var champions: Dictionary = {}
var content_hash := ""
var atlas_hash := ""
var last_error := ""
var atlas: Texture2D
var motion: MinimalChampionMotion
var cardinal_animation_contract: Dictionary = {}
var diagonal_core_contract: Dictionary = {}
var diagonal_locomotion_contract: Dictionary = {}
var diagonal_evasion_contract: Dictionary = {}
var locomotion_phase_contract: Dictionary = {}
var atlas_directions: Array = []
var extension_atlases: Dictionary[String, Texture2D] = {}
var atlas_states: Array = []
var semantic_state_aliases: Dictionary = {}
var body_templates: Dictionary = {}
var shared_style_contract: Dictionary = {}
var pixel_movement := PixelMovement.new()


func configure(visual_language: VisualLanguage, path: String = DEFAULT_PATH) -> bool:
	language = visual_language
	champions.clear()
	content_hash = ""
	atlas_hash = ""
	last_error = ""
	atlas = null
	cardinal_animation_contract.clear()
	diagonal_core_contract.clear()
	diagonal_locomotion_contract.clear()
	diagonal_evasion_contract.clear()
	locomotion_phase_contract.clear()
	atlas_directions.clear()
	extension_atlases.clear()
	atlas_states.clear()
	semantic_state_aliases.clear()
	body_templates.clear()
	shared_style_contract.clear()
	motion = MinimalChampionMotion.new()
	if not motion.load_from_file():
		return _fail(motion.last_error)
	if language == null or language.ramps.is_empty():
		return _fail("Cartoon champions require the validated visual language")
	if not FileAccess.file_exists(path):
		return _fail("Cartoon champion recipes do not exist: %s" % path)
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _fail("Cartoon champion recipes cannot be opened")
	var source := file.get_as_text()
	var parsed: Variant = JSON.parse_string(source)
	if not parsed is Dictionary:
		return _fail("Cartoon champion recipe root must be an object")
	var data: Dictionary = parsed
	if int(data.get("schema_version", -1)) != 15 or String(data.get("id", "")) != EXPECTED_ID:
		return _fail("Cartoon champion recipe identity is unsupported")
	var art_camera: Dictionary = data.get("art_camera", {})
	if int(art_camera.get("elevation_degrees", 0)) != 55 or String(art_camera.get("ground_axes", "")) != "screen_cardinal":
		return _fail("Champion camera must agree with cardinal campus art")
	if String(data.get("authority", "")) != EXPECTED_AUTHORITY:
		return _fail("Cartoon champion recipes must remain presentation-only")
	if String(data.get("atlas_role", "")) != "body_and_clothing_only":
		return _fail("Cartoon champion atlas must contain body and clothing only")
	if String(data.get("front_pose", "")) != "camera_facing_symmetrical":
		return _fail("Cartoon champion front pose must face the camera symmetrically")
	if String(data.get("direction_policy", "")) != "south_front_camera_facing; south_east_front_three_quarter; east_profile; north_east_back_three_quarter; north_centered_back; north_west_back_three_quarter; west_profile; south_west_front_three_quarter":
		return _fail("Cartoon champion direction policy is unsupported")
	if data.get("excluded_layers", []) != EXPECTED_EXCLUDED_LAYERS:
		return _fail("Cartoon champion excluded-layer contract is invalid")
	if _vector2i(data.get("cell", [])) != Vector2i(96, 96) or _vector2i(data.get("pivot", [])) != Vector2i(48, 84):
		return _fail("Cartoon champion cell/pivot differs from the visual contract")
	if not _validate_body_template_contract(data.get("body_template_contract", {})):
		return false
	if not _validate_shared_style_contract(data.get("shared_style_contract", {})):
		return false
	var atlas_definition: Dictionary = data.get("atlas", {})
	if String(atlas_definition.get("path", "")) != ATLAS_PATH \
		or _vector2i(atlas_definition.get("dimensions", [])) != Vector2i(768, 2880) \
		or atlas_definition.get("champions", []) != REQUIRED_FOUNDATION \
		or atlas_definition.get("directions", []) != EXPECTED_DIRECTIONS \
		or atlas_definition.get("states", []) != EXPECTED_ATLAS_STATES \
		or String(atlas_definition.get("row_layout", "")) != "champion_major_state_minor":
		return _fail("Foundation cartoon atlas layout is unsupported")
	if not _validate_cardinal_animation_contract(data.get("cardinal_animation_contract", {})):
		return false
	if not _validate_diagonal_core_contract(data.get("diagonal_core_contract", {})):
		return false
	if not _validate_diagonal_locomotion_contract(data.get("diagonal_locomotion_contract", {})):
		return false
	if not _validate_diagonal_evasion_contract(data.get("diagonal_evasion_contract", {})):
		return false
	if not _validate_locomotion_phase_contract(data.get("locomotion_phase_contract", {})):
		return false
	if not _validate_semantic_state_aliases(data.get("semantic_state_aliases", {})):
		return false
	atlas_directions = (atlas_definition.get("directions", []) as Array).duplicate()
	atlas_states = (atlas_definition.get("states", []) as Array).duplicate()
	var expected_hash := String(atlas_definition.get("sha256", ""))
	var expected_rgba_hash := String(atlas_definition.get("imported_rgba_sha256", ""))
	if expected_hash.length() != 64 or expected_rgba_hash.length() != 64:
		return _fail("Foundation cartoon atlas hashes are invalid")
	if OS.has_feature("editor") and FileAccess.file_exists(ATLAS_PATH) and expected_hash != _sha256(ATLAS_PATH):
		return _fail("Foundation cartoon source atlas hash is invalid")
	atlas_hash = expected_hash
	champions = data.get("champions", {})
	for champion_id: String in REQUIRED_FOUNDATION:
		if not champions.has(champion_id) or not _validate_recipe(champion_id, champions[champion_id]):
			champions.clear()
			return false
	# Additional champions get bounded per-character pages instead of growing a
	# single texture beyond device limits. Base three-template IDs stay stable.
	var extension_data: Variant = data.get("extension_atlases", {})
	if not extension_data is Dictionary or (extension_data as Dictionary).size() > 21:
		return _fail("Additional champion pages require a bounded dictionary")
	var extensions: Dictionary = extension_data
	for champion_id: String in champions:
		if champion_id in REQUIRED_FOUNDATION:
			continue
		if not _validate_recipe(champion_id, champions[champion_id]) or not extensions.has(champion_id):
			return _fail("Additional champion lacks a validated recipe/page: " + champion_id)
		if not extensions[champion_id] is Dictionary:
			return _fail("Additional champion page must be an object")
		var page: Dictionary = extensions[champion_id]
		var page_path := String(page.get("path", ""))
		if not page_path.begins_with("res://assets/sprites/champions_v3/") or not ResourceLoader.exists(page_path):
			return _fail("Additional champion page path is invalid: " + champion_id)
		if OS.has_feature("editor") and FileAccess.get_sha256(page_path) != String(page.get("sha256", "")):
			return _fail("Additional champion page source hash changed: " + champion_id)
		var texture := load(page_path) as Texture2D
		if texture == null or texture.get_size() != Vector2(768, 960):
			return _fail("Additional champion page must contain ten eight-direction rows")
		var decoded_page := texture.get_image()
		decoded_page.convert(Image.FORMAT_RGBA8)
		if _bytes_sha256(decoded_page.get_data()) != String(page.get("imported_rgba_sha256", "")):
			return _fail("Additional champion decoded page hash changed: " + champion_id)
		extension_atlases[champion_id] = texture
	var atlas_resource: Resource = load(ATLAS_PATH)
	if not atlas_resource is Texture2D:
		champions.clear()
		return _fail("Foundation cartoon atlas cannot be loaded")
	atlas = atlas_resource
	if atlas.get_size() != Vector2(768.0, 2880.0):
		atlas = null
		champions.clear()
		return _fail("Foundation cartoon atlas dimensions are invalid")
	var decoded := atlas.get_image()
	if decoded == null or decoded.is_empty() or decoded.get_format() != Image.FORMAT_RGBA8 \
		or _bytes_sha256(decoded.get_data()) != expected_rgba_hash:
		atlas = null
		champions.clear()
		return _fail("Foundation cartoon decoded atlas hash is invalid")
	content_hash = source.sha256_text()
	return true


func can_present(champion_id: String) -> bool:
	return champions.has(champion_id)


func recipe(champion_id: String) -> Dictionary:
	return (champions.get(champion_id, {}) as Dictionary).duplicate(true)


func source_region(champion_id: String, state: PlayerState) -> Rect2:
	return source_region_for_animation_state(champion_id, state, silhouette_state(state) if state != null else "")


func source_region_for_animation_state(champion_id: String, state: PlayerState, animation_state: String) -> Rect2:
	if state == null or not champions.has(champion_id):
		return Rect2()
	var row := int((champions[champion_id] as Dictionary).get("atlas_row", -1))
	if row < 0 or row >= REQUIRED_FOUNDATION.size():
		return Rect2()
	var facing_state := animation_state.trim_suffix("_b")
	var facing_vector := presentation_facing_vector(state, facing_state)
	var facing := direction_for_state(animation_state, facing_vector.x, facing_vector.y)
	var state_index := atlas_states.find(animation_state)
	var direction_index := atlas_directions.find(facing)
	if state_index < 0 or direction_index < 0:
		return Rect2()
	var atlas_row := row * atlas_states.size() + state_index
	return Rect2(Vector2(float(direction_index) * CELL_SIZE.x, float(atlas_row) * CELL_SIZE.y), CELL_SIZE)


func draw(
	canvas: CanvasItem,
	state: PlayerState,
	champion_id: String,
	body_anchor: Vector2,
	presentation_tick: float,
	config: SimConfig,
	reduced_effects: bool = false,
	ground_anchor: Vector2 = Vector2.INF,
) -> bool:
	if canvas == null or state == null or not champions.has(champion_id):
		return false
	var frame := movement_frame(champion_id, state, presentation_tick, config, reduced_effects)
	if frame.is_empty():
		return false
	var definition: Dictionary = champions[champion_id]
	var anchor := body_anchor + (frame["offset"] as Vector2)
	var floor_anchor := ground_anchor if ground_anchor.is_finite() else body_anchor
	if pixel_movement.ready() and atlas != null:
		pixel_movement.draw_afterimages(canvas, state, config, texture_for_champion(champion_id), frame["source_region"], anchor, float(definition.get("height",68)), reduced_effects)
	_draw_counter_strafe_accent(canvas, state, floor_anchor, reduced_effects)
	_draw_takeoff_accent(canvas, state, floor_anchor, config, reduced_effects)
	_draw_movement_accent(canvas, state, floor_anchor, roundi(presentation_tick), reduced_effects, body_anchor, config)
	_draw_aura(canvas, definition, anchor, roundi(presentation_tick), reduced_effects, float(frame["aura_scale"]))
	if atlas == null:
		return false
	_draw_atlas_candidate(canvas, state, champion_id, String(frame["animation_state"]), anchor)
	_draw_evasion_contour(canvas, state, anchor, config, reduced_effects, float(definition.get("height", 68)))
	return true


func movement_frame(champion_id: String, state: PlayerState, presentation_tick: float, config: SimConfig, reduced_effects: bool = false) -> Dictionary:
	if state == null or config == null or not champions.has(champion_id):
		return {}
	var definition: Dictionary = champions[champion_id]
	var animation_state := silhouette_state(state)
	var motion_id := MinimalChampionMotion.motion_id(state)
	# Bare-hand cast effects remain separate. Moving casts must not freeze the
	# legs or replace an airborne/low silhouette with an upright aiming body.
	if animation_state in ["walk", "sprint"]:
		motion_id = animation_state
	elif animation_state in ["slide", "roll"]:
		motion_id = "low"
	elif animation_state == "jump":
		motion_id = "air"
	var motion_elapsed := MinimalChampionMotion.elapsed_for_state(state, motion_id, presentation_tick, config)
	# Contact pose and secondary motion share one seeded phase. Previously the
	# opposite foot could be selected while the torso was still on contact A.
	if motion_id in ["walk", "sprint"]:
		motion_elapsed += float(maxi(0, state.entity_id) * 3)
	var motion_sample := motion.sample(String(definition.get("motion_profile", "")), motion_id, motion_elapsed, reduced_effects)
	if motion_id in ["walk", "sprint"]:
		var response := movement_response_scale(state)
		motion_sample.offset *= response
		motion_sample.aura_scale = lerpf(1.0, motion_sample.aura_scale, response)
		_apply_relative_gait_motion(motion_sample, locomotion_gait(state), reduced_effects)
	# Foot plants retain their exact pivot; the between-contact motion is tiny
	# and smooth, never a scale pulse or blended directional atlas frame.
	var pose_offset := motion_sample.offset.round() if motion_id in ["cast", "hit"] else Vector2.ZERO
	if motion_id in ["walk", "sprint"]:
		pose_offset = motion.locomotion_pivot_offset(String(definition.get("motion_profile", "")), motion_id, motion_elapsed, Vector2(state.velocity_x, state.velocity_y), movement_response_scale(state), reduced_effects)
	var contact_frame := 0
	if animation_state in EXPECTED_PHASE_STATES:
		contact_frame = motion.locomotion_contact_frame(String(definition.get("motion_profile", "")), motion_id, motion_elapsed)
		if contact_frame == 1:
			animation_state += "_b"
	return {"animation_state": animation_state, "motion_id": motion_id, "contact_frame": contact_frame, "offset": pose_offset, "scale": Vector2.ONE, "aura_scale": motion_sample.aura_scale, "source_region": source_region_for_animation_state(champion_id, state, animation_state)}


func _draw_atlas_candidate(canvas: CanvasItem, state: PlayerState, champion_id: String, animation_state: String, anchor: Vector2) -> void:
	var source := source_region_for_animation_state(champion_id, state, animation_state)
	canvas.draw_texture_rect_region(texture_for_champion(champion_id), Rect2(anchor - PIVOT, CELL_SIZE), source)


func texture_for_champion(champion_id: String) -> Texture2D:
	return extension_atlases.get(champion_id, atlas)


func portrait_region(champion_id: String) -> Rect2:
	if not can_present(champion_id):
		return Rect2()
	var definition: Dictionary = champions[champion_id]
	var row := int(definition.get("atlas_row", 0)) * atlas_states.size()
	return Rect2(32, row * 96 + 83 - int(definition.get("height", 68)), 32, 32)


func silhouette_state(state: PlayerState) -> String:
	var action := semantic_action(state)
	if state != null and state.health > 0 and state.control_state in [PlayerState.ControlState.FREE, PlayerState.ControlState.SLOWED]:
		if state.is_rolling():
			return "roll"
		if state.movement_mode in [PlayerState.MovementMode.SLIDE, PlayerState.MovementMode.WAVE_DASH, PlayerState.MovementMode.WALL_SKIM]:
			return "slide"
		if state.is_airborne():
			return "jump"
		if state.velocity_x != 0 or state.velocity_y != 0:
			if state.movement_mode in [PlayerState.MovementMode.WALK, PlayerState.MovementMode.SLOWED]:
				return "walk"
			if state.movement_mode == PlayerState.MovementMode.SPRINT:
				return "sprint"
	return atlas_state_for_action(action)


func atlas_state_for_action(action_id: String) -> String:
	return String(semantic_state_aliases.get(action_id, ""))


static func semantic_action(state: PlayerState) -> String:
	if state == null:
		return "idle"
	if state.health <= 0:
		return "defeated"
	match state.control_state:
		PlayerState.ControlState.LAUNCHED:
			return "launched"
		PlayerState.ControlState.GRAPPLED:
			return "grappled"
		PlayerState.ControlState.CHARGING:
			return "charging"
		PlayerState.ControlState.STUNNED:
			return "stunned"
		PlayerState.ControlState.ROOTED:
			return "rooted"
		PlayerState.ControlState.SLOWED:
			return "slowed"
	if state.pending_cast_wire_id > 0 or state.last_event.begins_with("cast_start_"):
		return "cast"
	if state.cast_recovery_ticks > 0:
		return "cast_recovery"
	if state.is_rolling():
		return "roll"
	match state.movement_mode:
		PlayerState.MovementMode.WALK:
			return "walk"
		PlayerState.MovementMode.SPRINT:
			return "sprint"
		PlayerState.MovementMode.HOP:
			return "jump"
		PlayerState.MovementMode.DOUBLE_JUMP:
			return "double_jump"
		PlayerState.MovementMode.SLIDE:
			return "slide"
		PlayerState.MovementMode.SLIDE_JUMP:
			return "slide_jump"
		PlayerState.MovementMode.AIR_DODGE:
			return "air_dodge"
		PlayerState.MovementMode.WAVE_DASH:
			return "wave_dash"
		PlayerState.MovementMode.WALL_KICK:
			return "wall_kick"
		PlayerState.MovementMode.VAULT:
			return "vault"
		PlayerState.MovementMode.SUPERGLIDE:
			return "superglide"
		PlayerState.MovementMode.LAUNCHED:
			return "launched"
		PlayerState.MovementMode.GRAPPLED:
			return "grappled"
		PlayerState.MovementMode.CHARGING:
			return "charging"
		PlayerState.MovementMode.STUNNED:
			return "stunned"
		PlayerState.MovementMode.ROOTED:
			return "rooted"
		PlayerState.MovementMode.SLOWED:
			return "slowed"
		PlayerState.MovementMode.FAST_FALL:
			return "fast_fall"
		PlayerState.MovementMode.WALL_SKIM:
			return "wall_skim"
		PlayerState.MovementMode.IMPACT_RECOVERY:
			return "impact_recovery"
		PlayerState.MovementMode.ROLL:
			return "roll"
	if state.is_airborne():
		return "jump"
	return "idle"


static func cardinal_direction(x: int, y: int) -> String:
	return EightDirectionResolver.nearest_cardinal_id(x, y)


static func direction_for_state(state_id: String, x: int, y: int) -> String:
	if state_id in EXPECTED_DIAGONAL_STATES:
		return EightDirectionResolver.direction_id_from_vector(x, y)
	return cardinal_direction(x, y)


static func presentation_facing_vector(state: PlayerState, state_id: String = "") -> Vector2i:
	if state == null:
		return Vector2i(0, 1000)
	var resolved_state := state_id if not state_id.is_empty() else "grounded"
	if resolved_state == "cast":
		if state.pending_cast_wire_id > 0:
			return Vector2i(state.pending_cast_aim_x, state.pending_cast_aim_y)
		return Vector2i(state.aim_x, state.aim_y)
	if resolved_state in ["walk", "sprint", "slide", "roll", "jump"]:
		# Body intent follows the accepted movement input, including reversal;
		# physical coast remains legible through separate travel-facing dust.
		var intended := Vector2i(state.facing_x, state.facing_y)
		if intended != Vector2i.ZERO:
			return intended
		var travel := Vector2i(state.velocity_x, state.velocity_y)
		if travel != Vector2i.ZERO:
			return travel
	return Vector2i(state.facing_x, state.facing_y)


static func has_combat_facing_intent(state: PlayerState) -> bool:
	return state != null and (
		state.primary_held
		or state.pending_cast_wire_id > 0
		or state.cast_recovery_ticks > 0
		or state.last_event.begins_with("cast_start_")
	)


static func locomotion_gait(state: PlayerState) -> String:
	if state == null or state.movement_mode not in [PlayerState.MovementMode.WALK, PlayerState.MovementMode.SPRINT]:
		return "idle"
	var travel := Vector2i(state.velocity_x, state.velocity_y)
	if travel == Vector2i.ZERO:
		return "idle"
	var facing := presentation_facing_vector(state, "walk")
	return EightDirectionResolver.relative_gait_from_vectors(facing, travel)


static func _apply_relative_gait_motion(sample: MinimalChampionMotion.Sample, gait: String, reduced: bool) -> void:
	if sample == null or gait in ["idle", "forward"]:
		return
	var strength := 0.35 if reduced else 1.0
	match gait:
		"backward":
			sample.offset.x *= -1.0
			sample.offset.y *= lerpf(1.0, 0.72, strength)
			sample.aura_scale = lerpf(1.0, sample.aura_scale, lerpf(1.0, 0.84, strength))
		"strafe_left":
			sample.offset.x -= 0.65 * strength
		"strafe_right":
			sample.offset.x += 0.65 * strength


static func body_type_render_scale(body_type: String) -> float:
	return float(BODY_TYPE_RENDER_SCALE.get(body_type.to_lower(), 1.0))


func _validate_body_template_contract(value: Variant) -> bool:
	body_templates.clear()
	if not value is Dictionary:
		return _fail("Cartoon champion body template contract must be an object")
	var contract: Dictionary = value
	if contract.get("types", []) != EXPECTED_BODY_TYPES \
		or contract.get("template_build_order", []) != EXPECTED_BODY_TYPES \
		or String(contract.get("proportion_reference", "")) != PROPORTION_REFERENCE_PATH \
		or contract.get("ordinary_head_ratio_range", []) != [0.20, 0.23] \
		or String(contract.get("head_measurement_policy", "")) != "ordinary_cranium_excludes_hair_fins_horns_and_ancestry_crowns" \
		or String(contract.get("anatomy_reference_champion", "")) != "red_baron" \
		or _vector2i(contract.get("shared_cell", [])) != Vector2i(96, 96) \
		or _vector2i(contract.get("shared_feet_pivot", [])) != Vector2i(48, 84) \
		or contract.get("runtime_scale", []) != [1.0, 1.0]:
		return _fail("Cartoon champion body template geometry is unsupported")
	if String(contract.get("shared_collision_policy", "")) != "universal_gameplay_collision_independent_of_visual_body_type" \
		or String(contract.get("animation_policy", "")) != "pose_and_offset_only_never_rescale_body":
		return _fail("Cartoon champion size lock must remain presentation-only and invariant")
	var templates: Dictionary = contract.get("templates", {})
	var expected_exemplars := {"small": "s_wayne", "middle": "oh_tipi", "large": "red_baron"}
	var expected_heights := {"small": 58, "middle": 68, "large": 76}
	for body_type: String in EXPECTED_BODY_TYPES:
		if not templates.has(body_type) or not templates[body_type] is Dictionary:
			return _fail("Cartoon champion body template is missing: %s" % body_type)
		var template: Dictionary = templates[body_type]
		if String(template.get("exemplar", "")) != String(expected_exemplars[body_type]) \
			or int(template.get("reference_height", 0)) != int(expected_heights[body_type]) \
			or String(template.get("silhouette", "")).is_empty():
			return _fail("Cartoon champion body template is invalid: %s" % body_type)
	body_templates = templates.duplicate(true)
	return true


func _validate_shared_style_contract(value: Variant) -> bool:
	shared_style_contract.clear()
	if not value is Dictionary:
		return _fail("Cartoon champion shared style contract must be an object")
	var contract: Dictionary = value
	if String(contract.get("reference_champion", "")) != "red_baron" \
		or String(contract.get("outline_source", "")) != "shared_64_color_old_world_material_palette" \
		or int(contract.get("outline_radius_pixels", 0)) != 1 \
		or String(contract.get("outline_application", "")) != "cell_bounded_exterior_ink_without_rescale" \
		or int(contract.get("palette_budget", 0)) != 64 \
		or String(contract.get("material_language", "")) != "compact_cartoon_pixel_clusters_with_dark_ink_and_bounded_highlights" \
		or String(contract.get("identity_policy", "")) != "share rendering grammar while preserving ancestry silhouette body template clothing and palette" \
		or String(contract.get("authority", "")) != "presentation_only":
		return _fail("Cartoon champion shared style contract is unsupported")
	shared_style_contract = contract.duplicate(true)
	return true


static func hand_cast_origin(body_anchor: Vector2, aim: Vector2) -> Vector2:
	var direction := aim.normalized() if aim.length_squared() > 0.01 else Vector2.DOWN
	var side := direction.orthogonal()
	return body_anchor + Vector2(0.0, -HAND_CAST_HEIGHT) + direction * HAND_CAST_FORWARD + side * HAND_CAST_SIDE


func _draw_aura(canvas: CanvasItem, definition: Dictionary, anchor: Vector2, tick: int, reduced: bool, motion_scale: float = 1.0) -> void:
	var affinities: Array = definition.get("affinities", [])
	var count := mini(affinities.size(), 1 if reduced else 3)
	for index: int in range(count):
		var element_id := String(affinities[index])
		var color := language.element_color(element_id, "base")
		var phase := float((tick * (index + 2) + index * 17) % 90) / 90.0
		var radius := (23.0 + float(index) * 4.0 + phase * 3.0) * motion_scale
		var start := phase * TAU + float(index) * 1.9
		canvas.draw_arc(anchor + Vector2(0.0, -19.0), radius, start, start + 0.74, 7, Color(color, 0.42), 2.0)
		var spark := anchor + Vector2.from_angle(start + 0.37) * Vector2(radius, radius * 0.55) + Vector2(0.0, -19.0)
		canvas.draw_rect(Rect2(spark - Vector2(1.0, 1.0), Vector2(3.0, 3.0)), Color(language.element_color(element_id, "bright"), 0.72), true)


static func _directional_lean(state: PlayerState, motion_id: String, reduced: bool) -> Vector2:
	if motion_id not in ["walk", "sprint", "low", "air"]:
		return Vector2.ZERO
	var velocity := Vector2(float(state.velocity_x), float(state.velocity_y))
	if velocity.length_squared() < 1.0:
		return Vector2.ZERO
	var amount := 1.0 if motion_id == "walk" else (2.0 if motion_id in ["sprint", "air"] else 2.5)
	if motion_id in ["walk", "sprint"]:
		amount *= movement_response_scale(state)
	if reduced:
		amount *= 0.35
	return velocity.normalized() * amount


static func movement_response_scale(state: PlayerState) -> float:
	if state == null:
		return 0.0
	var reference_speed := float(MovementTuning.BASE_SPEED * state.movement_speed_ratio) / 1000.0
	if state.movement_mode == PlayerState.MovementMode.SPRINT:
		reference_speed *= float(MovementTuning.SPRINT_MULTIPLIER) / 1000.0
	if reference_speed <= 0.0:
		return 0.0
	var speed := Vector2(float(state.velocity_x), float(state.velocity_y)).length()
	return smoothstep(0.0, 1.0, clampf(speed / reference_speed, 0.0, 1.0))


func _draw_counter_strafe_accent(canvas: CanvasItem, state: PlayerState, ground_anchor: Vector2, reduced: bool) -> void:
	if state.is_airborne() or state.movement_mode not in [PlayerState.MovementMode.WALK, PlayerState.MovementMode.SPRINT]:
		return
	var velocity := Vector2(float(state.velocity_x), float(state.velocity_y))
	var facing := Vector2(float(state.facing_x), float(state.facing_y))
	if velocity.dot(facing) >= float(MovementTuning.COUNTER_STRAFE_DOT_THRESHOLD):
		return
	if pixel_movement.stamp(canvas, "slide_trail", ground_anchor - velocity.normalized() * 8.0, 0, reduced, velocity.angle(), 0.50):
		return
	var definition := motion.accent_by_id("counter_strafe")
	if definition.is_empty():
		return
	var color := language.ramp_color(String(definition.get("ramp", "warm_stone")), int(definition.get("index", 4)))
	var opacity := float(definition.get("opacity", 0.46)) * (0.5 if reduced else 1.0)
	var travel := velocity.normalized()
	var side := Vector2(-travel.y, travel.x)
	var mark_count := 1 if reduced else 2
	for index: int in range(mark_count):
		var sign_value := -1.0 if index == 0 else 1.0
		var heel := ground_anchor - travel * 5.0 + side * 7.0 * sign_value
		canvas.draw_line(heel, heel - travel * 9.0, Color(color, opacity), 2.0)
		canvas.draw_rect(Rect2(heel - travel * 11.0 - Vector2.ONE, Vector2(2.0, 2.0)), Color(color, opacity * 0.75), true)


func _draw_takeoff_accent(canvas: CanvasItem, state: PlayerState, ground_anchor: Vector2, config: SimConfig, reduced: bool) -> void:
	var cue := JumpPresentation.takeoff_contract(state, config, reduced)
	if not bool(cue["active"]):
		return
	var takeoff_age := maxi(0, config.milliseconds_to_ticks(MovementTuning.JUMP_INVULNERABILITY_MS) - state.jump_protection_ticks)
	if pixel_movement.stamp(canvas,"jump_takeoff",ground_anchor,takeoff_age,reduced):
		return
	var radius := float(cue["radius"])
	var opacity := float(cue["opacity"])
	var color := language.ramp_color("aged_brass", 4)
	for side: float in [-1.0, 1.0]:
		canvas.draw_arc(ground_anchor, radius, side * 0.22, side * 2.86, 12, Color(color, opacity), 1.5)
	if not reduced:
		for direction: Vector2 in [Vector2.LEFT, Vector2.RIGHT]:
			canvas.draw_line(ground_anchor + direction * (radius + 3.0), ground_anchor + direction * (radius + 6.0), Color(color, opacity * 0.7), 1.5)


static func movement_trail_contract(state: PlayerState, config: SimConfig, reduced: bool = false) -> Dictionary:
	var result := {"active": false, "body_anchored": false, "lines": [], "dust": [], "opacity": 0.0}
	if state == null or config == null or state.health <= 0:
		return result
	var dodge := state.air_dodge_ticks > 0 and not state.is_rolling()
	var slide := state.slide_ticks > 0 and not state.is_airborne()
	if not dodge and not slide:
		return result
	var direction := LandingPresentation.motion_direction(state)
	var speed := Vector2(state.velocity_x, state.velocity_y).length()
	if speed <= float(SimConfig.FIXED_SCALE):
		return result
	var side := direction.orthogonal()
	var phase := 0.0
	if dodge:
		var total := config.milliseconds_to_ticks(MovementTuning.AIR_DODGE_DURATION_MS)
		phase = clampf(1.0 - float(state.air_dodge_ticks) / float(maxi(1, total)), 0.0, 1.0)
	var length := (12.0 + (1.0 - phase) * 15.0) if dodge else clampf(speed / 25000.0, 12.0, 25.0)
	length *= 0.6 if reduced else 1.0
	var lines: Array[PackedVector2Array] = []
	var dust: Array[Vector2] = []
	for sign_value: float in [-1.0, 1.0]:
		# Flank placement keeps southward trails outside the lifted/low body,
		# instead of hiding every line behind its crisp opaque silhouette.
		var start := -direction * (10.0 if dodge else 8.0) + side * (24.0 if dodge else 22.0) * sign_value
		lines.append(PackedVector2Array([start - direction * length, start]))
		if not reduced:
			if dodge:
				lines.append(PackedVector2Array([start - direction * (length + 5.0) + side * sign_value * 4.0, start - direction * 10.0 + side * sign_value * 4.0]))
			else:
				dust.append(start - direction * (length + 3.0))
	result["active"] = true
	result["body_anchored"] = dodge
	result["lines"] = lines
	result["dust"] = dust
	result["opacity"] = (0.50 if reduced else 0.72) * (1.0 - phase * 0.42)
	return result


func _draw_movement_accent(canvas: CanvasItem, state: PlayerState, ground_anchor: Vector2, tick: int, reduced: bool, body_anchor: Vector2 = Vector2.INF, config: SimConfig = null) -> void:
	if pixel_movement.ready():
		_draw_pixel_movement_accent(canvas,state,ground_anchor,tick * 2,reduced,config)
		return
	var trail := movement_trail_contract(state, config, reduced)
	if bool(trail["active"]):
		var trail_anchor := body_anchor if bool(trail["body_anchored"]) and body_anchor.is_finite() else ground_anchor
		var trail_color := language.ramp_color("aged_brass" if bool(trail["body_anchored"]) else "warm_stone", 4)
		for line: PackedVector2Array in trail["lines"]:
			canvas.draw_polyline(_offset(line, trail_anchor), Color(trail_color, float(trail["opacity"])), 1.5)
		for dust: Vector2 in trail["dust"]:
			canvas.draw_arc(trail_anchor + dust, 2.5, 0.2, 5.5, 6, Color(trail_color, float(trail["opacity"]) * 0.7), 1.5)
	var definition := motion.accent(state)
	if definition.is_empty():
		return
	var kind := String(definition.get("kind", ""))
	# The legacy DOUBLE_JUMP adapter is Float, whose state is marked only by
	# the immediate protection layer. Never loop a stale lift ring on release.
	if kind in ["lift_ring", "ground_wake", "speed_fins"]:
		return
	if kind in ["speed_fins", "fall_lines", "recovery_brace"] and body_anchor.is_finite():
		ground_anchor = body_anchor
	var color := language.ramp_color(String(definition.get("ramp", "aged_brass")), int(definition.get("index", 3)))
	var opacity := float(definition.get("opacity", 0.4)) * (0.55 if reduced else 1.0)
	var velocity := Vector2(float(state.velocity_x), float(state.velocity_y))
	var direction := velocity.normalized() if velocity.length_squared() > 1.0 else Vector2(float(state.facing_x), float(state.facing_y)).normalized()
	var side := Vector2(-direction.y, direction.x)
	var phase := float(tick % 12) / 12.0
	match kind:
		"ground_chevron":
			for index: int in range(2):
				var center := ground_anchor - direction * (12.0 + float(index) * 9.0)
				canvas.draw_polyline(PackedVector2Array([center + side * 7.0, center - direction * 6.0, center - side * 7.0]), Color(color, opacity * (1.0 - float(index) * 0.25)), 2.0)
		"kick_burst":
			var contact := ground_anchor - direction * 11.0
			for angle_offset: float in [-0.55, 0.0, 0.55]:
				var ray := (-direction).rotated(angle_offset)
				canvas.draw_line(contact + ray * 4.0, contact + ray * 13.0, Color(color, opacity), 2.0)
		"crest_arc":
			canvas.draw_arc(ground_anchor + Vector2(0, -10), 18.0, PI + 0.25, TAU - 0.25, 12, Color(color, opacity), 2.0)
		"fall_lines":
			for x_offset: float in [-8.0, 0.0, 8.0]:
				canvas.draw_line(ground_anchor + Vector2(x_offset, -28.0), ground_anchor + Vector2(x_offset, -16.0 + phase * 5.0), Color(color, opacity), 2.0)
		"wall_sparks":
			var contact_geometry := wall_contact_geometry(state)
			if contact_geometry.is_empty():
				return
			var wall_normal: Vector2 = contact_geometry["normal"]
			var contact := ground_anchor + (contact_geometry["offset"] as Vector2)
			var count := 1 if reduced else 3
			for index: int in range(count):
				var spark_direction := wall_normal.rotated(-0.5 + float(index) * 0.5 if count > 1 else 0.0)
				canvas.draw_line(contact, contact + spark_direction * (4.0 + phase * 3.0), Color(color, opacity * (0.7 + phase * 0.3)), 1.0)
		"recovery_brace":
			var contraction := 1.0 - phase
			var impact_center := ground_anchor + Vector2(0, -21) - direction * (6.0 + contraction * 3.0)
			canvas.draw_circle(impact_center, 9.0 + contraction * 3.0, Color(language.ramp_color("worldbone", 0), opacity * 0.28))
			for angle_offset: float in [-0.46, 0.0, 0.46]:
				var ray := (-direction).rotated(angle_offset)
				canvas.draw_line(impact_center + ray * 7.0, impact_center + ray * (15.0 + contraction * 5.0), Color(color, opacity * (0.72 + contraction * 0.28)), 3.0 if not reduced else 2.0)
			for side_sign: float in [-1.0, 1.0]:
				var brace_center := ground_anchor + side * side_sign * (18.0 + contraction * 5.0)
				canvas.draw_arc(brace_center, 7.0, -1.2 if side_sign < 0.0 else 1.9, 1.2 if side_sign < 0.0 else 4.3, 7, Color(color, opacity * (0.6 + contraction * 0.4)), 3.0 if not reduced else 2.0)
			canvas.draw_line(ground_anchor - direction * 10.0, ground_anchor - direction * (19.0 + contraction * 6.0), Color(color, opacity * 0.9), 3.0 if not reduced else 2.0)


static func wall_contact_geometry(state: PlayerState) -> Dictionary:
	if state == null or state.wall_skim_ticks <= 0 or state.wall_skim_surface_id <= 0:
		return {}
	var normal := Vector2(state.wall_x, state.wall_y).normalized()
	if normal == Vector2.ZERO:
		return {}
	return {"normal": normal, "offset": -normal * float(state.radius) / SimConfig.FIXED_SCALE}


func _draw_pixel_movement_accent(canvas: CanvasItem, state: PlayerState, ground_anchor: Vector2, age: int, reduced: bool, config: SimConfig) -> void:
	if state.health <= 0 or config == null:
		return
	var velocity := Vector2(state.velocity_x,state.velocity_y)
	var walljump := pixel_movement.walljump_contact(state,config,age,ground_anchor)
	if not walljump.is_empty():
		pixel_movement.stamp(canvas,"walljump_burst",walljump.anchor,walljump.age,reduced)
	if state.slide_ticks > 0 and not state.is_airborne() and velocity.length_squared() > 1000000.0:
		pixel_movement.stamp(canvas,"slide_trail",ground_anchor - velocity.normalized() * 14,age,reduced,velocity.angle(),0.65)
		var elapsed := maxi(0,config.milliseconds_to_ticks(MovementTuning.SLIDE_DURATION_MS) - state.slide_ticks)
		pixel_movement.stamp(canvas,"slide_dust",ground_anchor - velocity.normalized() * 14,elapsed,reduced,0.0,0.65)
	var contact := wall_contact_geometry(state)
	if not contact.is_empty():
		pixel_movement.stamp(canvas,"wallrun_sparks",ground_anchor + (contact.offset as Vector2),age,reduced)


func _draw_evasion_contour(
	canvas: CanvasItem,
	state: PlayerState,
	ground_anchor: Vector2,
	config: SimConfig,
	reduced: bool,
	body_height: float = 68.0,
) -> void:
	if state.health <= 0 or (state.spawn_protection_ticks <= 0 and not MovementSystem.is_combat_intangible(state, config)):
		return
	var contract := protection_contract(state, config, reduced, body_height)
	if not bool(contract["active"]):
		return
	if pixel_movement.protection(canvas,contract,ground_anchor,reduced):
		return
	var teal := language.ramp_color("deep_water", 4)
	var ink := language.ramp_color("deep_water", 0)
	# The shape, not hue or flashing, communicates protection in every profile.
	# No time interpolation or afterimage is permitted on this layer.
	for segment: PackedVector2Array in contract["brackets"]:
		var points := _offset(segment, ground_anchor)
		canvas.draw_polyline(points, Color(ink, 0.98), 6.0)
		canvas.draw_polyline(points, Color(teal, 1.0), 4.0)
		canvas.draw_polyline(points, Color.WHITE, 1.5)
	var shield := _offset(contract["shield"], ground_anchor)
	canvas.draw_colored_polygon(shield, Color(ink, 0.98))
	canvas.draw_polyline(shield, Color(teal, 1.0), 4.0)
	canvas.draw_polyline(shield, Color.WHITE, 1.5)
	for wing: PackedVector2Array in contract["float_wings"]:
		var points := _offset(wing, ground_anchor)
		canvas.draw_polyline(points, Color(ink, 0.98), 5.0)
		canvas.draw_polyline(points, Color(teal, 1.0), 3.0)
		canvas.draw_polyline(points, Color.WHITE, 1.25)


static func protection_contract(state: PlayerState, config: SimConfig, _reduced: bool = false, body_height: float = 68.0) -> Dictionary:
	var result := {"active": false, "brackets": [], "shield": PackedVector2Array(), "float_wings": [], "remaining_ratio": 0.0}
	var ratio := JumpPresentation.protection_ratio(state, config)
	if ratio <= 0.0:
		return result
	result["active"] = true
	result["remaining_ratio"] = ratio
	var top := -clampf(body_height, 40.0, 76.0) - 2.0
	var bottom := 2.0
	var brackets: Array[PackedVector2Array] = []
	for side: float in [-1.0, 1.0]:
		var x := 29.0 * side
		brackets.append(PackedVector2Array([Vector2(x - side * 7, top), Vector2(x, top), Vector2(x, top + 9)]))
		brackets.append(PackedVector2Array([Vector2(x - side * 7, bottom), Vector2(x, bottom), Vector2(x, bottom - 9)]))
	result["brackets"] = brackets
	var center := Vector2(0, top - 11.0)
	result["shield"] = PackedVector2Array([center + Vector2(-5, -4), center + Vector2(5, -4), center + Vector2(4, 2), center + Vector2(0, 6), center + Vector2(-4, 2), center + Vector2(-5, -4)])
	if state.air_floating and state.air_height > 0 and state.stamina > 0:
		var wings: Array[PackedVector2Array] = []
		for side: float in [-1.0, 1.0]:
			wings.append(PackedVector2Array([center + Vector2(side * 8.0, 2.0), center + Vector2(side * 14.0, 2.0), center + Vector2(side * 18.0, -3.0)]))
		result["float_wings"] = wings
	return result


static func evasion_direction(state: PlayerState) -> String:
	if state == null:
		return "south"
	var velocity := Vector2i(state.velocity_x, state.velocity_y)
	if velocity != Vector2i.ZERO:
		return EightDirectionResolver.direction_id_from_vector(velocity.x, velocity.y)
	return EightDirectionResolver.direction_id_from_vector(state.facing_x, state.facing_y)


func _draw_directional_evasion_cue(
	canvas: CanvasItem,
	state: PlayerState,
	ground_anchor: Vector2,
	phase: float,
	color: Color,
	opacity: float,
) -> void:
	var direction_value := EightDirectionResolver.fixed_vector(evasion_direction(state))
	var direction := Vector2(float(direction_value.x), float(direction_value.y)).normalized()
	var side := direction.orthogonal()
	var length := 9.0 + phase * 4.0
	var start := ground_anchor - direction * (15.0 + phase * 3.0)
	for side_sign: float in [-1.0, 1.0]:
		var center := start + side * side_sign * 6.0
		canvas.draw_line(center, center - direction * length, Color(color, opacity * 0.72), 2.0)


func _validate_recipe(champion_id: String, value: Variant) -> bool:
	if not value is Dictionary:
		return _fail("Cartoon champion recipe must be an object: %s" % champion_id)
	var definition: Dictionary = value
	var body_type := String(definition.get("body_type", ""))
	if body_type not in EXPECTED_BODY_TYPES:
		return _fail("Cartoon champion body type is unsupported: %s" % champion_id)
	var body_template: Dictionary = body_templates.get(body_type, {})
	if body_template.is_empty() or (champion_id in REQUIRED_FOUNDATION and String(body_template.get("exemplar", "")) != champion_id) \
		or int(body_template.get("reference_height", 0)) != int(definition.get("height", 0)):
		return _fail("Cartoon champion does not match its reusable body template: %s" % champion_id)
	var atlas_row := int(definition.get("atlas_row", -1))
	if champion_id not in REQUIRED_FOUNDATION and atlas_row != 0:
		return _fail("Additional champion page rows must start at zero: " + champion_id)
	if atlas_row < 0 or atlas_row >= REQUIRED_FOUNDATION.size():
		return _fail("Cartoon champion atlas row is unsupported: %s" % champion_id)
	var height := int(definition.get("height", 0))
	var ratio := float(definition.get("head_ratio", 0.0))
	if height < 44 or height > 76 or ratio < 0.20 or ratio > 0.23:
		return _fail("Cartoon champion proportions exceed the gameplay contract: %s" % champion_id)
	var affinities: Array = definition.get("affinities", [])
	if affinities.size() < 2 or affinities.size() > 3:
		return _fail("Cartoon champion must expose two or three affinities: %s" % champion_id)
	for element_id: Variant in affinities:
		if String(element_id) not in VisualLanguage.REQUIRED_ELEMENTS:
			return _fail("Cartoon champion uses an unknown element: %s" % champion_id)
	var features: Array = definition.get("silhouette_features", [])
	if features.size() < 3 or String(definition.get("equipment", "")) != "body_clothing_only":
		return _fail("Cartoon champion lacks a distinct body/clothing read: %s" % champion_id)
	if String(definition.get("casting_origin", "")) != "hands":
		return _fail("Cartoon champion magic must originate from hands: %s" % champion_id)
	var casting_tokens := "%s %s" % [String(definition.get("equipment", "")), " ".join(features)]
	for forbidden_token: String in ["staff", "wand", "scepter", "rod", "focus_orb", "orb", "spell", "aura", "shadow", "projectile", "environment"]:
		if forbidden_token in casting_tokens.to_lower():
			return _fail("Cartoon champion uses a forbidden casting focus: %s" % champion_id)
	var motion_profile := String(definition.get("motion_profile", ""))
	if motion == null or not motion.has_profile(motion_profile):
		return _fail("Cartoon champion lacks a validated minimal-motion profile: %s" % champion_id)
	var materials: Dictionary = definition.get("materials", {})
	for material_id: String in ["outline", "skin_dark", "skin", "armor", "trim", "eye"]:
		var material: Array = materials.get(material_id, [])
		if material.size() != 2 or not language.ramps.has(String(material[0])) or int(material[1]) < 0 or int(material[1]) > 4:
			return _fail("Cartoon champion material is invalid: %s/%s" % [champion_id, material_id])
	return true


func _validate_cardinal_animation_contract(value: Variant) -> bool:
	if not value is Dictionary:
		return _fail("Cartoon champion cardinal animation contract must be an object")
	var contract: Dictionary = value
	if contract.get("directions", []) != EXPECTED_CARDINAL_DIRECTIONS:
		return _fail("Cartoon champion cardinal directions must be south, east, north, west")
	if contract.get("states", []) != EXPECTED_CARDINAL_STATES:
		return _fail("Cartoon champion cardinal action states are incomplete")
	if String(contract.get("coverage", "")) != "every_champion_has_every_state_in_every_cardinal_direction":
		return _fail("Cartoon champion cardinal action coverage is unsupported")
	if String(contract.get("row_layout", "")) != "champion_major_state_minor":
		return _fail("Cartoon champion cardinal atlas row layout is unsupported")
	if String(contract.get("diagonal_policy", "")) != "state_scoped_promoted_diagonals":
		return _fail("Cartoon champion diagonal direction policy is unsupported")
	cardinal_animation_contract = contract.duplicate(true)
	return true


func _validate_diagonal_core_contract(value: Variant) -> bool:
	diagonal_core_contract.clear()
	if not value is Dictionary:
		return _fail("Cartoon champion diagonal core contract must be an object")
	var contract: Dictionary = value
	if contract.get("directions", []) != EXPECTED_DIAGONAL_DIRECTIONS:
		return _fail("Cartoon champion diagonal core directions are incomplete")
	if contract.get("states", []) != EXPECTED_DIAGONAL_CORE_STATES:
		return _fail("Cartoon champion diagonal core states are incomplete")
	if String(contract.get("coverage", "")) != "every_foundation_champion_has_every_diagonal_core_cell":
		return _fail("Cartoon champion diagonal core coverage is unsupported")
	if contract.get("fallback_states", []) != []:
		return _fail("Cartoon champion diagonal core retains obsolete fallback states")
	if String(contract.get("fallback_policy", "")) != "none_all_states_promoted":
		return _fail("Cartoon champion diagonal fallback policy is unsupported")
	diagonal_core_contract = contract.duplicate(true)
	return true


func _validate_diagonal_locomotion_contract(value: Variant) -> bool:
	diagonal_locomotion_contract.clear()
	if not value is Dictionary:
		return _fail("Cartoon champion diagonal locomotion contract must be an object")
	var contract: Dictionary = value
	if contract.get("directions", []) != EXPECTED_DIAGONAL_DIRECTIONS:
		return _fail("Cartoon champion diagonal locomotion directions are incomplete")
	if contract.get("states", []) != EXPECTED_DIAGONAL_LOCOMOTION_STATES:
		return _fail("Cartoon champion diagonal locomotion states are incomplete")
	if String(contract.get("coverage", "")) != "every_foundation_champion_has_every_diagonal_locomotion_cell":
		return _fail("Cartoon champion diagonal locomotion coverage is unsupported")
	if contract.get("gaits", []) != EXPECTED_RELATIVE_GAITS:
		return _fail("Cartoon champion relative gait catalog is incomplete")
	if String(contract.get("facing_policy", "")) != "travel_when_free_aim_when_combat_intent" \
		or String(contract.get("authority", "")) != "presentation_only":
		return _fail("Cartoon champion locomotion facing policy is unsupported")
	diagonal_locomotion_contract = contract.duplicate(true)
	return true


func _validate_diagonal_evasion_contract(value: Variant) -> bool:
	diagonal_evasion_contract.clear()
	if not value is Dictionary:
		return _fail("Cartoon champion diagonal evasion contract must be an object")
	var contract: Dictionary = value
	if contract.get("directions", []) != EXPECTED_DIAGONAL_DIRECTIONS:
		return _fail("Cartoon champion diagonal evasion directions are incomplete")
	if contract.get("states", []) != EXPECTED_DIAGONAL_EVASION_STATES:
		return _fail("Cartoon champion diagonal evasion states are incomplete")
	if String(contract.get("coverage", "")) != "every_foundation_champion_has_every_diagonal_evasion_cell":
		return _fail("Cartoon champion diagonal evasion coverage is unsupported")
	if String(contract.get("art_status", "")) != "reviewed_source_integrated" \
		or String(contract.get("authority", "")) != "presentation_only":
		return _fail("Cartoon champion diagonal evasion policy is unsupported")
	diagonal_evasion_contract = contract.duplicate(true)
	return true


func _validate_locomotion_phase_contract(value: Variant) -> bool:
	locomotion_phase_contract.clear()
	if not value is Dictionary:
		return _fail("Cartoon champion locomotion phase contract must be an object")
	var contract: Dictionary = value
	if contract.get("states", []) != EXPECTED_PHASE_STATES:
		return _fail("Cartoon champion locomotion phase states are incomplete")
	var frame_states: Dictionary = contract.get("frame_states", {})
	if frame_states.get("walk", []) != ["walk", "walk_b"] \
		or frame_states.get("sprint", []) != ["sprint", "sprint_b"]:
		return _fail("Cartoon champion locomotion contact frames are incomplete")
	if String(contract.get("coverage", "")) != "two_contacts_per_champion_per_eight_directions" \
		or String(contract.get("timing", "")) != "motion_profile_half_cycle" \
		or String(contract.get("authority", "")) != "presentation_only":
		return _fail("Cartoon champion locomotion phase policy is unsupported")
	locomotion_phase_contract = contract.duplicate(true)
	return true


func _validate_semantic_state_aliases(value: Variant) -> bool:
	semantic_state_aliases.clear()
	if not value is Dictionary:
		return _fail("Cartoon champion semantic state aliases must be an object")
	var aliases: Dictionary = value
	var actual_actions: Array[String] = []
	for action_id: Variant in aliases.keys():
		if not action_id is String:
			return _fail("Cartoon champion semantic action IDs must be strings")
		actual_actions.append(String(action_id))
	var expected_actions := EXPECTED_SEMANTIC_ACTIONS.duplicate()
	actual_actions.sort()
	expected_actions.sort()
	if actual_actions != expected_actions:
		return _fail("Cartoon champion semantic action coverage is incomplete")
	for action_id: String in expected_actions:
		var atlas_state := String(aliases.get(action_id, ""))
		if atlas_state not in EXPECTED_CARDINAL_STATES:
			return _fail("Cartoon champion semantic action targets an unsupported atlas state: %s" % action_id)
	semantic_state_aliases = aliases.duplicate(true)
	return true


static func _offset(points: PackedVector2Array, offset: Vector2) -> PackedVector2Array:
	var output := PackedVector2Array()
	for point: Vector2 in points:
		output.append(point + offset)
	return output


static func _vector2i(value: Variant) -> Vector2i:
	if not value is Array or value.size() != 2:
		return Vector2i.ZERO
	return Vector2i(int(value[0]), int(value[1]))


func _fail(message: String) -> bool:
	last_error = message
	return false


static func _sha256(path: String) -> String:
	var context := HashingContext.new()
	if context.start(HashingContext.HASH_SHA256) != OK:
		return ""
	if context.update(FileAccess.get_file_as_bytes(path)) != OK:
		return ""
	return context.finish().hex_encode()


static func _bytes_sha256(bytes: PackedByteArray) -> String:
	var context := HashingContext.new()
	if context.start(HashingContext.HASH_SHA256) != OK or context.update(bytes) != OK:
		return ""
	return context.finish().hex_encode()
