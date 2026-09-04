class_name MovementSystem
extends RefCounted


static func step(state: PlayerState, command: SimCommand, config: SimConfig, world: CollisionWorld) -> void:
	_advance_timers(state, config)
	var direction: Vector2i = _direction(command.move_x, command.move_y, Vector2i(state.facing_x, state.facing_y))
	if command.move_x != 0 or command.move_y != 0:
		state.facing_x = direction.x
		state.facing_y = direction.y
	_capture_action_buffers(state, command, config)
	_update_wall_attachment(state, command, world, config)
	if state.is_airborne() and (command.move_x != 0 or command.move_y != 0):
		state.landing_input_x = direction.x
		state.landing_input_y = direction.y
		state.landing_input_ticks = config.milliseconds_to_ticks(MovementTuning.LANDING_INPUT_BUFFER_MS)

	var impact_tech_started := false
	if state.impact_recovery_ticks > 0:
		impact_tech_started = _try_impact_recovery_tech(state, direction, config)
	var control_locked: bool = state.impact_recovery_ticks > 0 or state.control_state in [
		PlayerState.ControlState.LAUNCHED,
		PlayerState.ControlState.GRAPPLED,
		PlayerState.ControlState.CHARGING,
		PlayerState.ControlState.STUNNED,
		PlayerState.ControlState.ROOTED,
	]
	if not control_locked:
		_consume_evade_buffer(state, direction, config)
		_consume_slide_buffer(state, direction, config)
		_consume_jump_buffer(state, command, direction, config)
		_consume_technique_buffer(state, command, direction, config, world)
	_apply_variable_air_time(state, command, config)

	if impact_tech_started:
		pass # The technique owns this tick's velocity; ordinary control resumes next tick.
	elif state.impact_recovery_ticks > 0:
		_apply_impact_recovery_velocity(state, config)
	elif control_locked:
		if state.control_state == PlayerState.ControlState.LAUNCHED:
			_apply_launch_influence(state, command, direction, config)
		_apply_control_velocity(state, config)
	else:
		var movement_command := command
		if state.last_event == "land" and command.move_x == 0 and command.move_y == 0 and state.landing_input_ticks > 0:
			movement_command = command.copy()
			movement_command.move_x = state.landing_input_x
			movement_command.move_y = state.landing_input_y
			direction = Vector2i(state.landing_input_x, state.landing_input_y)
			state.landing_input_ticks = 0
		_apply_velocity(state, movement_command, direction, config)
		if state.control_state == PlayerState.ControlState.SLOWED:
			@warning_ignore("integer_division")
			state.velocity_x = state.velocity_x * state.slow_ratio / 1000
			@warning_ignore("integer_division")
			state.velocity_y = state.velocity_y * state.slow_ratio / 1000
	_integrate(state, config, world)
	_update_wall_attachment(state, command, world, config)
	_update_mode(state, command)


static func _capture_action_buffers(state: PlayerState, command: SimCommand, config: SimConfig) -> void:
	var buffer_ticks: int = config.milliseconds_to_ticks(MovementTuning.INPUT_BUFFER_MS)
	if command.has_pressed(SimCommand.PRESSED_EVADE):
		state.evade_buffer_ticks = buffer_ticks
	if command.has_pressed(SimCommand.PRESSED_JUMP):
		state.jump_buffer_ticks = buffer_ticks
	if command.has_pressed(SimCommand.PRESSED_TECHNIQUE):
		state.technique_buffer_ticks = buffer_ticks
	if command.has_pressed(SimCommand.PRESSED_SLIDE):
		state.slide_buffer_ticks = buffer_ticks


static func _consume_slide_buffer(state: PlayerState, direction: Vector2i, config: SimConfig) -> void:
	if state.slide_buffer_ticks > 0 and state.slide_ticks > 0:
		state.slide_ticks = 0
		state.slide_buffer_ticks = 0
		state.velocity_x = 0
		state.velocity_y = 0
		state.last_event = "slide_brake"
		return
	if state.slide_buffer_ticks > 0 and not state.is_airborne() and _try_slide(state, direction, config):
		state.slide_buffer_ticks = 0


static func _consume_jump_buffer(state: PlayerState, _command: SimCommand, direction: Vector2i, config: SimConfig) -> void:
	if state.jump_buffer_ticks <= 0:
		return
	var consumed := false
	if state.slide_ticks > 0:
		consumed = _try_slide_jump(state, direction, config)
	elif state.hop_ticks > 0:
		var outward := direction.x * state.wall_x + direction.y * state.wall_y > 0
		if state.wall_memory_ticks > 0 and state.wall_contact_id > 0 and outward and state.hop_stage == 1:
			consumed = _try_air_wall_kick(state, direction, config)
		else:
			consumed = _try_double_jump(state, direction, config)
	elif state.air_dodge_ticks <= 0:
		consumed = _try_hop(state, direction, config)
	if consumed:
		state.jump_buffer_ticks = 0


static func _consume_evade_buffer(state: PlayerState, direction: Vector2i, config: SimConfig) -> void:
	if state.evade_buffer_ticks <= 0:
		return
	var consumed := _try_air_dodge(state, direction, config) if state.is_airborne() else _try_roll(state, direction, config)
	if consumed:
		state.evade_buffer_ticks = 0


static func _consume_technique_buffer(state: PlayerState, _command: SimCommand, direction: Vector2i, config: SimConfig, world: CollisionWorld) -> void:
	if state.technique_buffer_ticks <= 0:
		return
	var consumed := false
	if state.wall_skim_ticks > 0:
		_end_wall_run(state, "wall_detach", config)
		consumed = true
	elif state.is_airborne():
		consumed = _try_air_redirect(state, direction, config)
	elif _has_wall_contact(state, world, state.wall_contact_id):
		consumed = _try_wall_skim(state, direction, config)
	if consumed:
		state.technique_buffer_ticks = 0
		if state.is_airborne():
			state.variable_jump_grace_ticks = 1


static func _apply_variable_air_time(state: PlayerState, command: SimCommand, config: SimConfig) -> void:
	if state.hop_ticks <= 0:
		state.fast_falling = false
		return
	if command.has_held(SimCommand.HELD_FAST_FALL):
		state.hop_ticks = maxi(1, state.hop_ticks - MovementTuning.FAST_FALL_EXTRA_TICKS)
		if not state.fast_falling:
			state.last_event = "fast_fall"
		state.fast_falling = true
		return
	state.fast_falling = false
	if state.variable_jump_grace_ticks > 0:
		return
	var jump_is_held: bool = command.has_held(SimCommand.HELD_JUMP) or command.has_pressed(SimCommand.PRESSED_JUMP)
	var minimum_ticks: int = config.milliseconds_to_ticks(MovementTuning.VARIABLE_JUMP_MINIMUM_MS)
	if not jump_is_held and state.hop_ticks > minimum_ticks:
		state.hop_ticks = minimum_ticks
		state.last_event = "jump_cut"


static func apply_control_state(
	state: PlayerState,
	requested_state: int,
	duration_ms: int,
	direction: Vector2i,
	speed: int,
	config: SimConfig,
	slow_ratio: int = 1000,
) -> bool:
	if requested_state < PlayerState.ControlState.FREE or requested_state > PlayerState.ControlState.SLOWED:
		return false
	if requested_state == PlayerState.ControlState.FREE:
		state.control_state = PlayerState.ControlState.FREE
		state.control_ticks = 0
		state.control_speed = 0
		state.slow_ratio = 1000
		state.impact_recovery_ticks = 0
		return true
	if duration_ms <= 0:
		return false
	var normalized := _direction(direction.x, direction.y, Vector2i(state.facing_x, state.facing_y))
	state.control_state = requested_state
	state.control_ticks = config.milliseconds_to_ticks(duration_ms)
	state.control_x = normalized.x
	state.control_y = normalized.y
	state.control_speed = clampi(speed, 0, MovementTuning.MAX_AUTHORED_SPEED)
	state.slow_ratio = clampi(slow_ratio, MovementTuning.SLOW_MINIMUM_RATIO, MovementTuning.SLOW_MAXIMUM_RATIO)
	state.impact_recovery_ticks = 0
	if requested_state == PlayerState.ControlState.LAUNCHED:
		_cancel_authored_movement(state)
	state.last_event = "control_%d" % requested_state
	return true


static func _advance_timers(state: PlayerState, config: SimConfig) -> void:
	var was_hopping: bool = state.hop_ticks > 0
	var was_fast_falling: bool = state.fast_falling
	var was_air_dodging: bool = state.air_dodge_ticks > 0
	var was_rolling: bool = state.is_rolling()
	var was_wall_skimming: bool = state.wall_skim_ticks > 0
	var was_landing: bool = state.landing_ticks > 0
	var was_impact_recovering: bool = state.impact_recovery_ticks > 0
	var previous_control_state: int = state.control_state
	for property_name: StringName in [
		&"stamina_recovery_delay_ticks", &"hop_ticks", &"hop_cooldown_ticks",
		&"air_dodge_ticks", &"air_dodge_cooldown_ticks", &"wave_dash_ticks",
		&"slide_ticks", &"slide_cooldown_ticks", &"vault_ticks",
		&"vault_cooldown_ticks", &"superglide_ticks", &"wall_memory_ticks",
		&"wall_skim_ticks", &"wall_skim_cooldown_ticks", &"wall_skim_lockout_ticks",
		&"landing_ticks", &"impact_recovery_ticks", &"wall_lockout_ticks", &"control_ticks",
		&"jump_buffer_ticks", &"technique_buffer_ticks", &"slide_buffer_ticks",
		&"variable_jump_grace_ticks", &"jump_protection_ticks", &"evade_buffer_ticks", &"landing_input_ticks",
	]:
		state.set(property_name, maxi(0, int(state.get(property_name)) - 1))
	if was_landing and state.landing_ticks == 0:
		state.landing_intensity = 0
	if was_impact_recovering and state.impact_recovery_ticks == 0:
		state.technique_buffer_ticks = 0
		state.last_event = "impact_recovery_end"
	if was_hopping and state.hop_ticks == 0:
		state.landing_intensity = _hop_landing_intensity(state.hop_mode, was_fast_falling)
		state.hop_stage = 0
		state.jump_protection_ticks = 0
		state.air_redirects_remaining = 0
		state.fast_falling = false
		state.landing_ticks = config.milliseconds_to_ticks(MovementTuning.LANDING_WINDOW_MS)
		state.last_event = "land"
	if was_air_dodging and state.air_dodge_ticks == 0:
		if was_rolling:
			state.landing_ticks = config.milliseconds_to_ticks(MovementTuning.LANDING_WINDOW_MS)
			state.landing_intensity = MovementTuning.LANDING_WALL_SKIM_INTENSITY
			state.last_event = "roll_end"
		elif state.wave_dash_queued:
			state.wave_dash_ticks = config.milliseconds_to_ticks(MovementTuning.WAVE_DASH_DURATION_MS)
			state.wave_dash_x = state.air_dodge_x
			state.wave_dash_y = state.air_dodge_y
			state.last_event = "wave_dash"
		else:
			state.landing_ticks = config.milliseconds_to_ticks(MovementTuning.LANDING_WINDOW_MS)
			state.landing_intensity = MovementTuning.LANDING_AIR_DODGE_INTENSITY
		state.wave_dash_queued = false
	if was_wall_skimming and state.wall_skim_ticks == 0:
		state.wall_skim_surface_id = 0
		state.landing_ticks = config.milliseconds_to_ticks(MovementTuning.LANDING_WINDOW_MS)
		state.landing_intensity = MovementTuning.LANDING_WALL_SKIM_INTENSITY
		state.last_event = "wall_skim_end"
	if previous_control_state == PlayerState.ControlState.LAUNCHED and state.control_ticks == 0:
		_begin_impact_recovery(state, config)
	elif previous_control_state != PlayerState.ControlState.FREE and state.control_ticks == 0:
		state.control_state = PlayerState.ControlState.FREE
		state.control_speed = 0
		state.slow_ratio = 1000
		state.last_event = "control_end"


static func _apply_launch_influence(state: PlayerState, command: SimCommand, direction: Vector2i, config: SimConfig) -> void:
	if command.move_x == 0 and command.move_y == 0:
		return
	var influence_step: int = config.per_tick(MovementTuning.IMPACT_INFLUENCE_PER_SECOND)
	var influenced := _normalized_fixed(
		_approach(state.control_x, direction.x, influence_step),
		_approach(state.control_y, direction.y, influence_step),
		Vector2i(state.control_x, state.control_y),
	)
	state.control_x = influenced.x
	state.control_y = influenced.y


static func _begin_impact_recovery(state: PlayerState, config: SimConfig) -> void:
	state.control_state = PlayerState.ControlState.FREE
	state.control_ticks = 0
	state.control_speed = 0
	state.slow_ratio = 1000
	state.impact_recovery_ticks = config.milliseconds_to_ticks(MovementTuning.IMPACT_RECOVERY_DURATION_MS)
	@warning_ignore("integer_division")
	state.velocity_x = state.velocity_x * MovementTuning.IMPACT_RECOVERY_SPEED_RETENTION / 1000
	@warning_ignore("integer_division")
	state.velocity_y = state.velocity_y * MovementTuning.IMPACT_RECOVERY_SPEED_RETENTION / 1000
	state.landing_ticks = config.milliseconds_to_ticks(MovementTuning.LANDING_WINDOW_MS)
	state.landing_intensity = MovementTuning.IMPACT_RECOVERY_INTENSITY
	state.sprinting = false
	state.last_event = "impact_recovery"


static func _try_impact_recovery_tech(state: PlayerState, direction: Vector2i, config: SimConfig) -> bool:
	if state.technique_buffer_ticks <= 0 or state.stamina < MovementTuning.IMPACT_RECOVERY_TECH_COST:
		return false
	_spend_stamina(state, MovementTuning.IMPACT_RECOVERY_TECH_COST, config)
	state.impact_recovery_ticks = 0
	state.technique_buffer_ticks = 0
	_set_directional_velocity(state, direction, MovementTuning.IMPACT_RECOVERY_TECH_SPEED)
	_clear_landing_cue(state)
	state.last_event = "impact_tech"
	return true


static func _apply_impact_recovery_velocity(state: PlayerState, config: SimConfig) -> void:
	var braking: int = config.per_tick(MovementTuning.IMPACT_RECOVERY_DECELERATION)
	state.velocity_x = _approach(state.velocity_x, 0, braking)
	state.velocity_y = _approach(state.velocity_y, 0, braking)
	state.sprinting = false


static func _cancel_authored_movement(state: PlayerState) -> void:
	state.hop_ticks = 0
	state.hop_stage = 0
	state.hop_mode = PlayerState.MovementMode.AIR_DODGE
	state.air_redirects_remaining = 0
	state.fast_falling = false
	state.air_dodge_ticks = 0
	state.wave_dash_queued = false
	state.wave_dash_ticks = 0
	state.slide_ticks = 0
	state.vault_ticks = 0
	state.superglide_ticks = 0
	state.wall_skim_ticks = 0
	state.wall_skim_surface_id = 0
	_clear_landing_cue(state)


static func _try_hop(state: PlayerState, direction: Vector2i, config: SimConfig) -> bool:
	if state.hop_cooldown_ticks > 0 or state.stamina < MovementTuning.HOP_COST:
		return false
	var wall_kick: bool = state.wall_memory_ticks > 0
	if wall_kick:
		direction = _wall_kick_direction(direction, Vector2i(state.wall_x, state.wall_y))
	_spend_stamina(state, MovementTuning.HOP_COST, config)
	state.hop_ticks = config.milliseconds_to_ticks(MovementTuning.HOP_DURATION_MS)
	state.jump_protection_ticks = config.milliseconds_to_ticks(MovementTuning.JUMP_INVULNERABILITY_MS)
	state.wall_skim_ticks = 0
	state.wall_skim_surface_id = 0
	state.variable_jump_grace_ticks = 1
	state.hop_cooldown_ticks = config.milliseconds_to_ticks(MovementTuning.HOP_COOLDOWN_MS)
	state.hop_stage = 1
	state.hop_mode = PlayerState.MovementMode.WALL_KICK if wall_kick else PlayerState.MovementMode.HOP
	state.hop_speed = MovementTuning.WALL_KICK_SPEED if wall_kick else MovementTuning.HOP_SPEED
	state.hop_x = direction.x
	state.hop_y = direction.y
	state.air_redirects_remaining = 1
	_clear_landing_cue(state)
	state.wall_memory_ticks = 0
	if wall_kick:
		state.wall_lockout_id = state.wall_contact_id
		state.wall_lockout_ticks = config.milliseconds_to_ticks(MovementTuning.SAME_WALL_LOCKOUT_MS)
	state.wall_contact_id = 0
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
	state.jump_protection_ticks = config.milliseconds_to_ticks(MovementTuning.JUMP_INVULNERABILITY_MS)
	state.variable_jump_grace_ticks = 1
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
	_clear_landing_cue(state)
	state.last_event = "air_dodge"
	return true


static func _try_roll(state: PlayerState, direction: Vector2i, config: SimConfig) -> bool:
	if (
		state.air_dodge_cooldown_ticks > 0 or state.air_dodge_ticks > 0
		or state.slide_ticks > 0 or state.wave_dash_ticks > 0
		or state.vault_ticks > 0 or state.superglide_ticks > 0
		or state.stamina < MovementTuning.ROLL_COST
	):
		return false
	_spend_stamina(state, MovementTuning.ROLL_COST, config)
	state.wall_skim_ticks = 0
	state.wall_skim_surface_id = 0
	state.hop_mode = PlayerState.MovementMode.ROLL
	state.air_dodge_ticks = config.milliseconds_to_ticks(MovementTuning.ROLL_DURATION_MS)
	state.air_dodge_cooldown_ticks = config.milliseconds_to_ticks(MovementTuning.ROLL_COOLDOWN_MS)
	state.air_dodge_x = direction.x
	state.air_dodge_y = direction.y
	state.wave_dash_queued = false
	state.sprinting = false
	_clear_landing_cue(state)
	state.last_event = "roll"
	return true


static func is_combat_intangible(state: PlayerState, config: SimConfig) -> bool:
	if state == null or config == null:
		return false
	if state.hop_ticks > 0:
		return state.jump_protection_ticks > 0
	if state.slide_ticks > 0:
		return _timer_is_in_opening_window(state.slide_ticks,
			config.milliseconds_to_ticks(MovementTuning.SLIDE_DURATION_MS),
			config.milliseconds_to_ticks(MovementTuning.SLIDE_INVULNERABILITY_MS))
	if state.air_dodge_ticks > 0:
		var action_duration_ms := MovementTuning.ROLL_DURATION_MS if state.is_rolling() else MovementTuning.AIR_DODGE_DURATION_MS
		var invulnerability_ms := MovementTuning.ROLL_INVULNERABILITY_MS if state.is_rolling() else MovementTuning.AIR_DODGE_INVULNERABILITY_MS
		return _timer_is_in_opening_window(
			state.air_dodge_ticks,
			config.milliseconds_to_ticks(action_duration_ms),
			config.milliseconds_to_ticks(invulnerability_ms),
		)
	return false


static func _timer_is_in_opening_window(remaining_ticks: int, total_ticks: int, window_ticks: int) -> bool:
	return remaining_ticks > 0 and total_ticks > 0 and total_ticks - remaining_ticks < window_ticks


static func _try_slide(state: PlayerState, direction: Vector2i, config: SimConfig) -> bool:
	if (
		state.slide_cooldown_ticks > 0 or state.slide_ticks > 0 or state.is_airborne()
		or state.air_dodge_ticks > 0
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
	state.jump_protection_ticks = config.milliseconds_to_ticks(MovementTuning.JUMP_INVULNERABILITY_MS)
	state.variable_jump_grace_ticks = 1
	state.hop_stage = 1
	state.hop_mode = PlayerState.MovementMode.SLIDE_JUMP
	state.hop_speed = MovementTuning.SLIDE_JUMP_SPEED
	state.hop_x = direction.x
	state.hop_y = direction.y
	state.air_redirects_remaining = 1
	_clear_landing_cue(state)
	state.last_event = "slide_jump"
	return true


# Vault/superglide wire IDs and state slots remain reserved; no action activates them.
static func _try_wall_skim(state: PlayerState, direction: Vector2i, config: SimConfig) -> bool:
	if (
		state.wall_memory_ticks <= 0 or state.wall_contact_id <= 0
		or state.air_dodge_ticks > 0 or state.hop_ticks > 0
		or state.wall_skim_ticks > 0 or state.wall_skim_cooldown_ticks > 0
		or (state.wall_skim_lockout_id == state.wall_contact_id and state.wall_skim_lockout_ticks > 0)
		or state.slide_ticks > 0 or state.wave_dash_ticks > 0 or state.vault_ticks > 0
		or state.stamina < MovementTuning.WALL_SKIM_COST
	):
		return false
	var wall_normal := Vector2i(state.wall_x, state.wall_y)
	if wall_normal == Vector2i.ZERO:
		return false
	var dot: int = direction.x * wall_normal.x + direction.y * wall_normal.y
	@warning_ignore("integer_division")
	var tangent := direction - Vector2i(
		wall_normal.x * dot / 1_000_000,
		wall_normal.y * dot / 1_000_000,
	)
	var clockwise := Vector2i(-wall_normal.y, wall_normal.x)
	if dot > 0 or tangent == Vector2i.ZERO:
		return false
	tangent = _direction(tangent.x, tangent.y, clockwise)
	_spend_stamina(state, MovementTuning.WALL_SKIM_COST, config)
	state.wall_skim_ticks = config.milliseconds_to_ticks(MovementTuning.WALL_SKIM_DURATION_MS)
	state.wall_skim_cooldown_ticks = config.milliseconds_to_ticks(MovementTuning.WALL_SKIM_COOLDOWN_MS)
	state.wall_skim_x = tangent.x
	state.wall_skim_y = tangent.y
	state.wall_skim_surface_id = state.wall_contact_id
	state.wall_skim_lockout_id = state.wall_contact_id
	state.wall_skim_lockout_ticks = config.milliseconds_to_ticks(MovementTuning.WALL_SKIM_SAME_SURFACE_LOCKOUT_MS)
	state.wall_memory_ticks = 0
	state.wall_contact_id = 0
	_clear_landing_cue(state)
	state.sprinting = false
	state.last_event = "wall_skim"
	return true


static func _apply_velocity(state: PlayerState, command: SimCommand, direction: Vector2i, config: SimConfig) -> void:
	if state.superglide_ticks > 0:
		_set_directional_velocity(state, Vector2i(state.superglide_x, state.superglide_y), MovementTuning.SUPERGLIDE_SPEED)
	elif state.air_dodge_ticks > 0:
		var dodge_speed := MovementTuning.ROLL_SPEED if state.is_rolling() else MovementTuning.AIR_DODGE_SPEED
		_set_directional_velocity(state, Vector2i(state.air_dodge_x, state.air_dodge_y), dodge_speed)
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
		var hop_direction := _steer_hop(
			Vector2i(state.hop_x, state.hop_y),
			direction,
			command,
			config,
		)
		state.hop_x = hop_direction.x
		state.hop_y = hop_direction.y
		_set_directional_velocity(state, hop_direction, state.hop_speed)
	elif state.wall_skim_ticks > 0:
		_set_directional_velocity(state, Vector2i(state.wall_skim_x, state.wall_skim_y), MovementTuning.WALL_SKIM_SPEED)
	else:
		_apply_ground_velocity(state, command, direction, config)


static func _apply_control_velocity(state: PlayerState, config: SimConfig) -> void:
	state.sprinting = false
	match state.control_state:
		PlayerState.ControlState.LAUNCHED, PlayerState.ControlState.GRAPPLED, PlayerState.ControlState.CHARGING:
			_set_directional_velocity(state, Vector2i(state.control_x, state.control_y), state.control_speed)
		PlayerState.ControlState.STUNNED:
			var braking: int = config.per_tick(MovementTuning.DECELERATION)
			state.velocity_x = _approach(state.velocity_x, 0, braking)
			state.velocity_y = _approach(state.velocity_y, 0, braking)
		PlayerState.ControlState.ROOTED:
			state.velocity_x = 0
			state.velocity_y = 0


static func _apply_ground_velocity(state: PlayerState, command: SimCommand, direction: Vector2i, config: SimConfig) -> void:
	var moving: bool = command.move_x != 0 or command.move_y != 0
	var sprinting: bool = moving and command.has_held(SimCommand.HELD_SPRINT) and state.stamina > 0
	@warning_ignore("integer_division")
	var speed: int = MovementTuning.BASE_SPEED * state.movement_speed_ratio / 1000
	@warning_ignore("integer_division")
	speed = speed * _input_magnitude(command.move_x, command.move_y) / 1000
	if sprinting:
		@warning_ignore("integer_division")
		speed = speed * MovementTuning.SPRINT_MULTIPLIER / 1000
	var desired_x: int = direction.x * speed / 1000 if moving else 0
	var desired_y: int = direction.y * speed / 1000 if moving else 0
	var opposing: bool = (
		moving
		and state.velocity_x * direction.x + state.velocity_y * direction.y
		< MovementTuning.COUNTER_STRAFE_DOT_THRESHOLD
	)
	var rate: int = MovementTuning.ACCELERATION if moving else MovementTuning.DECELERATION
	# Reserved chemistry seam remains exactly neutral; no per-frame allocation.
	var surface_ratio := SurfaceMotionPolicy.acceleration_ratio() if moving else SurfaceMotionPolicy.braking_ratio()
	rate = rate * surface_ratio / SurfaceMotionPolicy.NEUTRAL_RATIO
	if opposing:
		@warning_ignore("integer_division")
		rate = rate * MovementTuning.COUNTER_STRAFE_MULTIPLIER / 1000
		if state.landing_ticks > 0:
			@warning_ignore("integer_division")
			rate = rate * MovementTuning.LANDING_CUT_MULTIPLIER / 1000
			state.landing_ticks = 0
			state.landing_intensity = 0
			state.last_event = "landing_cut"
	var step_amount: int = config.per_tick(rate)
	var approached := _approach_vector(
		Vector2i(state.velocity_x, state.velocity_y),
		Vector2i(desired_x, desired_y),
		step_amount,
	)
	state.velocity_x = approached.x
	state.velocity_y = approached.y
	state.sprinting = sprinting
	if sprinting:
		_apply_stamina_rate(state, -MovementTuning.SPRINT_DRAIN_PER_SECOND, config)
		state.stamina_recovery_delay_ticks = config.milliseconds_to_ticks(MovementTuning.STAMINA_RECOVERY_DELAY_MS)
	elif state.stamina_recovery_delay_ticks == 0:
		_apply_stamina_rate(state, state.stamina_recovery_per_second, config)


static func _integrate(state: PlayerState, config: SimConfig, world: CollisionWorld) -> void:
	var was_launched: bool = state.control_state == PlayerState.ControlState.LAUNCHED
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
		if result.wall_id != state.wall_lockout_id or state.wall_lockout_ticks == 0:
			state.wall_memory_ticks = config.milliseconds_to_ticks(MovementTuning.WALL_MEMORY_MS)
			state.wall_x = result.wall_normal.x
			state.wall_y = result.wall_normal.y
			state.wall_contact_id = result.wall_id
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
		if was_launched:
			_begin_impact_recovery(state, config)
			state.last_event = "launch_impact"


static func _update_mode(state: PlayerState, command: SimCommand) -> void:
	if state.control_state != PlayerState.ControlState.FREE:
		state.movement_mode = PlayerState.MovementMode.LAUNCHED + state.control_state - PlayerState.ControlState.LAUNCHED
	elif state.impact_recovery_ticks > 0:
		state.movement_mode = PlayerState.MovementMode.IMPACT_RECOVERY
	elif state.superglide_ticks > 0:
		state.movement_mode = PlayerState.MovementMode.SUPERGLIDE
	elif state.air_dodge_ticks > 0:
		state.movement_mode = PlayerState.MovementMode.ROLL if state.is_rolling() else PlayerState.MovementMode.AIR_DODGE
	elif state.wave_dash_ticks > 0:
		state.movement_mode = PlayerState.MovementMode.WAVE_DASH
	elif state.vault_ticks > 0:
		state.movement_mode = PlayerState.MovementMode.VAULT
	elif state.slide_ticks > 0:
		state.movement_mode = PlayerState.MovementMode.SLIDE
	elif state.hop_ticks > 0:
		state.movement_mode = PlayerState.MovementMode.FAST_FALL if state.fast_falling else state.hop_mode
	elif state.wall_skim_ticks > 0:
		state.movement_mode = PlayerState.MovementMode.WALL_SKIM
	elif state.sprinting:
		state.movement_mode = PlayerState.MovementMode.SPRINT
	elif (
		command.move_x != 0 or command.move_y != 0
		or _speed_squared(state.velocity_x, state.velocity_y)
		>= MovementTuning.MOVING_MODE_MINIMUM_SPEED * MovementTuning.MOVING_MODE_MINIMUM_SPEED
	):
		state.movement_mode = PlayerState.MovementMode.WALK
	else:
		state.movement_mode = PlayerState.MovementMode.IDLE


static func _spend_stamina(state: PlayerState, amount: int, config: SimConfig) -> void:
	state.stamina = maxi(0, state.stamina - amount)
	state.stamina_remainder = 0
	state.stamina_recovery_delay_ticks = config.milliseconds_to_ticks(MovementTuning.STAMINA_RECOVERY_DELAY_MS)


static func _clear_landing_cue(state: PlayerState) -> void:
	state.landing_ticks = 0
	state.landing_intensity = 0


static func _hop_landing_intensity(hop_mode: int, fast_falling: bool) -> int:
	var intensity: int = MovementTuning.LANDING_HOP_INTENSITY
	match hop_mode:
		PlayerState.MovementMode.DOUBLE_JUMP:
			intensity = MovementTuning.LANDING_DOUBLE_JUMP_INTENSITY
		PlayerState.MovementMode.SLIDE_JUMP:
			intensity = MovementTuning.LANDING_SLIDE_JUMP_INTENSITY
		PlayerState.MovementMode.WALL_KICK:
			intensity = MovementTuning.LANDING_WALL_KICK_INTENSITY
	if fast_falling:
		intensity += MovementTuning.LANDING_FAST_FALL_BONUS
	return mini(1000, intensity)


static func _apply_stamina_rate(state: PlayerState, rate_per_second: int, config: SimConfig) -> void:
	var total: int = state.stamina_remainder + rate_per_second
	@warning_ignore("integer_division")
	var amount: int = total / config.tick_rate
	state.stamina_remainder = total - amount * config.tick_rate
	state.stamina = clampi(state.stamina + amount, 0, state.stamina_maximum)


static func _direction(input_x: int, input_y: int, fallback: Vector2i) -> Vector2i:
	var x: int = signi(input_x)
	var y: int = signi(input_y)
	if x == 0 and y == 0:
		return fallback if fallback != Vector2i.ZERO else Vector2i(1000, 0)
	if x != 0 and y != 0:
		return Vector2i(x * 707, y * 707)
	return Vector2i(x * 1000, y * 1000)


static func _normalized_fixed(x: int, y: int, fallback: Vector2i) -> Vector2i:
	if x == 0 and y == 0:
		return fallback if fallback != Vector2i.ZERO else Vector2i(1000, 0)
	var magnitude := _integer_sqrt(x * x + y * y)
	if magnitude <= 0:
		return fallback
	@warning_ignore("integer_division")
	var normalized_x: int = x * 1000 / magnitude
	@warning_ignore("integer_division")
	var normalized_y: int = y * 1000 / magnitude
	return Vector2i(clampi(normalized_x, -1000, 1000), clampi(normalized_y, -1000, 1000))


static func _input_magnitude(x: int, y: int) -> int:
	var magnitude := mini(1000, _integer_sqrt(x * x + y * y))
	# The exact fixed-point diagonal is 707/707 (length 999 after integer
	# truncation); treat the final two units as a full digital/controller gate.
	return 1000 if magnitude >= 998 else magnitude


static func _integer_sqrt(value: int) -> int:
	if value <= 0:
		return 0
	var estimate := value
	var candidate := (estimate + 1) / 2
	while candidate < estimate:
		estimate = candidate
		candidate = (estimate + value / estimate) / 2
	return estimate


static func _wall_kick_direction(requested: Vector2i, wall_normal: Vector2i) -> Vector2i:
	var dot: int = requested.x * wall_normal.x + requested.y * wall_normal.y
	@warning_ignore("integer_division")
	var tangent := requested - Vector2i(wall_normal.x * dot / 1_000_000, wall_normal.y * dot / 1_000_000)
	return _direction(wall_normal.x + tangent.x * 72 / 100, wall_normal.y + tangent.y * 72 / 100, wall_normal)


static func _steer(current: Vector2i, requested: Vector2i, command: SimCommand, ratio: int) -> Vector2i:
	if command.move_x == 0 and command.move_y == 0:
		return current
	return _direction(_blend_axis(current.x, requested.x, ratio), _blend_axis(current.y, requested.y, ratio), current)


static func _steer_hop(current: Vector2i, requested: Vector2i, command: SimCommand, config: SimConfig) -> Vector2i:
	if command.move_x == 0 and command.move_y == 0 or config == null:
		return current
	@warning_ignore("integer_division")
	var ratio := clampi(MovementTuning.HOP_STEERING_PER_SECOND / config.tick_rate, 1, 1000)
	# Keep the blended magnitude: reversing in air should briefly trade speed
	# for control instead of snapping through a zero-angle discontinuity.
	return Vector2i(
		_blend_axis(current.x, requested.x, ratio),
		_blend_axis(current.y, requested.y, ratio),
	)


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


static func _approach_vector(current: Vector2i, target: Vector2i, amount: int) -> Vector2i:
	var delta := target - current
	var distance := _integer_sqrt(delta.x * delta.x + delta.y * delta.y)
	if distance <= maxi(0, amount):
		return target
	var direction := _normalized_fixed(delta.x, delta.y, Vector2i.ZERO)
	@warning_ignore("integer_division")
	var step_x: int = direction.x * amount / 1000
	@warning_ignore("integer_division")
	var step_y: int = direction.y * amount / 1000
	return current + Vector2i(step_x, step_y)


static func _speed_squared(x: int, y: int) -> int:
	return x * x + y * y

static func _try_air_wall_kick(state: PlayerState, direction: Vector2i, config: SimConfig) -> bool:
	if state.stamina < MovementTuning.HOP_COST or state.wall_lockout_id == state.wall_contact_id and state.wall_lockout_ticks > 0:
		return false
	var redirects := state.air_redirects_remaining
	var old_cooldown := state.hop_cooldown_ticks
	state.hop_cooldown_ticks = 0
	if not _try_hop(state, direction, config):
		state.hop_cooldown_ticks = old_cooldown
		return false
	# Spend the same finite second air-action budget as double jump.
	state.hop_stage = 2
	state.air_redirects_remaining = redirects
	return true


static func _has_wall_contact(state: PlayerState, world: CollisionWorld, surface_id: int) -> bool:
	if surface_id <= 0:
		return false
	for obstacle: CollisionWorld.Obstacle in world.obstacles:
		if obstacle.obstacle_id != surface_id or not obstacle.wall_runnable:
			continue
		var tolerance := state.radius + MovementTuning.WALL_CONTACT_TOLERANCE
		if state.wall_x != 0 and state.position_y >= obstacle.minimum_y and state.position_y <= obstacle.maximum_y:
			var face := obstacle.minimum_x if state.wall_x < 0 else obstacle.maximum_x
			return absi(state.position_x - face) <= tolerance
		if state.wall_y != 0 and state.position_x >= obstacle.minimum_x and state.position_x <= obstacle.maximum_x:
			var face := obstacle.minimum_y if state.wall_y < 0 else obstacle.maximum_y
			return absi(state.position_y - face) <= tolerance
	return false


static func _update_wall_attachment(state: PlayerState, command: SimCommand, world: CollisionWorld, config: SimConfig) -> void:
	if state.wall_skim_ticks <= 0:
		return
	var moving_away := command.move_x * state.wall_x + command.move_y * state.wall_y > 0
	if moving_away or not _has_wall_contact(state, world, state.wall_skim_surface_id):
		_end_wall_run(state, "wall_detach" if moving_away else "wall_end", config)
	else:
		state.wall_contact_id = state.wall_skim_surface_id
		state.wall_memory_ticks = config.milliseconds_to_ticks(MovementTuning.WALL_MEMORY_MS)


static func _end_wall_run(state: PlayerState, event_name: String, config: SimConfig) -> void:
	state.wall_skim_ticks = 0
	state.wall_skim_surface_id = 0
	state.landing_ticks = config.milliseconds_to_ticks(MovementTuning.LANDING_WINDOW_MS)
	state.landing_intensity = MovementTuning.LANDING_WALL_SKIM_INTENSITY
	state.last_event = event_name
