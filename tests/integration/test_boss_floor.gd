extends GutTest
## The boss floor: the warden guards the exit, fires volleys, enrages,
## and drops a relic that ends the run.
##
## The tests drive the world by hand, so no engine frame runs between an
## action and its assertion.

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

## Descends to the final floor, which is the boss floor.
func _descend_to_boss_floor() -> void:
	main.start_run(2026)
	_step_to_exit()
	_step_to_exit()
	assert_eq(main.floor_index, 2)
	assert_true(main.run_rules.is_boss_floor(main.floor_index))

## Kills the warden so the exit unseals and the relic drops.
func _kill_warden() -> void:
	assert_not_null(main._boss, "a boss should guard the final floor")
	main._boss.take_damage(100000)

## A wide open map so a warden always has line of sight.
func _open_map() -> DungeonMap:
	var map := DungeonMap.new(24, 10)
	for x in 24:
		for y in 10:
			map.set_tile(x, y, DungeonMap.Tile.FLOOR)
	return map

## Spawns a warden monster inside the world for AI checks.
func _warden_monster(p_map: DungeonMap, p_at: Vector2i) -> MonsterActor:
	var monster := MonsterActor.new()
	main.add_child(monster)
	var view := DungeonView.new()
	view.map = p_map
	autofree(view)
	monster.setup(MonsterSpecs.warden(), p_at, view, {}, main.player)
	return monster

func test_earlier_floors_spawn_no_boss() -> void:
	main.start_run(31337)
	assert_null(main._boss)
	_step_to_exit()
	assert_eq(main.floor_index, 1)
	assert_null(main._boss)

func test_the_final_floor_spawns_the_warden() -> void:
	_descend_to_boss_floor()
	assert_not_null(main._boss)
	assert_eq(main._boss.spec.id, &"warden")
	assert_true(main.result_overlay.visible == false)

func test_the_warden_stands_guard_near_the_exit() -> void:
	_descend_to_boss_floor()
	var boss_pos: Vector2i = main._boss.grid_pos
	assert_eq(boss_pos, main.run.boss_spawn)
	assert_ne(boss_pos, main.run.exit_pos)
	assert_true(main.run.map.is_walkable_cell(boss_pos))

func test_the_exit_stays_sealed_until_the_warden_falls() -> void:
	_descend_to_boss_floor()
	_step_to_exit()
	assert_eq(main.floor_index, 2)
	assert_eq(RunState.status, RunState.RunStatus.ACTIVE)
	assert_false(main.result_overlay.visible)

func test_killing_the_warden_drops_the_relic() -> void:
	_descend_to_boss_floor()
	_kill_warden()
	assert_true(main._boss_defeated)
	assert_null(main._boss)
	var has_relic := false
	for pickup: Pickup in main.pickups_root.get_children():
		if pickup.kind == &"relic":
			has_relic = true
	assert_true(has_relic)

func test_collecting_the_relic_wins_the_run() -> void:
	_descend_to_boss_floor()
	_kill_warden()
	var relic: Pickup = null
	for pickup: Pickup in main.pickups_root.get_children():
		if pickup.kind == &"relic":
			relic = pickup
	assert_not_null(relic)
	main.player.grid_pos = relic.grid_pos
	main._collect_pickups()
	assert_eq(RunState.status, RunState.RunStatus.WON)
	assert_true(main.result_overlay.visible)

func test_the_warden_fires_a_volley_of_bolts() -> void:
	var monster := _warden_monster(_open_map(), Vector2i(2, 3))
	main.player.grid_pos = Vector2i(9, 3)
	var shots: Array = []
	monster.ranged_fired.connect(func(p_monster, p_direction):
		shots.append(p_direction)
	)
	monster._physics_process(0.016)
	assert_eq(shots.size(), 3)
	assert_true(shots.has(Vector2i.RIGHT))
	assert_true(shots.has(Vector2i(1, -1)))
	assert_true(shots.has(Vector2i(1, 1)))

func test_the_warden_does_not_fire_through_a_wall() -> void:
	var map := _open_map()
	map.set_tile(5, 3, DungeonMap.Tile.WALL)
	var monster := _warden_monster(map, Vector2i(2, 3))
	main.player.grid_pos = Vector2i(9, 3)
	var shots: Array = []
	monster.ranged_fired.connect(func(p_monster, p_direction):
		shots.append(p_direction)
	)
	monster._physics_process(0.016)
	monster._physics_process(0.016)
	assert_eq(shots.size(), 0)

func test_the_warden_melee_slams_a_close_hero() -> void:
	var monster := _warden_monster(_open_map(), Vector2i(2, 3))
	main.player.grid_pos = Vector2i(3, 3)
	var hits: Array = []
	monster.attack_player.connect(func(p_damage): hits.append(p_damage))
	monster._physics_process(0.016)
	assert_eq(hits.size(), 1)
	assert_eq(hits[0], MonsterSpecs.warden().stats.damage)

func test_the_warden_enrages_below_half_health() -> void:
	var monster := _warden_monster(_open_map(), Vector2i(2, 3))
	var enrage_calls := [0]
	monster.enraged.connect(func(p_monster): enrage_calls[0] += 1)
	monster.take_damage(100)
	assert_true(monster.stats.is_dead() == false)
	assert_eq(enrage_calls[0], 1)
	assert_true(monster._enraged)
	assert_gt(monster._speed(), monster.stats.speed)
	assert_lt(monster._cooldown(), monster.stats.attack_cooldown)

func test_the_warden_enrages_only_once() -> void:
	var monster := _warden_monster(_open_map(), Vector2i(2, 3))
	var enrage_calls := [0]
	monster.enraged.connect(func(p_monster): enrage_calls[0] += 1)
	monster.take_damage(100)
	monster.take_damage(50)
	assert_eq(enrage_calls[0], 1)
