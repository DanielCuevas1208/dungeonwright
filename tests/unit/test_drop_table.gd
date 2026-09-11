extends GutTest
## Drop tables: determinism, balance, and bounds.

const ENTRIES := [
	{ "item": &"coin", "weight": 6.0, "min": 1, "max": 3 },
	{ "item": &"shard", "weight": 2.0, "min": 1, "max": 2 },
	{ "item": &"potion", "weight": 1.0, "min": 1, "max": 1 },
]

func test_same_seed_same_rolls() -> void:
	var a := DropTable.from_entries(ENTRIES, SeededRng.new(77))
	var b := DropTable.from_entries(ENTRIES, SeededRng.new(77))
	for i in 40:
		var drop_a := a.roll()
		var drop_b := b.roll()
		assert_eq(drop_a.item, drop_b.item)
		assert_eq(drop_a.count, drop_b.count)

func test_roll_returns_items_from_table() -> void:
	var table := DropTable.from_entries(ENTRIES, SeededRng.new(3))
	var known := [&"coin", &"shard", &"potion"]
	for i in 40:
		var drop := table.roll()
		assert_true(known.has(drop.item))
		assert_gt(drop.count, 0)

func test_empty_table_returns_null() -> void:
	var table := DropTable.from_entries([], SeededRng.new(1))
	assert_null(table.roll())

func test_probabilities_sum_roughly_to_one() -> void:
	var table := DropTable.from_entries(ENTRIES, SeededRng.new(5))
	var total := table.probability_of(&"coin") \
		+ table.probability_of(&"shard") \
		+ table.probability_of(&"potion")
	assert_almost_eq(total, 1.0, 0.001)

func test_potions_drop_less_often_than_coins() -> void:
	var table := DropTable.from_entries(ENTRIES, SeededRng.new(5))
	assert_lt(table.probability_of(&"potion"), table.probability_of(&"coin"))

func test_long_run_balance_matches_weights() -> void:
	var table := DropTable.from_entries(ENTRIES, SeededRng.new(2024))
	var counts := { &"coin": 0, &"shard": 0, &"potion": 0 }
	for i in 2000:
		counts[table.roll().item] += 1
	assert_gt(counts[&"coin"], counts[&"shard"])
	assert_gt(counts[&"shard"], counts[&"potion"])

func test_every_monster_drop_table_is_balanced() -> void:
	for spec in MonsterSpecs.all():
		var table := spec.drop_table
		assert_gt(table.probability_of(&"coin"), table.probability_of(&"potion"), spec.id)
		assert_lte(table.probability_of(&"potion"), 0.35, spec.id)

func test_every_monster_can_drop_a_bomb() -> void:
	for spec in MonsterSpecs.all():
		var table := spec.drop_table
		assert_gt(table.probability_of(&"bomb"), 0.0, spec.id)

func test_bombs_drop_less_often_than_potions() -> void:
	for spec in MonsterSpecs.all():
		var table := spec.drop_table
		assert_lt(table.probability_of(&"bomb"), table.probability_of(&"potion"), spec.id)

func test_every_monster_can_drop_an_aegis() -> void:
	for spec in MonsterSpecs.all():
		var table := spec.drop_table
		assert_gt(table.probability_of(&"aegis"), 0.0, spec.id)

func test_aegis_drops_rarely() -> void:
	for spec in MonsterSpecs.all():
		var table := spec.drop_table
		assert_lt(table.probability_of(&"aegis"), table.probability_of(&"coin"), spec.id)
		assert_lte(table.probability_of(&"aegis"), 0.1, spec.id)
