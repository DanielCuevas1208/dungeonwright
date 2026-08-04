extends GutTest
## Music themes: every biome maps to a valid, looping theme.

func test_every_biome_has_a_looping_theme() -> void:
	for biome in Biomes.all():
		var stream := MusicTheme.theme(biome.id)
		assert_not_null(stream, biome.id)
		assert_eq(stream.loop_mode, AudioStreamWAV.LOOP_FORWARD, biome.id)
		assert_eq(stream.mix_rate, MusicTheme.MIX_RATE, biome.id)
		assert_gt(stream.data.size(), 0, biome.id)

func test_menu_theme_builds() -> void:
	var stream := MusicTheme.theme(&"menu")
	assert_not_null(stream)
	assert_eq(stream.loop_mode, AudioStreamWAV.LOOP_FORWARD)
	assert_gt(stream.data.size(), 0)

func test_theme_length_matches_the_expected_sample_count() -> void:
	var expected := roundi(MusicTheme.CHORD_DURATION * MusicTheme.CHORD_COUNT * MusicTheme.MIX_RATE)
	var stream := MusicTheme.theme(&"crypt")
	assert_eq(stream.loop_begin, 0)
	assert_eq(stream.loop_end, expected)

func test_theme_is_cached() -> void:
	assert_eq(MusicTheme.theme(&"frost_vault"), MusicTheme.theme(&"frost_vault"))

func test_themes_are_distinct() -> void:
	var menu := MusicTheme.theme(&"menu")
	var crypt := MusicTheme.theme(&"crypt")
	assert_ne(menu.data, crypt.data)

