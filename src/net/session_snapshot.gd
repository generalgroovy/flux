class_name SessionSnapshot
extends RefCounted


const SCHEMA_VERSION: int = 1
const MAX_PLAYERS: int = 8
const PLAYER_VALUE_COUNT: int = 35
const MAX_ABSOLUTE_POSITION: int = 100_000_000
const MAX_TIMER_TICKS: int = 1_000_000


static func capture(world: SimWorld, names_by_entity: Dictionary) -> Dictionary:
	var ordered: Array[PlayerState] = []
	for state: PlayerState in world.players:
		if state.actor_kind == PlayerState.ActorKind.CHAMPION:
			ordered.append(state)
	ordered.sort_custom(func(left: PlayerState, right: PlayerState) -> bool: return left.entity_id < right.entity_id)
	var players: Array[Dictionary] = []
	for state: PlayerState in ordered:
		players.append({
			"entity_id": state.entity_id,
			"name": _safe_name(String(names_by_entity.get(state.entity_id, "Traveller %d" % state.entity_id))),
			"values": PackedInt64Array([
				state.champion_wire_id,
				state.position_x, state.position_y,
				state.velocity_x, state.velocity_y,
				state.facing_x, state.facing_y,
				state.aim_x, state.aim_y,
				state.radius, state.movement_mode,
				state.health_maximum, state.health,
				state.flux_maximum, state.flux,
				state.stamina_maximum, state.stamina,
				state.hop_ticks, state.hop_mode,
				state.air_dodge_ticks, state.superglide_ticks,
				state.vault_ticks, state.wave_dash_ticks, state.slide_ticks,
				state.landing_ticks, state.landing_intensity,
				state.control_state, state.control_ticks,
				state.primary_wire_id, state.active_1_wire_id,
				state.slow_ratio, state.team_id,
				int(state.sprinting), int(state.fast_falling),
				state.cast_recovery_ticks,
			]),
		})
	return {
		"schema": SCHEMA_VERSION,
		"tick": world.tick,
		"state_hash": world.state_hash(),
		"players": players,
	}


static func validate(snapshot: Dictionary) -> bool:
	if typeof(snapshot.get("schema")) != TYPE_INT or int(snapshot["schema"]) != SCHEMA_VERSION:
		return false
	if typeof(snapshot.get("tick")) != TYPE_INT or int(snapshot["tick"]) < 0 or int(snapshot["tick"]) > 0x7fffffff:
		return false
	var state_hash := String(snapshot.get("state_hash", ""))
	if not _is_sha256(state_hash):
		return false
	var players_value: Variant = snapshot.get("players")
	if not players_value is Array:
		return false
	var players: Array = players_value
	if players.is_empty() or players.size() > MAX_PLAYERS:
		return false
	var seen: Dictionary[int, bool] = {}
	var previous_entity_id: int = 0
	for player_value: Variant in players:
		if not player_value is Dictionary:
			return false
		var player: Dictionary = player_value
		if typeof(player.get("entity_id")) != TYPE_INT:
			return false
		var entity_id := int(player["entity_id"])
		if entity_id < 1 or entity_id > MAX_PLAYERS or entity_id <= previous_entity_id or seen.has(entity_id):
			return false
		previous_entity_id = entity_id
		seen[entity_id] = true
		if _safe_name(String(player.get("name", ""))).is_empty():
			return false
		var values_value: Variant = player.get("values")
		if typeof(values_value) != TYPE_PACKED_INT64_ARRAY:
			return false
		var values: PackedInt64Array = values_value
		if values.size() != PLAYER_VALUE_COUNT or not _valid_player_values(values):
			return false
	return true


static func apply_to_world(snapshot: Dictionary, world: SimWorld) -> bool:
	if world == null or not world.is_valid() or not validate(snapshot):
		return false
	var retained: Array[PlayerState] = []
	for state: PlayerState in world.players:
		if state.actor_kind != PlayerState.ActorKind.CHAMPION:
			retained.append(state)
	world.players = retained
	for player_value: Variant in snapshot["players"]:
		var player: Dictionary = player_value
		var state := PlayerState.new(int(player["entity_id"]))
		_apply_values(state, player["values"])
		world.players.append(state)
	world.players.sort_custom(func(left: PlayerState, right: PlayerState) -> bool: return left.entity_id < right.entity_id)
	world.tick = int(snapshot["tick"])
	world.projectiles = []
	world.combat_events = []
	return true


static func names(snapshot: Dictionary) -> Dictionary[int, String]:
	var result: Dictionary[int, String] = {}
	if not validate(snapshot):
		return result
	for player_value: Variant in snapshot["players"]:
		var player: Dictionary = player_value
		result[int(player["entity_id"])] = String(player["name"])
	return result


static func _apply_values(state: PlayerState, values: PackedInt64Array) -> void:
	state.champion_wire_id = values[0]
	state.position_x = values[1]
	state.position_y = values[2]
	state.velocity_x = values[3]
	state.velocity_y = values[4]
	state.facing_x = values[5]
	state.facing_y = values[6]
	state.aim_x = values[7]
	state.aim_y = values[8]
	state.radius = values[9]
	state.movement_mode = values[10]
	state.health_maximum = values[11]
	state.health = values[12]
	state.flux_maximum = values[13]
	state.flux = values[14]
	state.stamina_maximum = values[15]
	state.stamina = values[16]
	state.hop_ticks = values[17]
	state.hop_mode = values[18]
	state.air_dodge_ticks = values[19]
	state.superglide_ticks = values[20]
	state.vault_ticks = values[21]
	state.wave_dash_ticks = values[22]
	state.slide_ticks = values[23]
	state.landing_ticks = values[24]
	state.landing_intensity = values[25]
	state.control_state = values[26]
	state.control_ticks = values[27]
	state.primary_wire_id = values[28]
	state.active_1_wire_id = values[29]
	state.slow_ratio = values[30]
	state.team_id = values[31]
	state.sprinting = values[32] == 1
	state.fast_falling = values[33] == 1
	state.cast_recovery_ticks = values[34]


static func _valid_player_values(values: PackedInt64Array) -> bool:
	if values[0] <= 0 or values[0] > 4096:
		return false
	for index: int in [1, 2]:
		if absi(values[index]) > MAX_ABSOLUTE_POSITION:
			return false
	for index: int in [3, 4]:
		if absi(values[index]) > 10_000_000:
			return false
	for index: int in [5, 6, 7, 8]:
		if values[index] < -1000 or values[index] > 1000:
			return false
	if values[9] <= 0 or values[9] > 100_000:
		return false
	if values[10] < 0 or values[10] >= PlayerState.MovementMode.size():
		return false
	for pair: Vector2i in [Vector2i(11, 12), Vector2i(13, 14), Vector2i(15, 16)]:
		if values[pair.x] < 0 or values[pair.x] > 1_000_000 or values[pair.y] < 0 or values[pair.y] > values[pair.x]:
			return false
	for index: int in [17, 19, 20, 21, 22, 23, 24, 27, 34]:
		if values[index] < 0 or values[index] > MAX_TIMER_TICKS:
			return false
	if values[18] < 0 or values[18] >= PlayerState.MovementMode.size():
		return false
	if values[25] < 0 or values[25] > 1000:
		return false
	if values[26] < 0 or values[26] >= PlayerState.ControlState.size():
		return false
	for index: int in [28, 29]:
		if values[index] <= 0 or values[index] > 65_535:
			return false
	if values[30] < 0 or values[30] > 1000 or values[31] < 0 or values[31] > 32:
		return false
	return values[32] in [0, 1] and values[33] in [0, 1]


static func _safe_name(requested_name: String) -> String:
	var safe_name := requested_name.strip_edges()
	if safe_name.is_empty() or safe_name.length() > 24:
		return ""
	for character: String in safe_name:
		var codepoint := character.unicode_at(0)
		if codepoint < 32 or codepoint == 127:
			return ""
	return safe_name


static func _is_sha256(value: String) -> bool:
	if value.length() != 64:
		return false
	for character: String in value:
		if character not in "0123456789abcdef":
			return false
	return true
