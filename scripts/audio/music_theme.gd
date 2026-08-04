class_name MusicTheme
extends RefCounted
## Builds a looping ambient theme for each biome.
##
## A theme is a chord pad with a bass line and a soft arpeggio. The notes
## come from a fixed table per biome, so every theme is stable and has a
## distinct mood. The finished loop is cached, and the smoke test guards
## that every biome maps to a valid theme.

const MIX_RATE := 16000
const CHORD_DURATION := 2.0
const CHORD_COUNT := 4

static var _cache: Dictionary = {}

## Returns the looping stream for a theme id.
## Biome ids and the menu id all resolve to a theme.
static func theme(p_id: StringName) -> AudioStreamWAV:
	if _cache.has(p_id):
		return _cache[p_id]
	var samples := _build(p_id)
	var stream := Waveform.pack_wav(samples, MIX_RATE, true)
	_cache[p_id] = stream
	return stream

static func _build(p_id: StringName) -> PackedFloat32Array:
	var settings := _settings(p_id)
	var out := PackedFloat32Array()
	for chord in settings["chords"]:
		out.append_array(_chord_segment(settings, chord))
	return out

## Renders one chord: a sustained pad, a bass note, and an arpeggio.
static func _chord_segment(p_settings: Dictionary, p_chord: Array) -> PackedFloat32Array:
	var buf := Waveform.silence(CHORD_DURATION, MIX_RATE)
	var pad_gain := float(p_settings.get("pad_gain", 0.13))
	var bass_gain := float(p_settings.get("bass_gain", 0.3))
	var arp_gain := float(p_settings.get("arp_gain", 0.18))

	for midi in p_chord:
		var pad := Waveform.tone(Waveform.note_frequency(midi), CHORD_DURATION, MIX_RATE, &"sine")
		pad = Waveform.envelope(pad, 0.5, 0.9, MIX_RATE)
		buf = Waveform.overlay(buf, pad, 0, pad_gain)

	var bass_freq := Waveform.note_frequency(int(p_chord[0]) - 12)
	var bass := Waveform.tone(bass_freq, CHORD_DURATION, MIX_RATE, &"triangle")
	bass = Waveform.envelope(bass, 0.03, 0.7, MIX_RATE)
	buf = Waveform.overlay(buf, bass, 0, bass_gain)

	var arp_offset := roundi(0.05 * MIX_RATE)
	var arp_gap := roundi(0.16 * MIX_RATE)
	for i in p_chord.size():
		var note := Waveform.tone(
			Waveform.note_frequency(int(p_chord[i]) + 12), 0.5, MIX_RATE, &"triangle"
		)
		note = Waveform.envelope(note, 0.005, 0.4, MIX_RATE)
		buf = Waveform.overlay(buf, note, arp_offset + i * arp_gap, arp_gain)
	return buf

## The per-theme note and level table.
static func _settings(p_id: StringName) -> Dictionary:
	match p_id:
		&"menu":
			return {
				"chords": [[50, 54, 57], [45, 49, 52], [48, 52, 55], [43, 47, 50]],
				"pad_gain": 0.12,
				"bass_gain": 0.28,
				"arp_gain": 0.12,
			}
		&"crypt":
			return {
				"chords": [[57, 60, 64], [53, 57, 60], [48, 52, 55], [55, 59, 62]],
				"pad_gain": 0.13,
				"bass_gain": 0.3,
				"arp_gain": 0.16,
			}
		&"drowned_forest":
			return {
				"chords": [[52, 55, 59], [48, 52, 55], [55, 59, 62], [50, 54, 57]],
				"pad_gain": 0.12,
				"bass_gain": 0.28,
				"arp_gain": 0.18,
			}
		&"ember_stronghold":
			return {
				"chords": [[50, 53, 57], [46, 50, 53], [53, 57, 60], [45, 49, 52]],
				"pad_gain": 0.14,
				"bass_gain": 0.34,
				"arp_gain": 0.15,
			}
		&"frost_vault":
			return {
				"chords": [[55, 58, 62], [51, 55, 58], [46, 50, 53], [53, 57, 60]],
				"pad_gain": 0.11,
				"bass_gain": 0.26,
				"arp_gain": 0.2,
			}
		&"boss":
			return {
				"chords": [[40, 43, 46], [38, 41, 44], [40, 43, 46], [35, 38, 42]],
				"pad_gain": 0.15,
				"bass_gain": 0.36,
				"arp_gain": 0.24,
			}
		_:
			return _settings(&"menu")
