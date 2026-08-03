extends GutTest
## Floor progression: seed derivation, scaling, and replayable descents.

func test_seed_for_floor_is_deterministic() -> void:
	assert_eq(FloorRules.seed_for(12345, 2), FloorRules.seed_for(12345, 2))
	assert_eq(FloorRules.seed_for(999, 4), FloorRules.seed_for(999, 4))

func test_different_floors_derive_different_seeds() -> void:
	var seen := {}
	for floor in range(1, FloorRules.FLOOR_COUNT + 1):
		var seed := FloorRules.seed_for(12345, floor)
		assert_false(seen.has(seed), "floor %d repeats a seed" % floor)
		seen[seed] = true

func test_final_floor_is_recognised() -> void:
	assert_eq(FloorRules.FLOOR_COUNT, 5)
	assert_true(FloorRules.is_final(FloorRules.FLOOR_COUNT))
	assert_false(FloorRules.is_final(FloorRules.FLOOR_COUNT - 1))

func test_scaled_keeps_biome_identity() -> void:
	var biome := Biomes.crypt()
	var scaled := FloorRules.scaled(biome, 3)
	assert_eq(scaled.id, biome.id)
	assert_eq(scaled.display_name, biome.display_name)
	assert_eq(scaled.palette, biome.palette)

func test_scaled_stays_valid_on_every_floor() -> void:
	for biome in Biomes.all():
		for floor in range(1, FloorRules.FLOOR_COUNT + 1):
			var scaled := FloorRules.scaled(biome, floor)
			assert_true(scaled.is_valid(), "%s floor %d is invalid" % [biome.id, floor])

func test_deeper_floors_scale_monster_pressure() -> void:
	var base := Biomes.crypt()
	var shallow := FloorRules.scaled(base, 1)
	var deep := FloorRules.scaled(base, 5)
	assert_eq(shallow.monster_health_scale, 1.0)
	assert_gt(deep.monster_health_scale, shallow.monster_health_scale)
	assert_gt(deep.monster_damage_scale, shallow.monster_damage_scale)
	assert_gt(deep.monster_density, shallow.monster_density)
	assert_gte(deep.monster_cap, shallow.monster_cap)
	assert_gte(deep.door_count_max, shallow.door_count_max)

func test_same_floor_scales_the_same() -> void:
	var a := FloorRules.scaled(Biomes.crypt(), 4)
	var b := FloorRules.scaled(Biomes.crypt(), 4)
	assert_eq(a.monster_health_scale, b.monster_health_scale)
	assert_eq(a.monster_density, b.monster_density)

func test_full_descent_replays_identically() -> void:
	var first := _descent(777)
	var second := _descent(777)
	assert_eq(first.size(), second.size())
	for floor in first.size():
		assert_true(first[floor].solvable)
		assert_eq(
			first[floor].map._cells, second[floor].map._cells,
			"floor %d differs" % (floor + 1)
		)

func _descent(p_run_seed: int) -> Array[DungeonResult]:
	var results: Array[DungeonResult] = []
	var generator := DungeonGenerator.new()
	for floor in range(1, FloorRules.FLOOR_COUNT + 1):
		var floor_seed := FloorRules.seed_for(p_run_seed, floor)
		var biome := Biomes.random(SeededRng.new(floor_seed ^ 0x5EED))
		results.append(generator.generate(FloorRules.scaled(biome, floor), floor_seed))
	return results
