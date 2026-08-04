extends SceneTree
## Headless smoke test for CI.
##
## Loads the main scene, starts a fixed-seed run, clears every floor,
## and verifies the world stays live and solvable. The final floor
## awards victory. Exits with code 0 on success and code 1 on failure.

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

	var max_floors := Descent.floor_count(_main.biome)
	for floor in range(2, max_floors + 1):
		print("[smoke] descending to floor %d" % floor)
		_step_onto_exit()
		for i in 8:
			await physics_frame
		if _failed:
			quit(1)
			return
		_verify_floor(floor)
		if _failed:
			quit(1)
			return

	print("[smoke] clearing the final floor")
	_step_onto_exit()
	for i in 8:
		await physics_frame

	if _failed:
		quit(1)
		return

	if not _main._ended:
		_fail("victory did not trigger on the final floor")
	elif RunState.status != RunState.RunStatus.WON:
		_fail("run did not end in victory")
	elif RunState.floors_cleared != RunState.max_floors:
		_fail("floors cleared does not match the run length")

	if _failed:
		print("[smoke] FAILED")
		quit(1)
	else:
		print("Smoke test passed: seed 12345 cleared %d floors." % max_floors)
		quit(0)

func _step_onto_exit() -> void:
	_main.player.grid_pos = _main.run.exit_pos
	_main.player.position = _main.dungeon_view.tile_to_world(_main.run.exit_pos)

func _verify_floor(p_expected_floor: int) -> void:
	if _main.run == null:
		_fail("no run was generated")
	elif _main.player == null:
		_fail("player was not spawned")
	elif _main.run.floor != p_expected_floor:
		_fail("expected floor %d, got %d" % [p_expected_floor, _main.run.floor])
	elif _main.player.grid_pos != _main.run.start_pos:
		_fail("player is not at the start tile")
	elif not Pathfinding.reaches(_main.run.map, _main.run.start_pos, _main.run.exit_pos, true):
		_fail("exit is not reachable from the start")
	elif not _main.run.solvable:
		_fail("dungeon is not solvable")
	_verify_input_bindings()

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
