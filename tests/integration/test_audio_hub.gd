extends GutTest
## The audio hub node plays effects and music from generated buffers.

var _muted_flag := false

func _make_hub() -> AudioHub:
	var hub := AudioHub.new()
	add_child_autofree(hub)
	await get_tree().process_frame
	return hub

func test_hub_is_ready_after_build() -> void:
	var hub := await _make_hub()
	assert_true(hub.is_ready())

func test_hub_plays_a_known_effect() -> void:
	var hub := await _make_hub()
	assert_true(hub.play_sfx(&"hit"))
	assert_true(hub.play_sfx(&"pickup", 1234))

func test_hub_rejects_unknown_effect() -> void:
	var hub := await _make_hub()
	assert_false(hub.play_sfx(&"bogus"))

func test_hub_caches_repeated_effects() -> void:
	var hub := await _make_hub()
	var first := hub._cached_stream(&"hit", 7)
	var second := hub._cached_stream(&"hit", 7)
	assert_eq(first, second)

func test_hub_toggle_mute_emits_signal() -> void:
	var hub := await _make_hub()
	hub.muted_changed.connect(func(p_muted: bool) -> void: _muted_flag = p_muted)
	assert_false(hub.is_muted())
	var new_state := hub.toggle_mute()
	assert_true(new_state)
	assert_true(hub.is_muted())
	assert_true(_muted_flag)
	assert_false(hub.toggle_mute())
	assert_false(hub.is_muted())

func test_hub_mute_silences_sfx() -> void:
	var hub := await _make_hub()
	hub.set_muted(true)
	assert_true(hub.play_sfx(&"hit"))
	for player in hub._sfx_players:
		assert_false(player.playing)

func test_hub_plays_music_loop() -> void:
	var hub := await _make_hub()
	hub.play_music(&"crypt", 31337)
	var stream: AudioStreamWAV = hub._music_player.stream
	assert_not_null(stream)
	assert_eq(stream.loop_mode, AudioStreamWAV.LOOP_FORWARD)
	assert_eq(stream.loop_begin, 0)
	assert_eq(stream.loop_end, MusicBox.buffer(&"crypt", 31337).size())
	assert_true(stream.stereo)

func test_hub_mute_stops_music() -> void:
	var hub := await _make_hub()
	hub.play_music(&"crypt", 1)
	hub.set_muted(true)
	assert_false(hub._music_player.playing)
	hub.set_muted(false)
	assert_true(hub._music_player.playing)
