extends GutTest
## Every biome produces a valid dungeon with its own rules.

func test_all_biomes_are_valid() -> void:
	for biome in Biomes.all():
		assert_true(biome.is_valid(), "biome %s failed validation: %s" % [biome.id, str(biome.validate())])

func test_each_biome_builds_solvable_dungeons() -> void:
	for biome in Biomes.all():
		for seed in [101, 202, 303, 404, 505]:
			var result := DungeonGenerator.new().generate(biome, seed)
			assert_true(result.solvable, "%s seed %d is not solvable" % [biome.id, seed])
			assert_true(result.room_count() >= 2)
			assert_true(result.depth > 0)

func test_every_biome_places_keys_for_doors() -> void:
	for biome in Biomes.all():
		var result := DungeonGenerator.new().generate(biome, 999)
		assert_eq(result.key_count(), result.door_count(), biome.id)
		for key in result.keys:
			assert_true(result.map.is_walkable_cell(key.position))

func test_biomes_use_different_generation_rules() -> void:
	var crypt := Biomes.crypt()
	var forest := Biomes.drowned_forest()
	var ember := Biomes.ember_stronghold()
	assert_ne(crypt.corridor_style, forest.corridor_style)
	assert_ne(forest.corridor_style, ember.corridor_style)
	assert_ne(crypt.room_count_max, ember.room_count_max)
	assert_ne(crypt.loop_chance, forest.loop_chance)

func test_fourth_biome_frost_vault_is_distinct() -> void:
	var frost := Biomes.frost_vault()
	assert_eq(frost.id, &"frost_vault")
	assert_ne(frost.palette, Biomes.crypt().palette)
	assert_ne(frost.palette, Biomes.ember_stronghold().palette)
	assert_gt(frost.loop_chance, Biomes.crypt().loop_chance)
	assert_true(frost.is_valid())

func test_frost_vault_references_existing_monsters() -> void:
	for entry in Biomes.frost_vault().monster_table:
		var spec := MonsterSpecs.by_id(entry.monster)
		assert_eq(spec.id, entry.monster, "unknown monster %s" % entry.monster)

func test_tidebound_archive_references_existing_monsters() -> void:
	for entry in Biomes.tidebound_archive().monster_table:
		var spec := MonsterSpecs.by_id(entry.monster)
		assert_eq(spec.id, entry.monster, "unknown monster %s" % entry.monster)

func test_there_are_five_biomes() -> void:
	assert_eq(Biomes.all().size(), 5)

func test_same_seed_different_biome_differs() -> void:
	var seed := 2468
	var crypt_map := DungeonGenerator.new().generate(Biomes.crypt(), seed)
	var forest_map := DungeonGenerator.new().generate(Biomes.drowned_forest(), seed)
	var ember_map := DungeonGenerator.new().generate(Biomes.ember_stronghold(), seed)
	assert_ne(crypt_map.exit_pos, forest_map.exit_pos)
	assert_ne(crypt_map.exit_pos, ember_map.exit_pos)

func test_biome_choice_is_seeded() -> void:
	var first := Biomes.random(SeededRng.new(555))
	var second := Biomes.random(SeededRng.new(555))
	assert_eq(first.id, second.id)

func test_fifth_biome_tidebound_archive_is_distinct() -> void:
	var archive := Biomes.tidebound_archive()
	assert_eq(archive.id, &"tidebound_archive")
	assert_ne(archive.palette, Biomes.frost_vault().palette)
	assert_ne(archive.palette, Biomes.drowned_forest().palette)
	assert_gt(archive.loop_chance, Biomes.frost_vault().loop_chance)
	assert_eq(archive.corridor_style, DungeonConfig.CorridorStyle.winding)
	assert_true(archive.is_valid())

func test_tidebound_archive_replays_identically() -> void:
	var generator := DungeonGenerator.new()
	var first := generator.generate(Biomes.tidebound_archive(), 8675309)
	var second := generator.generate(Biomes.tidebound_archive(), 8675309)
	assert_eq(first.map._cells, second.map._cells)
	assert_eq(first.start_pos, second.start_pos)
	assert_eq(first.exit_pos, second.exit_pos)
	assert_eq(first.monster_spawns.size(), second.monster_spawns.size())
