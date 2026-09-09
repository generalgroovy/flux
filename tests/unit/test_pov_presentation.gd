extends FluxTestSuite


const Harness = preload("res://tests/support/chemistry_coach_harness.gd")

class SpectatorHarness:
	extends "res://tests/support/chemistry_coach_harness.gd"
	var follow_id := 0
	func _is_spectating() -> bool:
		return follow_id > 0
	func _spectator_state() -> PlayerState:
		return world.player(follow_id) if follow_id > 0 else null


func run() -> int:
	_test_owned_sprite_overlay()
	_test_shared_rear_visibility()
	_test_spectator_overlay_owner()
	return finish("pov-presentation")


func _test_owned_sprite_overlay() -> void:
	var node := Harness.new()
	check(node.configure_fixture(true), "POV tests configure production body presentation")
	var state: PlayerState = node.world.player()
	for champion_id: String in ["s_wayne", "oh_tipi", "red_baron"]:
		check(node.champion_catalog.apply_to_player(state, champion_id), "POV uses actual size identity")
		state.spawn_protection_ticks = 0
		for aim: Vector2i in EightDirectionResolver.FIXED_VECTORS:
			state.aim_x = aim.x
			state.aim_y = aim.y
			for angle: int in [15, 120, 360]:
				node.player_preferences.pov_mode = PlayerPreferences.POV_CONE
				node.player_preferences.set_pov_angle_degrees(angle)
				for height: int in [0, 65000]:
					state.air_height = height
					state.movement_mode = PlayerState.MovementMode.IDLE if height == 0 else PlayerState.MovementMode.HOP
					node.previous_air_height = height
					var before := state.canonical_values()
					var overlay: Dictionary = node._pov_observer_overlay_frame(30.0, 0.0)
					check(not overlay.is_empty(), "own sprite has a body-only overlay for every heading, angle and jump height")
					equal(overlay.get("observer_id"), state.entity_id, "overlay belongs to the living viewpoint owner")
					var ordinary := node.cartoon_champion_presenter.movement_frame(champion_id, state, 30.0, node.world.config, false, 0.0)
					equal(overlay.get("source_region"), ordinary.get("source_region"), "postmask body uses exactly the ordinary animation cell")
					equal(overlay.get("texture"), ordinary.get("texture"), "postmask body uses the same corresponding size texture")
					var jump := JumpPresentation.sample(state, node.world.config, 0.0, false, height)
					var expected := node.current_position + Vector2(0, float(MovementTuning.PLAYER_RADIUS) / 1000.0 * 0.58 - jump.body_lift_pixels) + (ordinary["offset"] as Vector2) - CartoonChampionPresenter.PIVOT
					equal((overlay["destination"] as Rect2).position, expected, "raised body placement stays exact without growing a mask hole")
					equal(state.canonical_values(), before, "overlay queries never change jump, visibility, collision or combat authority")
	node.player_preferences.pov_mode = PlayerPreferences.POV_FULL
	check(node._pov_observer_overlay_frame(0.0, 0.0).is_empty(), "default full view adds no redundant overlay")
	node.player_preferences.pov_mode = PlayerPreferences.POV_CONE
	state.health = 0
	check(node._pov_observer_overlay_frame(0.0, 0.0).is_empty(), "dead local body is not resurrected above the mask")
	node.free()


func _test_shared_rear_visibility() -> void:
	var node := Harness.new()
	check(node.configure_fixture(), "rear visibility fixture configures without rendering")
	var observer: PlayerState = node.world.player()
	observer.position_x = 1000000
	observer.position_y = 1000000
	observer.aim_x = 1000
	observer.aim_y = 0
	node.current_position = Vector2(1000, 1000)
	node.previous_position = node.current_position
	node.player_preferences.pov_mode = PlayerPreferences.POV_CONE
	node.player_preferences.set_pov_angle_degrees(15)
	var target := PlayerState.new(2)
	target.position_x = 930000
	target.position_y = 1000000
	node.world.players.append(target)
	var original_buildings: Array = node.campus_layout.data["buildings"]
	node.campus_layout.data["buildings"] = []
	check(node._chemistry_actor_visible(target), "near rear target is visible in clear space")
	node.campus_layout.data["buildings"] = [{"bounds": [955, 990, 10, 20], "occlusion_policy": "los_cutaway"}]
	check(not node._chemistry_actor_visible(target), "the shared actor predicate hides a target behind near opaque rear cover")
	target.chemistry_reveal_ticks = 2
	check(not node._chemistry_actor_visible(target), "chemical reveal cannot turn rear awareness into a wall reveal")
	target.chemistry_reveal_ticks = 0
	node.campus_layout.data["buildings"] = [{"bounds": [955, 990, 10, 20], "occlusion_policy": "low_never_occludes"}]
	check(node._chemistry_actor_visible(target), "authored low cover keeps its existing non-occluding policy")
	var steam := ElementReactionState.new()
	steam.recipe_wire_id = 310
	steam.position_x = 965000
	steam.position_y = 1000000
	steam.origin_x = steam.position_x
	steam.origin_y = steam.position_y
	steam.radius = 30000
	steam.active_tick = 0
	steam.decay_tick = 100
	steam.expiry_tick = 120
	node.world.reactions.append(steam)
	check(not node._chemistry_actor_visible(target), "rear awareness does not bypass existing Steam concealment beyond its64px grace")
	target.chemistry_reveal_ticks = 2
	check(node._chemistry_actor_visible(target), "authoritative chemical reveal still defeats chemistry when opaque LOS is clear")
	node.campus_layout.data["buildings"] = original_buildings
	node.player_preferences.pov_mode = PlayerPreferences.POV_FULL
	check(node._chemistry_actor_visible(target), "full-view mode preserves its prior chemistry-reveal behavior")
	node.free()


func _test_spectator_overlay_owner() -> void:
	var node := SpectatorHarness.new()
	check(node.configure_fixture(true), "spectator overlay fixture configures")
	var local: PlayerState = node.world.player()
	local.health = 0
	var followed := PlayerState.new(2)
	check(node.champion_catalog.apply_to_player(followed, "red_baron"), "spectator follows a real large body")
	followed.position_x = local.position_x + 50000
	followed.position_y = local.position_y
	node.world.players.append(followed)
	node.actor_motion_history.capture(node.world.players)
	node.follow_id = 2
	node.player_preferences.pov_mode = PlayerPreferences.POV_CONE
	var overlay: Dictionary = node._pov_observer_overlay_frame(0.0, 0.0)
	equal(overlay.get("observer_id"), 2, "only the followed actor owns the spectator mask exemption")
	followed.health = 0
	check(node._pov_observer_overlay_frame(0.0, 0.0).is_empty(), "dead followed actor is not repainted as a live visible character")
	node.free()
