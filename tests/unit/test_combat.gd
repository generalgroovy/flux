extends FluxTestSuite


func run() -> int:
	for tick_rate: int in [60, 120]:
		_test_semantic_spell_slots(tick_rate)
		_test_resource_free_primary(tick_rate)
		_test_vector_lance_flux_and_hit(tick_rate)
		_test_oh_tipi_rillshot(tick_rate)
		_test_oh_tipi_tideline(tick_rate)
		_test_s_wayne_eclipse_disc(tick_rate)
		_test_s_wayne_disc_ricochet(tick_rate)
		_test_s_wayne_pocket_eclipse(tick_rate)
		_test_edgeweave(tick_rate)
	return finish("combat")


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

	var empty_world := SimWorld.new(tick_rate)
	var empty: PlayerState = empty_world.player()
	var initial_flux: int = empty.flux
	check(_step(empty_world, SimCommand.new(0, 1, 0, 0, 0, SimCommand.PRESSED_SPELL_4, 1000, 0)), "%d Hz empty slot command steps" % tick_rate)
	equal(empty.pending_cast_wire_id, 0, "%d Hz empty slot starts no cast" % tick_rate)
	equal(empty.flux, initial_flux, "%d Hz empty slot spends no Flux" % tick_rate)
	check(empty_world.combat_events.any(func(event: Dictionary) -> bool: return event.get("type") == "cast_refused" and event.get("reason") == "empty_slot" and int(event.get("slot", 0)) == 4), "%d Hz empty slot refusal is explicit" % tick_rate)

	var rewoven_world := SimWorld.new(tick_rate)
	var rewoven: PlayerState = rewoven_world.player()
	check(rewoven.place_kit_spell(4, rewoven.primary_wire_id), "%d Hz primary rewoves into slot 5" % tick_rate)
	check(_step(rewoven_world, SimCommand.new(0, 1, 0, 0, 0, SimCommand.PRESSED_SPELL_5, 1000, 0)), "%d Hz rewoven command steps" % tick_rate)
	equal(rewoven.pending_cast_wire_id, rewoven.primary_wire_id, "%d Hz rewoven slot invokes its canonical spell wire" % tick_rate)


func _step(world: SimWorld, command: SimCommand) -> bool:
	return world.step([command])


func _add_enemy(world: SimWorld, position: Vector2i) -> PlayerState:
	var enemy := PlayerState.new(2)
	enemy.team_id = 2
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


func _test_resource_free_primary(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var caster: PlayerState = world.player()
	var enemy: PlayerState = _add_enemy(world, Vector2i(360_000, 360_000))
	var initial_flux: int = caster.flux
	check(_step(world, SimCommand.new(0, 1, 0, 0, SimCommand.HELD_PRIMARY, 0, 1000, 0)), "%d Hz primary start steps" % tick_rate)
	equal(caster.pending_cast_wire_id, CombatTuning.PRIMARY_WIRE_ID, "%d Hz primary enters authored startup" % tick_rate)
	equal(caster.flux, initial_flux, "%d Hz primary spends no Flux" % tick_rate)
	var saw_spawn: bool = false
	var saw_hit: bool = false
	for _index: int in range(tick_rate):
		check(_step(world, SimCommand.new(world.tick, 1, 0, 0, 0, 0, 1000, 0)), "%d Hz primary flight steps" % tick_rate)
		for event: Dictionary in world.combat_events:
			saw_spawn = saw_spawn or String(event.get("type", "")) == "projectile_spawned"
			saw_hit = saw_hit or String(event.get("type", "")) == "projectile_hit"
		if saw_hit:
			break
	check(saw_spawn, "%d Hz primary releases after startup" % tick_rate)
	check(saw_hit, "%d Hz primary resolves an authoritative hit" % tick_rate)
	equal(enemy.health, PlayerTuning.HEALTH_MAXIMUM - CombatTuning.PRIMARY_DAMAGE, "%d Hz primary damage is exact" % tick_rate)
	equal(caster.flux, initial_flux, "%d Hz primary remains Flux-free through impact" % tick_rate)
	check(caster.primary_cooldown_ticks > 0, "%d Hz primary cooldown is active" % tick_rate)


func _test_vector_lance_flux_and_hit(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var caster: PlayerState = world.player()
	var enemy: PlayerState = _add_enemy(world, Vector2i(420_000, 360_000))
	check(_step(world, SimCommand.new(0, 1, 0, 0, 0, SimCommand.PRESSED_ACTIVE_1, 1000, 0)), "%d Hz Vector Lance start steps" % tick_rate)
	equal(caster.pending_cast_wire_id, CombatTuning.ACTIVE_1_WIRE_ID, "%d Hz Vector Lance enters authored startup" % tick_rate)
	equal(caster.flux, PlayerTuning.FLUX_MAXIMUM - CombatTuning.ACTIVE_1_FLUX_COST, "%d Hz Vector Lance Flux cost is exact" % tick_rate)
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
	equal(enemy.health, PlayerTuning.HEALTH_MAXIMUM - CombatTuning.ACTIVE_1_DAMAGE, "%d Hz Vector Lance damage is exact" % tick_rate)
	check(caster.active_1_cooldown_ticks > 0, "%d Hz Vector Lance cooldown is active" % tick_rate)

	var refused_world := SimWorld.new(tick_rate)
	var refused: PlayerState = refused_world.player()
	refused.flux = CombatTuning.ACTIVE_1_FLUX_COST - 1
	refused.flux_recovery_delay_ticks = tick_rate
	check(_step(refused_world, SimCommand.new(0, 1, 0, 0, 0, SimCommand.PRESSED_ACTIVE_1)), "%d Hz refused cast command steps" % tick_rate)
	equal(refused.pending_cast_wire_id, 0, "%d Hz unaffordable active does not enter startup" % tick_rate)
	equal(refused.flux, CombatTuning.ACTIVE_1_FLUX_COST - 1, "%d Hz refused active spends nothing while recovery is held" % tick_rate)
	check(refused_world.combat_events.any(func(event: Dictionary) -> bool: return event.get("type") == "cast_refused"), "%d Hz refused active emits a diagnostic event" % tick_rate)


func _test_oh_tipi_rillshot(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var caster: PlayerState = world.player()
	_apply_oh_tipi(caster)
	var enemy: PlayerState = _add_enemy(world, Vector2i(360_000, 360_000))
	var initial_flux: int = caster.flux
	check(_step(world, SimCommand.new(0, 1, 0, 0, SimCommand.HELD_PRIMARY, 0, 1000)), "%d Hz Rillshot starts" % tick_rate)
	equal(caster.pending_cast_wire_id, CombatTuning.RILLSHOT_WIRE_ID, "%d Hz Oh Tipi primary is Rillshot" % tick_rate)
	equal(caster.flux, initial_flux, "%d Hz Rillshot is resource-free" % tick_rate)
	var saw_hit: bool = false
	for _index: int in range(tick_rate):
		check(_step(world, SimCommand.new(world.tick, 1, 0, 0, 0, 0, 1000)), "%d Hz Rillshot flight steps" % tick_rate)
		saw_hit = saw_hit or world.combat_events.any(func(event: Dictionary) -> bool: return event.get("type") == "projectile_hit" and int(event.get("source_wire_id", 0)) == CombatTuning.RILLSHOT_WIRE_ID)
		if saw_hit:
			break
	check(saw_hit, "%d Hz Rillshot hits authoritatively" % tick_rate)
	equal(enemy.health, enemy.health_maximum - CombatTuning.RILLSHOT_DAMAGE, "%d Hz Rillshot damage is exact" % tick_rate)


func _test_oh_tipi_tideline(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var caster: PlayerState = world.player()
	_apply_oh_tipi(caster)
	var enemy: PlayerState = _add_enemy(world, Vector2i(420_000, 360_000))
	check(_step(world, SimCommand.new(0, 1, 0, 0, 0, SimCommand.PRESSED_ACTIVE_1, 1000)), "%d Hz Tideline starts" % tick_rate)
	equal(caster.pending_cast_wire_id, CombatTuning.TIDELINE_WIRE_ID, "%d Hz Oh Tipi active is Tideline" % tick_rate)
	equal(caster.flux, caster.flux_maximum - CombatTuning.TIDELINE_FLUX_COST, "%d Hz Tideline Flux spend is exact" % tick_rate)
	var saw_hit: bool = false
	for _index: int in range(tick_rate * 2):
		check(_step(world, SimCommand.new(world.tick, 1, 0, 0, 0, 0, 1000)), "%d Hz Tideline flight steps" % tick_rate)
		saw_hit = saw_hit or world.combat_events.any(func(event: Dictionary) -> bool: return event.get("type") == "projectile_hit" and int(event.get("source_wire_id", 0)) == CombatTuning.TIDELINE_WIRE_ID)
		if saw_hit:
			break
	check(saw_hit, "%d Hz Tideline hits authoritatively" % tick_rate)
	equal(enemy.health, enemy.health_maximum - CombatTuning.TIDELINE_DAMAGE, "%d Hz Tideline damage is exact" % tick_rate)
	equal(enemy.control_state, PlayerState.ControlState.LAUNCHED, "%d Hz Tideline applies bounded launch control" % tick_rate)
	equal(enemy.control_speed, CombatTuning.TIDELINE_LAUNCH_SPEED, "%d Hz Tideline launch speed is exact" % tick_rate)
	equal(enemy.control_ticks, world.config.milliseconds_to_ticks(CombatTuning.TIDELINE_LAUNCH_DURATION_MS), "%d Hz Tideline launch duration is exact" % tick_rate)


func _test_s_wayne_eclipse_disc(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var caster: PlayerState = world.player()
	_apply_s_wayne(caster)
	var enemy: PlayerState = _add_enemy(world, Vector2i(360_000, 360_000))
	var initial_flux: int = caster.flux
	check(_step(world, SimCommand.new(0, 1, 0, 0, SimCommand.HELD_PRIMARY, 0, 1000)), "%d Hz Eclipse Disc starts" % tick_rate)
	equal(caster.pending_cast_wire_id, CombatTuning.ECLIPSE_DISC_WIRE_ID, "%d Hz S. Wayne primary is Eclipse Disc" % tick_rate)
	equal(caster.flux, initial_flux, "%d Hz Eclipse Disc is resource-free" % tick_rate)
	var saw_hit: bool = false
	for _index: int in range(tick_rate):
		check(_step(world, SimCommand.new(world.tick, 1, 0, 0, 0, 0, 1000)), "%d Hz Eclipse Disc flight steps" % tick_rate)
		saw_hit = saw_hit or world.combat_events.any(func(event: Dictionary) -> bool: return event.get("type") == "projectile_hit" and int(event.get("source_wire_id", 0)) == CombatTuning.ECLIPSE_DISC_WIRE_ID)
		if saw_hit:
			break
	check(saw_hit, "%d Hz Eclipse Disc hits authoritatively" % tick_rate)
	equal(enemy.health, enemy.health_maximum - CombatTuning.ECLIPSE_DISC_DAMAGE, "%d Hz Eclipse Disc damage is exact" % tick_rate)


func _test_s_wayne_disc_ricochet(tick_rate: int) -> void:
	var collision := CollisionWorld.new(800_000, 720_000)
	collision.add_obstacle(CollisionWorld.Obstacle.new(77, 300_000, 200_000, 340_000, 500_000))
	var owner := PlayerState.new(1)
	var projectile := ProjectileState.new(
		9004, owner.entity_id, owner.team_id,
		CombatTuning.ECLIPSE_DISC_WIRE_ID, CombatTuning.ECLIPSE_DISC_ELEMENT_WIRE_ID,
		Vector2i(250_000, 350_000), Vector2i(CombatTuning.ECLIPSE_DISC_SPEED, 0),
		CombatTuning.ECLIPSE_DISC_RADIUS, CombatTuning.ECLIPSE_DISC_DAMAGE,
		tick_rate, CombatTuning.NO_HIT_CONTROL_STATE, 0, 0, 1000,
		CombatTuning.ECLIPSE_DISC_BOUNCES,
	)
	var projectiles: Array[ProjectileState] = [projectile]
	var bounced: bool = false
	for _index: int in range(tick_rate):
		var events: Array[Dictionary] = []
		projectiles = CombatSystem.advance_projectiles(projectiles, [owner], SimConfig.new(tick_rate), collision, events)
		bounced = bounced or events.any(func(event: Dictionary) -> bool: return event.get("type") == "projectile_bounced" and int(event.get("wall_id", 0)) == 77)
		if bounced:
			break
	check(bounced, "%d Hz Eclipse Disc emits one authored ricochet" % tick_rate)
	equal(projectiles.size(), 1, "%d Hz Eclipse Disc survives its available ricochet" % tick_rate)
	if not projectiles.is_empty():
		check(projectiles[0].velocity_x < 0, "%d Hz Eclipse Disc reflects away from the wall" % tick_rate)
		equal(projectiles[0].remaining_bounces, 0, "%d Hz Eclipse Disc consumes its only ricochet" % tick_rate)


func _test_s_wayne_pocket_eclipse(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var caster: PlayerState = world.player()
	_apply_s_wayne(caster)
	var enemy: PlayerState = _add_enemy(world, Vector2i(420_000, 360_000))
	check(_step(world, SimCommand.new(0, 1, 0, 0, 0, SimCommand.PRESSED_ACTIVE_1, 1000)), "%d Hz Pocket Eclipse starts" % tick_rate)
	equal(caster.pending_cast_wire_id, CombatTuning.POCKET_ECLIPSE_WIRE_ID, "%d Hz S. Wayne active is Pocket Eclipse" % tick_rate)
	equal(caster.flux, caster.flux_maximum - CombatTuning.POCKET_ECLIPSE_FLUX_COST, "%d Hz Pocket Eclipse Flux spend is exact" % tick_rate)
	var saw_hit: bool = false
	for _index: int in range(tick_rate * 2):
		check(_step(world, SimCommand.new(world.tick, 1, 0, 0, 0, 0, 1000)), "%d Hz Pocket Eclipse flight steps" % tick_rate)
		saw_hit = saw_hit or world.combat_events.any(func(event: Dictionary) -> bool: return event.get("type") == "projectile_hit" and int(event.get("source_wire_id", 0)) == CombatTuning.POCKET_ECLIPSE_WIRE_ID)
		if saw_hit:
			break
	check(saw_hit, "%d Hz Pocket Eclipse hits authoritatively" % tick_rate)
	equal(enemy.health, enemy.health_maximum - CombatTuning.POCKET_ECLIPSE_DAMAGE, "%d Hz Pocket Eclipse damage is exact" % tick_rate)
	equal(enemy.control_state, PlayerState.ControlState.SLOWED, "%d Hz Pocket Eclipse applies bounded slow control" % tick_rate)
	equal(enemy.slow_ratio, CombatTuning.POCKET_ECLIPSE_SLOW_RATIO, "%d Hz Pocket Eclipse slow ratio is exact" % tick_rate)
	equal(enemy.control_ticks, world.config.milliseconds_to_ticks(CombatTuning.POCKET_ECLIPSE_SLOW_DURATION_MS), "%d Hz Pocket Eclipse slow duration is exact" % tick_rate)


func _test_edgeweave(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var runner: PlayerState = world.player()
	runner.position_x = 350_000
	runner.position_y = 100_000
	runner.velocity_x = 400_000
	runner.velocity_y = 0
	runner.stamina = 50_000
	var shooter: PlayerState = _add_enemy(world, Vector2i(180_000, 100_000))
	var hit_radius: int = runner.radius + CombatTuning.PRIMARY_RADIUS
	var projectile := ProjectileState.new(
		9001,
		shooter.entity_id,
		shooter.team_id,
		CombatTuning.PRIMARY_WIRE_ID,
		CombatTuning.PRIMARY_ELEMENT_WIRE_ID,
		Vector2i(runner.position_x - 30_000, runner.position_y + hit_radius + 8_000),
		Vector2i(2_000_000, 0),
		CombatTuning.PRIMARY_RADIUS,
		CombatTuning.PRIMARY_DAMAGE,
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
		CombatTuning.PRIMARY_ELEMENT_WIRE_ID,
		Vector2i(runner.position_x - 30_000, runner.position_y),
		Vector2i(2_000_000, 0),
		CombatTuning.PRIMARY_RADIUS,
		CombatTuning.PRIMARY_DAMAGE,
		tick_rate,
	)
	events = []
	CombatSystem.advance_projectiles([hit_projectile], world.players, world.config, world.collision, events)
	equal(runner.stamina, 50_000, "%d Hz inner hit volume never rewards Edgeweave" % tick_rate)
	equal(runner.health, PlayerTuning.HEALTH_MAXIMUM - CombatTuning.PRIMARY_DAMAGE, "%d Hz inner hit still applies damage" % tick_rate)

	runner.health = PlayerTuning.HEALTH_MAXIMUM
	runner.edgeweave_cooldown_ticks = 0
	runner.stamina = 50_000
	var training_projectile := ProjectileState.new(
		9003, shooter.entity_id, shooter.team_id, 9999, 0,
		Vector2i(runner.position_x - 30_000, runner.position_y + hit_radius + 8_000),
		Vector2i(2_000_000, 0), CombatTuning.PRIMARY_RADIUS, 0, tick_rate
	)
	CombatSystem.advance_projectiles([training_projectile], world.players, world.config, world.collision, [])
	equal(runner.stamina, 50_000, "%d Hz training pressure never rewards Edgeweave" % tick_rate)
