extends FluxTestSuite


const History = preload("res://src/presentation/actor_motion_history.gd")


func run() -> int:
	var history := History.new()
	var state := PlayerState.new(2)
	state.champion_wire_id = 1
	state.position_x = 100_000
	state.position_y = 200_000
	state.air_height = 20_000
	var actors: Array[PlayerState] = [state]
	history.capture(actors)
	equal(history.sample(state, 0.0), Vector3(100, 200, 20), "new actor never flies in from an old origin")
	state.position_x += 10_000
	state.air_height += 6_000
	history.capture(actors)
	var canonical_before := state.canonical_values()
	equal(history.sample(state, 0.5), Vector3(105, 200, 23), "planar and elevation samples use the same slight interpolation")
	equal(history.previous_height(state), 20_000, "jump sampler receives exact fixed previous height")
	equal(history.sample(state, -2.0), Vector3(100, 200, 20), "negative alpha never extrapolates backwards")
	equal(history.sample(state, 2.0), Vector3(110, 200, 26), "late frames never extrapolate through cover")
	equal(state.canonical_values(), canonical_before, "render interpolation cannot mutate authority")
	state.position_x += 200_000
	history.capture(actors)
	equal(history.sample(state, 0.0), Vector3(310, 200, 26), "teleport snaps instead of sliding through the world")
	state.champion_wire_id = 2
	state.air_height = 0
	history.capture(actors)
	equal(history.previous_height(state), 0, "character switch resets old elevation")
	state.health = 0
	state.position_x += 1000
	history.capture(actors)
	equal(history.sample(state, 0.0).x, 311.0, "defeat has no delayed position trail")
	actors.clear()
	for entity_id: int in range(1, 12):
		actors.append(PlayerState.new(entity_id))
	history.capture(actors)
	equal(history.tracks.size(), 8, "history remains bounded to eight admitted champion tracks")
	actors.clear()
	history.capture(actors)
	equal(history.tracks.size(), 0, "disconnected actors leave no retained history")
	history.clear()
	return finish("actor-motion-history")
