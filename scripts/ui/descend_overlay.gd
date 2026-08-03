class_name DescendOverlay
extends Control
## The stairwell prompt between floors.
##
## When the hero reaches the exit of a floor, this overlay asks whether
## to descend. The hero keeps coins and health, and keys reset. The same
## overlay never appears on the final floor, where the exit is the goal.

signal descend_requested
signal stay_requested

var _title: Label = null
var _summary: Label = null
var _descend_button: Button = null
var _stay_button: Button = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build()

## Shows the prompt with the current floor numbers and heal amount.
func show_descend(p_floor: int, p_total: int, p_heal: int) -> void:
	visible = true
	_title.text = "Stairwell found"
	_summary.text = "Floor %d of %d complete.\nCoins and health carry over.\nKeys reset. Descending heals %d HP." % [
		p_floor + 1, p_total, p_heal,
	]
	_descend_button.grab_focus()

func hide_descend() -> void:
	visible = false

func _unhandled_input(p_event: InputEvent) -> void:
	if visible and p_event.is_action_pressed("pause"):
		stay_requested.emit()
		get_viewport().set_input_as_handled()

func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.8)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(400, 0)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)

	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 36)

	_summary = Label.new()
	_summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_summary.add_theme_font_size_override("font_size", 15)

	_descend_button = Button.new()
	_descend_button.text = "Descend"
	_descend_button.custom_minimum_size = Vector2(0, 36)

	_stay_button = Button.new()
	_stay_button.text = "Stay on this floor"
	_stay_button.custom_minimum_size = Vector2(0, 36)

	box.add_child(_title)
	box.add_child(_summary)
	box.add_child(_descend_button)
	box.add_child(_stay_button)

	margin.add_child(box)
	panel.add_child(margin)
	center.add_child(panel)
	add_child(center)

	_descend_button.pressed.connect(func() -> void: descend_requested.emit())
	_stay_button.pressed.connect(func() -> void: stay_requested.emit())
