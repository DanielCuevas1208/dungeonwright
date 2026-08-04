class_name AudioController
extends Node
## Plays the generated sound effects and the biome music.
##
## The controller owns a pool of short-effect players and one music
## player. It builds every stream through SoundBank and MusicTheme, so
## the game ships no audio files. Players keep running while the game is
## paused, so menu music and result stings still play.

const SFX_POOL_SIZE := 8
const SFX_VOLUME_DB := -6.0
const MUSIC_VOLUME_DB := -14.0

var _sfx_players: Array[AudioStreamPlayer] = []
var _music_player: AudioStreamPlayer = null
var _next_sfx := 0

func _ready() -> void:
	for i in SFX_POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.volume_db = SFX_VOLUME_DB
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(player)
		_sfx_players.append(player)
	_music_player = AudioStreamPlayer.new()
	_music_player.volume_db = MUSIC_VOLUME_DB
	_music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_music_player)

## Plays a short sound effect once on the next free player.
func play_sfx(p_cue: StringName) -> void:
	if not SoundBank.has(p_cue) or _sfx_players.is_empty():
		return
	var player := _sfx_players[_next_sfx]
	_next_sfx = (_next_sfx + 1) % _sfx_players.size()
	player.stream = SoundBank.cue(p_cue)
	player.play()

## Loops the theme for a theme id until the music changes.
func play_music(p_theme_id: StringName) -> void:
	if _music_player == null:
		return
	_music_player.stream = MusicTheme.theme(p_theme_id)
	_music_player.play()

## Stops the music, used when a run ends.
func stop_music() -> void:
	if _music_player == null:
		return
	_music_player.stop()

## Stops every player and drops its stream, used before teardown.
func stop_all() -> void:
	for player in _sfx_players:
		player.stop()
		player.stream = null
	if _music_player != null:
		_music_player.stop()
		_music_player.stream = null

## True when the music stream is playing.
func is_music_playing() -> bool:
	return _music_player != null and _music_player.playing
