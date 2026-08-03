extends SceneTree
## Headless smoke test for CI.
##
## Loads the main scene, starts a fixed-seed run, lets the engine run a
## few frames, then verifies the world is live and solvable. Exits with
## code 0 on success and code 1 on failure.

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
	_verify_floor(1)
	if _failed:
		quit(1)
		return

	print("[smoke] descending to floor 2")
	_main.advance_floor()
	for i in 30:
		await physics_frame
	_verify_floor(2)
	if _failed:
		quit(1)
		return

	print("[smoke] descending to floor 3")
	_main.advance_floor()
	for i in 30:
		await physics_frame
	_verify_floor(3)

	_verify_input_bindings()

func _verify_floor(p_floor: int) -> void:
	if _main.floor_number != p_floor:
		_fail("expected floor %d, got %d" % [p_floor, _main.floor_number])
	if RunState.floor != p_floor:
		_fail("RunState.floor is %d, expected %d" % [RunState.floor, p_floor])
	if _main.run == null:
		_fail("no run was generated on floor %d" % p_floor)
		return
	if _main.player == null:
		_fail("player was not spawned on floor %d" % p_floor)
		return
	if _main.player.grid_pos != _main.run.start_pos:
		_fail("player is not at the start tile on floor %d" % p_floor)
		return
	if not _main.run.solvable:
		_fail("floor %d is not solvable" % p_floor)
		return
	if not Pathfinding.reaches(_main.run.map, _main.run.start_pos, _main.run.exit_pos, true):
		_fail("exit is not reachable on floor %d" % p_floor)
		return
	var expected_tile := DungeonMap.Tile.EXIT if RunProfile.is_final_floor(p_floor) \
		else DungeonMap.Tile.STAIRS_DOWN
	if _main.run.map.get_tile_cell(_main.run.exit_pos) != expected_tile:
		_fail("floor %d exit tile is wrong" % p_floor)
		return
	print("[smoke] floor %d verified" % p_floor)

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

	if _failed:
		print("[smoke] FAILED")
		quit(1)
	else:
		print("Smoke test passed: seed 12345 descended 3 solvable floors.")
		quit(0)

func _fail(p_message: String) -> void:
	_failed = true
	push_error("[smoke] " + p_message)
