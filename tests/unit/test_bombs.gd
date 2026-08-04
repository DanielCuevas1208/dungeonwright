extends GutTest
## Bomb flight: throw travel, landing, and the fuse timing.
##
## Every step uses tick() with a fixed delta, so the tests are exact.
## A range-two bomb thrown right needs three steps to land: one for each
## tile plus one step where the range runs out.

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

## Builds a bomb thrown right from (1, 1).
func _bomb(p_map: DungeonMap, p_range: int) -> Bomb:
	var bomb := Bomb.new()
	bomb.setup(20, 5.0, Vector2i.RIGHT, Vector2i(1, 1), _view_for(p_map), p_range, 0.8, 2)
	autofree(bomb)
	return bomb

func test_bomb_lands_at_the_end_of_its_range() -> void:
	var bomb := _bomb(_empty_map(), 2)
	for i in 3:
		bomb.tick(0.2)
	assert_true(bomb.landed)
	assert_eq(bomb.grid_pos, Vector2i(3, 1))
	assert_false(bomb.is_expired())

func test_bomb_stops_at_a_wall() -> void:
	var map := _empty_map()
	map.set_tile(2, 1, DungeonMap.Tile.WALL)
	var bomb := _bomb(map, 4)
	bomb.tick(0.2)
	assert_true(bomb.landed)
	assert_eq(bomb.grid_pos, Vector2i(1, 1))
	assert_false(bomb.is_expired())

func test_bomb_stops_at_the_map_edge() -> void:
	var map := _empty_map(4, 8)
	var bomb := _bomb(map, 6)
	for i in 3:
		bomb.tick(0.2)
	assert_true(bomb.landed)
	assert_eq(bomb.grid_pos, Vector2i(3, 1))

func test_bomb_does_not_explode_until_the_fuse_ends() -> void:
	var bomb := _bomb(_empty_map(), 2)
	for i in 5:
		bomb.tick(0.2)
	assert_true(bomb.landed)
	assert_false(bomb.is_expired())

func test_bomb_explodes_after_the_fuse() -> void:
	var bomb := _bomb(_empty_map(), 2)
	var calls := [0]
	bomb.on_explode = func() -> void:
		calls[0] += 1
	for i in 7:
		bomb.tick(0.2)
	assert_true(bomb.is_expired())
	assert_eq(calls[0], 1)
	assert_eq(bomb.grid_pos, Vector2i(3, 1))

func test_bomb_reports_its_profile() -> void:
	var bomb := _bomb(_empty_map(), 2)
	assert_eq(bomb.damage, 20)
	assert_eq(bomb.blast_radius, 2)
	assert_eq(bomb.fuse, 0.8)
