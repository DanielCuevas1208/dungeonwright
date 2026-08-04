extends GutTest
## Waveform synthesis: deterministic, bounded, and correctly packaged.

func test_note_frequency_matches_twelve_tone() -> void:
	assert_almost_eq(Waveform.note_frequency(69), 440.0, 0.001)
	assert_almost_eq(Waveform.note_frequency(81), 880.0, 0.001)
	assert_almost_eq(Waveform.note_frequency(57), 220.0, 0.001)

func test_sine_length_matches_duration() -> void:
	assert_eq(Waveform.sine(440.0, 0.5, 22050).size(), 11025)
	assert_eq(Waveform.sine(440.0, 0.01, 1000).size(), 10)

func test_sine_starts_at_zero() -> void:
	assert_eq(Waveform.sine(440.0, 0.01, 1000)[0], 0.0)

func test_sine_is_deterministic() -> void:
	var a := Waveform.sine(440.0, 0.25, 8000)
	var b := Waveform.sine(440.0, 0.25, 8000)
	assert_eq(a, b)

func test_sine_stays_in_range() -> void:
	var samples := Waveform.sine(440.0, 0.5, 8000)
	assert_lt(_max_abs(samples), 1.0001)

func test_square_is_binary() -> void:
	var samples := Waveform.tone(440.0, 0.02, 1000, &"square")
	for value in samples:
		assert_true(value == 1.0 or value == -1.0)

func test_sweep_is_deterministic() -> void:
	var a := Waveform.sweep(800.0, 200.0, 0.2, 8000)
	var b := Waveform.sweep(800.0, 200.0, 0.2, 8000)
	assert_eq(a, b)
	assert_eq(a.size(), 1600)

func test_noise_is_deterministic_per_seed() -> void:
	var a := Waveform.noise(0.1, 1000, 7)
	var b := Waveform.noise(0.1, 1000, 7)
	var c := Waveform.noise(0.1, 1000, 8)
	assert_eq(a, b)
	assert_ne(a, c)

func test_noise_stays_in_range() -> void:
	var samples := Waveform.noise(0.2, 1000)
	assert_lt(_max_abs(samples), 1.0001)

func test_envelope_fades_the_edges() -> void:
	var ones := PackedFloat32Array()
	ones.resize(20)
	for i in 20:
		ones[i] = 1.0
	var shaped := Waveform.envelope(ones, 0.01, 0.01, 1000)
	assert_eq(shaped[0], 0.0)
	assert_almost_eq(shaped[10], 1.0, 0.0001)
	assert_almost_eq(shaped[19], 0.1, 0.0001)

func test_envelope_of_empty_is_empty() -> void:
	var empty := PackedFloat32Array()
	assert_eq(Waveform.envelope(empty, 0.1, 0.1, 1000), empty)

func test_scale_multiplies_each_sample() -> void:
	var samples := PackedFloat32Array([1.0, -1.0, 0.5, 0.0])
	var scaled := Waveform.scale(samples, 0.5)
	assert_eq(scaled, PackedFloat32Array([0.5, -0.5, 0.25, 0.0]))

func test_mix_sums_and_clamps() -> void:
	var a := PackedFloat32Array([0.5, 0.9, 0.0])
	var b := PackedFloat32Array([0.25, 0.9, 0.0])
	assert_eq(Waveform.mix(a, b), PackedFloat32Array([0.75, 1.0, 0.0]))

func test_mix_pads_shorter_buffer() -> void:
	var a := PackedFloat32Array([0.5, 0.5])
	var b := PackedFloat32Array([0.5])
	assert_eq(Waveform.mix(a, b), PackedFloat32Array([1.0, 0.5]))

func test_append_joins_end_to_end() -> void:
	var a := PackedFloat32Array([1.0, 2.0])
	var b := PackedFloat32Array([3.0])
	assert_eq(Waveform.append(a, b), PackedFloat32Array([1.0, 2.0, 3.0]))

func test_concat_joins_many_parts() -> void:
	var parts := [
		PackedFloat32Array([1.0]),
		PackedFloat32Array([2.0, 2.0]),
		PackedFloat32Array([3.0]),
	]
	assert_eq(Waveform.concat(parts), PackedFloat32Array([1.0, 2.0, 2.0, 3.0]))

func test_overlay_places_the_source() -> void:
	var target := PackedFloat32Array([0.0, 0.0, 0.0, 0.0])
	var source := PackedFloat32Array([1.0, 1.0])
	assert_eq(Waveform.overlay(target, source, 2, 1.0), PackedFloat32Array([0.0, 0.0, 1.0, 1.0]))

func test_overlay_clamps_the_sum() -> void:
	var target := PackedFloat32Array([0.8])
	var source := PackedFloat32Array([0.8])
	assert_eq(Waveform.overlay(target, source, 0, 1.0), PackedFloat32Array([1.0]))

func test_silence_has_the_right_length() -> void:
	assert_eq(Waveform.silence(0.5, 1000).size(), 500)
	var silent := Waveform.silence(0.1, 1000)
	assert_eq(_max_abs(silent), 0.0)

func test_pack_wav_writes_16_bit_mono() -> void:
	var samples := PackedFloat32Array([0.0, 0.5, -0.5, 1.0])
	var stream := Waveform.pack_wav(samples, 8000, false)
	assert_eq(stream.format, AudioStreamWAV.FORMAT_16_BITS)
	assert_eq(stream.mix_rate, 8000)
	assert_false(stream.stereo)
	assert_eq(stream.data.size(), 8)
	assert_eq(stream.loop_mode, AudioStreamWAV.LOOP_DISABLED)
	assert_eq(stream.data[0], 0)
	assert_eq(stream.data[1], 0)
	assert_eq(stream.data[2], 0)
	assert_eq(stream.data[3], 64)
	assert_eq(stream.data[4], 0)
	assert_eq(stream.data[5], 192)
	assert_eq(stream.data[6], 255)
	assert_eq(stream.data[7], 127)

func test_pack_wav_sets_loop_bounds() -> void:
	var samples := Waveform.silence(0.1, 1000)
	var stream := Waveform.pack_wav(samples, 1000, true)
	assert_eq(stream.loop_mode, AudioStreamWAV.LOOP_FORWARD)
	assert_eq(stream.loop_begin, 0)
	assert_eq(stream.loop_end, 100)

func _max_abs(p_samples: PackedFloat32Array) -> float:
	var peak := 0.0
	for value in p_samples:
		peak = maxf(peak, absf(value))
	return peak

