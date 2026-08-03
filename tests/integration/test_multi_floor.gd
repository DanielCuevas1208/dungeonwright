extends GutTest
## Multi-floor runs: deterministic sequences, solvable floors, and scale.

func test_run_replays_identical_floor_sequence() -> void:
	var first := _build_floors(12345)
	var second := _build_floors(12345)
	assert_eq(first.size(), RunProgression.TOTAL_FLOORS)
	for floor in range(first.size()):
		assert_eq(first[floor].config.id, second[floor].config.id)
		assert_eq(first[floor].map._cells, second[floor].map._cells)

func test_floor_maps_differ_within_a_run() -> void:
	var floors := _build_floors(909)
	assert_ne(floors[0].map._cells, floors[1].map._cells)
	assert_ne(floors[1].map._cells, floors[2].map._cells)

func test_every_floor_is_solvable() -> void:
	for run_seed in [7, 8, 9, 10]:
		for floor in _build_floors(run_seed):
			assert_true(floor.solvable, "run %d has an unsolvable floor" % run_seed)

func test_start_and_exit_are_valid_on_every_floor() -> void:
	for floor in _build_floors(31337):
		assert_true(floor.map.is_walkable_cell(floor.start_pos))
		assert_true(floor.map.is_walkable_cell(floor.exit_pos))
		assert_true(Pathfinding.reaches(floor.map, floor.start_pos, floor.exit_pos, true))

func test_floor_zero_generation_matches_single_floor_run() -> void:
	var run_seed := 8080
	var biome := RunProgression.biome_for_floor(run_seed, 0)
	var through_progression := DungeonGenerator.new().generate(
		biome, RunProgression.floor_seed(run_seed, 0), 0
	)
	var direct := DungeonGenerator.new().generate(biome, RunProgression.floor_seed(run_seed, 0))
	assert_eq(through_progression.map._cells, direct.map._cells)
	assert_eq(through_progression.monster_spawns.size(), direct.monster_spawns.size())

func test_deeper_floors_hold_more_monsters() -> void:
	var counts := [0, 0, 0]
	for run_seed in range(1, 13):
		var floors := _build_floors(run_seed)
		for floor in range(floors.size()):
			counts[floor] += floors[floor].monster_count()
	assert_gt(counts[2], counts[0], "deep floors should host more monsters")
	assert_gt(counts[2], counts[1])

func test_monster_stats_scale_with_floor() -> void:
	var spec := MonsterSpecs.by_id(&"skeleton")
	var floor_zero_hp := maxi(1, roundi(spec.stats.max_health * RunProgression.monster_health_scale(0)))
	var floor_two_hp := maxi(1, roundi(spec.stats.max_health * RunProgression.monster_health_scale(2)))
	assert_gt(floor_two_hp, floor_zero_hp)

func test_actor_spawn_applies_floor_scale() -> void:
	var view := DungeonView.new()
	add_child_autofree(view)
	await wait_frames(1)
	var run_seed := 55
	var floor := 2
	var biome := RunProgression.biome_for_floor(run_seed, floor)
	var result := DungeonGenerator.new().generate(
		biome, RunProgression.floor_seed(run_seed, floor), floor
	)
	view.configure(result.map, biome)
	var monster: MonsterActor = preload("res://scenes/actors/monster.tscn").instantiate()
	add_child_autofree(monster)
	var spec := MonsterSpecs.by_id(&"skeleton")
	monster.setup(
		spec,
		result.start_pos,
		view,
		{},
		null,
		RunProgression.monster_health_scale(floor),
		RunProgression.monster_damage_scale(floor)
	)
	assert_eq(
		monster.stats.max_health,
		maxi(1, roundi(spec.stats.max_health * RunProgression.monster_health_scale(floor)))
	)
	assert_eq(
		monster.stats.damage,
		maxi(1, roundi(spec.stats.damage * RunProgression.monster_damage_scale(floor)))
	)

func _build_floors(p_run_seed: int) -> Array[DungeonResult]:
	var floors: Array[DungeonResult] = []
	for floor in range(RunProgression.TOTAL_FLOORS):
		var biome := RunProgression.biome_for_floor(p_run_seed, floor)
		floors.append(DungeonGenerator.new().generate(
			biome, RunProgression.floor_seed(p_run_seed, floor), floor
		))
	return floors
