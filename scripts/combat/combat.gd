class_name Combat
extends RefCounted
## Pure damage math used by the player and the monsters.
##
## Keeping the formulas here makes combat deterministic and testable.

const MIN_DAMAGE := 1

## Computes the damage an attacker deals to a defender.
## A high defence never reduces damage below the minimum.
static func compute_damage(p_attack: int, p_defence: int) -> int:
	return maxi(MIN_DAMAGE, p_attack - p_defence)

## True when the attacker can reach the target from its position.
static func within_attack_range(p_distance_sq: float, p_range: float) -> bool:
	return p_distance_sq <= p_range * p_range

## True when the target lies inside the facing wedge of the attacker.
## The wedge is the tile in front of the attacker plus the two side tiles.
static func in_facing_arc(p_origin: Vector2i, p_facing: Vector2i, p_target: Vector2i) -> bool:
	if p_origin == p_target:
		return false
	var delta := p_target - p_origin
	var forward := p_facing
	if forward == Vector2i.LEFT or forward == Vector2i.RIGHT:
		return absi(delta.y) <= 1 and signi(delta.x) == forward.x
	return absi(delta.x) <= 1 and signi(delta.y) == forward.y

## True when a straight line from p_from to p_to crosses no wall.
## Locked doors block vision, because they are solid until opened.
## The source and target tiles themselves never block the line.
static func has_line_of_sight(p_map: DungeonMap, p_from: Vector2i, p_to: Vector2i) -> bool:
	if p_from == p_to:
		return true
	var delta_x := p_to.x - p_from.x
	var delta_y := p_to.y - p_from.y
	var steps := maxi(absi(delta_x), absi(delta_y))
	var step_x := float(delta_x) / float(steps)
	var step_y := float(delta_y) / float(steps)
	for i in range(1, steps + 1):
		var cell := Vector2i(
			roundi(p_from.x + step_x * i),
			roundi(p_from.y + step_y * i)
		)
		if cell == p_to:
			break
		if not p_map.in_bounds_cell(cell):
			return false
		var tile := p_map.get_tile_cell(cell)
		if tile == DungeonMap.Tile.WALL or tile == DungeonMap.Tile.DOOR_LOCKED:
			return false
	return true

## True when p_cell lies within the square blast of a bomb at p_center.
## The blast is a square ring, so a radius of one covers every neighbor.
static func in_blast_radius(p_center: Vector2i, p_cell: Vector2i, p_radius: int) -> bool:
	if p_radius <= 0:
		return p_center == p_cell
	return maxi(absi(p_center.x - p_cell.x), absi(p_center.y - p_cell.y)) <= p_radius

## Returns the eight-direction step from p_from toward p_to.
## A shared cell maps to DOWN, which is never used in practice.
static func direction_toward(p_from: Vector2i, p_to: Vector2i) -> Vector2i:
	var dx := signi(p_to.x - p_from.x)
	var dy := signi(p_to.y - p_from.y)
	if dx == 0 and dy == 0:
		return Vector2i.DOWN
	return Vector2i(dx, dy)

## Returns a fan of p_count directions centered on p_base.
## The fan spreads across the eight compass directions, so a three-shot
## volley sends one bolt at the aim line and one to each side of it.
static func volley_directions(p_base: Vector2i, p_count: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	if p_count <= 1:
		result.append(p_base)
		return result
	var index := _direction_index(p_base)
	if index < 0:
		result.append(p_base)
		return result
	var half := p_count / 2
	for offset in range(-half, half + 1):
		var wrapped := (index + offset) % _COMPASS.size()
		if wrapped < 0:
			wrapped += _COMPASS.size()
		result.append(_COMPASS[wrapped])
	return result

## The eight compass directions in clockwise order from right.
const _COMPASS := [
	Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(-1, 1),
	Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
]

static func _direction_index(p_direction: Vector2i) -> int:
	for i in _COMPASS.size():
		if _COMPASS[i] == p_direction:
			return i
	return -1
