extends GutTest
## The menu previews a challenge before play and the live run uses its rules.

const CHALLENGE_CODE := "DW1-002N9C-I"

func before_each() -> void:
	get_tree().paused = false
	RunState.status = RunState.RunStatus.IDLE
	RunState.challenge_code = ""

func after_each() -> void:
	get_tree().paused = false
	RunState.challenge_code = ""

func test_menu_shows_challenge_rules_without_starting_a_run() -> void:
	var main: Main = await _add_main()
	main.menu_overlay.show_menu(false, main.run_history)
	main.menu_overlay._seed_edit.text = CHALLENGE_CODE
	main.menu_overlay._on_seed_changed(CHALLENGE_CODE)

	assert_true(main.menu_overlay._challenge_label.text.contains("Iron Descent"))
	assert_true(main.menu_overlay._challenge_label.text.contains("no healing"))
	assert_true(main.menu_overlay._challenge_label.text.contains("Generator 1"))
	assert_null(main.run)
	assert_eq(RunState.status, RunState.RunStatus.IDLE)

func test_menu_starts_challenge_with_fixed_rules_and_reachable_map() -> void:
	var main: Main = await _add_main()
	main.menu_overlay._seed_edit.text = CHALLENGE_CODE
	main.menu_overlay._on_start_pressed()
	var challenge := SeededChallenge.decode(CHALLENGE_CODE)

	assert_eq(main.active_challenge.code(), CHALLENGE_CODE)
	assert_eq(RunState.challenge_code, CHALLENGE_CODE)
	assert_eq(main.run_rules.heal_between_floors, 0.0)
	assert_eq(main.run_rules.difficulty_per_floor, 0.25)
	assert_true(main.run.solvable)
	assert_eq(main.run.seed_value, challenge.seed_value)
	assert_true(main.hud.seed_label.text.contains(CHALLENGE_CODE))

func _add_main() -> Main:
	var scene: PackedScene = load("res://scenes/main.tscn")
	var main: Main = scene.instantiate()
	add_child_autofree(main)
	await wait_process_frames(1)
	return main
