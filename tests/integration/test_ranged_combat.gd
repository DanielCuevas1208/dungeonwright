extends GutTest
## Ranged combat end to end: monsters fire bolts and walls stop them.

const MONSTER_SCENE := preload("res://scenes/actors/monster.tscn")
const PROJECTILE_SCENE := preload("res://scenes/actors/projectile.tscn")

func _open_hall() -> DungeonMap:
	var map := DungeonMap.new(16, 5)
	for x in range(1, 15):
		map.set_tile(x, 2, DungeonMap.Tile.FLOOR)
	return map

func test_ranged_monster_fires_and_the_bolt_damages_the_hero() -> void:
	var view := DungeonView.new()
	add_child_autofree(view)
	view.configure(_open_hall(), Biomes.crypt())

	var occupancy := {}
	var hero := Player.new()
	hero.setup(
		CombatStats.make({ "max_health": 100, "health": 100 }),
		Vector2i(2, 2), view, occupancy
	)
	add_child_autofree(hero)
	occupancy[hero.grid_pos] = hero

	var monster: MonsterActor = MONSTER_SCENE.instantiate()
	add_child_autofree(monster)
	var spec := MonsterSpecs.bonecaster()
	monster.setup(spec, Vector2i(8, 2), view, occupancy, hero)
	occupancy[monster.grid_pos] = monster

	var shots: Array[int] = []
	var bolts: Array = []
	monster.shoot_requested.connect(
		func(_p_origin: Vector2i, p_target: Vector2i, p_spec: MonsterSpec) -> void:
			shots.append(1)
			var bolt: Projectile = PROJECTILE_SCENE.instantiate()
			add_child(bolt)
			bolts.append(bolt)
			bolt.setup(p_spec, monster.grid_pos, p_target, view, hero)
			bolt.hit_player.connect(hero.take_damage)
	)

	await wait_physics_frames(240)
	assert_gt(shots.size(), 0, "the ranged monster never fired")
	assert_lt(hero.stats.health, 100, "a bolt never damaged the hero")
	for bolt in bolts:
		if is_instance_valid(bolt):
			bolt.free()

func test_a_bolt_stops_at_a_wall_before_the_hero() -> void:
	var map := DungeonMap.new(14, 5)
	for x in range(1, 6):
		map.set_tile(x, 2, DungeonMap.Tile.FLOOR)
	for x in range(8, 13):
		map.set_tile(x, 2, DungeonMap.Tile.FLOOR)
	var view := DungeonView.new()
	add_child_autofree(view)
	view.configure(map, Biomes.crypt())

	var occupancy := {}
	var hero := Player.new()
	hero.setup(
		CombatStats.make({ "max_health": 100, "health": 100 }),
		Vector2i(11, 2), view, occupancy
	)
	add_child_autofree(hero)

	var bolt: Projectile = PROJECTILE_SCENE.instantiate()
	add_child(bolt)
	var spec := MonsterSpecs.bonecaster()
	bolt.setup(spec, Vector2i(2, 2), Vector2i(11, 2), view, hero)
	bolt.hit_player.connect(hero.take_damage)

	await wait_physics_frames(90)
	assert_eq(hero.stats.health, 100, "a wall must stop the bolt before the hero")
	if is_instance_valid(bolt):
		bolt.free()

func test_ranged_monster_keeps_distance_from_a_close_hero() -> void:
	var view := DungeonView.new()
	add_child_autofree(view)
	view.configure(_open_hall(), Biomes.crypt())

	var occupancy := {}
	var hero := Player.new()
	hero.setup(
		CombatStats.make({ "max_health": 100, "health": 100 }),
		Vector2i(4, 2), view, occupancy
	)
	add_child_autofree(hero)
	occupancy[hero.grid_pos] = hero

	var monster: MonsterActor = MONSTER_SCENE.instantiate()
	add_child_autofree(monster)
	var spec := MonsterSpecs.bonecaster()
	monster.setup(spec, Vector2i(6, 2), view, occupancy, hero)
	occupancy[monster.grid_pos] = monster

	await wait_physics_frames(180)
	var distance := absi(monster.grid_pos.x - hero.grid_pos.x) \
		+ absi(monster.grid_pos.y - hero.grid_pos.y)
	assert_gt(distance, 2, "a ranged monster must flee when the hero is too close")
