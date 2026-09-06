class_name ElementChemistryPresenter
extends RefCounted

# Shared native-size material, with authority-owned occupied masks. Exact edges
# and one identity core never compete with optional decorative density.
const ELEMENTS: Array[String] = ["", "earth", "fire", "water", "wind", "ice", "charge", "light", "dark"]
const LINE_SHAPES: Array[String] = ["corridor", "front", "growing_strip", "pulse_lane", "bands", "reveal_line", "water_path", "frost_path", "branch"]
const LINK_SHAPES := ["water_path", "frost_path", "branch"]
const Library = preload("res://src/presentation/pixel_magic_library.gd")
const Mask = preload("res://src/presentation/pixel_effect_geometry.gd")
const Reaction = preload("res://src/sim/chemistry/element_reaction_state.gd")
const INK := Color("16212a")
const CELL_SIZE := 32.0
var language: VisualLanguage
var library: PixelMagicLibrary
var last_error := ""
var _masks := Mask.new()
var _config := SimConfig.new(120)
var _collision: CollisionWorld
var _viewport := Rect2()
var _deposits_by_id: Dictionary = {}
var _reduced := false
var _optional_limit := 192
var _unlinked_proxy := Reaction.new()
var _stats := {"optional_stamps": 0, "core_stamps": 0, "boundary_loops": 0, "boundary_markers": 0, "clipped_parts": 0, "culled": 0}


func configure(visual_language: VisualLanguage, shared_library: PixelMagicLibrary = null) -> bool:
	last_error = ""
	language = null
	library = null
	if visual_language == null or visual_language.elements.is_empty():
		last_error = "Element chemistry requires validated visual tokens"
		return false
	var candidate := shared_library if shared_library != null else Library.default_library()
	if candidate.asset_count() != 474 or candidate.page_count() != 3:
		last_error = "Element chemistry pixel pack is unavailable: %s" % candidate.last_error
		return false
	language = visual_language
	library = candidate
	return true


func begin_frame(config: SimConfig, collision: CollisionWorld, viewport_world: Rect2, deposits: Array, reduced: bool = false) -> void:
	_config = config if config != null else _config
	_collision = collision
	_viewport = viewport_world if viewport_world.position.is_finite() and viewport_world.size.is_finite() else Rect2()
	_reduced = reduced
	_optional_limit = 96 if reduced else 192
	_deposits_by_id.clear()
	for deposit: RefCounted in deposits:
		if deposit != null and int(deposit.strength) > 0:
			_deposits_by_id[int(deposit.entity_id)] = deposit
	for key: String in _stats:
		_stats[key] = 0


func stats() -> Dictionary:
	var result := _stats.duplicate()
	result["optional_limit"] = _optional_limit
	result["geometry"] = _masks.stats()
	return result


static func phase_at(state: RefCounted, tick: float) -> String:
	if state == null or not is_finite(tick) or tick < state.created_tick or tick >= state.expiry_tick:
		return "expired"
	if tick < state.active_tick:
		return "forming"
	return "active" if tick < state.decay_tick else "decaying"


static func phase_opacity(state: RefCounted, tick: float) -> float:
	var phase := phase_at(state, tick)
	if phase == "expired":
		return 0.0
	if phase == "forming":
		return 0.35 + 0.65 * clampf((tick - float(state.created_tick)) / maxf(1.0, float(state.active_tick - state.created_tick)), 0.0, 1.0)
	if phase == "decaying":
		return clampf((float(state.expiry_tick) - tick) / maxf(1.0, float(state.expiry_tick - state.decay_tick)), 0.0, 1.0)
	return 1.0


static func geometry(state: RefCounted, recipe: Dictionary) -> Dictionary:
	if state == null or recipe.is_empty() or int(recipe.get("wire_id", -1)) != state.recipe_wire_id:
		return {}
	var direction := Vector2(state.direction_x, state.direction_y).normalized()
	if direction.length_squared() < 0.5:
		direction = Vector2.RIGHT
	var position := Vector2(state.position_x, state.position_y) / 1000.0
	var endpoint := Vector2(state.endpoint_x, state.endpoint_y) / 1000.0
	var radius := maxf(0.0, float(state.radius) / 1000.0)
	var length := maxf(0.0, float(state.length) / 1000.0)
	return {"position": position, "endpoint": endpoint, "direction": direction, "normal": direction.orthogonal(), "radius": radius, "length": length, "inner_radius": length if String(recipe.get("shape", "")) in ["ring", "annulus"] else 0.0, "shape": String(recipe.get("shape", "")), "id": String(recipe.get("id", ""))}


static func hail_position(state: RefCounted, tick: float) -> Vector2:
	if state == null or not is_finite(tick):
		return Vector2.ZERO
	# Source pulse uses direction * length, never a decorative endpoint lerp.
	var age := maxi(0, int(floor(tick)) - int(state.active_tick)) % 54
	@warning_ignore("integer_division")
	var distance: int = int(state.length) * age / 54
	@warning_ignore("integer_division")
	var delta := Vector2i(int(state.direction_x) * distance / 1000, int(state.direction_y) * distance / 1000)
	return Vector2(state.position_x, state.position_y) / 1000.0 + Vector2(delta) / 1000.0


func deposit_model(deposit: RefCounted, tick: float, reduced_effects: bool = false) -> Dictionary:
	if library == null or deposit == null or not is_finite(tick) or tick < deposit.created_tick or tick >= deposit.expiry_tick or int(deposit.strength) <= 0:
		return {}
	var element := int(deposit.element_wire_id)
	if element < 1 or element > 8:
		return {}
	var position := Vector2(deposit.position_x, deposit.position_y) / 1000.0
	var radius := maxf(0.0, float(deposit.radius) / 1000.0)
	if not _visible(Rect2(position - Vector2.ONE * radius, Vector2.ONE * radius * 2.0)):
		return {}
	var reduced := reduced_effects or _reduced
	var formation_id := Library.element_asset_id(element, "deposit_formation", reduced)
	var decay_id := Library.element_asset_id(element, "deposit_decay", reduced)
	var quarter_life := floori(float(int(deposit.expiry_tick) - int(deposit.created_tick)) * 0.25)
	var formation_ticks := mini(int(library.asset(formation_id)["total_ticks"]), quarter_life)
	var decay_ticks := mini(int(library.asset(decay_id)["total_ticks"]), quarter_life)
	var now := int(floor(tick))
	var phase := "formation" if now < int(deposit.created_tick) + formation_ticks else "decay" if now >= int(deposit.expiry_tick) - decay_ticks else "active"
	var start := int(deposit.created_tick) if phase == "formation" else int(deposit.expiry_tick) - decay_ticks if phase == "decay" else int(deposit.created_tick) + formation_ticks
	var asset_id := Library.element_asset_id(element, "deposit_" + phase, reduced)
	var mask := _masks.disk_mask(position, radius, _collision)
	if mask.is_empty() or (mask["polygons"] as Array).is_empty():
		return {}
	var opacity := clampf((float(deposit.expiry_tick) - tick) / maxf(1.0, float(decay_ticks)), 0.0, 1.0)
	return {"kind": "deposit", "asset_id": asset_id, "frame": library.sample(asset_id, now - start), "phase": phase, "age_ticks": now - start, "mask": mask, "core_anchor": _core_anchor(mask, position), "opacity": opacity, "material_opacity": opacity * (0.48 if reduced else 0.68), "edge_color": language.element_color(ELEMENTS[element]), "reduced": reduced, "unlinked": false, "socket": false}


func reaction_model(state: RefCounted, recipe: Dictionary, tick: float, reduced_effects: bool = false) -> Dictionary:
	if library == null or geometry(state, recipe).is_empty():
		return {}
	var phase_label := phase_at(state, tick)
	if phase_label == "expired":
		return {}
	var now := int(floor(tick))
	var phase := "formation" if phase_label == "forming" else "decay" if phase_label == "decaying" else "active"
	var start := int(state.created_tick) if phase == "formation" else int(state.active_tick) if phase == "active" else int(state.decay_tick)
	var reduced := reduced_effects or _reduced
	var position := Vector2(state.position_x, state.position_y) / 1000.0
	var shape := String(recipe.get("shape", ""))
	var unlinked := shape in LINK_SHAPES and not _links_live(state, now)
	var effective := _without_path(state) if unlinked else state
	if not _visible(Mask._extent(effective, shape, position, float(state.radius) / 1000.0)):
		return {}
	var mask := _masks.reaction_mask(effective, recipe, now, _config, _collision)
	if mask.is_empty():
		return {}
	var socket := unlinked and (mask["polygons"] as Array).is_empty()
	if (mask["polygons"] as Array).is_empty() and not socket:
		return {}
	if socket and _collision != null and not _collision.can_occupy(Vector2i(position * 1000.0), 0):
		return {}
	var asset_id := library.reaction_asset_id(state.recipe_wire_id, phase, reduced)
	var metadata := library.reaction(state.recipe_wire_id)
	var composition: Dictionary = metadata["composition"]
	var elements: Array = recipe.get("elements", [])
	if elements.size() != 2 or int(elements[0]) < 1 or int(elements[0]) > 8:
		return {}
	var edge := language.element_color(ELEMENTS[int(elements[0])])
	if int(state.recipe_wire_id) == 310:
		edge = Color("becfc7")
	var opacity := phase_opacity(state, tick)
	return {"kind": "reaction", "asset_id": asset_id, "frame": library.sample(asset_id, now - start), "phase": phase, "age_ticks": now - start, "mask": mask, "core_anchor": position if socket else _core_anchor(mask, mask["hail_position"] if shape == "pulse_lane" else position), "opacity": opacity, "material_opacity": opacity * float(composition["opacity_cap_reduced" if reduced else "opacity_cap_normal"]), "edge_color": edge, "reduced": reduced, "unlinked": unlinked, "socket": socket}


func draw_deposit(canvas: CanvasItem, deposit: RefCounted, tick: float, reduced_effects: bool = false) -> bool:
	return _draw_model(canvas, deposit_model(deposit, tick, reduced_effects)) if canvas != null else false


func draw_reaction(canvas: CanvasItem, reaction: RefCounted, recipe: Dictionary, tick: float, reduced_effects: bool = false) -> bool:
	return _draw_model(canvas, reaction_model(reaction, recipe, tick, reduced_effects)) if canvas != null else false


func _draw_model(canvas: CanvasItem, model: Dictionary) -> bool:
	if canvas == null or model.is_empty():
		return false
	canvas.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var mask: Dictionary = model["mask"]
	var polygons: Array = mask["polygons"]
	var core: Vector2 = model["core_anchor"]
	if bool(model["socket"]):
		var socket_id := "magic.geometry.unconnected_node.%s" % ("reduced" if model["reduced"] else "normal")
		if library.draw_stamp(canvas, socket_id, core, 0, 0.0, float(model["opacity"])):
			_stats.core_stamps += 1
		return true
	var frame: Dictionary = model["frame"]
	if not frame.is_empty():
		_stats.clipped_parts += Mask.draw_clipped_frame(canvas, frame, core, polygons, float(model["material_opacity"]))
		_stats.core_stamps += 1
		var remaining := mini(library.decoration_remaining(), maxi(0, (96 if model["reduced"] else _optional_limit) - int(_stats.optional_stamps)))
		for anchor: Vector2 in tile_anchors(mask, core, bool(model["reduced"]), remaining):
			if not _take_optional(String(model["asset_id"]), bool(model["reduced"])):
				break
			_stats.clipped_parts += Mask.draw_clipped_frame(canvas, frame, anchor, polygons, float(model["material_opacity"]))
	_draw_boundaries(canvas, model)
	return true


func _draw_boundaries(canvas: CanvasItem, model: Dictionary) -> void:
	var mask: Dictionary = model["mask"]
	var color: Color = model["edge_color"]
	var opacity := float(model["opacity"])
	var marker_id := "magic.geometry.boundary_%s.%s" % [model["phase"], "reduced" if model["reduced"] else "normal"]
	var frame := library.sample(marker_id, int(model["age_ticks"]))
	for boundary: PackedVector2Array in mask["boundaries"]:
		# Thin source geometry is essential information, never optional material
		# or an invented optical ray. Both safe-annulus edges remain visible.
		canvas.draw_polyline(boundary, Color(INK, opacity * 0.8), 2.0, false)
		canvas.draw_polyline(boundary, Color(color, opacity * 0.9), 1.0, false)
		_stats.boundary_loops += 1
		if not frame.is_empty() and boundary.size() >= 2:
			_stats.clipped_parts += Mask.draw_clipped_frame(canvas, frame, boundary[0], mask["polygons"], opacity, (boundary[1] - boundary[0]).angle())
			_stats.boundary_markers += 1


func tile_anchors(mask: Dictionary, core: Vector2, reduced: bool, maximum: int) -> PackedVector2Array:
	var result := PackedVector2Array()
	if mask.is_empty() or maximum <= 0:
		return result
	var bounds: Rect2 = mask["bounds"]
	if _viewport.has_area():
		bounds = bounds.intersection(_viewport)
	var first := Vector2i(floor(bounds.position.x / CELL_SIZE), floor(bounds.position.y / CELL_SIZE))
	var last := Vector2i(ceil(bounds.end.x / CELL_SIZE), ceil(bounds.end.y / CELL_SIZE))
	var examined := 0
	for y: int in range(first.y, last.y):
		for x: int in range(first.x, last.x):
			examined += 1
			if examined > 1024 or result.size() >= mini(maximum, 192):
				return result
			if reduced and posmod(x + y, 2) != 0:
				continue
			var anchor := Vector2(float(x) + 0.5, float(y) + 0.5) * CELL_SIZE
			if anchor.distance_squared_to(core) < CELL_SIZE * CELL_SIZE or not Mask.contains_point(mask["polygons"], anchor):
				continue
			result.append(anchor)
	return result


func _take_optional(asset_id: String, reduced: bool) -> bool:
	_optional_limit = mini(_optional_limit, 96 if reduced else 192)
	if int(_stats.optional_stamps) >= _optional_limit or not library.take_decoration(asset_id):
		return false
	_stats.optional_stamps += 1
	return true


func _links_live(state: RefCounted, tick: int) -> bool:
	if state.path_points.size() < 4 or state.linked_deposit_ids.is_empty():
		return false
	for identifier: int in state.linked_deposit_ids:
		var deposit: RefCounted = _deposits_by_id.get(identifier)
		if deposit == null or int(deposit.strength) <= 0 or tick < deposit.created_tick or tick >= deposit.expiry_tick:
			return false
	return true


func _without_path(state: RefCounted) -> RefCounted:
	for field: String in ["recipe_wire_id", "position_x", "position_y", "direction_x", "direction_y", "radius", "length", "endpoint_x", "endpoint_y", "created_tick", "active_tick", "decay_tick", "expiry_tick"]:
		_unlinked_proxy.set(field, state.get(field))
	_unlinked_proxy.path_points = PackedInt64Array()
	return _unlinked_proxy


func _visible(bounds: Rect2) -> bool:
	var visible := not _viewport.has_area() or _viewport.intersects(bounds, true)
	if not visible:
		_stats.culled += 1
	return visible


func _core_anchor(mask: Dictionary, preferred: Vector2) -> Vector2:
	var polygons: Array = mask["polygons"]
	if (not _viewport.has_area() or _viewport.has_point(preferred)) and Mask.contains_point(polygons, preferred):
		return preferred
	for polygon: PackedVector2Array in polygons:
		var candidates: Array = [polygon]
		if _viewport.has_area():
			candidates = Geometry2D.intersect_polygons(polygon, Mask.rectangle_polygon(_viewport))
		for candidate: PackedVector2Array in candidates:
			if candidate.size() < 3:
				continue
			var center := Vector2.ZERO
			for point: Vector2 in candidate:
				center += point
			return center / float(candidate.size())
	return preferred
