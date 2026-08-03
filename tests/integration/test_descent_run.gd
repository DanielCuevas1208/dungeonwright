extends GutTest
## End-to-end descent: every floor of a run stays solvable, and each
## floor of one run differs from the others.

func test_every_floor_of_every_biome_is_solvable() -> void:
	var generator := DungeonGenerator.new()
	for biome in Biomes.all():
		for run_seed in [11, 22, 33, 44, 55]:
			for floor in range(1, biome.max_floors + 1):
				var floor_seed := Descent.floor_seed(run_seed, floor)
				var result := generator.generate(biome, floor_seed, floor, run_seed)
				assert_true(
					result.solvable,
					"%s seed %d floor %d is not solvable" % [biome.id, run_seed, floor]
				)
				assert_eq(result.floor, floor)

func test_floors_of_one_run_produce_different_maps() -> void:
	var biome := Biomes.ember_stronghold()
	var generator := DungeonGenerator.new()
	var run_seed := 606
	var first := generator.generate(biome, Descent.floor_seed(run_seed, 1), 1, run_seed)
	var second := generator.generate(biome, Descent.floor_seed(run_seed, 2), 2, run_seed)
	var differences := 0
	for y in first.map.height:
		for x in first.map.width:
			if first.map.get_tile(x, y) != second.map.get_tile(x, y):
				differences += 1
	assert_gt(differences, 100)
	assert_ne(first.exit_pos, second.exit_pos)

func test_exit_stays_reachable_on_every_floor() -> void:
	var generator := DungeonGenerator.new()
	for biome in Biomes.all():
		var run_seed := 707
		for floor in range(1, biome.max_floors + 1):
			var result := generator.generate(biome, Descent.floor_seed(run_seed, floor), floor, run_seed)
			assert_true(
				Pathfinding.reaches(result.map, result.start_pos, result.exit_pos, true),
				"%s floor %d" % [biome.id, floor]
			)

func test_replay_of_a_run_repeats_every_floor() -> void:
	var biome := Biomes.crypt()
	var generator := DungeonGenerator.new()
	var run_seed := 808
	for floor in range(1, biome.max_floors + 1):
		var a := generator.generate(biome, Descent.floor_seed(run_seed, floor), floor, run_seed)
		var b := generator.generate(biome, Descent.floor_seed(run_seed, floor), floor, run_seed)
		assert_eq(a.map._cells, b.map._cells)
		assert_eq(a.doors.size(), b.doors.size())
		assert_eq(a.exit_pos, b.exit_pos)
