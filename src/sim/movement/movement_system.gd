class_name MovementSystem
extends RefCounted


static func step(state: PlayerState, command: SimCommand, config: SimConfig, world: CollisionWorld) -> void:
	_advance_timers(state, config)
	var direction: Vector2i = _direction(command.move_x, command.move_y, Vector2i(state.facing_x, state.facing_y))
	if command.move_x != 0 or command.move_y != 0:
		state.facing_x = direction.x
		state.facing_y = direction.y

	if command.has_pressed(SimCommand.PRESSED_JUMP):
		if state.vault_ticks > 0:
			_try_superglide(state, direction, config)
		elif state.slide_ticks > 0:
			_try_slide_jump(state, direction, config)
		elif state.hop_ticks > 0:
			_try_double_jump(state, direction, config)
		elif command.has_held(SimCommand.HELD_SPRINT):
			_try_slide(state, direction, config)
		else:
			_try_hop(state, direction, config)

	if command.has_pressed(SimCommand.PRESSED_TECHNIQUE):
		if state.is_airborne():
			if command.has_held(SimCommand.HELD_SPRINT):
				_try_air_dodge(state, direction, config)
			else:
				_try_air_redirect(state, direction, config)
		else:
			_try_vault(state, direction, config, world)

	_apply_velocity(state, command, direction, config)
	_integrate(state, config, world)
	_update_mode(state, command)


static func _advance_timers(state: PlayerState, config: SimConfig) -> void:
	var was_hopping: bool = state.hop_ticks > 0
	var was_air_dodging: bool = state.air_dodge_ticks > 0
	for property_name: StringName in [
		&"stamina_recovery_delay_ticks", &"hop_ticks", &"hop_cooldown_ticks",
		&"air_dodge_ticks", &"air_dodge_cooldown_ticks", &"wave_dash_ticks",
		&"slide_ticks", &"slide_cooldown_ticks", &"vault_ticks",
		&"vault_cooldown_ticks", &"superglide_ticks", &"wall_memory_ticks",
		&"landing_ticks",
	]:
		state.set(property_name, maxi(0, int(state.get(property_name)) - 1))
	if was_hopping and state.hop_ticks == 0:
		state.hop_stage = 0
		state.air_redirects_remaining = 0
		state.landing_ticks = config.milliseconds_to_ticks(MovementTuning.LANDING_WINDOW_MS)
		state.last_event = "land"
	if was_air_dodging and state.air_dodge_ticks == 0:
		if state.wave_dash_queued:
			state.wave_dash_ticks = config.milliseconds_to_ticks(MovementTuning.WAVE_DASH_DURATION_MS)
			state.wave_dash_x = state.air_dodge_x
			state.wave_dash_y = state.air_dodge_y
			state.last_event = "wave_dash"
		else:
			state.landing_ticks = config.milliseconds_to_ticks(MovementTuning.LANDING_WINDOW_MS)
		state.wave_dash_queued = false


static func _try_hop(state: PlayerState, direction: Vector2i, config: SimConfig) -> bool:
	if state.hop_cooldown_ticks > 0 or state.stamina < MovementTuning.HOP_COST:
		return false
	var wall_kick: bool = state.wall_memory_ticks > 0
	if wall_kick:
		direction = _wall_kick_direction(direction, Vector2i(state.wall_x, state.wall_y))
	_spend_stamina(state, MovementTuning.HOP_COST, config)
	state.hop_ticks = config.milliseconds_to_ticks(MovementTuning.HOP_DURATION_MS)
	state.hop_cooldown_ticks = config.milliseconds_to_ticks(MovementTuning.HOP_COOLDOWN_MS)
	state.hop_stage = 1
	state.hop_mode = PlayerState.MovementMode.WALL_KICK if wall_kick else PlayerState.MovementMode.HOP
	state.hop_speed = MovementTuning.WALL_KICK_SPEED if wall_kick else MovementTuning.HOP_SPEED
	state.hop_x = direction.x
	state.hop_y = direction.y
	state.air_redirects_remaining = 1
	state.wall_memory_ticks = 0
	state.sprinting = false
	state.last_event = "wall_kick" if wall_kick else "hop"
	return true


static func _try_double_jump(state: PlayerState, direction: Vector2i, config: SimConfig) -> bool:
	if state.hop_stage != 1 or state.stamina < MovementTuning.DOUBLE_JUMP_COST:
		return false
	_spend_stamina(state, MovementTuning.DOUBLE_JUMP_COST, config)
	state.hop_stage = 2
	state.hop_mode = PlayerState.MovementMode.DOUBLE_JUMP
	state.hop_ticks = config.milliseconds_to_ticks(MovementTuning.DOUBLE_JUMP_DURATION_MS)
	state.hop_speed = MovementTuning.DOUBLE_JUMP_SPEED
	state.hop_x = direction.x
	state.hop_y = direction.y
	state.air_redirects_remaining = 1
	state.last_event = "double_jump"
	return true


static func _try_air_redirect(state: PlayerState, direction: Vector2i, config: SimConfig) -> bool:
	if state.hop_ticks <= 0 or state.air_redirects_remaining <= 0 or state.stamina < MovementTuning.AIR_REDIRECT_COST:
		return false
	_spend_stamina(state, MovementTuning.AIR_REDIRECT_COST, config)
	state.hop_x = _blend_axis(state.hop_x, direction.x, MovementTuning.AIR_REDIRECT_BLEND)
	state.hop_y = _blend_axis(state.hop_y, direction.y, MovementTuning.AIR_REDIRECT_BLEND)
	var redirected: Vector2i = _direction(state.hop_x, state.hop_y, direction)
	state.hop_x = redirected.x
	state.hop_y = redirected.y
	state.air_redirects_remaining = 0
	state.last_event = "air_redirect"
	return true


static func _try_air_dodge(state: PlayerState, direction: Vector2i, config: SimConfig) -> bool:
	if state.hop_ticks <= 0 or state.air_dodge_cooldown_ticks > 0 or state.stamina < MovementTuning.AIR_DODGE_COST:
		return false
	var dot: int = state.hop_x * direction.x + state.hop_y * direction.y
	var turn: int = 1_000_000 - dot
	state.wave_dash_queued = (
		state.hop_ticks <= config.milliseconds_to_ticks(MovementTuning.WAVE_DASH_INPUT_WINDOW_MS)
		and turn >= MovementTuning.WAVE_DASH_MINIMUM_TURN
	)
	_spend_stamina(state, MovementTuning.AIR_DODGE_COST, config)
	state.hop_ticks = 0
	state.hop_stage = 0
	state.air_redirects_remaining = 0
	state.air_dodge_ticks = config.milliseconds_to_ticks(MovementTuning.AIR_DODGE_DURATION_MS)
	state.air_dodge_cooldown_ticks = config.milliseconds_to_ticks(MovementTuning.AIR_DODGE_COOLDOWN_MS)
	state.air_dodge_x = direction.x
	state.air_dodge_y = direction.y
	state.landing_ticks = 0
	state.last_event = "air_dodge"
	return true


static func _try_slide(state: PlayerState, direction: Vector2i, config: SimConfig) -> bool:
	if (
		state.slide_cooldown_ticks > 0 or state.slide_ticks > 0 or state.is_airborne()
		or state.wave_dash_ticks > 0 or state.vault_ticks > 0 or state.superglide_ticks > 0
		or state.stamina < MovementTuning.SLIDE_COST
		or _speed_squared(state.velocity_x, state.velocity_y) < MovementTuning.SLIDE_ENTRY_SPEED * MovementTuning.SLIDE_ENTRY_SPEED
	):
		return false
	_spend_stamina(state, MovementTuning.SLIDE_COST, config)
	state.slide_ticks = config.milliseconds_to_ticks(MovementTuning.SLIDE_DURATION_MS)
	state.slide_cooldown_ticks = config.milliseconds_to_ticks(MovementTuning.SLIDE_COOLDOWN_MS)
	state.slide_x = direction.x
	state.slide_y = direction.y
	state.sprinting = false
	state.last_event = "slide"
	return true


static func _try_slide_jump(state: PlayerState, direction: Vector2i, config: SimConfig) -> bool:
	if state.slide_ticks > config.milliseconds_to_ticks(MovementTuning.SLIDE_JUMP_WINDOW_MS) or state.stamina < MovementTuning.SLIDE_JUMP_COST:
		return false
	_spend_stamina(state, MovementTuning.SLIDE_JUMP_COST, config)
	state.slide_ticks = 0
	state.hop_ticks = config.milliseconds_to_ticks(MovementTuning.SLIDE_JUMP_DURATION_MS)
	state.hop_stage = 1
	state.hop_mode = PlayerState.MovementMode.SLIDE_JUMP
	state.hop_speed = MovementTuning.SLIDE_JUMP_SPEED
	state.hop_x = direction.x
	state.hop_y = direction.y
	state.air_redirects_remaining = 1
	state.last_event = "slide_jump"
	return true


static func _try_vault(state: PlayerState, direction: Vector2i, config: SimConfig, world: CollisionWorld) -> bool:
	if state.vault_cooldown_ticks > 0 or state.stamina < MovementTuning.VAULT_COST:
		return false
	var obstacle: CollisionWorld.Obstacle = world.find_vault_candidate(Vector2i(state.position_x, state.position_y), direction, state.radius)
	if obstacle == null:
		state.last_event = "vault_miss"
		return false
	var destination: Vector2i = world.vault_destination(Vector2i(state.position_x, state.position_y), direction, state.radius, obstacle)
	if destination == Vector2i(state.position_x, state.position_y):
		state.last_event = "vault_blocked"
		return false
	_spend_stamina(state, MovementTuning.VAULT_COST, config)
	state.position_x = destination.x
	state.position_y = destination.y
	state.position_remainder_x = 0
	state.position_remainder_y = 0
	state.velocity_x = 0
	state.velocity_y = 0
	state.vault_ticks = config.milliseconds_to_ticks(MovementTuning.VAULT_DURATION_MS)
	state.vault_cooldown_ticks = config.milliseconds_to_ticks(MovementTuning.VAULT_COOLDOWN_MS)
	state.vault_x = direction.x
	state.vault_y = direction.y
	state.last_event = "vault"
	return true


static func _try_superglide(state: PlayerState, direction: Vector2i, config: SimConfig) -> bool:
	var crest_start: int = config.milliseconds_to_ticks(MovementTuning.VAULT_CREST_START_MS)
	var crest_end: int = config.milliseconds_to_ticks(MovementTuning.VAULT_CREST_END_MS)
	if state.vault_ticks < crest_start or state.vault_ticks > crest_end or state.stamina < MovementTuning.SUPERGLIDE_COST:
		return false
	_spend_stamina(state, MovementTuning.SUPERGLIDE_COST, config)
	state.vault_ticks = 0
	state.superglide_ticks = config.milliseconds_to_ticks(MovementTuning.SUPERGLIDE_DURATION_MS)
	state.superglide_x = direction.x
	state.superglide_y = direction.y
	state.last_event = "superglide"
	return true


static func _apply_velocity(state: PlayerState, command: SimCommand, direction: Vector2i, config: SimConfig) -> void:
	if state.superglide_ticks > 0:
		_set_directional_velocity(state, Vector2i(state.superglide_x, state.superglide_y), MovementTuning.SUPERGLIDE_SPEED)
	elif state.air_dodge_ticks > 0:
		_set_directional_velocity(state, Vector2i(state.air_dodge_x, state.air_dodge_y), MovementTuning.AIR_DODGE_SPEED)
	elif state.wave_dash_ticks > 0:
		var steered := _steer(Vector2i(state.wave_dash_x, state.wave_dash_y), direction, command, MovementTuning.WAVE_DASH_STEERING)
		state.wave_dash_x = steered.x
		state.wave_dash_y = steered.y
		_set_directional_velocity(state, steered, MovementTuning.WAVE_DASH_SPEED)
	elif state.vault_ticks > 0:
		state.velocity_x = 0
		state.velocity_y = 0
	elif state.slide_ticks > 0:
		var slide_direction := _steer(Vector2i(state.slide_x, state.slide_y), direction, command, MovementTuning.SLIDE_STEERING)
		state.slide_x = slide_direction.x
		state.slide_y = slide_direction.y
		_set_directional_velocity(state, slide_direction, MovementTuning.SLIDE_SPEED)
	elif state.hop_ticks > 0:
		_set_directional_velocity(state, Vector2i(state.hop_x, state.hop_y), state.hop_speed)
	else:
		_apply_ground_velocity(state, command, direction, config)


static func _apply_ground_velocity(state: PlayerState, command: SimCommand, direction: Vector2i, config: SimConfig) -> void:
	var moving: bool = command.move_x != 0 or command.move_y != 0
	var sprinting: bool = moving and command.has_held(SimCommand.HELD_SPRINT) and state.stamina > 0
	var speed: int = MovementTuning.BASE_SPEED
	if sprinting:
		@warning_ignore("integer_division")
		speed = speed * MovementTuning.SPRINT_MULTIPLIER / 1000
	var desired_x: int = direction.x * speed / 1000 if moving else 0
	var desired_y: int = direction.y * speed / 1000 if moving else 0
	var opposing: bool = moving and state.velocity_x * direction.x + state.velocity_y * direction.y < -198_000_000
	var rate: int = MovementTuning.ACCELERATION if moving else MovementTuning.DECELERATION
	if opposing:
		@warning_ignore("integer_division")
		rate = rate * MovementTuning.COUNTER_STRAFE_MULTIPLIER / 1000
		if state.landing_ticks > 0:
			@warning_ignore("integer_division")
			rate = rate * MovementTuning.LANDING_CUT_MULTIPLIER / 1000
			state.landing_ticks = 0
			state.last_event = "landing_cut"
	var step_amount: int = config.per_tick(rate)
	state.velocity_x = _approach(state.velocity_x, desired_x, step_amount)
	state.velocity_y = _approach(state.velocity_y, desired_y, step_amount)
	state.sprinting = sprinting
	if sprinting:
		_apply_stamina_rate(state, -MovementTuning.SPRINT_DRAIN_PER_SECOND, config)
		state.stamina_recovery_delay_ticks = config.milliseconds_to_ticks(MovementTuning.STAMINA_RECOVERY_DELAY_MS)
	elif state.stamina_recovery_delay_ticks == 0:
		_apply_stamina_rate(state, MovementTuning.STAMINA_RECOVERY_PER_SECOND, config)


static func _integrate(state: PlayerState, config: SimConfig, world: CollisionWorld) -> void:
	var total_x: int = state.position_remainder_x + state.velocity_x
	var total_y: int = state.position_remainder_y + state.velocity_y
	@warning_ignore("integer_division")
	var delta := Vector2i(total_x / config.tick_rate, total_y / config.tick_rate)
	state.position_remainder_x = total_x - delta.x * config.tick_rate
	state.position_remainder_y = total_y - delta.y * config.tick_rate
	var result: CollisionWorld.MoveResult = world.move_box(Vector2i(state.position_x, state.position_y), delta, state.radius)
	state.position_x = result.position.x
	state.position_y = result.position.y
	if result.wall_normal != Vector2i.ZERO:
		state.wall_memory_ticks = config.milliseconds_to_ticks(MovementTuning.WALL_MEMORY_MS)
		state.wall_x = result.wall_normal.x
		state.wall_y = result.wall_normal.y
		state.position_remainder_x = 0 if result.wall_normal.x != 0 else state.position_remainder_x
		state.position_remainder_y = 0 if result.wall_normal.y != 0 else state.position_remainder_y
		if result.wall_normal.x != 0:
			state.velocity_x = 0
		if result.wall_normal.y != 0:
			state.velocity_y = 0
		if state.air_dodge_ticks > 0 or state.wave_dash_ticks > 0 or state.slide_ticks > 0 or state.superglide_ticks > 0:
			state.air_dodge_ticks = 0
			state.wave_dash_ticks = 0
			state.wave_dash_queued = false
			state.slide_ticks = 0
			state.superglide_ticks = 0
			state.last_event = "movement_impact"


static func _update_mode(state: PlayerState, command: SimCommand) -> void:
	if state.superglide_ticks > 0:
		state.movement_mode = PlayerState.MovementMode.SUPERGLIDE
	elif state.air_dodge_ticks > 0:
		state.movement_mode = PlayerState.MovementMode.AIR_DODGE
	elif state.wave_dash_ticks > 0:
		state.movement_mode = PlayerState.MovementMode.WAVE_DASH
	elif state.vault_ticks > 0:
		state.movement_mode = PlayerState.MovementMode.VAULT
	elif state.slide_ticks > 0:
		state.movement_mode = PlayerState.MovementMode.SLIDE
	elif state.hop_ticks > 0:
		state.movement_mode = state.hop_mode
	elif state.sprinting:
		state.movement_mode = PlayerState.MovementMode.SPRINT
	elif command.move_x != 0 or command.move_y != 0:
		state.movement_mode = PlayerState.MovementMode.WALK
	else:
		state.movement_mode = PlayerState.MovementMode.IDLE


static func _spend_stamina(state: PlayerState, amount: int, config: SimConfig) -> void:
	state.stamina = maxi(0, state.stamina - amount)
	state.stamina_remainder = 0
	state.stamina_recovery_delay_ticks = config.milliseconds_to_ticks(MovementTuning.STAMINA_RECOVERY_DELAY_MS)


static func _apply_stamina_rate(state: PlayerState, rate_per_second: int, config: SimConfig) -> void:
	var total: int = state.stamina_remainder + rate_per_second
	@warning_ignore("integer_division")
	var amount: int = total / config.tick_rate
	state.stamina_remainder = total - amount * config.tick_rate
	state.stamina = clampi(state.stamina + amount, 0, MovementTuning.STAMINA_MAXIMUM)


static func _direction(input_x: int, input_y: int, fallback: Vector2i) -> Vector2i:
	var x: int = signi(input_x)
	var y: int = signi(input_y)
	if x == 0 and y == 0:
		return fallback if fallback != Vector2i.ZERO else Vector2i(1000, 0)
	if x != 0 and y != 0:
		return Vector2i(x * 707, y * 707)
	return Vector2i(x * 1000, y * 1000)


static func _wall_kick_direction(requested: Vector2i, wall_normal: Vector2i) -> Vector2i:
	var dot: int = requested.x * wall_normal.x + requested.y * wall_normal.y
	@warning_ignore("integer_division")
	var tangent := requested - Vector2i(wall_normal.x * dot / 1_000_000, wall_normal.y * dot / 1_000_000)
	return _direction(wall_normal.x + tangent.x * 72 / 100, wall_normal.y + tangent.y * 72 / 100, wall_normal)


static func _steer(current: Vector2i, requested: Vector2i, command: SimCommand, ratio: int) -> Vector2i:
	if command.move_x == 0 and command.move_y == 0:
		return current
	return _direction(_blend_axis(current.x, requested.x, ratio), _blend_axis(current.y, requested.y, ratio), current)


static func _blend_axis(current: int, requested: int, ratio: int) -> int:
	@warning_ignore("integer_division")
	return (current * (1000 - ratio) + requested * ratio) / 1000


static func _set_directional_velocity(state: PlayerState, direction: Vector2i, speed: int) -> void:
	@warning_ignore("integer_division")
	state.velocity_x = direction.x * speed / 1000
	@warning_ignore("integer_division")
	state.velocity_y = direction.y * speed / 1000
	state.sprinting = false


static func _approach(current: int, target: int, amount: int) -> int:
	return mini(current + amount, target) if current < target else maxi(current - amount, target)


static func _speed_squared(x: int, y: int) -> int:
	return x * x + y * y
