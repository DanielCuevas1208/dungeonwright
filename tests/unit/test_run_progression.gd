extends GutTest
## RunProgression: deterministic floor seeds, biome choice, and scaling.

func test_floor_seed_is_deterministic() -> void:
	assert_eq(RunProgression.floor_seed(123, 2), RunProgression.floor_seed(123, 2))

func test_floor_seed_changes_with_floor() -> void:
	assert_ne(RunProgression.floor_seed(777, 0), RunProgression.floor_seed(777, 1))
	assert_ne(RunProgression.floor_seed(777, 1), RunProgression.floor_seed(777, 2))

func test_floor_seed_stays_in_seed_mask() -> void:
	for run_seed in [1, 7, 999, 123456]:
		for floor in range(0, RunProgression.TOTAL_FLOORS):
			var value := RunProgression.floor_seed(run_seed, floor)
			assert_lte(value, SeededRng.SEED_MASK)
			assert_gte(value, 0)

func test_floor_zero_seed_equals_run_seed() -> void:
	assert_eq(RunProgression.floor_seed(4242, 0), 4242 & SeededRng.SEED_MASK)

func test_biome_for_floor_is_deterministic() -> void:
	for run_seed in [1, 2, 3]:
		for floor in range(0, RunProgression.TOTAL_FLOORS):
			var first := RunProgression.biome_for_floor(run_seed, floor)
			var second := RunProgression.biome_for_floor(run_seed, floor)
			assert_eq(first.id, second.id)

func test_every_floor_biome_is_valid() -> void:
	for run_seed in [5, 6, 7, 8]:
		for floor in range(0, RunProgression.TOTAL_FLOORS):
			var biome := RunProgression.biome_for_floor(run_seed, floor)
			assert_true(biome.is_valid(), "run %d floor %d invalid" % [run_seed, floor])

func test_biome_choice_covers_multiple_biomes() -> void:
	var seen := {}
	for run_seed in range(1, 31):
		for floor in range(0, RunProgression.TOTAL_FLOORS):
			seen[RunProgression.biome_for_floor(run_seed, floor).id] = true
	assert_gte(seen.size(), 2, "the descent should mix biomes")

func test_is_final_floor() -> void:
	assert_true(RunProgression.is_final_floor(RunProgression.TOTAL_FLOORS - 1))
	assert_false(RunProgression.is_final_floor(0))
	assert_false(RunProgression.is_final_floor(RunProgression.TOTAL_FLOORS - 2))

func test_floor_zero_scales_are_neutral() -> void:
	assert_eq(RunProgression.monster_health_scale(0), 1.0)
	assert_eq(RunProgression.monster_damage_scale(0), 1.0)
	assert_eq(RunProgression.density_multiplier(0), 1.0)
	assert_eq(RunProgression.cap_bonus(0), 0)

func test_monster_scales_grow_with_floor() -> void:
	assert_lt(RunProgression.monster_health_scale(0), RunProgression.monster_health_scale(1))
	assert_lt(RunProgression.monster_health_scale(1), RunProgression.monster_health_scale(2))
	assert_lt(RunProgression.monster_damage_scale(0), RunProgression.monster_damage_scale(1))
	assert_lt(RunProgression.density_multiplier(0), RunProgression.density_multiplier(2))
	assert_gt(RunProgression.cap_bonus(2), RunProgression.cap_bonus(0))

func test_total_floors_is_reasonable() -> void:
	assert_gt(RunProgression.TOTAL_FLOORS, 1)
	assert_lt(RunProgression.TOTAL_FLOORS, 10)
