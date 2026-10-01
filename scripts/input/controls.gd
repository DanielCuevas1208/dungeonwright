class_name Controls
extends RefCounted
## Input helpers for the keyboard and a gamepad.
##
## The game reads movement through this class. It applies a deadzone,
## caps diagonal speed, and picks display labels for the active device.
## The helpers are pure functions so the test suite can assert them.

const MOVE_DEADZONE := 0.25

## Every action the game binds. Tests and the smoke test use this list
## to prove the input map stays complete.
const ACTIONS: Array[StringName] = [
	&"move_left", &"move_right", &"move_up", &"move_down",
	&"attack", &"throw_bomb", &"interact", &"new_run", &"toggle_minimap", &"pause",
]

## Movement from the keyboard or the first connected gamepad.
## Returns a vector with a length of at most one.
static func movement_vector() -> Vector2:
	return sanitize_axis(
		Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down", MOVE_DEADZONE)
	)

## Zeroes inputs below the deadzone and caps the length at one.
static func sanitize_axis(p_vector: Vector2, p_deadzone: float = MOVE_DEADZONE) -> Vector2:
	if p_vector.length() < p_deadzone:
		return Vector2.ZERO
	return clamp_unit(p_vector)

## Caps the vector length while keeping its direction.
static func clamp_unit(p_vector: Vector2, p_max_length: float = 1.0) -> Vector2:
	return p_vector.limit_length(p_max_length)

## True when a gamepad is connected.
static func gamepad_active() -> bool:
	return not Input.get_connected_joypads().is_empty()

## Returns the display label for an action on the active device.
static func action_label(p_action: StringName) -> String:
	return label_for(p_action, gamepad_active())

## Returns the display label for an action on a given device.
static func label_for(p_action: StringName, p_gamepad: bool) -> String:
	match p_action:
		&"move":
			return "Left stick or d-pad" if p_gamepad else "WASD or arrows"
		&"attack":
			return "A or R shoulder" if p_gamepad else "Space, J, or click"
		&"throw_bomb":
			return "X" if p_gamepad else "B"
		&"interact":
			return "B" if p_gamepad else "E"
		&"new_run":
			return "Y" if p_gamepad else "N"
		&"toggle_minimap":
			return "Select" if p_gamepad else "M"
		&"pause":
			return "Start" if p_gamepad else "Esc"
	return ""

## A two-line hint for the menu, tailored to the active device.
static func hint_text() -> String:
	return hint_for(gamepad_active())

## A two-line hint for the menu, tailored to a given device.
static func hint_for(p_gamepad: bool) -> String:
	if p_gamepad:
		return "Move: left stick or d-pad   Attack: A or R shoulder   Bomb: X\nShrines: B   Open doors: walk in with a key   New run: Y   Pause: Start"
	return "Move: WASD or arrows   Attack: Space, J, or click   Bomb: B\nShrines: E   Open doors: walk in with a key   New run: N   Pause: Esc"
