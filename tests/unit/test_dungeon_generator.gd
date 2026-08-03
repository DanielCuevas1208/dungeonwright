extends GutTest
## The generator must build a valid, deterministic dungeon.

var generator := DungeonGenerator.new()

func test_same_seed_builds_identical_map() -> void:
	var biome := Biomes.crypt()
	var first := generator.generate(biome, 4242)
	var second := generator.generate(biome, 4242)
	assert_eq(first.room_count(), second.room_count())
	assert_eq(first.exit_pos, second.exit_pos)
	assert_eq(first.start_pos, second.start_pos)
	for y in first.map.height:
		for x in first.map.width:
			assert_eq(
				first.map.get_tile(x, y), second.map.get_tile(x, y),
				"cell (%d, %d) differs" % [x, y]
			)

func test_different_seeds_build_different_maps() -> void:
	var biome := Biomes.crypt()
	var first := generator.generate(biome, 100)
	var second := generator.generate(biome, 200)
	var differences := 0
	for y in first.map.height:
		for x in first.map.width:
			if first.map.get_tile(x, y) != second.map.get_tile(x, y):
				differences += 1
	assert_gt(differences, 100)

func test_start_and_exit_are_valid() -> void:
	var biome := Biomes.crypt()
	var result := generator.generate(biome, 777)
	assert_true(result.map.in_bounds_cell(result.start_pos))
	assert_true(result.map.in_bounds_cell(result.exit_pos))
	assert_true(result.map.is_walkable_cell(result.start_pos))
	assert_true(result.map.is_walkable_cell(result.exit_pos))
	assert_eq(result.map.get_tile_cell(result.start_pos), DungeonMap.Tile.START)
	assert_eq(result.map.get_tile_cell(result.exit_pos), DungeonMap.Tile.EXIT)

func test_map_dimensions_match_config() -> void:
	var biome := Biomes.crypt()
	var result := generator.generate(biome, 555)
	assert_eq(result.map.width, biome.width)
	assert_eq(result.map.height, biome.height)

func test_room_count_within_expected_range() -> void:
	var biome := Biomes.crypt()
	for seed in [1, 2, 3, 4, 5]:
		var result := generator.generate(biome, seed)
		assert_gte(result.room_count(), 2)
		assert_lte(result.room_count(), biome.room_count_max)

func test_exit_reachable_from_start_with_doors_open() -> void:
	var biome := Biomes.crypt()
	for seed in [11, 12, 13, 14, 15]:
		var result := generator.generate(biome, seed)
		assert_true(
			Pathfinding.reaches(result.map, result.start_pos, result.exit_pos, true),
			"exit unreachable for seed %d" % seed
		)

func test_dungeon_is_solvable() -> void:
	var biome := Biomes.crypt()
	for seed in [21, 22, 23, 24, 25]:
		var result := generator.generate(biome, seed)
		assert_true(result.solvable, "seed %d is not solvable" % seed)

func test_every_door_has_a_key_on_its_start_side() -> void:
	var biome := Biomes.crypt()
	var result := generator.generate(biome, 31337)
	assert_eq(result.key_count(), result.door_count())
	for door in result.doors:
		var key_pos: Vector2i = door.key_pos
		assert_true(result.map.is_walkable_cell(key_pos))
		assert_ne(key_pos, door.position)
		assert_true(
			Pathfinding.reaches(result.map, result.start_pos, key_pos, false),
			"key for door at %s is not reachable" % str(door.position)
		)

func test_monsters_spawn_on_walkable_cells() -> void:
	var biome := Biomes.crypt()
	for seed in [31, 32, 33]:
		var result := generator.generate(biome, seed)
		for spawn in result.monster_spawns:
			assert_true(result.map.is_walkable_cell(spawn.position))

func test_monster_specs_are_valid() -> void:
	for spec in MonsterSpecs.all():
		assert_true(spec.is_valid(), "monster %s is invalid" % spec.id)
