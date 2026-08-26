class_name CartoonChampionPresenter
extends RefCounted


const DEFAULT_PATH := "res://content/visual/foundation_champion_visuals_v1.json"
const EXPECTED_ID := "foundation-champion-visuals-v2-body-only"
const EXPECTED_AUTHORITY := "presentation only; hitboxes, movement, casts and outcomes remain authoritative elsewhere"
const REQUIRED_FOUNDATION := ["oh_tipi", "s_wayne"]
const ATLAS_PATH := "res://assets/sprites/champions_v3/foundation/runtime_atlas_body_v3.png"
const EXPECTED_BODY_TYPES: Array[String] = ["small", "middle", "large"]
const EXPECTED_EXCLUDED_LAYERS: Array[String] = ["spell", "element", "projectile", "aura", "shadow", "environment", "equipment", "focus"]
const CELL_SIZE := Vector2(96.0, 96.0)
const PIVOT := Vector2(48.0, 84.0)
const BODY_TYPE_RENDER_SCALE := {
	"small": 0.90,
	"middle": 1.00,
	"large": 1.10,
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


func configure(visual_language: VisualLanguage, path: String = DEFAULT_PATH) -> bool:
	language = visual_language
	champions.clear()
	content_hash = ""
	atlas_hash = ""
	last_error = ""
	atlas = null
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
	if int(data.get("schema_version", -1)) != 2 or String(data.get("id", "")) != EXPECTED_ID:
		return _fail("Cartoon champion recipe identity is unsupported")
	if String(data.get("authority", "")) != EXPECTED_AUTHORITY:
		return _fail("Cartoon champion recipes must remain presentation-only")
	if String(data.get("atlas_role", "")) != "body_and_clothing_only":
		return _fail("Cartoon champion atlas must contain body and clothing only")
	if String(data.get("front_pose", "")) != "camera_facing_symmetrical":
		return _fail("Cartoon champion front pose must face the camera symmetrically")
	if String(data.get("direction_policy", "")) != "south_front_camera_facing; east_profile; west_mirrored_east; north_centered_back":
		return _fail("Cartoon champion direction policy is unsupported")
	if data.get("excluded_layers", []) != EXPECTED_EXCLUDED_LAYERS:
		return _fail("Cartoon champion excluded-layer contract is invalid")
	if _vector2i(data.get("cell", [])) != Vector2i(96, 96) or _vector2i(data.get("pivot", [])) != Vector2i(48, 84):
		return _fail("Cartoon champion cell/pivot differs from the visual contract")
	var atlas_definition: Dictionary = data.get("atlas", {})
	if String(atlas_definition.get("path", "")) != ATLAS_PATH \
		or _vector2i(atlas_definition.get("dimensions", [])) != Vector2i(672, 192) \
		or atlas_definition.get("rows", []) != REQUIRED_FOUNDATION \
		or atlas_definition.get("columns", []) != ["south", "east", "west", "north", "jump", "cast", "hit"]:
		return _fail("Foundation cartoon atlas layout is unsupported")
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
	var atlas_resource: Resource = load(ATLAS_PATH)
	if not atlas_resource is Texture2D:
		champions.clear()
		return _fail("Foundation cartoon atlas cannot be loaded")
	atlas = atlas_resource
	if atlas.get_size() != Vector2(672.0, 192.0):
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
	if state == null or not champions.has(champion_id):
		return Rect2()
	var row := 0 if champion_id == "oh_tipi" else 1
	var state_id := silhouette_state(state)
	var column := 0
	if state_id == "jump":
		column = 4
	elif state_id == "cast":
		column = 5
	elif state_id == "hit":
		column = 6
	else:
		match cardinal_direction(state.facing_x, state.facing_y):
			"east":
				column = 1
			"west":
				column = 2
			"north":
				column = 3
			_:
				column = 0
	return Rect2(Vector2(float(column) * CELL_SIZE.x, float(row) * CELL_SIZE.y), CELL_SIZE)


func draw(
	canvas: CanvasItem,
	state: PlayerState,
	champion_id: String,
	body_anchor: Vector2,
	presentation_tick: int,
	config: SimConfig,
	reduced_effects: bool = false,
) -> bool:
	if canvas == null or state == null or not champions.has(champion_id):
		return false
	var definition: Dictionary = champions[champion_id]
	var motion_id := MinimalChampionMotion.motion_id(state)
	var motion_elapsed := MinimalChampionMotion.elapsed_for_state(state, motion_id, float(presentation_tick), config)
	var motion_sample := motion.sample(String(definition.get("motion_profile", "")), motion_id, motion_elapsed, reduced_effects)
	if motion_id in ["walk", "sprint"]:
		var response := movement_response_scale(state)
		motion_sample.offset *= response
		motion_sample.scale = Vector2.ONE.lerp(motion_sample.scale, response)
		motion_sample.aura_scale = lerpf(1.0, motion_sample.aura_scale, response)
	var anchor := body_anchor + motion_sample.offset + _directional_lean(state, motion_id, reduced_effects)
	var body_type := String(definition.get("body_type", "middle"))
	var body_scale := body_type_render_scale(body_type)
	_draw_counter_strafe_accent(canvas, state, body_anchor, reduced_effects)
	_draw_movement_accent(canvas, state, body_anchor, presentation_tick, reduced_effects)
	_draw_aura(canvas, definition, anchor, presentation_tick, reduced_effects, motion_sample.aura_scale)
	if atlas == null:
		return false
	_draw_atlas_candidate(canvas, state, champion_id, anchor, motion_sample.scale * body_scale)
	_draw_evasion_contour(canvas, state, body_anchor, presentation_tick, config, reduced_effects)
	return true


func _draw_atlas_candidate(canvas: CanvasItem, state: PlayerState, champion_id: String, anchor: Vector2, motion_scale: Vector2) -> void:
	var source := source_region(champion_id, state)
	var size := CELL_SIZE * motion_scale
	var pivot := Vector2(PIVOT.x * motion_scale.x, PIVOT.y * motion_scale.y)
	canvas.draw_texture_rect_region(atlas, Rect2(anchor - pivot, size), source)


static func silhouette_state(state: PlayerState) -> String:
	if state.movement_mode in [PlayerState.MovementMode.LAUNCHED, PlayerState.MovementMode.IMPACT_RECOVERY] or state.control_state == PlayerState.ControlState.STUNNED:
		return "hit"
	if state.pending_cast_wire_id > 0 or state.last_event.begins_with("cast_start_"):
		return "cast"
	if state.is_airborne():
		return "jump"
	return "grounded"


static func cardinal_direction(x: int, y: int) -> String:
	if absi(x) > absi(y):
		return "east" if x >= 0 else "west"
	return "south" if y >= 0 else "north"


static func body_type_render_scale(body_type: String) -> float:
	return float(BODY_TYPE_RENDER_SCALE.get(body_type.to_lower(), 1.0))


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


func _draw_movement_accent(canvas: CanvasItem, state: PlayerState, ground_anchor: Vector2, tick: int, reduced: bool) -> void:
	var definition := motion.accent(state)
	if definition.is_empty():
		return
	var kind := String(definition.get("kind", ""))
	var color := language.ramp_color(String(definition.get("ramp", "aged_brass")), int(definition.get("index", 3)))
	var opacity := float(definition.get("opacity", 0.4)) * (0.55 if reduced else 1.0)
	var velocity := Vector2(float(state.velocity_x), float(state.velocity_y))
	var direction := velocity.normalized() if velocity.length_squared() > 1.0 else Vector2(float(state.facing_x), float(state.facing_y)).normalized()
	var side := Vector2(-direction.y, direction.x)
	var phase := float(tick % 12) / 12.0
	match kind:
		"lift_ring":
			canvas.draw_arc(ground_anchor + Vector2(0, 2), 15.0 + phase * 5.0, 0.0, TAU, 16, Color(color, opacity * (1.0 - phase)), 2.0)
		"ground_wake":
			for sign_value: float in [-1.0, 1.0]:
				var start := ground_anchor - direction * 9.0 + side * 8.0 * sign_value
				canvas.draw_line(start, start - direction * (14.0 + phase * 7.0), Color(color, opacity * (1.0 - phase * 0.5)), 2.0)
		"speed_fins":
			for sign_value: float in [-1.0, 1.0]:
				var fin := ground_anchor - direction * 13.0 + side * 13.0 * sign_value
				canvas.draw_polyline(PackedVector2Array([fin - direction * 12.0, fin, fin - direction * 7.0 + side * 5.0 * sign_value]), Color(color, opacity), 2.0)
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
			var wall_side := Vector2(float(state.wall_x), float(state.wall_y)).normalized()
			if wall_side == Vector2.ZERO:
				wall_side = side
			var contact := ground_anchor + wall_side * 14.0
			for index: int in range(3):
				var spark_direction := (-wall_side).rotated(-0.5 + float(index) * 0.5)
				canvas.draw_line(contact, contact + spark_direction * (5.0 + float(index) * 2.0), Color(color, opacity), 1.0)
		"recovery_brace":
			var contraction := 1.0 - phase
			for side_sign: float in [-1.0, 1.0]:
				var brace_center := ground_anchor + side * side_sign * (18.0 + contraction * 5.0)
				canvas.draw_arc(brace_center, 7.0, -1.2 if side_sign < 0.0 else 1.9, 1.2 if side_sign < 0.0 else 4.3, 7, Color(color, opacity * (0.6 + contraction * 0.4)), 2.0)
			canvas.draw_line(ground_anchor - direction * 10.0, ground_anchor - direction * (17.0 + contraction * 5.0), Color(color, opacity * 0.8), 2.0)


func _draw_evasion_contour(
	canvas: CanvasItem,
	state: PlayerState,
	ground_anchor: Vector2,
	tick: int,
	config: SimConfig,
	reduced: bool,
) -> void:
	if not MovementSystem.is_combat_intangible(state, config):
		return
	var color := language.ramp_color("parchment", 4)
	var phase := float(tick % 12) / 12.0
	var radius := 20.0 + phase * 3.0
	var opacity := 0.62 if not reduced else 0.48
	var center := ground_anchor + Vector2(0.0, -22.0)
	canvas.draw_arc(center, radius, -1.35 + phase, 0.25 + phase, 10, Color(color, opacity), 2.0)
	canvas.draw_arc(center, radius, 1.8 + phase, 3.4 + phase, 10, Color(color, opacity), 2.0)


func _validate_recipe(champion_id: String, value: Variant) -> bool:
	if not value is Dictionary:
		return _fail("Cartoon champion recipe must be an object: %s" % champion_id)
	var definition: Dictionary = value
	if String(definition.get("body_type", "")) not in EXPECTED_BODY_TYPES:
		return _fail("Cartoon champion body type is unsupported: %s" % champion_id)
	var height := int(definition.get("height", 0))
	var ratio := float(definition.get("head_ratio", 0.0))
	if height < 44 or height > 68 or ratio < 0.40 or ratio > 0.45:
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
