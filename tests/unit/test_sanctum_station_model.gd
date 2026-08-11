extends FluxTestSuite


const CAMPUS_PATH: String = "res://content/maps/sanctum_campus_g2_v1.json"


func run() -> int:
	_test_repository_stations()
	_test_range_and_tie_breaking()
	_test_invalid_station_entries_are_ignored()
	return finish("sanctum-station-model")


func _test_repository_stations() -> void:
	var layout := SanctumCampusLayout.new()
	check(layout.load_from_file(CAMPUS_PATH), "campus loads for station focus")
	equal(layout.stations_by_id.size(), 3, "walk-up slice exposes guide, practice and champion stations")
	equal(
		SanctumStationModel.nearest_station_id(layout.stations_by_id, Vector2i(1_180_000, 780_000)),
		"movement-guide",
		"movement guide focuses at its world anchor",
	)
	equal(
		SanctumStationModel.nearest_station_id(layout.stations_by_id, Vector2i(1_380_000, 780_000)),
		"training-reset",
		"practice bell focuses at its world anchor",
	)
	equal(
		SanctumStationModel.nearest_station_id(layout.stations_by_id, Vector2i(1_280_000, 900_000)),
		"champion-loom",
		"champion loom focuses at its world anchor",
	)
	equal(
		SanctumStationModel.nearest_station_id(layout.stations_by_id, Vector2i(1_280_000, 720_000)),
		"",
		"spawn begins free of an automatic station focus",
	)


func _test_range_and_tie_breaking() -> void:
	var stations := {
		"zeta": {"position": [20, 0], "interaction_radius": 30},
		"alpha": {"position": [-20, 0], "interaction_radius": 30},
	}
	equal(
		SanctumStationModel.nearest_station_id(stations, Vector2i.ZERO),
		"alpha",
		"equal-distance focus uses stable lexical station identity",
	)
	equal(
		SanctumStationModel.nearest_station_id(stations, Vector2i(49_999, 0)),
		"zeta",
		"closer in-range station wins before lexical order",
	)
	equal(
		SanctumStationModel.nearest_station_id(stations, Vector2i(50_001, 0)),
		"",
		"focus ends immediately outside every authored radius",
	)


func _test_invalid_station_entries_are_ignored() -> void:
	var stations := {
		"missing-position": {"interaction_radius": 100},
		"wrong-position-type": {"position": "0,0", "interaction_radius": 100},
		"zero-radius": {"position": [0, 0], "interaction_radius": 0},
	}
	equal(
		SanctumStationModel.nearest_station_id(stations, Vector2i.ZERO),
		"",
		"malformed runtime station data fails closed",
	)
