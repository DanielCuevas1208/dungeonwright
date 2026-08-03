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
	_verify_audio()

## Verifies the audio hub plays every effect and the biome music.
func _verify_audio() -> void:
	if _main.audio == null:
		_fail("audio hub is missing")
	elif not _main.audio.is_ready():
		_fail("audio hub did not build its players")
	elif _main.audio._music_player.stream == null:
		_fail("run did not start the music bed")
	else:
		for id in SoundKit.ids():
			if not _main.audio.play_sfx(id, 12345):
				_fail("audio hub rejected effect " + str(id))

	var music := MusicBox.buffer(_main.run.config.id, _main.run.seed_value)
	if WaveBuilder.peak(music) <= 0.05:
		_fail("run music bed is silent")
	if WaveBuilder.peak(music) > 1.0:
		_fail("run music bed clips")
	if absf(WaveBuilder.duration(music) - MusicBox.loop_seconds()) > 0.01:
		_fail("run music bed has the wrong length")

	if _failed:
		print("[smoke] FAILED")
		quit(1)
	else:
		print("Smoke test passed: seed 12345 spawned a solvable dungeon and audio.")
		quit(0)

func _fail(p_message: String) -> void:
	_failed = true
	push_error("[smoke] " + p_message)
