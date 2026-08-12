class_name CollisionWorld
extends RefCounted


class Obstacle:
	extends RefCounted
	var obstacle_id: int
	var minimum_x: int
	var minimum_y: int
	var maximum_x: int
	var maximum_y: int
	var vaultable: bool

	func _init(
		requested_id: int,
		requested_minimum_x: int,
		requested_minimum_y: int,
		requested_maximum_x: int,
		requested_maximum_y: int,
		requested_vaultable: bool = false,
	) -> void:
		obstacle_id = requested_id
		minimum_x = requested_minimum_x
		minimum_y = requested_minimum_y
		maximum_x = requested_maximum_x
		maximum_y = requested_maximum_y
		vaultable = requested_vaultable

	func projected_depth(direction: Vector2i) -> int:
		@warning_ignore("integer_division")
		return (
			absi(direction.x) * (maximum_x - minimum_x)
			+ absi(direction.y) * (maximum_y - minimum_y)
		) / SimConfig.FIXED_SCALE


class MoveResult:
	extends RefCounted
	var position: Vector2i
	var wall_normal: Vector2i
	var wall_id: int

	func _init(
		requested_position: Vector2i,
		requested_normal: Vector2i = Vector2i.ZERO,
		requested_wall_id: int = 0,
	) -> void:
		position = requested_position
		wall_normal = requested_normal
		wall_id = requested_wall_id


var width: int
var height: int
var obstacles: Array[Obstacle] = []


func _init(requested_width: int = 1_280_000, requested_height: int = 720_000) -> void:
	width = requested_width
	height = requested_height


func add_obstacle(obstacle: Obstacle) -> void:
	obstacles.append(obstacle)
	obstacles.sort_custom(func(left: Obstacle, right: Obstacle) -> bool: return left.obstacle_id < right.obstacle_id)


func move_box(position: Vector2i, delta: Vector2i, radius: int) -> MoveResult:
	var resolved := position
	var normal := Vector2i.ZERO
	var wall_id: int = 0
	var next_x: int = clampi(position.x + delta.x, radius, width - radius)
	if next_x != position.x + delta.x:
		normal.x = -signi(delta.x) * 1000
		wall_id = -1
	for obstacle: Obstacle in obstacles:
		if not _ranges_overlap(position.y - radius, position.y + radius, obstacle.minimum_y, obstacle.maximum_y):
			continue
		if delta.x > 0 and position.x + radius <= obstacle.minimum_x and next_x + radius > obstacle.minimum_x:
			next_x = mini(next_x, obstacle.minimum_x - radius)
			normal.x = -1000
			wall_id = obstacle.obstacle_id
		elif delta.x < 0 and position.x - radius >= obstacle.maximum_x and next_x - radius < obstacle.maximum_x:
			next_x = maxi(next_x, obstacle.maximum_x + radius)
			normal.x = 1000
			wall_id = obstacle.obstacle_id
	resolved.x = next_x

	var next_y: int = clampi(position.y + delta.y, radius, height - radius)
	if next_y != position.y + delta.y:
		normal.y = -signi(delta.y) * 1000
		wall_id = -2
	for obstacle: Obstacle in obstacles:
		if not _ranges_overlap(resolved.x - radius, resolved.x + radius, obstacle.minimum_x, obstacle.maximum_x):
			continue
		if delta.y > 0 and position.y + radius <= obstacle.minimum_y and next_y + radius > obstacle.minimum_y:
			next_y = mini(next_y, obstacle.minimum_y - radius)
			normal.y = -1000
			wall_id = obstacle.obstacle_id
		elif delta.y < 0 and position.y - radius >= obstacle.maximum_y and next_y - radius < obstacle.maximum_y:
			next_y = maxi(next_y, obstacle.maximum_y + radius)
			normal.y = 1000
			wall_id = obstacle.obstacle_id
	resolved.y = next_y
	return MoveResult.new(resolved, normal, wall_id)


func find_vault_candidate(position: Vector2i, direction: Vector2i, radius: int) -> Obstacle:
	var best: Obstacle = null
	var best_distance_squared: int = 0x7fffffffffffffff
	var maximum_distance: int = radius + MovementTuning.VAULT_APPROACH
	for obstacle: Obstacle in obstacles:
		if not obstacle.vaultable or obstacle.projected_depth(direction) > MovementTuning.VAULT_MAXIMUM_DEPTH:
			continue
		var nearest := Vector2i(
			clampi(position.x, obstacle.minimum_x, obstacle.maximum_x),
			clampi(position.y, obstacle.minimum_y, obstacle.maximum_y),
		)
		var offset: Vector2i = nearest - position
		var distance_squared: int = offset.length_squared()
		if distance_squared > maximum_distance * maximum_distance or distance_squared >= best_distance_squared:
			continue
		var approach_dot: int = offset.x * direction.x + offset.y * direction.y
		if approach_dot <= 0 or approach_dot * approach_dot < distance_squared * 518_400:
			continue
		best = obstacle
		best_distance_squared = distance_squared
	return best


func vault_destination(
	position: Vector2i,
	direction: Vector2i,
	radius: int,
	obstacle: Obstacle,
) -> Vector2i:
	var destination := position
	if absi(direction.x) >= absi(direction.y):
		destination.x = (
			obstacle.maximum_x + radius + MovementTuning.VAULT_LANDING
			if direction.x > 0
			else obstacle.minimum_x - radius - MovementTuning.VAULT_LANDING
		)
		@warning_ignore("integer_division")
		destination.y += direction.y * obstacle.projected_depth(direction) / 1000
	else:
		destination.y = (
			obstacle.maximum_y + radius + MovementTuning.VAULT_LANDING
			if direction.y > 0
			else obstacle.minimum_y - radius - MovementTuning.VAULT_LANDING
		)
		@warning_ignore("integer_division")
		destination.x += direction.x * obstacle.projected_depth(direction) / 1000
	destination.x = clampi(destination.x, radius, width - radius)
	destination.y = clampi(destination.y, radius, height - radius)
	return destination if can_occupy(destination, radius) else position


func can_occupy(position: Vector2i, radius: int, ignored_obstacle_id: int = -1) -> bool:
	if position.x < radius or position.x > width - radius or position.y < radius or position.y > height - radius:
		return false
	for obstacle: Obstacle in obstacles:
		if obstacle.obstacle_id == ignored_obstacle_id:
			continue
		if _ranges_overlap(position.x - radius, position.x + radius, obstacle.minimum_x, obstacle.maximum_x) and _ranges_overlap(position.y - radius, position.y + radius, obstacle.minimum_y, obstacle.maximum_y):
			return false
	return true


static func _ranges_overlap(minimum_a: int, maximum_a: int, minimum_b: int, maximum_b: int) -> bool:
	return maximum_a > minimum_b and minimum_a < maximum_b
