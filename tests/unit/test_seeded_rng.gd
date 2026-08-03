extends GutTest
## Deterministic RNG behaviour: same seed, same sequence.

func test_same_seed_same_sequence() -> void:
	var a := SeededRng.new(12345)
	var b := SeededRng.new(12345)
	for i in 50:
		assert_eq(a.next_float(), b.next_float())
		assert_eq(a.next_int(100), b.next_int(100))

func test_different_seeds_differ() -> void:
	var a := SeededRng.new(1)
	var b := SeededRng.new(2)
	var differences := 0
	for i in 100:
		if a.next_float() != b.next_float():
			differences += 1
	assert_gt(differences, 90)

func test_next_float_in_range() -> void:
	var rng := SeededRng.new(7)
	for i in 200:
		var value := rng.next_float()
		assert_between(value, 0.0, 1.0)

func test_next_int_in_range() -> void:
	var rng := SeededRng.new(9)
	for i in 200:
		var value := rng.next_int(13)
		assert_between(value, 0, 12)

func test_next_int_range_inclusive() -> void:
	var rng := SeededRng.new(11)
	for i in 200:
		var value := rng.next_int_range(3, 9)
		assert_between(value, 3, 9)

func test_weighted_index_respects_weights() -> void:
	var rng := SeededRng.new(42)
	var counts := [0, 0, 0]
	for i in 3000:
		counts[rng.weighted_index([7.0, 2.0, 1.0])] += 1
	assert_gt(counts[0], counts[1])
	assert_gt(counts[1], counts[2])

func test_shuffle_keeps_all_items() -> void:
	var rng := SeededRng.new(5)
	var items := [1, 2, 3, 4, 5]
	var shuffled := rng.shuffle(items)
	assert_eq(shuffled.size(), 5)
	for item in items:
		assert_true(shuffled.has(item))

func test_encode_decode_round_trip() -> void:
	for seed in [0, 1, 777, 123456, 16777215]:
		var encoded := SeededRng.encode_seed(seed)
		assert_eq(encoded.length(), 6)
		assert_eq(SeededRng.decode_seed(encoded), seed)

func test_decode_rejects_garbage() -> void:
	assert_eq(SeededRng.decode_seed(""), -1)
	assert_eq(SeededRng.decode_seed("TOOLONG"), -1)
	assert_eq(SeededRng.decode_seed("###"), -1)

func test_encode_is_case_insensitive_when_decoding() -> void:
	var encoded := SeededRng.encode_seed(543210).to_lower()
	assert_eq(SeededRng.decode_seed(encoded), 543210)
