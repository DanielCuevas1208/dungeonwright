extends GutTest
## Scene-level behaviour: a run descends through its floors.

var main: Main = null

func before_each() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	get_tree().root.add_child(main)
	get_tree().paused = false
	await wait_physics_frames(1)

func after_each() -> void:
	main.queue_free()
	RunState.status = RunState.RunStatus.IDLE
	get_tree().paused = false
	await wait_physics_frames(1)

func test_run_starts_on_floor_one() -> void:
	main.start_run(12345)
	await wait_physics_frames(2)
	assert_eq(main.run.floor, 1)
	assert_eq(main.run.floors_total, main.plan.floors_total)
	assert_eq(main.player.keys_held, 0)
	assert_eq(main.player.coins, 0)

func test_reaching_exit_descends_to_the_next_floor() -> void:
	main.start_run(4242)
	await wait_physics_frames(2)
	main.descend_delay = 0.0
	main.player.grid_pos = main.run.exit_pos
	await wait_physics_frames(6)
	assert_eq(main.run.floor, 2)
	assert_eq(main.player.grid_pos, main.run.start_pos)
	assert_true(main.run.solvable)

func test_descend_keeps_state_and_resets_keys() -> void:
	main.start_run(777)
	await wait_physics_frames(2)
	main.player.coins = 42
	main.player.add_key()
	main.player.take_damage(10)
	var hp_before: int = main.player.stats.health
	main.descend_delay = 0.0
	main.player.grid_pos = main.run.exit_pos
	await wait_physics_frames(6)
	assert_eq(main.run.floor, 2)
	assert_eq(main.player.coins, 42)
	assert_eq(main.player.keys_held, 0)
	assert_eq(main.player.stats.health, hp_before)

func test_the_last_floor_exit_wins_the_run() -> void:
	main.start_run(31337)
	await wait_physics_frames(2)
	main.descend_delay = 0.0
	for i in main.plan.floors_total:
		main.player.grid_pos = main.run.exit_pos
		await wait_physics_frames(6)
	assert_eq(RunState.status, RunState.RunStatus.WON)
	assert_true(main.result_overlay.visible)

func test_same_seed_descends_through_identical_floors() -> void:
	main.start_run(909)
	await wait_physics_frames(2)
	main.descend_delay = 0.0
	main.player.grid_pos = main.run.exit_pos
	await wait_physics_frames(6)
	assert_eq(main.run.floor, 2)
	var first := _capture()
	main.start_run(909)
	await wait_physics_frames(2)
	assert_eq(main.run.floor, 1)
	main.descend_delay = 0.0
	main.player.grid_pos = main.run.exit_pos
	await wait_physics_frames(6)
	assert_eq(main.run.floor, 2)
	var second := _capture()
	assert_eq(first, second)

func _capture() -> Dictionary:
	return {
		"biome": main.biome.id,
		"exit": main.run.exit_pos,
		"start": main.run.start_pos,
		"doors": main.run.door_count(),
		"keys": main.run.key_count(),
		"solvable": main.run.solvable,
	}
