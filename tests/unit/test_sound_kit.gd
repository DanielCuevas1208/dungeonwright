extends GutTest
## Sound effects: every id resolves, stays short, and stays audible.

func test_every_id_is_known() -> void:
	for id in SoundKit.ids():
		assert_true(SoundKit.has(id), "missing effect %s" % id)

func test_unknown_id_is_rejected() -> void:
	assert_false(SoundKit.has(&"bogus"))
	assert_false(SoundKit.has(&""))

func test_same_id_and_seed_are_deterministic() -> void:
	for id in SoundKit.ids():
		var first := SoundKit.buffer(id, 1234)
		var second := SoundKit.buffer(id, 1234)
		assert_eq(first, second, "effect %s is not deterministic" % id)

func test_seed_changes_effect_texture() -> void:
	for id in SoundKit.ids():
		var first := SoundKit.buffer(id, 10)
		var second := SoundKit.buffer(id, 20)
		assert_ne(first, second, "effect %s ignores its seed" % id)

func test_effect_durations_are_short() -> void:
	for id in SoundKit.ids():
		var buffer := SoundKit.buffer(id)
		var seconds := WaveBuilder.duration(buffer)
		assert_gt(seconds, 0.02, "effect %s is too short" % id)
		assert_lt(seconds, 1.5, "effect %s is too long" % id)

func test_effects_are_audible() -> void:
	for id in SoundKit.ids():
		var buffer := SoundKit.buffer(id)
		assert_gt(WaveBuilder.peak(buffer), 0.1, "effect %s is silent" % id)

func test_effects_stay_bounded() -> void:
	for id in SoundKit.ids():
		var buffer := SoundKit.buffer(id)
		assert_lte(WaveBuilder.peak(buffer), 1.0, "effect %s clips" % id)

func test_effects_differ_from_each_other() -> void:
	var ids := SoundKit.ids()
	for i in ids.size():
		for j in range(i + 1, ids.size()):
			var a := SoundKit.buffer(ids[i])
			var b := SoundKit.buffer(ids[j])
			assert_ne(a, b, "effects %s and %s are identical" % [ids[i], ids[j]])

func test_unknown_id_returns_short_silence() -> void:
	var buffer := SoundKit.buffer(&"bogus")
	assert_almost_eq(WaveBuilder.peak(buffer), 0.0, 0.0001)
