class_name ClientPrediction
extends RefCounted


const MAX_PENDING_INPUTS: int = 48
const SOFT_CORRECTION_LIMIT_PIXELS: float = 72.0
const CORRECTION_RECOVERY_PIXELS_PER_SECOND: float = 720.0
const MOVEMENT_HELD_MASK: int = SimCommand.HELD_SPRINT | SimCommand.HELD_JUMP | SimCommand.HELD_FAST_FALL
const MOVEMENT_PRESSED_MASK: int = SimCommand.PRESSED_JUMP | SimCommand.PRESSED_TECHNIQUE | SimCommand.PRESSED_SLIDE
const STATE_FIELDS: Array[StringName] = [
	&"entity_id",
	&"position_x", &"position_y", &"position_remainder_x", &"position_remainder_y",
	&"velocity_x", &"velocity_y",
	&"facing_x", &"facing_y", &"aim_x", &"aim_y",
	&"radius", &"movement_mode",
	&"stamina_maximum", &"stamina_recovery_per_second", &"movement_speed_ratio",
	&"stamina", &"stamina_remainder", &"stamina_recovery_delay_ticks",
	&"jump_buffer_ticks", &"technique_buffer_ticks", &"slide_buffer_ticks",
	&"fast_falling", &"variable_jump_grace_ticks",
	&"hop_ticks", &"hop_cooldown_ticks", &"hop_stage", &"hop_mode",
	&"hop_speed", &"hop_x", &"hop_y", &"air_redirects_remaining",
	&"air_dodge_ticks", &"air_dodge_cooldown_ticks", &"air_dodge_x", &"air_dodge_y",
	&"wave_dash_queued", &"wave_dash_ticks", &"wave_dash_x", &"wave_dash_y",
	&"slide_ticks", &"slide_cooldown_ticks", &"slide_x", &"slide_y",
	&"vault_ticks", &"vault_cooldown_ticks", &"vault_x", &"vault_y",
	&"superglide_ticks", &"superglide_x", &"superglide_y",
	&"wall_memory_ticks", &"wall_x", &"wall_y", &"wall_contact_id",
	&"wall_lockout_id", &"wall_lockout_ticks",
	&"wall_skim_ticks", &"wall_skim_cooldown_ticks", &"wall_skim_x", &"wall_skim_y",
	&"wall_skim_surface_id", &"wall_skim_lockout_id", &"wall_skim_lockout_ticks",
	&"landing_ticks", &"landing_intensity", &"sprinting",
	&"control_state", &"control_ticks", &"control_x", &"control_y", &"control_speed", &"slow_ratio",
]
const BOOLEAN_FIELDS: Array[StringName] = [&"fast_falling", &"wave_dash_queued", &"sprinting"]
const DIRECTION_FIELDS: Array[StringName] = [
	&"facing_x", &"facing_y", &"aim_x", &"aim_y",
	&"hop_x", &"hop_y", &"air_dodge_x", &"air_dodge_y",
	&"wave_dash_x", &"wave_dash_y", &"slide_x", &"slide_y",
	&"vault_x", &"vault_y", &"superglide_x", &"superglide_y",
	&"wall_x", &"wall_y", &"wall_skim_x", &"wall_skim_y",
	&"control_x", &"control_y",
]
const TIMER_FIELDS: Array[StringName] = [
	&"stamina_recovery_delay_ticks", &"jump_buffer_ticks", &"technique_buffer_ticks", &"slide_buffer_ticks",
	&"variable_jump_grace_ticks", &"hop_ticks", &"hop_cooldown_ticks",
	&"air_dodge_ticks", &"air_dodge_cooldown_ticks", &"wave_dash_ticks",
	&"slide_ticks", &"slide_cooldown_ticks", &"vault_ticks", &"vault_cooldown_ticks",
	&"superglide_ticks", &"wall_memory_ticks", &"wall_lockout_ticks",
	&"wall_skim_ticks", &"wall_skim_cooldown_ticks", &"wall_skim_lockout_ticks",
	&"landing_ticks", &"control_ticks",
]

var config: SimConfig
var collision: CollisionWorld
var local_entity_id: int = 0
var predicted_state: PlayerState
var pending_inputs: Array[Dictionary] = []
var last_queued_sequence: int = -1
var last_acknowledged_sequence: int = -1
var last_authoritative_tick: int = -1
var last_authoritative_position_pixels := Vector2.ZERO
var last_correction_pixels: float = 0.0
var correction_count: int = 0
var hard_snap_count: int = 0
var history_overflowed: bool = false
var visual_offset := Vector2.ZERO


func configure(new_config: SimConfig, new_collision: CollisionWorld, entity_id: int) -> bool:
	reset()
	if new_config == null or not new_config.is_valid() or new_collision == null:
		return false
	if entity_id < 2 or entity_id > SessionTransport.MAX_PLAYERS:
		return false
	config = new_config
	collision = new_collision
	local_entity_id = entity_id
	return true


func reset() -> void:
	config = null
	collision = null
	local_entity_id = 0
	predicted_state = null
	pending_inputs = []
	last_queued_sequence = -1
	last_acknowledged_sequence = -1
	last_authoritative_tick = -1
	last_authoritative_position_pixels = Vector2.ZERO
	last_correction_pixels = 0.0
	correction_count = 0
	hard_snap_count = 0
	history_overflowed = false
	visual_offset = Vector2.ZERO


func is_ready() -> bool:
	return predicted_state != null and config != null and collision != null


func queue_input(sequence: int, command: SimCommand) -> bool:
	if config == null or collision == null or command == null:
		return false
	if sequence <= last_queued_sequence or sequence < 0 or sequence > 0x7fffffff:
		return false
	if command.entity_id != local_entity_id:
		return false
	var movement_command := SimCommand.new(
		0,
		local_entity_id,
		command.move_x,
		command.move_y,
		command.held_actions & MOVEMENT_HELD_MASK,
		command.pressed_actions & MOVEMENT_PRESSED_MASK,
		command.aim_x,
		command.aim_y,
	)
	pending_inputs.append({"sequence": sequence, "command": movement_command})
	last_queued_sequence = sequence
	if pending_inputs.size() > MAX_PENDING_INPUTS:
		pending_inputs.pop_front()
		history_overflowed = true
	if is_ready():
		_step_prediction(movement_command)
	return true


func reconcile(packet: Dictionary, authoritative_event: String = "network_snapshot", reduced_motion: bool = false) -> bool:
	if not validate_packet(packet) or config == null or collision == null:
		return false
	var values: PackedInt64Array = packet["values"]
	if values[0] != local_entity_id:
		return false
	var authoritative_tick := int(packet["tick"])
	var acknowledged_sequence := int(packet["sequence"])
	if authoritative_tick <= last_authoritative_tick or acknowledged_sequence < last_acknowledged_sequence:
		return false
	if acknowledged_sequence > last_queued_sequence:
		return false
	var previous_raw := raw_position_pixels()
	var had_prediction := is_ready()
	predicted_state = restore_state(values)
	predicted_state.last_event = authoritative_event
	last_authoritative_position_pixels = raw_position_pixels()
	last_authoritative_tick = authoritative_tick
	last_acknowledged_sequence = acknowledged_sequence
	while not pending_inputs.is_empty() and int(pending_inputs.front()["sequence"]) <= acknowledged_sequence:
		pending_inputs.pop_front()
	for pending: Dictionary in pending_inputs:
		_step_prediction(pending["command"])
	var corrected_raw := raw_position_pixels()
	last_correction_pixels = previous_raw.distance_to(corrected_raw) if had_prediction else 0.0
	if had_prediction and last_correction_pixels > 0.01:
		correction_count += 1
	var hard_snap := history_overflowed or reduced_motion or last_correction_pixels > SOFT_CORRECTION_LIMIT_PIXELS
	if hard_snap:
		if had_prediction and last_correction_pixels > 0.01:
			hard_snap_count += 1
		visual_offset = Vector2.ZERO
	elif had_prediction:
		visual_offset += previous_raw - corrected_raw
		if visual_offset.length() > SOFT_CORRECTION_LIMIT_PIXELS:
			visual_offset = visual_offset.normalized() * SOFT_CORRECTION_LIMIT_PIXELS
	else:
		visual_offset = Vector2.ZERO
	history_overflowed = false
	return true


func advance_visual(delta: float) -> void:
	if visual_offset == Vector2.ZERO:
		return
	visual_offset = visual_offset.move_toward(Vector2.ZERO, maxf(0.0, delta) * CORRECTION_RECOVERY_PIXELS_PER_SECOND)
	if visual_offset.length_squared() < 0.0001:
		visual_offset = Vector2.ZERO


func raw_position_pixels() -> Vector2:
	if predicted_state == null:
		return Vector2.ZERO
	return Vector2(float(predicted_state.position_x) / SimConfig.FIXED_SCALE, float(predicted_state.position_y) / SimConfig.FIXED_SCALE)


func presented_position_pixels() -> Vector2:
	return raw_position_pixels() + visual_offset


func pending_count() -> int:
	return pending_inputs.size()


func estimated_ack_delay_ms() -> int:
	if config == null or last_acknowledged_sequence < 0:
		return 0
	return maxi(0, last_queued_sequence - last_acknowledged_sequence) * 1000 / config.tick_rate


func _step_prediction(command: SimCommand) -> void:
	predicted_state.aim_x = command.aim_x
	predicted_state.aim_y = command.aim_y
	MovementSystem.step(predicted_state, command, config, collision)


static func capture_packet(state: PlayerState, tick: int, acknowledged_sequence: int) -> Dictionary:
	if state == null:
		return {}
	var values := PackedInt64Array()
	for property_name: StringName in STATE_FIELDS:
		var value: Variant = state.get(property_name)
		values.append(int(value))
	var packet := {"tick": tick, "sequence": acknowledged_sequence, "values": values}
	return packet if validate_packet(packet) else {}


static func restore_state(values: PackedInt64Array) -> PlayerState:
	if not validate_values(values):
		return null
	var state := PlayerState.new(int(values[0]))
	for index: int in range(STATE_FIELDS.size()):
		var property_name := STATE_FIELDS[index]
		state.set(property_name, values[index] == 1 if property_name in BOOLEAN_FIELDS else int(values[index]))
	return state


static func validate_packet(packet: Dictionary) -> bool:
	if typeof(packet.get("tick")) != TYPE_INT or typeof(packet.get("sequence")) != TYPE_INT:
		return false
	if int(packet["tick"]) < 0 or int(packet["tick"]) > 0x7fffffff:
		return false
	if int(packet["sequence"]) < -1 or int(packet["sequence"]) > 0x7fffffff:
		return false
	var values: Variant = packet.get("values")
	return typeof(values) == TYPE_PACKED_INT64_ARRAY and validate_values(values)


static func validate_values(values: PackedInt64Array) -> bool:
	if values.size() != STATE_FIELDS.size():
		return false
	if _value(values, &"entity_id") < 2 or _value(values, &"entity_id") > SessionTransport.MAX_PLAYERS:
		return false
	for property_name: StringName in [&"position_x", &"position_y"]:
		if absi(_value(values, property_name)) > SessionSnapshot.MAX_ABSOLUTE_POSITION:
			return false
	for property_name: StringName in [&"position_remainder_x", &"position_remainder_y"]:
		if absi(_value(values, property_name)) > 1000:
			return false
	for property_name: StringName in [&"velocity_x", &"velocity_y", &"hop_speed", &"control_speed"]:
		if absi(_value(values, property_name)) > 10_000_000:
			return false
	for property_name: StringName in DIRECTION_FIELDS:
		if _value(values, property_name) < -1000 or _value(values, property_name) > 1000:
			return false
	for property_name: StringName in BOOLEAN_FIELDS:
		if _value(values, property_name) not in [0, 1]:
			return false
	for property_name: StringName in TIMER_FIELDS:
		if _value(values, property_name) < 0 or _value(values, property_name) > SessionSnapshot.MAX_TIMER_TICKS:
			return false
	var radius := _value(values, &"radius")
	if radius <= 0 or radius > 100_000:
		return false
	if _value(values, &"movement_mode") < 0 or _value(values, &"movement_mode") >= PlayerState.MovementMode.size():
		return false
	if _value(values, &"hop_mode") < 0 or _value(values, &"hop_mode") >= PlayerState.MovementMode.size():
		return false
	if _value(values, &"control_state") < 0 or _value(values, &"control_state") >= PlayerState.ControlState.size():
		return false
	var stamina_maximum := _value(values, &"stamina_maximum")
	var stamina := _value(values, &"stamina")
	if stamina_maximum <= 0 or stamina_maximum > 1_000_000 or stamina < 0 or stamina > stamina_maximum:
		return false
	if _value(values, &"stamina_recovery_per_second") < 0 or _value(values, &"stamina_recovery_per_second") > 1_000_000:
		return false
	if _value(values, &"movement_speed_ratio") <= 0 or _value(values, &"movement_speed_ratio") > 5000:
		return false
	if absi(_value(values, &"stamina_remainder")) > 1_000_000:
		return false
	if _value(values, &"landing_intensity") < 0 or _value(values, &"landing_intensity") > 1000:
		return false
	if _value(values, &"slow_ratio") < 0 or _value(values, &"slow_ratio") > 1000:
		return false
	for property_name: StringName in [&"hop_stage", &"air_redirects_remaining", &"wall_contact_id", &"wall_lockout_id", &"wall_skim_surface_id", &"wall_skim_lockout_id"]:
		if _value(values, property_name) < 0 or _value(values, property_name) > 0x7fffffff:
			return false
	return true


static func _value(values: PackedInt64Array, property_name: StringName) -> int:
	return int(values[STATE_FIELDS.find(property_name)])
