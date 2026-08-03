extends GutTest
## The biome music bed: fixed length, deterministic, and audible.

func test_loop_seconds_is_fixed() -> void:
	assert_almost_eq(MusicBox.loop_seconds(), 8.0, 0.001)

func test_buffer_length_matches_loop() -> void:
	for biome in Biomes.all():
		var buffer := MusicBox.buffer(biome.id, 555)
		assert_almost_eq(
			WaveBuilder.duration(buffer),
			MusicBox.loop_seconds(),
			0.001,
			"wrong length for %s" % biome.id
		)

func test_same_biome_and_seed_are_deterministic() -> void:
	for biome in Biomes.all():
		var first := MusicBox.buffer(biome.id, 777)
		var second := MusicBox.buffer(biome.id, 777)
		assert_eq(first, second, "music for %s is not deterministic" % biome.id)

func test_different_seed_changes_the_loop() -> void:
	for biome in Biomes.all():
		var first := MusicBox.buffer(biome.id, 100)
		var second := MusicBox.buffer(biome.id, 200)
		assert_ne(first, second, "music for %s ignores its seed" % biome.id)

func test_different_biomes_differ() -> void:
	var crypt := MusicBox.buffer(&"crypt", 500)
	var forest := MusicBox.buffer(&"drowned_forest", 500)
	var ember := MusicBox.buffer(&"ember_stronghold", 500)
	assert_ne(crypt, forest)
	assert_ne(crypt, ember)
	assert_ne(forest, ember)

func test_loop_is_audible() -> void:
	for biome in Biomes.all():
		var buffer := MusicBox.buffer(biome.id, 900)
		assert_gt(WaveBuilder.peak(buffer), 0.05, "music for %s is silent" % biome.id)

func test_loop_stays_bounded() -> void:
	for biome in Biomes.all():
		var buffer := MusicBox.buffer(biome.id, 900)
		assert_lte(WaveBuilder.peak(buffer), 1.0, "music for %s clips" % biome.id)

func test_loop_edges_fade_to_avoid_clicks() -> void:
	var buffer := MusicBox.buffer(&"crypt", 42)
	assert_lt(absf(buffer[0]), 0.05)
	assert_lt(absf(buffer[buffer.size() - 1]), 0.05)

func test_base_frequency_is_stable() -> void:
	assert_almost_eq(MusicBox.base_frequency(&"crypt"), 55.0, 0.001)
	assert_almost_eq(MusicBox.base_frequency(&"drowned_forest"), 49.0, 0.001)
	assert_gt(MusicBox.base_frequency(&"ember_stronghold"), 50.0)
	assert_almost_eq(MusicBox.base_frequency(&"unknown_biome"), 55.0, 0.001)
