class_name MusicBox
extends RefCounted
## Generates a looping ambient music bed for a biome.
##
## The bed has a low drone and a set of soft notes from a pentatonic
## scale. The generator is pure data and deterministic. The same biome
## and seed always produce the same loop, so a run can replay with its
## exact audio.

const LOOP_SECONDS := 8.0

## Semitone offsets of a pentatonic scale within one octave.
const SCALE := [0, 2, 4, 7, 9]

## The length of the generated loop in seconds.
static func loop_seconds() -> float:
	return LOOP_SECONDS

## A fixed base frequency for each biome.
## Plain constants keep the output stable across platforms.
static func base_frequency(p_biome_id: StringName) -> float:
	match p_biome_id:
		&"crypt":
			return 55.0
		&"drowned_forest":
			return 49.0
		&"ember_stronghold":
			return 58.27
		_:
			return 55.0

## A fixed seed offset for each biome.
static func _biome_constant(p_biome_id: StringName) -> int:
	match p_biome_id:
		&"crypt":
			return 0xC7E9
		&"drowned_forest":
			return 0xD9E8
		&"ember_stronghold":
			return 0xE5E9
		_:
			return 0x5150

## Returns the ambient loop for a biome and run seed.
static func buffer(p_biome_id: StringName, p_seed: int) -> PackedFloat32Array:
	var rng := SeededRng.new(p_seed ^ _biome_constant(p_biome_id))
	var base := base_frequency(p_biome_id)
	var total := WaveBuilder.silent(LOOP_SECONDS)

	var drone := WaveBuilder.tone(base, LOOP_SECONDS, 0.1, 0.8, 0.8)
	drone = WaveBuilder.mix(drone, WaveBuilder.tone(base * 1.01, LOOP_SECONDS, 0.08, 0.8, 0.8))
	drone = WaveBuilder.mix(drone, WaveBuilder.tone(base * 2.0, LOOP_SECONDS, 0.05, 0.8, 0.8))
	total = WaveBuilder.mix(total, drone)

	var note_count := rng.next_int_range(5, 8)
	for i in note_count:
		var scale_index := rng.next_int(SCALE.size())
		var octave := rng.next_int_range(2, 4)
		var semitones: int = SCALE[scale_index] + octave * 12
		var frequency := base * pow(2.0, float(semitones) / 12.0)
		var duration := rng.next_float_range(0.5, 1.1)
		var start_time := rng.next_float_range(0.0, LOOP_SECONDS - duration)
		var volume := rng.next_float_range(0.05, 0.11)
		var note := WaveBuilder.tone(frequency, duration, volume, 0.08, 0.4)
		var start_sample := int(round(start_time * WaveBuilder.DEFAULT_SAMPLE_RATE))
		total = _place(total, note, start_sample)

	_crossfade_edges(total)
	return WaveBuilder.scaled(total, 0.9)

## Adds a layer into a target buffer starting at a sample offset.
static func _place(
	p_target: PackedFloat32Array,
	p_layer: PackedFloat32Array,
	p_at: int
) -> PackedFloat32Array:
	for i in p_layer.size():
		var index := p_at + i
		if index >= p_target.size():
			break
		p_target[index] = clampf(p_target[index] + p_layer[i], -WaveBuilder.PEAK, WaveBuilder.PEAK)
	return p_target

## Fades the loop edges so the loop point does not click.
static func _crossfade_edges(p_buffer: PackedFloat32Array) -> void:
	var fade := int(round(0.05 * WaveBuilder.DEFAULT_SAMPLE_RATE))
	for i in fade:
		var envelope := float(i) / float(fade)
		p_buffer[i] *= envelope
		p_buffer[p_buffer.size() - 1 - i] *= envelope
