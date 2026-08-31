extends FluxTestSuite


func run() -> int:
	var catalog := BodyTypeProfileCatalog.new()
	check(catalog.load_from_file(), "body-type profiles validate: %s" % catalog.last_error)
	equal(catalog.profiles.keys().size(), 3, "exactly three reusable body profiles exist")
	equal(catalog.role("small"), "skirmisher", "small champions trade reserves for tempo")
	equal(catalog.role("middle"), "adapter", "middle champions own the balanced role")
	equal(catalog.role("large"), "anchor", "large champions trade speed for staying power")
	equal(int(catalog.shared_rules.get("competitive_budget", 0)), 100, "every size uses the same competitive budget")
	equal(String(catalog.shared_rules.get("collision_radius_policy", "")), "shared_foundation_radius", "size cannot create a hidden collision advantage")
	var movement: Array = catalog.shared_rules.get("universal_movement", [])
	for action_id: String in ["jump", "slide", "roll", "air_dodge", "wave_dash", "wall_kick"]:
		check(movement.has(action_id), "%s remains available to every size" % action_id)
	check(catalog.accepts("small", {"health_maximum": 90000, "health_recovery_per_second": 2200, "flux_maximum": 112000, "flux_recovery_per_second": 23000, "stamina_maximum": 96000, "stamina_recovery_per_second": 28000, "movement_speed_ratio": 1060}), "S. Wayne fits the small skirmisher envelope")
	check(catalog.accepts("middle", {"health_maximum": 108000, "health_recovery_per_second": 1800, "flux_maximum": 104000, "flux_recovery_per_second": 19000, "stamina_maximum": 108000, "stamina_recovery_per_second": 30000, "movement_speed_ratio": 980}), "Oh Tipi fits the middle adapter envelope")
	check(catalog.accepts("large", {"health_maximum": 132000, "health_recovery_per_second": 1200, "flux_maximum": 96000, "flux_recovery_per_second": 17000, "stamina_maximum": 128000, "stamina_recovery_per_second": 32000, "movement_speed_ratio": 910}), "The Red Baron fits the large anchor envelope")
	var invalid := catalog.data.duplicate(true)
	((invalid["profiles"] as Dictionary)["large"] as Dictionary)["role"] = ""
	var rejected := BodyTypeProfileCatalog.new()
	rejected.data = invalid
	check(not rejected.validate(), "roleless body profile fails closed")
	return finish("body-type-profile-catalog")
