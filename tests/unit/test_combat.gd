extends FluxTestSuite


func run() -> int:
	for tick_rate: int in [60, 120]:
		_test_resource_free_primary(tick_rate)
		_test_vector_lance_flux_and_hit(tick_rate)
		_test_oh_tipi_rillshot(tick_rate)
		_test_oh_tipi_tideline(tick_rate)
		_test_edgeweave(tick_rate)
	return finish("combat")


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
