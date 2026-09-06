extends FluxTestSuite

const Chemistry = preload("res://src/sim/chemistry/element_chemistry_system.gd")
const Deposit = preload("res://src/sim/chemistry/element_deposit_state.gd")
const Reaction = preload("res://src/sim/chemistry/element_reaction_state.gd")
var config := SimConfig.new(120)

func run() -> int:
	_test_deposits()
	_test_pairs()
	_test_effects()
	_test_optics()
	_test_connectivity()
	_test_capacity_and_replay()
	_test_live_beam_routing()
	return finish("element-chemistry")

func _deposit(id: int,element: int,at: Vector2i = Vector2i(500000,500000),cast_id: int = -1) -> ElementDepositState:
	var deposits: Array = []
	equal(Chemistry.deposit_terminal(deposits,id,id if cast_id < 0 else cast_id,100,1,1,element,at,0,config),1,"paid terminal produces finite material")
	return deposits[0]

func _reaction(wire: int) -> ElementReactionState:
	var pair: Array = Chemistry.recipe(wire)["elements"]
	return Chemistry.form_reaction(_deposit(1,int(pair[0])),_deposit(2,int(pair[1])),4000,0,config)

func _actor(at: Vector2i = Vector2i(500000,500000)) -> PlayerState:
	var actor := PlayerState.new(2)
	actor.team_id = 2
	actor.position_x = at.x
	actor.position_y = at.y
	return actor

func _apply(result: ElementReactionState,actor: PlayerState,tick: int,others: Array = [],deposits: Array = []) -> void:
	var reactions: Array = [result]
	reactions.append_array(others)
	var events: Array = []
	Chemistry.step(deposits,reactions,[actor],null,config,tick,5000,events)

func _test_deposits() -> void:
	for element: int in range(1,9):
		var deposit := _deposit(element,element)
		check(deposit.validate(),"all eight deposit states validate")
		equal(deposit.expiry_tick,config.milliseconds_to_ticks(Chemistry.ELEMENT_LIFE_MS[element]),"element owns its 2-5 second lifetime")
		var decoded := Deposit.from_values(deposit.canonical_values())
		check(decoded != null,"deposit roundtrip validates")
		equal(decoded.canonical_values(),deposit.canonical_values(),"every deposit field survives roundtrip")
		var deposits: Array = [deposit]
		var original := deposit.canonical_values()
		equal(Chemistry.deposit_terminal(deposits,100,element,100,1,1,element,Vector2i(500001,500001),100,config),0,"same cast/cell coalesces")
		equal(deposit.canonical_values(),original,"repeated contact never refreshes strength or expiry")
		var reactions: Array = []
		var events: Array = []
		Chemistry.step(deposits,reactions,[],null,config,deposit.expiry_tick,4000,events)
		check(deposits.is_empty(),"deposit expires at its exact deadline")
	check(Deposit.from_values(PackedInt64Array([1,2])) == null,"short malformed deposit refuses")
	var corrupt := _deposit(9,1).canonical_values()
	corrupt[5] = 12
	check(Deposit.from_values(corrupt) == null,"deferred element cannot arrive through network")

func _test_pairs() -> void:
	var seen := {}
	for wire: int in range(301,337):
		var definition := Chemistry.recipe(wire)
		var pair: Array = definition["elements"]
		equal(Chemistry.recipe_wire(int(pair[0]),int(pair[1])),wire,"forward pair maps to stable wire")
		equal(Chemistry.recipe_wire(int(pair[1]),int(pair[0])),wire,"all 36 pairs are symmetric")
		check(not seen.has(definition["id"]),"each recipe has a unique decision identity")
		seen[definition["id"]] = true
		var deposits: Array = [_deposit(1,int(pair[0])),_deposit(2,int(pair[1]))]
		var reactions: Array = []
		var events: Array = []
		equal(Chemistry.step(deposits,reactions,[],null,config,0,4000,events),4001,"one finite pair admits one result")
		equal(reactions.size(),1,"pair result is persistent simulation state")
		equal(deposits.size(),0,"both strengths are consumed exactly once")
		var result: ElementReactionState = reactions[0]
		check(result.validate(),"all 36 reaction states validate")
		check(not result.active(0) and result.active(result.active_tick),"formation precedes active effects")
		var decoded := Reaction.from_values(result.canonical_values())
		check(decoded != null,"every recipe canonical state decodes")
		if decoded != null:
			equal(decoded.canonical_values(),result.canonical_values(),"reaction roundtrip is exact")
		Chemistry.step(deposits,reactions,[],null,config,result.expiry_tick,4001,events)
		check(reactions.is_empty(),"every recipe has finite cleanup")
	equal(seen.size(),36,"first-grade upper triangle is complete")

func _test_effects() -> void:
	var actor := _actor()
	var mud := _reaction(303)
	_apply(mud,actor,mud.active_tick)
	equal(actor.slow_ratio,700,"Mud applies proportional grounded slow")
	actor = _actor()
	actor.air_height = 20000
	_apply(_reaction(303),actor,mud.active_tick)
	equal(actor.control_state,PlayerState.ControlState.FREE,"airborne actors clear Mud")
	var blight := _reaction(308)
	actor = _actor()
	_apply(blight,actor,blight.active_tick)
	equal(actor.chemistry_regen_block_ticks,2,"Blightsoil suppresses occupied recovery")
	for wire: int in [304,310,315,317,321,326,333,336]:
		var veil := _reaction(wire)
		actor = _actor()
		_apply(veil,actor,veil.active_tick)
		check(actor.chemistry_conceal_ticks > 0,"%s owns concealment" % Chemistry.recipe(wire)["id"])
		check(Chemistry.blocks_sight(Vector2i(350000,500000),Vector2i(650000,500000),[veil],veil.active_tick),"%s blocks distant sight" % Chemistry.recipe(wire)["id"])
	var steam := _reaction(310)
	_apply(steam,_actor(),steam.active_tick)
	var early := steam.radius
	_apply(steam,_actor(),steam.active_tick+100)
	check(steam.radius > early,"Steam expands radially")
	check(not Chemistry.blocks_sight(Vector2i(350000,500000),Vector2i(650000,500000),[steam],steam.decay_tick-1),"Steam thins before expiry")
	for wire: int in [314,320,321,330,332,334,335,336]:
		var reveal := _reaction(wire)
		actor = _actor()
		actor.velocity_x = 10000
		_apply(reveal,actor,reveal.active_tick)
		check(actor.chemistry_reveal_ticks > 0,"%s executes reveal" % Chemistry.recipe(wire)["id"])
	for wire: int in [304,316,322,331]:
		var flow := _reaction(wire)
		actor = _actor(Vector2i(550000,500000) if wire in [322,331] else Vector2i(500000,500000))
		var before := Vector2i(actor.position_x,actor.position_y)
		_apply(flow,actor,flow.active_tick)
		check(Vector2i(actor.position_x,actor.position_y) != before,"%s physically displaces grounded actors" % Chemistry.recipe(wire)["id"])
	var vortex := _reaction(322)
	actor = _actor()
	_apply(vortex,actor,vortex.active_tick)
	equal(Vector2i(actor.position_x,actor.position_y),Vector2i(500000,500000),"Vortex has a safe center")
	for wire: int in [302,309,311,323,324]:
		var hazard := _reaction(wire)
		actor = _actor(Vector2i(550000,500000) if wire == 309 else Vector2i(500000,500000))
		_apply(hazard,actor,hazard.active_tick)
		check(actor.health < actor.health_maximum,"%s executes damage" % Chemistry.recipe(wire)["id"])
	for wire: int in [315,336]:
		var delayed := _reaction(wire)
		actor = _actor()
		_apply(delayed,actor,delayed.active_tick)
		equal(actor.health,actor.health_maximum,"delayed attrition gives time to leave")
		_apply(delayed,actor,delayed.active_tick+180)
		check(actor.health < actor.health_maximum,"remaining inside eventually deals damage")
	var freeze := _reaction(318)
	actor = _actor()
	_apply(freeze,actor,freeze.active_tick)
	check(actor.control_ticks > 0,"Freeze slows crossing")
	var initial_length := freeze.length
	_apply(freeze,_actor(),freeze.active_tick+120)
	check(freeze.length > initial_length,"Freeze grows its strip")
	var black_ice := _reaction(330)
	actor = _actor()
	_apply(black_ice,actor,black_ice.active_tick)
	equal(actor.control_state,PlayerState.ControlState.FREE,"Black Ice warns before slowing")
	_apply(black_ice,actor,black_ice.active_tick+50)
	check(actor.control_ticks > 0,"Black Ice slow is delayed")
	var fracture := _reaction(312)
	var cover := _reaction(327)
	cover.active_tick = 1
	var health_before := cover.health
	_apply(fracture,_actor(),fracture.active_tick,[cover])
	check(cover.health < health_before,"Thermal Shock damages temporary cover")

func _test_optics() -> void:
	for wire: int in [301,305,327]:
		var cover := _reaction(wire)
		var projectile := ProjectileState.new(100,2,2,100,2,Vector2i(510000,500000),Vector2i(500000,0),4000,10,50)
		projectile.previous_x = 490000
		check(bool(Chemistry.projectile_interaction(projectile,[cover],null,config,cover.active_tick)["blocked"]),"%s intercepts projectiles" % Chemistry.recipe(wire)["id"])
		equal(cover.health,int(Chemistry.recipe(wire)["health"])-10,"cover HP is finite")
	for wire: int in [307,325,329]:
		var optical := _reaction(wire)
		var projectile := ProjectileState.new(100,2,2,100,7,Vector2i(510000,500000),Vector2i(500000,0),4000,11,50)
		projectile.previous_x = 490000
		var response := Chemistry.projectile_interaction(projectile,[optical],null,config,optical.active_tick,1)
		check(bool(response["reflected"]) if wire == 307 else bool(response["bent"]),"%s transforms velocity" % Chemistry.recipe(wire)["id"])
		if wire == 329:
			equal(projectile.damage+int(response["split_damage"]),11,"Lens preserves damage budget")
			check((response["split_velocity"] as Vector2i).y < 0 and projectile.velocity_y > 0,"Lens produces two paths")
		var velocity := Vector2i(projectile.velocity_x,projectile.velocity_y)
		Chemistry.projectile_interaction(projectile,[optical],null,config,optical.active_tick,1)
		equal(Vector2i(projectile.velocity_x,projectile.velocity_y),velocity,"optical mask prevents repeated transforms")
		var ray := Chemistry.ray_interaction(Vector2i(400000,500000),Vector2i(650000,500000),7,11,[optical],optical.active_tick)
		check(bool(ray["transformed"]),"immediate beams use same optical primitive")
		equal((ray["rays"] as Array).size(),2 if wire == 329 else 1,"ray fanout bounded")
	var node := _reaction(306)
	var charge := ProjectileState.new(100,2,2,100,6,Vector2i(510000,500000),Vector2i(500000,0),4000,12000,50)
	charge.previous_x = 490000
	check(bool(Chemistry.projectile_interaction(charge,[node],null,config,node.active_tick)["blocked"]) and node.capacity == 24000,"Grounding Network stores bounded incoming charge")
	var bend := _reaction(325)
	var farther_cover := _reaction(301)
	farther_cover.position_x = 600000
	farther_cover.origin_x = 600000
	var bypass := Chemistry.ray_interaction(Vector2i(400000,500000),Vector2i(750000,500000),2,1000,[bend,farther_cover],maxi(bend.active_tick,farther_cover.active_tick))
	check(bool(bypass["blocked"]),"ineligible Lightbend cannot hide farther cover from a Fire beam")
	var prism := _reaction(307)
	var fire := ProjectileState.new(200,2,2,100,2,Vector2i(510000,500000),Vector2i(500000,0),4000,12000,50)
	fire.previous_x = 490000
	check(bool(Chemistry.projectile_interaction(fire,[prism],null,config,prism.active_tick)["reflected"]),"Prism reflects non-Light projectiles as well")
	var narrow := _reaction(317)
	check(Chemistry.blocks_sight(Vector2i(613000,50000),Vector2i(613000,950000),[narrow],narrow.active_tick),"long sight line cannot skip a narrow mist corridor between samples")

func _test_connectivity() -> void:
	for wire: int in [313,319,328]:
		var result := _reaction(wire)
		var element := 6 if wire == 313 else 3 if wire == 319 else 5
		var deposits: Array = [_deposit(10,element,Vector2i(610000,500000))]
		Chemistry._build_path(result,deposits,null)
		equal(result.linked_deposit_ids.size(),1,"conduction preview uses real connected material")
		var actor := _actor(Vector2i(570000,500000))
		_apply(result,actor,result.active_tick,[],deposits)
		check(actor.health < actor.health_maximum,"conduction hits its connected path")
		result.pulse_index = -1
		actor = _actor(Vector2i(570000,500000))
		_apply(result,actor,result.active_tick+1)
		equal(actor.health,actor.health_maximum,"broken connectivity prevents discharge")
	var veil := _reaction(310)
	var wall := CollisionWorld.new(1000000,1000000)
	wall.add_obstacle(CollisionWorld.Obstacle.new(1,520000,0,540000,1000000))
	var actor := _actor(Vector2i(550000,500000))
	var events: Array = []
	Chemistry.step([],[veil],[actor],wall,config,veil.active_tick+90,5000,events)
	equal(actor.chemistry_conceal_ticks,0,"worldbone prevents effect reach")

func _test_capacity_and_replay() -> void:
	var deposits: Array = [_deposit(1,2,Vector2i(500000,500000),7),_deposit(2,2,Vector2i(530000,500000),7)]
	var reactions: Array = []
	var events: Array = []
	Chemistry.step(deposits,reactions,[],null,config,0,4000,events)
	check(reactions.is_empty() and deposits.size() == 2,"Burst siblings cannot self-react")
	deposits = [_deposit(1,2),_deposit(2,3)]
	for index: int in range(32):
		var result := _reaction(310)
		result.entity_id += index
		result.origin_x += index*100000
		reactions.append(result)
	Chemistry.step(deposits,reactions,[],null,config,0,5000,events)
	equal(deposits.size(),2,"full reaction capacity preserves paid inputs")
	equal(reactions.size(),32,"reaction capacity hard bound")
	var crowded: Array = []
	for index: int in range(16):
		equal(Chemistry.deposit_terminal(crowded,index+1,index+1,100,1,1,1,Vector2i(500000+index*100000,500000),0,config),1,"owner may fill reserved slots")
	equal(Chemistry.deposit_terminal(crowded,17,17,100,1,1,1,Vector2i(2500000,500000),0,config),-1,"per-owner admission refuses overflow")
	var left: Array = [_deposit(1,2),_deposit(2,3),_deposit(3,1)]
	var right: Array = [left[2],left[1],left[0]]
	for index: int in range(right.size()):
		right[index] = Deposit.from_values(right[index].canonical_values())
	var a: Array = []
	var b: Array = []
	var events_a: Array = []
	var events_b: Array = []
	Chemistry.step(left,a,[],null,config,0,4000,events_a)
	Chemistry.step(right,b,[],null,config,0,4000,events_b)
	equal(a[0].canonical_values(),b[0].canonical_values(),"third-source resolution uses stable IDs")
	equal(events_a,events_b,"formation events are deterministic")
	var result: ElementReactionState = a[0]
	result.source_a = 2_147_483_648
	check(not result.validate(),"hostile source IDs fail before int32 conversion")

func _test_live_beam_routing() -> void:
	var world := CollisionWorld.new(1400000,1000000)
	var owner := PlayerState.new(1)
	owner.position_x = 400000
	owner.position_y = 500000
	var lens := _reaction(329)
	var target_a := _actor(Vector2i(620000,537000))
	var target_b := _actor(Vector2i(620000,463000))
	target_b.entity_id = 3
	var actors: Array[PlayerState] = [owner,target_a,target_b]
	var events: Array[Dictionary] = [{"type":"beam_requested","owner_id":1,"source_wire_id":143,"origin_x":400000,"origin_y":500000,"aim_x":1000,"aim_y":0}]
	CombatSystem.resolve_instant_casts(actors,config,world,events,[lens],lens.active_tick)
	var fired := 0
	var shifted_origin := false
	for event: Dictionary in events:
		if String(event.get("type","")) == "beam_fired":
			fired += 1
			shifted_origin = shifted_origin or int(event.get("origin_x",0)) > 400000
	equal(fired,3,"Lens displays approach plus two real outgoing segments")
	check(shifted_origin,"split visuals start at the actual lens rather than owner feet")
	check(target_a.health < target_a.health_maximum and target_b.health < target_b.health_maximum,"real Beam traces hit both split paths")
	var total_damage := target_a.health_maximum-target_a.health+target_b.health_maximum-target_b.health
	check(total_damage <= int(CombatTuning.cast_definition(143)["damage"]),"real Beam split preserves the original total damage budget")
	var cover := _reaction(301)
	var behind := _actor(Vector2i(600000,500000))
	events = [{"type":"beam_requested","owner_id":1,"source_wire_id":143,"origin_x":400000,"origin_y":500000,"aim_x":1000,"aim_y":0}]
	CombatSystem.resolve_instant_casts([owner,behind],config,world,events,[cover],cover.active_tick)
	equal(behind.health,behind.health_maximum,"temporary cover intercepts an actual instant Beam")
	check(cover.health < int(Chemistry.recipe(301)["health"]),"actual Beam damages cover")
