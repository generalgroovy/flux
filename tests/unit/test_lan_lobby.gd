extends FluxTestSuite


func run() -> int:
	_test_discovery_packet_validation()
	_test_discovery_compatibility_and_source_identity()
	return finish("lan-lobby")


func _advertisement(signature: String) -> Dictionary:
	return {
		"magic": LanLobby.DISCOVERY_MAGIC,
		"kind": LanLobby.DISCOVERY_KIND_ADVERTISEMENT,
		"port": SessionTransport.DEFAULT_PORT,
		"name": "Lantern Host",
		"players": 2,
		"capacity": 8,
		"signature": signature,
		"protocol": SimConfig.PROTOCOL_VERSION,
	}


func _test_discovery_packet_validation() -> void:
	var signature := "a".repeat(64)
	check(LanLobby._valid_signature(signature), "lowercase SHA-256-shaped discovery identity validates")
	check(not LanLobby._valid_signature(signature.to_upper()), "uppercase discovery identity fails closed")
	check(not LanLobby._valid_signature("a".repeat(63)), "short discovery identity fails closed")

	var host := LanLobby.normalized_host(_advertisement(signature), "192.168.1.44", signature, 1234)
	check(not host.is_empty(), "bounded advertisement normalizes")
	equal(String(host.get("address", "")), "192.168.1.44", "sender IP, not packet data, owns the discovered endpoint")
	equal(int(host.get("port", 0)), SessionTransport.DEFAULT_PORT, "advertised game port survives normalization")
	equal(int(host.get("players", 0)), 2, "player count survives normalization")
	equal(int(host.get("capacity", 0)), 8, "capacity survives normalization")
	equal(int(host.get("last_seen_ms", 0)), 1234, "discovery stores bounded freshness time")

	var wrong_magic := _advertisement(signature)
	wrong_magic["magic"] = "OTHER_GAME"
	check(LanLobby.normalized_host(wrong_magic, "192.168.1.44", signature, 1).is_empty(), "foreign discovery traffic is ignored")
	var query := _advertisement(signature)
	query["kind"] = LanLobby.DISCOVERY_KIND_QUERY
	check(LanLobby.normalized_host(query, "192.168.1.44", signature, 1).is_empty(), "discovery queries cannot masquerade as hosts")
	var bad_port := _advertisement(signature)
	bad_port["port"] = 80
	check(LanLobby.normalized_host(bad_port, "192.168.1.44", signature, 1).is_empty(), "privileged advertised ports fail closed")
	var impossible_roster := _advertisement(signature)
	impossible_roster["players"] = 8
	impossible_roster["capacity"] = 2
	check(LanLobby.normalized_host(impossible_roster, "192.168.1.44", signature, 1).is_empty(), "impossible host rosters fail closed")


func _test_discovery_compatibility_and_source_identity() -> void:
	var local_signature := "a".repeat(64)
	var matching := LanLobby.normalized_host(_advertisement(local_signature), "10.0.0.7", local_signature, 10)
	check(bool(matching.get("compatible", false)), "matching build identity is selectable")

	var remote_signature := "b".repeat(64)
	var incompatible := LanLobby.normalized_host(_advertisement(remote_signature), "10.0.0.8", local_signature, 20)
	check(not incompatible.is_empty(), "incompatible hosts remain visible for explanation")
	check(not bool(incompatible.get("compatible", true)), "different build identity is not selectable")

	var oversized_name := _advertisement(local_signature)
	oversized_name["name"] = "X".repeat(SessionTransport.MAX_PLAYER_NAME_LENGTH + 20)
	var bounded := LanLobby.normalized_host(oversized_name, "10.0.0.9", local_signature, 30)
	equal(String(bounded.get("name", "")).length(), SessionTransport.MAX_PLAYER_NAME_LENGTH, "discovered host names are bounded")
