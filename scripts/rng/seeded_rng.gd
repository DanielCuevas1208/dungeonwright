class_name SeededRng
extends RefCounted
## Deterministic pseudo-random number generator.
##
## Uses the mulberry32 algorithm. The output depends only on the seed,
## not on the Godot version or the platform, so any run can repeat.
## The class also encodes seeds as short strings for display and input.

const ALPHABET := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const SEED_MASK := 0xFFFFFF
const U32_MAX := 0xFFFFFFFF

var seed_value: int = 0

var _state: int = 0

## Creates an RNG with the given seed.
func _init(p_seed: int = 0) -> void:
	set_seed(p_seed)

## Resets the RNG to a fixed seed.
func set_seed(p_seed: int) -> void:
	seed_value = p_seed & SEED_MASK
	_state = seed_value

## Returns a float in the range [0.0, 1.0).
func next_float() -> float:
	return _next_u32() / 4294967296.0

## Returns a float in the range [p_from, p_to).
func next_float_range(p_from: float, p_to: float) -> float:
	if p_to <= p_from:
		return p_from
	return p_from + next_float() * (p_to - p_from)

## Returns an integer in the range [0, p_count).
func next_int(p_count: int) -> int:
	assert(p_count > 0, "p_count must be positive")
	var limit := U32_MAX - (U32_MAX % p_count)
	var value := _next_u32()
	while value >= limit:
		value = _next_u32()
	return value % p_count

## Returns an integer in the range [p_from, p_to] inclusive.
func next_int_range(p_from: int, p_to: int) -> int:
	if p_to <= p_from:
		return p_from
	return p_from + next_int(p_to - p_from + 1)

## Returns true with the given probability.
func chance(p_probability: float) -> bool:
	return next_float() < p_probability

## Picks one element from a non-empty array.
func pick(p_array: Array) -> Variant:
	assert(p_array.size() > 0, "cannot pick from an empty array")
	return p_array[next_int(p_array.size())]

## Picks an index using the given weights.
func weighted_index(p_weights: Array) -> int:
	assert(p_weights.size() > 0, "p_weights must not be empty")
	var total := 0.0
	for weight in p_weights:
		assert(weight >= 0.0, "weights must be non-negative")
		total += weight
	assert(total > 0.0, "total weight must be positive")
	var roll := next_float() * total
	for i in p_weights.size():
		roll -= p_weights[i]
		if roll < 0.0:
			return i
	return p_weights.size() - 1

## Shuffles the array in place and returns it.
func shuffle(p_array: Array) -> Array:
	for i in range(p_array.size() - 1, 0, -1):
		var j := next_int(i + 1)
		var tmp = p_array[i]
		p_array[i] = p_array[j]
		p_array[j] = tmp
	return p_array

## Derives a new seed from a base seed and a salt value.
## The result depends only on the inputs, never on the platform.
## Run planners use this to give every floor its own seed.
static func derive(p_seed: int, p_salt: int) -> int:
	var state := (p_seed + p_salt * 0x6D2B79F5) & U32_MAX
	state = state ^ (state >> 15)
	state = (state * (state | 1)) & U32_MAX
	state = state ^ (state >> 13)
	state = state ^ (state >> 16)
	return state & SEED_MASK

## Encodes a seed as a fixed-width base-36 string.
static func encode_seed(p_seed: int, p_width: int = 6) -> String:
	var chars := PackedStringArray()
	var value := p_seed & SEED_MASK
	for i in p_width:
		chars.append(ALPHABET[value % 36])
		value /= 36
	chars.reverse()
	return "".join(chars)

## Decodes a base-36 seed string back to an integer.
## Returns -1 when the string is not a valid seed.
static func decode_seed(p_text: String) -> int:
	var text := p_text.strip_edges().to_upper()
	if text.is_empty() or text.length() > 6:
		return -1
	var value := 0
	for i in text.length():
		var index := ALPHABET.find(text[i])
		if index < 0:
			return -1
		value = value * 36 + index
	return value & SEED_MASK

func _next_u32() -> int:
	_state = (_state + 0x6D2B79F5) & U32_MAX
	var t := _state
	t = t ^ (t >> 15)
	t = (t * (t | 1)) & U32_MAX
	t = t ^ (t >> 13)
	return t ^ (t >> 16)
