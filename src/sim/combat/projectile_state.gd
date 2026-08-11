class_name ProjectileState
extends RefCounted


var entity_id: int
var owner_id: int
var team_id: int
var source_wire_id: int
var element_wire_id: int
var position_x: int
var position_y: int
var previous_x: int
var previous_y: int
var velocity_x: int
var velocity_y: int
var remainder_x: int = 0
var remainder_y: int = 0
var radius: int
var damage: int
var lifetime_ticks: int
var hit_control_state: int = CombatTuning.NO_HIT_CONTROL_STATE
var hit_control_duration_ms: int = 0
var hit_control_speed: int = 0
var grazed_entity_ids := PackedInt64Array()


func _init(
	requested_entity_id: int,
	requested_owner_id: int,
	requested_team_id: int,
	requested_source_wire_id: int,
	requested_element_wire_id: int,
	requested_position: Vector2i,
	requested_velocity: Vector2i,
	requested_radius: int,
	requested_damage: int,
	requested_lifetime_ticks: int,
	requested_hit_control_state: int = CombatTuning.NO_HIT_CONTROL_STATE,
	requested_hit_control_duration_ms: int = 0,
	requested_hit_control_speed: int = 0,
) -> void:
	entity_id = requested_entity_id
	owner_id = requested_owner_id
	team_id = requested_team_id
	source_wire_id = requested_source_wire_id
	element_wire_id = requested_element_wire_id
	position_x = requested_position.x
	position_y = requested_position.y
	previous_x = requested_position.x
	previous_y = requested_position.y
	velocity_x = requested_velocity.x
	velocity_y = requested_velocity.y
	radius = requested_radius
	damage = requested_damage
	lifetime_ticks = requested_lifetime_ticks
	hit_control_state = requested_hit_control_state
	hit_control_duration_ms = requested_hit_control_duration_ms
	hit_control_speed = requested_hit_control_speed


func canonical_values() -> PackedInt64Array:
	var values := PackedInt64Array([
		entity_id, owner_id, team_id, source_wire_id, element_wire_id,
		position_x, position_y, previous_x, previous_y,
		velocity_x, velocity_y, remainder_x, remainder_y,
		radius, damage, lifetime_ticks,
		hit_control_state, hit_control_duration_ms, hit_control_speed,
	])
	values.append(grazed_entity_ids.size())
	for grazed_id: int in grazed_entity_ids:
		values.append(grazed_id)
	return values


func has_grazed(entity_id_to_find: int) -> bool:
	return grazed_entity_ids.has(entity_id_to_find)


func record_graze(grazed_entity_id: int) -> void:
	if not grazed_entity_ids.has(grazed_entity_id):
		grazed_entity_ids.append(grazed_entity_id)
		grazed_entity_ids.sort()
