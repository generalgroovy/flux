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
	return finish("element-chemistry-presenter")
