extends GutTest
## Completed runs stay ordered, bounded, isolated, and durable.

const TEST_PATH := "res://.dungeonwright_run_history_test.json"
const MISSING_PATH := "res://.dungeonwright_run_history_missing.json"

func after_all() -> void:
	_remove_file(TEST_PATH)
	_remove_file(MISSING_PATH)

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
	var stats := RunStats.new()
	stats.record_damage_dealt(12)
	stats.record_damage_blocked(3)
	stats.record_bomb_thrown()
	history.add_result(true, "000002", 3, 3, 6, 70.0, stats)

	var formatted := history.format_records()
	assert_true(formatted.begins_with("1. WON | 000002 | F3/3 | 6c | 1:10 | dmg 12 blk 3 bomb 1"))
	assert_true(formatted.contains("2. LOST | 000001 | F1/3 | 0c | 0:09 | dmg 0 blk 0 bomb 0"))

func test_save_and_load_round_trip_preserves_records() -> void:
	_remove_file(TEST_PATH)
	var history := RunHistory.new()
	var stats := RunStats.new()
	stats.record_damage_dealt(12)
	stats.record_damage_blocked(3)
	stats.record_bomb_thrown()
	history.add_result(true, "000123", 3, 3, 4, 70.0, stats)

	assert_true(history.save_to_disk(TEST_PATH))
	var loaded := RunHistory.new()
	assert_true(loaded.load_from_disk(TEST_PATH))
	assert_eq(loaded.records(), history.records())

func test_missing_file_starts_an_empty_history() -> void:
	_remove_file(MISSING_PATH)
	var history := RunHistory.new()
	history.add_result(true, "000123", 3, 3, 4, 70.0)

	assert_true(history.load_from_disk(MISSING_PATH))
	assert_true(history.is_empty())

func test_unknown_version_keeps_existing_records() -> void:
	_remove_file(TEST_PATH)
	var file := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify({"version": 99, "records": []}))
	file.close()
	var history := RunHistory.new()
	history.add_result(true, "000123", 3, 3, 4, 70.0)

	assert_false(history.load_from_disk(TEST_PATH))
	assert_eq(history.size(), 1)
	assert_eq(history.records()[0]["seed"], "000123")

func test_invalid_records_are_skipped() -> void:
	_remove_file(TEST_PATH)
	var valid_record := {
		"won": true,
		"seed": "000123",
		"floor_reached": 3,
		"floor_count": 3,
		"coins": 4,
		"time": 70.0,
		"damage_dealt": 12,
		"damage_blocked": 3,
		"bombs_thrown": 1,
	}
	var file := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify({
		"version": RunHistory.STORAGE_VERSION,
		"records": [valid_record, {"won": "yes", "seed": "invalid"}],
	}))
	file.close()
	var history := RunHistory.new()

	assert_true(history.load_from_disk(TEST_PATH))
	assert_eq(history.size(), 1)
	assert_eq(history.records()[0]["seed"], "000123")

func test_clear_saved_persists_an_empty_history() -> void:
	_remove_file(TEST_PATH)
	var history := RunHistory.new()
	history.add_result(true, "000123", 3, 3, 4, 70.0)
	assert_true(history.save_to_disk(TEST_PATH))

	assert_true(history.clear_saved())
	var loaded := RunHistory.new()
	assert_true(loaded.load_from_disk(TEST_PATH))
	assert_true(loaded.is_empty())

func _remove_file(p_path: String) -> void:
	if FileAccess.file_exists(p_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(p_path))
