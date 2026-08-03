extends SceneTree
## Headless smoke test for CI.
##
## Loads the main scene, starts a fixed-seed run, lets the engine run a
## few frames, then verifies the world is live and solvable. Exits with
## code 0 on success and code 1 on failure.

var _main: Main = null
var _failed := false
var _projectile_hit := false

func _initialize() -> void:
	_run()

func _run() -> void:
	print("[smoke] loading main scene")
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_fail("main scene failed to load")
		quit(1)
		return
	_main = scene.instantiate()
	root.add_child(_main)
	print("[smoke] scene added")

	for i in 5:
		await process_frame

	print("[smoke] starting run with seed 12345")
	_main.start_run(12345)

	for i in 90:
		await physics_frame

	if _failed:
		quit(1)
		return
	_verify()

func _verify() -> void:
	if _main.run == null:
		_fail("no run was generated")
	elif _main.player == null:
		_fail("player was not spawned")
	elif _main.player.grid_pos != _main.run.start_pos:
		_fail("player is not at the start tile")
	elif not Pathfinding.reaches(_main.run.map, _main.run.start_pos, _main.run.exit_pos, true):
		_fail("exit is not reachable from the start")
	elif not _main.run.solvable:
		_fail("dungeon is not solvable")
	_verify_projectile()

func _verify_projectile() -> void:
	var projectile: ProjectileActor = preload("res://scenes/actors/projectile.tscn").instantiate()
	_main.projectiles_root.add_child(projectile)
	var target_cell := _main.player.grid_pos
	var origin_cell := _pick_clear_origin(target_cell)
	if origin_cell == Vector2i(-1, -1):
		_fail("no clear line to the hero for a projectile")
		projectile.queue_free()
		return
	_projectile_hit = false
	var hp_before := _main.player.stats.health
	projectile.hit_player.connect(_on_smoke_projectile_hit)
	projectile.setup(ProjectileSpecs.bone_spike(), origin_cell, target_cell, _main.dungeon_view, _main.player)
	for i in 60:
		await physics_frame
		if not is_instance_valid(projectile):
			break
	if not _projectile_hit:
		_fail("projectile did not reach the hero")
	elif _main.player.stats.health >= hp_before:
		_fail("projectile hit did no damage")

	if _failed:
		print("[smoke] FAILED")
		quit(1)
	else:
		print("Smoke test passed: seed 12345 spawned a solvable dungeon and a projectile.")
		quit(0)

func _on_smoke_projectile_hit(p_damage: int) -> void:
	_projectile_hit = true
	_main.player.take_damage(p_damage)

## Finds a cell two tiles away that has line of sight to the hero.
func _pick_clear_origin(p_target: Vector2i) -> Vector2i:
	for direction: Vector2i in Pathfinding.ORTHO:
		var origin := p_target + direction * 2
		if not _main.run.map.in_bounds_cell(origin):
			continue
		if not _main.run.map.is_walkable_cell(origin):
			continue
		if not Pathfinding.line_of_sight(_main.run.map, origin, p_target):
			continue
		return origin
	return Vector2i(-1, -1)

func _fail(p_message: String) -> void:
	_failed = true
	push_error("[smoke] " + p_message)
