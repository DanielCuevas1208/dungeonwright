class_name MenuOverlay
extends Control
## The main menu and pause overlay.
##
## The hero enters a seed to replay a run, or asks for a random one.
## The same overlay pauses the game when the hero presses Escape.

signal start_requested(seed_text: String)
signal continue_requested
signal clear_history_requested

const SHOWCASE_SCENE := preload('res://scenes/ui/showcase.tscn')

var _seed_edit: LineEdit = null
var _continue_button: Button = null
var _history_button: Button = null
var _gallery_button: Button = null
var _showcase_button: Button = null
var _error_label: Label = null
var _hint_label: Label = null
var _gallery: BiomeGallery = null
var _showcase: ShowcaseOverlay = null
var _menu_center: CenterContainer = null
var _history_center: CenterContainer = null
var _history_label: Label = null
var _history_clear_button: Button = null
var _history_back_button: Button = null
var _history: RunHistory = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

func show_menu(p_can_continue: bool, p_history: RunHistory = null) -> void:
	if p_history != null:
		set_history(p_history)
	_close_history()
	if _gallery != null:
		_gallery.close()
	if _showcase != null:
		_showcase.close()
	visible = true
	_continue_button.visible = p_can_continue
	_seed_edit.text = ""
	_error_label.text = ""
	_seed_edit.grab_focus()

func hide_menu() -> void:
	if _gallery != null:
		_gallery.close()
	if _showcase != null:
		_showcase.close()
	_close_history()
	visible = false

## Supplies the shared versioned history store used by the main controller.
func set_history(p_history: RunHistory) -> void:
	_history = p_history
	_refresh_history()

## Shows a validation message under the seed field.
func show_error(p_text: String) -> void:
	_error_label.text = p_text

func _unhandled_input(p_event: InputEvent) -> void:
	if _history_center != null and _history_center.visible:
		if p_event.is_action_pressed("pause"):
			_close_history()
			get_viewport().set_input_as_handled()
		return

	if _gallery != null:
		if _gallery.visible:
			return
	if _showcase != null:
		if _showcase.visible:
			return
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
	_menu_center = center
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
	_history_button = Button.new()
	_gallery_button = Button.new()
	_gallery_button.text = 'Browse biomes'
	_gallery_button.custom_minimum_size = Vector2(0, 36)
	_showcase_button = Button.new()
	_showcase_button.text = 'View showcase'
	_showcase_button.custom_minimum_size = Vector2(0, 36)
	_continue_button.text = "Continue"
	_continue_button.custom_minimum_size = Vector2(0, 36)
	_history_button.text = "View run history"
	_history_button.custom_minimum_size = Vector2(0, 36)

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
	box.add_child(_history_button)
	box.add_child(_continue_button)
	box.add_child(_gallery_button)
	box.add_child(_showcase_button)
	box.add_child(_hint_label)

	margin.add_child(box)
	panel.add_child(margin)
	center.add_child(panel)
	add_child(center)

	start_button.pressed.connect(_on_start_pressed)
	_history_button.pressed.connect(_open_history)
	_continue_button.pressed.connect(func() -> void: continue_requested.emit())
	_gallery_button.pressed.connect(_open_gallery)
	_showcase_button.pressed.connect(_open_showcase)
	_gallery = BiomeGallery.new()
	add_child(_gallery)
	_showcase = SHOWCASE_SCENE.instantiate()
	_showcase.closed.connect(_on_showcase_closed)
	_showcase.play_requested.connect(_on_showcase_play_requested)
	add_child(_showcase)
	_build_history_view()
	_seed_edit.text_submitted.connect(func(_text: String) -> void: _on_start_pressed())

func _build_history_view() -> void:
	_history_center = CenterContainer.new()
	_history_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_history_center.visible = false
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(620, 0)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)

	var title := Label.new()
	title.text = "Run history"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color("#e4b86a"))

	var subtitle := Label.new()
	subtitle.text = "Completed runs stay on this computer. Opening this view does not start a run."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", Color("#92a4b5"))

	_history_label = Label.new()
	_history_label.text = "No completed runs saved."
	_history_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_history_label.add_theme_font_size_override("font_size", 14)
	_history_label.add_theme_color_override("font_color", Color("#d7e0e8"))

	_history_clear_button = Button.new()
	_history_clear_button.text = "Clear saved history"
	_history_clear_button.custom_minimum_size = Vector2(0, 34)

	_history_back_button = Button.new()
	_history_back_button.text = "Back to main menu"
	_history_back_button.custom_minimum_size = Vector2(0, 36)

	box.add_child(title)
	box.add_child(subtitle)
	box.add_child(_history_label)
	box.add_child(_history_clear_button)
	box.add_child(_history_back_button)
	margin.add_child(box)
	panel.add_child(margin)
	_history_center.add_child(panel)
	add_child(_history_center)

	_history_clear_button.pressed.connect(_confirm_clear_history)
	_history_back_button.pressed.connect(_close_history)

func _open_history() -> void:
	_refresh_history()
	_menu_center.visible = false
	_history_center.visible = true
	_history_back_button.grab_focus()

func _close_history() -> void:
	if _history_center == null:
		return
	_history_center.visible = false
	_menu_center.visible = true
	if _history_button != null and visible:
		_history_button.grab_focus()

func _refresh_history() -> void:
	if _history_label == null:
		return
	if _history == null:
		_history_label.text = "No completed runs saved."
		_history_clear_button.visible = false
		return
	_history_label.text = _history.format_records()
	_history_clear_button.visible = not _history.is_empty()

func _on_start_pressed() -> void:
	start_requested.emit(_seed_edit.text)

func _open_gallery() -> void:
	if _showcase != null:
		_showcase.close()
	_gallery.open()

func _open_showcase() -> void:
	if _gallery != null:
		_gallery.close()
	_showcase.open()

func _on_showcase_closed() -> void:
	_seed_edit.grab_focus()

func _on_showcase_play_requested(p_seed_text: String) -> void:
	start_requested.emit(p_seed_text)

func _confirm_clear_history() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = "Clear saved history?"
	dialog.dialog_text = "Remove the five saved run records from this computer?"
	dialog.ok_button_text = "Clear"
	dialog.cancel_button_text = "Keep records"
	dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	dialog.confirmed.connect(func() -> void:
		clear_history_requested.emit()
		dialog.queue_free()
	)
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered()
