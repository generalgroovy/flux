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
const MAX_PACKETS_PER_POLL: int = 64
const MAX_QUEUED_INPUTS: int = MAX_REMOTE_CLIENTS * 4
const MAX_PLAYER_NAME_LENGTH: int = 24
const CONNECT_TIMEOUT_MS: int = 5_000
const SERVER_PEER_ID: int = 1

const PACKET_HELLO: int = 1
const PACKET_ACCEPT: int = 2
const PACKET_REJECT: int = 3
const PACKET_INPUT: int = 4

var peer: ENetMultiplayerPeer
var mode: int = Mode.OFFLINE
var bound_port: int = 0
var join_address: String = ""
var session_signature: String = ""
var player_name: String = "Traveller"
var last_error: String = ""
var status_detail: String = "Offline"
var accepted: bool = false
var local_peer_id: int = 0
var accepted_peer_ids := PackedInt32Array()
var incoming_inputs: Array[Dictionary] = []
var last_input_sequence_by_peer: Dictionary[int, int] = {}
var _hello_sent: bool = false
var _connect_started_ms: int = 0


static func compatibility_signature(
	protocol_version: int,
	tick_rate: int,
	map_hash: String,
	ability_hash: String,
	champion_hash: String,
) -> String:
	return CanonicalContent.sha256({
		"protocol_version": protocol_version,
		"tick_rate": tick_rate,
		"map_hash": map_hash,
		"ability_hash": ability_hash,
		"champion_hash": champion_hash,
	})


func start_host(port: int, signature: String, requested_player_name: String = "Host") -> bool:
	last_error = ""
	if not _valid_port(port, true):
		return _fail("Host port must be 0 for automatic testing or 1024-65535")
	if not _valid_signature(signature):
		return _fail("Session compatibility signature must be 64 lowercase hexadecimal characters")
	var safe_name := _validated_player_name(requested_player_name)
	if safe_name.is_empty():
		return _fail("Player name must contain 1-24 safe characters")
	stop()
	var candidate := ENetMultiplayerPeer.new()
	var error: Error = candidate.create_server(port, MAX_REMOTE_CLIENTS)
	if error != OK:
		return _fail("Could not host UDP port %d (error %d)" % [port, error])
	peer = candidate
	peer.transfer_mode = MultiplayerPeer.TRANSFER_MODE_RELIABLE
	peer.peer_disconnected.connect(_on_peer_disconnected)
	mode = Mode.HOSTING
	session_signature = signature
	player_name = safe_name
	bound_port = peer.host.get_local_port()
	local_peer_id = SERVER_PEER_ID
	accepted = true
	accepted_peer_ids = PackedInt32Array()
	status_detail = "Hosting %d/8 on UDP %d" % [player_count(), bound_port]
	return true


func start_join(address: String, port: int, signature: String, requested_player_name: String = "Traveller") -> bool:
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
	stop()
	var candidate := ENetMultiplayerPeer.new()
	var error: Error = candidate.create_client(safe_address, port)
	if error != OK:
		return _fail("Could not begin joining %s:%d (error %d)" % [safe_address, port, error])
	peer = candidate
	peer.transfer_mode = MultiplayerPeer.TRANSFER_MODE_RELIABLE
	mode = Mode.CONNECTING
	session_signature = signature
	player_name = safe_name
	join_address = safe_address
	bound_port = port
	accepted = false
	local_peer_id = 0
	_hello_sent = false
	_connect_started_ms = Time.get_ticks_msec()
	status_detail = "Seeking %s:%d" % [join_address, bound_port]
	return true


func poll() -> void:
	if peer == null:
		return
	peer.poll()
	if mode == Mode.CONNECTING:
		var connection_status: int = peer.get_connection_status()
		if connection_status == MultiplayerPeer.CONNECTION_CONNECTED and not _hello_sent:
			local_peer_id = peer.get_unique_id()
			_send_to(SERVER_PEER_ID, {
				"kind": PACKET_HELLO,
				"signature": session_signature,
				"name": player_name,
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


func take_inputs() -> Array[Dictionary]:
	var result: Array[Dictionary] = incoming_inputs
	incoming_inputs = []
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
					incoming_inputs.append(accepted_input)
					last_input_sequence_by_peer[sender_id] = sequence
		return
	if sender_id != SERVER_PEER_ID or mode != Mode.CONNECTING:
		return
	match kind:
		PACKET_ACCEPT:
			accepted = true
			mode = Mode.CLIENT
			status_detail = "Joined %s:%d" % [join_address, bound_port]
		PACKET_REJECT:
			_disconnect_with_error(String(packet.get("reason", "Join refused")).left(80))


func _handle_hello(sender_id: int, packet: Dictionary) -> void:
	if sender_id <= SERVER_PEER_ID or accepted_peer_ids.has(sender_id):
		return
	if String(packet.get("signature", "")) != session_signature:
		_send_to(sender_id, {"kind": PACKET_REJECT, "reason": "Incompatible build or session rules"})
		return
	if accepted_peer_ids.size() >= MAX_REMOTE_CLIENTS:
		_send_to(sender_id, {"kind": PACKET_REJECT, "reason": "Session is full"})
		return
	var safe_name := _validated_player_name(String(packet.get("name", "")))
	if safe_name.is_empty():
		_send_to(sender_id, {"kind": PACKET_REJECT, "reason": "Invalid traveller name"})
		return
	accepted_peer_ids.append(sender_id)
	accepted_peer_ids.sort()
	last_input_sequence_by_peer[sender_id] = -1
	_send_to(sender_id, {
		"kind": PACKET_ACCEPT,
		"peer_id": sender_id,
		"player_count": player_count(),
	})
	status_detail = "Hosting %d/8 on UDP %d" % [player_count(), bound_port]


func _send_to(target_peer_id: int, packet: Dictionary) -> bool:
	if peer == null:
		return false
	var encoded: PackedByteArray = var_to_bytes(packet)
	if encoded.is_empty() or encoded.size() > MAX_PACKET_BYTES:
		return false
	peer.set_target_peer(target_peer_id)
	return peer.put_packet(encoded) == OK


func _on_peer_disconnected(peer_id: int) -> void:
	if is_host():
		var index: int = accepted_peer_ids.find(peer_id)
		if index >= 0:
			accepted_peer_ids.remove_at(index)
		last_input_sequence_by_peer.erase(peer_id)
		status_detail = "Hosting %d/8 on UDP %d" % [player_count(), bound_port]
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
	accepted = false
	local_peer_id = 0
	accepted_peer_ids = PackedInt32Array()
	incoming_inputs = []
	last_input_sequence_by_peer = {}
	_hello_sent = false
	_connect_started_ms = 0


func _fail(message: String) -> bool:
	last_error = message
	status_detail = message
	return false


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
