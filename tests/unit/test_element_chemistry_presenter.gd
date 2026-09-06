extends FluxTestSuite

const Presenter = preload("res://src/presentation/element_chemistry_presenter.gd")
const Chemistry = preload("res://src/sim/chemistry/element_chemistry_system.gd")
const Reaction = preload("res://src/sim/chemistry/element_reaction_state.gd")
const Deposit = preload("res://src/sim/chemistry/element_deposit_state.gd")
const Reticle = preload("res://src/presentation/aim_reticle_presenter.gd")

func run() -> int:
	var language := VisualLanguage.new()
	check(language.load_from_file(), "chemistry visual language loads")
	var presenter := Presenter.new()
	check(not presenter.configure(null), "chemistry rendering refuses missing visual tokens")
	check(presenter.configure(language), "chemistry rendering uses canonical element palette")
	var identities := {}
	for wire: int in range(301,337):
		var recipe := Chemistry.recipe(wire)
		var state := Reaction.new()
		state.recipe_wire_id = wire
		state.position_x = 123000
		state.position_y = 234000
		state.endpoint_x = 323000
		state.endpoint_y = 234000
		state.direction_x = 1000
		state.radius = int(recipe.radius) / 2
		state.length = int(recipe.length) / 2
		state.created_tick = 10
		state.active_tick = 30
		state.decay_tick = 300
		state.expiry_tick = 360
		var before := state.canonical_values()
		var g := Presenter.geometry(state,recipe)
		equal(g.position,Vector2(123,234),"recipe %d uses actual moving authority origin" % wire)
		equal(g.endpoint,Vector2(323,234),"recipe %d uses authoritative endpoint" % wire)
		equal(g.radius,float(state.radius)/1000.0,"recipe %d uses current grown radius, not final authored radius" % wire)
		equal(g.length,float(state.length)/1000.0,"recipe %d uses actual length" % wire)
		check(not identities.has(g.id),"recipe %d has distinct rendered identity" % wire)
		identities[g.id] = true
		equal(Presenter.phase_at(state,9),"expired","unborn matter is not shown")
		equal(Presenter.phase_at(state,10),"forming","formation is explicit")
		equal(Presenter.phase_at(state,30),"active","active phase starts at authority tick")
		equal(Presenter.phase_at(state,300),"decaying","decay begins at authority tick")
		equal(Presenter.phase_at(state,360),"expired","expired matter is never shown")
		equal(Presenter.phase_opacity(state,360),0.0,"expired opacity is exactly zero")
		check(Presenter.phase_opacity(state,330) < Presenter.phase_opacity(state,300),"decay visibly reduces opacity")
		check(not presenter.draw_reaction(null,state,recipe,30),"null canvas cannot accidentally mutate chemistry")
		equal(state.canonical_values(),before,"presentation queries cannot change game state")
		check(Presenter.geometry(state,Chemistry.recipe(301 if wire!=301 else 302)).is_empty(),"mismatched recipe fails closed")
	equal(identities.size(),36,"all thirty-six reactions are represented")
	check("front" in Presenter.LINE_SHAPES,"Magma uses the authority corridor, not a perpendicular invented ridge")
	var ring := Reaction.new()
	ring.recipe_wire_id = 309
	ring.radius = 72000
	ring.length = 24000
	equal(Presenter.geometry(ring,Chemistry.recipe(309)).inner_radius,24.0,"Conflagration safe hole uses inner radius, not thickness subtraction")
	var hail := Reaction.new()
	hail.position_x = 10000
	hail.endpoint_x = 110000
	hail.length = 100000
	hail.active_tick = 20
	equal(Presenter.hail_position(hail,20),Vector2(10,0),"single hail pulse starts at authoritative activation")
	equal(Presenter.hail_position(hail,47),Vector2(60,0),"single hail pulse reaches halfway after225ms")
	equal(Presenter.hail_position(hail,74),Vector2(10,0),"single hail pulse restarts exactly every450ms")
	for wire: int in range(1,9):
		var deposit := Deposit.new()
		deposit.element_wire_id = wire
		check(not presenter.draw_deposit(null,deposit,0),"deposit draw refuses missing canvas")
	for direction: Vector2 in [Vector2.RIGHT,Vector2.DOWN,Vector2.ZERO]:
		var lines := Reticle.segments(Vector2(640,360),direction)
		equal(lines.size(),5,"reticle preserves a four-arm open centre and direction tail")
		for line: PackedVector2Array in lines:
			for p: Vector2 in line:
				check(p.distance_to(Vector2(640,360)) >= 4,"reticle leaves target centre unobscured")
	check(Reticle.segments(Vector2(INF,0)).is_empty(),"reticle rejects invalid screen location")
	_test_pixel_phases_and_native_cells(presenter)
	_test_live_links_and_worldbone(presenter)
	_test_budget_culling_and_information(presenter)
	var empty_library := PixelMagicLibrary.new()
	check(not Presenter.new().configure(language, empty_library), "invalid pixel library cannot silently fall back to old chemistry visuals")
	return finish("element-chemistry-presenter")


func _state(wire: int) -> ElementReactionState:
	var definition := Chemistry.recipe(wire)
	var deposits: Array = []
	for index: int in range(2):
		Chemistry.deposit_terminal(deposits, 3000 + index, 1000 + index, 100, 1, 1, int(definition.elements[index]), Vector2i(500000, 500000), 0, SimConfig.new())
	return Chemistry.form_reaction(deposits[0], deposits[1], 4000, 0, SimConfig.new())


func _test_pixel_phases_and_native_cells(presenter: ElementChemistryPresenter) -> void:
	presenter.begin_frame(SimConfig.new(), null, Rect2(), [])
	for wire: int in range(301, 337):
		var state := _state(wire)
		var before := state.canonical_values()
		var definition := Chemistry.recipe(wire)
		for reduced: bool in [false, true]:
			for phase: String in ["formation", "active", "decay"]:
				var tick := state.created_tick if phase == "formation" else state.active_tick if phase == "active" else state.decay_tick
				var model := presenter.reaction_model(state, definition, tick, reduced)
				check(not model.is_empty(), "all36 reactions have visible authored phase models")
				if model.is_empty():
					continue
				equal(model.asset_id, "magic.reaction.%s.%s.%s" % [definition.id, phase, "reduced" if reduced else "normal"], "reaction selects its distinct material and exact accessibility phase")
				equal(model.age_ticks, 0, "phase change immediately selects its first authored key pose")
				equal(model.frame.index, 0, "absolute first pose never delays behind another animation")
				equal(model.frame.size, Vector2(32, 32), "material cells remain native32px instead of stretching across gameplay geometry")
				if not model.socket:
					check(PixelEffectGeometry.contains_point(model.mask.polygons, model.core_anchor), "essential identity core is anchored inside actual occupied geometry")
		check(presenter.reaction_model(state, definition, state.created_tick - 1).is_empty(), "unborn effect has no pixel material")
		check(presenter.reaction_model(state, definition, state.expiry_tick).is_empty(), "authority expiry immediately removes material and boundaries")
		equal(state.canonical_values(), before, "phase sampling never mutates reaction state")
	for element: int in range(1, 9):
		var values: Array = []
		Chemistry.deposit_terminal(values, 3010, 1010, 100, 1, 1, element, Vector2i(500000, 500000), 0, SimConfig.new())
		var deposit: ElementDepositState = values[0]
		var before := deposit.canonical_values()
		var first := presenter.deposit_model(deposit, 0)
		var active := presenter.deposit_model(deposit, 100)
		var decay := presenter.deposit_model(deposit, deposit.expiry_tick - 1)
		equal(first.phase, "formation", "deposit uses authored immediate formation")
		equal(active.phase, "active", "deposit switches to actual remaining-lifetime material loop")
		equal(decay.phase, "decay", "finite deposit ends with its authored decay")
		equal(first.frame.size, Vector2(32, 32), "deposit never grows a fake tall collision pillar")
		check(presenter.deposit_model(deposit, deposit.expiry_tick).is_empty(), "deposit pixels stop exactly at expiry")
		deposit.strength = 0
		check(presenter.deposit_model(deposit, 0).is_empty(), "consumed deposit disappears immediately")
		deposit.strength = 1000
		equal(deposit.canonical_values(), before, "deposit artwork owns no gameplay fields")
	var hail := _state(323)
	hail.endpoint_y += 20000
	var hail_model := presenter.reaction_model(hail, Chemistry.recipe(323), hail.active_tick + 27)
	equal(hail_model.mask.hail_position, Presenter.hail_position(hail, hail.active_tick + 27), "display helper agrees with actual single-pulse geometry despite noncollinear endpoint")
	check(not PixelEffectGeometry.contains_point(hail_model.mask.polygons, Vector2(510, 500)), "warning lane does not become a string of active hail projectiles")
	var steam := _state(310)
	var steam_model := presenter.reaction_model(steam, Chemistry.recipe(310), steam.active_tick)
	equal(steam_model.edge_color, Color("becfc7"), "Steam keeps neutral pale information color, never Fire orange")


func _test_live_links_and_worldbone(presenter: ElementChemistryPresenter) -> void:
	var config := SimConfig.new()
	for wire: int in [313, 319, 328]:
		var state := _state(wire)
		state.path_points = PackedInt64Array([500000, 500000, 600000, 500000])
		state.linked_deposit_ids = PackedInt64Array([3010])
		var deposit := Deposit.new()
		deposit.entity_id = 3010
		deposit.strength = 1000
		deposit.expiry_tick = 500
		var before := state.canonical_values()
		presenter.begin_frame(config, null, Rect2(), [deposit])
		var linked := presenter.reaction_model(state, Chemistry.recipe(wire), state.active_tick)
		check(not linked.unlinked and PixelEffectGeometry.contains_point(linked.mask.polygons, Vector2(560, 500)), "live deposit sustains only the actual stored connection")
		presenter.begin_frame(config, null, Rect2(), [])
		var missing := presenter.reaction_model(state, Chemistry.recipe(wire), state.active_tick)
		check(missing.unlinked and not PixelEffectGeometry.contains_point(missing.mask.polygons, Vector2(560, 500)), "missing source removes stale active connection immediately")
		equal(missing.socket, wire != 319, "only unlinked Water retains local material; Frost/Plasma show an unconnected socket")
		equal(PixelEffectGeometry.contains_point(missing.mask.polygons, Vector2(500, 500)), wire == 319, "Water local disk and inactive Frost/Plasma remain distinct")
		presenter.begin_frame(config, null, Rect2(), [deposit])
		deposit.expiry_tick = state.active_tick
		check(presenter.reaction_model(state, Chemistry.recipe(wire), state.active_tick).unlinked, "exact source expiry is not kept alive by cached geometry")
		equal(state.canonical_values(), before, "clearing a stale render path never erases the authoritative path history")
	var collision := CollisionWorld.new(1000000, 1000000)
	collision.add_obstacle(CollisionWorld.Obstacle.new(1, 520000, 480000, 528000, 520000))
	presenter.begin_frame(config, collision, Rect2(), [])
	for wire: int in [309, 322, 303]:
		var state := _state(wire)
		var model := presenter.reaction_model(state, Chemistry.recipe(wire), state.active_tick)
		check(not PixelEffectGeometry.contains_point(model.mask.polygons, Vector2(550, 500)), "material and warning masks stop behind worldbone")
		check(PixelEffectGeometry.contains_point(model.mask.polygons, Vector2(460, 500)), "unoccluded material survives worldbone clipping")
		if wire in [309, 322]:
			check(not PixelEffectGeometry.contains_point(model.mask.polygons, Vector2(500, 500)), "ring safe hole is never painted by the identity core")
		for anchor: Vector2 in presenter.tile_anchors(model.mask, model.core_anchor, false, 192):
			for part: Dictionary in PixelEffectGeometry.clipped_frame_parts(model.frame, anchor, model.mask.polygons):
				var center := Vector2.ZERO
				for point: Vector2 in part.points:
					center += point
				center /= float(part.points.size())
				check(PixelEffectGeometry.contains_point(model.mask.polygons, center), "every clipped native-cell polygon stays in actual material coverage")
	for wire: int in [307, 329]:
		var state := _state(wire)
		var model := presenter.reaction_model(state, Chemistry.recipe(wire), state.active_tick)
		check(not PixelEffectGeometry.contains_point(model.mask.polygons, Vector2(560, 500)), "optical facet art never invents a continuation ray")


func _test_budget_culling_and_information(presenter: ElementChemistryPresenter) -> void:
	var config := SimConfig.new()
	for reduced: bool in [false, true]:
		presenter.library.begin_frame(reduced)
		presenter.begin_frame(config, null, Rect2(), [], reduced)
		var admitted := 0
		for element: int in range(1, 9):
			for attempt: int in range(100):
				if presenter._take_optional(PixelMagicLibrary.element_asset_id(element, "deposit_active", reduced), reduced):
					admitted += 1
		equal(admitted, 96 if reduced else 192, "all chemistry shares the exact bounded optional-material budget")
		equal(presenter.stats().optional_stamps, admitted, "decorative admission is measured independently of essential information")
		var state := _state(309)
		var model := presenter.reaction_model(state, Chemistry.recipe(309), state.active_tick, reduced)
		check(not model.frame.is_empty() and (model.mask.boundaries as Array).size() == 2, "exhausted decoration never removes core art or either occupied ring boundary")
		equal(presenter.tile_anchors(model.mask, model.core_anchor, reduced, 0).size(), 0, "zero remaining decorative budget allocates no optional anchors")
		var normal := presenter.tile_anchors(model.mask, model.core_anchor, false, 192)
		var sparse := presenter.tile_anchors(model.mask, model.core_anchor, true, 192)
		check(sparse.size() <= normal.size(), "reduced mode removes optional cell density, not effect coverage")
		for point: Vector2 in sparse:
			check(normal.has(point), "reduced stamps are a stable subset of the same world-locked grid")
		presenter.begin_frame(config, null, Rect2(), [], reduced)
		equal(presenter.library.decoration_remaining(), 0, "chemistry frame setup never resets global spell decoration admission")
	var state := _state(303)
	presenter.begin_frame(config, null, Rect2(0, 0, 100, 100), [])
	var builds := int(presenter.stats().geometry.builds)
	check(presenter.reaction_model(state, Chemistry.recipe(303), state.active_tick).is_empty(), "off-camera reaction is culled")
	equal(int(presenter.stats().geometry.builds), builds, "off-camera effects are rejected before polygon construction")
	equal(presenter.stats().culled, 1, "viewport culling is observable")
