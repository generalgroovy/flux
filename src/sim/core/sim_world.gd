class_name SimWorld
extends RefCounted


const MAP_ID: String = "foundation-arena-v1"
const MAP_HASH: String = "worldbone:none;bounds:1280x720;rails:v1"

var config: SimConfig
var collision: CollisionWorld
var tick: int = 0
var seed: int = 1
var players: Array[PlayerState] = []
var last_error: String = ""


func _init(requested_tick_rate: int = 60, requested_seed: int = 1) -> void:
	config = SimConfig.new(requested_tick_rate)
	seed = requested_seed
	collision = CollisionWorld.new()
	if config.is_valid():
		collision.add_obstacle(CollisionWorld.Obstacle.new(1, 560_000, 250_000, 620_000, 470_000, false))
		collision.add_obstacle(CollisionWorld.Obstacle.new(2, 820_000, 300_000, 900_000, 380_000, true))
		players.append(PlayerState.new(1))
	else:
		last_error = "unsupported tick rate: %d; expected 60 or 120" % requested_tick_rate


func is_valid() -> bool:
	return config.is_valid() and last_error.is_empty()


func player(entity_id: int = 1) -> PlayerState:
	for candidate: PlayerState in players:
		if candidate.entity_id == entity_id:
			return candidate
	return null


func step(commands: Array[SimCommand]) -> bool:
	if not is_valid():
		return false
	var ordered: Array[SimCommand] = commands.duplicate()
	ordered.sort_custom(func(left: SimCommand, right: SimCommand) -> bool: return left.entity_id < right.entity_id)
	var seen: Dictionary[int, bool] = {}
	for command: SimCommand in ordered:
		if command.tick != tick:
			last_error = "command tick %d does not match world tick %d" % [command.tick, tick]
			return false
		if seen.has(command.entity_id):
			last_error = "duplicate command for entity %d at tick %d" % [command.entity_id, tick]
			return false
		seen[command.entity_id] = true
		var state: PlayerState = player(command.entity_id)
		if state == null:
			last_error = "unknown entity %d" % command.entity_id
			return false
		MovementSystem.step(state, command, config, collision)
	for state: PlayerState in players:
		if not seen.has(state.entity_id):
			MovementSystem.step(state, SimCommand.new(tick, state.entity_id), config, collision)
	tick += 1
	return true


func state_hash() -> String:
	var payload := PackedByteArray()
	for value: int in [SimConfig.PROTOCOL_VERSION, config.tick_rate, tick, seed]:
		CanonicalBytes.append_i64(payload, value)
	CanonicalBytes.append_string(payload, MAP_ID)
	CanonicalBytes.append_string(payload, MAP_HASH)
	var ordered: Array[PlayerState] = players.duplicate()
	ordered.sort_custom(func(left: PlayerState, right: PlayerState) -> bool: return left.entity_id < right.entity_id)
	CanonicalBytes.append_i64(payload, ordered.size())
	for state: PlayerState in ordered:
		for value: int in state.canonical_values():
			CanonicalBytes.append_i64(payload, value)
	return CanonicalBytes.sha256_hex(payload)
