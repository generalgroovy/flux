extends Node2D


const MAX_CATCH_UP_STEPS: int = 8
const SNAPSHOT_TICK_INTERVAL: int = 2
const HUB_DEFINITION_PATH: String = "res://content/maps/sanctum_hub_v1.json"
const CAMPUS_LAYOUT_PATH: String = "res://content/maps/sanctum_campus_g2_v1.json"
const ABILITY_CATALOG_PATH: String = "res://content/abilities/foundation_abilities_v1.json"
const CHAMPION_CATALOG_PATH: String = "res://content/champions/foundation_champions_v1.json"
const LOADOUT_PATH: String = "res://content/loadouts/foundation_practitioner_v1.json"
const MATERIAL_CATALOG_PATH: String = "res://content/materials/foundation_materials_v1.json"
const MATERIAL_YARD_PATH: String = "res://content/maps/sanctum_material_yard_v1.json"
const WATER_COLOR := Color("153c4a")
const WATER_HIGHLIGHT_COLOR := Color("28677a")
const FOREST_SHADOW_COLOR := Color("17261b")
const GRASS_COLOR := Color("304b27")
const MOSS_COLOR := Color("66834a")
const PATH_COLOR := Color("8b7045")
const PALE_STONE_COLOR := Color("b6a477")
const WORLDBONE_COLOR := Color("26282a")
const TIMBER_COLOR := Color("4b3226")
const BRASS_COLOR := Color("b88438")
const ATTUNEMENT_COLOR := Color("55dbe0")
const FLUX_COLOR := Color("9b65d9")
const FIRE_COLOR := Color("e58a38")
const PARCHMENT_COLOR := Color("e2d8b2")
const PANEL_COLOR := Color("11130ee6")
const PLAYER_COLOR := ATTUNEMENT_COLOR
const POV_MASK_COLOR := Color("090d0be8")
const POV_EDGE_COLOR := Color("6f8c72a8")

var world: SimWorld
var input_router: InputRouter
var hub_definition: HubDefinition
var campus_layout: SanctumCampusLayout
var campus_renderer: SanctumCampusRenderer
var ability_catalog: AbilityCatalog
var champion_catalog: ChampionCatalog
var loadout: LoadoutDefinition
var material_registry: MaterialRegistry
var material_yard: MaterialYardDefinition
var material_grid: MaterialGrid
var material_preview_texture: ImageTexture
var player_preferences: PlayerPreferences
var player_sprite: WellspringCharacterSprite
var session_transport: SessionTransport
var authoritative_session: AuthoritativeSession
var session_names_by_entity: Dictionary[int, String] = {}
var remote_player_sprites: Dictionary[int, WellspringCharacterSprite] = {}
var tick_rate: int = 120
var accumulator_seconds: float = 0.0
var previous_position := Vector2.ZERO
var current_position := Vector2.ZERO
var dropped_time_seconds: float = 0.0
var show_debug_overlay: bool = false
var capture_pointer_world := Vector2i(-1, -1)
var focused_station_id: String = ""
var expanded_station_id: String = ""
var station_notice: String = ""
var station_notice_seconds: float = 0.0
var selected_champion_id: String = "oh_tipi"
var join_address: String = "127.0.0.1"
var session_port: int = SessionTransport.DEFAULT_PORT
var local_player_name: String = "Traveller"
var requested_farflow_mode: String = ""
var client_input_sequence: int = 0
var client_replica_active: bool = false
var last_client_snapshot_tick: int = -1
var network_projectile_overflow: int = 0
var combat_cues: Array[Dictionary] = []


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	player_preferences = PlayerPreferences.new()
	var preferences_existed: bool = FileAccess.file_exists(PlayerPreferences.DEFAULT_PATH)
	if not player_preferences.load_from_file():
		push_warning("%s; using safe defaults" % player_preferences.last_error)
		player_preferences.reset_to_defaults()
	if not preferences_existed and not player_preferences.save_to_file():
		push_warning(player_preferences.last_error)
	_apply_preference_overrides()
	hub_definition = HubDefinition.new()
	if not hub_definition.load_from_file(HUB_DEFINITION_PATH):
		push_error(hub_definition.last_error)
		get_tree().quit(1)
		return
	campus_layout = SanctumCampusLayout.new()
	if not campus_layout.load_from_file(CAMPUS_LAYOUT_PATH):
		push_error(campus_layout.last_error)
		get_tree().quit(1)
		return
	campus_renderer = SanctumCampusRenderer.new()
	capture_pointer_world = _requested_capture_pointer()
	ability_catalog = AbilityCatalog.new()
	if not ability_catalog.load_from_file(ABILITY_CATALOG_PATH):
		push_error(ability_catalog.last_error)
		get_tree().quit(1)
		return
	champion_catalog = ChampionCatalog.new()
	if not champion_catalog.load_from_file(CHAMPION_CATALOG_PATH, ability_catalog):
		push_error(champion_catalog.last_error)
		get_tree().quit(1)
		return
	selected_champion_id = _requested_champion_id()
	join_address = _requested_join_address()
	session_port = _requested_session_port()
	local_player_name = _requested_player_name()
	requested_farflow_mode = _requested_farflow_mode()
	session_transport = SessionTransport.new()
	authoritative_session = AuthoritativeSession.new()
	_load_player_sprite_candidate()
	loadout = LoadoutDefinition.new()
	if not loadout.load_from_file(LOADOUT_PATH, ability_catalog):
		push_error(loadout.last_error)
		get_tree().quit(1)
		return
	material_registry = MaterialRegistry.new()
	if not material_registry.load_from_file(MATERIAL_CATALOG_PATH):
		push_error(material_registry.last_error)
		get_tree().quit(1)
		return
	material_yard = MaterialYardDefinition.new()
	if not material_yard.load_from_file(MATERIAL_YARD_PATH, material_registry):
		push_error(material_yard.last_error)
		get_tree().quit(1)
		return
	tick_rate = _requested_tick_rate()
	if not _start_match(tick_rate):
		get_tree().quit(1)
		return
	_start_requested_farflow()
	print(
		"FLUX2 bootstrap: %d Hz, protocol %d, controls %s, POV %s/%d/%d, Sanctum districts %d, travel nodes %d, campus %s, ability catalog %s, champions %s, build %d/13, materials %s, yard %s"
		% [
			tick_rate,
			SimConfig.PROTOCOL_VERSION,
			player_preferences.movement_reference,
			player_preferences.pov_mode,
			player_preferences.pov_angle_degrees,
			player_preferences.pov_range,
			hub_definition.districts_by_id.size(),
			hub_definition.travel_nodes_by_id.size(),
			campus_layout.content_hash.left(12),
			ability_catalog.content_hash.left(12),
			champion_catalog.content_hash.left(12),
			loadout.active_points,
			material_registry.content_hash.left(12),
			material_yard.content_hash.left(12),
		]
	)
	set_process(true)
	queue_redraw()


func _exit_tree() -> void:
	if session_transport != null:
		session_transport.stop()
	_clear_player_sprite_candidate()
	_clear_remote_player_sprites()


func _process(delta: float) -> void:
	if session_transport != null:
		session_transport.poll()
		_sync_session_transport()
	_handle_preference_actions()
	if Input.is_action_just_pressed(&"toggle_debug_overlay"):
		show_debug_overlay = not show_debug_overlay
	if Input.is_action_just_pressed(&"reset_match"):
		if session_transport.is_connected_client():
			station_notice = "Only the Farflow host can restore the shared court."
			station_notice_seconds = 2.5
		elif not _start_match(tick_rate):
			set_process(false)
			return
	if Input.is_action_just_pressed(&"toggle_tick_rate"):
		if session_transport.is_online():
			station_notice = "Close Farflow before changing the simulation cadence."
			station_notice_seconds = 2.5
		elif not _start_match(60 if tick_rate == 120 else 120):
			set_process(false)
			return
	_update_station_focus()
	station_notice_seconds = maxf(0.0, station_notice_seconds - delta)
	_update_combat_cues(delta)
	if Input.is_action_just_pressed(InputRouter.INTERACT_ACTION):
		_activate_focused_station()

	var fixed_delta: float = 1.0 / float(tick_rate)
	accumulator_seconds += minf(delta, 0.1)
	var steps: int = 0
	while accumulator_seconds >= fixed_delta and steps < MAX_CATCH_UP_STEPS:
		previous_position = current_position
		var pointer_world_position := Vector2(capture_pointer_world) if capture_pointer_world.x >= 0 else get_viewport().get_mouse_position() + _camera_origin(current_position)
		var command: SimCommand = input_router.sample(
			world.tick,
			current_position,
			pointer_world_position,
		)
		if session_transport.is_connected_client():
			client_input_sequence += 1
			if not session_transport.send_input(client_input_sequence, command):
				station_notice = "Farflow input could not reach the host."
				station_notice_seconds = 1.0
		else:
			var commands: Array[SimCommand] = [command]
			if session_transport.is_host():
				commands = authoritative_session.commands_for_tick(command)
			if not world.step(commands):
				push_error(world.last_error)
				set_process(false)
				break
			_ingest_combat_cues(world.combat_events)
			if session_transport.is_host() and world.tick % SNAPSHOT_TICK_INTERVAL == 0:
				authoritative_session.record_combat_events(world.combat_events)
				if session_transport.broadcast_snapshot(authoritative_session.capture_snapshot()):
					authoritative_session.acknowledge_snapshot()
			elif session_transport.is_host():
				authoritative_session.record_combat_events(world.combat_events)
			current_position = _player_position()
		accumulator_seconds -= fixed_delta
		steps += 1
	if accumulator_seconds >= fixed_delta:
		dropped_time_seconds += accumulator_seconds - fmod(accumulator_seconds, fixed_delta)
		accumulator_seconds = fmod(accumulator_seconds, fixed_delta)
	queue_redraw()


func _draw() -> void:
	var alpha: float = clampf(accumulator_seconds * float(tick_rate), 0.0, 1.0)
	var rendered_position: Vector2 = previous_position.lerp(current_position, alpha)
	var camera_origin: Vector2 = _camera_origin(rendered_position)
	draw_set_transform(-camera_origin)
	campus_renderer.draw(self, campus_layout, world.tick)
	_draw_practice_targets(camera_origin)
	if show_debug_overlay:
		for obstacle: CollisionWorld.Obstacle in world.collision.obstacles:
			var rectangle := Rect2(
				Vector2(float(obstacle.minimum_x) / 1000.0, float(obstacle.minimum_y) / 1000.0),
				Vector2(float(obstacle.maximum_x - obstacle.minimum_x) / 1000.0, float(obstacle.maximum_y - obstacle.minimum_y) / 1000.0),
			)
			draw_rect(rectangle, Color(BRASS_COLOR if obstacle.vaultable else ATTUNEMENT_COLOR, 0.18), true)
			draw_rect(rectangle, BRASS_COLOR if obstacle.vaultable else ATTUNEMENT_COLOR, false, 2.0)
	for projectile: ProjectileState in world.projectiles:
		var projectile_position := Vector2(float(projectile.position_x) / 1000.0, float(projectile.position_y) / 1000.0)
		var projectile_color: Color = _projectile_color(projectile.element_wire_id)
		_draw_projectile(projectile, projectile_position, projectile_color)
	_draw_combat_cues(camera_origin)
	var state: PlayerState = _local_player_state()
	if state == null:
		return
	_draw_remote_travellers(camera_origin, state.entity_id)
	var presentation := JumpPresentation.sample(state, world.config, alpha, player_preferences.reduced_motion)
	var landing := LandingPresentation.sample(state, world.config, alpha, player_preferences.reduced_motion)
	var player_radius: float = float(state.radius) / 1000.0
	var shadow_center := rendered_position + Vector2(0.0, player_radius * 0.58)
	var shadow_scale: Vector2 = landing.shadow_scale if landing.active else presentation.shadow_scale
	draw_set_transform(
		shadow_center - camera_origin,
		0.0,
		Vector2(player_radius * shadow_scale.x, player_radius * shadow_scale.y),
	)
	draw_circle(Vector2.ZERO, 1.0, Color(FOREST_SHADOW_COLOR, presentation.shadow_opacity))
	draw_set_transform(-camera_origin)
	if landing.active:
		_draw_landing_cue(shadow_center, landing)
	var body_position := rendered_position + Vector2(0.0, -float(presentation.body_lift_pixels))
	var sprite_drawn: bool = false
	if player_sprite != null:
		if player_sprite.sync_from_player(state, world.config, world.tick, alpha):
			var sprite_anchor := shadow_center + Vector2(0.0, -float(presentation.body_lift_pixels))
			draw_texture_rect_region(
				player_sprite.texture,
				WellspringCharacterSprite.destination_rect(sprite_anchor),
				player_sprite.region_rect,
			)
			sprite_drawn = true
		else:
			push_warning("Champion presentation candidate disabled: %s" % player_sprite.last_error)
			_clear_player_sprite_candidate()
	if not sprite_drawn:
		draw_circle(body_position, player_radius + 5.0, Color(ATTUNEMENT_COLOR, 0.18))
		draw_circle(body_position, player_radius, PLAYER_COLOR)
		draw_arc(body_position, player_radius + 2.0, 0.0, TAU, 24, PARCHMENT_COLOR, 2.0)
	draw_line(body_position, body_position + Vector2(state.aim_x, state.aim_y) * 0.032, Color.WHITE, 3.0)
	_draw_station_bubble(rendered_position)
	draw_set_transform(Vector2.ZERO)
	var rendered_screen_position: Vector2 = rendered_position - camera_origin
	_draw_pov_mask(rendered_screen_position, Vector2(state.aim_x, state.aim_y), camera_origin)
	draw_rect(Rect2(16, 14, 1248, 96), PANEL_COLOR, true)
	draw_rect(Rect2(16, 14, 1248, 96), BRASS_COLOR.darkened(0.3), false, 2.0)
	var champion_data: Dictionary = champion_catalog.champion(selected_champion_id)
	var champion_name := String(champion_data.get("display_name", selected_champion_id))
	var champion_kit: Dictionary = champion_data.get("foundation_kit", {})
	var primary_ability: Dictionary = ability_catalog.ability(String(champion_kit.get("primary", "")))
	var active_ability: Dictionary = ability_catalog.ability(String(champion_kit.get("active_1", "")))
	var primary_name := String(primary_ability.get("display_name", "PRIMARY"))
	var active_name := String(active_ability.get("display_name", "ACTIVE"))
	draw_string(ThemeDB.fallback_font, Vector2(32, 42), "%s · THE WELLSPRING" % champion_name.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 22, PARCHMENT_COLOR)
	var movement_name: String = String(PlayerState.MovementMode.keys()[state.movement_mode]).replace("_", " ")
	draw_string(ThemeDB.fallback_font, Vector2(400, 40), "%s · %s" % [movement_name, _readable_event(state)], HORIZONTAL_ALIGNMENT_RIGHT, 280.0, 13, ATTUNEMENT_COLOR)
	_draw_resource_bar(Rect2(700, 24, 168, 20), "HEALTH", state.health, state.health_maximum, Color("d9634f"))
	_draw_resource_bar(Rect2(884, 24, 168, 20), "FLUX", state.flux, state.flux_maximum, FLUX_COLOR)
	_draw_resource_bar(Rect2(1068, 24, 168, 20), "STAMINA", state.stamina, state.stamina_maximum, ATTUNEMENT_COLOR)
	draw_string(ThemeDB.fallback_font, Vector2(32, 70), "WASD MOVE · SHIFT SPRINT · CTRL/C SLIDE · SPACE JUMP · V TECHNIQUE", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, PALE_STONE_COLOR)
	draw_string(ThemeDB.fallback_font, Vector2(700, 70), _session_label(), HORIZONTAL_ALIGNMENT_RIGHT, 536.0, 12, ATTUNEMENT_COLOR if session_transport.is_online() else PALE_STONE_COLOR)
	var view_description := "FULL" if player_preferences.pov_mode == PlayerPreferences.POV_FULL else "CONE %d°/%d" % [player_preferences.pov_angle_degrees, player_preferences.pov_range]
	draw_string(
		ThemeDB.fallback_font,
		Vector2(32, 96),
		"LMB %s · RMB/E %s · F INTERACT · F8 VIEW %s"
		% [primary_name.to_upper(), _active_hint(state, active_name, active_ability), view_description],
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		13,
		ATTUNEMENT_COLOR,
	)
	if show_debug_overlay and dropped_time_seconds > 0.0:
		draw_string(ThemeDB.fallback_font, Vector2(32, 132), "BOUNDED CATCH-UP DROPPED %.3fs" % dropped_time_seconds, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, FIRE_COLOR)
	if show_debug_overlay:
		_draw_material_yard_preview()


func _draw_resource_bar(rectangle: Rect2, label: String, value: int, maximum: int, color: Color) -> void:
	var ratio: float = clampf(float(value) / float(maximum), 0.0, 1.0)
	draw_rect(rectangle, Color(FOREST_SHADOW_COLOR, 0.92), true)
	draw_rect(Rect2(rectangle.position + Vector2(2, 2), Vector2((rectangle.size.x - 4.0) * ratio, rectangle.size.y - 4.0)), color, true)
	draw_rect(rectangle, Color(PARCHMENT_COLOR, 0.65), false, 1.0)
	draw_string(ThemeDB.fallback_font, rectangle.position + Vector2(7, 15), "%s %d/%d" % [label, value / 1000, maximum / 1000], HORIZONTAL_ALIGNMENT_LEFT, rectangle.size.x - 12.0, 12, Color.WHITE)


func _ingest_combat_cues(events: Array[Dictionary]) -> void:
	for event: Dictionary in events:
		var kind := String(event.get("type", ""))
		if kind not in ["projectile_hit", "edgeweave", "cast_refused", "cast_blocked", "projectile_bounced"]:
			continue
		var anchor := _combat_event_anchor(event)
		if anchor.is_empty():
			continue
		var label: String = ""
		var color: Color = ATTUNEMENT_COLOR
		match kind:
			"projectile_hit":
				label = "-%d" % (int(event.get("damage", 0)) / 1000)
				color = FIRE_COLOR
			"edgeweave":
				label = "EDGE +%d" % (int(event.get("stamina", 0)) / 1000)
				color = ATTUNEMENT_COLOR
			"cast_refused":
				label = "NO FLUX" if String(event.get("reason", "")) == "flux" else "CAST REFUSED"
				color = FLUX_COLOR
			"cast_blocked":
				label = "BLOCKED"
				color = PALE_STONE_COLOR
			"projectile_bounced":
				label = "RICOCHET"
				color = PARCHMENT_COLOR
		combat_cues.append({
			"position": anchor["position"],
			"label": label,
			"color": color,
			"remaining": 0.55,
			"duration": 0.55,
		})
	while combat_cues.size() > 24:
		combat_cues.pop_front()


func _combat_event_anchor(event: Dictionary) -> Dictionary:
	var kind := String(event.get("type", ""))
	var entity_id: int = 0
	if kind == "projectile_hit":
		entity_id = int(event.get("target_id", 0))
	elif kind in ["edgeweave", "cast_refused", "cast_blocked"]:
		entity_id = int(event.get("entity_id", 0))
	if entity_id > 0:
		var state: PlayerState = world.player(entity_id)
		if state != null:
			return {"position": Vector2(float(state.position_x) / 1000.0, float(state.position_y) / 1000.0)}
	var projectile_id := int(event.get("projectile_id", 0))
	for projectile: ProjectileState in world.projectiles:
		if projectile.entity_id == projectile_id:
			return {"position": Vector2(float(projectile.position_x) / 1000.0, float(projectile.position_y) / 1000.0)}
	return {}


func _update_combat_cues(delta: float) -> void:
	for index: int in range(combat_cues.size() - 1, -1, -1):
		var cue: Dictionary = combat_cues[index]
		cue["remaining"] = float(cue.get("remaining", 0.0)) - delta
		if float(cue["remaining"]) <= 0.0:
			combat_cues.remove_at(index)
		else:
			combat_cues[index] = cue


func _draw_combat_cues(camera_origin: Vector2) -> void:
	draw_set_transform(-camera_origin)
	for cue: Dictionary in combat_cues:
		var remaining := float(cue.get("remaining", 0.0))
		var duration := maxf(0.001, float(cue.get("duration", 0.55)))
		var phase := clampf(1.0 - remaining / duration, 0.0, 1.0)
		var position: Vector2 = cue.get("position", Vector2.ZERO)
		var color: Color = cue.get("color", ATTUNEMENT_COLOR)
		var opacity := 1.0 - phase
		draw_arc(position, 10.0 + phase * 22.0, 0.0, TAU, 20, Color(color, opacity * 0.8), 2.0)
		var label := String(cue.get("label", ""))
		var label_width := ThemeDB.fallback_font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x
		draw_string(ThemeDB.fallback_font, position + Vector2(-label_width * 0.5, -28.0 - phase * 18.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 11, Color(color, opacity))


func _draw_remote_travellers(camera_origin: Vector2, local_entity_id: int) -> void:
	for remote_state: PlayerState in world.players:
		if remote_state.actor_kind != PlayerState.ActorKind.CHAMPION or remote_state.entity_id == local_entity_id:
			continue
		var position := Vector2(float(remote_state.position_x) / 1000.0, float(remote_state.position_y) / 1000.0)
		var presentation := JumpPresentation.sample(remote_state, world.config, 0.0, player_preferences.reduced_motion)
		var landing := LandingPresentation.sample(remote_state, world.config, 0.0, player_preferences.reduced_motion)
		var radius := float(remote_state.radius) / 1000.0
		var shadow_center := position + Vector2(0.0, radius * 0.58)
		var shadow_scale: Vector2 = landing.shadow_scale if landing.active else presentation.shadow_scale
		draw_set_transform(shadow_center - camera_origin, 0.0, Vector2(radius * shadow_scale.x, radius * shadow_scale.y))
		draw_circle(Vector2.ZERO, 1.0, Color(FOREST_SHADOW_COLOR, presentation.shadow_opacity))
		draw_set_transform(-camera_origin)
		if landing.active:
			_draw_landing_cue(shadow_center, landing)
		var body_position := position + Vector2(0.0, -float(presentation.body_lift_pixels))
		var sprite := _remote_player_sprite(remote_state)
		var sprite_drawn: bool = false
		if sprite != null and sprite.sync_from_player(remote_state, world.config, world.tick, 0.0):
			var sprite_anchor := shadow_center + Vector2(0.0, -float(presentation.body_lift_pixels))
			draw_texture_rect_region(sprite.texture, WellspringCharacterSprite.destination_rect(sprite_anchor), sprite.region_rect)
			sprite_drawn = true
		if not sprite_drawn:
			var body_color := FLUX_COLOR if remote_state.champion_wire_id == 2 else ATTUNEMENT_COLOR
			draw_circle(body_position, radius + 5.0, Color(body_color, 0.18))
			draw_circle(body_position, radius, body_color)
			draw_arc(body_position, radius + 2.0, 0.0, TAU, 24, PARCHMENT_COLOR, 2.0)
		draw_line(body_position, body_position + Vector2(remote_state.aim_x, remote_state.aim_y) * 0.032, Color(PARCHMENT_COLOR, 0.9), 2.0)
		var display_name := String(session_names_by_entity.get(remote_state.entity_id, "TRAVELLER %d" % remote_state.entity_id)).to_upper()
		var name_width := ThemeDB.fallback_font.get_string_size(display_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
		var label_position := body_position + Vector2(-name_width * 0.5, -43.0)
		draw_string(ThemeDB.fallback_font, label_position, display_name, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 10, PARCHMENT_COLOR)
		var health_bar := Rect2(body_position + Vector2(-22.0, -37.0), Vector2(44.0, 4.0))
		draw_rect(health_bar, Color(FOREST_SHADOW_COLOR, 0.9), true)
		var health_ratio := clampf(float(remote_state.health) / float(maxi(1, remote_state.health_maximum)), 0.0, 1.0)
		draw_rect(Rect2(health_bar.position + Vector2.ONE, Vector2((health_bar.size.x - 2.0) * health_ratio, 2.0)), Color("d9634f"), true)
	draw_set_transform(-camera_origin)


func _remote_player_sprite(state: PlayerState) -> WellspringCharacterSprite:
	var champion_id := champion_catalog.champion_id_from_wire(state.champion_wire_id)
	if champion_id.is_empty():
		return null
	if remote_player_sprites.has(state.entity_id):
		var retained: WellspringCharacterSprite = remote_player_sprites[state.entity_id]
		if retained.source_id == champion_id:
			return retained
		_clear_remote_player_sprite(state.entity_id)
	var sprite := WellspringCharacterSprite.new()
	sprite.source_kind = "champion"
	sprite.source_id = champion_id
	sprite.playing = false
	if not sprite.load_source():
		sprite.free()
		return null
	remote_player_sprites[state.entity_id] = sprite
	return sprite


func _clear_remote_player_sprite(entity_id: int) -> void:
	if not remote_player_sprites.has(entity_id):
		return
	var sprite: WellspringCharacterSprite = remote_player_sprites[entity_id]
	sprite.texture = null
	sprite.free()
	remote_player_sprites.erase(entity_id)


func _clear_remote_player_sprites() -> void:
	var entity_ids: Array[int] = remote_player_sprites.keys()
	for entity_id: int in entity_ids:
		_clear_remote_player_sprite(entity_id)


func _prune_remote_player_sprites() -> void:
	var entity_ids: Array[int] = remote_player_sprites.keys()
	for entity_id: int in entity_ids:
		var state: PlayerState = world.player(entity_id)
		if state == null or state.actor_kind != PlayerState.ActorKind.CHAMPION:
			_clear_remote_player_sprite(entity_id)


func _readable_event(state: PlayerState) -> String:
	for prefix: String in ["cast_start_", "cast_release_", "cast_blocked_"]:
		if state.last_event.begins_with(prefix):
			var wire_text := state.last_event.trim_prefix(prefix)
			var ability_id := String(ability_catalog.ability_ids_by_wire.get(wire_text.to_int(), ""))
			var ability_name := String(ability_catalog.ability(ability_id).get("display_name", "SPELL")).to_upper()
			if prefix == "cast_start_":
				return "CHANNEL %s" % ability_name
			if prefix == "cast_blocked_":
				return "%s BLOCKED" % ability_name
			return ability_name
	if state.last_event.begins_with("champion_"):
		return "ATTUNED"
	return state.last_event.replace("_", " ").to_upper()


func _active_hint(state: PlayerState, ability_name: String, ability: Dictionary) -> String:
	if state.active_1_cooldown_ticks > 0:
		return "%s %.1fs" % [ability_name.to_upper(), float(state.active_1_cooldown_ticks) / float(world.config.tick_rate)]
	return "%s %d FLUX" % [ability_name.to_upper(), int(ability.get("flux_cost", 0))]


func _draw_landing_cue(center: Vector2, landing: LandingPresentation.Sample) -> void:
	var color := Color(ATTUNEMENT_COLOR, landing.ring_opacity)
	draw_arc(center, landing.ring_radius, 0.0, TAU, 20, color, landing.ring_width)
	for direction: Vector2 in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]:
		var inner := center + direction * (landing.ring_radius - 2.0)
		var outer := center + direction * (landing.ring_radius + 2.0)
		draw_line(inner, outer, color, landing.ring_width)


func _draw_station_bubble(player_position: Vector2) -> void:
	if station_notice_seconds > 0.0 and not station_notice.is_empty():
		_draw_transparent_bubble(player_position + Vector2(0, -76), "WELLSPRING", [station_notice], true)
		return
	if focused_station_id.is_empty() or not campus_layout.stations_by_id.has(focused_station_id):
		return
	var station: Dictionary = campus_layout.stations_by_id[focused_station_id]
	var values: Array = station.get("position", [])
	var station_position := Vector2(float(values[0]), float(values[1]))
	var expanded: bool = expanded_station_id == focused_station_id
	var lines: Array = _station_lines(station) if expanded else [String(station.get("prompt", "F  INTERACT"))]
	_draw_transparent_bubble(station_position + Vector2(0, -54), String(station.get("title", "STATION")), lines, expanded)


func _station_lines(station: Dictionary) -> Array:
	var command := String(station.get("command", ""))
	if command == "host_session":
		return [session_transport.status_detail, "UDP %d · %d/8 travellers" % [session_port, session_transport.player_count()], "F closes the gate" if session_transport.is_host() else "F opens a direct friend gate"]
	if command == "join_session":
		return [session_transport.status_detail, "%s:%d" % [join_address, session_port], "F closes the gate" if session_transport.mode != SessionTransport.Mode.OFFLINE else "F seeks the configured friend gate"]
	if command != "champion_switch":
		return station.get("lines", [])
	var current: Dictionary = champion_catalog.champion(selected_champion_id)
	var stats: Dictionary = current.get("stats", {})
	var next_id := champion_catalog.next_champion_id(selected_champion_id)
	var next: Dictionary = champion_catalog.champion(next_id)
	return [
		"ATTUNED: %s · %s" % [String(current.get("display_name", "")).to_upper(), String(current.get("ancestry", "")).to_upper()],
		"HP %d · FLUX %d · STAMINA %d · SPEED %d%%" % [int(stats.get("health_maximum", 0)) / 1000, int(stats.get("flux_maximum", 0)) / 1000, int(stats.get("stamina_maximum", 0)) / 1000, int(stats.get("movement_speed_ratio", 0)) / 10],
		"F attunes %s" % String(next.get("display_name", next_id)),
	]


func _sync_session_transport() -> void:
	if session_transport.is_host():
		var joined := session_transport.take_joined_peers()
		if not joined.is_empty():
			authoritative_session.register_peers(joined)
			session_names_by_entity = authoritative_session.names_by_entity.duplicate()
			for event: Dictionary in joined:
				print("FLUX2 farflow host: joined entity %d (%s)" % [int(event.get("entity_id", 0)), String(event.get("name", "Traveller"))])
		var disconnected := session_transport.take_disconnected_peers()
		if not disconnected.is_empty():
			for event: Dictionary in disconnected:
				_clear_remote_player_sprite(int(event.get("entity_id", 0)))
				print("FLUX2 farflow host: left entity %d (%s)" % [int(event.get("entity_id", 0)), String(event.get("name", "Traveller"))])
			authoritative_session.remove_peers(disconnected)
			session_names_by_entity = authoritative_session.names_by_entity.duplicate()
		authoritative_session.ingest_inputs(session_transport.take_inputs())
		return
	if session_transport.is_connected_client():
		client_replica_active = true
		var snapshots := session_transport.take_snapshots()
		if snapshots.is_empty():
			return
		var snapshot: Dictionary = snapshots.back()
		if int(snapshot.get("tick", -1)) <= last_client_snapshot_tick:
			return
		var first_snapshot: bool = last_client_snapshot_tick < 0
		if SessionSnapshot.apply_to_world(snapshot, world):
			last_client_snapshot_tick = int(snapshot["tick"])
			network_projectile_overflow = int(snapshot.get("projectile_overflow", 0))
			session_names_by_entity = SessionSnapshot.names(snapshot)
			_prune_remote_player_sprites()
			_ingest_combat_cues(world.combat_events)
			input_router.entity_id = session_transport.local_entity_id
			var local_state := _local_player_state()
			if local_state != null:
				if first_snapshot:
					print("FLUX2 farflow replica: local entity %d, snapshot tick %d, travellers %d" % [local_state.entity_id, world.tick, session_names_by_entity.size()])
				var replicated_champion_id := champion_catalog.champion_id_from_wire(local_state.champion_wire_id)
				if not replicated_champion_id.is_empty() and replicated_champion_id != selected_champion_id:
					selected_champion_id = replicated_champion_id
					_load_player_sprite_candidate()
				var replicated_position := _player_position()
				previous_position = replicated_position if first_snapshot else current_position
				current_position = replicated_position
		return
	if client_replica_active and session_transport.mode == SessionTransport.Mode.OFFLINE:
		var disconnect_message := session_transport.last_error
		client_replica_active = false
		client_input_sequence = 0
		last_client_snapshot_tick = -1
		network_projectile_overflow = 0
		if _start_match(tick_rate):
			station_notice = disconnect_message if not disconnect_message.is_empty() else "The Farflow gate is closed."
			station_notice_seconds = 3.0


func _draw_transparent_bubble(anchor: Vector2, title: String, lines: Array, expanded: bool) -> void:
	var width: float = 264.0 if expanded else 216.0
	var height: float = 38.0 + float(lines.size()) * 17.0
	var rectangle := Rect2(anchor.x - width * 0.5, anchor.y - height, width, height)
	draw_rect(rectangle, Color(PANEL_COLOR, 0.82), true)
	draw_rect(rectangle, Color(BRASS_COLOR, 0.78), false, 2.0)
	var tail := PackedVector2Array([
		Vector2(anchor.x - 8.0, anchor.y),
		Vector2(anchor.x + 8.0, anchor.y),
		Vector2(anchor.x, anchor.y + 10.0),
	])
	draw_colored_polygon(tail, Color(PANEL_COLOR, 0.82))
	draw_string(ThemeDB.fallback_font, rectangle.position + Vector2(12, 18), title, HORIZONTAL_ALIGNMENT_LEFT, width - 24.0, 12, PARCHMENT_COLOR)
	for index: int in range(lines.size()):
		draw_string(ThemeDB.fallback_font, rectangle.position + Vector2(12, 37 + index * 17), String(lines[index]), HORIZONTAL_ALIGNMENT_LEFT, width - 24.0, 11, PALE_STONE_COLOR)


func _update_station_focus() -> void:
	if world == null:
		focused_station_id = ""
		return
	var state: PlayerState = _local_player_state()
	var next_focus := SanctumStationModel.nearest_station_id(
		campus_layout.stations_by_id,
		Vector2i(state.position_x, state.position_y),
	)
	if not expanded_station_id.is_empty() and expanded_station_id != next_focus:
		expanded_station_id = ""
	focused_station_id = next_focus


func _activate_focused_station() -> void:
	if focused_station_id.is_empty() or not campus_layout.stations_by_id.has(focused_station_id):
		return
	var station: Dictionary = campus_layout.stations_by_id[focused_station_id]
	match String(station.get("command", "")):
		"movement_guide":
			expanded_station_id = "" if expanded_station_id == focused_station_id else focused_station_id
		"training_reset":
			if session_transport.is_connected_client():
				station_notice = "Only the Farflow host can restore the shared court."
				station_notice_seconds = 2.5
			elif _start_match(tick_rate):
				station_notice = "The practice court is restored."
				station_notice_seconds = 2.0
				_update_station_focus()
		"champion_switch":
			if session_transport.is_connected_client():
				station_notice = "Shared attunement requests arrive in the next Farflow slice."
				station_notice_seconds = 2.5
				return
			selected_champion_id = champion_catalog.next_champion_id(selected_champion_id)
			if champion_catalog.apply_to_player(_local_player_state(), selected_champion_id):
				_load_player_sprite_candidate()
				var champion_name := String(champion_catalog.champion(selected_champion_id).get("display_name", selected_champion_id))
				station_notice = "Attuned to %s." % champion_name
				station_notice_seconds = 2.0
				expanded_station_id = ""
		"host_session":
			_toggle_host_session()
		"join_session":
			_toggle_join_session()


func _toggle_host_session() -> void:
	if session_transport.mode != SessionTransport.Mode.OFFLINE:
		session_transport.stop()
		client_replica_active = false
		client_input_sequence = 0
		last_client_snapshot_tick = -1
		network_projectile_overflow = 0
		_start_match(tick_rate)
		station_notice = "The Farflow gate is closed."
	else:
		var signature := _session_compatibility_signature()
		if session_transport.start_host(session_port, signature, local_player_name):
			authoritative_session.bind(world, champion_catalog, campus_layout.spawn, local_player_name)
			session_names_by_entity = authoritative_session.names_by_entity.duplicate()
			station_notice = "Friend gate open on UDP %d." % session_port
			print("FLUX2 farflow host: listening on UDP %d" % session_transport.bound_port)
		else:
			station_notice = session_transport.last_error
	station_notice_seconds = 3.0
	expanded_station_id = focused_station_id


func _toggle_join_session() -> void:
	if session_transport.mode != SessionTransport.Mode.OFFLINE:
		session_transport.stop()
		client_replica_active = false
		client_input_sequence = 0
		last_client_snapshot_tick = -1
		network_projectile_overflow = 0
		_start_match(tick_rate)
		station_notice = "The Farflow gate is closed."
	else:
		var signature := _session_compatibility_signature()
		if session_transport.start_join(join_address, session_port, signature, local_player_name):
			station_notice = "Seeking %s:%d." % [join_address, session_port]
			print("FLUX2 farflow join: seeking %s:%d" % [join_address, session_port])
		else:
			station_notice = session_transport.last_error
	station_notice_seconds = 3.0
	expanded_station_id = focused_station_id


func _session_compatibility_signature() -> String:
	return SessionTransport.compatibility_signature(
		SimConfig.PROTOCOL_VERSION,
		tick_rate,
		campus_layout.content_hash,
		ability_catalog.content_hash,
		champion_catalog.content_hash,
	)


func _session_label() -> String:
	if session_transport == null or session_transport.mode == SessionTransport.Mode.OFFLINE:
		return "FARFLOW OFFLINE"
	if session_transport.is_connected_client() and network_projectile_overflow > 0:
		return "FARFLOW LOAD +%d BOLTS" % network_projectile_overflow
	if session_transport.is_host():
		return "FARFLOW HOST %d/8 · UDP %d" % [session_transport.player_count(), session_transport.bound_port]
	if session_transport.is_connected_client():
		return "FARFLOW JOINED · %s" % join_address
	return "FARFLOW SEEKING · %s" % join_address


func _start_requested_farflow() -> void:
	match requested_farflow_mode:
		"host":
			_toggle_host_session()
		"join":
			_toggle_join_session()


func _draw_pov_mask(origin: Vector2, aim: Vector2, camera_origin: Vector2) -> void:
	if player_preferences.pov_mode != PlayerPreferences.POV_CONE:
		return
	var sight_range: float = float(player_preferences.pov_range)
	var viewport_size: Vector2 = get_viewport_rect().size
	var outer_radius: float = maxf(viewport_size.x, viewport_size.y) * 2.25
	var segment_count: int = 96
	for segment: int in range(segment_count):
		var angle_a: float = TAU * float(segment) / float(segment_count)
		var angle_b: float = TAU * float(segment + 1) / float(segment_count)
		_draw_mask_quad(origin, sight_range, outer_radius, angle_a, angle_b)

	var visible_radians: float = deg_to_rad(float(player_preferences.pov_angle_degrees))
	var aim_angle: float = aim.angle() if aim.length_squared() > 0.01 else 0.0
	var half_visible: float = visible_radians * 0.5
	if player_preferences.pov_angle_degrees < PlayerPreferences.MAX_POV_ANGLE_DEGREES:
		var hidden_span: float = TAU - visible_radians
		var hidden_segments: int = maxi(1, ceili(float(segment_count) * hidden_span / TAU))
		var hidden_start: float = aim_angle + half_visible
		var player_safe_radius: float = 30.0
		for segment: int in range(hidden_segments):
			var angle_a: float = hidden_start + hidden_span * float(segment) / float(hidden_segments)
			var angle_b: float = hidden_start + hidden_span * float(segment + 1) / float(hidden_segments)
			_draw_mask_quad(origin, player_safe_radius, sight_range, angle_a, angle_b)
		draw_line(origin + Vector2.from_angle(aim_angle - half_visible) * player_safe_radius, origin + Vector2.from_angle(aim_angle - half_visible) * sight_range, POV_EDGE_COLOR, 1.5)
		draw_line(origin + Vector2.from_angle(aim_angle + half_visible) * player_safe_radius, origin + Vector2.from_angle(aim_angle + half_visible) * sight_range, POV_EDGE_COLOR, 1.5)
	_draw_building_occlusion_shadows(origin, camera_origin, outer_radius)
	draw_arc(origin, sight_range, aim_angle - half_visible, aim_angle + half_visible, maxi(12, ceili(48.0 * visible_radians / TAU)), POV_EDGE_COLOR, 1.5)


func _draw_building_occlusion_shadows(origin: Vector2, camera_origin: Vector2, outer_distance: float) -> void:
	for building_value: Variant in campus_layout.data.get("buildings", []):
		var building: Dictionary = building_value
		if String(building.get("occlusion_policy", "")) != "los_cutaway":
			continue
		var world_bounds := SanctumCampusLayout._parse_bounds(building.get("bounds", []))
		var screen_bounds := Rect2(Vector2(world_bounds.position) - camera_origin, Vector2(world_bounds.size))
		var shadow := SightOcclusion.shadow_polygon(origin, screen_bounds, outer_distance)
		if shadow.size() != 4:
			continue
		draw_colored_polygon(shadow, POV_MASK_COLOR)
		draw_line(shadow[0], shadow[1], POV_EDGE_COLOR, 1.0)
		draw_line(shadow[3], shadow[2], POV_EDGE_COLOR, 1.0)


func _draw_mask_quad(origin: Vector2, inner_radius: float, outer_radius: float, angle_a: float, angle_b: float) -> void:
	var points := PackedVector2Array([
		origin + Vector2.from_angle(angle_a) * inner_radius,
		origin + Vector2.from_angle(angle_a) * outer_radius,
		origin + Vector2.from_angle(angle_b) * outer_radius,
		origin + Vector2.from_angle(angle_b) * inner_radius,
	])
	draw_colored_polygon(points, POV_MASK_COLOR)


func _draw_material_yard_preview() -> void:
	if material_preview_texture == null or material_grid == null:
		return
	var panel := Rect2(1082, 492, 174, 194)
	draw_rect(panel, PANEL_COLOR, true)
	draw_rect(panel, BRASS_COLOR.darkened(0.25), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(1094, 515), "MATERIAL YARD F1", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, PARCHMENT_COLOR)
	draw_texture_rect(material_preview_texture, Rect2(1105, 526, 128, 128), false)
	draw_rect(Rect2(1105, 526, 128, 128), PALE_STONE_COLOR.darkened(0.2), false, 2.0)
	draw_string(
		ThemeDB.fallback_font,
		Vector2(1094, 675),
		"SEED %s · WB %s" % [material_grid.seed_state_hash.left(6), material_grid.seed_worldbone_hash.left(6)],
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		11,
		ATTUNEMENT_COLOR,
	)


func _start_match(requested_tick_rate: int) -> bool:
	focused_station_id = ""
	expanded_station_id = ""
	station_notice = ""
	station_notice_seconds = 0.0
	tick_rate = requested_tick_rate
	world = SimWorld.new(
		tick_rate,
		8675309,
		campus_layout.build_collision_world(),
		String(campus_layout.data.get("id", "")),
		campus_layout.content_hash,
	)
	var player_state: PlayerState = world.player()
	player_state.position_x = campus_layout.spawn.x * SimConfig.FIXED_SCALE
	player_state.position_y = campus_layout.spawn.y * SimConfig.FIXED_SCALE
	if not champion_catalog.apply_to_player(player_state, selected_champion_id):
		push_error("Selected champion could not be applied: %s" % selected_champion_id)
		return false
	_spawn_practice_targets()
	var existing_roster: Array[Dictionary] = []
	if session_transport != null and session_transport.is_host():
		existing_roster = session_transport.host_roster()
	if not authoritative_session.bind(world, champion_catalog, campus_layout.spawn, local_player_name, existing_roster):
		push_error(authoritative_session.last_error)
		return false
	session_names_by_entity = authoritative_session.names_by_entity.duplicate()
	_clear_remote_player_sprites()
	material_grid = MaterialGrid.new()
	if not material_grid.initialize(material_yard, material_registry, world.config):
		push_error(material_grid.last_error)
		return false
	_refresh_material_preview()
	input_router = InputRouter.new(1)
	if not input_router.configure_movement_reference(player_preferences.movement_reference):
		push_error("Invalid movement reference reached match startup")
		return false
	if not input_router.configure_keyboard_bindings(player_preferences.keyboard_bindings):
		push_error("Invalid keyboard bindings reached match startup")
		return false
	accumulator_seconds = 0.0
	dropped_time_seconds = 0.0
	current_position = _player_position()
	previous_position = current_position
	print("FLUX2 match initialized at %d Hz" % tick_rate)
	return true


func _spawn_practice_targets() -> void:
	var target_ids: Array[String] = campus_layout.practice_targets_by_id.keys()
	target_ids.sort()
	for target_id: String in target_ids:
		var definition: Dictionary = campus_layout.practice_targets_by_id[target_id]
		var target := PlayerState.new(int(definition.get("entity_id", 0)))
		target.actor_kind = PlayerState.ActorKind.TRAINING_TARGET
		target.team_id = 2
		var position_values: Array = definition.get("position", [])
		target.position_x = int(position_values[0]) * SimConfig.FIXED_SCALE
		target.position_y = int(position_values[1]) * SimConfig.FIXED_SCALE
		target.radius = int(definition.get("radius", 18)) * SimConfig.FIXED_SCALE
		target.health_maximum = int(definition.get("health", 80_000))
		target.health = target.health_maximum
		target.health_recovery_per_second = 0
		target.flux_maximum = 0
		target.flux = 0
		target.flux_recovery_per_second = 0
		target.stamina_maximum = 0
		target.stamina = 0
		target.stamina_recovery_per_second = 0
		target.movement_speed_ratio = 0
		target.last_event = "target_ready"
		world.players.append(target)


func _draw_practice_targets(camera_origin: Vector2) -> void:
	for target_id: String in campus_layout.practice_targets_by_id:
		var definition: Dictionary = campus_layout.practice_targets_by_id[target_id]
		var state: PlayerState = world.player(int(definition.get("entity_id", 0)))
		if state == null:
			continue
		var position := Vector2(float(state.position_x) / 1000.0, float(state.position_y) / 1000.0)
		var alive: bool = state.health > 0
		draw_set_transform(position - camera_origin + Vector2(2, 9), 0.0, Vector2(20.0, 7.0))
		draw_circle(Vector2.ZERO, 1.0, Color(FOREST_SHADOW_COLOR, 0.62))
		draw_set_transform(-camera_origin)
		var body_color := TIMBER_COLOR if alive else Color("4f463e")
		draw_rect(Rect2(position.x - 4, position.y - 19, 8, 27), body_color, true)
		draw_line(position + Vector2(-13, -7), position + Vector2(13, -7), body_color, 5.0)
		draw_circle(position + Vector2(0, -20), 14.0, Color(WORLDBONE_COLOR, 0.96))
		draw_arc(position + Vector2(0, -20), 11.0, 0.0, TAU, 16, BRASS_COLOR, 3.0)
		if alive:
			draw_circle(position + Vector2(0, -20), 5.0, WATER_HIGHLIGHT_COLOR)
			draw_line(position + Vector2(-5, -25), position + Vector2(5, -15), PARCHMENT_COLOR, 1.5)
			draw_line(position + Vector2(5, -25), position + Vector2(-5, -15), PARCHMENT_COLOR, 1.5)
		else:
			draw_line(position + Vector2(-8, -27), position + Vector2(8, -13), Color("8b6652"), 3.0)
			draw_line(position + Vector2(8, -27), position + Vector2(-8, -13), Color("8b6652"), 3.0)
		var bar := Rect2(position.x - 30, position.y - 43, 60, 6)
		draw_rect(bar, Color(FOREST_SHADOW_COLOR, 0.9), true)
		var health_ratio: float = clampf(float(state.health) / float(state.health_maximum), 0.0, 1.0)
		draw_rect(Rect2(bar.position + Vector2.ONE, Vector2((bar.size.x - 2.0) * health_ratio, bar.size.y - 2.0)), Color("d9634f"), true)
		var label := String(definition.get("label", "TARGET"))
		var label_width: float = ThemeDB.fallback_font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x
		draw_string(ThemeDB.fallback_font, Vector2(position.x - label_width * 0.5, position.y + 22), label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 9, PARCHMENT_COLOR if alive else Color("9b8a73"))
	draw_set_transform(-camera_origin)


func _refresh_material_preview() -> void:
	var image := Image.create(material_grid.width, material_grid.height, false, Image.FORMAT_RGBA8)
	for cell_y: int in range(material_grid.height):
		for cell_x: int in range(material_grid.width):
			var cell_index := cell_y * material_grid.width + cell_x
			var material_id := material_registry.material_id(material_grid.material_wire_ids[cell_index])
			var color := _material_color(material_id)
			var charge_ratio := float(material_grid.charges[cell_index]) / float(SimConfig.FIXED_SCALE)
			if charge_ratio > 0.0:
				color = color.lerp(ATTUNEMENT_COLOR, charge_ratio * 0.7)
			image.set_pixel(cell_x, cell_y, color)
	material_preview_texture = ImageTexture.create_from_image(image)


func _load_player_sprite_candidate() -> void:
	_clear_player_sprite_candidate()
	player_sprite = WellspringCharacterSprite.new()
	player_sprite.source_kind = "champion"
	player_sprite.source_id = selected_champion_id
	player_sprite.playing = false
	if not player_sprite.load_source():
		push_warning("%s presentation candidate unavailable: %s; using procedural fallback" % [selected_champion_id, player_sprite.last_error])
		_clear_player_sprite_candidate()


func _clear_player_sprite_candidate() -> void:
	if player_sprite == null:
		return
	player_sprite.texture = null
	player_sprite.free()
	player_sprite = null


func _material_color(material_id: String) -> Color:
	match material_id:
		"worldbone":
			return WORLDBONE_COLOR
		"stone":
			return PALE_STONE_COLOR.darkened(0.28)
		"brick":
			return Color("8f5745")
		"wood":
			return TIMBER_COLOR
		"water":
			return WATER_HIGHLIGHT_COLOR
		"oil":
			return Color("342f42")
		"fire":
			return FIRE_COLOR
		"steam":
			return Color("b8c8c6")
		"ice":
			return Color("9bc7d9")
		"rubble":
			return Color("685e54")
		_:
			return Color("151711")


func _projectile_color(element_wire_id: int) -> Color:
	match element_wire_id:
		3:
			return WATER_HIGHLIGHT_COLOR.lightened(0.28)
		6:
			return ATTUNEMENT_COLOR
		7:
			return PARCHMENT_COLOR
		8:
			return FLUX_COLOR.darkened(0.12)
		_:
			return FLUX_COLOR


func _draw_projectile(projectile: ProjectileState, position: Vector2, color: Color) -> void:
	var radius: float = float(projectile.radius) / 1000.0
	var previous := Vector2(float(projectile.previous_x) / 1000.0, float(projectile.previous_y) / 1000.0)
	draw_line(previous, position, Color(color, 0.42), maxf(2.0, radius * 0.65))
	match projectile.source_wire_id:
		CombatTuning.ECLIPSE_DISC_WIRE_ID:
			draw_circle(position, radius + 8.0, Color(color, 0.16))
			draw_circle(position, radius, Color("241d2e"))
			draw_arc(position, radius, -2.35, 0.78, 16, color.lightened(0.2), 3.0)
			draw_arc(position, radius - 3.0, 0.78, 3.93, 16, PARCHMENT_COLOR.darkened(0.25), 2.0)
		CombatTuning.POCKET_ECLIPSE_WIRE_ID:
			draw_circle(position, radius + 10.0, Color(color, 0.14))
			draw_circle(position, radius, color)
			draw_circle(position + Vector2(radius * 0.45, 0.0), radius * 0.82, Color("30243d"))
			for ray: Vector2 in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]:
				draw_line(position + ray * (radius + 2.0), position + ray * (radius + 6.0), Color(color, 0.8), 2.0)
		_:
			draw_circle(position, radius + 7.0, Color(color, 0.18))
			draw_circle(position, radius, color)


func _requested_tick_rate() -> int:
	var configured: int = int(ProjectSettings.get_setting("flux/simulation/default_tick_rate", 120))
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--tick-rate="):
			configured = argument.trim_prefix("--tick-rate=").to_int()
	if not SimConfig.is_supported_tick_rate(configured):
		push_warning("Unsupported tick rate %d; falling back to 120" % configured)
		return 120
	return configured


func _requested_join_address() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--join-address="):
			var requested := argument.trim_prefix("--join-address=").strip_edges()
			if SessionTransport._valid_address(requested):
				return requested
			push_warning("Invalid join address override; using 127.0.0.1")
	return "127.0.0.1"


func _requested_session_port() -> int:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--session-port="):
			var requested: int = argument.trim_prefix("--session-port=").to_int()
			if SessionTransport._valid_port(requested, false):
				return requested
			push_warning("Invalid session port override; using %d" % SessionTransport.DEFAULT_PORT)
	return SessionTransport.DEFAULT_PORT


func _requested_player_name() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--player-name="):
			var requested := SessionTransport._validated_player_name(argument.trim_prefix("--player-name="))
			if not requested.is_empty():
				return requested
			push_warning("Invalid player name override; using Traveller")
	return "Traveller"


func _requested_farflow_mode() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--farflow="):
			var requested := parse_farflow_mode(argument)
			if not requested.is_empty():
				return requested
			push_warning("Invalid Farflow override; expected --farflow=host or --farflow=join")
	return ""


static func parse_farflow_mode(argument: String) -> String:
	if not argument.begins_with("--farflow="):
		return ""
	var requested := argument.trim_prefix("--farflow=").strip_edges().to_lower()
	return requested if requested in ["host", "join"] else ""


func _requested_champion_id() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--champion="):
			var requested := argument.trim_prefix("--champion=")
			if champion_catalog.champions_by_id.has(requested):
				return requested
			push_warning("Unknown champion %s; falling back to %s" % [requested, champion_catalog.default_champion_id])
	return champion_catalog.default_champion_id


func _requested_capture_pointer() -> Vector2i:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-pointer="):
			var parsed := parse_capture_pointer(argument, campus_layout.canvas_size)
			if parsed.x < 0:
				push_warning("Invalid capture pointer; expected --capture-pointer=X,Y inside the campus")
			return parsed
	return Vector2i(-1, -1)


static func parse_capture_pointer(argument: String, canvas_size: Vector2i) -> Vector2i:
	if not argument.begins_with("--capture-pointer="):
		return Vector2i(-1, -1)
	var components := argument.trim_prefix("--capture-pointer=").split(",", false)
	if components.size() != 2 or not components[0].is_valid_int() or not components[1].is_valid_int():
		return Vector2i(-1, -1)
	var point := Vector2i(components[0].to_int(), components[1].to_int())
	if point.x < 0 or point.y < 0 or point.x >= canvas_size.x or point.y >= canvas_size.y:
		return Vector2i(-1, -1)
	return point


func _apply_preference_overrides() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--movement-reference="):
			var requested_reference: String = argument.trim_prefix("--movement-reference=")
			if not player_preferences.apply_control_preset(requested_reference):
				push_warning(player_preferences.last_error)
		elif argument.begins_with("--pov-mode="):
			var requested_mode: String = argument.trim_prefix("--pov-mode=")
			if not player_preferences.set_pov_mode(requested_mode):
				push_warning(player_preferences.last_error)
		elif argument.begins_with("--pov-angle="):
			var angle_text: String = argument.trim_prefix("--pov-angle=")
			if angle_text.is_valid_int():
				player_preferences.set_pov_angle_degrees(angle_text.to_int())
			else:
				push_warning("Invalid --pov-angle value: %s" % angle_text)
		elif argument.begins_with("--pov-range="):
			var range_text: String = argument.trim_prefix("--pov-range=")
			if range_text.is_valid_int():
				player_preferences.set_pov_range(range_text.to_int())
			else:
				push_warning("Invalid --pov-range value: %s" % range_text)


func _handle_preference_actions() -> void:
	var changed: bool = false
	if Input.is_action_just_pressed(&"toggle_movement_reference"):
		var next_reference := PlayerPreferences.MOVEMENT_AIM_RELATIVE if player_preferences.movement_reference == PlayerPreferences.MOVEMENT_WORLD_RELATIVE else PlayerPreferences.MOVEMENT_WORLD_RELATIVE
		changed = player_preferences.apply_control_preset(next_reference)
		if changed and input_router != null:
			input_router.configure_movement_reference(next_reference)
	if Input.is_action_just_pressed(&"toggle_pov_mode"):
		var next_mode := PlayerPreferences.POV_CONE if player_preferences.pov_mode == PlayerPreferences.POV_FULL else PlayerPreferences.POV_FULL
		changed = player_preferences.set_pov_mode(next_mode) or changed
	if Input.is_action_just_pressed(&"adjust_pov_angle"):
		var angle_delta: int = -15 if Input.is_key_pressed(KEY_SHIFT) else 15
		player_preferences.set_pov_angle_degrees(player_preferences.pov_angle_degrees + angle_delta)
		changed = true
	if Input.is_action_just_pressed(&"adjust_pov_range"):
		var range_delta: int = -80 if Input.is_key_pressed(KEY_SHIFT) else 80
		player_preferences.set_pov_range(player_preferences.pov_range + range_delta)
		changed = true
	if changed and not player_preferences.save_to_file():
		push_warning(player_preferences.last_error)


func _player_position() -> Vector2:
	var state: PlayerState = _local_player_state()
	if state == null:
		return current_position
	return Vector2(float(state.position_x) / 1000.0, float(state.position_y) / 1000.0)


func _local_player_state() -> PlayerState:
	if world == null:
		return null
	var entity_id: int = SessionTransport.SERVER_PEER_ID
	if session_transport != null and session_transport.is_connected_client() and session_transport.local_entity_id > 0:
		entity_id = session_transport.local_entity_id
	var state: PlayerState = world.player(entity_id)
	return state if state != null else world.player(SessionTransport.SERVER_PEER_ID)


func _camera_origin(focus_position: Vector2) -> Vector2:
	if campus_layout == null:
		return Vector2.ZERO
	var viewport_size := Vector2(campus_layout.viewport_size)
	var focus_screen := Vector2(viewport_size.x * 0.5, (float(campus_layout.reserved_ui_top) + viewport_size.y) * 0.5)
	var maximum_origin := Vector2(campus_layout.canvas_size - campus_layout.viewport_size)
	return Vector2(
		clampf(focus_position.x - focus_screen.x, 0.0, maximum_origin.x),
		clampf(focus_position.y - focus_screen.y, 0.0, maximum_origin.y),
	)
