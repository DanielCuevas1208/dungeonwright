class_name SoundKit
extends RefCounted
## Generates every named sound effect as a deterministic PCM buffer.
##
## The same effect id and seed always produce the same audio. Effects
## are short bursts built from tones, sweeps, and noise. The hub plays
## these buffers, so the project ships no audio files.

const SAMPLE_RATE := WaveBuilder.DEFAULT_SAMPLE_RATE

## Returns every known effect id in a stable order.
static func ids() -> Array[StringName]:
	return [
		&"hit", &"hurt", &"monster_die", &"pickup", &"key",
		&"door", &"victory", &"defeat", &"start",
	]

## True when the id names a known effect.
static func has(p_id: StringName) -> bool:
	return ids().has(p_id)

## Returns the PCM buffer for a named effect.
## An unknown id returns a short silent buffer.
static func buffer(p_id: StringName, p_seed: int = 0) -> PackedFloat32Array:
	var rng := SeededRng.new(p_seed ^ _id_constant(p_id))
	var jitter := 0.9 + rng.next_float() * 0.2
	match p_id:
		&"hit":
			return _hit(rng, jitter)
		&"hurt":
			return _hurt(jitter)
		&"monster_die":
			return _monster_die(rng, jitter)
		&"pickup":
			return _pickup(jitter)
		&"key":
			return _key(jitter)
		&"door":
			return _door(rng, jitter)
		&"victory":
			return _victory(jitter)
		&"defeat":
			return _defeat(jitter)
		&"start":
			return _start(jitter)
		_:
			return WaveBuilder.silent(0.05)

## The attack thud and metal tick on a landed blow.
static func _hit(p_rng: SeededRng, p_jitter: float) -> PackedFloat32Array:
	var body := WaveBuilder.sweep(220.0 * p_jitter, 90.0, 0.12, 0.5, 0.002, 0.08)
	var tick := WaveBuilder.noise(p_rng.next_int(99999), 0.06, 0.35)
	return WaveBuilder.scaled(WaveBuilder.mix(body, tick), 0.8)

## A short falling tone for damage taken.
static func _hurt(p_jitter: float) -> PackedFloat32Array:
	return WaveBuilder.scaled(
		WaveBuilder.sweep(320.0 * p_jitter, 130.0, 0.24, 0.5, 0.005, 0.1), 0.8
	)

## A burst of noise that falls away when a monster is defeated.
static func _monster_die(p_rng: SeededRng, p_jitter: float) -> PackedFloat32Array:
	var burst := WaveBuilder.noise(p_rng.next_int(99999), 0.1, 0.4)
	var fall := WaveBuilder.sweep(220.0 * p_jitter, 55.0, 0.32, 0.5, 0.005, 0.14)
	return WaveBuilder.scaled(WaveBuilder.append(burst, fall), 0.8)

## Two quick rising notes for coins and shards.
static func _pickup(p_jitter: float) -> PackedFloat32Array:
	var first := WaveBuilder.tone(660.0 * p_jitter, 0.06, 0.4, 0.004, 0.03)
	var second := WaveBuilder.tone(880.0 * p_jitter, 0.1, 0.4, 0.004, 0.05)
	return WaveBuilder.scaled(WaveBuilder.append(first, second), 0.8)

## A bright rising chime for a key.
static func _key(p_jitter: float) -> PackedFloat32Array:
	var slide := WaveBuilder.sweep(700.0 * p_jitter, 1100.0 * p_jitter, 0.16, 0.4, 0.004, 0.08)
	var bell := WaveBuilder.tone(1400.0 * p_jitter, 0.14, 0.2, 0.002, 0.1)
	return WaveBuilder.scaled(WaveBuilder.mix(slide, bell), 0.8)

## A low rumble and stone click when a door opens.
static func _door(p_rng: SeededRng, p_jitter: float) -> PackedFloat32Array:
	var rumble := WaveBuilder.noise(p_rng.next_int(99999), 0.12, 0.3)
	var grind := WaveBuilder.sweep(130.0 * p_jitter, 80.0, 0.22, 0.4, 0.01, 0.1)
	return WaveBuilder.scaled(WaveBuilder.mix(rumble, grind), 0.8)

## An ascending arpeggio for victory.
static func _victory(p_jitter: float) -> PackedFloat32Array:
	var notes := [523.0, 659.0, 784.0, 1047.0]
	var part := WaveBuilder.silent(0.0)
	for i in notes.size():
		part = WaveBuilder.append(part, WaveBuilder.tone(notes[i] * p_jitter, 0.14, 0.35, 0.004, 0.06))
	part = WaveBuilder.append(part, WaveBuilder.tone(1047.0 * p_jitter, 0.4, 0.3, 0.004, 0.18))
	return WaveBuilder.scaled(part, 0.8)

## A descending arpeggio for defeat.
static func _defeat(p_jitter: float) -> PackedFloat32Array:
	var notes := [392.0, 330.0, 262.0, 196.0]
	var part := WaveBuilder.silent(0.0)
	for i in notes.size():
		part = WaveBuilder.append(part, WaveBuilder.tone(notes[i] * p_jitter, 0.2, 0.35, 0.004, 0.1))
	return WaveBuilder.scaled(part, 0.8)

## A single bell tone when a run begins.
static func _start(p_jitter: float) -> PackedFloat32Array:
	var bell := WaveBuilder.tone(784.0 * p_jitter, 0.3, 0.4, 0.004, 0.16)
	var overtone := WaveBuilder.tone(1175.0 * p_jitter, 0.3, 0.15, 0.004, 0.16)
	return WaveBuilder.scaled(WaveBuilder.mix(bell, overtone), 0.8)

## A stable per-id constant so the jitter is deterministic.
static func _id_constant(p_id: StringName) -> int:
	match p_id:
		&"hit":
			return 0x11A0
		&"hurt":
			return 0x22B1
		&"monster_die":
			return 0x33C2
		&"pickup":
			return 0x44D3
		&"key":
			return 0x55E4
		&"door":
			return 0x66F5
		&"victory":
			return 0x7706
		&"defeat":
			return 0x8817
		&"start":
			return 0x9928
		_:
			return 0x5150
