class_name SessionSnapshot
extends RefCounted


const SCHEMA_VERSION: int = 2
const MAX_PLAYERS: int = 8
const PLAYER_VALUE_COUNT: int = 43
const PROJECTILE_VALUE_COUNT: int = 12
const EVENT_VALUE_COUNT: int = 6
const MAX_PROJECTILES: int = 26
const MAX_EVENTS: int = 12
const MAX_ABSOLUTE_POSITION: int = 100_000_000
const MAX_TIMER_TICKS: int = 1_000_000


static func capture(
	world: SimWorld,
	names_by_entity: Dictionary,
	combat_events: Array[Dictionary] = [],
) -> Dictionary:
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
			"event": _safe_event_name(state.last_event),
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
				state.pending_cast_wire_id, state.pending_cast_ticks,
				state.primary_cooldown_ticks, state.active_1_cooldown_ticks,
				state.edgeweave_cooldown_ticks, int(state.primary_held),
				state.pending_cast_aim_x, state.pending_cast_aim_y,
			]),
		})
	var ordered_projectiles: Array[ProjectileState] = world.projectiles.duplicate()
	ordered_projectiles.sort_custom(func(left: ProjectileState, right: ProjectileState) -> bool: return left.entity_id < right.entity_id)
	var projectiles: Array[PackedInt64Array] = []
	for index: int in range(mini(ordered_projectiles.size(), MAX_PROJECTILES)):
		var projectile: ProjectileState = ordered_projectiles[index]
		projectiles.append(PackedInt64Array([
			projectile.entity_id, projectile.owner_id,
			projectile.source_wire_id, projectile.element_wire_id,
			projectile.position_x, projectile.position_y,
			projectile.previous_x, projectile.previous_y,
			projectile.velocity_x, projectile.velocity_y,
			projectile.radius, projectile.lifetime_ticks,
		]))
	var events: Array[PackedInt64Array] = []
	var first_event_index := maxi(0, combat_events.size() - MAX_EVENTS)
	for index: int in range(first_event_index, combat_events.size()):
		var encoded_event := encode_event(combat_events[index])
		if not encoded_event.is_empty():
			events.append(encoded_event)
	return {
		"schema": SCHEMA_VERSION,
		"tick": world.tick,
		"state_hash": world.state_hash(),
		"players": players,
		"projectiles": projectiles,
		"projectile_overflow": maxi(0, ordered_projectiles.size() - MAX_PROJECTILES),
		"events": events,
		"event_overflow": maxi(0, combat_events.size() - MAX_EVENTS),
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
		if _safe_event_name(String(player.get("event", ""))).is_empty():
			return false
		var values_value: Variant = player.get("values")
		if typeof(values_value) != TYPE_PACKED_INT64_ARRAY:
			return false
		var values: PackedInt64Array = values_value
		if values.size() != PLAYER_VALUE_COUNT or not _valid_player_values(values):
			return false
	var projectiles_value: Variant = snapshot.get("projectiles")
	if not projectiles_value is Array or projectiles_value.size() > MAX_PROJECTILES:
		return false
	var previous_projectile_id: int = 0
	for values_value: Variant in projectiles_value:
		if typeof(values_value) != TYPE_PACKED_INT64_ARRAY:
			return false
		var values: PackedInt64Array = values_value
		if values.size() != PROJECTILE_VALUE_COUNT or not _valid_projectile_values(values):
			return false
		if values[0] <= previous_projectile_id:
			return false
		previous_projectile_id = values[0]
	if not _valid_overflow(snapshot.get("projectile_overflow")):
		return false
	var events_value: Variant = snapshot.get("events")
	if not events_value is Array or events_value.size() > MAX_EVENTS:
		return false
	for values_value: Variant in events_value:
		if typeof(values_value) != TYPE_PACKED_INT64_ARRAY:
			return false
		var values: PackedInt64Array = values_value
		if values.size() != EVENT_VALUE_COUNT or not _valid_event_values(values):
			return false
	if not _valid_overflow(snapshot.get("event_overflow")):
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
		state.last_event = String(player["event"])
		world.players.append(state)
	world.players.sort_custom(func(left: PlayerState, right: PlayerState) -> bool: return left.entity_id < right.entity_id)
	world.tick = int(snapshot["tick"])
	world.projectiles = []
	for values_value: Variant in snapshot["projectiles"]:
		world.projectiles.append(_projectile_from_values(values_value))
	world.combat_events = []
	for values_value: Variant in snapshot["events"]:
		world.combat_events.append(decode_event(values_value))
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
	state.pending_cast_wire_id = values[35]
	state.pending_cast_ticks = values[36]
	state.primary_cooldown_ticks = values[37]
	state.active_1_cooldown_ticks = values[38]
	state.edgeweave_cooldown_ticks = values[39]
	state.primary_held = values[40] == 1
	state.pending_cast_aim_x = values[41]
	state.pending_cast_aim_y = values[42]


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
	for index: int in [17, 19, 20, 21, 22, 23, 24, 27, 34, 36, 37, 38, 39]:
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
	if values[35] < 0 or values[35] > 65_535 or values[40] not in [0, 1]:
		return false
	for index: int in [41, 42]:
		if values[index] < -1000 or values[index] > 1000:
			return false
	return values[32] in [0, 1] and values[33] in [0, 1]


static func _projectile_from_values(values: PackedInt64Array) -> ProjectileState:
	var projectile := ProjectileState.new(
		values[0],
		values[1],
		0,
		values[2],
		values[3],
		Vector2i(values[4], values[5]),
		Vector2i(values[8], values[9]),
		values[10],
		0,
		values[11],
	)
	projectile.previous_x = values[6]
	projectile.previous_y = values[7]
	return projectile


static func _valid_projectile_values(values: PackedInt64Array) -> bool:
	if values[0] <= 0 or values[0] > 0x7fffffff:
		return false
	if values[1] < 1 or values[1] > MAX_PLAYERS:
		return false
	for index: int in [2, 3]:
		if values[index] <= 0 or values[index] > 65_535:
			return false
	for index: int in [4, 5, 6, 7]:
		if absi(values[index]) > MAX_ABSOLUTE_POSITION:
			return false
	for index: int in [8, 9]:
		if absi(values[index]) > 10_000_000:
			return false
	return values[10] > 0 and values[10] <= 100_000 and values[11] >= 0 and values[11] <= MAX_TIMER_TICKS


static func encode_event(event: Dictionary) -> PackedInt64Array:
	match String(event.get("type", "")):
		"cast_started":
			return PackedInt64Array([1, int(event.get("entity_id", 0)), int(event.get("wire_id", 0)), 0, 0, 0])
		"cast_refused":
			var reason_code: int = {"kit": 1, "flux": 2}.get(String(event.get("reason", "")), 3)
			return PackedInt64Array([2, int(event.get("entity_id", 0)), int(event.get("wire_id", 0)), reason_code, 0, 0])
		"cast_blocked":
			return PackedInt64Array([3, int(event.get("entity_id", 0)), int(event.get("wire_id", 0)), 0, 0, 0])
		"projectile_spawned":
			return PackedInt64Array([4, int(event.get("projectile_id", 0)), int(event.get("owner_id", 0)), int(event.get("wire_id", 0)), 0, 0])
		"projectile_hit":
			return PackedInt64Array([5, int(event.get("projectile_id", 0)), int(event.get("source_wire_id", 0)), int(event.get("owner_id", 0)), int(event.get("target_id", 0)), int(event.get("damage", 0))])
		"projectile_impact":
			return PackedInt64Array([6, int(event.get("projectile_id", 0)), int(event.get("wall_id", 0)), 0, 0, 0])
		"projectile_bounced":
			return PackedInt64Array([7, int(event.get("projectile_id", 0)), int(event.get("wall_id", 0)), int(event.get("remaining_bounces", 0)), 0, 0])
		"projectile_expired":
			return PackedInt64Array([8, int(event.get("projectile_id", 0)), 0, 0, 0, 0])
		"edgeweave":
			return PackedInt64Array([9, int(event.get("entity_id", 0)), int(event.get("projectile_id", 0)), int(event.get("stamina", 0)), 0, 0])
		_:
			return PackedInt64Array()


static func decode_event(values: PackedInt64Array) -> Dictionary:
	match values[0]:
		1:
			return {"type": "cast_started", "entity_id": values[1], "wire_id": values[2]}
		2:
			var reason: String = {1: "kit", 2: "flux", 3: "other"}.get(values[3], "other")
			return {"type": "cast_refused", "entity_id": values[1], "wire_id": values[2], "reason": reason}
		3:
			return {"type": "cast_blocked", "entity_id": values[1], "wire_id": values[2]}
		4:
			return {"type": "projectile_spawned", "projectile_id": values[1], "owner_id": values[2], "wire_id": values[3]}
		5:
			return {"type": "projectile_hit", "projectile_id": values[1], "source_wire_id": values[2], "owner_id": values[3], "target_id": values[4], "damage": values[5]}
		6:
			return {"type": "projectile_impact", "projectile_id": values[1], "wall_id": values[2]}
		7:
			return {"type": "projectile_bounced", "projectile_id": values[1], "wall_id": values[2], "remaining_bounces": values[3]}
		8:
			return {"type": "projectile_expired", "projectile_id": values[1]}
		9:
			return {"type": "edgeweave", "entity_id": values[1], "projectile_id": values[2], "stamina": values[3]}
	return {}


static func _valid_event_values(values: PackedInt64Array) -> bool:
	var kind := int(values[0])
	if kind < 1 or kind > 9:
		return false
	if kind in [1, 2, 3]:
		if values[1] < 1 or values[1] > MAX_PLAYERS or values[2] <= 0 or values[2] > 65_535:
			return false
		return kind != 2 or values[3] in [1, 2, 3]
	if kind == 4:
		return values[1] > 0 and values[2] >= 1 and values[2] <= MAX_PLAYERS and values[3] > 0 and values[3] <= 65_535
	if kind == 5:
		return values[1] > 0 and values[2] > 0 and values[2] <= 65_535 and values[3] >= 1 and values[3] <= MAX_PLAYERS and values[4] >= 1 and values[4] <= 0x7fffffff and values[5] > 0 and values[5] <= 1_000_000
	if kind in [6, 7]:
		return values[1] > 0 and values[2] >= 0 and (kind != 7 or (values[3] >= 0 and values[3] <= 8))
	if kind == 8:
		return values[1] > 0
	return values[1] >= 1 and values[1] <= MAX_PLAYERS and values[2] > 0 and values[3] > 0 and values[3] <= 1_000_000


static func _valid_overflow(value: Variant) -> bool:
	return typeof(value) == TYPE_INT and int(value) >= 0 and int(value) <= 0x7fffffff


static func _safe_event_name(requested_name: String) -> String:
	var safe_name := requested_name.strip_edges()
	if safe_name.is_empty() or safe_name.length() > 48:
		return ""
	for character: String in safe_name:
		if character not in "abcdefghijklmnopqrstuvwxyz0123456789_":
			return ""
	return safe_name


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
