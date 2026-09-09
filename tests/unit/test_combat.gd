extends FluxTestSuite


func run() -> int:
	for tick_rate: int in [120]:
		_test_complete_matrix_executes(tick_rate)
		_test_semantic_spell_slots(tick_rate)
		_test_positive_flux_primary(tick_rate)
		_test_vector_lance_flux_and_hit(tick_rate)
		_test_oh_tipi_rillshot(tick_rate)
		_test_oh_tipi_tideline(tick_rate)
		_test_oh_tipi_rimewake(tick_rate)
		_test_s_wayne_eclipse_disc(tick_rate)
		_test_s_wayne_disc_ricochet(tick_rate)
		_test_s_wayne_pocket_eclipse(tick_rate)
		_test_red_baron_cinderbolt(tick_rate)
		_test_red_baron_cinder_fan(tick_rate)
		_test_movement_spell_chains(tick_rate)
		_test_casts_during_every_movement_mode(tick_rate)
		_test_pressure_exhaustion_and_recovery(tick_rate)
		_test_edgeweave(tick_rate)
		_test_evasive_intangibility(tick_rate)
	_test_whole_cast_admission()
	_test_cast_capacity_refusal_and_reuse()
	_test_global_cast_capacity()
	_test_repeated_cast_owner_limit()
	_test_segment_circle_bounds()
	_test_projectile_reaction_candidates()
	return finish("combat")


func _test_projectile_reaction_candidates() -> void:
	var reactions: Array[ElementReactionState] = []
	equal(CombatSystem._projectile_reaction_candidates(reactions,10),[],"empty reaction list remains empty")
	for wire: int in range(301,337):
		var reaction := ElementReactionState.new()
		reaction.entity_id = wire
		reaction.recipe_wire_id = wire
		reaction.active_tick = 10
		reaction.decay_tick = 20
		reaction.health = 0
		reactions.append(reaction)
	var expected: Array[int] = [301,305,306,307,320,325,327,329,335]
	var candidates := CombatSystem._projectile_reaction_candidates(reactions,10)
	equal(candidates.size(),9,"only nine projectile-interacting recipe identities are selected")
	for index: int in range(expected.size()):
		equal(candidates[index],reactions[expected[index]-301],"candidate selection retains exact order and references, including health-zero active cover")
	equal(CombatSystem._projectile_reaction_candidates(reactions,9),[],"forming reactions cannot enter this tick's batch")
	equal(CombatSystem._projectile_reaction_candidates(reactions,20),[],"decay boundary is excluded")
	reactions.append(reactions[0])
	candidates = CombatSystem._projectile_reaction_candidates(reactions,10)
	equal(candidates.size(),10,"duplicate references preserve duplicate visits")
	equal(candidates[0],candidates[9],"duplicate candidates still alias the same mutable reaction")
	reactions[0].decay_tick = 10
	check(not candidates[0].active(10) and not candidates[9].active(10),"earlier-projectile decay remains visible through both references")


func _test_segment_circle_bounds() -> void:
	# These expected values also lock the old signed integer projection, which
	# intentionally is not a floating-point projection rewrite.
	var cases: Array[Array] = [
		[Vector2i(-10,0),Vector2i(10,0),Vector2i(0,3),3,true],
		[Vector2i(-10,0),Vector2i(10,0),Vector2i(0,4),3,false],
		[Vector2i(-10,0),Vector2i(10,0),Vector2i(13,0),3,true],
		[Vector2i(-10,0),Vector2i(10,0),Vector2i(14,0),3,false],
		[Vector2i(-10,0),Vector2i(10,0),Vector2i(13,3),3,false],
		[Vector2i.ZERO,Vector2i.ZERO,Vector2i.ZERO,0,true],
		[Vector2i.ZERO,Vector2i.ZERO,Vector2i(1,0),0,false],
		[Vector2i.ZERO,Vector2i.ZERO,Vector2i(3,4),-5,true],
		[Vector2i.ZERO,Vector2i.ZERO,Vector2i(3,5),-5,false],
		[Vector2i(-3,-2),Vector2i(4,1),Vector2i(1,0),0,false],
		[Vector2i(4,1),Vector2i(-3,-2),Vector2i(1,0),0,false],
		[Vector2i(4,1),Vector2i(-3,-2),Vector2i(1,0),1,true],
		[Vector2i(99900000,99900000),Vector2i(100000000,100000000),Vector2i(100000000,100000000),0,true],
	]
	var projectile := ProjectileState.new(9001,1,1,179,2,Vector2i.ZERO,Vector2i.ZERO,1000,9000,120)
	var target := PlayerState.new(2)
	for query: Array in cases:
		# Reuse both objects so stale bounds would fail after mutation.
		projectile.previous_x = (query[0] as Vector2i).x
		projectile.previous_y = (query[0] as Vector2i).y
		projectile.position_x = (query[1] as Vector2i).x
		projectile.position_y = (query[1] as Vector2i).y
		target.position_x = (query[2] as Vector2i).x
		target.position_y = (query[2] as Vector2i).y
		var before_projectile := projectile.canonical_values()
		var before_target := target.canonical_values()
		equal(CombatSystem._segment_circle_hit(projectile,target,query[3]),query[4],"strict bounds retain tangent, endpoint, signed rounding and radius behavior")
		equal(projectile.canonical_values(),before_projectile,"circle query does not mutate projectile")
		equal(target.canonical_values(),before_target,"circle query does not mutate target")


func _admission_world(player_count: int, projectiles_per_owner: int = 0, fields_per_owner: int = 0) -> SimWorld:
	var world := SimWorld.new(120, 77, CollisionWorld.new(4_000_000, 4_000_000))
	world.players.clear()
	for owner_id: int in range(1, player_count + 1):
		var state := PlayerState.new(owner_id)
		state.team_id = 1
		state.position_x = 500_000
		state.position_y = 500_000 + owner_id * 150_000
		world.players.append(state)
		check(state.place_proven_spell(0, CombatTuning.CINDERFAN_WIRE_ID), "admission actor equips a complete Burst")
		check(state.place_proven_spell(1, CombatTuning.RIMEWAKE_WIRE_ID), "admission actor equips one persistent Field")
		check(state.place_proven_spell(2, CombatTuning.PRIMARY_WIRE_ID), "admission actor equips one Bolt")
		for _index: int in range(projectiles_per_owner):
			world.projectiles.append(ProjectileState.new(world.next_projectile_id, owner_id, 1, CombatTuning.PRIMARY_WIRE_ID, 6, Vector2i(3_000_000, 3_000_000), Vector2i.ZERO, 7000, 10000, 600))
			world.next_projectile_id += 1
		for _index: int in range(fields_per_owner):
			world.fields.append(FieldState.new(world.next_field_id, owner_id, 1, CombatTuning.RIMEWAKE_WIRE_ID, 5, Vector2i(3_000_000, 3_000_000), 72000, 600, PlayerState.ControlState.SLOWED, 700, 650))
			world.next_field_id += 1
	return world


func _admission_commands(world: SimWorld, pressed: int = 0, reversed: bool = false) -> Array[SimCommand]:
	var commands: Array[SimCommand] = []
	for state: PlayerState in world.players:
		commands.append(SimCommand.new(world.tick, state.entity_id, 0, 0, 0, pressed, 1000, 0))
	if reversed:
		commands.reverse()
	return commands


func _test_whole_cast_admission() -> void:
	var first := _admission_world(8, 11, 3)
	var reversed := _admission_world(8, 11, 3)
	reversed.players.reverse()
	check(first.step(_admission_commands(first, SimCommand.PRESSED_SPELL_1)), "eight simultaneous fans enter startup")
	check(reversed.step(_admission_commands(reversed, SimCommand.PRESSED_SPELL_1, true)), "reversed actor/command order enters the same startups")
	equal(first.projectiles.size(), 88, "pending fans do not fabricate live projectiles")
	for state: PlayerState in first.players:
		equal(state.pending_cast_wire_id, CombatTuning.CINDERFAN_WIRE_ID, "each of eight actors reserves all five lanes")
		equal(state.flux, state.flux_maximum - int(CombatTuning.cast_definition(CombatTuning.CINDERFAN_WIRE_ID)["flux_cost"]), "each accepted whole fan pays exactly once")
		equal(first.available_cast_capacity(state.entity_id).x, 0, "live plus pending reservations fill the entire 128-projectile capacity")
	equal(first.state_hash(), reversed.state_hash(), "reservation state ignores incoming order")
	for _tick: int in range(20):
		check(first.step(_admission_commands(first)), "reserved eight-fan release advances")
		check(reversed.step([]), "omitted idle commands preserve canonical release ordering")
		equal(first.state_hash(), reversed.state_hash(), "paid release IDs and live state agree regardless of actor/input ordering")
		check(first.projectiles.size() <= SimConfig.MAX_ACTIVE_PROJECTILES, "whole releases never exceed global projectile capacity")
	equal(first.projectiles.size(), 128, "all eight paid fans release completely at the global limit")
	check(first.step(_admission_commands(first, SimCommand.PRESSED_SPELL_2)), "eight Fields reserve the remaining field slots independently of projectiles")
	for state: PlayerState in first.players:
		equal(state.pending_cast_wire_id, CombatTuning.RIMEWAKE_WIRE_ID, "each actor reserves its fourth Field")
		equal(first.available_cast_capacity(state.entity_id).y, 0, "pending Fields reserve the exact 32-field global capacity")
	for _tick: int in range(30):
		check(first.step([]), "paid Fields release from their reserved slots")
		check(first.fields.size() <= SimConfig.MAX_ACTIVE_FIELDS, "Field releases never exceed global capacity")
	equal(first.fields.size(), 32, "eight reserved Fields all release at capacity")


func _test_cast_capacity_refusal_and_reuse() -> void:
	var world := _admission_world(1, 12, 4)
	var caster := world.player()
	var initial_flux := caster.flux
	var projectile_serial := world.next_projectile_id
	var field_serial := world.next_field_id
	check(world.step(_admission_commands(world, SimCommand.PRESSED_SPELL_1)), "fan capacity refusal remains a valid world tick")
	equal(caster.pending_cast_wire_id, 0, "four free slots cannot admit a partial five-shot fan")
	equal(caster.flux, initial_flux, "capacity refusal spends no Flux")
	equal(caster.spell_cooldown_for_wire(CombatTuning.CINDERFAN_WIRE_ID), 0, "capacity refusal starts no cooldown")
	equal(world.next_projectile_id, projectile_serial, "capacity refusal allocates no projectile IDs")
	check(world.combat_events.any(func(event: Dictionary) -> bool: return event.get("type") == "cast_refused" and event.get("reason") == "capacity"), "capacity refusal explains the limiting state")
	check(world.step(_admission_commands(world, SimCommand.PRESSED_SPELL_2)), "full owner Field capacity refuses cleanly")
	equal(caster.pending_cast_wire_id, 0, "fifth owner Field cannot enter startup")
	equal(caster.flux, initial_flux, "Field capacity refusal spends no Flux")
	equal(caster.spell_cooldown_for_wire(CombatTuning.RIMEWAKE_WIRE_ID), 0, "Field capacity refusal starts no cooldown")
	equal(world.next_field_id, field_serial, "Field refusal allocates no ID")
	for projectile: ProjectileState in world.projectiles:
		projectile.lifetime_ticks = 1
	for field: FieldState in world.fields:
		field.lifetime_ticks = 1
	check(world.step([]), "ordinary lifecycle expiry releases capacity")
	var remaining_material := world.deposits.filter(func(deposit: ElementDepositState) -> bool: return deposit.owner_id == caster.entity_id).size()
	check(remaining_material > 0, "expired projectiles retain paid terminal material until its own expiry")
	var free_material_slots := 16 - remaining_material
	equal(world.available_cast_capacity(caster.entity_id), Vector2i(free_material_slots, 4), "projectile expiry does not erase terminal material reservations")
	check(world.step(_admission_commands(world, SimCommand.PRESSED_SPELL_1)), "the previously refused fan can reuse expired capacity")
	equal(caster.pending_cast_wire_id, CombatTuning.CINDERFAN_WIRE_ID, "retry accepts exactly one whole fan")
	equal(caster.flux, initial_flux - int(CombatTuning.cast_definition(CombatTuning.CINDERFAN_WIRE_ID)["flux_cost"]), "retry spends Flux only when accepted")
	equal(world.available_cast_capacity(caster.entity_id).x, free_material_slots - 5, "startup reserves five slots in addition to still-live material")
	caster.health = 0
	check(world.step([]), "death clears the paid pending cast without leaking reservation")
	equal(world.available_cast_capacity(caster.entity_id).x, free_material_slots, "dead pending casts release only their own reservations")
	equal(world.projectiles.size(), 0, "a defeated pending caster emits no orphan fan")
	var last_material_expiry := world.tick
	for deposit: ElementDepositState in world.deposits:
		last_material_expiry = maxi(last_material_expiry, deposit.expiry_tick)
	while world.tick <= last_material_expiry:
		check(world.step([]), "terminal material expires through ordinary world ticks")
	equal(world.available_cast_capacity(caster.entity_id), Vector2i(16,4), "only actual material expiry restores the full owner budget")


func _test_repeated_cast_owner_limit() -> void:
	var world := _admission_world(1)
	var caster := world.player()
	check(caster.place_proven_spell(1, 148), "second distinct Burst enters the repeat-cast fixture")
	check(caster.place_proven_spell(2, 147), "third distinct Burst enters the repeat-cast fixture")
	check(caster.place_proven_spell(3, CombatTuning.PRIMARY_WIRE_ID), "one Bolt can use spare owner capacity")
	var expected_live := 0
	for pressed: int in [SimCommand.PRESSED_SPELL_1, SimCommand.PRESSED_SPELL_2]:
		check(world.step(_admission_commands(world, pressed)), "successive distinct Burst pays for its own reservation")
		for _tick: int in range(19):
			check(world.step([]), "successive Burst releases through ordinary startup")
		expected_live += 5
		equal(world.projectiles.size(), expected_live, "each paid Burst adds all five lanes without expiry or truncation")
	equal(world.deposits.size(), 4, "two paid Waves also fill the four optional trail slots")
	check(world.deposits.all(func(deposit: ElementDepositState) -> bool: return deposit.is_trail()), "shared material occupancy is real flight trail, not an early terminal")
	equal(world.available_cast_capacity(caster.entity_id).x, 2, "ten shots and four trails leave two paid single-shot slots")
	equal(world.available_cast_offer(caster.entity_id).x, 6, "four optional trails offer enough virtual room for another whole Wave")
	var flux_before := caster.flux
	var next_id := world.next_projectile_id
	check(world.step(_admission_commands(world, SimCommand.PRESSED_SPELL_3)), "third whole Wave can trade exactly three optional trails for its reservation")
	equal(caster.pending_cast_wire_id, 147, "the third Wave is admitted as a whole paid cast")
	equal(caster.flux, flux_before - int(CombatTuning.cast_definition(147).flux_cost), "reclamation does not alter the third Wave's positive cost")
	equal(world.next_projectile_id, next_id, "startup still allocates no partial Wave IDs")
	equal(world.deposits.size(), 1, "only the three trails actually needed by the Wave are reclaimed")
	equal(world.available_cast_capacity(caster.entity_id).x, 0, "ten live shots plus five paid lanes and one trail fill the shared cap")
	for _tick: int in range(19):
		check(world.step([]), "third paid Wave releases through normal startup")
	equal(world.projectiles.size(), 15, "all five lanes release without truncation after reclamation")
	check(world.step(_admission_commands(world, SimCommand.PRESSED_SPELL_4)), "a paid Bolt can reclaim the last optional trail for the final hard projectile slot")
	equal(world.available_cast_capacity(caster.entity_id).x, 0, "Bolt reservation keeps the shared and projectile caps exact")
	check(world.deposits.is_empty(), "the final Bolt needed exactly the one remaining optional trail")
	for _tick: int in range(12):
		check(world.step([]), "final paid Bolt releases without truncation")
	equal(world.projectiles.size(), SimConfig.MAX_PROJECTILES_PER_PLAYER, "sixteen live projectiles remain the immutable owner cap")
	equal(world.projectiles.size() + world.deposits.size(), ElementChemistrySystem.MAX_OWNER_DEPOSITS, "repeated production casts stop at the exact sixteen-slot shared material cap")
	equal(world.available_cast_offer(caster.entity_id).x, 0, "reclamation cannot invent a seventeenth projectile slot")


func _test_global_cast_capacity() -> void:
	var world := _admission_world(8, 16, 4)
	var extra := PlayerState.new(9)
	extra.team_id = 1
	extra.position_x = 500_000
	extra.position_y = 500_000
	world.players.append(extra)
	check(extra.place_proven_spell(0, CombatTuning.CINDERFAN_WIRE_ID), "offline overflow actor equips the same fan")
	check(extra.place_proven_spell(1, CombatTuning.RIMEWAKE_WIRE_ID), "offline overflow actor equips the same Field")
	var flux_before := extra.flux
	equal(world.available_cast_capacity(9), Vector2i.ZERO, "global caps still apply to an owner with no live objects")
	check(world.step([SimCommand.new(world.tick, 9, 0, 0, 0, SimCommand.PRESSED_SPELL_1, 1000, 0)]), "global projectile overflow refuses admission without rejecting the tick")
	equal(extra.pending_cast_wire_id, 0, "global limit refuses another whole fan")
	equal(extra.flux, flux_before, "global projectile refusal spends no Flux")
	check(world.step([SimCommand.new(world.tick, 9, 0, 0, 0, SimCommand.PRESSED_SPELL_2, 1000, 0)]), "global Field overflow refuses admission")
	equal(extra.pending_cast_wire_id, 0, "global limit refuses another Field")
	equal(extra.flux, flux_before, "global Field refusal spends no Flux")
	equal(world.projectiles.size(), SimConfig.MAX_ACTIVE_PROJECTILES, "refusal never drops existing dangerous projectile state")
	equal(world.fields.size(), SimConfig.MAX_ACTIVE_FIELDS, "refusal never drops existing persistent Field state")
	check(extra.place_proven_spell(0, CombatTuning.POCKET_ECLIPSE_WIRE_ID), "an instant Beam remains an independent geometry choice")
	check(world.step([SimCommand.new(world.tick, 9, 0, 0, 0, SimCommand.PRESSED_SPELL_1, 1000, 0)]), "full persistent capacity does not reject an instant Beam")
	equal(extra.pending_cast_wire_id, CombatTuning.POCKET_ECLIPSE_WIRE_ID, "instant delivery consumes no projectile or Field reservation")


func _test_complete_matrix_executes(tick_rate: int) -> void:
	var catalog := AbilityCatalog.new()
	check(catalog.load_from_file("res://content/abilities/foundation_abilities_v1.json"), "matrix execution catalog validates")
	var event_by_shape := {
		"projectile": "projectile_spawned",
		"spray": "spray_fired",
		"beam": "beam_fired",
		"field": "field_spawned",
	}
	for wire_id: int in catalog.spell_matrix_wire_ids:
		var ability := catalog.ability_from_wire(wire_id)
		var shape := String(ability.get("shape", ""))
		var world := SimWorld.new(tick_rate)
		var caster: PlayerState = world.player()
		check(caster.place_proven_spell(0, wire_id), "%s equips through the canonical weave" % ability.get("display_name", "spell"))
		var initial_flux := caster.flux
		check(_step(world, SimCommand.new(0, 1, 0, 0, 0, SimCommand.PRESSED_SPELL_1, 1000, 0)), "%s begins through semantic slot 1" % ability.get("display_name", "spell"))
		equal(caster.flux, initial_flux - int(CombatTuning.cast_definition(wire_id).get("flux_cost", 0)), "%s pays its exact positive Flux cost" % ability.get("display_name", "spell"))
		var expected_event := String(event_by_shape.get(shape, ""))
		var released := false
		for _release_tick: int in range(60):
			check(_step(world, SimCommand.new(world.tick, 1, 0, 0, 0, 0, 1000, 0)), "%s release tick remains deterministic" % ability.get("display_name", "spell"))
			if world.combat_events.any(func(event: Dictionary) -> bool: return String(event.get("type", "")) == expected_event and int(event.get("source_wire_id", event.get("wire_id", 0))) == wire_id):
				released = true
				break
		check(released, "%s releases through its %s resolver" % [ability.get("display_name", "spell"), shape])


func _test_evasive_intangibility(tick_rate: int) -> void:
	var config := SimConfig.new(tick_rate)
	var collision := CollisionWorld.new(900_000, 720_000)
	var owner := PlayerState.new(1)
	owner.team_id = 1
	var target := PlayerState.new(2)
	target.team_id = 2
	target.position_x = 330_000
	target.position_y = 360_000
	target.hop_mode = PlayerState.MovementMode.ROLL
	target.air_dodge_ticks = config.milliseconds_to_ticks(MovementTuning.ROLL_DURATION_MS)
	var projectile := ProjectileState.new(
		9900, owner.entity_id, owner.team_id,
		CombatTuning.PRIMARY_WIRE_ID, int(CombatTuning.cast_definition(CombatTuning.PRIMARY_WIRE_ID)["element_wire_id"]),
		Vector2i(300_000, 360_000), Vector2i(1_800_000, 0),
		int(CombatTuning.cast_definition(CombatTuning.PRIMARY_WIRE_ID)["radius"]), int(CombatTuning.cast_definition(CombatTuning.PRIMARY_WIRE_ID)["damage"]),
		tick_rate, PlayerState.ControlState.LAUNCHED, 180, 300_000, 1000, 0,
	)
	var events: Array[Dictionary] = []
	var survivors := CombatSystem.advance_projectiles([projectile], [owner, target], config, collision, events)
	equal(target.health, target.health_maximum, "%d Hz roll intangibility rejects projectile damage" % tick_rate)
	equal(target.control_state, PlayerState.ControlState.FREE, "%d Hz roll intangibility rejects projectile control" % tick_rate)
	equal(target.last_event, "evaded_projectile", "%d Hz projectile evasion remains explicit" % tick_rate)
	equal(survivors.size(), 1, "%d Hz projectile passes through an intangible roller" % tick_rate)
	check(not events.any(func(event: Dictionary) -> bool: return event.get("type") == "projectile_hit"), "%d Hz evasion emits no false hit" % tick_rate)

	target.air_dodge_ticks = 0
	target.hop_mode = PlayerState.MovementMode.HOP
	target.hop_ticks = config.milliseconds_to_ticks(MovementTuning.HOP_DURATION_MS)
	target.jump_protection_ticks = config.milliseconds_to_ticks(MovementTuning.JUMP_INVULNERABILITY_MS)
	check(not PlayerResourcesSystem.damage(target, 10_000, config), "%d Hz opening jump frames reject direct combat damage" % tick_rate)
	equal(target.health, target.health_maximum, "%d Hz opening jump frames preserve health" % tick_rate)
	target.hop_ticks = 1
	target.jump_protection_ticks = 0
	check(PlayerResourcesSystem.damage(target, 10_000, config), "%d Hz jump recovery is vulnerable" % tick_rate)
	equal(target.health, target.health_maximum - 10_000, "%d Hz vulnerable jump recovery takes exact damage" % tick_rate)


func _test_semantic_spell_slots(tick_rate: int) -> void:
	var primary_world := SimWorld.new(tick_rate)
	var primary: PlayerState = primary_world.player()
	check(_step(primary_world, SimCommand.new(0, 1, 0, 0, 0, SimCommand.PRESSED_SPELL_1, 1000, 0)), "%d Hz slot 1 command steps" % tick_rate)
	equal(primary.pending_cast_wire_id, primary.primary_wire_id, "%d Hz slot 1 adapts to the proven primary" % tick_rate)

	var active_world := SimWorld.new(tick_rate)
	var active: PlayerState = active_world.player()
	check(_step(active_world, SimCommand.new(0, 1, 0, 0, 0, SimCommand.PRESSED_SPELL_2, 1000, 0)), "%d Hz slot 2 command steps" % tick_rate)
	equal(active.pending_cast_wire_id, active.active_1_wire_id, "%d Hz slot 2 adapts to the proven active" % tick_rate)
	check(active.flux < active.flux_maximum, "%d Hz slot 2 uses the existing Flux rule" % tick_rate)

	var global_world := SimWorld.new(tick_rate)
	var global_spell: PlayerState = global_world.player()
	var global_wire := global_spell.spell_wire_id(4)
	check(_step(global_world, SimCommand.new(0, 1, 0, 0, 0, SimCommand.PRESSED_SPELL_4, 1000, 0)), "%d Hz global non-kit spell command steps" % tick_rate)
	equal(global_spell.pending_cast_wire_id, global_wire, "%d Hz globally woven row-major spell starts for the default Arc kit" % tick_rate)
	equal(global_spell.flux, global_spell.flux_maximum - int(CombatTuning.cast_definition(global_wire)["flux_cost"]), "%d Hz globally woven spell pays its canonical Flux cost" % tick_rate)

	var empty_world := SimWorld.new(tick_rate)
	var empty: PlayerState = empty_world.player()
	empty.spell_wire_ids[9] = 0
	empty.spell_cooldown_ticks[9] = 0
	empty._sync_legacy_spell_cooldowns()
	var initial_flux: int = empty.flux
	check(_step(empty_world, SimCommand.new(0, 1, 0, 0, 0, SimCommand.PRESSED_SPELL_10, 1000, 0)), "%d Hz empty slot command steps" % tick_rate)
	equal(empty.pending_cast_wire_id, 0, "%d Hz empty slot starts no cast" % tick_rate)
	equal(empty.flux, initial_flux, "%d Hz empty slot spends no Flux" % tick_rate)
	check(empty_world.combat_events.any(func(event: Dictionary) -> bool: return event.get("type") == "cast_refused" and event.get("reason") == "empty_slot" and int(event.get("slot", 0)) == 10), "%d Hz empty slot refusal is explicit" % tick_rate)

	var rewoven_world := SimWorld.new(tick_rate)
	var rewoven: PlayerState = rewoven_world.player()
	check(rewoven.place_proven_spell(11, rewoven.primary_wire_id), "%d Hz primary rewoves into Alt+4" % tick_rate)
	check(_step(rewoven_world, SimCommand.new(0, 1, 0, 0, 0, SimCommand.PRESSED_SPELL_12, 1000, 0)), "%d Hz rewoven command steps" % tick_rate)
	equal(rewoven.pending_cast_wire_id, rewoven.primary_wire_id, "%d Hz rewoven slot invokes its canonical spell wire" % tick_rate)


func _step(world: SimWorld, command: SimCommand) -> bool:
	return world.step([command])


func _add_enemy(world: SimWorld, position: Vector2i, entity_id: int = 2) -> PlayerState:
	var enemy := PlayerState.new(entity_id)
	enemy.team_id = entity_id
	enemy.position_x = position.x
	enemy.position_y = position.y
	world.players.append(enemy)
	return enemy


func _apply_oh_tipi(state: PlayerState) -> void:
	var abilities := AbilityCatalog.new()
	check(abilities.load_from_file("res://content/abilities/foundation_abilities_v1.json"), "ability catalog loads for Oh Tipi combat")
	var champions := ChampionCatalog.new()
	check(champions.load_from_file("res://content/champions/foundation_champions_v1.json", abilities), "champion catalog loads for Oh Tipi combat")
	check(champions.apply_to_player(state, "oh_tipi"), "Oh Tipi combat profile applies")


func _apply_s_wayne(state: PlayerState) -> void:
	var abilities := AbilityCatalog.new()
	check(abilities.load_from_file("res://content/abilities/foundation_abilities_v1.json"), "ability catalog loads for S. Wayne combat")
	var champions := ChampionCatalog.new()
	check(champions.load_from_file("res://content/champions/foundation_champions_v1.json", abilities), "champion catalog loads for S. Wayne combat")
	check(champions.apply_to_player(state, "s_wayne"), "S. Wayne combat profile applies")


func _apply_red_baron(state: PlayerState) -> void:
	var abilities := AbilityCatalog.new()
	check(abilities.load_from_file("res://content/abilities/foundation_abilities_v1.json"), "ability catalog loads for Red Baron combat")
	var champions := ChampionCatalog.new()
	check(champions.load_from_file("res://content/champions/foundation_champions_v1.json", abilities), "champion catalog loads for Red Baron combat")
	check(champions.apply_to_player(state, "red_baron"), "Red Baron combat profile applies")


func _test_positive_flux_primary(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var caster: PlayerState = world.player()
	var enemy: PlayerState = _add_enemy(world, Vector2i(360_000, 360_000))
	var initial_flux: int = caster.flux
	check(_step(world, SimCommand.new(0, 1, 0, 0, SimCommand.HELD_PRIMARY, 0, 1000, 0)), "%d Hz primary start steps" % tick_rate)
	equal(caster.pending_cast_wire_id, CombatTuning.PRIMARY_WIRE_ID, "%d Hz primary enters authored startup" % tick_rate)
	equal(caster.flux, initial_flux - int(CombatTuning.cast_definition(CombatTuning.PRIMARY_WIRE_ID)["flux_cost"]), "%d Hz primary spends exact positive Flux" % tick_rate)
	var saw_spawn: bool = false
	var saw_hit: bool = false
	for _index: int in range(tick_rate):
		check(_step(world, SimCommand.new(world.tick, 1, 0, 0, 0, 0, 1000, 0)), "%d Hz primary flight steps" % tick_rate)
		for event: Dictionary in world.combat_events:
			if String(event.get("type", "")) == "projectile_spawned":
				equal(caster.primary_cooldown_ticks, world.config.milliseconds_to_ticks(int(CombatTuning.cast_definition(CombatTuning.PRIMARY_WIRE_ID)["cooldown_ms"])), "%d Hz primary starts its exact authored cooldown on release" % tick_rate)
			saw_spawn = saw_spawn or String(event.get("type", "")) == "projectile_spawned"
			saw_hit = saw_hit or String(event.get("type", "")) == "projectile_hit"
		if saw_hit:
			break
	check(saw_spawn, "%d Hz primary releases after startup" % tick_rate)
	check(saw_hit, "%d Hz primary resolves an authoritative hit" % tick_rate)
	equal(enemy.health, PlayerTuning.HEALTH_MAXIMUM - int(CombatTuning.cast_definition(CombatTuning.PRIMARY_WIRE_ID)["damage"]), "%d Hz primary damage is exact" % tick_rate)
	equal(caster.flux, initial_flux - int(CombatTuning.cast_definition(CombatTuning.PRIMARY_WIRE_ID)["flux_cost"]), "%d Hz primary cannot recover before its combat delay" % tick_rate)
	# Slower projectiles may hit after their unchanged cast cooldown has elapsed.
	check(caster.primary_cooldown_ticks >= 0, "%d Hz primary cooldown stays bounded independently of flight time" % tick_rate)

	var refused_world := SimWorld.new(tick_rate)
	var refused: PlayerState = refused_world.player()
	refused.flux = int(CombatTuning.cast_definition(CombatTuning.PRIMARY_WIRE_ID)["flux_cost"]) - 1
	refused.flux_recovery_delay_ticks = tick_rate
	check(_step(refused_world, SimCommand.new(0, 1, 0, 0, 0, SimCommand.PRESSED_SPELL_1)), "%d Hz unaffordable primary command steps" % tick_rate)
	equal(refused.pending_cast_wire_id, 0, "%d Hz unaffordable primary cannot enter startup" % tick_rate)
	equal(refused.flux, int(CombatTuning.cast_definition(CombatTuning.PRIMARY_WIRE_ID)["flux_cost"]) - 1, "%d Hz refused primary spends nothing" % tick_rate)
	check(refused_world.combat_events.any(func(event: Dictionary) -> bool: return event.get("type") == "cast_refused" and event.get("reason") == "flux"), "%d Hz semantic primary reports insufficient Flux" % tick_rate)


func _test_vector_lance_flux_and_hit(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var caster: PlayerState = world.player()
	var enemy: PlayerState = _add_enemy(world, Vector2i(420_000, 360_000))
	check(_step(world, SimCommand.new(0, 1, 0, 0, 0, SimCommand.PRESSED_ACTIVE_1, 1000, 0)), "%d Hz Vector Lance start steps" % tick_rate)
	equal(caster.pending_cast_wire_id, CombatTuning.ACTIVE_1_WIRE_ID, "%d Hz Vector Lance enters authored startup" % tick_rate)
	equal(caster.flux, PlayerTuning.FLUX_MAXIMUM - int(CombatTuning.cast_definition(CombatTuning.ACTIVE_1_WIRE_ID)["flux_cost"]), "%d Hz Vector Lance Flux cost is exact" % tick_rate)
	var saw_hit: bool = false
	for _index: int in range(tick_rate * 2):
		check(_step(world, SimCommand.new(world.tick, 1, 0, 0, 0, 0, 1000, 0)), "%d Hz Vector Lance flight steps" % tick_rate)
		for event: Dictionary in world.combat_events:
			saw_hit = saw_hit or (
				String(event.get("type", "")) == "projectile_hit"
				and int(event.get("source_wire_id", 0)) == CombatTuning.ACTIVE_1_WIRE_ID
			)
		if saw_hit:
			break
	check(saw_hit, "%d Hz Vector Lance resolves an authoritative hit" % tick_rate)
	equal(enemy.health, PlayerTuning.HEALTH_MAXIMUM - int(CombatTuning.cast_definition(CombatTuning.ACTIVE_1_WIRE_ID)["damage"]), "%d Hz Vector Lance damage is exact" % tick_rate)
	check(caster.active_1_cooldown_ticks > 0, "%d Hz Vector Lance cooldown is active" % tick_rate)

	var refused_world := SimWorld.new(tick_rate)
	var refused: PlayerState = refused_world.player()
	refused.flux = int(CombatTuning.cast_definition(CombatTuning.ACTIVE_1_WIRE_ID)["flux_cost"]) - 1
	refused.flux_recovery_delay_ticks = tick_rate
	check(_step(refused_world, SimCommand.new(0, 1, 0, 0, 0, SimCommand.PRESSED_ACTIVE_1)), "%d Hz refused cast command steps" % tick_rate)
	equal(refused.pending_cast_wire_id, 0, "%d Hz unaffordable active does not enter startup" % tick_rate)
	equal(refused.flux, int(CombatTuning.cast_definition(CombatTuning.ACTIVE_1_WIRE_ID)["flux_cost"]) - 1, "%d Hz refused active spends nothing while recovery is held" % tick_rate)
	check(refused_world.combat_events.any(func(event: Dictionary) -> bool: return event.get("type") == "cast_refused"), "%d Hz refused active emits a diagnostic event" % tick_rate)


func _test_oh_tipi_rillshot(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var caster: PlayerState = world.player()
	_apply_oh_tipi(caster)
	var enemy: PlayerState = _add_enemy(world, Vector2i(360_000, 360_000))
	var initial_flux: int = caster.flux
	check(_step(world, SimCommand.new(0, 1, 0, 0, SimCommand.HELD_PRIMARY, 0, 1000)), "%d Hz Rillshot starts" % tick_rate)
	equal(caster.pending_cast_wire_id, CombatTuning.RILLSHOT_WIRE_ID, "%d Hz Oh Tipi primary is Rillshot" % tick_rate)
	equal(caster.flux, initial_flux - int(CombatTuning.cast_definition(CombatTuning.RILLSHOT_WIRE_ID)["flux_cost"]), "%d Hz Rillshot spends exact positive Flux" % tick_rate)
	var saw_hit: bool = false
	for _index: int in range(tick_rate):
		check(_step(world, SimCommand.new(world.tick, 1, 0, 0, 0, 0, 1000)), "%d Hz Rillshot flight steps" % tick_rate)
		saw_hit = saw_hit or world.combat_events.any(func(event: Dictionary) -> bool: return event.get("type") == "projectile_hit" and int(event.get("source_wire_id", 0)) == CombatTuning.RILLSHOT_WIRE_ID)
		if saw_hit:
			break
	check(saw_hit, "%d Hz Rillshot hits authoritatively" % tick_rate)
	equal(enemy.health, enemy.health_maximum - int(CombatTuning.cast_definition(CombatTuning.RILLSHOT_WIRE_ID)["damage"]), "%d Hz Rillshot damage is exact" % tick_rate)


func _test_red_baron_cinderbolt(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var caster: PlayerState = world.player()
	_apply_red_baron(caster)
	var enemy: PlayerState = _add_enemy(world, Vector2i(360_000, 360_000))
	var initial_flux := caster.flux
	check(_step(world, SimCommand.new(0, 1, 0, 0, SimCommand.HELD_PRIMARY, 0, 1000)), "%d Hz Cinderbolt starts" % tick_rate)
	equal(caster.pending_cast_wire_id, CombatTuning.CINDERBOLT_WIRE_ID, "%d Hz Red Baron primary is Cinderbolt" % tick_rate)
	equal(caster.flux, initial_flux - int(CombatTuning.cast_definition(CombatTuning.CINDERBOLT_WIRE_ID)["flux_cost"]), "%d Hz Cinderbolt spends exact positive Flux" % tick_rate)
	var saw_hit := false
	for _index: int in range(tick_rate):
		check(_step(world, SimCommand.new(world.tick, 1, 0, 0, 0, 0, 1000)), "%d Hz Cinderbolt flight steps" % tick_rate)
		saw_hit = saw_hit or world.combat_events.any(func(event: Dictionary) -> bool: return event.get("type") == "projectile_hit" and int(event.get("source_wire_id", 0)) == CombatTuning.CINDERBOLT_WIRE_ID)
		if saw_hit:
			break
	check(saw_hit, "%d Hz Cinderbolt hits authoritatively" % tick_rate)
	equal(enemy.health, enemy.health_maximum - int(CombatTuning.cast_definition(CombatTuning.CINDERBOLT_WIRE_ID)["damage"]), "%d Hz Cinderbolt damage is exact" % tick_rate)


func _test_red_baron_cinder_fan(tick_rate: int) -> void:
	var collision := CollisionWorld.new(1_200_000, 720_000)
	var world := SimWorld.new(tick_rate, 146, collision)
	var caster: PlayerState = world.player()
	_apply_red_baron(caster)
	var enemy: PlayerState = _add_enemy(world, Vector2i(600_000, 360_000), 9)
	enemy.actor_kind = PlayerState.ActorKind.TRAINING_TARGET
	var initial_flux := caster.flux
	check(_step(world, SimCommand.new(0, 1, 0, 0, 0, SimCommand.PRESSED_SPELL_3, 1000, 0)), "%d Hz Cinder Fan starts from Red Baron's third kit slot" % tick_rate)
	equal(caster.pending_cast_wire_id, CombatTuning.CINDERFAN_WIRE_ID, "%d Hz Cinder Fan owns the requested cast channel" % tick_rate)
	equal(caster.flux, initial_flux - int(CombatTuning.cast_definition(CombatTuning.CINDERFAN_WIRE_ID)["flux_cost"]), "%d Hz Cinder Fan spends one exact positive Flux cost" % tick_rate)
	var spawn_events: Array[Dictionary] = []
	for _index: int in range(tick_rate):
		check(_step(world, SimCommand.new(world.tick, 1, 0, 0, 0, 0, 1000, 0)), "%d Hz Cinder Fan release advances" % tick_rate)
		for event: Dictionary in world.combat_events:
			if event.get("type") == "projectile_spawned" and int(event.get("wire_id", 0)) == CombatTuning.CINDERFAN_WIRE_ID:
				spawn_events.append(event)
		if spawn_events.size() == 5:
			break
	equal(spawn_events.size(), 5, "%d Hz Cinder Fan releases exactly five bounded lanes" % tick_rate)
	equal(world.projectiles.size(), 5, "%d Hz all five fan lanes enter authoritative collision state" % tick_rate)
	equal(world.next_projectile_id, 1005, "%d Hz fan reserves exactly five stable projectile IDs" % tick_rate)
	var observed_ids: Array[int] = []
	var observed_angles: Array[int] = []
	for event: Dictionary in spawn_events:
		observed_ids.append(int(event.get("projectile_id", 0)))
		observed_angles.append(int(event.get("lane_angle_degrees", 999)))
	equal(observed_ids, [1000, 1001, 1002, 1003, 1004], "%d Hz projectile IDs follow left-to-right lane order" % tick_rate)
	equal(observed_angles, CombatTuning.cast_definition(CombatTuning.CINDERFAN_WIRE_ID)["projectile_angles_degrees"], "%d Hz fan exposes exact -24..24 degree readability" % tick_rate)
	if world.projectiles.size() == 5:
		equal(world.projectiles[0].velocity_x, world.projectiles[4].velocity_x, "%d Hz outer fan lanes have mirrored forward speed" % tick_rate)
		equal(world.projectiles[0].velocity_y, -world.projectiles[4].velocity_y, "%d Hz outer fan lanes mirror vertically" % tick_rate)
		equal(world.projectiles[1].velocity_y, -world.projectiles[3].velocity_y, "%d Hz inner fan lanes mirror vertically" % tick_rate)
		equal(world.projectiles[2].velocity_y, 0, "%d Hz center fan lane preserves exact aim" % tick_rate)
	var snapshot := SessionSnapshot.capture(world, {1: "Baron"}, world.combat_events)
	check(SessionSnapshot.validate(snapshot), "%d Hz five-shot fan fits the validated network snapshot" % tick_rate)
	equal(int((snapshot["overflow"] as PackedInt32Array)[0]), 0, "%d Hz one complete fan stays inside the projectile packet budget" % tick_rate)

	check(_step(world, SimCommand.new(world.tick, 1, 1000, 0, SimCommand.HELD_JUMP, SimCommand.PRESSED_JUMP, 1000, 0)), "%d Hz movement remains executable under live fan pressure" % tick_rate)
	check(caster.is_airborne(), "%d Hz jump can chain while the fan lanes remain active" % tick_rate)
	var saw_center_hit := false
	for _index: int in range(tick_rate * 2):
		check(_step(world, SimCommand.new(world.tick, 1, 0, 0, 0, 0, 1000, 0)), "%d Hz Cinder Fan flight advances" % tick_rate)
		saw_center_hit = saw_center_hit or world.combat_events.any(func(event: Dictionary) -> bool: return event.get("type") == "projectile_hit" and int(event.get("source_wire_id", 0)) == CombatTuning.CINDERFAN_WIRE_ID)
		if saw_center_hit:
			break
	check(saw_center_hit, "%d Hz one readable fan lane resolves authoritative collision" % tick_rate)
	equal(enemy.health, enemy.health_maximum - int(CombatTuning.cast_definition(CombatTuning.CINDERFAN_WIRE_ID)["damage"]), "%d Hz ranged center-lane damage is exact without hidden fan multiplication" % tick_rate)


func _test_oh_tipi_tideline(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var caster: PlayerState = world.player()
	_apply_oh_tipi(caster)
	var enemy: PlayerState = _add_enemy(world, Vector2i(420_000, 360_000))
	var fan_enemy: PlayerState = _add_enemy(world, Vector2i(400_000, 400_000), 3)
	var outside_enemy: PlayerState = _add_enemy(world, Vector2i(160_000, 100_000), 4)
	check(_step(world, SimCommand.new(0, 1, 0, 0, 0, SimCommand.PRESSED_ACTIVE_1, 1000)), "%d Hz Tideline starts" % tick_rate)
	equal(caster.pending_cast_wire_id, CombatTuning.TIDELINE_WIRE_ID, "%d Hz Oh Tipi active is Tideline" % tick_rate)
	equal(caster.flux, caster.flux_maximum - int(CombatTuning.cast_definition(CombatTuning.TIDELINE_WIRE_ID)["flux_cost"]), "%d Hz Tideline Flux spend is exact" % tick_rate)
	var spray_event: Dictionary = {}
	var hit_targets: Array[int] = []
	for _index: int in range(tick_rate * 2):
		check(_step(world, SimCommand.new(world.tick, 1, 0, 0, 0, 0, 1000)), "%d Hz Tideline release steps" % tick_rate)
		for event: Dictionary in world.combat_events:
			if event.get("type") == "spray_fired" and int(event.get("source_wire_id", 0)) == CombatTuning.TIDELINE_WIRE_ID:
				spray_event = event
			if event.get("type") == "spray_hit":
				hit_targets.append(int(event.get("target_id", 0)))
		if not spray_event.is_empty():
			break
	check(not spray_event.is_empty(), "%d Hz Tideline resolves an authoritative spray fan" % tick_rate)
	equal(int(spray_event.get("hit_count", 0)), 2, "%d Hz Tideline reports every legal fan target" % tick_rate)
	equal(hit_targets, [2, 3], "%d Hz Tideline spray hits are stable entity order" % tick_rate)
	equal(world.projectiles.size(), 0, "%d Hz spray never enters projectile storage" % tick_rate)
	equal(enemy.health, enemy.health_maximum - int(CombatTuning.cast_definition(CombatTuning.TIDELINE_WIRE_ID)["damage"]), "%d Hz Tideline damage is exact" % tick_rate)
	equal(fan_enemy.health, fan_enemy.health_maximum - int(CombatTuning.cast_definition(CombatTuning.TIDELINE_WIRE_ID)["damage"]), "%d Hz Tideline damages a second in-fan target once" % tick_rate)
	equal(outside_enemy.health, outside_enemy.health_maximum, "%d Hz Tideline leaves targets outside the fan untouched" % tick_rate)
	equal(enemy.control_state, PlayerState.ControlState.LAUNCHED, "%d Hz Tideline applies bounded launch control" % tick_rate)
	equal(enemy.control_speed, int(CombatTuning.cast_definition(CombatTuning.TIDELINE_WIRE_ID)["hit_control_speed"]), "%d Hz Tideline launch speed is exact" % tick_rate)
	equal(enemy.control_ticks, world.config.milliseconds_to_ticks(int(CombatTuning.cast_definition(CombatTuning.TIDELINE_WIRE_ID)["hit_control_duration_ms"])), "%d Hz Tideline launch duration is exact" % tick_rate)
	equal(fan_enemy.control_state, PlayerState.ControlState.LAUNCHED, "%d Hz second fan target receives the same bounded launch" % tick_rate)

	var covered_collision := CollisionWorld.new(800_000, 720_000)
	covered_collision.add_obstacle(CollisionWorld.Obstacle.new(78, 300_000, 300_000, 340_000, 420_000))
	var covered_world := SimWorld.new(tick_rate, 8, covered_collision)
	var covered_caster: PlayerState = covered_world.player()
	_apply_oh_tipi(covered_caster)
	var covered_enemy: PlayerState = _add_enemy(covered_world, Vector2i(420_000, 360_000))
	check(_step(covered_world, SimCommand.new(0, 1, 0, 0, 0, SimCommand.PRESSED_ACTIVE_1, 1000)), "%d Hz covered Tideline starts" % tick_rate)
	var covered_spray: Dictionary = {}
	for _index: int in range(tick_rate):
		check(_step(covered_world, SimCommand.new(covered_world.tick, 1, 0, 0, 0, 0, 1000)), "%d Hz covered Tideline release steps" % tick_rate)
		for event: Dictionary in covered_world.combat_events:
			if event.get("type") == "spray_fired":
				covered_spray = event
		if not covered_spray.is_empty():
			break
	check(not covered_spray.is_empty(), "%d Hz cover-stopped spray still emits its fan" % tick_rate)
	equal(int(covered_spray.get("hit_count", -1)), 0, "%d Hz authored cover rejects the hidden spray target" % tick_rate)
	equal(covered_enemy.health, covered_enemy.health_maximum, "%d Hz spray cannot damage through cover" % tick_rate)


func _test_oh_tipi_rimewake(tick_rate: int) -> void:
	var roomy_collision := CollisionWorld.new(1_200_000, 720_000)
	var world := SimWorld.new(tick_rate, 11, roomy_collision)
	var caster: PlayerState = world.player()
	_apply_oh_tipi(caster)
	var enemy: PlayerState = _add_enemy(world, Vector2i(400_000, 360_000))
	var ally: PlayerState = _add_enemy(world, Vector2i(400_000, 360_000), 3)
	ally.team_id = caster.team_id
	var protected_enemy: PlayerState = _add_enemy(world, Vector2i(400_000, 360_000), 4)
	protected_enemy.spawn_protection_ticks = tick_rate * 10
	var defeated_enemy: PlayerState = _add_enemy(world, Vector2i(400_000, 360_000), 5)
	defeated_enemy.health = 0
	var before_hash := world.state_hash()
	check(_step(world, SimCommand.new(0, 1, 0, 0, 0, SimCommand.PRESSED_SPELL_3, 1000, 0)), "%d Hz Rimewake slot starts" % tick_rate)
	equal(caster.pending_cast_wire_id, CombatTuning.RIMEWAKE_WIRE_ID, "%d Hz slot 3 adapts to Rimewake" % tick_rate)
	equal(caster.flux, caster.flux_maximum - int(CombatTuning.cast_definition(CombatTuning.RIMEWAKE_WIRE_ID)["flux_cost"]), "%d Hz Rimewake Flux spend is exact" % tick_rate)
	var spawn_event: Dictionary = {}
	var trigger_targets: Array[int] = []
	for _index: int in range(tick_rate):
		check(_step(world, SimCommand.new(world.tick, 1, 0, 0, 0, 0, 1000, 0)), "%d Hz Rimewake release steps" % tick_rate)
		for event: Dictionary in world.combat_events:
			if event.get("type") == "field_spawned":
				spawn_event = event
			elif event.get("type") == "field_triggered":
				trigger_targets.append(int(event.get("target_id", 0)))
		if not spawn_event.is_empty():
			break
	check(not spawn_event.is_empty(), "%d Hz Rimewake creates an authoritative persistent field" % tick_rate)
	equal(world.fields.size(), 1, "%d Hz exactly one Rimewake field persists after release" % tick_rate)
	equal(world.projectiles.size(), 0, "%d Hz Rimewake never enters projectile storage" % tick_rate)
	equal(trigger_targets, [enemy.entity_id], "%d Hz Rimewake first entry resolves in stable order and ignores ally/protected/defeated actors" % tick_rate)
	equal(enemy.control_state, PlayerState.ControlState.SLOWED, "%d Hz Rimewake applies bounded slow control" % tick_rate)
	equal(enemy.slow_ratio, int(CombatTuning.cast_definition(CombatTuning.RIMEWAKE_WIRE_ID)["hit_control_slow_ratio"]), "%d Hz Rimewake slow ratio is exact" % tick_rate)
	equal(enemy.control_ticks, world.config.milliseconds_to_ticks(int(CombatTuning.cast_definition(CombatTuning.RIMEWAKE_WIRE_ID)["hit_control_duration_ms"])), "%d Hz Rimewake slow duration is exact" % tick_rate)
	equal(ally.control_state, PlayerState.ControlState.FREE, "%d Hz allied actor is unaffected by Rimewake" % tick_rate)
	equal(protected_enemy.control_state, PlayerState.ControlState.FREE, "%d Hz protected actor is unaffected by Rimewake" % tick_rate)
	equal(defeated_enemy.control_state, PlayerState.ControlState.FREE, "%d Hz defeated actor is unaffected by Rimewake" % tick_rate)
	equal(caster.active_2_cooldown_ticks, world.config.milliseconds_to_ticks(int(CombatTuning.cast_definition(CombatTuning.RIMEWAKE_WIRE_ID)["cooldown_ms"])), "%d Hz Rimewake owns an independent exact cooldown" % tick_rate)
	check(world.state_hash() != before_hash, "%d Hz persistent field contributes to canonical state" % tick_rate)

	MovementSystem.apply_control_state(enemy, PlayerState.ControlState.FREE, 0, Vector2i.ZERO, 0, world.config)
	check(_step(world, SimCommand.new(world.tick, 1)), "%d Hz occupied Rimewake field advances" % tick_rate)
	equal(enemy.control_state, PlayerState.ControlState.FREE, "%d Hz one field cannot retrigger the same actor" % tick_rate)
	check(not world.combat_events.any(func(event: Dictionary) -> bool: return event.get("type") == "field_triggered" and int(event.get("target_id", 0)) == enemy.entity_id), "%d Hz repeat field contact emits no duplicate trigger" % tick_rate)

	var late_enemy: PlayerState = _add_enemy(world, Vector2i(400_000, 360_000), 6)
	check(_step(world, SimCommand.new(world.tick, 1)), "%d Hz late field entry advances" % tick_rate)
	equal(late_enemy.control_state, PlayerState.ControlState.SLOWED, "%d Hz a later hostile entrant can trigger the surviving field" % tick_rate)
	check(world.combat_events.any(func(event: Dictionary) -> bool: return event.get("type") == "field_triggered" and int(event.get("target_id", 0)) == late_enemy.entity_id), "%d Hz late entry has a semantic cue" % tick_rate)

	var remaining_ticks: int = world.fields[0].lifetime_ticks
	for _index: int in range(maxi(0, remaining_ticks - 1)):
		check(_step(world, SimCommand.new(world.tick, 1)), "%d Hz Rimewake lifetime advances" % tick_rate)
	equal(world.fields.size(), 1, "%d Hz Rimewake survives through its penultimate lifetime tick" % tick_rate)
	check(_step(world, SimCommand.new(world.tick, 1)), "%d Hz Rimewake expiration advances" % tick_rate)
	equal(world.fields.size(), 0, "%d Hz Rimewake expires on its exact normalized lifetime" % tick_rate)
	check(world.combat_events.any(func(event: Dictionary) -> bool: return event.get("type") == "field_expired"), "%d Hz Rimewake expiration is semantically observable" % tick_rate)

	var blocked_collision := CollisionWorld.new(1_200_000, 720_000)
	# Leave enough real clearance for the enlarged field and its minimum range.
	blocked_collision.add_obstacle(CollisionWorld.Obstacle.new(81, 360_000, 290_000, 470_000, 430_000))
	var blocked_world := SimWorld.new(tick_rate, 12, blocked_collision)
	var blocked_caster: PlayerState = blocked_world.player()
	_apply_oh_tipi(blocked_caster)
	check(_step(blocked_world, SimCommand.new(0, 1, 0, 0, 0, SimCommand.PRESSED_SPELL_3, 1000, 0)), "%d Hz obstructed Rimewake starts" % tick_rate)
	for _index: int in range(tick_rate):
		check(_step(blocked_world, SimCommand.new(blocked_world.tick, 1, 0, 0, 0, 0, 1000, 0)), "%d Hz obstructed Rimewake release advances" % tick_rate)
		if not blocked_world.fields.is_empty():
			break
	equal(blocked_world.fields.size(), 1, "%d Hz Rimewake traces back to safe ground when maximum range is obstructed" % tick_rate)
	if not blocked_world.fields.is_empty():
		check(blocked_world.fields[0].position_x + blocked_world.fields[0].radius < 360_000, "%d Hz fallback placement keeps the entire authored radius clear of the obstacle" % tick_rate)

	var sealed_collision := CollisionWorld.new(1_200_000, 720_000)
	sealed_collision.add_obstacle(CollisionWorld.Obstacle.new(82, 220_000, 270_000, 470_000, 450_000))
	var sealed_world := SimWorld.new(tick_rate, 13, sealed_collision)
	var sealed_caster: PlayerState = sealed_world.player()
	_apply_oh_tipi(sealed_caster)
	check(_step(sealed_world, SimCommand.new(0, 1, 0, 0, 0, SimCommand.PRESSED_SPELL_3, 1000, 0)), "%d Hz fully blocked Rimewake starts" % tick_rate)
	var saw_blocked: bool = false
	for _index: int in range(tick_rate):
		check(_step(sealed_world, SimCommand.new(sealed_world.tick, 1, 0, 0, 0, 0, 1000, 0)), "%d Hz fully blocked Rimewake release advances" % tick_rate)
		saw_blocked = saw_blocked or sealed_world.combat_events.any(func(event: Dictionary) -> bool: return event.get("type") == "cast_blocked" and int(event.get("wire_id", 0)) == CombatTuning.RIMEWAKE_WIRE_ID)
		if saw_blocked:
			break
	check(saw_blocked, "%d Hz unsafe Rimewake placement refuses visibly" % tick_rate)
	equal(sealed_world.fields.size(), 0, "%d Hz fully blocked placement creates no field state" % tick_rate)
	check(sealed_caster.active_2_cooldown_ticks > 0, "%d Hz blocked release retains its committed cooldown" % tick_rate)


func _test_s_wayne_eclipse_disc(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var caster: PlayerState = world.player()
	_apply_s_wayne(caster)
	var enemy: PlayerState = _add_enemy(world, Vector2i(360_000, 360_000))
	var initial_flux: int = caster.flux
	check(_step(world, SimCommand.new(0, 1, 0, 0, SimCommand.HELD_PRIMARY, 0, 1000)), "%d Hz Eclipse Disc starts" % tick_rate)
	equal(caster.pending_cast_wire_id, CombatTuning.ECLIPSE_DISC_WIRE_ID, "%d Hz S. Wayne primary is Eclipse Disc" % tick_rate)
	equal(caster.flux, initial_flux - int(CombatTuning.cast_definition(CombatTuning.ECLIPSE_DISC_WIRE_ID)["flux_cost"]), "%d Hz Eclipse Disc spends exact positive Flux" % tick_rate)
	var saw_hit: bool = false
	for _index: int in range(tick_rate):
		check(_step(world, SimCommand.new(world.tick, 1, 0, 0, 0, 0, 1000)), "%d Hz Eclipse Disc flight steps" % tick_rate)
		saw_hit = saw_hit or world.combat_events.any(func(event: Dictionary) -> bool: return event.get("type") == "projectile_hit" and int(event.get("source_wire_id", 0)) == CombatTuning.ECLIPSE_DISC_WIRE_ID)
		if saw_hit:
			break
	check(saw_hit, "%d Hz Eclipse Disc hits authoritatively" % tick_rate)
	equal(enemy.health, enemy.health_maximum - int(CombatTuning.cast_definition(CombatTuning.ECLIPSE_DISC_WIRE_ID)["damage"]), "%d Hz Eclipse Disc damage is exact" % tick_rate)


func _test_s_wayne_disc_ricochet(tick_rate: int) -> void:
	var collision := CollisionWorld.new(800_000, 720_000)
	collision.add_obstacle(CollisionWorld.Obstacle.new(77, 300_000, 200_000, 340_000, 500_000))
	var owner := PlayerState.new(1)
	var projectile := ProjectileState.new(
		9004, owner.entity_id, owner.team_id,
		CombatTuning.ECLIPSE_DISC_WIRE_ID, int(CombatTuning.cast_definition(CombatTuning.ECLIPSE_DISC_WIRE_ID)["element_wire_id"]),
		Vector2i(250_000, 350_000), Vector2i(int(CombatTuning.cast_definition(CombatTuning.ECLIPSE_DISC_WIRE_ID)["speed"]), 0),
		int(CombatTuning.cast_definition(CombatTuning.ECLIPSE_DISC_WIRE_ID)["radius"]), int(CombatTuning.cast_definition(CombatTuning.ECLIPSE_DISC_WIRE_ID)["damage"]),
		tick_rate, CombatTuning.NO_HIT_CONTROL_STATE, 0, 0, 1000,
		int(CombatTuning.cast_definition(CombatTuning.ECLIPSE_DISC_WIRE_ID)["remaining_bounces"]),
	)
	var projectiles: Array[ProjectileState] = [projectile]
	var impacted: bool = false
	var terminal: bool = false
	for _index: int in range(tick_rate):
		var events: Array[Dictionary] = []
		projectiles = CombatSystem.advance_projectiles(projectiles, [owner], SimConfig.new(tick_rate), collision, events)
		impacted = impacted or events.any(func(event: Dictionary) -> bool: return event.get("type") == "projectile_impact" and int(event.get("wall_id", 0)) == 77)
		terminal = terminal or events.any(func(event: Dictionary) -> bool: return event.get("type") == "projectile_terminal" and int(event.get("element_wire_id", 0)) == 8)
		if impacted:
			break
	check(impacted, "%d Hz Eclipse Disc explodes on worldbone" % tick_rate)
	check(terminal, "%d Hz Eclipse Disc emits one terminal Dark material source" % tick_rate)
	equal(projectiles.size(), 0, "%d Hz all projectile spells stop at obstacles" % tick_rate)


func _test_s_wayne_pocket_eclipse(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var caster: PlayerState = world.player()
	_apply_s_wayne(caster)
	var enemy: PlayerState = _add_enemy(world, Vector2i(420_000, 360_000))
	check(_step(world, SimCommand.new(0, 1, 0, 0, 0, SimCommand.PRESSED_ACTIVE_1, 1000)), "%d Hz Pocket Eclipse starts" % tick_rate)
	equal(caster.pending_cast_wire_id, CombatTuning.POCKET_ECLIPSE_WIRE_ID, "%d Hz S. Wayne active is Pocket Eclipse" % tick_rate)
	equal(caster.flux, caster.flux_maximum - int(CombatTuning.cast_definition(CombatTuning.POCKET_ECLIPSE_WIRE_ID)["flux_cost"]), "%d Hz Pocket Eclipse Flux spend is exact" % tick_rate)
	var beam_event: Dictionary = {}
	for _index: int in range(tick_rate * 2):
		check(_step(world, SimCommand.new(world.tick, 1, 0, 0, 0, 0, 1000)), "%d Hz Pocket Eclipse release steps" % tick_rate)
		for event: Dictionary in world.combat_events:
			if event.get("type") == "beam_fired" and int(event.get("source_wire_id", 0)) == CombatTuning.POCKET_ECLIPSE_WIRE_ID:
				beam_event = event
		if not beam_event.is_empty():
			break
	check(not beam_event.is_empty(), "%d Hz Pocket Eclipse resolves an authoritative beam" % tick_rate)
	equal(int(beam_event.get("target_id", 0)), enemy.entity_id, "%d Hz Pocket Eclipse names its first legal target" % tick_rate)
	equal(Vector2i(int(beam_event.get("end_x", 0)), int(beam_event.get("end_y", 0))), Vector2i(enemy.position_x, enemy.position_y), "%d Hz Pocket Eclipse terminates visibly at its hit" % tick_rate)
	equal(world.projectiles.size(), 0, "%d Hz beam never enters projectile storage" % tick_rate)
	equal(enemy.health, enemy.health_maximum - int(CombatTuning.cast_definition(CombatTuning.POCKET_ECLIPSE_WIRE_ID)["damage"]), "%d Hz Pocket Eclipse damage is exact" % tick_rate)
	equal(enemy.control_state, PlayerState.ControlState.SLOWED, "%d Hz Pocket Eclipse applies bounded slow control" % tick_rate)
	equal(enemy.slow_ratio, int(CombatTuning.cast_definition(CombatTuning.POCKET_ECLIPSE_WIRE_ID)["hit_control_slow_ratio"]), "%d Hz Pocket Eclipse slow ratio is exact" % tick_rate)
	equal(enemy.control_ticks, world.config.milliseconds_to_ticks(int(CombatTuning.cast_definition(CombatTuning.POCKET_ECLIPSE_WIRE_ID)["hit_control_duration_ms"])), "%d Hz Pocket Eclipse slow duration is exact" % tick_rate)

	var covered_collision := CollisionWorld.new(800_000, 720_000)
	covered_collision.add_obstacle(CollisionWorld.Obstacle.new(77, 300_000, 300_000, 340_000, 420_000))
	var covered_world := SimWorld.new(tick_rate, 9, covered_collision)
	var covered_caster: PlayerState = covered_world.player()
	_apply_s_wayne(covered_caster)
	var covered_enemy: PlayerState = _add_enemy(covered_world, Vector2i(420_000, 360_000))
	check(_step(covered_world, SimCommand.new(0, 1, 0, 0, 0, SimCommand.PRESSED_ACTIVE_1, 1000)), "%d Hz covered Pocket Eclipse starts" % tick_rate)
	var covered_event: Dictionary = {}
	for _index: int in range(tick_rate):
		check(_step(covered_world, SimCommand.new(covered_world.tick, 1, 0, 0, 0, 0, 1000)), "%d Hz covered Pocket Eclipse release steps" % tick_rate)
		for event: Dictionary in covered_world.combat_events:
			if event.get("type") == "beam_fired":
				covered_event = event
		if not covered_event.is_empty():
			break
	check(not covered_event.is_empty(), "%d Hz cover-stopped beam still emits a readable lane" % tick_rate)
	equal(int(covered_event.get("target_id", -1)), 0, "%d Hz authored cover prevents the hidden target hit" % tick_rate)
	check(int(covered_event.get("end_x", 0)) < 300_000, "%d Hz beam endpoint stops before cover" % tick_rate)
	equal(covered_enemy.health, covered_enemy.health_maximum, "%d Hz beam cannot damage through cover" % tick_rate)


func _test_movement_spell_chains(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var caster: PlayerState = world.player()
	_apply_oh_tipi(caster)
	var jump_and_cast := SimCommand.new(
		world.tick,
		caster.entity_id,
		1000,
		0,
		SimCommand.HELD_JUMP,
		SimCommand.PRESSED_JUMP | SimCommand.PRESSED_SPELL_1,
		1000,
		0,
	)
	check(_step(world, jump_and_cast), "%d Hz simultaneous jump and Rillshot steps" % tick_rate)
	check(caster.hop_ticks > 0, "%d Hz spell startup does not suppress a legal movement action" % tick_rate)
	equal(caster.pending_cast_wire_id, CombatTuning.RILLSHOT_WIRE_ID, "%d Hz movement does not suppress spell startup" % tick_rate)
	while caster.pending_cast_wire_id != 0:
		check(_step(world, SimCommand.new(world.tick, caster.entity_id, 1000, 0, SimCommand.HELD_JUMP)), "%d Hz moving Rillshot startup advances" % tick_rate)
	check(caster.cast_recovery_ticks > 0, "%d Hz released Rillshot exposes its presentation recovery" % tick_rate)
	var flux_before_chain := caster.flux
	check(_step(world, SimCommand.new(world.tick, caster.entity_id, 1000, 0, 0, SimCommand.PRESSED_SPELL_2)), "%d Hz recovery-chain Tideline command steps" % tick_rate)
	equal(caster.pending_cast_wire_id, CombatTuning.TIDELINE_WIRE_ID, "%d Hz a different spell starts during generic recovery" % tick_rate)
	equal(caster.flux, flux_before_chain - int(CombatTuning.cast_definition(CombatTuning.TIDELINE_WIRE_ID)["flux_cost"]), "%d Hz recovery chain retains exact spell cost" % tick_rate)
	check(_step(world, SimCommand.new(world.tick, caster.entity_id, 1000, 0, 0, SimCommand.PRESSED_SPELL_3)), "%d Hz occupied-channel command steps" % tick_rate)
	check(world.combat_events.any(func(event: Dictionary) -> bool: return event.get("type") == "cast_refused" and event.get("reason") == "startup_commitment" and int(event.get("wire_id", 0)) == CombatTuning.RIMEWAKE_WIRE_ID), "%d Hz occupied startup refuses the next spell visibly" % tick_rate)

	var rooted_world := SimWorld.new(tick_rate)
	var rooted: PlayerState = rooted_world.player()
	_apply_oh_tipi(rooted)
	check(MovementSystem.apply_control_state(rooted, PlayerState.ControlState.ROOTED, 300, Vector2i.RIGHT, 0, rooted_world.config), "%d Hz rooted chain fixture applies" % tick_rate)
	var rooted_flux := rooted.flux
	check(_step(rooted_world, SimCommand.new(rooted_world.tick, rooted.entity_id, 0, 0, 0, SimCommand.PRESSED_SPELL_2)), "%d Hz rooted spell command steps" % tick_rate)
	equal(rooted.pending_cast_wire_id, 0, "%d Hz rooted physical state cannot begin a spell" % tick_rate)
	equal(rooted.flux, rooted_flux, "%d Hz rooted refusal spends no Flux" % tick_rate)
	check(rooted_world.combat_events.any(func(event: Dictionary) -> bool: return event.get("reason") == "control_rooted"), "%d Hz rooted refusal names its physical reason" % tick_rate)

	var cooldown_world := SimWorld.new(tick_rate)
	var cooling: PlayerState = cooldown_world.player()
	_apply_oh_tipi(cooling)
	cooling.primary_cooldown_ticks = 10
	check(_step(cooldown_world, SimCommand.new(cooldown_world.tick, cooling.entity_id, 0, 0, 0, SimCommand.PRESSED_SPELL_1)), "%d Hz cooling spell command steps" % tick_rate)
	check(cooldown_world.combat_events.any(func(event: Dictionary) -> bool: return event.get("reason") == "cooldown" and int(event.get("wire_id", 0)) == CombatTuning.RILLSHOT_WIRE_ID), "%d Hz own cooldown refusal is visible" % tick_rate)


func _test_casts_during_every_movement_mode(tick_rate: int) -> void:
	for champion_id: String in ["s_wayne", "oh_tipi", "red_baron"]:
		for mode: int in PlayerState.MovementMode.values():
			var world := SimWorld.new(tick_rate)
			var caster: PlayerState = world.player()
			match champion_id:
				"s_wayne": _apply_s_wayne(caster)
				"oh_tipi": _apply_oh_tipi(caster)
				"red_baron": _apply_red_baron(caster)
			caster.movement_mode = mode
			caster.movement_commitment_ticks = 24
			caster.cast_recovery_ticks = 18
			var policy := ActionTransitionPolicy.new()
			check(policy.load_from_file(), "cast/movement fixture loads current policy")
			var events: Array[Dictionary] = []
			var flux_before := caster.flux
			var stamina_before := caster.stamina
			var wire := caster.primary_wire_id
			var label := "%s/%s" % [champion_id, PlayerState.MovementMode.keys()[mode]]
			# Direct production combat entry preserves the seeded movement phase;
			# the existing simultaneous-jump test separately exercises world order.
			# Raw mode tags (including compatibility-only values) are not control
			# locks or newly enabled moves. Separate ControlState gates still apply.
			CombatSystem.step_player(caster, SimCommand.new(0, caster.entity_id, 0, 0, 0, SimCommand.PRESSED_SPELL_1), world.config, 100, 200, world.collision, events, policy)
			equal(caster.pending_cast_wire_id, wire, label + " permits paid spell startup during movement/recovery")
			check(events.any(func(event: Dictionary) -> bool: return event.get("type") == "cast_started"), label + " emits real cast start")
			equal(caster.flux, flux_before - int(CombatTuning.cast_definition(wire)["flux_cost"]), label + " spends exact positive Flux")
			equal(caster.stamina, stamina_before, label + " does not charge movement Stamina for a spell")
			equal(caster.movement_mode, mode, label + " does not cancel movement")
			equal(caster.movement_commitment_ticks, 24, label + " preserves movement phase")


func _test_pressure_exhaustion_and_recovery(tick_rate: int) -> void:
	var abilities := AbilityCatalog.new()
	check(abilities.load_from_file("res://content/abilities/foundation_abilities_v1.json"), "pressure candidate loads the canonical spells")
	var champions := ChampionCatalog.new()
	check(champions.load_from_file("res://content/champions/foundation_champions_v1.json", abilities), "pressure candidate loads all promoted champions")
	for champion_id: String in champions.ordered_champion_ids():
		var world := SimWorld.new(tick_rate)
		var caster: PlayerState = world.player()
		check(champions.apply_to_player(caster, champion_id), champion_id + " pressure candidate applies")
		var definition := CombatTuning.cast_definition(caster.primary_wire_id)
		var primary_cost := int(definition["flux_cost"])
		@warning_ignore("integer_division")
		var expected_casts: int = caster.flux_maximum / primary_cost
		var cast_count := 0
		var exhausted_tick := -1
		var cycle_bound := world.config.milliseconds_to_ticks(int(definition["startup_ms"])) + world.config.milliseconds_to_ticks(int(definition["cooldown_ms"])) + 2
		var exhaustion_limit := expected_casts * cycle_bound
		for _index: int in range(exhaustion_limit):
			# This fixture measures cost/cadence, not material admission. The
			# separate capacity fixture above preserves and tests every deposit.
			world.deposits.clear()
			world.reactions.clear()
			check(_step(world, SimCommand.new(world.tick, caster.entity_id, 0, 0, SimCommand.HELD_PRIMARY, 0, 1000, 0)), "%d Hz %s sustained-pressure tick steps" % [tick_rate, champion_id])
			for event: Dictionary in world.combat_events:
				if event.get("type") == "cast_started" and int(event.get("wire_id", 0)) == caster.primary_wire_id:
					cast_count += 1
			if caster.pending_cast_wire_id == 0 and caster.primary_cooldown_ticks == 0 and caster.flux < primary_cost:
				exhausted_tick = world.tick
				break
		check(exhausted_tick > 0 and exhausted_tick <= exhaustion_limit, "%d Hz %s sustained pressure exhausts inside its authored cost/cadence bound" % [tick_rate, champion_id])
		print("RESOURCE_TUNING %s: flux=%.1f; stamina=%.1f; paid_primary_casts=%d; exhaustion_ms=%.3f" % [champion_id, caster.flux_maximum / 1000.0, caster.stamina_maximum / 1000.0, cast_count, exhausted_tick * 1000.0 / tick_rate])
		equal(cast_count, expected_casts, "%d Hz %s receives no free pressure casts" % [tick_rate, champion_id])
		check(caster.flux < primary_cost, "%d Hz %s exhaustion is visible in canonical Flux" % [tick_rate, champion_id])

		var pause_ticks := world.config.milliseconds_to_ticks(PlayerTuning.FLUX_RECOVERY_DELAY_MS + 500)
		for _index: int in range(pause_ticks):
			check(_step(world, SimCommand.new(world.tick, caster.entity_id)), "%d Hz %s deliberate recovery tick steps" % [tick_rate, champion_id])
		check(caster.flux >= primary_cost, "%d Hz %s deliberate pause restores a cast" % [tick_rate, champion_id])
		var recovered_flux := caster.flux
		check(_step(world, SimCommand.new(world.tick, caster.entity_id, 0, 0, 0, SimCommand.PRESSED_SPELL_1, 1000, 0)), "%d Hz %s recovered primary command steps" % [tick_rate, champion_id])
		equal(caster.pending_cast_wire_id, caster.primary_wire_id, "%d Hz %s recovered pressure starts" % [tick_rate, champion_id])
		check(caster.flux < recovered_flux, "%d Hz %s recovered cast pays Flux again" % [tick_rate, champion_id])


func _test_edgeweave(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var runner: PlayerState = world.player()
	runner.position_x = 350_000
	runner.position_y = 100_000
	runner.velocity_x = 400_000
	runner.velocity_y = 0
	runner.stamina = 50_000
	var shooter: PlayerState = _add_enemy(world, Vector2i(180_000, 100_000))
	var hit_radius: int = runner.radius + int(CombatTuning.cast_definition(CombatTuning.PRIMARY_WIRE_ID)["radius"])
	var projectile := ProjectileState.new(
		9001,
		shooter.entity_id,
		shooter.team_id,
		CombatTuning.PRIMARY_WIRE_ID,
		int(CombatTuning.cast_definition(CombatTuning.PRIMARY_WIRE_ID)["element_wire_id"]),
		Vector2i(runner.position_x - 30_000, runner.position_y + hit_radius + 8_000),
		Vector2i(2_000_000, 0),
		int(CombatTuning.cast_definition(CombatTuning.PRIMARY_WIRE_ID)["radius"]),
		int(CombatTuning.cast_definition(CombatTuning.PRIMARY_WIRE_ID)["damage"]),
		tick_rate,
	)
	var events: Array[Dictionary] = []
	var projectiles: Array[ProjectileState] = [projectile]
	projectiles = CombatSystem.advance_projectiles(projectiles, world.players, world.config, world.collision, events)
	equal(runner.stamina, 50_000 + CombatTuning.EDGEWEAVE_REWARD, "%d Hz hostile swept near-miss rewards exact Stamina" % tick_rate)
	equal(runner.health, PlayerTuning.HEALTH_MAXIMUM, "%d Hz Edgeweave outer band is not a hit" % tick_rate)
	check(runner.edgeweave_cooldown_ticks > 0, "%d Hz Edgeweave cooldown starts" % tick_rate)
	check(projectile.has_grazed(runner.entity_id), "%d Hz projectile records rewarded fighter" % tick_rate)
	check(events.any(func(event: Dictionary) -> bool: return event.get("type") == "edgeweave"), "%d Hz Edgeweave emits a semantic event" % tick_rate)

	runner.edgeweave_cooldown_ticks = 0
	runner.stamina = 50_000
	events = []
	projectiles = CombatSystem.advance_projectiles(projectiles, world.players, world.config, world.collision, events)
	equal(runner.stamina, 50_000, "%d Hz one projectile cannot reward the same fighter twice" % tick_rate)

	runner.edgeweave_cooldown_ticks = 0
	runner.health = PlayerTuning.HEALTH_MAXIMUM
	runner.stamina = 50_000
	var hit_projectile := ProjectileState.new(
		9002,
		shooter.entity_id,
		shooter.team_id,
		CombatTuning.PRIMARY_WIRE_ID,
		int(CombatTuning.cast_definition(CombatTuning.PRIMARY_WIRE_ID)["element_wire_id"]),
		Vector2i(runner.position_x - 30_000, runner.position_y),
		Vector2i(2_000_000, 0),
		int(CombatTuning.cast_definition(CombatTuning.PRIMARY_WIRE_ID)["radius"]),
		int(CombatTuning.cast_definition(CombatTuning.PRIMARY_WIRE_ID)["damage"]),
		tick_rate,
	)
	events = []
	CombatSystem.advance_projectiles([hit_projectile], world.players, world.config, world.collision, events)
	equal(runner.stamina, 50_000, "%d Hz inner hit volume never rewards Edgeweave" % tick_rate)
	equal(runner.health, PlayerTuning.HEALTH_MAXIMUM - int(CombatTuning.cast_definition(CombatTuning.PRIMARY_WIRE_ID)["damage"]), "%d Hz inner hit still applies damage" % tick_rate)

	runner.health = PlayerTuning.HEALTH_MAXIMUM
	runner.edgeweave_cooldown_ticks = 0
	runner.stamina = 50_000
	var training_projectile := ProjectileState.new(
		9003, shooter.entity_id, shooter.team_id, 9999, 0,
		Vector2i(runner.position_x - 30_000, runner.position_y + hit_radius + 8_000),
		Vector2i(2_000_000, 0), int(CombatTuning.cast_definition(CombatTuning.PRIMARY_WIRE_ID)["radius"]), 0, tick_rate
	)
	CombatSystem.advance_projectiles([training_projectile], world.players, world.config, world.collision, [])
	equal(runner.stamina, 50_000, "%d Hz training pressure never rewards Edgeweave" % tick_rate)
