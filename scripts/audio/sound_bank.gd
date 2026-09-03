class_name SoundBank
extends RefCounted
## Builds every sound effect as a generated stream.
##
## Cues are short, layered tones and noise bursts. They are built once
## and cached, so the game never loads audio files. The cue list is
## stable and the smoke test guards it against content drift.

const MIX_RATE := 22050

const CUES: Array[StringName] = [
	&"swing",
	&"hit",
	&"hurt",
	&"death",
	&"shoot",
	&"impact",
	&"throw",
	&"explosion",
	&"roar",
	&"pickup_coin",
	&"pickup_shard",
	&"pickup_potion",
	&"pickup_bomb",
	&"pickup_key",
	&"pickup_emblem",
	&"pickup_aegis",
	&"shrine_activate",
	&"pickup_relic",
	&"door_open",
	&"descend",
	&"victory",
	&"defeat",
]

static var _cache: Dictionary = {}

## Returns every cue id in a stable order.
static func ids() -> Array[StringName]:
	return CUES.duplicate()

## True when the id names a known cue.
static func has(p_id: StringName) -> bool:
	return CUES.has(p_id)

## Returns the stream for a cue, building it on first use.
static func cue(p_id: StringName) -> AudioStreamWAV:
	if _cache.has(p_id):
		return _cache[p_id]
	var stream := _build(p_id)
	_cache[p_id] = stream
	return stream

static func _build(p_id: StringName) -> AudioStreamWAV:
	match p_id:
		&"swing":
			return _pack(_swing())
		&"hit":
			return _pack(_hit())
		&"hurt":
			return _pack(_hurt())
		&"death":
			return _pack(_death())
		&"shoot":
			return _pack(_shoot())
		&"impact":
			return _pack(_impact())
		&"throw":
			return _pack(_throw())
		&"explosion":
			return _pack(_explosion())
		&"roar":
			return _pack(_roar())
		&"pickup_coin":
			return _pack(_pickup_coin())
		&"pickup_shard":
			return _pack(_pickup_shard())
		&"pickup_potion":
			return _pack(_pickup_potion())
		&"pickup_bomb":
			return _pack(_pickup_bomb())
		&"pickup_key":
			return _pack(_pickup_key())
		&"pickup_emblem":
			return _pack(_pickup_emblem())
		&"pickup_aegis":
			return _pack(_pickup_aegis())
		&"shrine_activate":
			return _pack(_shrine_activate())
		&"pickup_relic":
			return _pack(_pickup_relic())
		&"door_open":
			return _pack(_door_open())
		&"descend":
			return _pack(_descend())
		&"victory":
			return _pack(_victory())
		&"defeat":
			return _pack(_defeat())
		_:
			return _pack(Waveform.silence(0.05, MIX_RATE))

static func _pack(p_samples: PackedFloat32Array) -> AudioStreamWAV:
	return Waveform.pack_wav(p_samples, MIX_RATE, false)

## A quick whoosh: filtered noise over a downward glide.
static func _swing() -> PackedFloat32Array:
	var whoosh := Waveform.envelope(Waveform.noise(0.16, MIX_RATE), 0.01, 0.14, MIX_RATE)
	var glide := Waveform.envelope(Waveform.sweep(850, 220, 0.16, MIX_RATE), 0.01, 0.14, MIX_RATE)
	return Waveform.mix(Waveform.scale(whoosh, 0.45), Waveform.scale(glide, 0.5))

## A short blip when a sword lands on a monster.
static func _hit() -> PackedFloat32Array:
	var blip := Waveform.envelope(Waveform.sweep(320, 170, 0.12, MIX_RATE), 0.005, 0.1, MIX_RATE)
	var crack := Waveform.envelope(Waveform.noise(0.08, MIX_RATE), 0.003, 0.06, MIX_RATE)
	return Waveform.mix(Waveform.scale(blip, 0.55), Waveform.scale(crack, 0.3))

## A low growl when the hero takes damage.
static func _hurt() -> PackedFloat32Array:
	var low := Waveform.envelope(Waveform.sweep(190, 90, 0.25, MIX_RATE), 0.005, 0.2, MIX_RATE)
	var grit := Waveform.envelope(Waveform.noise(0.25, MIX_RATE), 0.005, 0.2, MIX_RATE)
	return Waveform.mix(Waveform.scale(low, 0.6), Waveform.scale(grit, 0.4))

## A long falling tone when a monster is slain.
static func _death() -> PackedFloat32Array:
	var tail := Waveform.envelope(Waveform.sweep(420, 55, 0.45, MIX_RATE), 0.01, 0.4, MIX_RATE)
	var grit := Waveform.envelope(Waveform.noise(0.3, MIX_RATE), 0.005, 0.25, MIX_RATE)
	return Waveform.mix(Waveform.scale(tail, 0.55), Waveform.scale(grit, 0.3))

## A thin square blip as an archer fires.
static func _shoot() -> PackedFloat32Array:
	var pluck := Waveform.envelope(
		Waveform.sweep(950, 600, 0.1, MIX_RATE, &"square"), 0.004, 0.08, MIX_RATE
	)
	return Waveform.scale(pluck, 0.4)

## A soft knock where a bolt lands.
static func _impact() -> PackedFloat32Array:
	var thud := Waveform.envelope(Waveform.sweep(160, 70, 0.16, MIX_RATE), 0.004, 0.14, MIX_RATE)
	var dust := Waveform.envelope(Waveform.noise(0.12, MIX_RATE), 0.003, 0.1, MIX_RATE)
	return Waveform.mix(Waveform.scale(thud, 0.6), Waveform.scale(dust, 0.4))

## A rising flutter as a bomb leaves the hand.
static func _throw() -> PackedFloat32Array:
	var up := Waveform.envelope(Waveform.sweep(250, 700, 0.2, MIX_RATE), 0.01, 0.18, MIX_RATE)
	return Waveform.scale(up, 0.5)

## A deep blast: noise with a falling rumble underneath.
static func _explosion() -> PackedFloat32Array:
	var burst := Waveform.envelope(Waveform.noise(0.6, MIX_RATE), 0.005, 0.55, MIX_RATE)
	var rumble := Waveform.envelope(Waveform.sweep(160, 40, 0.6, MIX_RATE), 0.005, 0.55, MIX_RATE)
	return Waveform.mix(Waveform.scale(burst, 0.8), Waveform.scale(rumble, 0.8))

## A low roar when the warden enrages.
static func _roar() -> PackedFloat32Array:
	var growl := Waveform.envelope(
		Waveform.sweep(200, 70, 0.7, MIX_RATE, &"saw"), 0.02, 0.6, MIX_RATE
	)
	var grit := Waveform.envelope(Waveform.noise(0.65, MIX_RATE), 0.01, 0.55, MIX_RATE)
	return Waveform.mix(Waveform.scale(growl, 0.6), Waveform.scale(grit, 0.35))

## Two bright dings for a coin.
static func _pickup_coin() -> PackedFloat32Array:
	var first := Waveform.envelope(Waveform.sine(1320, 0.1, MIX_RATE), 0.003, 0.09, MIX_RATE)
	var second := Waveform.envelope(Waveform.sine(1760, 0.14, MIX_RATE), 0.003, 0.12, MIX_RATE)
	return Waveform.scale(
		Waveform.concat([first, Waveform.silence(0.02, MIX_RATE), second]), 0.4
	)

## A rising gliss for a shard.
static func _pickup_shard() -> PackedFloat32Array:
	var up := Waveform.envelope(Waveform.sweep(600, 1200, 0.28, MIX_RATE), 0.005, 0.24, MIX_RATE)
	var sparkle := Waveform.envelope(Waveform.sine(2400, 0.18, MIX_RATE), 0.005, 0.15, MIX_RATE)
	return Waveform.mix(Waveform.scale(up, 0.5), Waveform.scale(sparkle, 0.25))

## A warm two-tone blip for a potion.
static func _pickup_potion() -> PackedFloat32Array:
	var first := Waveform.envelope(Waveform.sine(494, 0.12, MIX_RATE), 0.005, 0.1, MIX_RATE)
	var second := Waveform.envelope(Waveform.sine(622, 0.18, MIX_RATE), 0.005, 0.16, MIX_RATE)
	return Waveform.scale(
		Waveform.concat([first, Waveform.silence(0.03, MIX_RATE), second]), 0.5
	)

## A firm low knock for a bomb pickup.
static func _pickup_bomb() -> PackedFloat32Array:
	var knock := Waveform.envelope(
		Waveform.sweep(320, 200, 0.12, MIX_RATE, &"square"), 0.004, 0.1, MIX_RATE
	)
	var rattle := Waveform.envelope(Waveform.noise(0.1, MIX_RATE), 0.003, 0.08, MIX_RATE)
	return Waveform.mix(Waveform.scale(knock, 0.5), Waveform.scale(rattle, 0.3))

## A short metallic clank for a key.
static func _pickup_key() -> PackedFloat32Array:
	var ring := Waveform.envelope(
		Waveform.sine(1200, 0.22, MIX_RATE), 0.003, 0.2, MIX_RATE
	)
	var overtone := Waveform.envelope(
		Waveform.sine(2400, 0.12, MIX_RATE), 0.003, 0.1, MIX_RATE
	)
	var click := Waveform.envelope(Waveform.noise(0.05, MIX_RATE), 0.002, 0.04, MIX_RATE)
	var body := Waveform.mix(Waveform.scale(ring, 0.4), Waveform.scale(overtone, 0.2))
	return Waveform.mix(body, Waveform.scale(click, 0.2))

## A bright power chime for a damage emblem.
static func _pickup_emblem() -> PackedFloat32Array:
	var up := Waveform.envelope(
		Waveform.sweep(440, 880, 0.3, MIX_RATE, &"square"), 0.005, 0.26, MIX_RATE
	)
	var sparkle := Waveform.envelope(Waveform.sine(1760, 0.2, MIX_RATE), 0.005, 0.17, MIX_RATE)
	return Waveform.mix(Waveform.scale(up, 0.4), Waveform.scale(sparkle, 0.25))

## A resonant, protective chime for an aegis pickup.
static func _pickup_aegis() -> PackedFloat32Array:
	var base := Waveform.envelope(
		Waveform.sine(330, 0.28, MIX_RATE), 0.005, 0.24, MIX_RATE
	)
	var chord := Waveform.envelope(
		Waveform.sine(494, 0.28, MIX_RATE), 0.005, 0.24, MIX_RATE
	)
	var shimmer := Waveform.envelope(
		Waveform.sine(988, 0.22, MIX_RATE), 0.003, 0.18, MIX_RATE
	)
	var resonance := Waveform.mix(Waveform.scale(base, 0.4), Waveform.scale(chord, 0.3))
	return Waveform.mix(resonance, Waveform.scale(shimmer, 0.25))

## A clear, resonant chord when a floor shrine grants its blessing.
static func _shrine_activate() -> PackedFloat32Array:
	var low := Waveform.envelope(Waveform.sine(262, 0.45, MIX_RATE), 0.01, 0.4, MIX_RATE)
	var high := Waveform.envelope(Waveform.sine(784, 0.32, MIX_RATE), 0.01, 0.28, MIX_RATE)
	var shimmer := Waveform.envelope(Waveform.sine(1568, 0.24, MIX_RATE), 0.005, 0.2, MIX_RATE)
	var chord := Waveform.mix(Waveform.scale(low, 0.45), Waveform.scale(high, 0.35))
	return Waveform.mix(chord, Waveform.scale(shimmer, 0.2))

## A rising fanfare for the warden's relic.
static func _pickup_relic() -> PackedFloat32Array:
	var steps: Array = []
	for midi in [392, 523, 659, 784]:
		var note := Waveform.envelope(Waveform.sine(midi, 0.2, MIX_RATE), 0.005, 0.18, MIX_RATE)
		steps.append(note)
		steps.append(Waveform.silence(0.03, MIX_RATE))
	return Waveform.scale(Waveform.concat(steps), 0.45)

## A low grind as a locked door swings open.
static func _door_open() -> PackedFloat32Array:
	var grind := Waveform.envelope(
		Waveform.sweep(120, 60, 0.5, MIX_RATE, &"saw"), 0.08, 0.4, MIX_RATE
	)
	var stone := Waveform.envelope(Waveform.noise(0.45, MIX_RATE), 0.06, 0.38, MIX_RATE)
	return Waveform.mix(Waveform.scale(grind, 0.5), Waveform.scale(stone, 0.35))

## Three falling notes when the hero descends.
static func _descend() -> PackedFloat32Array:
	var steps: Array = []
	for midi in [523, 392, 294]:
		var note := Waveform.envelope(Waveform.sine(midi, 0.2, MIX_RATE), 0.01, 0.18, MIX_RATE)
		steps.append(note)
		steps.append(Waveform.silence(0.02, MIX_RATE))
	return Waveform.scale(Waveform.concat(steps), 0.45)

## A rising arpeggio for victory.
static func _victory() -> PackedFloat32Array:
	var steps: Array = []
	for midi in [523, 659, 784, 1047]:
		var note := Waveform.envelope(Waveform.sine(midi, 0.22, MIX_RATE), 0.01, 0.2, MIX_RATE)
		steps.append(note)
		steps.append(Waveform.silence(0.04, MIX_RATE))
	return Waveform.scale(Waveform.concat(steps), 0.45)

## A slow falling line for defeat.
static func _defeat() -> PackedFloat32Array:
	var steps: Array = []
	for midi in [392, 330, 262, 196]:
		var note := Waveform.envelope(Waveform.sine(midi, 0.26, MIX_RATE), 0.01, 0.24, MIX_RATE)
		steps.append(note)
		steps.append(Waveform.silence(0.06, MIX_RATE))
	return Waveform.scale(Waveform.concat(steps), 0.45)
