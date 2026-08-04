extends GutTest
## Projectile rules: aim, blocking tiles, and line of sight.

func _build_open(p_width: int, p_height: int) -> DungeonMap:
	var map := DungeonMap.new(p_width, p_height)
	for x in p_width:
		for y in p_height:
			map.set_tile(x, y, DungeonMap.Tile.FLOOR)
	return map

func test_aim_points_from_origin_to_target() -> void:
	assert_eq(Projectile.aim(Vector2(0, 0), Vector2(0, 16)), Vector2.DOWN)
	assert_eq(Projectile.aim(Vector2(16, 0), Vector2(0, 0)), Vector2.LEFT)

func test_aim_is_a_unit_vector_on_diagonals() -> void:
	var direction := Projectile.aim(Vector2(0, 0), Vector2(16, 16))
	assert_almost_eq(direction.x, 0.7071, 0.001)
	assert_almost_eq(direction.y, 0.7071, 0.001)

func test_aim_on_same_position_falls_back() -> void:
	assert_eq(Projectile.aim(Vector2(8, 8), Vector2(8, 8)), Vector2.RIGHT)

func test_blocks_walls_and_locked_doors() -> void:
	assert_true(Projectile.blocks(DungeonMap.Tile.WALL))
	assert_true(Projectile.blocks(DungeonMap.Tile.DOOR_LOCKED))

func test_open_floor_does_not_block() -> void:
	assert_false(Projectile.blocks(DungeonMap.Tile.FLOOR))
	assert_false(Projectile.blocks(DungeonMap.Tile.DOOR_OPEN))
	assert_false(Projectile.blocks(DungeonMap.Tile.START))
	assert_false(Projectile.blocks(DungeonMap.Tile.EXIT))

func test_los_is_clear_along_open_row() -> void:
	var map := _build_open(8, 8)
	assert_true(Projectile.los_clear(map, Vector2i(1, 4), Vector2i(6, 4)))

func test_los_same_cell_is_clear() -> void:
	var map := _build_open(4, 4)
	assert_true(Projectile.los_clear(map, Vector2i(2, 2), Vector2i(2, 2)))

func test_los_is_clear_on_open_diagonal() -> void:
	var map := _build_open(8, 8)
	assert_true(Projectile.los_clear(map, Vector2i(1, 1), Vector2i(6, 6)))

func test_los_is_blocked_by_a_wall_cell() -> void:
	var map := _build_open(9, 9)
	map.set_tile(4, 4, DungeonMap.Tile.WALL)
	assert_false(Projectile.los_clear(map, Vector2i(1, 4), Vector2i(7, 4)))

func test_los_is_blocked_by_a_locked_door() -> void:
	var map := _build_open(9, 9)
	map.set_tile(4, 4, DungeonMap.Tile.DOOR_LOCKED)
	assert_false(Projectile.los_clear(map, Vector2i(1, 4), Vector2i(7, 4)))

func test_los_ignores_wall_behind_the_target() -> void:
	var map := _build_open(9, 9)
	map.set_tile(7, 4, DungeonMap.Tile.WALL)
	assert_true(Projectile.los_clear(map, Vector2i(1, 4), Vector2i(5, 4)))

func test_every_ranged_spec_is_valid_and_balanced() -> void:
	for spec in MonsterSpecs.all():
		if not spec.ranged:
			continue
		assert_true(spec.is_valid(), "ranged monster %s is invalid" % spec.id)
		assert_true(TileArt.has_entity(spec.projectile_key), spec.id)
		assert_gte(spec.projectile_range, spec.min_range, spec.id)
		assert_gt(spec.projectile_damage, 0, spec.id)
		assert_gt(spec.projectile_speed, 0.0, spec.id)
		assert_eq(spec.ai, MonsterSpec.AI.ranged, spec.id)

func test_melee_specs_are_not_ranged() -> void:
	for spec in MonsterSpecs.all():
		if spec.id in [&"bonecaster", &"spitter", &"slinger"]:
			assert_true(spec.ranged)
		else:
			assert_false(spec.ranged, spec.id)

func test_every_biome_offers_a_ranged_monster() -> void:
	for biome in Biomes.all():
		var ranged_ids := []
		for entry in biome.monster_table:
			if MonsterSpecs.by_id(entry.monster).ranged:
				ranged_ids.append(entry.monster)
		assert_false(ranged_ids.is_empty(), "%s has no ranged monster" % biome.id)
