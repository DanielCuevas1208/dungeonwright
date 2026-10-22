extends GutTest
## Main-menu history reads saved records without touching the active run.

const MISSING_PATH := "res://.dungeonwright_menu_missing_history.json"
const CORRUPT_PATH := "res://.dungeonwright_menu_corrupt_history.json"
const VALID_PATH := "res://.dungeonwright_menu_valid_history.json"

func before_each() -> void:
	get_tree().paused = false
	_remove_fixture(MISSING_PATH)
	_remove_fixture(CORRUPT_PATH)
	_remove_fixture(VALID_PATH)
	RunState.status = RunState.RunStatus.IDLE

func after_each() -> void:
	get_tree().paused = false
	_remove_fixture(MISSING_PATH)
	_remove_fixture(CORRUPT_PATH)
	_remove_fixture(VALID_PATH)

func test_missing_history_opens_as_empty_without_starting_or_changing_a_run() -> void:
	var main: Main = await _add_main(MISSING_PATH)
	main.start_run(2468)
	var seed_before := main.run.seed_value
	var floor_before := main.floor_index
	var position_before := main.player.grid_pos

	main.menu_overlay.show_menu(true, main.run_history)
	main.menu_overlay._history_button.pressed.emit()

	assert_eq(main.run_history.size(), 0)
	assert_true(main.menu_overlay._history_center.visible)
	assert_false(main.menu_overlay._menu_center.visible)
	assert_true(main.menu_overlay._history_label.text.contains("No completed runs saved."))
	assert_eq(main.run.seed_value, seed_before)
	assert_eq(main.floor_index, floor_before)
	assert_eq(main.player.grid_pos, position_before)

func test_corrupt_history_opens_as_empty_without_starting_or_changing_a_run() -> void:
	_write_text(CORRUPT_PATH, "{not valid json")
	var main: Main = await _add_main(CORRUPT_PATH)
	main.start_run(1357)
	var seed_before := main.run.seed_value
	var floor_before := main.floor_index

	main.menu_overlay.show_menu(true, main.run_history)
	main.menu_overlay._history_button.pressed.emit()

	assert_eq(main.run_history.size(), 0)
	assert_true(main.menu_overlay._history_label.text.contains("No completed runs saved."))
	assert_eq(main.run.seed_value, seed_before)
	assert_eq(main.floor_index, floor_before)

func test_saved_history_is_visible_before_new_run_and_clear_still_requires_confirmation() -> void:
	var history := RunHistory.new()
	history.add_result(true, "000123", 3, 3, 4, 70.0)
	assert_true(history.save_to_disk(VALID_PATH))
	var main: Main = await _add_main(VALID_PATH)
	main.start_run(9753)
	var seed_before := main.run.seed_value

	main.menu_overlay.show_menu(true, main.run_history)
	main.menu_overlay._history_button.pressed.emit()

	assert_true(main.menu_overlay._history_label.text.contains("WON | 000123"))
	assert_true(main.menu_overlay._history_clear_button.visible)
	assert_eq(main.run.seed_value, seed_before)

	main.menu_overlay._confirm_clear_history()
	var dialog: ConfirmationDialog = _confirmation_dialog(main.menu_overlay)
	assert_not_null(dialog)
	assert_true(dialog.visible)
	assert_eq(main.run_history.size(), 1)

	dialog.confirmed.emit()
	await wait_process_frames(1)

	assert_true(main.run_history.is_empty())
	var loaded := RunHistory.new()
	assert_true(loaded.load_from_disk(VALID_PATH))
	assert_true(loaded.is_empty())
	assert_eq(main.run.seed_value, seed_before)

func _add_main(p_history_path: String) -> Main:
	var scene: PackedScene = load("res://scenes/main.tscn")
	var main: Main = scene.instantiate()
	main.history_path = p_history_path
	add_child_autofree(main)
	await wait_process_frames(1)
	return main

func _confirmation_dialog(p_overlay: MenuOverlay) -> ConfirmationDialog:
	for child in p_overlay.get_children():
		if child is ConfirmationDialog:
			return child as ConfirmationDialog
	return null

func _write_text(p_path: String, p_text: String) -> void:
	var file := FileAccess.open(p_path, FileAccess.WRITE)
	file.store_string(p_text)
	file.close()

func _remove_fixture(p_path: String) -> void:
	if FileAccess.file_exists(p_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(p_path))

