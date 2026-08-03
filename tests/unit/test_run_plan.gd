extends GutTest
## The run plan must be deterministic, varied, and scaled with depth.

func test_floor_count_is_fixed() -> void:
	var plan := RunPlan.new()
	assert_eq(plan.floor_count, RunPlan.DEFAULT_FLOOR_COUNT)
	assert_eq(plan.floors(12345).size(), plan.floor_count)

func test_plan_is_deterministic() -> void:
	var a := RunPlan.new().floors(777)
	var b := RunPlan.new().floors(777)
	assert_eq(a.size(), b.size())
	for i in a.size():
		assert_eq(a[i].seed, b[i].seed)
		assert_eq(a[i].biome.id, b[i].biome.id)

func test_different_run_seeds_differ() -> void:
	var a := RunPlan.new().floors(1)
	var b := RunPlan.new().floors(2)
	assert_ne(a[0].seed, b[0].seed)

func test_first_floor_uses_the_run_seed() -> void:
	var floors := RunPlan.new().floors(424242)
	assert_eq(floors[0].seed, 424242 & SeededRng.SEED_MASK)

func test_floor_seeds_are_distinct() -> void:
	var floors := RunPlan.new().floors(99)
	var seen := {}
	for entry in floors:
		seen[entry.seed] = true
	assert_eq(seen.size(), floors.size())

func test_biomes_cycle_in_order() -> void:
	var plan := RunPlan.new(6)
	var floors := plan.floors(5)
	var all_biomes := Biomes.all()
	for i in floors.size():
		var biome: DungeonConfig = floors[i].biome
		assert_eq(biome.id, all_biomes[i % all_biomes.size()].id)

func test_difficulty_increases_with_floor() -> void:
	var floors := RunPlan.new(4).floors(2020)
	for i in range(1, floors.size()):
		var previous: DungeonConfig = floors[i - 1].biome
		var current: DungeonConfig = floors[i].biome
		assert_gt(current.monster_cap, previous.monster_cap)
		assert_gte(current.monster_density, previous.monster_density)

func test_density_stays_bounded() -> void:
	var floors := RunPlan.new(4).floors(818)
	for entry in floors:
		var biome: DungeonConfig = entry.biome
		assert_lte(biome.monster_density, 0.9)

func test_is_final_only_for_last_floor() -> void:
	var plan := RunPlan.new(4)
	assert_false(plan.is_final(0))
	assert_false(plan.is_final(2))
	assert_true(plan.is_final(3))

func test_single_floor_plan_is_its_own_final() -> void:
	var plan := RunPlan.new(1)
	assert_true(plan.is_final(0))

func test_every_planned_floor_is_solvable() -> void:
	var plan := RunPlan.new(4)
	var floors := plan.floors(31337)
	for i in floors.size():
		var exit_tile := DungeonMap.Tile.EXIT if plan.is_final(i) else DungeonMap.Tile.STAIRS
		var biome: DungeonConfig = floors[i].biome
		var result := DungeonGenerator.new().generate(biome, floors[i].seed, exit_tile)
		assert_true(result.solvable, "floor %d is not solvable" % i)
		assert_eq(result.map.get_tile_cell(result.exit_pos), exit_tile)

func test_scaled_config_does_not_mutate_the_source() -> void:
	var base := Biomes.ember_stronghold()
	var cap_before := base.monster_cap
	var deep := Biomes.scaled(base, 3)
	assert_eq(base.monster_cap, cap_before)
	assert_gt(deep.monster_cap, cap_before)
