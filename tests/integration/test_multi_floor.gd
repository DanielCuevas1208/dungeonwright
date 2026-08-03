extends GutTest
## A whole run: every floor generates, scales, and stays solvable.

func test_every_floor_of_every_biome_is_solvable() -> void:
	for biome in Biomes.all():
		for run_seed in [11, 22, 33]:
			for floor in range(1, RunProfile.total_floors() + 1):
				var config := RunProfile.config_for(biome, floor)
				var result := DungeonGenerator.new().generate(
					config, RunProfile.floor_seed(run_seed, floor)
				)
				assert_true(result.solvable, "%s seed %d floor %d" % [
					biome.id, run_seed, floor,
				])
				assert_true(
					Pathfinding.reaches(result.map, result.start_pos, result.exit_pos, true),
					"exit blocked on %s seed %d floor %d" % [biome.id, run_seed, floor],
				)

func test_floors_of_one_run_differ() -> void:
	var biome := Biomes.crypt()
	var floor_one := DungeonGenerator.new().generate(
		RunProfile.config_for(biome, 1), RunProfile.floor_seed(4242, 1)
	)
	var floor_two := DungeonGenerator.new().generate(
		RunProfile.config_for(biome, 2), RunProfile.floor_seed(4242, 2)
	)
	var differences := 0
	for y in floor_one.map.height:
		for x in floor_one.map.width:
			if floor_one.map.get_tile(x, y) != floor_two.map.get_tile(x, y):
				differences += 1
	assert_gt(differences, 100)

func test_every_floor_of_a_run_replays_identically() -> void:
	var biome := Biomes.drowned_forest()
	var run_seed := 909
	for floor in range(1, RunProfile.total_floors() + 1):
		var first := DungeonGenerator.new().generate(
			RunProfile.config_for(biome, floor), RunProfile.floor_seed(run_seed, floor)
		)
		var second := DungeonGenerator.new().generate(
			RunProfile.config_for(biome, floor), RunProfile.floor_seed(run_seed, floor)
		)
		assert_eq(first.map._cells, second.map._cells, "floor %d" % floor)
		assert_eq(first.exit_pos, second.exit_pos, "floor %d" % floor)
		assert_eq(first.start_pos, second.start_pos, "floor %d" % floor)

func test_hero_stats_ramp_with_floor() -> void:
	var biome := Biomes.ember_stronghold()
	var health_before := 0
	var damage_before := 0
	for floor in range(1, RunProfile.total_floors() + 1):
		var config := RunProfile.config_for(biome, floor)
		assert_gt(config.starting_health, health_before, "floor %d" % floor)
		assert_gt(config.player_damage, damage_before, "floor %d" % floor)
		health_before = config.starting_health
		damage_before = config.player_damage

func test_monster_pressure_ramps_with_floor() -> void:
	var biome := Biomes.crypt()
	var cap_before := 0
	var density_before := 0.0
	for floor in range(1, RunProfile.total_floors() + 1):
		var config := RunProfile.config_for(biome, floor)
		assert_gt(config.monster_cap, cap_before, "floor %d" % floor)
		assert_gt(config.monster_density, density_before, "floor %d" % floor)
		cap_before = config.monster_cap
		density_before = config.monster_density

func test_deeper_floors_stay_within_balance_bounds() -> void:
	for biome in Biomes.all():
		for floor in range(1, RunProfile.total_floors() + 1):
			var config := RunProfile.config_for(biome, floor)
			assert_lte(config.monster_density, 1.0, biome.id)
			assert_lte(config.door_count_min, config.door_count_max, biome.id)
			assert_lte(config.door_count_max, RunProfile.MAX_DOOR_COUNT, biome.id)
