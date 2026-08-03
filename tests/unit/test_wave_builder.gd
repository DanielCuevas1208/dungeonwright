extends GutTest
## Wave synthesis primitives: length, amplitude, and determinism.

func test_silent_length_matches_seconds() -> void:
	var buffer := WaveBuilder.silent(1.0)
	assert_eq(buffer.size(), WaveBuilder.DEFAULT_SAMPLE_RATE)
	assert_almost_eq(WaveBuilder.duration(buffer), 1.0, 0.001)

func test_silent_zero_length_is_empty() -> void:
	assert_eq(WaveBuilder.silent(0.0).size(), 0)
	assert_eq(WaveBuilder.silent(-0.5).size(), 0)

func test_tone_is_audible_and_bounded() -> void:
	var buffer := WaveBuilder.tone(440.0, 0.5, 0.5, 0.01, 0.1)
	assert_gt(WaveBuilder.peak(buffer), 0.1)
	assert_lte(WaveBuilder.peak(buffer), WaveBuilder.PEAK)

func test_tone_attacks_and_releases_softly() -> void:
	var buffer := WaveBuilder.tone(440.0, 0.5, 0.5, 0.01, 0.1)
	assert_lt(absf(buffer[0]), 0.05)
	assert_lt(absf(buffer[buffer.size() - 1]), 0.05)

func test_sweep_differs_from_steady_tone() -> void:
	var sweep := WaveBuilder.sweep(220.0, 440.0, 0.4, 0.5, 0.01, 0.1)
	var steady := WaveBuilder.tone(220.0, 0.4, 0.5, 0.01, 0.1)
	var differences := 0
	for i in sweep.size():
		if absf(sweep[i] - steady[i]) > 0.001:
			differences += 1
	assert_gt(differences, 100)

func test_noise_is_deterministic() -> void:
	var first := WaveBuilder.noise(42, 0.2, 0.5)
	var second := WaveBuilder.noise(42, 0.2, 0.5)
	assert_eq(first, second)

func test_noise_differs_between_seeds() -> void:
	var first := WaveBuilder.noise(1, 0.2, 0.5)
	var second := WaveBuilder.noise(2, 0.2, 0.5)
	var differences := 0
	for i in first.size():
		if first[i] != second[i]:
			differences += 1
	assert_gt(differences, first.size() / 2)

func test_mix_keeps_longest_length() -> void:
	var short_buffer := WaveBuilder.silent(0.1)
	var long_buffer := WaveBuilder.silent(0.3)
	assert_eq(WaveBuilder.mix(short_buffer, long_buffer).size(), long_buffer.size())
	assert_eq(WaveBuilder.mix(long_buffer, short_buffer).size(), long_buffer.size())

func test_mix_clamps_into_safe_peak() -> void:
	var loud_a := WaveBuilder.tone(220.0, 0.2, 0.8, 0.001, 0.001)
	var loud_b := WaveBuilder.tone(330.0, 0.2, 0.8, 0.001, 0.001)
	var mixed := WaveBuilder.mix(loud_a, loud_b)
	assert_lte(WaveBuilder.peak(mixed), WaveBuilder.PEAK)

func test_append_concatenates() -> void:
	var a := WaveBuilder.silent(0.1)
	var b := WaveBuilder.silent(0.2)
	var joined := WaveBuilder.append(a, b)
	assert_eq(joined.size(), a.size() + b.size())
	assert_almost_eq(WaveBuilder.duration(joined), 0.3, 0.001)

func test_scaled_reaches_requested_peak() -> void:
	var buffer := WaveBuilder.scaled(WaveBuilder.tone(440.0, 0.4, 0.3, 0.001, 0.001), 0.7)
	assert_almost_eq(WaveBuilder.peak(buffer), 0.7, 0.01)

func test_bytes_round_trip() -> void:
	var buffer := WaveBuilder.tone(440.0, 0.1, 0.5, 0.01, 0.05)
	var bytes := WaveBuilder.to_bytes(buffer)
	assert_eq(bytes.size(), buffer.size() * 2)
	var decoded := WaveBuilder.from_bytes(bytes)
	assert_eq(decoded.size(), buffer.size())
	for i in buffer.size():
		assert_almost_eq(decoded[i], buffer[i], 0.001, "sample %d" % i)

func test_stereo_bytes_interleave() -> void:
	var buffer := WaveBuilder.silent(0.01)
	buffer[0] = 0.5
	var bytes := WaveBuilder.to_stereo_bytes(buffer)
	assert_eq(bytes.size(), buffer.size() * 4)
	var left := bytes[0] | (bytes[1] << 8)
	var right := bytes[2] | (bytes[3] << 8)
	assert_eq(left, right)

func test_stream_metadata_is_mono_16_bit() -> void:
	var buffer := WaveBuilder.tone(440.0, 0.1, 0.5)
	var stream := WaveBuilder.to_stream(buffer)
	assert_eq(stream.format, AudioStreamWAV.FORMAT_16_BITS)
	assert_eq(stream.mix_rate, WaveBuilder.DEFAULT_SAMPLE_RATE)
	assert_false(stream.stereo)
	assert_eq(stream.data.size(), buffer.size() * 2)

func test_stereo_stream_reports_stereo() -> void:
	var buffer := WaveBuilder.tone(440.0, 0.1, 0.5)
	var stream := WaveBuilder.to_stereo_stream(buffer)
	assert_true(stream.stereo)
	assert_eq(stream.data.size(), buffer.size() * 4)
