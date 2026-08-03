class_name Pathfinding
extends RefCounted
## Flood-fill helpers over the dungeon grid.
##
## The player treats locked doors as walkable, while the connectivity
## checks in the generator and tests treat them as solid. A flag selects
## the behaviour.

const ORTHO := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

## Returns the distance from the origin to every reachable cell.
## Cells are reachable when they are walkable and not a locked door when
## p_open_doors is false.
static func flood(
	p_map: DungeonMap,
	p_origin: Vector2i,
	p_open_doors: bool = false
) -> Dictionary:
	var distances := {}
	distances[p_origin] = 0
	var frontier: Array[Vector2i] = [p_origin]
	var head := 0
	while head < frontier.size():
		var current := frontier[head]
		head += 1
		var distance: int = distances[current]
		for offset: Vector2i in ORTHO:
			var next_cell := current + offset
			if next_cell in distances:
				continue
			if not _is_open(p_map, next_cell, p_open_doors):
				continue
			distances[next_cell] = distance + 1
			frontier.append(next_cell)
	return distances

## True when p_target is reachable from p_origin.
static func reaches(
	p_map: DungeonMap,
	p_origin: Vector2i,
	p_target: Vector2i,
	p_open_doors: bool = false
) -> bool:
	return flood(p_map, p_origin, p_open_doors).has(p_target)

## Returns a shortest path from p_from to p_to as a list of cells.
## The list starts at p_to and walks back toward p_from.
static func find_path(
	p_map: DungeonMap,
	p_from: Vector2i,
	p_to: Vector2i,
	p_open_doors: bool = true
) -> Array[Vector2i]:
	if p_from == p_to:
		return [p_to]
	if not p_map.is_walkable_cell(p_to):
		p_to = p_map.nearest_walkable(p_to)
	var distances := flood(p_map, p_from, p_open_doors)
	if not distances.has(p_to):
		return []
	var path: Array[Vector2i] = []
	var current := p_to
	path.append(current)
	while current != p_from:
		var best := Vector2i(-1, -1)
		var best_score := 2147483647
		for offset: Vector2i in ORTHO:
			var candidate := current + offset
			if not distances.has(candidate):
				continue
			var score: int = distances[candidate]
			if score < best_score:
				best_score = score
				best = candidate
		if best == Vector2i(-1, -1):
			return []
		current = best
		path.append(current)
	return path

static func _is_open(p_map: DungeonMap, p_cell: Vector2i, p_open_doors: bool) -> bool:
	if not p_map.in_bounds_cell(p_cell):
		return false
	if not p_map.is_walkable_cell(p_cell):
		return false
	if not p_open_doors and p_map.get_tile_cell(p_cell) == DungeonMap.Tile.DOOR_LOCKED:
		return false
	return true
