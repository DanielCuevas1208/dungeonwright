extends GutTest
## Run statistics accept valid counters and ignore invalid input.

func test_counters_start_at_zero() -> void:
	var stats := RunStats.new()
	assert_eq(stats.damage_dealt, 0)
	assert_eq(stats.damage_blocked, 0)
	assert_eq(stats.bombs_thrown, 0)

func test_damage_counters_accumulate_actual_values() -> void:
	var stats := RunStats.new()
	stats.record_damage_dealt(12)
	stats.record_damage_dealt(8)
	stats.record_damage_blocked(3)
	stats.record_damage_blocked(2)
	assert_eq(stats.damage_dealt, 20)
	assert_eq(stats.damage_blocked, 5)

func test_negative_damage_does_not_reduce_totals() -> void:
	var stats := RunStats.new()
	stats.record_damage_dealt(-4)
	stats.record_damage_blocked(-2)
	assert_eq(stats.damage_dealt, 0)
	assert_eq(stats.damage_blocked, 0)

func test_bombs_thrown_counts_each_throw() -> void:
	var stats := RunStats.new()
	stats.record_bomb_thrown()
	stats.record_bomb_thrown()
	assert_eq(stats.bombs_thrown, 2)

func test_reset_clears_every_counter() -> void:
	var stats := RunStats.new()
	stats.record_damage_dealt(12)
	stats.record_damage_blocked(3)
	stats.record_bomb_thrown()
	stats.reset()
	assert_eq(stats.damage_dealt, 0)
	assert_eq(stats.damage_blocked, 0)
	assert_eq(stats.bombs_thrown, 0)

func test_snapshot_copies_every_counter() -> void:
	var stats := RunStats.new()
	stats.record_damage_dealt(12)
	stats.record_damage_blocked(3)
	stats.record_bomb_thrown()
	var snapshot := stats.snapshot()
	stats.reset()
	assert_eq(snapshot["damage_dealt"], 12)
	assert_eq(snapshot["damage_blocked"], 3)
	assert_eq(snapshot["bombs_thrown"], 1)

func test_result_screen_shows_counters() -> void:
	var overlay := ResultOverlay.new()
	autofree(overlay)
	add_child(overlay)
	await wait_process_frames(1)
	var stats := RunStats.new()
	stats.record_damage_dealt(12)
	stats.record_damage_blocked(3)
	stats.record_bomb_thrown()
	overlay.show_result(true, "000123", 3, 3, 4, 10.0, stats)
	assert_true(overlay._summary.text.contains("Damage dealt: 12"))
	assert_true(overlay._summary.text.contains("Damage blocked: 3"))
	assert_true(overlay._summary.text.contains("Bombs thrown: 1"))

func test_result_screen_shows_recent_history_when_provided() -> void:
	var overlay := ResultOverlay.new()
	autofree(overlay)
	add_child(overlay)
	await wait_process_frames(1)
	var history := RunHistory.new()
	history.add_result(true, "000123", 3, 3, 4, 10.0)
	overlay.show_result(true, "000123", 3, 3, 4, 10.0, null, history)
	assert_true(overlay._history_label.visible)
	assert_true(overlay._history_label.text.contains("Recent runs (this session)"))
	assert_true(overlay._history_label.text.contains("WON | 000123"))
