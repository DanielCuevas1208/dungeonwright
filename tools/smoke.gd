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
	await _verify_descent()
	await _verify_boss_floor()
	_main.audio.stop_all()
	for i in 5:
		await physics_frame
	if _failed:
		print("[smoke] FAILED")
		quit(1)
	else:
		print("Smoke test passed: seed 12345 spawned a solvable dungeon across floors.")
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
	elif _main.run.shrine_count() < 1:
		_fail("dungeon spawned no interactive shrine")
	elif _main.shrines_root.get_child_count() != _main.run.shrine_count():
		_fail("generated shrines did not enter the world")
	_verify_input_bindings()
	_verify_specs()
	_verify_audio()

## Every monster must resolve and have art. Every biome must reference
## a monster that exists. This guards against content drift.
func _verify_specs() -> void:
	for spec in MonsterSpecs.all():
		if not spec.is_valid():
			_fail("monster %s is invalid" % spec.id)
		if not TileArt.has_entity(StringName(spec.sprite_key)):
			_fail("monster %s has no art for key %s" % [spec.id, spec.sprite_key])
		for entry in spec.drop_table.entries:
			if not TileArt.has_entity(entry.item):
				_fail("drop item %s has no art" % entry.item)
	for biome in Biomes.all():
		for entry in biome.monster_table:
			var spec := MonsterSpecs.by_id(entry.monster)
			if spec.id != entry.monster:
				_fail("biome %s references unknown monster %s" % [biome.id, entry.monster])
	for key in [&"relic", &"emblem", &"aegis", &"warden", &"shrine"]:
		if not TileArt.has_entity(key):
			_fail("special entity %s has no art" % key)

## Every sound cue and music theme must resolve to audio.
## This guards against content drift in the audio bank.
func _verify_audio() -> void:
	if _main.audio == null:
		_fail("audio controller is missing")
		return
	for cue in SoundBank.ids():
		var stream := SoundBank.cue(cue)
		if stream == null or stream.data.is_empty():
			_fail("cue %s produced no audio" % cue)
	for biome in Biomes.all():
		var theme := MusicTheme.theme(biome.id)
		if theme == null or theme.data.is_empty() or theme.loop_mode == AudioStreamWAV.LOOP_DISABLED:
			_fail("theme %s is invalid" % biome.id)
	var menu := MusicTheme.theme(&"menu")
	if menu == null or menu.data.is_empty():
		_fail("menu theme is invalid")
	var boss := MusicTheme.theme(&"boss")
	if boss == null or boss.data.is_empty() or boss.loop_mode == AudioStreamWAV.LOOP_DISABLED:
		_fail("boss theme is invalid")

## Reaching the exit must start the next floor, not end the run.
func _verify_descent() -> void:
	_main.player.grid_pos = _main.run.exit_pos
	for i in 5:
		await physics_frame
	if _main.floor_index != 1:
		_fail("hero did not descend after reaching the exit")
	elif _main.run.seed_value != RunRules.floor_seed(12345, 1):
		_fail("floor seed is not derived from the run seed")
	elif not _main.run.solvable:
		_fail("floor 2 dungeon is not solvable")
	elif _main.player.grid_pos != _main.run.start_pos:
		_fail("hero is not at the start of the next floor")

## The final floor spawns a boss that seals the exit until it falls.
func _verify_boss_floor() -> void:
	_main.player.grid_pos = _main.run.exit_pos
	for i in 5:
		await physics_frame
	if _main.floor_index != 2:
		_fail("hero did not reach the boss floor")
		return
	if _main._boss == null:
		_fail("the boss floor spawned no boss")
		return
	_main._boss.take_damage(100000)
	for i in 3:
		await physics_frame
	if not _main._boss_defeated:
		_fail("the boss did not fall")
		return
	var has_relic := false
	for pickup in _main.pickups_root.get_children():
		if pickup.kind == &"relic":
			has_relic = true
	if not has_relic:
		_fail("the boss dropped no relic")

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
