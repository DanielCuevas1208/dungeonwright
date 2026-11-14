extends GutTest
## A Bonewalker telegraphs melee damage and misses when the hero moves away.

var main: Main = null

func before_each() -> void:
	var scene: PackedScene = load("res://scenes/main.tscn")
	main = scene.instantiate()
	add_child_autofree(main)
	await wait_physics_frames(1)

func _open_map() -> DungeonMap:
	var map := DungeonMap.new(12, 8)
	for x in 12:
		for y in 8:
			map.set_tile(x, y, DungeonMap.Tile.FLOOR)
	return map

func _bonewalker(p_at: Vector2i) -> MonsterActor:
	var monster := MonsterActor.new()
	main.add_child(monster)
	var view := DungeonView.new()
	view.map = _open_map()
	autofree(view)
	main.player.grid_pos = Vector2i(4, 3)
	monster.setup(MonsterSpecs.skeleton(), p_at, view, {}, main.player)
	autofree(monster)
	return monster

func test_bonewalker_windup_has_no_damage_window() -> void:
	var monster := _bonewalker(Vector2i(3, 3))
	var hits: Array[int] = []
	monster.attack_player.connect(func(p_damage: int): hits.append(p_damage))
	monster._physics_process(0.016)
	assert_eq(monster.attack_phase, EnemyAttackPattern.Phase.WINDUP)
	assert_true(monster._telegraph_ring.visible)
	assert_eq(hits.size(), 0)
	monster._physics_process(EnemyAttackPattern.WINDUP_DURATION - 0.02)
	assert_eq(hits.size(), 0)

func test_bonewalker_hits_once_at_attack_boundary() -> void:
	var monster := _bonewalker(Vector2i(3, 3))
	var hits: Array[int] = []
	var phases: Array[int] = []
	monster.attack_player.connect(func(p_damage: int): hits.append(p_damage))
	monster.attack_phase_changed.connect(func(p_phase: int): phases.append(p_phase))
	monster._physics_process(0.016)
	monster._physics_process(EnemyAttackPattern.WINDUP_DURATION)
	assert_eq(hits, [MonsterSpecs.skeleton().stats.damage])
	assert_eq(phases, [EnemyAttackPattern.Phase.WINDUP, EnemyAttackPattern.Phase.ATTACK])
	assert_eq(monster.attack_phase, EnemyAttackPattern.Phase.ATTACK)
	monster._physics_process(EnemyAttackPattern.ATTACK_DURATION)
	assert_eq(hits.size(), 1)
	assert_eq(monster.attack_phase, EnemyAttackPattern.Phase.RECOVERY)

func test_leaving_range_during_windup_cancels_damage() -> void:
	var monster := _bonewalker(Vector2i(3, 3))
	var hits: Array[int] = []
	monster.attack_player.connect(func(p_damage: int): hits.append(p_damage))
	monster._physics_process(0.016)
	main.player.grid_pos = Vector2i(8, 6)
	monster._physics_process(EnemyAttackPattern.WINDUP_DURATION)
	assert_eq(hits.size(), 0)
