class_name MenuOverlay
extends Control
## The main menu and pause overlay.
##
## The hero enters a seed to replay a run, or asks for a random one.
## The same overlay pauses the game when the hero presses Escape.

signal start_requested(seed_text: String)
signal continue_requested

var _seed_edit: LineEdit = null
var _continue_button: Button = null
var _error_label: Label = null
var _hint_label: Label = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

func show_menu(p_can_continue: bool) -> void:
	visible = true
	_continue_button.visible = p_can_continue
	_seed_edit.text = ""
	_error_label.text = ""
	_seed_edit.grab_focus()

func hide_menu() -> void:
	visible = false

## Shows a validation message under the seed field.
func show_error(p_text: String) -> void:
	_error_label.text = p_text

func _unhandled_input(p_event: InputEvent) -> void:
	if visible and p_event.is_action_pressed("pause"):
		continue_requested.emit()
		get_viewport().set_input_as_handled()

## Refreshes the control hints when a gamepad connects or disconnects.
func _on_joy_connection_changed(_p_device: int, _p_connected: bool) -> void:
	if _hint_label != null:
		_hint_label.text = Controls.hint_text()

func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.75)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(420, 0)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)

	var title := Label.new()
	title.text = "Dungeonwright"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)

	var subtitle := Label.new()
	subtitle.text = "Descend three floors. Every run builds a new dungeon from its seed."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_font_size_override("font_size", 14)

	_seed_edit = LineEdit.new()
	_seed_edit.placeholder_text = "Seed (optional, letters and digits)"
	_seed_edit.max_length = 6
	_seed_edit.tooltip_text = "Leave empty for a random seed"

	_error_label = Label.new()
	_error_label.add_theme_color_override("font_color", Color("#e07070"))
	_error_label.add_theme_font_size_override("font_size", 13)
	_error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var start_button := Button.new()
	start_button.text = "Start new run"
	start_button.custom_minimum_size = Vector2(0, 36)

	_continue_button = Button.new()
	_continue_button.text = "Continue"
	_continue_button.custom_minimum_size = Vector2(0, 36)

	_hint_label = Label.new()
	_hint_label.text = Controls.hint_text()
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint_label.add_theme_font_size_override("font_size", 13)

	box.add_child(title)
	box.add_child(subtitle)
	box.add_child(_seed_edit)
	box.add_child(_error_label)
	box.add_child(start_button)
	box.add_child(_continue_button)
	box.add_child(_hint_label)

	margin.add_child(box)
	panel.add_child(margin)
	center.add_child(panel)
	add_child(center)

	start_button.pressed.connect(_on_start_pressed)
	_continue_button.pressed.connect(func() -> void: continue_requested.emit())
	_seed_edit.text_submitted.connect(func(_text: String) -> void: _on_start_pressed())

func _on_start_pressed() -> void:
	start_requested.emit(_seed_edit.text)
