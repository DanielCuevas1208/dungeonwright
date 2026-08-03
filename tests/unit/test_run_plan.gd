extends GutTest
## The run plan turns a base seed into a reproducible set of floors.

func test_same_seed_reproduces_the_floor_plan() -> void:
	var a := RunPlan.make(12345)
	var b := RunPlan.make(12345)
	for i in 5:
		assert_eq(a.floor_seed(i), b.floor_seed(i))
		assert_eq(a.biome_for(i).id, b.biome_for(i).id)

func test_each_floor_uses_a_different_seed() -> void:
	var plan := RunPlan.make(999)
	var seen := {}
	for i in 6:
		assert_false(seen.has(plan.floor_seed(i)), "floor %d repeats a seed" % i)
		seen[plan.floor_seed(i)] = true

func test_floor_seeds_stay_in_seed_range() -> void:
	var plan := RunPlan.make(0xFFFFFFFFFF)
	for i in 3:
		var seed := plan.floor_seed(i)
		assert_gte(seed, 0)
		assert_lt(seed, SeededRng.SEED_MASK + 1)

func test_first_floor_seed_is_the_base_seed() -> void:
	var plan := RunPlan.make(4242)
	assert_eq(plan.floor_seed(0), 4242 & SeededRng.SEED_MASK)

func test_different_base_seeds_build_different_floors() -> void:
	var a := RunPlan.make(1)
	var b := RunPlan.make(2)
	var differences := 0
	for i in 8:
		if a.floor_seed(i) != b.floor_seed(i):
			differences += 1
	assert_gt(differences, 5)

func test_floors_total_defaults_to_three() -> void:
	assert_eq(RunPlan.make(7).floors_total, 3)

func test_floors_total_is_configurable_and_clamped() -> void:
	assert_eq(RunPlan.make(7, 1).floors_total, 1)
	assert_eq(RunPlan.make(7, 5).floors_total, 5)
	assert_eq(RunPlan.make(7, 0).floors_total, 1)

func test_every_floor_builds_a_solvable_dungeon() -> void:
	var plan := RunPlan.make(24680)
	for i in plan.floors_total:
		var result := DungeonGenerator.new().generate(
			plan.biome_for(i), plan.floor_seed(i)
		)
		assert_true(result.solvable, "floor %d is not solvable" % (i + 1))
