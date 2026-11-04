class_name SeededChallenge
extends RefCounted
## A shareable seed, generator version, and bounded ruleset.

const CODE_PREFIX := "DW"
const GENERATOR_VERSION := 1
const CODE_SEPARATOR := "-"

const MODIFIER_STANDARD: StringName = &"standard"
const MODIFIER_IRON: StringName = &"iron"
const MODIFIER_FRENZY: StringName = &"frenzy"
const MODIFIER_GAUNTLET: StringName = &"gauntlet"

const MODIFIER_CODES := {
	MODIFIER_STANDARD: "S",
	MODIFIER_IRON: "I",
	MODIFIER_FRENZY: "F",
	MODIFIER_GAUNTLET: "G",
}

const MODIFIER_DATA := {
	MODIFIER_STANDARD: {
		"name": "Standard Descent",
		"description": "Three floors with normal healing and escalating monsters.",
		"floor_count": 3,
		"heal_between_floors": 0.5,
		"difficulty_per_floor": 0.25,
	},
	MODIFIER_IRON: {
		"name": "Iron Descent",
		"description": "Three floors with no healing between floors.",
		"floor_count": 3,
		"heal_between_floors": 0.0,
		"difficulty_per_floor": 0.25,
	},
	MODIFIER_FRENZY: {
		"name": "Frenzy Descent",
		"description": "Three floors with faster monster growth.",
		"floor_count": 3,
		"heal_between_floors": 0.5,
		"difficulty_per_floor": 0.5,
	},
	MODIFIER_GAUNTLET: {
		"name": "Gauntlet",
		"description": "Three floors with no healing and faster monster growth.",
		"floor_count": 3,
		"heal_between_floors": 0.0,
		"difficulty_per_floor": 0.5,
	},
}

var seed_value: int
var generator_version: int
var modifier_id: StringName

func _init(
	p_seed_value: int = 0,
	p_modifier_id: StringName = MODIFIER_STANDARD,
	p_generator_version: int = GENERATOR_VERSION
) -> void:
	seed_value = p_seed_value & SeededRng.SEED_MASK
	modifier_id = p_modifier_id
	generator_version = p_generator_version

## Returns a canonical code such as DW1-0000ZJ-I.
func code() -> String:
	return "%s%d%s%s%s%s" % [
		CODE_PREFIX,
		generator_version,
		CODE_SEPARATOR,
		SeededRng.encode_seed(seed_value),
		CODE_SEPARATOR,
		modifier_code(),
	]

## Returns true when text has the challenge-code shape.
static func looks_like_code(p_text: String) -> bool:
	var text := p_text.strip_edges().to_upper()
	return text.begins_with(CODE_PREFIX) and text.contains(CODE_SEPARATOR)

## Decodes a canonical challenge code. Invalid or unknown codes return null.
static func decode(p_code: String) -> SeededChallenge:
	var parts := p_code.strip_edges().to_upper().split(CODE_SEPARATOR)
	if parts.size() != 3:
		return null
	var version_token := parts[0]
	if version_token.length() != CODE_PREFIX.length() + 1 or not version_token.begins_with(CODE_PREFIX):
		return null
	var version_text := version_token.substr(CODE_PREFIX.length())
	if not version_text.is_valid_int():
		return null
	var version := int(version_text)
	if version != GENERATOR_VERSION:
		return null
	if parts[1].length() != 6:
		return null
	var seed_value := SeededRng.decode_seed(parts[1])
	if seed_value < 0:
		return null
	var modifier_id := _modifier_from_code(parts[2])
	if modifier_id == StringName():
		return null
	return SeededChallenge.new(seed_value, modifier_id, version)

## Creates a canonical challenge code from a seed and fixed modifier.
static func encode(p_seed_value: int, p_modifier_id: StringName = MODIFIER_STANDARD) -> String:
	return SeededChallenge.new(p_seed_value, p_modifier_id).code()

## Returns true when this challenge contains supported data.
func is_valid() -> bool:
	return generator_version == GENERATOR_VERSION and MODIFIER_CODES.has(modifier_id)

## Applies the fixed modifier to a fresh run-rules object.
func apply_to(p_rules: RunRules) -> void:
	if p_rules == null or not is_valid():
		return
	var data := _modifier_data()
	p_rules.floor_count = int(data["floor_count"])
	p_rules.heal_between_floors = float(data["heal_between_floors"])
	p_rules.difficulty_per_floor = float(data["difficulty_per_floor"])

## Returns the fixed modifier name and short rules text.
func summary() -> String:
	var data := _modifier_data()
	return "%s — %s" % [data.get("name", "Unknown"), data.get("description", "Unknown rules.")]

## Returns the menu text shown before a challenge starts.
func preview_text() -> String:
	return "Challenge: %s\n%s\nSeed %s | Generator %d" % [
		code(),
		summary(),
		SeededRng.encode_seed(seed_value),
		generator_version,
	]

## Returns the one-letter modifier stored in the code.
func modifier_code() -> String:
	return str(MODIFIER_CODES.get(modifier_id, ""))

func _modifier_data() -> Dictionary:
	return MODIFIER_DATA.get(modifier_id, {})

static func _modifier_from_code(p_code: String) -> StringName:
	for modifier_id in MODIFIER_CODES:
		if MODIFIER_CODES[modifier_id] == p_code:
			return modifier_id
	return StringName()
