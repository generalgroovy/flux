class_name SessionTransport
extends RefCounted


enum Mode {
	OFFLINE,
	HOSTING,
	CONNECTING,
	CLIENT,
}

const DEFAULT_PORT: int = 24_872
const MAX_PLAYERS: int = 8
const MAX_REMOTE_CLIENTS: int = MAX_PLAYERS - 1
const MAX_PACKET_BYTES: int = 8_192
const ENET_MTU_BYTES: int = 1_392
const MAX_SNAPSHOT_UNCOMPRESSED_BYTES: int = MAX_PACKET_BYTES
const MAX_PACKETS_PER_POLL: int = 64
const MAX_QUEUED_INPUTS: int = MAX_REMOTE_CLIENTS * 4
const MAX_PLAYER_NAME_LENGTH: int = 24
const CONNECT_TIMEOUT_MS: int = 5_000
const RECONNECT_WINDOW_MS: int = 15_000
const ADMIN_DISCONNECT_GRACE_MS: int = 250
const RECONNECT_TOKEN_BYTES: int = 32
const SERVER_PEER_ID: int = 1

const PACKET_HELLO: int = 1
const PACKET_ACCEPT: int = 2
const PACKET_REJECT: int = 3
const PACKET_INPUT: int = 4
const PACKET_SNAPSHOT: int = 5
const PACKET_REQUEST: int = 6
const PACKET_RECONCILIATION: int = 7
const PACKET_ADMIN_CLOSE: int = 8
const MAX_ADMIN_REASON_LENGTH: int = 80
const MAX_QUEUED_SNAPSHOTS: int = 2
const MAX_QUEUED_REQUESTS: int = MAX_REMOTE_CLIENTS * 4
const MAX_QUEUED_RECONCILIATIONS: int = 2
const SNAPSHOT_CHANNEL: int = 0
const RECONCILIATION_CHANNEL: int = 1
const REQUEST_EMOTE: int = 1
const REQUEST_TRAINING_RESET: int = 2
const REQUEST_CHAMPION_NEXT: int = 3
const REQUEST_READY_TOGGLE: int = 4
const REQUEST_PRACTICE_START: int = 5
const REQUEST_SPELL_EQUIP: int = 6
# Twelve weave positions x the stable primary/active-one/active-two role lanes.
const MAX_SPELL_EQUIP_VALUE: int = PlayerState.SPELL_SLOT_COUNT * 3

var peer: ENetMultiplayerPeer
var mode: int = Mode.OFFLINE
var bound_port: int = 0
var join_address: String = ""
var session_signature: String = ""
var session_charter_id: String = ""
var session_charter_hash: String = ""
var maximum_players: int = MAX_PLAYERS
var player_name: String = "Traveller"
var last_error: String = ""
var status_detail: String = "Offline"
var accepted: bool = false
var local_peer_id: int = 0
var local_entity_id: int = 0
var accepted_peer_ids := PackedInt32Array()
var incoming_inputs: Array[Dictionary] = []
var incoming_snapshots: Array[Dictionary] = []
var incoming_requests: Array[Dictionary] = []
var incoming_reconciliations: Array[Dictionary] = []
var joined_peers: Array[Dictionary] = []
var disconnected_peers: Array[Dictionary] = []
var last_input_sequence_by_peer: Dictionary[int, int] = {}
var last_request_sequence_by_peer: Dictionary[int, int] = {}
var entity_by_peer: Dictionary[int, int] = {}
var name_by_peer: Dictionary[int, String] = {}
var reconnect_token_by_peer: Dictionary[int, String] = {}
var reconnect_reservations: Dictionary[String, Dictionary] = {}
var administrative_disconnect_reason_by_peer: Dictionary[int, String] = {}
var administrative_disconnect_deadline_by_peer: Dictionary[int, int] = {}
var reconnect_token: String = ""
var reconnect_address: String = ""
var reconnect_port: int = 0
var reconnect_signature: String = ""
var _hello_sent: bool = false
var _connect_started_ms: int = 0


static func compatibility_signature(
	protocol_version: int,
	tick_rate: int,
	map_hash: String,
	ability_hash: String,
	champion_hash: String,
	charter_catalog_hash: String = "",
) -> String:
	return CanonicalContent.sha256({
		"protocol_version": protocol_version,
		"tick_rate": tick_rate,
		"movement_hash": MovementTuning.compatibility_hash(),
		"map_hash": map_hash,
		"ability_hash": ability_hash,
		"champion_hash": champion_hash,
		"charter_catalog_hash": charter_catalog_hash,
	})


func start_host(
	port: int,
	signature: String,
	requested_player_name: String = "Host",
	requested_charter_id: String = SessionCharter.DEFAULT_ID,
	requested_charter_hash: String = "",
) -> bool:
	last_error = ""
	if not _valid_port(port, true):
		return _fail("Host port must be 0 for automatic testing or 1024-65535")
	if not _valid_signature(signature):
		return _fail("Session compatibility signature must be 64 lowercase hexadecimal characters")
	var safe_name := _validated_player_name(requested_player_name)
	if safe_name.is_empty():
		return _fail("Player name must contain 1-24 safe characters")
	var charter_hash := requested_charter_hash if not requested_charter_hash.is_empty() else SessionCharter.profile_hash(requested_charter_id)
	if not SessionCharter.validate_assignment(requested_charter_id, charter_hash):
		return _fail("Host session charter is invalid")
	var charter_capacity := SessionCharter.maximum_players(requested_charter_id)
	if charter_capacity < 2 or charter_capacity > MAX_PLAYERS:
		return _fail("Host session charter capacity is invalid")
	stop()
	var candidate := ENetMultiplayerPeer.new()
	# Keep the physical transport ceiling at eight so a charter-full client can
	# complete the guarded hello and receive an explicit refusal.
	var error: Error = candidate.create_server(port, MAX_REMOTE_CLIENTS)
	if error != OK:
		return _fail("Could not host UDP port %d (error %d)" % [port, error])
	peer = candidate
	peer.transfer_mode = MultiplayerPeer.TRANSFER_MODE_RELIABLE
	peer.peer_disconnected.connect(_on_peer_disconnected)
	mode = Mode.HOSTING
	session_signature = signature
	session_charter_id = requested_charter_id
	session_charter_hash = charter_hash
	maximum_players = charter_capacity
	player_name = safe_name
	bound_port = peer.host.get_local_port()
	local_peer_id = SERVER_PEER_ID
	local_entity_id = SERVER_PEER_ID
	accepted = true
	accepted_peer_ids = PackedInt32Array()
	status_detail = _host_status()
	return true


func start_join(
	address: String,
	port: int,
	signature: String,
	requested_player_name: String = "Traveller",
	requested_charter_catalog_hash: String = "",
) -> bool:
	last_error = ""
	var safe_address := address.strip_edges()
	if not _valid_address(safe_address):
		return _fail("Join address must be a valid IPv4, IPv6 or host name")
	if not _valid_port(port, false):
		return _fail("Join port must be 1024-65535")
	if not _valid_signature(signature):
		return _fail("Session compatibility signature must be 64 lowercase hexadecimal characters")
	var safe_name := _validated_player_name(requested_player_name)
	if safe_name.is_empty():
		return _fail("Player name must contain 1-24 safe characters")
	var charter_catalog_hash := requested_charter_catalog_hash if not requested_charter_catalog_hash.is_empty() else SessionCharter.catalog_hash()
	if charter_catalog_hash.length() != 64:
		return _fail("Join session charter catalog identity is invalid")
	stop()
	var candidate := ENetMultiplayerPeer.new()
	var error: Error = candidate.create_client(safe_address, port)
	if error != OK:
		return _fail("Could not begin joining %s:%d (error %d)" % [safe_address, port, error])
	peer = candidate
	peer.transfer_mode = MultiplayerPeer.TRANSFER_MODE_RELIABLE
	mode = Mode.CONNECTING
	session_signature = signature
	session_charter_id = ""
	session_charter_hash = charter_catalog_hash
	maximum_players = MAX_PLAYERS
	player_name = safe_name
	join_address = safe_address
	bound_port = port
	accepted = false
	local_peer_id = 0
	local_entity_id = 0
	_hello_sent = false
	_connect_started_ms = Time.get_ticks_msec()
	status_detail = "%s %s:%d" % ["Returning to" if not _reconnect_token_for_current_endpoint().is_empty() else "Seeking", join_address, bound_port]
	return true


func poll() -> void:
	if peer == null:
		return
	if is_host():
		_expire_reconnect_reservations(Time.get_ticks_msec())
	peer.poll()
	if is_host():
		_force_due_administrative_disconnects(Time.get_ticks_msec())
	if mode == Mode.CLIENT and peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		_disconnect_with_error("Host left the session")
		return
	if mode == Mode.CONNECTING:
		var connection_status: int = peer.get_connection_status()
		if connection_status == MultiplayerPeer.CONNECTION_CONNECTED and not _hello_sent:
			local_peer_id = peer.get_unique_id()
			_send_to(SERVER_PEER_ID, {
				"kind": PACKET_HELLO,
				"signature": session_signature,
				"name": player_name,
				"reconnect_token": _reconnect_token_for_current_endpoint(),
				"charter_catalog_hash": session_charter_hash,
			})
			_hello_sent = true
			status_detail = "Verifying session"
		elif connection_status == MultiplayerPeer.CONNECTION_DISCONNECTED:
			_disconnect_with_error("Host could not be reached")
			return
		elif Time.get_ticks_msec() - _connect_started_ms > CONNECT_TIMEOUT_MS:
			_disconnect_with_error("Join timed out")
			return
	var packets_processed: int = 0
	while peer != null and peer.get_available_packet_count() > 0 and packets_processed < MAX_PACKETS_PER_POLL:
		var sender_id: int = peer.get_packet_peer()
		var packet_bytes: PackedByteArray = peer.get_packet()
		_handle_packet(sender_id, packet_bytes)
		packets_processed += 1
		if peer == null:
			break


func stop() -> void:
	_close_peer()
	last_error = ""
	status_detail = "Offline"


func is_host() -> bool:
	return mode == Mode.HOSTING


func is_connected_client() -> bool:
	return mode == Mode.CLIENT and accepted


func is_online() -> bool:
	return is_host() or is_connected_client()


func player_count() -> int:
	if is_host():
		return 1 + accepted_peer_ids.size()
	if is_connected_client():
		return 2
	return 1


func player_capacity() -> int:
	return maximum_players


func reserved_count() -> int:
	return reconnect_reservations.size() if is_host() else 0


func can_reconnect() -> bool:
	return _valid_reconnect_token(reconnect_token) and not reconnect_address.is_empty() and reconnect_port > 0 and _valid_signature(reconnect_signature)


func send_input(sequence: int, command: SimCommand) -> bool:
	if not is_connected_client():
		return false
	var payload := {
		"kind": PACKET_INPUT,
		"sequence": sequence,
		"move_x": command.move_x,
		"move_y": command.move_y,
		"held": command.held_actions,
		"pressed": command.pressed_actions,
		"aim_x": command.aim_x,
		"aim_y": command.aim_y,
	}
	if not _valid_input_packet(payload):
		return false
	return _send_to(SERVER_PEER_ID, payload)


func send_request(sequence: int, action: int, value: int = 0) -> bool:
	if not is_connected_client():
		return false
	var payload := {"kind": PACKET_REQUEST, "sequence": sequence, "action": action, "value": value}
	if not _valid_request_packet(payload):
		return false
	return _send_to(SERVER_PEER_ID, payload)


func take_inputs() -> Array[Dictionary]:
	var result: Array[Dictionary] = incoming_inputs
	incoming_inputs = []
	return result


func take_requests() -> Array[Dictionary]:
	var result: Array[Dictionary] = incoming_requests
	incoming_requests = []
	return result


func send_reconciliation(peer_id: int, reconciliation: Dictionary) -> bool:
	if not is_host() or not accepted_peer_ids.has(peer_id) or not ClientPrediction.validate_packet(reconciliation):
		return false
	var values: PackedInt64Array = reconciliation["values"]
	if values[0] != int(entity_by_peer.get(peer_id, 0)):
		return false
	return _send_to(
		peer_id,
		{"kind": PACKET_RECONCILIATION, "reconciliation": reconciliation},
		MultiplayerPeer.TRANSFER_MODE_UNRELIABLE_ORDERED,
		RECONCILIATION_CHANNEL,
	)


func take_reconciliations() -> Array[Dictionary]:
	var result: Array[Dictionary] = incoming_reconciliations
	incoming_reconciliations = []
	return result


func take_joined_peers() -> Array[Dictionary]:
	var result: Array[Dictionary] = joined_peers
	joined_peers = []
	return result


func take_disconnected_peers() -> Array[Dictionary]:
	var result: Array[Dictionary] = disconnected_peers
	disconnected_peers = []
	return result


func host_roster() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not is_host():
		return result
	for peer_id: int in accepted_peer_ids:
		result.append({
			"peer_id": peer_id,
			"entity_id": int(entity_by_peer.get(peer_id, 0)),
			"name": String(name_by_peer.get(peer_id, "Traveller")),
		})
	result.sort_custom(func(left: Dictionary, right: Dictionary) -> bool: return int(left["entity_id"]) < int(right["entity_id"]))
	return result


func host_session_roster() -> Array[Dictionary]:
	var result := host_roster()
	if not is_host():
		return result
	for reservation: Dictionary in reconnect_reservations.values():
		result.append({
			"peer_id": 0,
			"entity_id": int(reservation.get("entity_id", 0)),
			"name": String(reservation.get("name", "Traveller")),
			"reserved": true,
		})
	result.sort_custom(func(left: Dictionary, right: Dictionary) -> bool: return int(left["entity_id"]) < int(right["entity_id"]))
	return result


func host_remove_entity(entity_id: int, requested_reason: String) -> bool:
	if not is_host() or entity_id < 2 or entity_id > MAX_PLAYERS:
		return false
	var reason := _validated_administration_reason(requested_reason)
	if reason.is_empty():
		return false
	var target_peer_id: int = 0
	for peer_id: int in accepted_peer_ids:
		if int(entity_by_peer.get(peer_id, 0)) == entity_id:
			target_peer_id = peer_id
			break
	if target_peer_id <= SERVER_PEER_ID:
		return false
	administrative_disconnect_reason_by_peer[target_peer_id] = reason
	administrative_disconnect_deadline_by_peer[target_peer_id] = Time.get_ticks_msec() + ADMIN_DISCONNECT_GRACE_MS
	if not _send_to(target_peer_id, {"kind": PACKET_ADMIN_CLOSE, "reason": reason}):
		administrative_disconnect_reason_by_peer.erase(target_peer_id)
		administrative_disconnect_deadline_by_peer.erase(target_peer_id)
		return false
	# Cooperative clients close on receipt. Poll enforces the same removal after
	# a short bounded grace if a modified client ignores the reliable notice.
	return true


func broadcast_snapshot(snapshot: Dictionary) -> bool:
	if not is_host() or not SessionSnapshot.validate(snapshot):
		return false
	var packet := _snapshot_wire_packet(snapshot)
	if packet.is_empty():
		return false
	var all_sent: bool = true
	for peer_id: int in accepted_peer_ids:
		all_sent = _send_to(peer_id, packet, MultiplayerPeer.TRANSFER_MODE_UNRELIABLE_ORDERED, SNAPSHOT_CHANNEL) and all_sent
	return all_sent


func take_snapshots() -> Array[Dictionary]:
	var result: Array[Dictionary] = incoming_snapshots
	incoming_snapshots = []
	return result


func _handle_packet(sender_id: int, packet_bytes: PackedByteArray) -> void:
	if packet_bytes.is_empty() or packet_bytes.size() > MAX_PACKET_BYTES:
		return
	var decoded: Variant = bytes_to_var(packet_bytes)
	if not decoded is Dictionary:
		return
	var packet: Dictionary = decoded
	var kind: int = int(packet.get("kind", 0))
	if is_host():
		match kind:
			PACKET_HELLO:
				_handle_hello(sender_id, packet)
			PACKET_INPUT:
				var sequence: int = int(packet.get("sequence", -1))
				var previous_sequence: int = last_input_sequence_by_peer.get(sender_id, -1)
				if (
					accepted_peer_ids.has(sender_id)
					and _valid_input_packet(packet)
					and sequence > previous_sequence
					and incoming_inputs.size() < MAX_QUEUED_INPUTS
				):
					var accepted_input: Dictionary = packet.duplicate(true)
					accepted_input["peer_id"] = sender_id
					accepted_input["entity_id"] = int(entity_by_peer.get(sender_id, 0))
					incoming_inputs.append(accepted_input)
					last_input_sequence_by_peer[sender_id] = sequence
			PACKET_REQUEST:
				var sequence: int = int(packet.get("sequence", -1))
				var previous_sequence: int = last_request_sequence_by_peer.get(sender_id, -1)
				if (
					accepted_peer_ids.has(sender_id)
					and _valid_request_packet(packet)
					and sequence > previous_sequence
					and incoming_requests.size() < MAX_QUEUED_REQUESTS
				):
					incoming_requests.append({
						"peer_id": sender_id,
						"entity_id": int(entity_by_peer.get(sender_id, 0)),
						"sequence": sequence,
						"action": int(packet["action"]),
						"value": int(packet["value"]),
					})
					last_request_sequence_by_peer[sender_id] = sequence
		return
	if sender_id != SERVER_PEER_ID:
		return
	if mode == Mode.CONNECTING:
		match kind:
			PACKET_ACCEPT:
				var assigned_entity_id: int = int(packet.get("entity_id", 0))
				if assigned_entity_id < 2 or assigned_entity_id > MAX_PLAYERS:
					_disconnect_with_error("Host assigned an invalid traveller identity")
					return
				var assigned_charter_id := String(packet.get("charter_id", ""))
				var assigned_charter_hash := String(packet.get("charter_hash", ""))
				var assigned_maximum_players := int(packet.get("maximum_players", 0))
				if (
					not SessionCharter.validate_assignment(assigned_charter_id, assigned_charter_hash)
					or assigned_maximum_players != SessionCharter.maximum_players(assigned_charter_id)
				):
					_disconnect_with_error("Host assigned an invalid session charter")
					return
				session_charter_id = assigned_charter_id
				session_charter_hash = assigned_charter_hash
				maximum_players = assigned_maximum_players
				local_entity_id = assigned_entity_id
				var assigned_reconnect_token := String(packet.get("reconnect_token", ""))
				if not _valid_reconnect_token(assigned_reconnect_token):
					_disconnect_with_error("Host assigned an invalid return token")
					return
				reconnect_token = assigned_reconnect_token
				reconnect_address = join_address
				reconnect_port = bound_port
				reconnect_signature = session_signature
				accepted = true
				mode = Mode.CLIENT
				status_detail = "Joined %s · %s · %d places" % [join_address, SessionCharter.display_name(session_charter_id), maximum_players]
			PACKET_REJECT:
				_disconnect_with_error(String(packet.get("reason", "Join refused")).left(80))
		return
	if mode == Mode.CLIENT:
		if kind == PACKET_ADMIN_CLOSE:
			var administration_reason := _validated_administration_reason(String(packet.get("reason", "")))
			if administration_reason.is_empty():
				return
			_clear_return_path()
			_disconnect_with_error(administration_reason)
			return
		if kind == PACKET_SNAPSHOT:
			var snapshot := _snapshot_from_wire_packet(packet)
			if not snapshot.is_empty():
				if incoming_snapshots.is_empty() or int(snapshot["tick"]) > int(incoming_snapshots.back()["tick"]):
					incoming_snapshots.append(snapshot)
					while incoming_snapshots.size() > MAX_QUEUED_SNAPSHOTS:
						incoming_snapshots.pop_front()
		elif kind == PACKET_RECONCILIATION:
			var reconciliation_value: Variant = packet.get("reconciliation")
			if reconciliation_value is Dictionary and ClientPrediction.validate_packet(reconciliation_value):
				var reconciliation: Dictionary = reconciliation_value
				var values: PackedInt64Array = reconciliation["values"]
				if values[0] == local_entity_id and (incoming_reconciliations.is_empty() or int(reconciliation["tick"]) > int(incoming_reconciliations.back()["tick"])):
					incoming_reconciliations.append(reconciliation)
					while incoming_reconciliations.size() > MAX_QUEUED_RECONCILIATIONS:
						incoming_reconciliations.pop_front()


func _handle_hello(sender_id: int, packet: Dictionary) -> void:
	if sender_id <= SERVER_PEER_ID or accepted_peer_ids.has(sender_id):
		return
	if String(packet.get("signature", "")) != session_signature:
		_send_to(sender_id, {"kind": PACKET_REJECT, "reason": "Incompatible build or session rules"})
		return
	if String(packet.get("charter_catalog_hash", "")) != SessionCharter.catalog_hash():
		_send_to(sender_id, {"kind": PACKET_REJECT, "reason": "Incompatible session charter catalog"})
		return
	var safe_name := _validated_player_name(String(packet.get("name", "")))
	if safe_name.is_empty():
		_send_to(sender_id, {"kind": PACKET_REJECT, "reason": "Invalid traveller name"})
		return
	var requested_reconnect_token := String(packet.get("reconnect_token", ""))
	var resumed: bool = false
	var entity_id: int = 0
	var consumed_reconnect_token: String = ""
	if not requested_reconnect_token.is_empty():
		if not _valid_reconnect_token(requested_reconnect_token) or not reconnect_reservations.has(requested_reconnect_token):
			_send_to(sender_id, {"kind": PACKET_REJECT, "reason": "Return token expired or is invalid"})
			return
		var reservation: Dictionary = reconnect_reservations[requested_reconnect_token]
		if String(reservation.get("name", "")) != safe_name:
			_send_to(sender_id, {"kind": PACKET_REJECT, "reason": "Return token does not match traveller name"})
			return
		entity_id = int(reservation.get("entity_id", 0))
		consumed_reconnect_token = requested_reconnect_token
		resumed = true
	else:
		if accepted_peer_ids.size() + reconnect_reservations.size() >= maximum_players - 1:
			_send_to(sender_id, {"kind": PACKET_REJECT, "reason": "Session is full"})
			return
		entity_id = _allocate_entity_id()
	if entity_id == 0:
		_send_to(sender_id, {"kind": PACKET_REJECT, "reason": "Session roster is full"})
		return
	var rotated_reconnect_token := _new_reconnect_token()
	if rotated_reconnect_token.is_empty():
		_send_to(sender_id, {"kind": PACKET_REJECT, "reason": "Host could not reserve a secure return path"})
		return
	if resumed:
		reconnect_reservations.erase(consumed_reconnect_token)
	accepted_peer_ids.append(sender_id)
	accepted_peer_ids.sort()
	entity_by_peer[sender_id] = entity_id
	name_by_peer[sender_id] = safe_name
	reconnect_token_by_peer[sender_id] = rotated_reconnect_token
	last_input_sequence_by_peer[sender_id] = -1
	last_request_sequence_by_peer[sender_id] = -1
	joined_peers.append({"peer_id": sender_id, "entity_id": entity_id, "name": safe_name, "resumed": resumed})
	_send_to(sender_id, {
		"kind": PACKET_ACCEPT,
		"peer_id": sender_id,
		"entity_id": entity_id,
		"player_count": player_count(),
		"reconnect_token": rotated_reconnect_token,
		"resumed": resumed,
		"charter_id": session_charter_id,
		"charter_hash": session_charter_hash,
		"maximum_players": maximum_players,
	})
	status_detail = _host_status()


func _send_to(
	target_peer_id: int,
	packet: Dictionary,
	transfer_mode: int = MultiplayerPeer.TRANSFER_MODE_RELIABLE,
	transfer_channel: int = 0,
) -> bool:
	if peer == null:
		return false
	var encoded: PackedByteArray = var_to_bytes(packet)
	if encoded.is_empty() or encoded.size() > MAX_PACKET_BYTES:
		return false
	peer.set_target_peer(target_peer_id)
	peer.transfer_mode = transfer_mode
	peer.transfer_channel = transfer_channel
	return peer.put_packet(encoded) == OK


static func _snapshot_wire_packet(snapshot: Dictionary) -> Dictionary:
	if not SessionSnapshot.validate(snapshot):
		return {}
	var raw := var_to_bytes(snapshot)
	if raw.is_empty() or raw.size() > MAX_SNAPSHOT_UNCOMPRESSED_BYTES:
		return {}
	var compressed := raw.compress(FileAccess.COMPRESSION_FASTLZ)
	if compressed.is_empty():
		return {}
	var packet := {
		"kind": PACKET_SNAPSHOT,
		"raw_size": raw.size(),
		"payload": compressed,
	}
	return packet if var_to_bytes(packet).size() <= ENET_MTU_BYTES else {}


static func _snapshot_from_wire_packet(packet: Dictionary) -> Dictionary:
	if typeof(packet.get("kind")) != TYPE_INT or int(packet["kind"]) != PACKET_SNAPSHOT or typeof(packet.get("raw_size")) != TYPE_INT:
		return {}
	var raw_size := int(packet["raw_size"])
	var payload_value: Variant = packet.get("payload")
	if (
		raw_size < 1
		or raw_size > MAX_SNAPSHOT_UNCOMPRESSED_BYTES
		or typeof(payload_value) != TYPE_PACKED_BYTE_ARRAY
	):
		return {}
	var payload: PackedByteArray = payload_value
	if payload.is_empty() or payload.size() > MAX_PACKET_BYTES:
		return {}
	var raw := payload.decompress(raw_size, FileAccess.COMPRESSION_FASTLZ)
	if raw.size() != raw_size:
		return {}
	var decoded: Variant = bytes_to_var(raw)
	if not decoded is Dictionary or not SessionSnapshot.validate(decoded):
		return {}
	return decoded


func _on_peer_disconnected(peer_id: int) -> void:
	if is_host():
		var entity_id: int = entity_by_peer.get(peer_id, 0)
		var disconnected_name: String = name_by_peer.get(peer_id, "Traveller")
		var return_token: String = reconnect_token_by_peer.get(peer_id, "")
		var administration_reason: String = administrative_disconnect_reason_by_peer.get(peer_id, "")
		var index: int = accepted_peer_ids.find(peer_id)
		if index >= 0:
			accepted_peer_ids.remove_at(index)
		if entity_id > 0 and not administration_reason.is_empty():
			disconnected_peers.append({
				"peer_id": peer_id,
				"entity_id": entity_id,
				"name": disconnected_name,
				"reserved": false,
				"administrative": true,
				"reason": administration_reason,
			})
		elif entity_id > 0 and _valid_reconnect_token(return_token):
			reconnect_reservations[return_token] = {
				"entity_id": entity_id,
				"name": disconnected_name,
				"expires_ms": Time.get_ticks_msec() + RECONNECT_WINDOW_MS,
			}
			disconnected_peers.append({"peer_id": peer_id, "entity_id": entity_id, "name": disconnected_name, "reserved": true})
		elif entity_id > 0:
			disconnected_peers.append({"peer_id": peer_id, "entity_id": entity_id, "name": disconnected_name, "reserved": false})
		last_input_sequence_by_peer.erase(peer_id)
		last_request_sequence_by_peer.erase(peer_id)
		entity_by_peer.erase(peer_id)
		name_by_peer.erase(peer_id)
		reconnect_token_by_peer.erase(peer_id)
		administrative_disconnect_reason_by_peer.erase(peer_id)
		administrative_disconnect_deadline_by_peer.erase(peer_id)
		status_detail = _host_status()
	elif peer_id == SERVER_PEER_ID:
		_disconnect_with_error("Host left the session")


func _disconnect_with_error(message: String) -> void:
	_close_peer()
	last_error = message
	status_detail = message


func _close_peer() -> void:
	if peer != null:
		peer.close()
	peer = null
	mode = Mode.OFFLINE
	bound_port = 0
	join_address = ""
	session_signature = ""
	session_charter_id = ""
	session_charter_hash = ""
	maximum_players = MAX_PLAYERS
	accepted = false
	local_peer_id = 0
	local_entity_id = 0
	accepted_peer_ids = PackedInt32Array()
	incoming_inputs = []
	incoming_snapshots = []
	incoming_requests = []
	incoming_reconciliations = []
	joined_peers = []
	disconnected_peers = []
	last_input_sequence_by_peer = {}
	last_request_sequence_by_peer = {}
	entity_by_peer = {}
	name_by_peer = {}
	reconnect_token_by_peer = {}
	reconnect_reservations = {}
	administrative_disconnect_reason_by_peer = {}
	administrative_disconnect_deadline_by_peer = {}
	_hello_sent = false
	_connect_started_ms = 0


func _fail(message: String) -> bool:
	last_error = message
	status_detail = message
	return false


func _allocate_entity_id() -> int:
	var used: Dictionary[int, bool] = {SERVER_PEER_ID: true}
	for entity_id: int in entity_by_peer.values():
		used[entity_id] = true
	for reservation: Dictionary in reconnect_reservations.values():
		used[int(reservation.get("entity_id", 0))] = true
	for candidate: int in range(2, MAX_PLAYERS + 1):
		if not used.has(candidate):
			return candidate
	return 0


func _expire_reconnect_reservations(now_ms: int) -> int:
	if not is_host():
		return 0
	var expired_tokens: Array[String] = []
	for return_token: String in reconnect_reservations:
		var reservation: Dictionary = reconnect_reservations[return_token]
		if now_ms >= int(reservation.get("expires_ms", 0)):
			expired_tokens.append(return_token)
	for return_token: String in expired_tokens:
		var reservation: Dictionary = reconnect_reservations[return_token]
		disconnected_peers.append({
			"peer_id": 0,
			"entity_id": int(reservation.get("entity_id", 0)),
			"name": String(reservation.get("name", "Traveller")),
			"reserved": false,
			"expired": true,
		})
		reconnect_reservations.erase(return_token)
	if not expired_tokens.is_empty():
		status_detail = _host_status()
	return expired_tokens.size()


func _force_due_administrative_disconnects(now_ms: int) -> int:
	if not is_host() or peer == null:
		return 0
	var due_peer_ids: Array[int] = []
	for peer_id: int in administrative_disconnect_deadline_by_peer:
		if now_ms >= int(administrative_disconnect_deadline_by_peer[peer_id]):
			due_peer_ids.append(peer_id)
	due_peer_ids.sort()
	for peer_id: int in due_peer_ids:
		administrative_disconnect_deadline_by_peer.erase(peer_id)
		if accepted_peer_ids.has(peer_id):
			peer.disconnect_peer(peer_id, true)
			# Some ENet backends defer the disconnect signal until the remote
			# endpoint polls. Host authority must not depend on client cooperation.
			if accepted_peer_ids.has(peer_id):
				_on_peer_disconnected(peer_id)
	return due_peer_ids.size()


func _reconnect_token_for_current_endpoint() -> String:
	if (
		_valid_reconnect_token(reconnect_token)
		and reconnect_address == join_address
		and reconnect_port == bound_port
		and reconnect_signature == session_signature
	):
		return reconnect_token
	return ""


func _host_status() -> String:
	var returns := reconnect_reservations.size()
	return "Hosting %d/%d on UDP %d" % [player_count(), maximum_players, bound_port] if returns == 0 else "Hosting %d/%d + %d returning on UDP %d" % [player_count(), maximum_players, returns, bound_port]


static func _valid_reconnect_token(token: String) -> bool:
	if token.length() != RECONNECT_TOKEN_BYTES * 2:
		return false
	for character: String in token:
		if character not in "0123456789abcdef":
			return false
	return true


static func _new_reconnect_token() -> String:
	var bytes := Crypto.new().generate_random_bytes(RECONNECT_TOKEN_BYTES)
	var token := bytes.hex_encode()
	return token if _valid_reconnect_token(token) else ""


func _clear_return_path() -> void:
	reconnect_token = ""
	reconnect_address = ""
	reconnect_port = 0
	reconnect_signature = ""


static func _validated_administration_reason(requested_reason: String) -> String:
	var reason := requested_reason.strip_edges()
	if reason.is_empty() or reason.length() > MAX_ADMIN_REASON_LENGTH:
		return ""
	for character: String in reason:
		if character.unicode_at(0) < 32:
			return ""
	return reason


static func _valid_port(port: int, allow_automatic: bool) -> bool:
	return (allow_automatic and port == 0) or (port >= 1024 and port <= 65_535)


static func _valid_signature(signature: String) -> bool:
	if signature.length() != 64:
		return false
	for character: String in signature:
		if character not in "0123456789abcdef":
			return false
	return true


static func _valid_address(address: String) -> bool:
	if address.is_empty() or address.length() > 255:
		return false
	for character: String in address:
		if character.unicode_at(0) <= 32 or character in "/\\":
			return false
	return true


static func _validated_player_name(requested_name: String) -> String:
	var safe_name := requested_name.strip_edges()
	if safe_name.is_empty() or safe_name.length() > MAX_PLAYER_NAME_LENGTH:
		return ""
	for character: String in safe_name:
		var codepoint: int = character.unicode_at(0)
		if codepoint < 32 or codepoint == 127:
			return ""
	return safe_name


static func _valid_input_packet(packet: Dictionary) -> bool:
	for key: String in ["sequence", "move_x", "move_y", "aim_x", "aim_y", "held", "pressed"]:
		if not packet.has(key) or typeof(packet[key]) != TYPE_INT:
			return false
	if int(packet["sequence"]) < 0 or int(packet["sequence"]) > 0x7fffffff:
		return false
	for key: String in ["move_x", "move_y", "aim_x", "aim_y"]:
		var value: int = int(packet[key])
		if value < -1000 or value > 1000:
			return false
	var held: int = int(packet["held"])
	var pressed: int = int(packet["pressed"])
	return held >= 0 and held <= 0xffff and pressed >= 0 and pressed <= 0xffff


static func _valid_request_packet(packet: Dictionary) -> bool:
	if typeof(packet.get("sequence")) != TYPE_INT or typeof(packet.get("action")) != TYPE_INT or typeof(packet.get("value")) != TYPE_INT:
		return false
	var sequence := int(packet["sequence"])
	var action := int(packet["action"])
	var value := int(packet["value"])
	if sequence < 0 or sequence > 0x7fffffff:
		return false
	if action == REQUEST_SPELL_EQUIP:
		return value >= 1 and value <= MAX_SPELL_EQUIP_VALUE
	return value == 0 and action in [REQUEST_EMOTE, REQUEST_TRAINING_RESET, REQUEST_CHAMPION_NEXT, REQUEST_READY_TOGGLE, REQUEST_PRACTICE_START]
