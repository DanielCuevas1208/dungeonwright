extends GutTest
## Projectile flight: line of sight, shot direction, and tile travel.

func _empty_map(p_width: int = 12, p_height: int = 8) -> DungeonMap:
	var map := DungeonMap.new(p_width, p_height)
	for x in p_width:
		for y in p_height:
			map.set_tile(x, y, DungeonMap.Tile.FLOOR)
	return map

func _view_for(p_map: DungeonMap) -> DungeonView:
	var view := DungeonView.new()
	view.map = p_map
	autofree(view)
	return view

## Builds a bolt that travels right from column one.
func _bolt(p_map: DungeonMap, p_range: int) -> Projectile:
	var bolt := Projectile.new()
	bolt.setup(7, 7.0, Vector2i.RIGHT, Vector2i(1, 4), _view_for(p_map), p_range)
	autofree(bolt)
	return bolt

func test_line_of_sight_is_clear_across_open_floor() -> void:
	var map := _empty_map()
	assert_true(Combat.has_line_of_sight(map, Vector2i(1, 4), Vector2i(8, 4)))

func test_line_of_sight_clears_diagonals() -> void:
	var map := _empty_map()
	assert_true(Combat.has_line_of_sight(map, Vector2i(1, 1), Vector2i(8, 8)))

func test_wall_blocks_line_of_sight() -> void:
	var map := _empty_map()
	map.set_tile(4, 4, DungeonMap.Tile.WALL)
	assert_false(Combat.has_line_of_sight(map, Vector2i(1, 4), Vector2i(8, 4)))

func test_locked_door_blocks_line_of_sight() -> void:
	var map := _empty_map()
	map.set_tile(4, 4, DungeonMap.Tile.DOOR_LOCKED)
	assert_false(Combat.has_line_of_sight(map, Vector2i(1, 4), Vector2i(8, 4)))

func test_open_door_allows_line_of_sight() -> void:
	var map := _empty_map()
	map.set_tile(4, 4, DungeonMap.Tile.DOOR_OPEN)
	assert_true(Combat.has_line_of_sight(map, Vector2i(1, 4), Vector2i(8, 4)))

func test_line_of_sight_from_own_cell_is_clear() -> void:
	var map := _empty_map()
	assert_true(Combat.has_line_of_sight(map, Vector2i(3, 3), Vector2i(3, 3)))

func test_direction_toward_matches_the_step() -> void:
	assert_eq(Combat.direction_toward(Vector2i(2, 2), Vector2i(5, 2)), Vector2i.RIGHT)
	assert_eq(Combat.direction_toward(Vector2i(2, 2), Vector2i(2, 6)), Vector2i.DOWN)
	assert_eq(Combat.direction_toward(Vector2i(2, 2), Vector2i(0, 0)), Vector2i(-1, -1))

func test_direction_toward_same_cell_falls_back_to_down() -> void:
	assert_eq(Combat.direction_toward(Vector2i(3, 3), Vector2i(3, 3)), Vector2i.DOWN)

func test_bolt_hits_the_hero_tile() -> void:
	var map := _empty_map()
	var bolt := _bolt(map, 9)
	bolt.target_grid = Vector2i(5, 4)
	bolt.tick(1.0)
	assert_true(bolt.hit)
	assert_true(bolt.is_expired())

func test_bolt_misses_a_hero_off_the_line() -> void:
	var map := _empty_map()
	var bolt := _bolt(map, 9)
	bolt.target_grid = Vector2i(5, 7)
	bolt.tick(1.0)
	assert_false(bolt.hit)
	assert_false(bolt.is_expired())

func test_bolt_stops_on_a_wall() -> void:
	var map := _empty_map()
	map.set_tile(3, 4, DungeonMap.Tile.WALL)
	var bolt := _bolt(map, 9)
	bolt.tick(1.0)
	assert_true(bolt.is_expired())
	assert_false(bolt.hit)
	assert_eq(bolt.grid_pos, Vector2i(2, 4))

func test_bolt_expires_after_its_range() -> void:
	var map := _empty_map()
	var bolt := _bolt(map, 3)
	bolt.tick(1.0)
	assert_true(bolt.is_expired())
	assert_false(bolt.hit)
	assert_eq(bolt.grid_pos, Vector2i(4, 4))

func test_bolt_stops_at_the_map_edge() -> void:
	var map := _empty_map(6, 8)
	var bolt := _bolt(map, 9)
	bolt.tick(1.0)
	assert_true(bolt.is_expired())
	assert_eq(bolt.grid_pos, Vector2i(5, 4))

func test_bolt_reports_damage() -> void:
	var bolt := _bolt(_empty_map(), 9)
	assert_eq(bolt.damage, 7)
