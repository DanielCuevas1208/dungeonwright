class_name TransitionOverlay
extends Control
## A brief full-screen message for floor changes.
##
## The overlay fades in, holds, and fades out on its own. The caller only
## adds it to the tree; it frees itself when the tween finishes.

const FADE_IN := 0.18
const HOLD := 0.7
const FADE_OUT := 0.4

## Shows a message and returns. The overlay frees itself.
static func play(p_parent: Node, p_title: String, p_subtitle: String) -> void:
	var overlay := TransitionOverlay.new()
	p_parent.add_child(overlay)
	overlay._show(p_title, p_subtitle)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()

func _show(p_title: String, p_subtitle: String) -> void:
	var dim: ColorRect = $Dim
	var title: Label = $Center/Box/Title
	var subtitle: Label = $Center/Box/Subtitle
	title.text = p_title
	subtitle.text = p_subtitle
	dim.modulate.a = 0.0
	title.modulate.a = 0.0
	subtitle.modulate.a = 0.0

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(dim, "modulate:a", 0.6, FADE_IN)
	tween.parallel().tween_property(title, "modulate:a", 1.0, FADE_IN)
	tween.parallel().tween_property(subtitle, "modulate:a", 1.0, FADE_IN)
	tween.tween_interval(HOLD)
	tween.tween_property(dim, "modulate:a", 0.0, FADE_OUT)
	tween.parallel().tween_property(title, "modulate:a", 0.0, FADE_OUT)
	tween.parallel().tween_property(subtitle, "modulate:a", 0.0, FADE_OUT)
	tween.tween_callback(queue_free)

func _build() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var dim := ColorRect.new()
	dim.name = "Dim"
	dim.color = Color(0.02, 0.02, 0.05, 0.6)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center := CenterContainer.new()
	center.name = "Center"
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	var box := VBoxContainer.new()
	box.name = "Box"
	box.add_theme_constant_override("separation", 8)

	var title := Label.new()
	title.name = "Title"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)

	var subtitle := Label.new()
	subtitle.name = "Subtitle"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)

	box.add_child(title)
	box.add_child(subtitle)
	center.add_child(box)
	add_child(center)
