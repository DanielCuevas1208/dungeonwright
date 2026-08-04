class_name Waveform
extends RefCounted
## Pure sample synthesis used by the sound bank and the music themes.
##
## Every function returns a PackedFloat32Array of samples in the range
## -1.0 to 1.0. The functions take only explicit inputs, so the output
## is deterministic and unit-testable.

const DEFAULT_MIX_RATE := 22050

## The frequency in hertz for a MIDI note number. Note 69 is A4 at 440 Hz.
static func note_frequency(p_midi: int) -> float:
	return 440.0 * pow(2.0, (float(p_midi) - 69.0) / 12.0)

## A tone of the given duration. The wave is one of
## sine, square, triangle, or saw.
static func tone(
	p_freq: float,
	p_duration: float,
	p_mix_rate: int = DEFAULT_MIX_RATE,
	p_wave: StringName = &"sine"
) -> PackedFloat32Array:
	var count := maxi(1, roundi(p_duration * p_mix_rate))
	var out := PackedFloat32Array()
	out.resize(count)
	var phase := 0.0
	for i in count:
		out[i] = _oscillate(fposmod(phase, 1.0), p_wave)
		phase += p_freq / float(p_mix_rate)
	return out

## A sine tone. Kept as a shorthand for the common case.
static func sine(p_freq: float, p_duration: float, p_mix_rate: int = DEFAULT_MIX_RATE) -> PackedFloat32Array:
	return tone(p_freq, p_duration, p_mix_rate, &"sine")

## A tone that glides from p_start_freq to p_end_freq.
static func sweep(
	p_start_freq: float,
	p_end_freq: float,
	p_duration: float,
	p_mix_rate: int = DEFAULT_MIX_RATE,
	p_wave: StringName = &"sine"
) -> PackedFloat32Array:
	var count := maxi(1, roundi(p_duration * p_mix_rate))
	var out := PackedFloat32Array()
	out.resize(count)
	var phase := 0.0
	var freq := p_start_freq
	var step := (p_end_freq - p_start_freq) / float(count)
	for i in count:
		out[i] = _oscillate(fposmod(phase, 1.0), p_wave)
		phase += freq / float(p_mix_rate)
		freq += step
	return out

## White noise driven by a fixed LCG, so every burst is reproducible.
static func noise(
	p_duration: float,
	p_mix_rate: int = DEFAULT_MIX_RATE,
	p_seed: int = 12345
) -> PackedFloat32Array:
	var count := maxi(1, roundi(p_duration * p_mix_rate))
	var out := PackedFloat32Array()
	out.resize(count)
	var state := p_seed & 0xFFFFFFFF
	for i in count:
		state = (state * 1664525 + 1013904223) & 0xFFFFFFFF
		out[i] = float(state >> 8) / 16777215.0 * 2.0 - 1.0
	return out

## Applies a linear attack and release so tones start and end softly.
static func envelope(
	p_samples: PackedFloat32Array,
	p_attack: float,
	p_release: float,
	p_mix_rate: int = DEFAULT_MIX_RATE
) -> PackedFloat32Array:
	if p_samples.is_empty():
		return p_samples
	var count := p_samples.size()
	var attack_samples := maxi(0, roundi(p_attack * p_mix_rate))
	var release_samples := maxi(0, roundi(p_release * p_mix_rate))
	var out := p_samples.duplicate()
	for i in count:
		var gain := 1.0
		if attack_samples > 0 and i < attack_samples:
			gain = minf(gain, float(i) / float(attack_samples))
		var release_start := count - release_samples
		if release_samples > 0 and i >= release_start:
			gain = minf(gain, float(count - i) / float(release_samples))
		out[i] = out[i] * gain
	return out

## Returns a copy of the samples scaled by p_gain.
static func scale(p_samples: PackedFloat32Array, p_gain: float) -> PackedFloat32Array:
	if p_gain == 1.0:
		return p_samples
	var out := p_samples.duplicate()
	for i in out.size():
		out[i] = out[i] * p_gain
	return out

## Sums two buffers sample by sample, clamped to the audio range.
static func mix(p_a: PackedFloat32Array, p_b: PackedFloat32Array) -> PackedFloat32Array:
	var size := maxi(p_a.size(), p_b.size())
	var out := PackedFloat32Array()
	out.resize(size)
	for i in size:
		var value := 0.0
		if i < p_a.size():
			value += p_a[i]
		if i < p_b.size():
			value += p_b[i]
		out[i] = clampf(value, -1.0, 1.0)
	return out

## Copies p_source into a copy of p_target starting at p_offset.
## The source is scaled by p_gain before it is added.
static func overlay(
	p_target: PackedFloat32Array,
	p_source: PackedFloat32Array,
	p_offset: int,
	p_gain: float = 1.0
) -> PackedFloat32Array:
	var out := p_target.duplicate()
	for i in p_source.size():
		var index := p_offset + i
		if index < 0 or index >= out.size():
			continue
		out[index] = clampf(out[index] + p_source[i] * p_gain, -1.0, 1.0)
	return out

## Returns the two buffers joined end to end.
static func append(p_a: PackedFloat32Array, p_b: PackedFloat32Array) -> PackedFloat32Array:
	var out := p_a.duplicate()
	out.append_array(p_b)
	return out

## Joins every part in order into one buffer.
static func concat(p_parts: Array) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	for part in p_parts:
		out.append_array(part)
	return out

## A buffer of silent samples of the given duration.
static func silence(p_duration: float, p_mix_rate: int = DEFAULT_MIX_RATE) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(maxi(1, roundi(p_duration * p_mix_rate)))
	return out

## Wraps samples into a 16-bit mono stream the engine can play.
static func pack_wav(
	p_samples: PackedFloat32Array,
	p_mix_rate: int = DEFAULT_MIX_RATE,
	p_loop: bool = false
) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = p_mix_rate
	stream.stereo = false
	var count := p_samples.size()
	var data := PackedByteArray()
	data.resize(count * 2)
	for i in count:
		var sample := clampi(roundi(p_samples[i] * 32767.0), -32768, 32767)
		var bits := sample & 0xFFFF
		data[i * 2] = bits & 0xFF
		data[i * 2 + 1] = (bits >> 8) & 0xFF
	stream.data = data
	if p_loop and count > 0:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = count
	return stream

static func _oscillate(p_phase: float, p_wave: StringName) -> float:
	match p_wave:
		&"square":
			return 1.0 if p_phase < 0.5 else -1.0
		&"triangle":
			return 4.0 * absf(p_phase - 0.5) - 1.0
		&"saw":
			return 2.0 * p_phase - 1.0
		_:
			return sin(TAU * p_phase)
