extends GutTest
## End-to-end generation: many seeds across all biomes stay solvable.

func test_many_runs_are_solvable() -> void:
	var generator := DungeonGenerator.new()
	for biome in Biomes.all():
		for seed in range(1, 21):
			var result := generator.generate(biome, seed)
			assert_true(result.solvable, "%s seed %d is not solvable" % [biome.id, seed])

func test_exit_and_start_are_never_blocked() -> void:
	var generator := DungeonGenerator.new()
	for biome in Biomes.all():
		for seed in range(21, 41):
			var result := generator.generate(biome, seed)
			assert_true(
				Pathfinding.reaches(result.map, result.start_pos, result.exit_pos, true),
				"%s seed %d" % [biome.id, seed]
			)

func test_door_counts_stay_in_config_bounds() -> void:
	var generator := DungeonGenerator.new()
	for biome in Biomes.all():
		for seed in range(41, 51):
			var result := generator.generate(biome, seed)
			assert_gte(result.door_count(), biome.door_count_min, "%s seed %d" % [biome.id, seed])
			assert_lte(result.door_count(), biome.door_count_max, "%s seed %d" % [biome.id, seed])

func test_all_walkable_cells_form_one_region_with_doors_open() -> void:
	var generator := DungeonGenerator.new()
	var biome := Biomes.ember_stronghold()
	var result := generator.generate(biome, 818)
	var distances := Pathfinding.flood(result.map, result.start_pos, true)
	for x in result.map.width:
		for y in result.map.height:
			var cell := Vector2i(x, y)
			if result.map.is_walkable_cell(cell):
				assert_true(distances.has(cell), "disconnected cell %s" % str(cell))

func test_replay_produces_identical_world() -> void:
	var generator := DungeonGenerator.new()
	var biome := Biomes.drowned_forest()
	var a := generator.generate(biome, 909)
	var b := generator.generate(biome, 909)
	assert_eq(a.map._cells, b.map._cells)
	assert_eq(a.doors.size(), b.doors.size())
	for i in a.doors.size():
		assert_eq(a.doors[i].position, b.doors[i].position)
		assert_eq(a.doors[i].key_pos, b.doors[i].key_pos)
	for i in a.monster_spawns.size():
		assert_eq(a.monster_spawns[i].position, b.monster_spawns[i].position)
		assert_eq(a.monster_spawns[i].monster, b.monster_spawns[i].monster)

func test_custom_seed_string_matches_run_seed() -> void:
	var seed := 1048575
	var biome := Biomes.crypt()
	var result := DungeonGenerator.new().generate(biome, seed)
	assert_eq(result.seed_value, SeededRng.decode_seed(SeededRng.encode_seed(seed)))

func test_ranged_monsters_spawn_in_every_biome() -> void:
	var generator := DungeonGenerator.new()
	var seen := {}
	for biome in Biomes.all():
		for seed in range(1, 61):
			var result := generator.generate(biome, seed)
			for spawn in result.monster_spawns:
				var spec := MonsterSpecs.by_id(spawn.monster)
				if spec.ai == MonsterSpec.AI.shooter:
					seen[spec.id] = true
					assert_true(
						result.map.is_walkable_cell(spawn.position),
						"shooter %s off the floor for %s seed %d" % [spec.id, biome.id, seed]
					)
	for biome in Biomes.all():
		var biome_has_shooter := false
		for entry in biome.monster_table:
			if MonsterSpecs.by_id(entry.monster).ai == MonsterSpec.AI.shooter:
				biome_has_shooter = true
		assert_true(biome_has_shooter, "%s has no ranged monster" % biome.id)
