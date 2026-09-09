class_name ElementChemistryPresenter
extends RefCounted

# Shared native-size material, with authority-owned occupied masks. Occupied
# material itself communicates area; no separate range rings or outlines.
const ELEMENTS: Array[String] = ["", "earth", "fire", "water", "wind", "ice", "charge", "light", "dark"]
const LINE_SHAPES: Array[String] = ["corridor", "front", "growing_strip", "pulse_lane", "bands", "reveal_line", "water_path", "frost_path", "branch"]
const LINK_SHAPES := ["water_path", "frost_path", "branch"]
const Library = preload("res://src/presentation/pixel_magic_library.gd")
const Mask = preload("res://src/presentation/pixel_effect_geometry.gd")
const Reaction = preload("res://src/sim/chemistry/element_reaction_state.gd")
const Chemistry = preload("res://src/sim/chemistry/element_chemistry_system.gd")
const INK := Color("16212a")
const CELL_SIZE := 32.0
const FOOTPRINT_STEP := 16.0
const FOOTPRINT_CACHE_LIMIT := 64
const FOOTPRINT_CELL_LIMIT := 512
# Compact reusable native-cell compositions, not enlarged material or new
# occupied geometry. Their stronger centre survives every decoration budget.
const DEPOSIT_ACCENTS := {
	1: [Vector2(-7, 3), Vector2(7, 3)], # Earth: low weighted pile.
	2: [Vector2(-7, 2), Vector2(6, -3)], # Fire: unequal rising tongues.
	3: [Vector2(-9, 2), Vector2(9, 2)], # Water: broad connected crests.
	4: [Vector2(-10, 4), Vector2(9, -4)], # Wind: an open diagonal sweep.
	5: [Vector2(-7, -2), Vector2(7, -2)], # Ice: a quiet facet cluster.
	6: [Vector2(-8, 5), Vector2(7, -5)], # Charge: stepped contacts.
	7: [Vector2(-10, 0), Vector2(10, 0)], # Light: measured side glints.
	8: [Vector2(-7, -4), Vector2(7, 4)], # Dark: offset inward wisps.
}
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
var _footprints: Dictionary = {}
var _unlinked_proxy := Reaction.new()
var _stats := {"optional_stamps": 0, "core_stamps": 0, "footprint_cells": 0, "boundary_loops": 0, "boundary_markers": 0, "clipped_parts": 0, "culled": 0}


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


static func deposit_role_profile(trail: bool, reduced: bool = false) -> Dictionary:
	# Plain elemental matter is an ingredient, never passive damage or status.
	# Keep a readable native identity while its tiled ground area is quieter
	# than active reaction material. Accessibility filters do not change roles.
	return {"material_role": "optional_trail" if trail else "terminal_ingredient",
		"deals_damage": false, "applies_status": false,
		"core_opacity": (0.62 if reduced else 0.68) if trail else (0.82 if reduced else 0.88),
		"material_opacity": (0.24 if reduced else 0.30) if trail else (0.36 if reduced else 0.50),
		"accent_limit": 0 if trail else (1 if reduced else 2)}


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
	var role := deposit_role_profile(deposit.is_trail(), reduced)
	return {"kind": "deposit", "element": element, "asset_id": asset_id, "frame": library.sample(asset_id, now - start), "phase": phase, "age_ticks": now - start, "mask": mask, "core_anchor": _core_anchor(mask, position), "opacity": opacity, "core_opacity": opacity * float(role.core_opacity), "material_opacity": opacity * float(role.material_opacity), "material_role": role.material_role, "deals_damage": role.deals_damage, "applies_status": role.applies_status, "accent_limit": role.accent_limit, "edge_color": language.element_color(ELEMENTS[element]), "reduced": reduced, "unlinked": false, "socket": false}


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
	var concealing: bool = state.active(now) and Chemistry._concealing(state, now, _config)
	# Keep the authored warning/decay phases and exact boundary intact. Only
	# active Steam thinning / Shadowdraft gaps use a lighter material cue.
	var veil_multiplier := 0.25 if phase == "active" and int(state.recipe_wire_id) in [310, 326] and not concealing else 1.0
	return {"kind": "reaction", "recipe_wire_id": int(state.recipe_wire_id), "asset_id": asset_id, "frame": library.sample(asset_id, now - start), "phase": phase, "age_ticks": now - start, "mask": mask, "material_path": _material_path(effective, shape), "core_anchor": position if socket else _core_anchor(mask, mask["hail_position"] if shape == "pulse_lane" else position), "opacity": opacity, "material_opacity": opacity * float(composition["opacity_cap_reduced" if reduced else "opacity_cap_normal"]) * veil_multiplier, "concealing": concealing, "edge_color": edge, "reduced": reduced, "unlinked": unlinked, "socket": socket}


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
		# Native material coverage is essential information, not decorative
		# admission: normal/reduced/zero-budget modes retain the same cells.
		var cell_index := 0
		for cell: Dictionary in footprint_cells(model):
			var sampled := decoration_frame(model, cell_index)
			var offset: Vector2 = sampled.region.position / sampled.texture.get_size()
			for part: Dictionary in cell.parts:
				Mask.draw_frame_part(canvas, part, sampled.texture, float(model["material_opacity"]), offset)
				_stats.clipped_parts += 1
			_stats.footprint_cells += 1
			cell_index += 1
		var accent_index := 0
		for anchor: Vector2 in accent_anchors(model):
			if not _take_optional(String(model["asset_id"]), bool(model["reduced"])):
				break
			accent_index += 1
			_stats.clipped_parts += Mask.draw_clipped_frame(canvas, decoration_frame(model, accent_index), anchor, polygons, float(model["material_opacity"]))
		# One native identity stamp stays stronger than optional ground texture.
		# Reaction/veil values intentionally retain their separate phase contract.
		_stats.clipped_parts += Mask.draw_clipped_frame(canvas, frame, core, polygons, float(model.get("core_opacity", model["material_opacity"])))
		_stats.core_stamps += 1
	return true


func accent_anchors(model: Dictionary) -> PackedVector2Array:
	var result := PackedVector2Array()
	if model.is_empty() or bool(model.get("socket", false)):
		return result
	var offsets: Array = DEPOSIT_ACCENTS.get(int(model.get("element", 0)), []) if model["kind"] == "deposit" else []
	var count := mini(offsets.size(), int(model.get("accent_limit", 1 if bool(model["reduced"]) else 2)))
	for index: int in range(count):
		var anchor: Vector2 = model["core_anchor"] + offsets[index]
		if Mask.contains_point(model["mask"]["polygons"], anchor):
			result.append(anchor)
	return result


func decoration_frame(model: Dictionary, index: int) -> Dictionary:
	# Only looped active material is staggered. Formation/decay still sample
	# their exact phase age; material can never pre-form or survive expiry.
	var staggered := int(model.get("element", 0)) == 2 or int(model.get("recipe_wire_id", 0)) == 310
	if model.get("phase", "") != "active" or not staggered:
		return model.get("frame", {})
	return library.sample(String(model["asset_id"]), int(model["age_ticks"]) + maxi(0, index) * 7)


func footprint_cells(model: Dictionary) -> Array:
	if model.is_empty() or bool(model.get("socket", false)) or (model.get("frame", {}) as Dictionary).is_empty():
		return []
	var mask: Dictionary = model["mask"]
	var frame: Dictionary = model["frame"]
	var bounds: Rect2 = mask["bounds"]
	if _viewport.has_area():
		bounds = bounds.intersection(_viewport)
	if not bounds.has_area():
		return []
	var signature := [mask["polygons"], bounds, frame.region.size, frame.pivot, frame.texture.get_size()]
	var key := hash(signature)
	if _footprints.has(key) and _footprints[key].signature == signature:
		return _footprints[key].cells
	var result: Array = []
	var step := FOOTPRINT_STEP
	bounds = bounds.grow(CELL_SIZE * 0.5)
	while (ceili(bounds.size.x / step) + 2) * (ceili(bounds.size.y / step) + 2) > FOOTPRINT_CELL_LIMIT:
		if step >= CELL_SIZE:
			break # Never create uncovered gaps between native32px cells.
		step += FOOTPRINT_STEP
	var first := Vector2i(floor(bounds.position.x / step), floor(bounds.position.y / step))
	var last := Vector2i(ceil(bounds.end.x / step), ceil(bounds.end.y / step))
	# Cache exact clipped cells with local UVs; phase changes only translate UVs
	# into the next native atlas frame, never rebuild world clipping geometry.
	var local_frame := {"texture": frame.texture, "region": Rect2(Vector2.ZERO, frame.region.size), "pivot": frame.pivot}
	for y: int in range(first.y, last.y):
		for x: int in range(first.x, last.x):
			var anchor: Vector2 = (Vector2(x, y) + Vector2(0.5, 0.5)) * step + frame.pivot - frame.region.size * 0.5
			var parts := Mask.clipped_frame_parts(local_frame, anchor, mask["polygons"])
			if not parts.is_empty():
				result.append({"anchor": anchor, "parts": parts})
	if _footprints.size() >= FOOTPRINT_CACHE_LIMIT:
		_footprints.erase(_footprints.keys()[0])
	_footprints[key] = {"signature": signature, "cells": result}
	return result


func tile_anchors(mask: Dictionary, core: Vector2, reduced: bool, maximum: int, material_path: PackedVector2Array = PackedVector2Array()) -> PackedVector2Array:
	var result := PackedVector2Array()
	if mask.is_empty() or maximum <= 0:
		return result
	# Thin strips can fall between every world-grid centre. Place their native
	# material on the real centreline, then retain the same exact mask clipping.
	# Reduced mode is a deterministic subset; no link or optical ray is invented.
	if material_path.size() >= 2:
		var examined := 0
		for segment: int in range(material_path.size() - 1):
			var start := material_path[segment]
			var lane := material_path[segment + 1] - start
			var length := lane.length()
			var direction := lane / length if length > 0.0 else Vector2.ZERO
			for index: int in range(ceili(length / CELL_SIZE) + 1):
				examined += 1
				if examined > 1024 or result.size() >= mini(maximum, 192):
					return result
				if reduced and posmod(index, 2) != 0:
					continue
				var anchor := start + direction * minf(float(index) * CELL_SIZE, length)
				if anchor.is_equal_approx(core) or result.has(anchor) or (_viewport.has_area() and not _viewport.has_point(anchor)) or not Mask.contains_point(mask["polygons"], anchor):
					continue
				result.append(anchor)
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


static func _material_path(state: RefCounted, shape: String) -> PackedVector2Array:
	var result := PackedVector2Array()
	if int(state.radius) > int(CELL_SIZE * 500.0):
		return result # Broad regions retain their sparse world-locked interior.
	if shape in LINK_SHAPES:
		for index: int in range(0, state.path_points.size() - 1, 2):
			result.append(Vector2(state.path_points[index], state.path_points[index + 1]) / 1000.0)
	elif shape in ["corridor", "front", "growing_strip", "bands", "reveal_line"]:
		result.append(Vector2(state.position_x, state.position_y) / 1000.0)
		result.append(Vector2(state.endpoint_x, state.endpoint_y) / 1000.0)
	elif shape in ["cover", "plane", "lens"]:
		var origin := Vector2(state.position_x, state.position_y) / 1000.0
		var side := Vector2(-state.direction_y, state.direction_x) * float(state.length) / 2000000.0
		result.append(origin - side)
		result.append(origin + side)
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
