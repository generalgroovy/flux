extends FluxTestSuite


func run() -> int:
	for tick_rate: int in [60, 120]:
		_test_separate_resources(tick_rate)
		_test_health_recovery_delay(tick_rate)
		_test_flux_spend_and_recovery(tick_rate)
	return finish("player-resources")


func _step_empty(world: SimWorld, ticks: int) -> void:
	var all_steps_succeeded: bool = true
	for _index: int in range(ticks):
		all_steps_succeeded = world.step([SimCommand.new(world.tick, 1)]) and all_steps_succeeded
	check(all_steps_succeeded, "%d empty resource ticks step" % ticks)


func _test_separate_resources(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var state: PlayerState = world.player()
	var initial_flux: int = state.flux
	var initial_health: int = state.health
	var all_steps_succeeded: bool = true
	for _index: int in range(tick_rate / 2):
		all_steps_succeeded = world.step([SimCommand.new(world.tick, 1, 1000, 0, SimCommand.HELD_SPRINT)]) and all_steps_succeeded
	check(all_steps_succeeded, "%d Hz sprint resource ticks step" % tick_rate)
	check(state.stamina < state.stamina_maximum, "%d Hz movement spends Stamina" % tick_rate)
	equal(state.flux, initial_flux, "%d Hz movement never spends Flux" % tick_rate)
	equal(state.health, initial_health, "%d Hz movement never spends Health" % tick_rate)


func _test_health_recovery_delay(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var state: PlayerState = world.player()
	check(PlayerResourcesSystem.damage(state, 10_000, world.config), "%d Hz damage applies" % tick_rate)
	equal(state.health, 90_000, "%d Hz damage is exact" % tick_rate)
	var recovery_delay: int = world.config.milliseconds_to_ticks(PlayerTuning.HEALTH_RECOVERY_DELAY_MS)
	_step_empty(world, recovery_delay - 1)
	equal(state.health, 90_000, "%d Hz Health does not recover during delay" % tick_rate)
	_step_empty(world, tick_rate)
	check(state.health > 90_000, "%d Hz Health recovers after 5.5 second delay" % tick_rate)
	check(state.health <= state.health_maximum, "%d Hz Health recovery is bounded" % tick_rate)


func _test_flux_spend_and_recovery(tick_rate: int) -> void:
	var world := SimWorld.new(tick_rate)
	var state: PlayerState = world.player()
	check(PlayerResourcesSystem.spend_flux(state, 25_000, world.config), "%d Hz legal Flux spend succeeds" % tick_rate)
	equal(state.flux, 75_000, "%d Hz Flux cost is exact" % tick_rate)
	check(not PlayerResourcesSystem.spend_flux(state, 80_000, world.config), "%d Hz unaffordable Flux spend fails" % tick_rate)
	var recovery_delay: int = world.config.milliseconds_to_ticks(PlayerTuning.FLUX_RECOVERY_DELAY_MS)
	_step_empty(world, recovery_delay - 1)
	equal(state.flux, 75_000, "%d Hz Flux does not recover during delay" % tick_rate)
	_step_empty(world, tick_rate)
	check(state.flux > 75_000, "%d Hz Flux recovers after its delay" % tick_rate)
	check(state.flux <= state.flux_maximum, "%d Hz Flux recovery is bounded" % tick_rate)
