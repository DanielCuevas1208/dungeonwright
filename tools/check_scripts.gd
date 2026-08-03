extends SceneTree
## Static checks for CI.
##
## Loads every GDScript file in the project and reports parse errors.
## It also verifies that the biome and monster registries stay consistent
## with the art and drop tables, and that seeds round-trip. Exits with
## code 0 on success and code 1 on failure.

var _failed := false

func _initialize() -> void:
	_check_scripts()
	_check_registries()
	_check_seed_math()
	if _failed:
		print("[check] FAILED")
		quit(1)
	else:
		print("[check] all static checks passed")
		quit(0)

func _check_scripts() -> void:
	for dir in ["res://scripts", "res://tests", "res://tools"]:
		_scan_dir(dir)

func _scan_dir(p_dir: String) -> void:
	var dir := DirAccess.open(p_dir)
	if dir == null:
		_fail("cannot open " + p_dir)
		return
	dir.list_dir_begin()
	var name := dir.get_next()
	while name != "":
		if dir.current_is_dir():
			if name != "." and name != "..":
				_scan_dir(p_dir.path_join(name))
		elif name.ends_with(".gd"):
			var script := load(p_dir.path_join(name))
			if script == null:
				_fail("failed to load " + p_dir.path_join(name))
		name = dir.get_next()
	dir.list_dir_end()

func _check_registries() -> void:
	for biome in Biomes.all():
		if not biome.is_valid():
			_fail("biome %s is invalid: %s" % [biome.id, str(biome.validate())])
			continue
		for entry in biome.monster_table:
			var monster_id: StringName = entry.monster
			var spec := MonsterSpecs.by_id(monster_id)
			if spec.id != monster_id:
				_fail("biome %s references unknown monster %s" % [biome.id, monster_id])
			if not TileArt.has_entity(monster_id):
				_fail("monster %s has no sprite" % monster_id)
	for spec in MonsterSpecs.all():
		if not spec.is_valid():
			_fail("monster %s is invalid" % spec.id)
		if not TileArt.has_entity(StringName(spec.sprite_key)):
			_fail("monster %s sprite %s has no art" % [spec.id, spec.sprite_key])
	for item in [&"player", &"key", &"potion", &"coin"]:
		if not TileArt.has_entity(item):
			_fail("entity %s has no art" % item)
	for entry in RunPlan.new().floors(7):
		var config: DungeonConfig = entry.biome
		if not config.is_valid():
			_fail("planned floor biome %s is invalid" % config.id)

func _check_seed_math() -> void:
	if SeededRng.decode_seed(SeededRng.encode_seed(1048575)) != 1048575:
		_fail("seed round-trip failed")
	if SeededRng.derive(123, 1) == SeededRng.derive(123, 2):
		_fail("seed derivation ignores the salt")
	if SeededRng.derive(1, 9) == SeededRng.derive(2, 9):
		_fail("seed derivation ignores the base seed")

func _fail(p_message: String) -> void:
	_failed = true
	push_error("[check] " + p_message)
