extends GutTest
## The run rules produce a deterministic, escalating descent.

func test_floor_zero_uses_the_run_seed() -> void:
	for seed in [1, 42, 424242, 1048575]:
		assert_eq(RunRules.floor_seed(seed, 0), seed & SeededRng.SEED_MASK)

func test_floor_seeds_differ_between_floors() -> void:
	for seed in [1, 777, 31337]:
		var floor0 := RunRules.floor_seed(seed, 0)
		var floor1 := RunRules.floor_seed(seed, 1)
		var floor2 := RunRules.floor_seed(seed, 2)
		assert_ne(floor0, floor1, "floor 0 and 1 collide for seed %d" % seed)
		assert_ne(floor1, floor2, "floor 1 and 2 collide for seed %d" % seed)
		assert_ne(floor0, floor2, "floor 0 and 2 collide for seed %d" % seed)

func test_floor_seed_is_deterministic() -> void:
	var first := RunRules.floor_seed(90210, 3)
	var second := RunRules.floor_seed(90210, 3)
	assert_eq(first, second)

func test_floor_seed_stays_in_seed_range() -> void:
	for seed in [0, 5, 123456]:
		for floor in range(0, 6):
			var value := RunRules.floor_seed(seed, floor)
			assert_lte(value, SeededRng.SEED_MASK)
			assert_gte(value, 0)

func test_only_the_last_floor_finishes_the_run() -> void:
	var rules := RunRules.new()
	rules.floor_count = 3
	assert_false(rules.is_final_floor(0))
	assert_false(rules.is_final_floor(1))
	assert_true(rules.is_final_floor(2))

func test_only_the_last_floor_is_a_boss_floor() -> void:
	var rules := RunRules.new()
	rules.floor_count = 3
	assert_false(rules.is_boss_floor(0))
	assert_false(rules.is_boss_floor(1))
	assert_true(rules.is_boss_floor(2))

func test_a_single_floor_run_is_always_a_boss_floor() -> void:
	var rules := RunRules.new()
	rules.floor_count = 1
	assert_true(rules.is_boss_floor(0))
	assert_true(rules.is_final_floor(0))

func test_single_floor_run_finishes_on_floor_one() -> void:
	var rules := RunRules.new()
	rules.floor_count = 1
	assert_true(rules.is_final_floor(0))

func test_monster_scale_starts_at_one_and_grows() -> void:
	var rules := RunRules.new()
	assert_eq(rules.monster_scale(0), 1.0)
	assert_gt(rules.monster_scale(2), rules.monster_scale(1))
	assert_gt(rules.monster_scale(1), 1.0)

func test_heal_between_restores_fraction_of_missing_health() -> void:
	var rules := RunRules.new()
	rules.heal_between_floors = 0.5
	var stats := CombatStats.make({"max_health": 100, "health": 40})
	var gained := rules.heal_between(stats)
	assert_eq(gained, 30)
	assert_eq(stats.health, 70)

func test_heal_between_never_exceeds_max_health() -> void:
	var rules := RunRules.new()
	var stats := CombatStats.make({"max_health": 50, "health": 45})
	rules.heal_between(stats)
	assert_lte(stats.health, stats.max_health)

func test_heal_between_does_nothing_at_full_health() -> void:
	var rules := RunRules.new()
	var stats := CombatStats.make({"max_health": 30, "health": 30})
	assert_eq(rules.heal_between(stats), 0)
	assert_eq(stats.health, 30)
