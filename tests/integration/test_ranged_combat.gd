extends GutTest
## Ranged combat: archers fire bolts that can hit the hero.
##
## The tests drive monsters and bolts by hand, so no engine frame runs
## between an action and its assertion. This keeps every check exact.

var main: Main = null

func before_each() -> void:
	var scene: PackedScene = load("res://scenes/main.tscn")
	main = scene.instantiate()
	add_child_autofree(main)
	await wait_physics_frames(1)

## A wide open map so an archer always has line of sight.
func _open_map() -> DungeonMap:
	var map := DungeonMap.new(24, 10)
	for x in 24:
		for y in 10:
			map.set_tile(x, y, DungeonMap.Tile.FLOOR)
	return map

## Wires the hero and the view so a bolt has a map to fly across.
func _prime_hero(p_map: DungeonMap) -> void:
	main.start_run(1)
	main.dungeon_view.map = p_map

func _archer_monster(p_map: DungeonMap, p_at: Vector2i) -> MonsterActor:
	var monster := MonsterActor.new()
	main.add_child(monster)
	var view := DungeonView.new()
	view.map = p_map
	autofree(view)
	monster.setup(MonsterSpecs.archer(), p_at, view, {}, main.player)
	return monster

func test_archer_fires_a_bolt_when_it_sees_the_hero() -> void:
	var monster := _archer_monster(_open_map(), Vector2i(2, 3))
	main.player.grid_pos = Vector2i(8, 3)
	var shots: Array = []
	monster.ranged_fired.connect(func(p_monster, p_direction):
		shots.append(p_direction)
	)
	monster._physics_process(0.016)
	assert_eq(shots.size(), 1)
	assert_eq(shots[0], Vector2i.RIGHT)

func test_archer_holds_its_shot_through_a_wall() -> void:
	var map := _open_map()
	map.set_tile(5, 3, DungeonMap.Tile.WALL)
	var monster := _archer_monster(map, Vector2i(2, 3))
	main.player.grid_pos = Vector2i(8, 3)
	var shots: Array = []
	monster.ranged_fired.connect(func(p_monster, p_direction):
		shots.append(p_direction)
	)
	monster._physics_process(0.016)
	monster._physics_process(0.016)
	assert_eq(shots.size(), 0)

func test_a_spawned_bolt_damages_the_hero() -> void:
	var map := _open_map()
	_prime_hero(map)
	main.player.grid_pos = Vector2i(5, 5)
	var start_health: int = main.player.stats.health
	var bolt := main.spawn_projectile(10, 7.0, Vector2i.RIGHT, Vector2i(2, 5), 9)
	bolt.target_grid = main.player.grid_pos
	for i in 20:
		bolt.tick(0.5)
	assert_eq(main.player.stats.health, start_health - 10)
	assert_true(bolt.hit)

func test_a_bolt_miss_keeps_the_hero_healthy() -> void:
	var map := _open_map()
	_prime_hero(map)
	main.player.grid_pos = Vector2i(8, 8)
	var start_health: int = main.player.stats.health
	var bolt := main.spawn_projectile(10, 7.0, Vector2i.RIGHT, Vector2i(2, 5), 9)
	bolt.target_grid = main.player.grid_pos
	for i in 20:
		bolt.tick(0.5)
	assert_eq(main.player.stats.health, start_health)
	assert_false(bolt.hit)

func test_scaled_ranged_archer_keeps_its_shot_profile() -> void:
	var base := MonsterSpecs.archer()
	var scaled := base.scaled(2.0)
	assert_eq(scaled.ai, MonsterSpec.AI.archer)
	assert_eq(scaled.projectile_speed, base.projectile_speed)
	assert_eq(scaled.projectile_range, base.projectile_range)
	assert_gt(scaled.stats.damage, base.stats.damage)
