extends GutTest
## Input bindings and helper math for controller support.

const ACTIONS: Array[StringName] = [
	&"move_left", &"move_right", &"move_up", &"move_down",
	&"attack", &"throw_bomb", &"interact", &"new_run", &"toggle_minimap", &"pause",
]

const LABEL_KEYS: Array[StringName] = [
	&"move", &"attack", &"throw_bomb", &"interact", &"new_run", &"toggle_minimap", &"pause",
]

func test_every_action_has_a_keyboard_binding() -> void:
	for action in ACTIONS:
		assert_true(_has_key(action), "%s has no keyboard binding" % action)

func test_every_action_has_a_gamepad_binding() -> void:
	for action in ACTIONS:
		assert_true(_has_joypad(action), "%s has no gamepad binding" % action)

func test_movement_bindings_cover_stick_and_dpad() -> void:
	assert_true(_has_stick_axis(&"move_up", 1, -1.0))
	assert_true(_has_stick_axis(&"move_down", 1, 1.0))
	assert_true(_has_stick_axis(&"move_left", 0, -1.0))
	assert_true(_has_stick_axis(&"move_right", 0, 1.0))
	assert_true(_has_button(&"move_up", 11))
	assert_true(_has_button(&"move_down", 12))
	assert_true(_has_button(&"move_left", 13))
	assert_true(_has_button(&"move_right", 14))

func test_action_buttons_are_bound() -> void:
	assert_true(_has_button(&"attack", 0))
	assert_true(_has_button(&"throw_bomb", 2))
	assert_true(_has_button(&"interact", 1))
	assert_true(_has_button(&"new_run", 3))
	assert_true(_has_button(&"toggle_minimap", 6))
	assert_true(_has_button(&"pause", 7))

func test_deadzone_filters_small_input() -> void:
	assert_eq(Controls.sanitize_axis(Vector2(0.1, 0.0)), Vector2.ZERO)
	assert_ne(Controls.sanitize_axis(Vector2(0.5, 0.0)), Vector2.ZERO)

func test_diagonal_speed_is_capped() -> void:
	var result := Controls.clamp_unit(Vector2(1.0, 1.0))
	assert_lte(result.length(), 1.0001)

func test_short_vectors_are_not_scaled() -> void:
	assert_eq(Controls.clamp_unit(Vector2(0.3, 0.4)), Vector2(0.3, 0.4))

func test_sanitize_keeps_units_at_most_one() -> void:
	var result := Controls.sanitize_axis(Vector2(0.9, 0.9))
	assert_lte(result.length(), 1.0001)

func test_headless_movement_is_still() -> void:
	assert_eq(Controls.movement_vector(), Vector2.ZERO)

func test_action_labels_exist_for_both_devices() -> void:
	for label_key in LABEL_KEYS:
		assert_ne(Controls.label_for(label_key, false), "", "%s label missing" % label_key)
		assert_ne(Controls.label_for(label_key, true), "", "%s gamepad label missing" % label_key)

func test_device_labels_differ() -> void:
	assert_ne(Controls.label_for(&"move", false), Controls.label_for(&"move", true))
	assert_ne(Controls.label_for(&"attack", false), Controls.label_for(&"attack", true))

func test_hint_text_is_not_empty() -> void:
	assert_ne(Controls.hint_for(false), "")
	assert_ne(Controls.hint_for(true), "")

func _has_key(p_action: StringName) -> bool:
	for event in InputMap.action_get_events(p_action):
		if event is InputEventKey:
			return true
	return false

func _has_joypad(p_action: StringName) -> bool:
	for event in InputMap.action_get_events(p_action):
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			return true
	return false

func _has_button(p_action: StringName, p_index: int) -> bool:
	for event in InputMap.action_get_events(p_action):
		if event is InputEventJoypadButton and event.button_index == p_index:
			return true
	return false

func _has_stick_axis(p_action: StringName, p_axis: int, p_value: float) -> bool:
	for event in InputMap.action_get_events(p_action):
		if event is InputEventJoypadMotion \
				and event.axis == p_axis \
				and is_equal_approx(event.axis_value, p_value):
			return true
	return false
