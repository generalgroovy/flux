class_name ActorMotionHistory
extends RefCounted


# One adjacent authoritative sample per admitted champion. Presentation only:
# no extrapolation, gameplay-state writes, or delayed facing/protection clocks.
const MAX_TRACKS: int = 8
const SNAP_DISTANCE_PIXELS: float = 72.0

class Track:
	extends RefCounted
	var previous := Vector3.ZERO
	var current := Vector3.ZERO
	var champion_wire_id: int = 0
	var alive: bool = true

var tracks: Dictionary[int, Track] = {}


func clear() -> void:
	tracks.clear()


func capture(states: Array[PlayerState]) -> void:
	var retained: Dictionary[int, bool] = {}
	for state: PlayerState in states:
		if state.actor_kind != PlayerState.ActorKind.CHAMPION or retained.size() >= MAX_TRACKS:
			continue
		retained[state.entity_id] = true
		var next := _point(state)
		var track: Track = tracks.get(state.entity_id)
		var reset := track == null
		if not reset:
			reset = track.champion_wire_id != state.champion_wire_id or track.alive != (state.health > 0)
			reset = reset or Vector2(track.current.x, track.current.y).distance_to(Vector2(next.x, next.y)) > SNAP_DISTANCE_PIXELS
		if track == null:
			track = Track.new()
		track.previous = next if reset else track.current
		track.current = next
		track.champion_wire_id = state.champion_wire_id
		track.alive = state.health > 0
		tracks[state.entity_id] = track
	for entity_id: int in tracks.keys():
		if not retained.has(entity_id):
			tracks.erase(entity_id)


func sample(state: PlayerState, alpha: float) -> Vector3:
	var track: Track = tracks.get(state.entity_id)
	if track == null:
		return _point(state)
	return track.previous.lerp(track.current, clampf(alpha, 0.0, 1.0))


func previous_height(state: PlayerState) -> int:
	var track: Track = tracks.get(state.entity_id)
	return state.air_height if track == null else roundi(track.previous.z * SimConfig.FIXED_SCALE)


static func _point(state: PlayerState) -> Vector3:
	return Vector3(state.position_x, state.position_y, state.air_height) / float(SimConfig.FIXED_SCALE)
