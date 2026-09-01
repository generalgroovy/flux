class_name LanLobby
extends CanvasLayer


const DISCOVERY_PORT: int = 24_873
const DISCOVERY_MAGIC: String = "FLUX2_LAN_V1"
const BROADCAST_ADDRESS: String = "255.255.255.255"
const BROADCAST_INTERVAL_MS: int = 750
const HOST_STALE_MS: int = 3_500
const MAX_DISCOVERY_PACKET_BYTES: int = 2_048
const MAX_DISCOVERED_HOSTS: int = 24
const MAX_PACKETS_PER_POLL: int = 32

var bootstrap: Node
var listener := PacketPeerUDP.new()
var broadcaster := PacketPeerUDP.new()
var listener_ready: bool = false
var broadcaster_ready: bool = false
var discovery_error: String = ""
var discovered_hosts: Dictionary = {}
var last_broadcast_ms: int = 0
var last_listener_retry_ms: int = 0
var browser_open: bool = false
var host_rows_fingerprint: String = ""

var panel: PanelContainer
var host_button: Button
var join_button: Button
var status_label: Label
var browser_box: VBoxContainer
var browser_status_label: Label
var host_rows: VBoxContainer
var direct_ip_button: Button


func _ready() -> void:
	layer = 80
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(false)
	call_deferred("_initialize")


func _initialize() -> void:
	bootstrap = get_parent()
	_build_ui()
	_open_discovery_listener()
	_prepare_broadcaster()
	set_process(true)


func _exit_tree() -> void:
	listener.close()
	broadcaster.close()


func _process(_delta: float) -> void:
	if bootstrap == null:
		return
	var transport := _transport()
	if transport == null:
		return

	if not listener_ready and Time.get_ticks_msec() - last_listener_retry_ms >= 3_000:
		_open_discovery_listener()
	_poll_discovery_packets()
	_expire_stale_hosts()

	if transport.is_host():
		_maybe_broadcast_host()

	_update_ui()


func _build_ui() -> void:
	panel = PanelContainer.new()
	panel.name = "LanMultiplayerPanel"
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.offset_left = -372.0
	panel.offset_right = -16.0
	panel.offset_top = 16.0
	panel.custom_minimum_size = Vector2(356.0, 0.0)
	add_child(panel)

	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 8)
	panel.add_child(outer)

	var title := Label.new()
	title.text = "FARFLOW · LAN MULTIPLAYER"
	title.add_theme_font_size_override("font_size", 15)
	outer.add_child(title)

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	outer.add_child(actions)

	host_button = Button.new()
	host_button.text = "HOST"
	host_button.custom_minimum_size = Vector2(150.0, 42.0)
	host_button.pressed.connect(_on_host_pressed)
	actions.add_child(host_button)

	join_button = Button.new()
	join_button.text = "JOIN"
	join_button.custom_minimum_size = Vector2(150.0, 42.0)
	join_button.pressed.connect(_on_join_pressed)
	actions.add_child(join_button)

	status_label = Label.new()
	status_label.text = "Offline"
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	outer.add_child(status_label)

	browser_box = VBoxContainer.new()
	browser_box.visible = false
	browser_box.add_theme_constant_override("separation", 6)
	outer.add_child(browser_box)

	var separator := HSeparator.new()
	browser_box.add_child(separator)

	var browser_title := Label.new()
	browser_title.text = "FOUND HOSTS"
	browser_title.add_theme_font_size_override("font_size", 13)
	browser_box.add_child(browser_title)

	browser_status_label = Label.new()
	browser_status_label.text = "Searching local network…"
	browser_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	browser_box.add_child(browser_status_label)

	host_rows = VBoxContainer.new()
	host_rows.add_theme_constant_override("separation", 5)
	browser_box.add_child(host_rows)

	direct_ip_button = Button.new()
	direct_ip_button.text = "Advanced: direct address"
	direct_ip_button.tooltip_text = "Fallback for internet/VPN play or networks that block LAN discovery."
	direct_ip_button.pressed.connect(_on_direct_ip_pressed)
	browser_box.add_child(direct_ip_button)


func _transport() -> SessionTransport:
	if bootstrap == null:
		return null
	return bootstrap.get("session_transport") as SessionTransport


func _on_host_pressed() -> void:
	var transport := _transport()
	if transport == null:
		return
	browser_open = false
	browser_box.visible = false
	bootstrap.call("_toggle_host_session")
	last_broadcast_ms = 0
	_update_ui()


func _on_join_pressed() -> void:
	var transport := _transport()
	if transport == null:
		return
	if transport.is_host():
		browser_open = false
		browser_box.visible = false
		return
	if transport.mode != SessionTransport.Mode.OFFLINE:
		bootstrap.call("_return_to_offline", "You left the Farflow company.")
	browser_open = not browser_open
	browser_box.visible = browser_open
	if browser_open:
		_open_discovery_listener()
		host_rows_fingerprint = ""
		_refresh_host_rows()
	_update_ui()


func _on_direct_ip_pressed() -> void:
	browser_open = false
	browser_box.visible = false
	bootstrap.call("_open_join_address_editor")


func _join_discovered_host(endpoint_key: String) -> void:
	if not discovered_hosts.has(endpoint_key):
		return
	var host: Dictionary = discovered_hosts[endpoint_key]
	if not bool(host.get("compatible", false)):
		return
	var transport := _transport()
	if transport == null:
		return
	if transport.mode != SessionTransport.Mode.OFFLINE:
		bootstrap.call("_return_to_offline", "Switching Farflow company.")
	bootstrap.set("join_address", String(host.get("address", "")))
	bootstrap.set("session_port", int(host.get("port", SessionTransport.DEFAULT_PORT)))
	browser_open = false
	browser_box.visible = false
	bootstrap.call("_start_join_session_now")
	_update_ui()


func _open_discovery_listener() -> void:
	if listener_ready:
		return
	last_listener_retry_ms = Time.get_ticks_msec()
	listener.close()
	listener = PacketPeerUDP.new()
	listener.set_broadcast_enabled(true)
	var error := listener.bind(DISCOVERY_PORT, "0.0.0.0")
	if error == OK:
		listener_ready = true
		discovery_error = ""
	else:
		listener_ready = false
		discovery_error = "LAN discovery unavailable (UDP %d, error %d)." % [DISCOVERY_PORT, error]


func _prepare_broadcaster() -> void:
	broadcaster.close()
	broadcaster = PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	var error := broadcaster.set_dest_address(BROADCAST_ADDRESS, DISCOVERY_PORT)
	broadcaster_ready = error == OK
	if not broadcaster_ready:
		discovery_error = "LAN advertising unavailable (error %d)." % error


func _maybe_broadcast_host() -> void:
	if not broadcaster_ready:
		_prepare_broadcaster()
	if not broadcaster_ready:
		return
	var now := Time.get_ticks_msec()
	if now - last_broadcast_ms < BROADCAST_INTERVAL_MS:
		return
	last_broadcast_ms = now
	var transport := _transport()
	if transport == null or not transport.is_host():
		return
	var signature := String(bootstrap.call("_session_compatibility_signature"))
	var name := String(bootstrap.get("local_player_name")).strip_edges().left(SessionTransport.MAX_PLAYER_NAME_LENGTH)
	var charter_id := String(bootstrap.get("selected_charter_id")).left(48)
	var packet := {
		"magic": DISCOVERY_MAGIC,
		"port": transport.bound_port,
		"name": name,
		"players": transport.player_count(),
		"capacity": transport.player_capacity(),
		"signature": signature,
		"charter": charter_id,
		"protocol": SimConfig.PROTOCOL_VERSION,
	}
	var bytes := JSON.stringify(packet).to_utf8_buffer()
	if bytes.size() <= MAX_DISCOVERY_PACKET_BYTES:
		broadcaster.put_packet(bytes)


func _poll_discovery_packets() -> void:
	if not listener_ready:
		return
	var processed := 0
	while listener.get_available_packet_count() > 0 and processed < MAX_PACKETS_PER_POLL:
		var bytes := listener.get_packet()
		var source_ip := listener.get_packet_ip()
		processed += 1
		if bytes.is_empty() or bytes.size() > MAX_DISCOVERY_PACKET_BYTES:
			continue
		var decoded: Variant = JSON.parse_string(bytes.get_string_from_utf8())
		if typeof(decoded) != TYPE_DICTIONARY:
			continue
		_accept_discovery_packet(decoded as Dictionary, source_ip)


func _accept_discovery_packet(packet: Dictionary, source_ip: String) -> void:
	if String(packet.get("magic", "")) != DISCOVERY_MAGIC:
		return
	if source_ip.is_empty():
		return
	var port := int(packet.get("port", 0))
	if port < 1_024 or port > 65_535:
		return
	var signature := String(packet.get("signature", ""))
	if not _valid_signature(signature):
		return
	var players := clampi(int(packet.get("players", 0)), 1, SessionTransport.MAX_PLAYERS)
	var capacity := clampi(int(packet.get("capacity", 0)), 2, SessionTransport.MAX_PLAYERS)
	if players > capacity:
		return
	var name := String(packet.get("name", "Host")).strip_edges().left(SessionTransport.MAX_PLAYER_NAME_LENGTH)
	if name.is_empty():
		name = "Host"
	var local_signature := String(bootstrap.call("_session_compatibility_signature"))
	var endpoint_key := "%s:%d" % [source_ip, port]
	discovered_hosts[endpoint_key] = {
		"address": source_ip,
		"port": port,
		"name": name,
		"players": players,
		"capacity": capacity,
		"signature": signature,
		"compatible": signature == local_signature,
		"charter": String(packet.get("charter", "")).left(48),
		"protocol": int(packet.get("protocol", 0)),
		"last_seen_ms": Time.get_ticks_msec(),
	}
	if discovered_hosts.size() > MAX_DISCOVERED_HOSTS:
		_remove_oldest_host()
	host_rows_fingerprint = ""


func _valid_signature(signature: String) -> bool:
	if signature.length() != 64:
		return false
	for index: int in signature.length():
		var code := signature.unicode_at(index)
		if not (code >= 48 and code <= 57) and not (code >= 97 and code <= 102):
			return false
	return true


func _expire_stale_hosts() -> void:
	var now := Time.get_ticks_msec()
	var removed := false
	for key: Variant in discovered_hosts.keys():
		var host: Dictionary = discovered_hosts[key]
		if now - int(host.get("last_seen_ms", 0)) > HOST_STALE_MS:
			discovered_hosts.erase(key)
			removed = true
	if removed:
		host_rows_fingerprint = ""


func _remove_oldest_host() -> void:
	var oldest_key: Variant = null
	var oldest_seen := Time.get_ticks_msec()
	for key: Variant in discovered_hosts.keys():
		var seen := int((discovered_hosts[key] as Dictionary).get("last_seen_ms", 0))
		if oldest_key == null or seen < oldest_seen:
			oldest_key = key
			oldest_seen = seen
	if oldest_key != null:
		discovered_hosts.erase(oldest_key)


func _update_ui() -> void:
	var transport := _transport()
	if transport == null or host_button == null:
		return
	if transport.is_host():
		host_button.text = "HOSTING %d/%d" % [transport.player_count(), transport.player_capacity()]
		host_button.tooltip_text = "Click twice within the confirmation window to close the host."
		join_button.disabled = true
		join_button.text = "JOIN"
		status_label.text = "Hosting on this LAN · %s" % transport.status_detail
	elif transport.is_connected_client():
		host_button.text = "HOST"
		host_button.disabled = true
		join_button.disabled = false
		join_button.text = "LEAVE"
		status_label.text = "Joined · %s" % transport.status_detail
	elif transport.mode == SessionTransport.Mode.CONNECTING:
		host_button.text = "HOST"
		host_button.disabled = true
		join_button.disabled = false
		join_button.text = "CANCEL"
		status_label.text = transport.status_detail
	else:
		host_button.text = "HOST"
		host_button.disabled = false
		join_button.disabled = false
		join_button.text = "JOIN"
		status_label.text = "Offline · Host or find a game on this Wi-Fi/LAN"

	browser_box.visible = browser_open and not transport.is_host()
	if browser_box.visible:
		_refresh_host_rows()


func _refresh_host_rows() -> void:
	if host_rows == null:
		return
	var keys: Array = discovered_hosts.keys()
	keys.sort_custom(
		func(left: Variant, right: Variant) -> bool:
			var a: Dictionary = discovered_hosts[left]
			var b: Dictionary = discovered_hosts[right]
			if bool(a.get("compatible", false)) != bool(b.get("compatible", false)):
				return bool(a.get("compatible", false))
			if int(a.get("players", 0)) != int(b.get("players", 0)):
				return int(a.get("players", 0)) > int(b.get("players", 0))
			return String(a.get("name", "")) < String(b.get("name", ""))
	)
	var parts: Array[String] = []
	for key: Variant in keys:
		var host: Dictionary = discovered_hosts[key]
		parts.append("%s|%s|%s|%s" % [key, host.get("players", 0), host.get("capacity", 0), host.get("compatible", false)])
	var fingerprint := ";".join(parts)
	if fingerprint == host_rows_fingerprint:
		return
	host_rows_fingerprint = fingerprint

	for child: Node in host_rows.get_children():
		child.queue_free()

	if keys.is_empty():
		browser_status_label.text = discovery_error if not discovery_error.is_empty() else "Searching local network… hosts appear automatically."
		return

	var compatible_count := 0
	for key: Variant in keys:
		var host: Dictionary = discovered_hosts[key]
		var compatible := bool(host.get("compatible", false))
		if compatible:
			compatible_count += 1
		var button := Button.new()
		var charter_id := String(host.get("charter", ""))
		var charter_label := SessionCharter.display_name(charter_id) if not charter_id.is_empty() else "Farflow"
		button.text = "%s  ·  %d/%d  ·  %s%s" % [
			String(host.get("name", "Host")),
			int(host.get("players", 1)),
			int(host.get("capacity", 2)),
			charter_label,
			"" if compatible else "  ·  DIFFERENT BUILD",
		]
		button.disabled = not compatible
		button.custom_minimum_size = Vector2(0.0, 40.0)
		var endpoint_key := String(key)
		button.pressed.connect(func() -> void: _join_discovered_host(endpoint_key))
		host_rows.add_child(button)

	browser_status_label.text = "%d compatible host%s found" % [compatible_count, "" if compatible_count == 1 else "s"]
