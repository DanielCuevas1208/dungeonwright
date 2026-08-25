extends GutTest
## The game controller descends through floors and wins on the last one.
##
## Each step is synchronous, so no engine frame runs between a teleport
## and its assertion. Monsters cannot move in that window, which keeps
## the checks deterministic.

var main: Main = null

func before_each() -> void:
	var scene: PackedScene = load("res://scenes/main.tscn")
	main = scene.instantiate()
	add_child_autofree(main)
	await wait_physics_frames(1)

## Teleports the hero onto the exit tile and runs one physics tick.
func _step_to_exit() -> void:
	main.player.grid_pos = main.run.exit_pos
	main.player.position = main.dungeon_view.tile_to_world(main.run.exit_pos)
	main._physics_process(0.016)

func test_run_starts_on_the_first_floor() -> void:
	main.start_run(12345)
	assert_eq(main.floor_index, 0)
	assert_eq(main.run.seed_value, 12345)
	assert_eq(main.run_rules.floor_count, RunRules.DEFAULT_FLOORS)

func test_reaching_the_exit_descends_to_the_next_floor() -> void:
	main.start_run(4242)
	var first_seed := main.run.seed_value
	_step_to_exit()
	assert_eq(main.floor_index, 1)
	assert_eq(main.run.seed_value, RunRules.floor_seed(4242, 1))
	assert_ne(main.run.seed_value, first_seed)
	assert_eq(main.player.grid_pos, main.run.start_pos)

func test_the_descent_generates_a_fresh_solvable_floor() -> void:
	main.start_run(7)
	_step_to_exit()
	assert_true(main.run.solvable)
	assert_true(Pathfinding.reaches(main.run.map, main.run.start_pos, main.run.exit_pos, true))
	assert_eq(main.run.keys.size(), main.run.doors.size())

func test_loot_carries_between_floors() -> void:
	main.start_run(99)
	main.player.apply_pickup(&"coin", 5)
	_step_to_exit()
	assert_eq(main.player.coins, 5)

func test_live_combat_updates_run_statistics() -> void:
	main.start_run(777)
	var monster := main.monsters_root.get_child(0) as MonsterActor
	var health_before := monster.stats.health
	main._damage_monster(monster, 3)
	assert_eq(main.run_stats.damage_dealt, health_before - monster.stats.health)
	main.player.apply_pickup(&"aegis", 2)
	main.player.take_damage(8)
	assert_eq(main.run_stats.damage_blocked, 2)
	main.player.bombs = 1
	assert_true(main.player.try_throw_bomb())
	assert_eq(main.run_stats.bombs_thrown, 1)

func test_run_statistics_carry_between_floors() -> void:
	main.start_run(321)
	main.run_stats.record_damage_dealt(7)
	main.run_stats.record_damage_blocked(2)
	main.run_stats.record_bomb_thrown()
	_step_to_exit()
	assert_eq(main.run_stats.damage_dealt, 7)
	assert_eq(main.run_stats.damage_blocked, 2)
	assert_eq(main.run_stats.bombs_thrown, 1)

func test_new_run_resets_statistics() -> void:
	main.start_run(654)
	main.run_stats.record_damage_dealt(7)
	main.run_stats.record_damage_blocked(2)
	main.run_stats.record_bomb_thrown()
	main.start_run(655)
	assert_eq(main.run_stats.damage_dealt, 0)
	assert_eq(main.run_stats.damage_blocked, 0)
	assert_eq(main.run_stats.bombs_thrown, 0)

func test_keys_reset_on_descent() -> void:
	main.start_run(123)
	main.player.apply_pickup(&"key", 3)
	_step_to_exit()
	assert_eq(main.player.keys_held, 0)

func test_health_persists_and_heals_between_floors() -> void:
	main.start_run(555)
	main.player.take_damage(60)
	var damaged_health: int = main.player.stats.health
	_step_to_exit()
	assert_gt(main.player.stats.health, damaged_health)
	assert_lt(main.player.stats.health, main.player.stats.max_health)

func test_monsters_grow_stronger_on_deeper_floors() -> void:
	main.start_run(31337)
	var floor_one_scale := main.run_rules.monster_scale(0)
	_step_to_exit()
	assert_gt(main.run_rules.monster_scale(main.floor_index), floor_one_scale)

func test_winning_on_the_final_floor_shows_victory() -> void:
	main.start_run(2026)
	_step_to_exit()
	assert_eq(main.floor_index, 1)
	_step_to_exit()
	assert_eq(main.floor_index, 2)
	assert_true(main.run_rules.is_final_floor(main.floor_index))
	# The boss floor seals the exit until the warden falls.
	_step_to_exit()
	assert_eq(RunState.status, RunState.RunStatus.ACTIVE)
	_kill_the_warden()
	_step_to_exit()
	assert_eq(RunState.status, RunState.RunStatus.WON)
	assert_true(main.result_overlay.visible)

## Kills the boss that guards the final-floor exit.
func _kill_the_warden() -> void:
	assert_not_null(main._boss, "a boss should guard the final floor")
	main._boss.take_damage(100000)

func test_defeat_still_shows_the_reached_floor() -> void:
	main.start_run(404)
	main.player.take_damage(100000)
	assert_eq(RunState.status, RunState.RunStatus.LOST)
	assert_true(main.result_overlay.visible)

func test_replay_restarts_from_the_first_floor() -> void:
	main.start_run(999)
	_step_to_exit()
	assert_eq(main.floor_index, 1)
	main.start_run(999)
	assert_eq(main.floor_index, 0)
	assert_eq(main.run.seed_value, 999)
	assert_eq(main.player.coins, 0)
