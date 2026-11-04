extends GutTest
## Challenge codes preserve the seed, generator version, and fixed modifier.

const MODIFIERS := [
	SeededChallenge.MODIFIER_STANDARD,
	SeededChallenge.MODIFIER_IRON,
	SeededChallenge.MODIFIER_FRENZY,
	SeededChallenge.MODIFIER_GAUNTLET,
]

func test_every_modifier_round_trips_without_data_loss() -> void:
	for modifier_id in MODIFIERS:
		var challenge := SeededChallenge.new(123456, modifier_id)
		var decoded := SeededChallenge.decode(challenge.code())
		assert_not_null(decoded)
		assert_eq(decoded.seed_value, 123456)
		assert_eq(decoded.generator_version, SeededChallenge.GENERATOR_VERSION)
		assert_eq(decoded.modifier_id, modifier_id)
		assert_eq(decoded.code(), challenge.code())

func test_codes_are_case_insensitive_and_fixed_width() -> void:
	var code := SeededChallenge.encode(123456, SeededChallenge.MODIFIER_IRON)
	assert_eq(code, "DW1-002N9C-I")
	var decoded := SeededChallenge.decode(code.to_lower())
	assert_not_null(decoded)
	assert_eq(decoded.code(), code)

func test_invalid_codes_are_rejected() -> void:
	for code in [
		"DW2-002N9C-I",
		"DW01-002N9C-I",
		"DW1-002N9C-X",
		"DW1-002N9C",
		"DW1-TOOLONG-I",
		"DW1-###-I",
	]:
		assert_null(SeededChallenge.decode(code), "code should be rejected: " + code)

func test_only_challenge_shape_uses_the_challenge_parser() -> void:
	assert_true(SeededChallenge.looks_like_code("DW1-002N9C-I"))
	assert_true(SeededChallenge.looks_like_code(" dw1-002n9c-i "))
	assert_false(SeededChallenge.looks_like_code("002N9C"))
	assert_false(SeededChallenge.looks_like_code(""))

func test_modifiers_apply_bounded_run_rules() -> void:
	var standard := _rules_for(SeededChallenge.MODIFIER_STANDARD)
	var iron := _rules_for(SeededChallenge.MODIFIER_IRON)
	var frenzy := _rules_for(SeededChallenge.MODIFIER_FRENZY)
	var gauntlet := _rules_for(SeededChallenge.MODIFIER_GAUNTLET)

	assert_eq(standard.floor_count, 3)
	assert_eq(standard.heal_between_floors, 0.5)
	assert_eq(standard.difficulty_per_floor, 0.25)
	assert_eq(iron.heal_between_floors, 0.0)
	assert_eq(frenzy.heal_between_floors, 0.5)
	assert_eq(frenzy.difficulty_per_floor, 0.5)
	assert_eq(gauntlet.heal_between_floors, 0.0)
	assert_eq(gauntlet.difficulty_per_floor, 0.5)

func test_each_challenge_code_reaches_every_generated_floor() -> void:
	var generator := DungeonGenerator.new()
	for modifier_id in MODIFIERS:
		var challenge := SeededChallenge.new(424242, modifier_id)
		var rules := challenge_rules(challenge)
		var biome := Biomes.random(SeededRng.new(challenge.seed_value ^ 0x5EED))
		for floor in rules.floor_count:
			var result := generator.generate(
				biome,
				RunRules.floor_seed(challenge.seed_value, floor)
			)
			assert_true(result.solvable, "%s floor %d is not solvable" % [modifier_id, floor])

func test_same_challenge_code_replays_the_same_dungeon() -> void:
	var first := SeededChallenge.decode("DW1-002N9C-G")
	var second := SeededChallenge.decode("dw1-002n9c-g")
	var biome := Biomes.random(SeededRng.new(first.seed_value ^ 0x5EED))
	var generator := DungeonGenerator.new()
	var first_result := generator.generate(biome, RunRules.floor_seed(first.seed_value, 1))
	var second_result := generator.generate(biome, RunRules.floor_seed(second.seed_value, 1))

	assert_eq(first_result.start_pos, second_result.start_pos)
	assert_eq(first_result.exit_pos, second_result.exit_pos)
	assert_eq(first_result.map.width, second_result.map.width)
	assert_eq(first_result.map.height, second_result.map.height)
	for y in first_result.map.height:
		for x in first_result.map.width:
			assert_eq(first_result.map.get_tile(x, y), second_result.map.get_tile(x, y))

func _rules_for(p_modifier_id: StringName) -> RunRules:
	return challenge_rules(SeededChallenge.new(0, p_modifier_id))

func challenge_rules(p_challenge: SeededChallenge) -> RunRules:
	var rules := RunRules.new()
	p_challenge.apply_to(rules)
	return rules
