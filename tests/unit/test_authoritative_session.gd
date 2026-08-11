extends FluxTestSuite


const ABILITY_PATH: String = "res://content/abilities/foundation_abilities_v1.json"
const CHAMPION_PATH: String = "res://content/champions/foundation_champions_v1.json"


func run() -> int:
	_test_authoritative_presence_and_input()
	return finish("authoritative-session")


func _test_authoritative_presence_and_input() -> void:
	var abilities := AbilityCatalog.new()
	check(abilities.load_from_file(ABILITY_PATH), "abilities load for authoritative session")
	var champions := ChampionCatalog.new()
	check(champions.load_from_file(CHAMPION_PATH, abilities), "champions load for authoritative session")
	var world := SimWorld.new(120, 9, CollisionWorld.new(3_000_000, 2_000_000))
	check(champions.apply_to_player(world.player(), "oh_tipi"), "host champion applies")
	var session := AuthoritativeSession.new()
	check(session.bind(world, champions, Vector2i(1280, 720), "Lantern Host"), "authoritative session binds")
	equal(session.register_peers([{"peer_id": 42, "entity_id": 2, "name": "River Guest"}]), 1, "accepted peer registers once")
	equal(session.register_peers([{"peer_id": 42, "entity_id": 2, "name": "River Guest"}]), 0, "duplicate entity registration is ignored")
	var guest: PlayerState = world.player(2)
	check(guest != null, "guest owns a host-side simulation actor")
	if guest != null:
		equal(guest.champion_wire_id, 2, "first guest receives S. Wayne for a distinct two-character test")
		equal(Vector2i(guest.position_x, guest.position_y), Vector2i(1_352_000, 720_000), "guest receives deterministic collision-cleared spawn offset")

	var packet := {
		"entity_id": 2,
		"sequence": 1,
		"move_x": 1000,
		"move_y": 0,
		"held": SimCommand.HELD_JUMP,
		"pressed": SimCommand.PRESSED_JUMP,
		"aim_x": 1000,
		"aim_y": 0,
	}
	equal(session.ingest_inputs([packet]), 1, "validated transport input enters authority controller")
	var commands := session.commands_for_tick(SimCommand.new(world.tick, 1))
	equal(commands.size(), 2, "authority emits one ordered command per traveller")
	check(world.step(commands), "host simulates both travellers in one tick")
	check(world.player(2).position_x > 1_352_000, "remote input moves only through host simulation")
	check(world.player(2).hop_ticks > 0, "remote jump action executes once through the shared movement grammar")
	var second_commands := session.commands_for_tick(SimCommand.new(world.tick, 1))
	equal(second_commands[1].pressed_actions, 0, "remote pressed action is consumed exactly once")
	check(world.step(second_commands), "held remote command continues on the next tick")
	for _index: int in range(world.config.milliseconds_to_ticks(AuthoritativeSession.REMOTE_INPUT_TIMEOUT_MS) + 2):
		check(world.step(session.commands_for_tick(SimCommand.new(world.tick, 1))), "host advances toward remote input timeout")
	var stale_commands := session.commands_for_tick(SimCommand.new(world.tick, 1))
	equal(stale_commands[1].move_x, 0, "stale remote movement fails safe to idle")
	equal(stale_commands[1].held_actions, 0, "stale remote held actions fail safe to idle")

	var snapshot := session.capture_snapshot()
	check(SessionSnapshot.validate(snapshot), "authority emits a validated roster snapshot")
	equal(SessionSnapshot.names(snapshot), {1: "Lantern Host", 2: "River Guest"}, "snapshot exposes authoritative presence names")
	equal(session.remove_peers([{"entity_id": 2, "name": "River Guest"}]), 1, "disconnect removes the remote actor")
	check(world.player(2) == null, "removed remote actor leaves no simulation ghost")
