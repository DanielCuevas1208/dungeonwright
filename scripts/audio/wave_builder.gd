class_name WaveBuilder
extends RefCounted
## Builds PCM sample buffers from simple synthesis primitives.
##
## All functions are pure data. They take numbers and return float
## sample buffers. The same inputs always produce the same output, so
## the test suite can assert exact results. The hub node converts these
## buffers into playable streams at run time.

const DEFAULT_SAMPLE_RATE := 22050
const PEAK := 0.9

## The length of a buffer in seconds at the given sample rate.
static func duration(p_buffer: PackedFloat32Array, p_sample_rate: int = DEFAULT_SAMPLE_RATE) -> float:
	return float(p_buffer.size()) / float(p_sample_rate)

## Creates a silent buffer of the given length in seconds.
## A zero or negative length returns an empty buffer.
static func silent(p_seconds: float, p_sample_rate: int = DEFAULT_SAMPLE_RATE) -> PackedFloat32Array:
	var count := int(round(p_seconds * p_sample_rate))
	var buffer := PackedFloat32Array()
	if count > 0:
		buffer.resize(count)
	return buffer

## A sine tone with a linear attack and release envelope.
static func tone(
	p_frequency: float,
	p_seconds: float,
	p_volume: float = 0.5,
	p_attack: float = 0.01,
	p_release: float = 0.1,
	p_sample_rate: int = DEFAULT_SAMPLE_RATE
) -> PackedFloat32Array:
	var buffer := silent(p_seconds, p_sample_rate)
	var attack_samples := maxi(1, int(round(p_attack * p_sample_rate)))
	var release_samples := maxi(1, int(round(p_release * p_sample_rate)))
	var phase := 0.0
	var step := TAU * p_frequency / float(p_sample_rate)
	for i in buffer.size():
		var envelope := 1.0
		if i < attack_samples:
			envelope = float(i) / float(attack_samples)
		elif i >= buffer.size() - release_samples:
			var release_index := buffer.size() - 1 - i
			envelope = maxf(0.0, float(release_index) / float(release_samples))
		buffer[i] = sin(phase) * p_volume * envelope
		phase += step
	return buffer

## A sine tone whose frequency slides from start to end.
static func sweep(
	p_start: float,
	p_end: float,
	p_seconds: float,
	p_volume: float = 0.5,
	p_attack: float = 0.01,
	p_release: float = 0.1,
	p_sample_rate: int = DEFAULT_SAMPLE_RATE
) -> PackedFloat32Array:
	var buffer := silent(p_seconds, p_sample_rate)
	var attack_samples := maxi(1, int(round(p_attack * p_sample_rate)))
	var release_samples := maxi(1, int(round(p_release * p_sample_rate)))
	var phase := 0.0
	for i in buffer.size():
		var ratio := float(i) / float(buffer.size() - 1) if buffer.size() > 1 else 0.0
		var frequency := lerpf(p_start, p_end, ratio)
		var envelope := 1.0
		if i < attack_samples:
			envelope = float(i) / float(attack_samples)
		elif i >= buffer.size() - release_samples:
			var release_index := buffer.size() - 1 - i
			envelope = maxf(0.0, float(release_index) / float(release_samples))
		buffer[i] = sin(phase) * p_volume * envelope
		phase += TAU * frequency / float(p_sample_rate)
	return buffer

## A deterministic white-noise burst.
## The same seed always returns the same noise.
static func noise(
	p_seed: int,
	p_seconds: float,
	p_volume: float = 0.5,
	p_sample_rate: int = DEFAULT_SAMPLE_RATE
) -> PackedFloat32Array:
	var rng := SeededRng.new(p_seed)
	var buffer := silent(p_seconds, p_sample_rate)
	for i in buffer.size():
		buffer[i] = (rng.next_float() * 2.0 - 1.0) * p_volume
	return buffer

## Mixes two buffers together. The result has the length of the longer
## input, and every sample stays within a safe peak.
static func mix(
	p_a: PackedFloat32Array,
	p_b: PackedFloat32Array,
	p_gain_b: float = 1.0
) -> PackedFloat32Array:
	var size := maxi(p_a.size(), p_b.size())
	var out := PackedFloat32Array()
	out.resize(size)
	for i in size:
		var sample_a := p_a[i] if i < p_a.size() else 0.0
		var sample_b := p_b[i] if i < p_b.size() else 0.0
		out[i] = clampf(sample_a + sample_b * p_gain_b, -PEAK, PEAK)
	return out

## Concatenates two buffers into one longer buffer.
static func append(p_a: PackedFloat32Array, p_b: PackedFloat32Array) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(p_a.size() + p_b.size())
	for i in p_a.size():
		out[i] = p_a[i]
	for i in p_b.size():
		out[p_a.size() + i] = p_b[i]
	return out

## The absolute peak amplitude of the buffer.
static func peak(p_buffer: PackedFloat32Array) -> float:
	var value := 0.0
	for sample in p_buffer:
		value = maxf(value, absf(sample))
	return value

## A copy of the buffer scaled to the given peak amplitude.
static func scaled(p_buffer: PackedFloat32Array, p_peak: float = PEAK) -> PackedFloat32Array:
	var current := peak(p_buffer)
	if current <= 0.0:
		return p_buffer.duplicate()
	var factor := p_peak / current
	var out := PackedFloat32Array()
	out.resize(p_buffer.size())
	for i in p_buffer.size():
		out[i] = p_buffer[i] * factor
	return out

## Encodes a mono buffer as 16-bit little-endian PCM bytes.
static func to_bytes(p_buffer: PackedFloat32Array) -> PackedByteArray:
	var bytes := PackedByteArray()
	bytes.resize(p_buffer.size() * 2)
	for i in p_buffer.size():
		var sample := clampi(int(round(p_buffer[i] * 32767.0)), -32768, 32767)
		bytes[i * 2] = sample & 0xFF
		bytes[i * 2 + 1] = (sample >> 8) & 0xFF
	return bytes

## Decodes 16-bit little-endian PCM bytes back to floats in [-1, 1].
static func from_bytes(p_bytes: PackedByteArray) -> PackedFloat32Array:
	var buffer := PackedFloat32Array()
	buffer.resize(p_bytes.size() / 2)
	for i in buffer.size():
		var sample := p_bytes[i * 2] | (p_bytes[i * 2 + 1] << 8)
		if sample >= 0x8000:
			sample -= 0x10000
		buffer[i] = float(sample) / 32768.0
	return buffer

## Encodes a mono buffer as 16-bit stereo interleaved PCM bytes.
static func to_stereo_bytes(p_buffer: PackedFloat32Array) -> PackedByteArray:
	var bytes := PackedByteArray()
	bytes.resize(p_buffer.size() * 4)
	for i in p_buffer.size():
		var sample := clampi(int(round(p_buffer[i] * 32767.0)), -32768, 32767)
		var low := sample & 0xFF
		var high := (sample >> 8) & 0xFF
		var base := i * 4
		bytes[base] = low
		bytes[base + 1] = high
		bytes[base + 2] = low
		bytes[base + 3] = high
	return bytes

## Builds a mono AudioStreamWAV from a buffer.
static func to_stream(p_buffer: PackedFloat32Array, p_sample_rate: int = DEFAULT_SAMPLE_RATE) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = p_sample_rate
	stream.stereo = false
	stream.data = to_bytes(p_buffer)
	return stream

## Builds a stereo AudioStreamWAV from a mono buffer.
## The hub uses this for the music bed.
static func to_stereo_stream(p_buffer: PackedFloat32Array, p_sample_rate: int = DEFAULT_SAMPLE_RATE) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = p_sample_rate
	stream.stereo = true
	stream.data = to_stereo_bytes(p_buffer)
	return stream
