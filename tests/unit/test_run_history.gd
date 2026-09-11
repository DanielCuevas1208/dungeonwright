extends GutTest
## Completed runs stay ordered, bounded, and isolated from later counter changes.

func test_history_starts_empty() -> void:
	var history := RunHistory.new()
	assert_true(history.is_empty())
	assert_eq(history.size(), 0)

func test_add_result_copies_run_stats() -> void:
	var history := RunHistory.new()
	var stats := RunStats.new()
	stats.record_damage_dealt(12)
	stats.record_damage_blocked(3)
	stats.record_bomb_thrown()
	history.add_result(true, "000123", 3, 3, 4, 70.0, stats)
	stats.reset()

	var record: Dictionary = history.records()[0]
	assert_eq(record["damage_dealt"], 12)
	assert_eq(record["damage_blocked"], 3)
	assert_eq(record["bombs_thrown"], 1)

func test_newest_result_is_first() -> void:
	var history := RunHistory.new()
	history.add_result(false, "000001", 1, 3, 0, 9.0)
	history.add_result(true, "000002", 3, 3, 6, 12.0)

	var record: Dictionary = history.records()[0]
	assert_true(record["won"])
	assert_eq(record["seed"], "000002")

func test_history_keeps_only_the_five_newest_results() -> void:
	var history := RunHistory.new()
	for seed in range(1, RunHistory.MAX_ENTRIES + 3):
		history.add_result(false, str(seed), 1, 3, 0, 0.0)

	assert_eq(history.size(), RunHistory.MAX_ENTRIES)
	assert_eq(history.records()[0]["seed"], "7")
	assert_eq(history.records()[4]["seed"], "3")

func test_records_are_copied() -> void:
	var history := RunHistory.new()
	history.add_result(true, "000123", 3, 3, 4, 10.0)
	var records := history.records()
	records[0]["seed"] = "changed"

	assert_eq(history.records()[0]["seed"], "000123")

func test_format_records_shows_newest_first() -> void:
	var history := RunHistory.new()
	history.add_result(false, "000001", 1, 3, 0, 9.0)
	history.add_result(true, "000002", 3, 3, 6, 70.0)

	var formatted := history.format_records()
	assert_true(formatted.begins_with("1. WON | 000002 | F3/3 | 6c | 1:10"))
	assert_true(formatted.contains("2. LOST | 000001 | F1/3 | 0c | 0:09"))
