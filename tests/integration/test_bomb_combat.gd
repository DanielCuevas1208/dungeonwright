extends GutTest
## Bomb combat: the hero throws bombs and the blast hurts monsters.
##
## The tests drive the world by hand, so no engine frame runs between an
## action and its assertion. Monsters sit on a wide open map so the bomb
## always has room to land and the blast hits exactly who it should.

var main: Main = null

func before_each() -> void:
	var scene: PackedScene = load("res://scenes/main.tscn")
	main = scene.instantiate()
	add_child_autofree(main)
	await wait_physics_frames(1)

func _open_map() -> DungeonMap:
	var map := DungeonMap.new(20, 12)
	for x in 20:
		for y in 12:
			map.set_tile(x, y, DungeonMap.Tile.FLOOR)
	return map

## Starts a run and swaps in the open map for the test.
func _prime(p_map: DungeonMap) -> void:
	main.start_run(1)
	main.dungeon_view.map = p_map

## Spawns a durable monster inside the world so a blast can reach it.
func _monster_at(p_map: DungeonMap, p_cell: Vector2i) -> MonsterActor:
	var monster := MonsterActor.new()
	main.monsters_root.add_child(monster)
	var view := DungeonView.new()
	view.map = p_map
	autofree(view)
	monster.setup(MonsterSpecs.golem(), p_cell, view, {}, main.player)
	return monster

## Throws a bomb right from (2, 4) and runs it to detonation.
func _throw_and_detonate() -> Bomb:
	var bomb := main.spawn_bomb(Vector2i(2, 4), Vector2i.RIGHT)
	for i in 6:
		bomb.tick(0.2)
	assert_true(bomb.is_expired())
	return bomb

func test_a_bomb_blast_damages_monsters_inside_the_radius() -> void:
	var map := _open_map()
	_prime(map)
	var monster := _monster_at(map, Vector2i(6, 4))
	var start_health: int = monster.stats.health
	var bomb := _throw_and_detonate()
	assert_eq(bomb.grid_pos, Vector2i(4, 4))
	assert_eq(monster.stats.health, start_health - bomb.damage)

func test_a_bomb_blast_ignores_monsters_outside_the_radius() -> void:
	var map := _open_map()
	_prime(map)
	var monster := _monster_at(map, Vector2i(9, 4))
	var start_health: int = monster.stats.health
	_throw_and_detonate()
	assert_eq(monster.stats.health, start_health)

func test_a_bomb_can_kill_a_frail_monster() -> void:
	var map := _open_map()
	_prime(map)
	var monster := MonsterActor.new()
	main.monsters_root.add_child(monster)
	var view := DungeonView.new()
	view.map = map
	autofree(view)
	monster.setup(MonsterSpecs.crawler(), Vector2i(6, 4), view, {}, main.player)
	_throw_and_detonate()
	assert_true(monster.stats.is_dead())

func test_the_hero_throws_a_bomb_when_it_has_one() -> void:
	var map := _open_map()
	_prime(map)
	main.player.apply_pickup(&"bomb", 1)
	var thrown: Array = []
	main.player.bomb_thrown.connect(func(p_origin, p_facing):
		thrown.append([p_origin, p_facing])
	)
	assert_true(main.player.try_throw_bomb())
	assert_eq(main.player.bombs, 0)
	assert_eq(thrown.size(), 1)
	assert_eq(thrown[0][0], main.player.grid_pos + main.player.facing)

func test_throwing_spawns_a_bomb_in_the_world() -> void:
	_prime(_open_map())
	main.player.apply_pickup(&"bomb", 1)
	assert_true(main.player.try_throw_bomb())
	assert_eq(main.bombs_root.get_child_count(), 1)

func test_the_hero_cannot_throw_without_a_bomb() -> void:
	_prime(_open_map())
	assert_false(main.player.try_throw_bomb())
	assert_eq(main.player.bombs, 0)
	assert_eq(main.bombs_root.get_child_count(), 0)
