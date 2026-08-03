class_name ResultOverlay
extends Control
## The victory and defeat overlay.
##
## Shows the run summary and lets the hero start again with a new seed
## or the same seed.

signal new_run_requested(same_seed: bool)

var _title: Label = null
var _summary: Label = null
var _same_seed_button: Button = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build()

func show_result(
	p_won: bool,
	p_seed: String,
	p_depth: int,
	p_coins: int,
	p_time: float,
	p_floors_cleared: int = 0,
	p_max_floors: int = 1
) -> void:
	visible = true
	_title.text = "Victory" if p_won else "Defeat"
	_title.add_theme_color_override("font_color", Color("#7fe8b9") if p_won else Color("#e07070"))
	var minutes := int(p_time) / 60
	var seconds := int(p_time) % 60
	_summary.text = "Seed: %s\nFloor: %d / %d\nDepth: %d\nCoins: %d\nTime: %d:%02d" % [
		p_seed, p_floors_cleared, p_max_floors, p_depth, p_coins, minutes, seconds,
	]
	_same_seed_button.visible = p_won

func hide_result() -> void:
	visible = false

func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.8)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(380, 0)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)

	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 38)

	_summary = Label.new()
	_summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_summary.add_theme_font_size_override("font_size", 16)

	var new_button := Button.new()
	new_button.text = "New run (random seed)"
	new_button.custom_minimum_size = Vector2(0, 36)

	_same_seed_button = Button.new()
	_same_seed_button.text = "Replay this seed"
	_same_seed_button.custom_minimum_size = Vector2(0, 36)

	box.add_child(_title)
	box.add_child(_summary)
	box.add_child(new_button)
	box.add_child(_same_seed_button)

	margin.add_child(box)
	panel.add_child(margin)
	center.add_child(panel)
	add_child(center)

	new_button.pressed.connect(func() -> void: new_run_requested.emit(false))
	_same_seed_button.pressed.connect(func() -> void: new_run_requested.emit(true))
