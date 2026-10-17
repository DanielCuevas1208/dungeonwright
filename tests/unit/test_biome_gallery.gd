extends GutTest
## Gallery previews use stable data and the real dungeon generator.

func test_preview_seeds_are_stable_and_distinct() -> void:
	assert_eq(BiomeGallery.preview_seed(0), BiomeGallery.preview_seed(0))
	assert_ne(BiomeGallery.preview_seed(0), BiomeGallery.preview_seed(1))
	assert_eq(BiomeGallery.preview_seed(2), 1005)

func test_preview_maps_replay_identically() -> void:
	var first := BiomeGallery.preview_result(0)
	var second := BiomeGallery.preview_result(0)
	assert_eq(first.map._cells, second.map._cells)
	assert_eq(first.start_pos, second.start_pos)
	assert_eq(first.exit_pos, second.exit_pos)

func test_every_biome_has_preview_details() -> void:
	for biome in Biomes.all():
		var details := BiomeGallery.details_text(biome)
		assert_false(details.is_empty(), biome.id)
		assert_true(details.contains('Map'), biome.id)
		assert_true(details.contains('rooms'), biome.id)
		assert_true(details.contains('loops'), biome.id)

func test_every_preview_is_solvable() -> void:
	for index in Biomes.all().size():
		assert_true(BiomeGallery.preview_result(index).solvable)

func test_gallery_opens_and_closes() -> void:
	var gallery := BiomeGallery.new()
	autofree(gallery)
	add_child(gallery)
	await wait_process_frames(1)
	gallery.open()
	assert_true(gallery.visible)
	gallery.close()
	assert_false(gallery.visible)
