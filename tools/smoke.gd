extends SceneTree
## Headless smoke test for CI.
##
## Loads the main scene, starts a fixed-seed run, lets the engine run a
## few frames, then verifies the world is live and solvable. It also
## proves the run descends to a second floor. Exits with code 0 on
## success and code 1 on failure.

var _main: Main = null
var _failed := false

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

	if _failed:
		quit(1)
		return
	_verify_descend()

	if _failed:
		print("[smoke] FAILED")
		quit(1)
	else:
		print("Smoke test passed: seed 12345 spawned a solvable multi-floor run.")
		quit(0)

func _verify() -> void:
	if _main.run == null:
		_fail("no run was generated")
		return
	if _main.player == null:
		_fail("player was not spawned")
		return
	if _main.player.grid_pos != _main.run.start_pos:
		_fail("player is not at the start tile")
		return
	if not Pathfinding.reaches(_main.run.map, _main.run.start_pos, _main.run.exit_pos, true):
		_fail("exit is not reachable from the start")
		return
	if not _main.run.solvable:
		_fail("dungeon is not solvable")
		return
	_verify_input_bindings()

func _verify_descend() -> void:
	if _main.run_plan == null or _main.floors.is_empty():
		_fail("no run plan was built")
		return
	if _main.run_plan.floor_count < 2:
		_fail("run does not span multiple floors")
		return
	if _main.run.map.get_tile_cell(_main.run.exit_pos) != DungeonMap.Tile.STAIRS:
		_fail("first floor exit is not stairs")
		return

	_main.player.grid_pos = _main.run.exit_pos
	for i in 5:
		await physics_frame

	if _main.floor_index != 1:
		_fail("descending did not advance to floor 1")
		return
	if not _main.run.solvable:
		_fail("second floor is not solvable")
		return

func _verify_input_bindings() -> void:
	for action in Controls.ACTIONS:
		var has_joypad := false
		for event in InputMap.action_get_events(action):
			if event is InputEventJoypadButton or event is InputEventJoypadMotion:
				has_joypad = true
				break
		if not has_joypad:
			_fail("action %s has no gamepad binding" % action)
	if Controls.hint_for(false).is_empty() or Controls.hint_for(true).is_empty():
		_fail("control hints are empty")

func _fail(p_message: String) -> void:
	_failed = true
	push_error("[smoke] " + p_message)
