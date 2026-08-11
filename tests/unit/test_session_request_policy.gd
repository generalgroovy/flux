extends FluxTestSuite


const CAMPUS_PATH: String = "res://content/maps/sanctum_campus_g2_v1.json"


func run() -> int:
	var layout := SanctumCampusLayout.new()
	check(layout.load_from_file(CAMPUS_PATH), "campus loads for interaction policy")
	var state := PlayerState.new(2)
	state.position_x = 1_380_000
	state.position_y = 780_000
	equal(SessionRequestPolicy.validate(SessionTransport.REQUEST_TRAINING_RESET, state, layout.stations_by_id, 20, 0), SessionRequestPolicy.ACCEPTED, "Practice Bell request is accepted only at its authoritative position")
	equal(SessionRequestPolicy.validate(SessionTransport.REQUEST_CHAMPION_NEXT, state, layout.stations_by_id, 20, 0), SessionRequestPolicy.REFUSED_DISTANCE, "Champion request is refused at the Practice Bell")
	state.position_x = 1_280_000
	state.position_y = 900_000
	equal(SessionRequestPolicy.validate(SessionTransport.REQUEST_CHAMPION_NEXT, state, layout.stations_by_id, 20, 0), SessionRequestPolicy.ACCEPTED, "Champion request is accepted at the Loom")
	state.position_x = 400_000
	state.position_y = 400_000
	equal(SessionRequestPolicy.validate(SessionTransport.REQUEST_TRAINING_RESET, state, layout.stations_by_id, 20, 0), SessionRequestPolicy.REFUSED_DISTANCE, "remote station request fails closed away from every station")
	equal(SessionRequestPolicy.validate(SessionTransport.REQUEST_EMOTE, state, layout.stations_by_id, 20, 0), SessionRequestPolicy.ACCEPTED, "social emote works away from stations")
	equal(SessionRequestPolicy.validate(SessionTransport.REQUEST_EMOTE, state, layout.stations_by_id, 20, 21), SessionRequestPolicy.REFUSED_COOLDOWN, "social emote cooldown is host-validated")
	equal(SessionRequestPolicy.validate(99, state, layout.stations_by_id, 20, 0), SessionRequestPolicy.REFUSED_UNAVAILABLE, "unknown request fails closed")
	state.actor_kind = PlayerState.ActorKind.TRAINING_TARGET
	equal(SessionRequestPolicy.validate(SessionTransport.REQUEST_EMOTE, state, layout.stations_by_id, 20, 0), SessionRequestPolicy.REFUSED_UNAVAILABLE, "non-champion cannot issue a social request")
	return finish("session-request-policy")
