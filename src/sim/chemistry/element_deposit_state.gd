class_name ElementDepositState
extends RefCounted

var entity_id: int = 0
var source_cast_id: int = 0
var source_wire_id: int = 0
var owner_id: int = 0
var team_id: int = 0
var element_wire_id: int = 0
var position_x: int = 0
var position_y: int = 0
var direction_x: int = 1000
var direction_y: int = 0
var radius: int = 32_000
var strength: int = 1000
var created_tick: int = 0
var expiry_tick: int = 0

func canonical_values() -> PackedInt64Array:
	return PackedInt64Array([entity_id, source_cast_id, source_wire_id, owner_id, team_id, element_wire_id, position_x, position_y, direction_x, direction_y, radius, strength, created_tick, expiry_tick])

func validate() -> bool:
	var footprint_valid := (radius >= 24000 and radius <= 32000) or (is_trail() and strength <= 250 and expiry_tick - created_tick <= 180)
	return entity_id > 0 and entity_id < 2_000_000_000 and source_cast_id > 0 and source_cast_id < 2_000_000_000 and source_wire_id >= 100 and source_wire_id <= 999 and owner_id > 0 and owner_id <= 10000 and team_id > 0 and team_id <= 256 and element_wire_id >= 1 and element_wire_id <= 8 and position_x >= 0 and position_y >= 0 and position_x <= 100_000_000 and position_y <= 100_000_000 and absi(direction_x) <= 1000 and absi(direction_y) <= 1000 and direction_x*direction_x+direction_y*direction_y > 0 and footprint_valid and strength > 0 and strength <= 1000 and created_tick >= 0 and expiry_tick > created_tick and expiry_tick-created_tick <= 600 and expiry_tick < 2_000_000_000

func is_trail() -> bool:
	# A reserved footprint identifies the role without adding snapshot fields.
	return radius == 16000

static func from_values(values: PackedInt64Array) -> ElementDepositState:
	if values.size() != 14:
		return null
	var result := ElementDepositState.new()
	var fields: Array[String] = ["entity_id","source_cast_id","source_wire_id","owner_id","team_id","element_wire_id","position_x","position_y","direction_x","direction_y","radius","strength","created_tick","expiry_tick"]
	for index: int in range(fields.size()):
		result.set(fields[index],values[index])
	return result if result.validate() else null
