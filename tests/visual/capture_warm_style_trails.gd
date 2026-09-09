extends SceneTree


const Harness = preload("res://tests/support/chemistry_coach_harness.gd")
const ELEMENTS: Array[String] = ["earth", "fire", "water", "wind", "ice", "charge", "light", "dark"]
var output := "res://.godot/warm-style-trails-render"
var node: Node2D
var viewport: SubViewport
var records: Array[Dictionary] = []
var payments: Array[Dictionary] = []
var chemistry_events: Array[Dictionary] = []


func _initialize() -> void:
	root.hide()
	_run.call_deferred()


func _run() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--output="):
			output = argument.trim_prefix("--output=")
	if not output.begins_with("res://.godot/warm-style-trails-render") or ".." in output or DirAccess.dir_exists_absolute(output):
		fail("Provide a fresh warm-style-trails output; prior evidence is preserved")
		return
	node = Harness.new()
	if not node.configure_fixture(true) or DirAccess.make_dir_recursive_absolute(output) != OK:
		fail("Integrated map/body/material fixture could not configure")
		node.free()
		return
	viewport = SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	viewport.add_child(node)
	node.player_preferences.pov_mode = PlayerPreferences.POV_FULL
	node.player_preferences.set_camera_zoom_percent(100)
	for champion: String in ["s_wayne", "oh_tipi", "red_baron"]:
		if not reset_trial(champion) or not await capture(champion + "-quiet", {"kind": "actual_quiet_body_size"}):
			return
	for element: String in ELEMENTS:
		if not await capture_spell(element, "bolt"):
			return
	if not await capture_spell("fire", "rapid"):
		return
	if not await capture_one_payload_steam():
		return
	if OS.get_cmdline_user_args().has("--playtest-clarity") and not await capture_paid_protection():
		return
	if OS.get_cmdline_user_args().has("--rampart"):
		for champion: String in ["s_wayne", "oh_tipi", "red_baron"]:
			if not await capture_paid_rampart(champion):
				return
	var receipt := FileAccess.open(output.path_join("capture-receipt.json"), FileAccess.WRITE)
	if receipt == null:
		fail("Integrated trail receipt could not be written")
		return
	receipt.store_string(JSON.stringify({"schema_version": 1, "frames": records, "payments": payments, "map_hash": node.campus_layout.content_hash, "ground_style_hash": node.campus_renderer.illustrated_kit.ground_style.content_hash, "trail_policy": ElementChemistrySystem.trail_policy(), "method": "fresh_offline_world_per_trial_real_catalog_spells_paid_inputs_production_bootstrap_draw", "deposits": "never_injected", "authority_unchanged_by_draw": true, "network": "not_started", "audio": "not_started", "preferences": "transient_fixture_only", "human_acceptance": "not_run"}, "  "))
	receipt.close()
	print("PASS:%d integrated actual-game frames;8Bolt flight+terminal,1Rapid flight+terminal,3body sizes,2paid older-trail/new-impact Steam+spent-expiry;optional paid Float/cast/protection expiry;no injected deposits;draw world hashes unchanged" % records.size())
	quit(0)


func capture_paid_rampart(champion: String) -> bool:
	if not reset_trial(champion):
		return false
	var target: Vector2i = node.fixture_anchor + Vector2i(0, -160000)
	var wire := wire_for("earth", "rapid")
	var first := begin_paid_cast(wire, target)
	if first.is_empty():
		return false
	for unused: int in 160:
		if not step_world():
			return false
		var actor: PlayerState = node.world.player()
		if not node.world.deposits.is_empty() and node.world.projectiles.is_empty() and actor.pending_cast_wire_id == 0 and actor.cast_recovery_ticks == 0 and actor.spell_cooldown_for_wire(wire) == 0:
			break
	var second := begin_paid_cast(wire, target, 2)
	if second.is_empty():
		return false
	for unused: int in 160:
		if not step_world():
			return false
		if not node.world.reactions.is_empty():
			break
	if node.world.reactions.size() != 1 or int(node.world.reactions[0].recipe_wire_id) != 301 or trail_count() != 0:
		fail("Earth pilot requires exactly one paid Rapid + Rapid mirror, no injected matter or trails")
		return false
	var reaction: ElementReactionState = node.world.reactions[0]
	var evidence := {"kind": "paid_earth_mirror_lifecycle", "first": first, "second": second, "reaction_values": Array(reaction.canonical_values())}
	if node.world.tick >= reaction.active_tick or not await capture(champion + "-rampart-formation", evidence):
		return false
	while node.world.tick <= reaction.active_tick + 10:
		if not step_world():
			return false
	var actor: PlayerState = node.world.player()
	for unused: int in 110:
		if not step_world([SimCommand.new(node.world.tick, actor.entity_id, 0, -1000, 0, 0, 0, -1000)]):
			return false
	if actor.wall_contact_id <= 0 or actor.position_y <= reaction.position_y:
		fail("Paid active Rampart must block approaching movement and expose a real wall contact")
		return false
	evidence["contact_id"] = actor.wall_contact_id
	evidence["contact_position"] = [actor.position_x, actor.position_y]
	if not await capture(champion + "-rampart-contact", evidence):
		return false
	while node.world.tick <= reaction.decay_tick + 3:
		if not step_world():
			return false
	if not await capture(champion + "-rampart-decay", evidence):
		return false
	for unused: int in 90:
		if not step_world([SimCommand.new(node.world.tick, actor.entity_id, 0, -1000, 0, 0, 0, -1000)]):
			return false
	if actor.position_y >= reaction.position_y or actor.wall_contact_id == int(evidence.contact_id):
		fail("Expired Rampart must release passage and cannot retain its wall contact")
		return false
	return await capture(champion + "-rampart-expired-passage", evidence)


func capture_paid_protection() -> bool:
	if not reset_trial("s_wayne"):
		return false
	var actor: PlayerState = node.world.player()
	var starting_stamina := actor.stamina
	if not step_world([SimCommand.new(node.world.tick, actor.entity_id, 1000, 0, SimCommand.HELD_JUMP, SimCommand.PRESSED_JUMP, 0, -1000)]):
		return false
	for unused: int in range(10):
		if not step_world([SimCommand.new(node.world.tick, actor.entity_id, 1000, 0, 0, 0, 0, -1000)]):
			return false
	if not step_world([SimCommand.new(node.world.tick, actor.entity_id, 1000, 0, SimCommand.HELD_JUMP, SimCommand.PRESSED_JUMP, 0, -1000)]):
		return false
	if not actor.air_floating or actor.stamina >= starting_stamina or CompactCombatHud.protection_status(actor) != "PROTECTED / FLOAT":
		fail("Protection capture must use an actual paid jump into finite Float")
		return false
	if not await capture("paid-float-protected", {"kind": "paid_jump_float", "stamina_paid": starting_stamina - actor.stamina, "float_ticks": actor.float_ticks, "protection": CompactCombatHud.protection_status(actor)}):
		return false
	var wire := wire_for("fire", "bolt")
	if not actor.place_proven_spell(0, wire):
		return false
	var starting_flux := actor.flux
	if not step_world([SimCommand.new(node.world.tick, actor.entity_id, 1000, 0, SimCommand.HELD_JUMP, SimCommand.PRESSED_SPELL_1, 0, -1000, node.fixture_target.x, node.fixture_target.y)]):
		return false
	if actor.pending_cast_wire_id != wire or actor.flux != starting_flux - int(CombatTuning.cast_definition(wire).flux_cost) or not actor.air_floating:
		fail("Moving protected cast must pay Flux without ending Float")
		return false
	if not await capture("paid-float-cast-startup", {"kind": "paid_cast_during_float", "flux_paid": starting_flux - actor.flux, "pending_wire": wire, "protection": CompactCombatHud.protection_status(actor)}):
		return false
	for unused: int in range(100):
		if not step_world([SimCommand.new(node.world.tick, actor.entity_id, 0, 0, 0, 0, 0, -1000)]):
			return false
	if not CompactCombatHud.protection_status(actor).is_empty():
		fail("Released protection must visibly end using accepted current state")
		return false
	return await capture("paid-float-ended", {"kind": "paid_float_released", "protection": CompactCombatHud.protection_status(actor)})


func reset_trial(champion: String = "oh_tipi") -> bool:
	# Independent controlled initial conditions, never inserted chemistry state.
	node.world = SimWorld.new(120, 909, node.campus_layout.build_collision_world())
	node.authoritative_session.world = node.world
	var actor: PlayerState = node.world.player()
	if not node.champion_catalog.apply_to_player(actor, champion):
		fail("Real champion identity could not configure")
		return false
	actor.reset_for_spawn(node.fixture_anchor)
	actor.spawn_protection_ticks = 0
	actor.flux_recovery_per_second = 0
	actor.health_recovery_per_second = 0
	actor.aim_x = 0
	actor.aim_y = -1000
	if not node.world.collision.can_occupy(node.fixture_anchor, actor.radius):
		fail("Authored trial anchor must remain outside real collision")
		return false
	node.selected_champion_id = champion
	node.session_round_values = node.authoritative_session.session_round.capture(node.world)
	node.actor_motion_history.clear()
	chemistry_events.clear()
	sync_fixture()
	return true


func wire_for(element: String, family: String) -> int:
	var id: String = node.ability_catalog.spell_id_at(element, family)
	var definition: Dictionary = node.ability_catalog.ability(id)
	return int(definition.get("wire_id", 0)) if String(definition.get("runtime_status", "")) == "playable" else 0


func begin_paid_cast(wire: int, target: Vector2i, slot: int = 1) -> Dictionary:
	var actor: PlayerState = node.world.player()
	var definition := CombatTuning.cast_definition(wire)
	var cost := int(definition.get("flux_cost", 0))
	if wire <= 0 or cost <= 0 or not actor.place_proven_spell(slot - 1, wire):
		fail("Trial requires an ordinary available catalog spell")
		return {}
	var before := actor.flux
	var command := SimCommand.new(node.world.tick, actor.entity_id, 0, 0, 0, SimCommand.SPELL_PRESSED_BITS[slot - 1], 0, -1000, target.x, target.y)
	if not step_world([command]) or actor.flux != before - cost or actor.pending_cast_wire_id != wire:
		fail("Trial cast must be accepted and pay exact authored Flux")
		return {}
	var accepted := false
	for event: Dictionary in node.world.combat_events:
		accepted = accepted or (String(event.get("type", "")) == "cast_started" and int(event.get("wire_id", 0)) == wire)
	if not accepted:
		fail("Paid trial needs its actual cast_started event")
		return {}
	var payment := {"wire_id": wire, "tick": node.world.tick - 1, "flux_before": before, "flux_after": actor.flux, "flux_paid": cost, "target": [target.x, target.y], "slot": slot}
	payments.append(payment)
	return payment


func capture_spell(element: String, family: String) -> bool:
	if not reset_trial():
		return false
	var wire := wire_for(element, family)
	var payment := begin_paid_cast(wire, node.fixture_anchor + Vector2i(0, -220000))
	if payment.is_empty():
		return false
	var flight_ticks := 0
	var source_id := 0
	var flight_ready := false
	for unused: int in 120:
		if not step_world():
			return false
		if not node.world.projectiles.is_empty():
			flight_ticks += 1
			source_id = node.world.projectiles[0].source_cast_id
		if family == "rapid" and not node.world.deposits.is_empty() and not node.world.projectiles.is_empty():
			fail("Rapid flight must never seed a deposit")
			return false
		if not node.world.projectiles.is_empty() and ((family == "rapid" and flight_ticks >= 16) or (family == "bolt" and trail_count() >= 2)):
			flight_ready = true
			break
	if not flight_ready or source_id <= 0 or not node.world.reactions.is_empty():
		fail("Independent trial must show real flight and bounded trails without self-reaction")
		return false
	var evidence := {"kind": "actual_paid_%s" % family, "element": element, "wire_id": wire, "source_cast_id": source_id, "payment": payment}
	if not await capture(element + "-" + family + "-flight", evidence):
		return false
	var terminal: ElementDepositState
	for unused: int in 120:
		if not step_world():
			return false
		for deposit: ElementDepositState in node.world.deposits:
			if deposit.source_cast_id == source_id and not deposit.is_trail():
				terminal = deposit
		if terminal != null and node.world.projectiles.is_empty():
			break
	if terminal == null or terminal.radius < 24000 or terminal.radius > 32000 or not node.world.projectiles.is_empty() or not node.world.reactions.is_empty():
		fail("Independent paid projectile must end in real24–32px terminal matter")
		return false
	if family == "rapid" and trail_count() != 0:
		fail("Rapid exception must leave terminal matter only")
		return false
	# Let the initial contact imprint settle while retaining the actual terminal.
	for unused: int in 8:
		if not step_world():
			return false
	evidence["terminal_id"] = terminal.entity_id
	evidence["terminal_radius"] = terminal.radius
	return await capture(element + "-" + family + "-terminal", evidence)


func capture_one_payload_steam() -> bool:
	if not reset_trial():
		return false
	var fire_payment := begin_paid_cast(wire_for("fire", "bolt"), node.fixture_anchor + Vector2i(0, -300000))
	if fire_payment.is_empty():
		return false
	for unused: int in 80:
		if not step_world():
			return false
		if trail_count() >= 2:
			break
	for unused: int in 60:
		var actor: PlayerState = node.world.player()
		if actor.pending_cast_wire_id == 0 and actor.cast_recovery_ticks == 0:
			break
		if not step_world():
			return false
	if node.world.projectiles.is_empty() or node.world.deposits.is_empty() or trail_count() < 2:
		fail("Steam pilot needs an older real Fire trail while its paid parent remains in flight")
		return false
	var old: ElementDepositState = node.world.deposits[0]
	var old_values := Array(old.canonical_values())
	var water_payment := begin_paid_cast(wire_for("water", "bolt"), Vector2i(old.position_x, old.position_y), 2)
	if water_payment.is_empty():
		return false
	for unused: int in 120:
		if not step_world():
			return false
		if not node.world.reactions.is_empty():
			break
	if node.world.reactions.size() != 1:
		fail("Older Fire trail plus new Water terminal must create exactly one real recipe")
		return false
	var reaction: ElementReactionState = node.world.reactions[0]
	var spent_sources: Array[int] = [reaction.source_a, reaction.source_b]
	var spent_live: Array[Dictionary] = []
	for projectile: ProjectileState in node.world.projectiles:
		if projectile.source_cast_id in spent_sources:
			if projectile.material_strength != 0:
				fail("Live parent must retain zero chemistry after its one payload is consumed")
				return false
			spent_live.append({"id": projectile.entity_id, "source_cast_id": projectile.source_cast_id, "material_strength": projectile.material_strength, "damage": projectile.damage})
	if reaction.recipe_wire_id != 310 or spent_live.is_empty() or not node.world.deposits.is_empty() or old.created_tick >= reaction.created_tick:
		fail("Steam evidence needs actual older-trail/new-terminal ordering, a spent live parent, and no leftover source fragments")
		return false
	var evidence := {"kind": "actual_paid_older_trail_new_impact_steam", "older_trail": old_values, "fire_payment": fire_payment, "water_payment": water_payment, "reaction_values": Array(reaction.canonical_values()), "spent_live_projectiles_at_formation": spent_live}
	while node.world.tick < reaction.active_tick + 12:
		if not step_world() or not no_regenerated_payload(spent_sources):
			return false
	if not await capture("older-fire-trail-water-impact-steam-active", evidence):
		return false
	while node.world.tick <= reaction.expiry_tick:
		if not step_world() or not no_regenerated_payload(spent_sources):
			return false
	if not node.world.projectiles.is_empty() or not node.world.deposits.is_empty() or not node.world.reactions.is_empty() or chemistry_events.size() != 1:
		fail("Spent parents must finish without daughter matter or repeated chemistry")
		return false
	evidence["no_payload_regeneration_through_tick"] = node.world.tick
	evidence["chemistry_formed_events"] = chemistry_events.duplicate(true)
	return await capture("steam-expired-no-child-matter", evidence)


func no_regenerated_payload(spent_sources: Array[int]) -> bool:
	for deposit: ElementDepositState in node.world.deposits:
		if deposit.source_cast_id in spent_sources:
			fail("Consumed casts regenerated a trail or terminal")
			return false
	for projectile: ProjectileState in node.world.projectiles:
		if projectile.source_cast_id in spent_sources and projectile.material_strength != 0:
			fail("Consumed projectile regained chemistry")
			return false
	return true


func step_world(commands: Array[SimCommand] = []) -> bool:
	if not node.world.step(commands):
		fail("Actual integrated simulation step failed: " + node.world.last_error)
		return false
	for event: Dictionary in node.world.combat_events:
		if String(event.get("type", "")) == "chemistry_formed":
			chemistry_events.append(event.duplicate(true))
	sync_fixture()
	return true


func sync_fixture() -> void:
	var actor: PlayerState = node.world.player()
	node.current_position = Vector2(actor.position_x, actor.position_y) / 1000.0
	node.previous_position = node.current_position
	node.previous_air_height = actor.air_height
	node.actor_motion_history.capture(node.world.players)


func trail_count() -> int:
	var count := 0
	for deposit: ElementDepositState in node.world.deposits:
		if deposit.is_trail():
			count += 1
	return count


func capture(name: String, evidence: Dictionary) -> bool:
	var before: String = node.world.state_hash()
	node.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	var footprint_audit := audit_footprints(name)
	var reaction_draws: Array[Dictionary] = []
	for reaction: ElementReactionState in node.world.reactions:
		var model: Dictionary = node.element_chemistry_presenter.reaction_model(reaction, ElementChemistrySystem.recipe(reaction.recipe_wire_id), node.world.tick)
		var summary := {"id": reaction.entity_id, "model_empty": model.is_empty(), "stats": node.element_chemistry_presenter.stats()}
		if not model.is_empty():
			summary["polygon_count"] = model.mask.polygons.size()
			summary["frame_empty"] = model.frame.is_empty()
			summary["footprint_cells"] = node.element_chemistry_presenter.footprint_cells(model).size()
			summary["opacity"] = model.material_opacity
		reaction_draws.append(summary)
		if name.contains("rampart"):
			print("RAMPART DRAW ", JSON.stringify(summary))
	if not (footprint_audit.invalid_parts as Array).is_empty():
		fail("Actual cached footprint triangles are invalid: " + name)
		return false
	var pixels := viewport.get_texture().get_image()
	if name.contains("rampart-contact"):
		node.hide_chemistry_for_visual_probe = true
		node.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		var baseline := viewport.get_texture().get_image()
		var changed := 0
		var strong := 0
		for y: int in range(280,400):
			for x: int in range(580,700):
				var delta: Color = pixels.get_pixel(x,y) - baseline.get_pixel(x,y)
				var amount := maxf(absf(delta.r), maxf(absf(delta.g), absf(delta.b)))
				changed += 1 if amount > 0.02 else 0
				strong += 1 if amount > 0.12 else 0
		evidence["actual_ridge_changed_pixels"] = changed
		evidence["actual_ridge_strong_pixels"] = strong
		print("RAMPART PIXELS changed=", changed, " strong=", strong)
		node.hide_chemistry_for_visual_probe = false
		node.queue_redraw()
		if strong < 900:
			fail("Active Rampart needs a visibly distinct solid footprint at actual gameplay scale")
			return false
	if pixels == null or pixels.save_png(output.path_join(name + ".png")) != OK or before != node.world.state_hash():
		fail("Integrated image capture failed or drawing changed authority: " + name)
		return false
	var deposits: Array[Dictionary] = []
	for deposit: ElementDepositState in node.world.deposits:
		deposits.append({"id": deposit.entity_id, "source_cast_id": deposit.source_cast_id, "element": deposit.element_wire_id, "role": "trail" if deposit.is_trail() else "terminal", "radius": deposit.radius, "strength": deposit.strength, "position": [deposit.position_x, deposit.position_y], "created_tick": deposit.created_tick, "expiry_tick": deposit.expiry_tick})
	var projectiles: Array[Dictionary] = []
	for projectile: ProjectileState in node.world.projectiles:
		projectiles.append({"id": projectile.entity_id, "source_cast_id": projectile.source_cast_id, "element": projectile.element_wire_id, "material_strength": projectile.material_strength, "position": [projectile.position_x, projectile.position_y]})
	var record := {"file": name + ".png", "tick": node.world.tick, "champion": node.selected_champion_id, "world_hash": before, "trail_count": trail_count(), "deposits": deposits, "projectiles": projectiles, "reaction_count": node.world.reactions.size(), "footprint_audit": footprint_audit}
	record.merge(evidence)
	record["reaction_draws"] = reaction_draws
	records.append(record)
	print("RENDERED ", output.path_join(name + ".png"))
	return true


func audit_footprints(frame_name: String) -> Dictionary:
	# Re-read the exact production clipping cache after drawing. This is a
	# capture-only diagnostic; no triangulation repair or state injection.
	var result := {"checked_parts": 0, "checked_triangles": 0, "invalid_parts": [], "legacy_world_failures": []}
	var sources: Array = []
	sources.append_array(node.world.deposits)
	sources.append_array(node.world.reactions)
	for deposit: RefCounted in sources:
		var model: Dictionary = node.element_chemistry_presenter.deposit_model(deposit, float(node.world.tick), false) if deposit is ElementDepositState else node.element_chemistry_presenter.reaction_model(deposit, ElementChemistrySystem.recipe(deposit.recipe_wire_id), float(node.world.tick))
		for cell: Dictionary in node.element_chemistry_presenter.footprint_cells(model):
			for part: Dictionary in cell.parts:
				result.checked_parts += 1
				var indices: PackedInt32Array = part.get("indices", PackedInt32Array())
				var expected := PixelEffectGeometry.local_triangle_indices(part.points)
				var valid := not indices.is_empty() and indices.size() % 3 == 0 and indices == expected
				for index: int in indices:
					valid = valid and index >= 0 and index < part.points.size()
				if valid:
					for offset: int in range(0, indices.size(), 3):
						var origin: Vector2 = part.points[indices[offset]]
						var edge_a: Vector2 = part.points[indices[offset + 1]] - origin
						var edge_b: Vector2 = part.points[indices[offset + 2]] - origin
						valid = valid and edge_a.is_finite() and edge_b.is_finite() and absf(edge_a.cross(edge_b)) > 0.0
						result.checked_triangles += 1
				var legacy_failed := Geometry2D.triangulate_polygon(part.points).is_empty()
				if valid and not legacy_failed:
					continue
				var points: Array = []
				for point: Vector2 in part.points:
					points.append([point.x, point.y])
				var local_points: PackedVector2Array = part.points.duplicate()
				if not local_points.is_empty():
					var local_origin := local_points[0]
					for index: int in range(local_points.size()):
						local_points[index] -= local_origin
				var details := {"frame": frame_name, "deposit_values": Array(deposit.canonical_values()), "points": points, "indices": Array(indices), "cell_anchor": [cell.anchor.x, cell.anchor.y], "local_origin_triangulates": not Geometry2D.triangulate_polygon(local_points).is_empty(), "production_triangles_valid": valid}
				if legacy_failed:
					result.legacy_world_failures.append(details)
					print("LEGACY_WORLD_TRIANGULATION ", JSON.stringify(details))
				if not valid:
					result.invalid_parts.append(details)
					print("INVALID_FOOTPRINT ", JSON.stringify(details))
	return result


func fail(message: String) -> void:
	push_error(message)
	quit(1)
