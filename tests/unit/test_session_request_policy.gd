extends FluxTestSuite


const CAMPUS_PATH: String = "res://content/maps/sanctum_campus_g2_v1.json"


func run() -> int:
	var layout := SanctumCampusLayout.new()
	check(layout.load_from_file(CAMPUS_PATH), "campus loads for interaction policy")
	var state := PlayerState.new(2)
	_place_at(state, layout, "training-reset")
	equal(SessionRequestPolicy.validate(SessionTransport.REQUEST_TRAINING_RESET, state, layout.stations_by_id, 20, 0), SessionRequestPolicy.ACCEPTED, "Practice Bell request is accepted only at its authoritative position")
	equal(SessionRequestPolicy.validate(SessionTransport.REQUEST_CHAMPION_NEXT, state, layout.stations_by_id, 20, 0), SessionRequestPolicy.REFUSED_DISTANCE, "Champion request is refused at the Practice Bell")
	_place_at(state, layout, "champion-loom")
	equal(SessionRequestPolicy.validate(SessionTransport.REQUEST_CHAMPION_NEXT, state, layout.stations_by_id, 20, 0), SessionRequestPolicy.ACCEPTED, "Champion request is accepted at the Loom")
	_place_at(state, layout, "spell-loom")
	equal(SessionRequestPolicy.validate(SessionTransport.REQUEST_SPELL_EQUIP, state, layout.stations_by_id, 20, 0), SessionRequestPolicy.ACCEPTED, "spell weave is accepted only at the Spell Loom")
	_place_at(state, layout, "momentum-chime")
	equal(SessionRequestPolicy.validate(SessionTransport.REQUEST_IMPACT_PRACTICE, state, layout.stations_by_id, 20, 0), SessionRequestPolicy.ACCEPTED, "impact practice is accepted only at the Momentum Chime")
	state.control_state = PlayerState.ControlState.LAUNCHED
	equal(SessionRequestPolicy.validate(SessionTransport.REQUEST_IMPACT_PRACTICE, state, layout.stations_by_id, 20, 0), SessionRequestPolicy.REFUSED_UNAVAILABLE, "impact practice cannot be retriggered during authored loss of control")
	state.control_state = PlayerState.ControlState.FREE
	state.impact_recovery_ticks = 2
	equal(SessionRequestPolicy.validate(SessionTransport.REQUEST_IMPACT_PRACTICE, state, layout.stations_by_id, 20, 0), SessionRequestPolicy.REFUSED_UNAVAILABLE, "impact practice cannot erase the recovery decision window")
	state.impact_recovery_ticks = 0
	state.position_x = 400_000
	state.position_y = 400_000
	equal(SessionRequestPolicy.validate(SessionTransport.REQUEST_TRAINING_RESET, state, layout.stations_by_id, 20, 0), SessionRequestPolicy.REFUSED_DISTANCE, "remote station request fails closed away from every station")
	equal(SessionRequestPolicy.validate(SessionTransport.REQUEST_EMOTE, state, layout.stations_by_id, 20, 0), SessionRequestPolicy.ACCEPTED, "social emote works away from stations")
	equal(SessionRequestPolicy.validate(SessionTransport.REQUEST_SPELL_EQUIP, state, layout.stations_by_id, 20, 0), SessionRequestPolicy.REFUSED_DISTANCE, "remote spell weave fails closed away from the Loom")
	equal(SessionRequestPolicy.validate(SessionTransport.REQUEST_IMPACT_PRACTICE, state, layout.stations_by_id, 20, 0), SessionRequestPolicy.REFUSED_DISTANCE, "remote impact practice fails closed away from the Chime")
	equal(SessionRequestPolicy.validate(SessionTransport.REQUEST_EMOTE, state, layout.stations_by_id, 20, 21), SessionRequestPolicy.REFUSED_COOLDOWN, "social emote cooldown is host-validated")
	equal(SessionRequestPolicy.validate(99, state, layout.stations_by_id, 20, 0), SessionRequestPolicy.REFUSED_UNAVAILABLE, "unknown request fails closed")
	_place_at(state, layout, "session-hearth")
	equal(SessionRequestPolicy.validate(SessionTransport.REQUEST_READY_TOGGLE, state, layout.stations_by_id, 20, 0), SessionRequestPolicy.ACCEPTED, "readiness toggle is accepted only at the Session Hearth")
	equal(SessionRequestPolicy.validate(SessionTransport.REQUEST_PRACTICE_START, state, layout.stations_by_id, 20, 0), SessionRequestPolicy.ACCEPTED, "practice start intent is accepted at the Session Hearth before host-role validation")
	equal(SessionRequestPolicy.validate(SessionTransport.REQUEST_READY_TOGGLE, state, layout.stations_by_id, 20, 0, SessionRound.Phase.ACTIVE), SessionRequestPolicy.REFUSED_UNAVAILABLE, "active court refuses Hearth mutation")
	equal(SessionRequestPolicy.validate(SessionTransport.REQUEST_EMOTE, state, layout.stations_by_id, 20, 0, SessionRound.Phase.ACTIVE), SessionRequestPolicy.ACCEPTED, "active court keeps bounded social emotes available")
	state.position_x = 2_300_000
	equal(SessionRequestPolicy.validate(SessionTransport.REQUEST_READY_TOGGLE, state, layout.stations_by_id, 20, 0), SessionRequestPolicy.REFUSED_DISTANCE, "remote readiness fails closed away from the Hearth")
	state.actor_kind = PlayerState.ActorKind.TRAINING_TARGET
	equal(SessionRequestPolicy.validate(SessionTransport.REQUEST_EMOTE, state, layout.stations_by_id, 20, 0), SessionRequestPolicy.REFUSED_UNAVAILABLE, "non-champion cannot issue a social request")
	return finish("session-request-policy")

func _place_at(state: PlayerState, layout: SanctumCampusLayout, station_id: String) -> void:
	var point := SanctumCampusLayout._parse_point(layout.stations_by_id[station_id]["position"]) * SimConfig.FIXED_SCALE
	state.position_x = point.x
	state.position_y = point.y
