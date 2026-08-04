extends GutTest
## The descent seed chain: deterministic, distinct, and bound to the
## biome floor count.

func test_floor_one_uses_the_run_seed() -> void:
	for seed in [0, 1, 12345, 16777215]:
		assert_eq(Descent.floor_seed(seed, 1), seed)

func test_floor_seeds_are_deterministic() -> void:
	for run_seed in [7, 99, 424242]:
		var first := Descent.floor_seed(run_seed, 3)
		var second := Descent.floor_seed(run_seed, 3)
		assert_eq(first, second)

func test_floor_seeds_differ_within_a_run() -> void:
	var run_seed := 54321
	var seen := {}
	for floor in range(1, 9):
		var seed := Descent.floor_seed(run_seed, floor)
		assert_false(seen.has(seed), "floor %d repeats a seed" % floor)
		seen[seed] = true

func test_floor_seeds_stay_in_seed_range() -> void:
	for run_seed in [1, 2, 3, 65536, 16777215]:
		for floor in range(1, 9):
			var seed := Descent.floor_seed(run_seed, floor)
			assert_between(seed, 0, SeededRng.SEED_MASK)

func test_generator_reports_the_floor_and_run_seed() -> void:
	var biome := Biomes.crypt()
	var base := 31415
	for floor in [1, 2, 3]:
		var result := DungeonGenerator.new().generate(
			biome, Descent.floor_seed(base, floor), floor, base
		)
		assert_eq(result.floor, floor)
		assert_eq(result.run_seed, base)
		assert_eq(result.seed_value, Descent.floor_seed(base, floor))

func test_single_floor_calls_keep_the_old_defaults() -> void:
	var biome := Biomes.crypt()
	var result := DungeonGenerator.new().generate(biome, 999)
	assert_eq(result.floor, 1)
	assert_eq(result.run_seed, 999)
	assert_eq(result.seed_value, 999)

func test_every_biome_supports_more_than_one_floor() -> void:
	for biome in Biomes.all():
		assert_gte(biome.max_floors, 2, biome.id)

func test_max_floors_validates_positive() -> void:
	var biome := Biomes.crypt()
	biome.max_floors = 0
	assert_false(biome.is_valid())
	assert_true(biome.validate().has("max floors must be at least 1"))

func test_is_final_floor_matches_floor_count() -> void:
	var biome := Biomes.ember_stronghold()
	for floor in range(1, biome.max_floors + 1):
		var result := DungeonGenerator.new().generate(
			biome, Descent.floor_seed(77, floor), floor, 77
		)
		assert_eq(result.is_final_floor(), floor == biome.max_floors)

func test_earlier_floors_place_stairs_and_the_final_places_exit() -> void:
	var biome := Biomes.drowned_forest()
	for floor in range(1, biome.max_floors + 1):
		var result := DungeonGenerator.new().generate(
			biome, Descent.floor_seed(2024, floor), floor, 2024
		)
		var expected := DungeonMap.Tile.STAIRS if floor < biome.max_floors else DungeonMap.Tile.EXIT
		assert_eq(result.map.get_tile_cell(result.exit_pos), expected, "floor %d" % floor)

func test_monster_pressure_scales_with_floor() -> void:
	var biome := Biomes.crypt()
	assert_gt(Descent.monster_density(biome, 3), Descent.monster_density(biome, 1))
	assert_gt(Descent.monster_cap(biome, 3), Descent.monster_cap(biome, 1))
	assert_lte(Descent.monster_density(biome, 20), 1.0)
