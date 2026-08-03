extends GutTest
## Flood fill and path finding over hand-built maps.

func _build_hall() -> DungeonMap:
	var map := DungeonMap.new(7, 7)
	for y in range(1, 6):
		for x in [1, 2]:
			map.set_tile(x, y, DungeonMap.Tile.FLOOR)
		for x in [4, 5]:
			map.set_tile(x, y, DungeonMap.Tile.FLOOR)
	map.set_tile(3, 3, DungeonMap.Tile.DOOR_LOCKED)
	map.set_tile(6, 3, DungeonMap.Tile.EXIT)
	return map

func test_flood_reaches_open_floor() -> void:
	var map := _build_hall()
	var origin := Vector2i(1, 1)
	var distances := Pathfinding.flood(map, origin, false)
	assert_true(distances.has(Vector2i(2, 5)))
	assert_eq(distances[Vector2i(2, 1)], 1)
	assert_false(distances.has(Vector2i(0, 0)))

func test_locked_door_blocks_closed_flood() -> void:
	var map := _build_hall()
	var origin := Vector2i(1, 1)
	var distances := Pathfinding.flood(map, origin, false)
	assert_false(distances.has(Vector2i(6, 3)))

func test_locked_door_is_open_for_open_flood() -> void:
	var map := _build_hall()
	var origin := Vector2i(1, 1)
	var distances := Pathfinding.flood(map, origin, true)
	assert_true(distances.has(Vector2i(6, 3)))

func test_path_steps_are_adjacent_and_walkable() -> void:
	var map := _build_hall()
	map.set_tile_cell(Vector2i(3, 3), DungeonMap.Tile.FLOOR)
	var path := Pathfinding.find_path(map, Vector2i(1, 1), Vector2i(5, 5), true)
	assert_true(path.size() >= 8)
	for i in range(1, path.size()):
		var previous: Vector2i = path[i - 1]
		var current: Vector2i = path[i]
		assert_eq(absi(previous.x - current.x) + absi(previous.y - current.y), 1)
		assert_true(map.is_walkable_cell(current))
	assert_eq(path[0], Vector2i(5, 5))

func test_path_avoids_locked_door_for_monsters() -> void:
	var map := _build_hall()
	var path := Pathfinding.find_path(map, Vector2i(1, 1), Vector2i(5, 5), false)
	var found_door := false
	for cell in path:
		if map.get_tile_cell(cell) == DungeonMap.Tile.DOOR_LOCKED:
			found_door = true
	assert_false(found_door)

func test_unreachable_target_returns_empty_path() -> void:
	var map := DungeonMap.new(5, 5)
	var path := Pathfinding.find_path(map, Vector2i(1, 1), Vector2i(3, 3), true)
	assert_true(path.is_empty())

func test_nearest_walkable_recovers_inside_room() -> void:
	var map := DungeonMap.new(5, 5)
	for x in range(1, 4):
		for y in range(1, 4):
			map.set_tile(x, y, DungeonMap.Tile.FLOOR)
	assert_eq(map.nearest_walkable(Vector2i(2, 2)), Vector2i(2, 2))
	var rescued := map.nearest_walkable(Vector2i(0, 0))
	assert_true(map.is_walkable_cell(rescued))

func _build_open_hall() -> DungeonMap:
	var map := DungeonMap.new(11, 5)
	for x in range(11):
		for y in range(5):
			map.set_tile(x, y, DungeonMap.Tile.FLOOR)
	return map

func test_line_of_sight_is_clear_across_floor() -> void:
	var map := _build_open_hall()
	assert_true(Pathfinding.line_of_sight(map, Vector2i(1, 2), Vector2i(9, 2)))

func test_line_of_sight_is_blocked_by_wall() -> void:
	var map := _build_open_hall()
	map.set_tile(5, 2, DungeonMap.Tile.WALL)
	assert_false(Pathfinding.line_of_sight(map, Vector2i(1, 2), Vector2i(9, 2)))

func test_line_of_sight_is_blocked_by_locked_door() -> void:
	var map := _build_open_hall()
	map.set_tile(5, 2, DungeonMap.Tile.DOOR_LOCKED)
	assert_false(Pathfinding.line_of_sight(map, Vector2i(1, 2), Vector2i(9, 2)))

func test_line_of_sight_passes_over_open_door() -> void:
	var map := _build_open_hall()
	map.set_tile(5, 2, DungeonMap.Tile.DOOR_OPEN)
	assert_true(Pathfinding.line_of_sight(map, Vector2i(1, 2), Vector2i(9, 2)))

func test_line_of_sight_same_cell_is_clear() -> void:
	var map := _build_open_hall()
	assert_true(Pathfinding.line_of_sight(map, Vector2i(4, 4), Vector2i(4, 4)))

func test_line_of_sight_diagonal_crosses_open_floor() -> void:
	var map := _build_open_hall()
	assert_true(Pathfinding.line_of_sight(map, Vector2i(1, 1), Vector2i(9, 3)))
