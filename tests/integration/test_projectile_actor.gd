extends GutTest
## The projectile actor flies, stops on walls, and reports hits.

var _hit := false
var _damage := 0

func _open_map() -> DungeonMap:
	var map := DungeonMap.new(20, 5)
	for x in range(20):
		for y in range(5):
			map.set_tile(x, y, DungeonMap.Tile.FLOOR)
	return map

func test_projectile_actor_hits_its_target() -> void:
	var view := DungeonView.new()
	view.map = _open_map()
	add_child_autofree(view)
	var target := Node2D.new()
	add_child_autofree(target)
	target.position = Vector2(3 * 16 + 8, 2 * 16 + 8)

	var actor := ProjectileActor.new()
	add_child_autofree(actor)
	actor.setup(ProjectileSpecs.bone_spike(), Vector2i(0, 2), Vector2i(3, 2), view, target)

	_hit = false
	_damage = 0
	actor.hit_player.connect(_on_hit)

	var guard := 0
	while not _hit and guard < 200 and is_instance_valid(actor):
		guard += 1
		await get_tree().physics_frame
	assert_true(_hit, "projectile never reached its target")
	assert_eq(_damage, ProjectileSpecs.bone_spike().damage)

func test_projectile_actor_blocks_on_wall() -> void:
	var view := DungeonView.new()
	view.map = _open_map()
	view.map.set_tile(4, 2, DungeonMap.Tile.WALL)
	add_child_autofree(view)
	var target := Node2D.new()
	add_child_autofree(target)
	target.position = Vector2(8 * 16 + 8, 2 * 16 + 8)

	var actor := ProjectileActor.new()
	add_child_autofree(actor)
	actor.setup(ProjectileSpecs.bone_spike(), Vector2i(0, 2), Vector2i(8, 2), view, target)

	_hit = false
	actor.hit_player.connect(_on_hit)

	var guard := 0
	while guard < 200 and is_instance_valid(actor):
		guard += 1
		await get_tree().physics_frame
	assert_false(_hit, "projectile passed through a wall")
	assert_false(is_instance_valid(actor), "projectile was not cleaned up")

func _on_hit(p_damage: int) -> void:
	_hit = true
	_damage = p_damage
