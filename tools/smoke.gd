extends SceneTree
## Headless smoke test for CI.
##
## Loads the main scene, starts a fixed-seed run, lets the engine run a
## few frames, then verifies the world is live and solvable. It also
## descends one floor and re-verifies the new map. Exits with code 0 on
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

	_verify_current_floor(1)

	if not _failed:
		print("[smoke] descending to floor 2")
		_main.advance_floor()
		for i in 90:
			await physics_frame
		_verify_current_floor(2)
		_verify_descended_world()

	_finish()

func _verify_current_floor(p_floor: int) -> void:
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
	elif RunState.floor != p_floor:
		_fail("expected floor %d, got %d" % [p_floor, RunState.floor])
	_verify_input_bindings()

## Checks that floor 2 replays identically from the same run seed.
func _verify_descended_world() -> void:
	var floor_seed := FloorRules.seed_for(_main.run_seed, 2)
	var replay := DungeonGenerator.new().generate(
		FloorRules.scaled(Biomes.by_id(_main.run.config.id), 2),
		floor_seed
	)
	if replay.map._cells != _main.run.map._cells:
		_fail("floor 2 does not replay from the run seed")
	elif not replay.solvable:
		_fail("floor 2 replay is not solvable")
	elif _main.run.config.monster_health_scale < 1.0:
		_fail("floor 2 does not scale monster health")

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

func _finish() -> void:
	if _failed:
		print("[smoke] FAILED")
		quit(1)
	else:
		print("Smoke test passed: seed 12345 spawned solvable floors 1 and 2.")
		quit(0)

func _fail(p_message: String) -> void:
	_failed = true
	push_error("[smoke] " + p_message)
