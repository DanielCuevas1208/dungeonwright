extends GutTest
## The run profile scales biomes across floors and stays deterministic.

func test_total_floors_is_meaningful() -> void:
	assert_gte(RunProfile.total_floors(), 2)
	assert_false(RunProfile.is_final_floor(1))
	assert_true(RunProfile.is_final_floor(RunProfile.total_floors()))

func test_floor_seed_is_deterministic() -> void:
	assert_eq(
		RunProfile.floor_seed(12345, 2),
		RunProfile.floor_seed(12345, 2)
	)
	assert_eq(
		RunProfile.floor_seed(777, 3),
		RunProfile.floor_seed(777, 3)
	)

func test_floor_seed_differs_by_floor_and_run() -> void:
	assert_ne(RunProfile.floor_seed(12345, 1), RunProfile.floor_seed(12345, 2))
	assert_ne(RunProfile.floor_seed(12345, 2), RunProfile.floor_seed(12345, 3))
	assert_ne(RunProfile.floor_seed(12345, 2), RunProfile.floor_seed(54321, 2))

func test_floor_seed_stays_in_seed_mask() -> void:
	for run_seed in [0, 1, 999999, 16777215]:
		for floor in range(1, RunProfile.total_floors() + 1):
			assert_eq(
				RunProfile.floor_seed(run_seed, floor) & SeededRng.SEED_MASK,
				RunProfile.floor_seed(run_seed, floor)
			)

func test_config_for_scales_with_floor() -> void:
	var base := Biomes.crypt()
	var floor_one := RunProfile.config_for(base, 1)
	var floor_two := RunProfile.config_for(base, 2)
	assert_gt(floor_two.monster_cap, floor_one.monster_cap)
	assert_gt(floor_two.starting_health, floor_one.starting_health)
	assert_gt(floor_two.player_damage, floor_one.player_damage)
	assert_gt(floor_two.monster_density, floor_one.monster_density)
	assert_true(floor_two.is_valid())

func test_config_for_never_invalidates() -> void:
	for biome in Biomes.all():
		for floor in range(1, RunProfile.total_floors() + 1):
			var config := RunProfile.config_for(biome, floor)
			assert_true(config.is_valid(), "%s floor %d: %s" % [
				biome.id, floor, str(config.validate()),
			])

func test_config_for_keeps_identity_and_palette() -> void:
	var base := Biomes.drowned_forest()
	var scaled := RunProfile.config_for(base, 3)
	assert_eq(scaled.id, base.id)
	assert_eq(scaled.display_name, base.display_name)
	assert_eq(scaled.palette, base.palette)
	assert_eq(scaled.width, base.width)
	assert_eq(scaled.height, base.height)

func test_config_for_does_not_mutate_base() -> void:
	var base := Biomes.ember_stronghold()
	var health_before := base.starting_health
	var damage_before := base.player_damage
	var density_before := base.monster_density
	RunProfile.config_for(base, 3)
	assert_eq(base.starting_health, health_before)
	assert_eq(base.player_damage, damage_before)
	assert_eq(base.monster_density, density_before)

func test_config_for_is_deterministic() -> void:
	var first := RunProfile.config_for(Biomes.crypt(), 2)
	var second := RunProfile.config_for(Biomes.crypt(), 2)
	assert_eq(first.monster_density, second.monster_density)
	assert_eq(first.starting_health, second.starting_health)
	assert_eq(first.door_count_min, second.door_count_min)
	assert_eq(first.door_count_max, second.door_count_max)
