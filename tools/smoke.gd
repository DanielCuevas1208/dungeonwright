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
	_verify_input_bindings()
	_verify_descent()

## The descent must advance the floor, keep coins, and reset keys.
func _verify_descent() -> void:
	var first_cells := _main.run.map._cells.duplicate()
	_main.player.coins = 7
	_main.player.keys_held = 3
	_main.descend()
	if _main.current_floor != 1:
		_fail("descent did not advance the floor")
	elif _main.run == null:
		_fail("descent did not generate a floor")
	elif _main.run.map._cells == first_cells:
		_fail("descent reused the previous map")
	elif _main.player.coins != 7:
		_fail("coins did not carry over the descent")
	elif _main.player.keys_held != 0:
		_fail("keys did not reset on descent")
	elif not _main.run.solvable:
		_fail("descended floor is not solvable")

	if _failed:
		print("[smoke] FAILED")
		quit(1)
	else:
		print("Smoke test passed: seed 12345 spawned a solvable dungeon.")
		quit(0)

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
