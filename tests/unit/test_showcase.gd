extends GutTest
## The showcase uses one fixed, playable dungeon.

func test_featured_biome_is_the_tidebound_archive() -> void:
	assert_eq(ShowcaseOverlay.featured_config().id, StringName('tidebound_archive'))

func test_featured_seed_is_stable_and_replayable() -> void:
	assert_eq(ShowcaseOverlay.featured_seed(), BiomeGallery.preview_seed(4))
	assert_eq(ShowcaseOverlay.featured_seed_text(), '0000ZJ')

func test_featured_result_is_solvable_and_has_preview_size() -> void:
	var result := ShowcaseOverlay.featured_result()
	var config := ShowcaseOverlay.featured_config()
	assert_true(result.solvable)
	var image := DungeonPreview.render_image(result, config)
	assert_eq(image.get_width(), config.width * DungeonPreview.DEFAULT_TILE_SIZE)
	assert_eq(image.get_height(), config.height * DungeonPreview.DEFAULT_TILE_SIZE)

func test_featured_result_replays_identically() -> void:
	var first := ShowcaseOverlay.featured_result()
	var second := ShowcaseOverlay.featured_result()
	assert_eq(first.map._cells, second.map._cells)
	assert_eq(first.monster_spawns, second.monster_spawns)

func test_showcase_opens_and_closes() -> void:
	var showcase := ShowcaseOverlay.new()
	autofree(showcase)
	add_child(showcase)
	await wait_frames(1)
	showcase.open()
	assert_true(showcase.visible)
	showcase.close()
	assert_false(showcase.visible)
