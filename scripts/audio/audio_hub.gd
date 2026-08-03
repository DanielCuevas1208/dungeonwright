class_name AudioHub
extends Node
## Plays generated sound effects and the ambient music bed.
##
## The hub owns AudioStreamPlayer nodes and turns PCM buffers from the
## pure generators into playable streams. It keeps a small cache so a
## repeated effect does not regenerate its audio. Mute stops all output.

signal muted_changed(muted: bool)

const SFX_PLAYER_COUNT := 8
const CACHE_LIMIT := 48

var _music_player: AudioStreamPlayer = null
var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_index := 0
var _muted := false
var _buffer_cache: Dictionary = {}

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	add_child(_music_player)
	for i in SFX_PLAYER_COUNT:
		var player := AudioStreamPlayer.new()
		player.volume_db = -6.0
		add_child(player)
		_sfx_players.append(player)

## True when the hub has built its players.
func is_ready() -> bool:
	return _music_player != null and not _sfx_players.is_empty()

## True when all audio output is muted.
func is_muted() -> bool:
	return _muted

## Plays a named sound effect. Returns false for unknown names.
func play_sfx(p_id: StringName, p_seed: int = 0) -> bool:
	if not SoundKit.has(p_id):
		return false
	if _muted:
		return true
	var stream := _cached_stream(p_id, p_seed)
	var player := _next_player()
	player.stream = stream
	player.play()
	return true

## Starts the biome music loop for a run seed.
func play_music(p_biome_id: StringName, p_seed: int) -> void:
	var buffer := MusicBox.buffer(p_biome_id, p_seed)
	var stream := WaveBuilder.to_stereo_stream(buffer)
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = buffer.size()
	_music_player.stream = stream
	if not _muted:
		_music_player.play()

## Silences or restores all audio output.
func set_muted(p_muted: bool) -> void:
	if _muted == p_muted:
		return
	_muted = p_muted
	if _muted:
		_music_player.stop()
	elif _music_player.stream != null:
		_music_player.play()
	muted_changed.emit(_muted)

## Flips the mute state and returns the new state.
func toggle_mute() -> bool:
	set_muted(not _muted)
	return _muted

func _next_player() -> AudioStreamPlayer:
	var player := _sfx_players[_sfx_index]
	_sfx_index = (_sfx_index + 1) % _sfx_players.size()
	return player

func _cached_stream(p_id: StringName, p_seed: int) -> AudioStreamWAV:
	var key := str(p_id) + ":" + str(p_seed)
	if _buffer_cache.has(key):
		return _buffer_cache[key]
	var stream := WaveBuilder.to_stream(SoundKit.buffer(p_id, p_seed))
	if _buffer_cache.size() >= CACHE_LIMIT:
		_buffer_cache.clear()
	_buffer_cache[key] = stream
	return stream
