extends GutTest
## Projectile specs, aim math, and flight model.

func test_all_specs_are_valid() -> void:
	for spec in ProjectileSpecs.all():
		assert_true(spec.is_valid(), "projectile %s is invalid" % spec.id)

func test_by_id_finds_each_spec() -> void:
	for spec in ProjectileSpecs.all():
		assert_eq(ProjectileSpecs.by_id(spec.id).id, spec.id)

func test_aim_points_from_origin_toward_target() -> void:
	var spec := ProjectileSpecs.bone_spike()
	var model := Projectile.aimed(spec, Vector2i(1, 1), Vector2i(4, 1))
	var direction := model.direction
	assert_eq(signi(int(round(direction.x))), 1)
	assert_almost_eq(direction.length(), 1.0, 0.001)

func test_advance_moves_by_speed_times_delta() -> void:
	var spec := ProjectileSpecs.spore_bolt()
	var model := Projectile.aimed(spec, Vector2i(0, 0), Vector2i(8, 0))
	var start := model.position()
	model.advance(0.5)
	var moved := model.position() - start
	assert_almost_eq(moved.length(), spec.speed * Projectile.TILE_SIZE * 0.5, 0.001)

func test_travelled_distance_in_tiles() -> void:
	var spec := ProjectileSpecs.ember_bolt()
	var model := Projectile.aimed(spec, Vector2i(0, 0), Vector2i(9, 0))
	model.advance(1.0)
	assert_almost_eq(model.distance_travelled(), spec.speed, 0.001)

func test_projectile_expires_at_full_range() -> void:
	var spec := ProjectileSpecs.bone_spike()
	var model := Projectile.aimed(spec, Vector2i(0, 0), Vector2i(9, 0))
	var guard := 0
	while not model.advance(0.1) and guard < 1000:
		guard += 1
	assert_true(model.is_expired())
	assert_lte(model.distance_travelled(), spec.range + 0.001)

func test_current_tile_follows_flight() -> void:
	var spec := ProjectileSpecs.bone_spike()
	var model := Projectile.aimed(spec, Vector2i(2, 2), Vector2i(6, 2))
	model.advance(0.4)
	var tile := model.current_tile()
	assert_eq(tile.y, 2)
	assert_gte(tile.x, 2)

func test_wall_blocks_projectile() -> void:
	var map := DungeonMap.new(9, 3)
	for x in range(9):
		for y in range(3):
			map.set_tile(x, y, DungeonMap.Tile.FLOOR)
	map.set_tile(4, 1, DungeonMap.Tile.WALL)
	var spec := ProjectileSpecs.bone_spike()
	var model := Projectile.aimed(spec, Vector2i(0, 1), Vector2i(8, 1))
	var blocked := false
	var guard := 0
	while not model.advance(0.1) and guard < 1000:
		guard += 1
		if model.blocked_by(map):
			blocked = true
			break
	assert_true(blocked)

func test_locked_door_blocks_projectile() -> void:
	var map := DungeonMap.new(9, 3)
	for x in range(9):
		for y in range(3):
			map.set_tile(x, y, DungeonMap.Tile.FLOOR)
	map.set_tile(4, 1, DungeonMap.Tile.DOOR_LOCKED)
	var spec := ProjectileSpecs.bone_spike()
	var model := Projectile.aimed(spec, Vector2i(0, 1), Vector2i(8, 1))
	var blocked := false
	var guard := 0
	while not model.advance(0.1) and guard < 1000:
		guard += 1
		if model.blocked_by(map):
			blocked = true
			break
	assert_true(blocked)
