extends GutTest
## Sound bank: every cue resolves to a distinct, playable stream.

func test_every_cue_builds_a_stream() -> void:
	for cue in SoundBank.ids():
		var stream := SoundBank.cue(cue)
		assert_not_null(stream, "cue %s" % cue)
		assert_eq(stream.format, AudioStreamWAV.FORMAT_16_BITS, "cue %s" % cue)
		assert_false(stream.stereo, "cue %s" % cue)
		assert_gt(stream.data.size(), 0, "cue %s" % cue)
		assert_eq(stream.data.size() % 2, 0, "cue %s" % cue)

func test_cues_are_unique() -> void:
	var seen := {}
	for cue in SoundBank.ids():
		seen[cue] = true
	assert_eq(seen.size(), SoundBank.ids().size())

func test_cue_is_cached() -> void:
	var first := SoundBank.cue(&"coin")
	var second := SoundBank.cue(&"coin")
	assert_eq(first, second)
	assert_eq(first.data, second.data)

func test_has_rejects_unknown_ids() -> void:
	assert_false(SoundBank.has(&"not_a_cue"))
	assert_true(SoundBank.has(&"swing"))

func test_every_cue_sounds_distinct() -> void:
	var ids := SoundBank.ids()
	for i in ids.size():
		for j in range(i + 1, ids.size()):
			assert_ne(
				SoundBank.cue(ids[i]).data,
				SoundBank.cue(ids[j]).data,
				"cues %s and %s overlap" % [ids[i], ids[j]]
			)

func test_unknown_cue_falls_back_to_silence() -> void:
	var stream := SoundBank.cue(&"missing")
	assert_not_null(stream)
	assert_gt(stream.data.size(), 0)
	assert_eq(stream.data.size() % 2, 0)

