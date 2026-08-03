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
	if _failed:
		quit(1)
		return
	await _verify_descent()
	if _failed:
		quit(1)
		return
	print("Smoke test passed: seed 12345 spawned a solvable dungeon.")
	quit(0)

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

func _verify_descent() -> void:
	if _main.plan == null:
		_fail("no run plan was built")
		return
	if _main.run.floor != 1 or _main.run.floors_total != _main.plan.floors_total:
		_fail("floor counter is wrong")
		return
	_main.descend_delay = 0.0
	_main.player.grid_pos = _main.run.exit_pos
	for i in 10:
		await physics_frame
	if _main.run.floor != 2:
		_fail("hero did not descend to floor 2")
		return
	if _main.player.grid_pos != _main.run.start_pos:
		_fail("hero is not at the new floor start")
		return
	if not _main.run.solvable:
		_fail("floor 2 dungeon is not solvable")
		return
	print("[smoke] descent to floor 2 verified")

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
