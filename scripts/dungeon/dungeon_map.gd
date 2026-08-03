class_name DungeonMap
extends RefCounted
## The tile grid of a generated dungeon.
##
## Cells are addressed as integer positions. The map is pure data and
## holds no nodes, which keeps generation fast and easy to test.

enum Tile {
	WALL,
	FLOOR,
	DOOR_LOCKED,
	DOOR_OPEN,
	START,
	EXIT,
	STAIRS_DOWN,
}

var width: int = 0
var height: int = 0

var _cells: PackedInt32Array = PackedInt32Array()

func _init(p_width: int = 0, p_height: int = 0) -> void:
	width = p_width
	height = p_height
	_cells.resize(p_width * p_height)
	_cells.fill(Tile.WALL)

func in_bounds(p_x: int, p_y: int) -> bool:
	return p_x >= 0 and p_x < width and p_y >= 0 and p_y < height

func in_bounds_cell(p_cell: Vector2i) -> bool:
	return in_bounds(p_cell.x, p_cell.y)

func get_tile(p_x: int, p_y: int) -> int:
	if not in_bounds(p_x, p_y):
		return Tile.WALL
	return _cells[p_y * width + p_x]

func get_tile_cell(p_cell: Vector2i) -> int:
	return get_tile(p_cell.x, p_cell.y)

func set_tile(p_x: int, p_y: int, p_tile: int) -> void:
	if not in_bounds(p_x, p_y):
		return
	_cells[p_y * width + p_x] = p_tile

func set_tile_cell(p_cell: Vector2i, p_tile: int) -> void:
	set_tile(p_cell.x, p_cell.y, p_tile)

## True when the player or a monster may step onto this cell.
## A locked door is walkable because a held key opens it on approach.
func is_walkable(p_x: int, p_y: int) -> bool:
	match get_tile(p_x, p_y):
		Tile.WALL:
			return false
		_:
			return true

func is_walkable_cell(p_cell: Vector2i) -> bool:
	return is_walkable(p_cell.x, p_cell.y)

## Finds the nearest walkable cell to the given cell using a spiral search.
func nearest_walkable(p_cell: Vector2i) -> Vector2i:
	if is_walkable_cell(p_cell):
		return p_cell
	var radius := 1
	var max_radius := maxi(width, height)
	while radius < max_radius:
		for x in range(p_cell.x - radius, p_cell.x + radius + 1):
			for y in range(p_cell.y - radius, p_cell.y + radius + 1):
				var candidate := Vector2i(x, y)
				if in_bounds_cell(candidate) and is_walkable_cell(candidate):
					return candidate
		radius += 1
	return p_cell

## Returns every floor cell in the map.
func walkable_cells() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for x in width:
		for y in height:
			if is_walkable(x, y):
				result.append(Vector2i(x, y))
	return result

## Counts the cells of a given tile type.
func count_tile(p_tile: int) -> int:
	var count := 0
	for cell in _cells:
		if cell == p_tile:
			count += 1
	return count
