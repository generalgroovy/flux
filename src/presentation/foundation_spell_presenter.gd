class_name FoundationSpellPresenter
extends RefCounted


const DEFAULT_PATH := "res://content/visual/foundation_spell_visuals_v1.json"
const EXPECTED_ID := "foundation-spell-visuals-v1"
const EXPECTED_AUTHORITY := "presentation only; simulation owns spell membership, geometry, timing, collision, resources, damage, control and outcomes"
const REQUIRED_IDS := ["rillshot", "tideline", "rimewake", "eclipse-disc", "pocket-eclipse"]
const STARTUPS := ["gathered_drop", "rising_fan", "frost_sigil", "orbiting_crescents", "paired_focus"]
const SILHOUETTES := ["droplet", "wave_fan", "crystal_wake", "eclipse_disc", "eclipse_beam"]
const TRAILS := ["none", "split_rill", "curling_lanes", "orbit_echo", "paired_boundary"]
const IMPACTS := ["splash_ring", "breaker_arc", "freeze_star", "crescent_break", "revealed_diamond"]

var language: VisualLanguage
var data: Dictionary = {}
var profiles_by_wire: Dictionary[int, Dictionary] = {}
var profiles_by_id: Dictionary[String, Dictionary] = {}
var animation_skeletons := SpellAnimationSkeletonLibrary.new()
var content_hash := ""
var animation_skeleton_hash := ""
var last_error := ""


func configure(visual_language: VisualLanguage, catalog: AbilityCatalog, path: String = DEFAULT_PATH) -> bool:
	language = visual_language
	data.clear()
	profiles_by_wire.clear()
	profiles_by_id.clear()
	animation_skeletons = SpellAnimationSkeletonLibrary.new()
	content_hash = ""
	animation_skeleton_hash = ""
	last_error = ""
	if language == null or catalog == null or language.elements.is_empty() or catalog.abilities_by_id.is_empty():
		return _fail("Foundation spell presentation requires validated visual and ability catalogs")
	if not animation_skeletons.load_from_file():
		return _fail(animation_skeletons.last_error)
	animation_skeleton_hash = animation_skeletons.content_hash
	if not FileAccess.file_exists(path):
		return _fail("Foundation spell presentation does not exist: %s" % path)
	var source := FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(source)
	if not parsed is Dictionary:
		return _fail("Foundation spell presentation root must be an object")
	data = parsed
	if not validate(catalog):
		data.clear()
		return false
	content_hash = source.sha256_text()
	return true


func validate(catalog: AbilityCatalog) -> bool:
	last_error = ""
	profiles_by_wire.clear()
	profiles_by_id.clear()
	if int(data.get("schema_version", -1)) != 1 or String(data.get("id", "")) != EXPECTED_ID:
		return _fail("Foundation spell presentation identity is unsupported")
	if String(data.get("authority", "")) != EXPECTED_AUTHORITY:
		return _fail("Foundation spell presentation must remain presentation-only")
	var budgets: Dictionary = data.get("budgets", {})
	if int(budgets.get("profile_count", 0)) != REQUIRED_IDS.size() \
		or int(budgets.get("maximum_curve_samples", 0)) < 16 or int(budgets.get("maximum_curve_samples", 0)) > 40 \
		or int(budgets.get("maximum_lane_rays", 0)) < 5 or int(budgets.get("maximum_lane_rays", 0)) > 9 \
		or float(budgets.get("maximum_effect_alpha", 0.0)) < 0.60 or float(budgets.get("maximum_effect_alpha", 0.0)) > 0.85:
		return _fail("Foundation spell visual budgets are unsafe")
	var profiles: Variant = data.get("profiles", [])
	if not profiles is Array or (profiles as Array).size() != REQUIRED_IDS.size():
		return _fail("Foundation spell presentation must define exactly five live profiles")
	var claimed_startups: Dictionary[String, bool] = {}
	for value: Variant in profiles:
		if not value is Dictionary:
			return _fail("Foundation spell profile must be an object")
		var profile: Dictionary = value
		var profile_id := String(profile.get("id", ""))
		var wire_id := int(profile.get("wire_id", 0))
		var ability := catalog.ability(profile_id)
		if profile_id not in REQUIRED_IDS or profiles_by_id.has(profile_id) or wire_id <= 0 or profiles_by_wire.has(wire_id):
			return _fail("Foundation spell profile identity is invalid: %s" % profile_id)
		if ability.is_empty() or int(ability.get("wire_id", 0)) != wire_id \
			or String(ability.get("shape", "")) != String(profile.get("shape", "")) \
			or String(ability.get("element", "")) != String(profile.get("element", "")) \
			or String(ability.get("residue", "")) != String(profile.get("residue", "")):
			return _fail("Foundation spell visual contradicts the ability catalog: %s" % profile_id)
		var skeleton_id := String(profile.get("skeleton_id", ""))
		if skeleton_id.is_empty() or not animation_skeletons.skeletons.has(skeleton_id) \
			or String(animation_skeletons.skeletons[skeleton_id].get("shape", "")) != String(profile.get("shape", "")):
			return _fail("Foundation spell visual has no matching animation skeleton: %s" % profile_id)
		var startup := String(profile.get("startup", ""))
		if startup not in STARTUPS or claimed_startups.has(startup) \
			or String(profile.get("silhouette", "")) not in SILHOUETTES \
			or String(profile.get("trail", "")) not in TRAILS \
			or String(profile.get("impact", "")) not in IMPACTS:
			return _fail("Foundation spell visual vocabulary is invalid: %s" % profile_id)
		claimed_startups[startup] = true
		profiles_by_id[profile_id] = profile
		profiles_by_wire[wire_id] = profile
	for profile_id: String in REQUIRED_IDS:
		if not profiles_by_id.has(profile_id):
			return _fail("Foundation spell visual is missing: %s" % profile_id)
	return true


func draw_startup(
	canvas: CanvasItem,
	wire_id: int,
	position: Vector2,
	aim: Vector2,
	phase: float,
	tick: int,
	reduced_effects: bool,
) -> bool:
	if canvas == null or not profiles_by_wire.has(wire_id):
		return false
	var profile: Dictionary = profiles_by_wire[wire_id]
	if not animation_skeletons.skeletons.has(String(profile.get("skeleton_id", ""))):
		return false
	var direction := aim.normalized() if aim.length_squared() > 0.0 else Vector2.RIGHT
	var side := direction.orthogonal()
	var progress := clampf(phase, 0.0, 1.0)
	var element := String(profile.get("element", "water"))
	var dark := language.element_color(element, "dark")
	var base := language.element_color(element, "base")
	var bright := language.element_color(element, "bright")
	var pulse := 0.0 if reduced_effects else sin(float(tick + wire_id) * 0.20) * 1.5
	var skeleton_phase := animation_skeletons.phase_for(String(profile.get("shape", "")), progress)
	var phase_id := String(skeleton_phase.get("id", ""))
	# The delivery skeleton contributes a small shared hand cue before the
	# spell-specific silhouette. It is presentation-only; the authoritative
	# cast timer still decides when this layer appears and disappears.
	match phase_id:
		"startup":
			var gather_radius := 5.0 + progress * 5.0
			canvas.draw_circle(position, gather_radius, Color(base, 0.12 if reduced_effects else 0.20))
			canvas.draw_arc(position, gather_radius + 4.0, -2.4, 0.6, 16, Color(bright, 0.72), 2.0)
		"release":
			var release_origin := position + direction * 7.0
			canvas.draw_arc(release_origin, 9.0 + pulse * 0.35, 0.0, TAU, 16, Color(bright, 0.82), 2.0)
			canvas.draw_line(position + direction * 2.0, position + direction * 14.0, Color(base, 0.64), 2.0)
	match String(profile.get("startup", "")):
		"gathered_drop":
			var gather := position + direction * (16.0 + progress * 7.0)
			canvas.draw_arc(gather, 10.0 - progress * 4.0 + pulse, -2.6, 0.55, 14, Color(bright, 0.82), 2.0)
			canvas.draw_line(gather - direction * 13.0 + side * 5.0, gather - direction * 4.0 + side * 2.0, Color(base, 0.54), 2.0)
			canvas.draw_line(gather - direction * 13.0 - side * 5.0, gather - direction * 4.0 - side * 2.0, Color(base, 0.54), 2.0)
		"rising_fan":
			for offset: float in [-0.34, 0.0, 0.34]:
				var lane := direction.rotated(offset)
				var reach := 22.0 + progress * 15.0
				canvas.draw_arc(position, reach, lane.angle() - 0.12, lane.angle() + 0.12, 6, Color(bright if offset == 0.0 else base, 0.54 + progress * 0.22), 2.0)
		"frost_sigil":
			var sigil_radius := 15.0 + progress * 8.0
			canvas.draw_arc(position, sigil_radius, 0.0, TAU, 18, Color(base, 0.48 + progress * 0.28), 2.0)
			for index: int in range(6):
				var ray := Vector2.from_angle(TAU * float(index) / 6.0)
				canvas.draw_line(position + ray * 8.0, position + ray * sigil_radius, Color(bright, 0.72), 2.0)
		"orbiting_crescents":
			for offset: float in [0.0, PI]:
				var angle := progress * PI * 1.4 + offset
				var center := position + Vector2.from_angle(angle) * (18.0 + pulse)
				canvas.draw_arc(center, 6.0, angle - 1.9, angle + 1.1, 9, Color(bright if offset == 0.0 else language.element_color("light", "bright"), 0.78), 2.0)
		"paired_focus":
			var focus := position + direction * (28.0 + progress * 12.0)
			var separation := 9.0 - progress * 5.0
			canvas.draw_line(position + side * separation, focus + side * separation, Color(base, 0.64), 2.0)
			canvas.draw_line(position - side * separation, focus - side * separation, Color(language.element_color("dark", "bright"), 0.64), 2.0)
			_draw_diamond(canvas, focus, 4.0 + progress * 3.0, Color(bright, 0.82), Color(dark, 0.24))
		_:
			return false
	return true


func draw_projectile(canvas: CanvasItem, projectile: ProjectileState, tick: int, reduced_effects: bool) -> bool:
	if canvas == null or projectile == null or not profiles_by_wire.has(projectile.source_wire_id):
		return false
	var profile: Dictionary = profiles_by_wire[projectile.source_wire_id]
	if String(profile.get("shape", "")) != "projectile":
		return false
	var position := Vector2(float(projectile.position_x), float(projectile.position_y)) / SimConfig.FIXED_SCALE
	var previous := Vector2(float(projectile.previous_x), float(projectile.previous_y)) / SimConfig.FIXED_SCALE
	var velocity := Vector2(float(projectile.velocity_x), float(projectile.velocity_y))
	var direction := velocity.normalized() if velocity.length_squared() > 0.0 else (position - previous).normalized()
	if direction.length_squared() <= 0.0:
		direction = Vector2.RIGHT
	var side := direction.orthogonal()
	var radius := float(projectile.radius) / SimConfig.FIXED_SCALE
	var element := String(profile.get("element", "water"))
	var dark := language.element_color(element, "dark")
	var base := language.element_color(element, "base")
	var bright := language.element_color(element, "bright")
	match String(profile.get("silhouette", "")):
		"droplet":
			var wake_length := 9.0 if reduced_effects else 16.0
			for side_value: float in [-1.0, 1.0]:
				canvas.draw_line(position - direction * 3.0 + side * side_value * 3.0, position - direction * wake_length + side * side_value * 5.0, Color(base, 0.42), 2.0)
			var drop := PackedVector2Array([
				position + direction * (radius + 4.0),
				position + side * radius,
				position - direction * (radius + 3.0),
				position - side * radius,
			])
			canvas.draw_colored_polygon(drop, base)
			canvas.draw_polyline(_closed(drop), bright, 2.0, false)
			canvas.draw_circle(position + direction * 2.0 - side * 2.0, maxf(2.0, radius * 0.30), Color(bright, 0.88))
		"eclipse_disc":
			var pulse := 0.0 if reduced_effects else sin(float(tick + projectile.entity_id) * 0.18) * 1.5
			canvas.draw_circle(position, radius + 8.0 + pulse, Color(base, 0.14))
			canvas.draw_circle(position, radius + 1.0, dark)
			canvas.draw_arc(position, radius + 1.0, -2.45, 0.70, 18, bright, 3.0)
			canvas.draw_arc(position, radius - 3.0, 0.70, 3.84, 18, Color(language.element_color("light", "bright"), 0.72), 2.0)
			canvas.draw_line(position - direction * 8.0 + side * 5.0, position - direction * 19.0 + side * 10.0, Color(base, 0.42), 2.0)
			for bounce_index: int in range(projectile.remaining_bounces):
				canvas.draw_circle(position + side * (radius + 7.0) + direction * float(bounce_index * 4 - 2), 1.5, bright)
		_:
			return false
	return true


func draw_field(canvas: CanvasItem, field: FieldState, life_ratio: float, tick: int, reduced_effects: bool) -> bool:
	if canvas == null or field == null or not profiles_by_wire.has(field.source_wire_id):
		return false
	var profile: Dictionary = profiles_by_wire[field.source_wire_id]
	if String(profile.get("silhouette", "")) != "crystal_wake":
		return false
	var center := Vector2(float(field.position_x), float(field.position_y)) / SimConfig.FIXED_SCALE
	var radius := float(field.radius) / SimConfig.FIXED_SCALE
	var dark := language.element_color("ice", "dark")
	var base := language.element_color("ice", "base")
	var bright := language.element_color("ice", "bright")
	var breath := 0.0 if reduced_effects else sin(float(tick + field.entity_id) * 0.08) * 2.0
	canvas.draw_circle(center, radius, Color(dark, 0.16 + life_ratio * 0.05))
	canvas.draw_arc(center, radius + breath, 0.0, TAU, 32, Color(base, 0.72), 3.0)
	canvas.draw_arc(center, radius * 0.72, 0.0, TAU, 24, Color(bright, 0.34), 1.0)
	for index: int in range(6):
		var direction := Vector2.from_angle(TAU * float(index) / 6.0)
		canvas.draw_line(center + direction * 14.0, center + direction * radius * 0.82, Color(bright, 0.52), 2.0)
		var branch := center + direction * radius * 0.58
		canvas.draw_line(branch, branch - direction.rotated(0.72) * 8.0, Color(base, 0.58), 2.0)
		canvas.draw_line(branch, branch - direction.rotated(-0.72) * 8.0, Color(base, 0.58), 2.0)
	for affected_index: int in range(mini(field.affected_entity_ids.size(), 8)):
		var angle := TAU * float(affected_index) / 8.0
		canvas.draw_rect(Rect2(center + Vector2.from_angle(angle) * radius * 0.90 - Vector2(2, 2), Vector2(4, 4)), bright, true)
	return true


func draw_cue(canvas: CanvasItem, cue: Dictionary, phase: float, reduced_effects: bool) -> bool:
	var wire_id := int(cue.get("source_wire_id", 0))
	if canvas == null or not profiles_by_wire.has(wire_id):
		return false
	var profile: Dictionary = profiles_by_wire[wire_id]
	if not animation_skeletons.skeletons.has(String(profile.get("skeleton_id", ""))):
		return false
	var position: Vector2 = cue.get("position", Vector2.ZERO)
	var start: Vector2 = cue.get("start", position)
	var endpoint: Vector2 = cue.get("end", position)
	var opacity := 1.0 - phase
	var element := String(profile.get("element", "water"))
	var dark := language.element_color(element, "dark")
	var base := language.element_color(element, "base")
	var bright := language.element_color(element, "bright")
	var event_type := String(cue.get("event_type", ""))
	if event_type in ["cast_refused", "cast_blocked"]:
		var refusal_radius := 12.0 + phase * 11.0
		canvas.draw_arc(position, refusal_radius, 0.0, TAU, 20, Color(base, opacity * 0.74), 2.0)
		canvas.draw_line(position + Vector2(-7.0, -7.0), position + Vector2(7.0, 7.0), Color(bright, opacity * 0.88), 2.0)
		canvas.draw_line(position + Vector2(-7.0, 7.0), position + Vector2(7.0, -7.0), Color(bright, opacity * 0.88), 2.0)
		return true
	if event_type == "beam_fired" and String(profile.get("silhouette", "")) == "eclipse_beam":
			var lane := endpoint - start
			var side := lane.normalized().orthogonal() if lane.length_squared() > 0.0 else Vector2.UP
			canvas.draw_line(start, endpoint, Color(dark, opacity * 0.42), 14.0)
			canvas.draw_line(start + side * 3.0, endpoint + side * 3.0, Color(base, opacity * 0.72), 3.0)
			canvas.draw_line(start - side * 3.0, endpoint - side * 3.0, Color(language.element_color("dark", "bright"), opacity * 0.66), 3.0)
			canvas.draw_line(start, endpoint, Color(bright, opacity * 0.92), 1.0)
			_draw_diamond(canvas, endpoint, 10.0 + phase * 8.0, Color(bright, opacity), Color(dark, opacity * 0.28))
			return true
	if event_type == "spray_fired" and String(profile.get("silhouette", "")) == "wave_fan":
			var lane := endpoint - start
			if lane.length_squared() <= 0.0:
				return true
			var direction := lane.normalized()
			var perpendicular := direction.orthogonal()
			var fan_width := lane.length() * 0.46
			var fan := PackedVector2Array([start, endpoint + perpendicular * fan_width, endpoint - perpendicular * fan_width])
			canvas.draw_colored_polygon(fan, Color(dark, opacity * 0.18))
			for offset: float in [-1.0, -0.66, -0.33, 0.0, 0.33, 0.66, 1.0]:
				var target := endpoint + perpendicular * fan_width * offset
				var midpoint := start.lerp(target, 0.58) + perpendicular * sin(offset * PI) * 9.0
				canvas.draw_polyline(PackedVector2Array([start, midpoint, target]), Color(bright if absf(offset) < 0.1 else base, opacity * (0.78 if absf(offset) < 0.1 else 0.42)), 2.0 if not reduced_effects else 1.0, false)
			canvas.draw_arc(start, minf(90.0, lane.length() * 0.34), lane.angle() - 0.43, lane.angle() + 0.43, 18, Color(bright, opacity * 0.82), 3.0)
			return true
	if event_type == "field_triggered" and String(profile.get("impact", "")) == "freeze_star":
		for index: int in range(6):
			var direction := Vector2.from_angle(TAU * float(index) / 6.0)
			canvas.draw_line(position, position + direction * (12.0 + phase * 20.0), Color(bright, opacity), 2.0)
		return true
	if event_type == "spray_hit" and String(profile.get("impact", "")) == "breaker_arc":
		var breaker_radius := 11.0 + phase * 28.0
		canvas.draw_arc(position, breaker_radius, -2.75, -0.39, 18, Color(bright, opacity), 3.0)
		canvas.draw_arc(position, breaker_radius * 0.66, -2.55, -0.59, 14, Color(base, opacity * 0.78), 2.0)
		canvas.draw_line(position + Vector2(-10.0, 2.0), position + Vector2(-17.0 - phase * 8.0, -7.0), Color(base, opacity * 0.72), 2.0)
		canvas.draw_line(position + Vector2(10.0, 2.0), position + Vector2(17.0 + phase * 8.0, -7.0), Color(base, opacity * 0.72), 2.0)
		return true
	if event_type == "projectile_hit":
		if String(profile.get("impact", "")) == "splash_ring":
			var splash_radius := 10.0 + phase * 30.0
			canvas.draw_arc(position, splash_radius, 0.0, TAU, 24, Color(base, opacity * 0.78), 2.0)
			canvas.draw_arc(position, splash_radius * 0.72, -2.8, -0.2, 18, Color(bright, opacity), 3.0)
			for side_value: float in [-1.0, 0.0, 1.0]:
				canvas.draw_line(position + Vector2(side_value * 5.0, 0), position + Vector2(side_value * 13.0, -11.0 - phase * 11.0), Color(bright, opacity * 0.82), 2.0)
		else:
			canvas.draw_arc(position, 9.0 + phase * 20.0, -2.4, 0.7, 18, Color(base, opacity), 3.0)
			canvas.draw_arc(position, 9.0 + phase * 20.0, 0.7, 3.84, 18, Color(language.element_color("light", "bright"), opacity * 0.72), 2.0)
		return true
	return false


static func _draw_diamond(canvas: CanvasItem, center: Vector2, radius: float, outline: Color, fill: Color) -> void:
	var points := PackedVector2Array([center + Vector2(0, -radius), center + Vector2(radius, 0), center + Vector2(0, radius), center + Vector2(-radius, 0)])
	canvas.draw_colored_polygon(points, fill)
	canvas.draw_polyline(_closed(points), outline, 2.0, false)


static func _closed(points: PackedVector2Array) -> PackedVector2Array:
	var output := points.duplicate()
	if not output.is_empty():
		output.append(output[0])
	return output


func _fail(message: String) -> bool:
	last_error = message
	return false
