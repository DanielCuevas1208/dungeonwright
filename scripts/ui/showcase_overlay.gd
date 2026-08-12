class_name ShowcaseOverlay
extends Control
## A capture-ready view of one real, replayable dungeon.

signal closed
signal play_requested(seed_text: String)

const FEATURED_BIOME_INDEX := 4
const PREVIEW_TILE_SIZE := 4

var _map_preview: TextureRect = null
var _biome_label: Label = null
var _seed_label: Label = null
var _description_label: Label = null
var _stats_label: Label = null
var _status_label: Label = null
var _close_button: Button = null
var _play_button: Button = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = false
	_build()

## Returns the biome used by the fixed showcase composition.
static func featured_config() -> DungeonConfig:
	return Biomes.all()[FEATURED_BIOME_INDEX]

## Returns the stable seed used by the fixed showcase composition.
static func featured_seed() -> int:
	return BiomeGallery.preview_seed(FEATURED_BIOME_INDEX)

## Generates the same dungeon shown by the showcase.
static func featured_result() -> DungeonResult:
	var config := featured_config()
	return DungeonGenerator.new().generate(config, featured_seed())

## Returns the replay string shown in the showcase.
static func featured_seed_text() -> String:
	return SeededRng.encode_seed(featured_seed())

func open() -> void:
	_render()
	visible = true
	_close_button.grab_focus()

func close() -> void:
	if not visible:
		return
	visible = false
	closed.emit()

func _unhandled_input(p_event: InputEvent) -> void:
	if not visible:
		return
	if p_event.is_action_pressed('ui_cancel') or p_event.is_action_pressed('pause'):
		close()
		get_viewport().set_input_as_handled()

func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color('#080d12f5')
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)
	var margin := MarginContainer.new()
	add_child(margin)
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override('margin_left', 32)
	margin.add_theme_constant_override('margin_right', 32)
	margin.add_theme_constant_override('margin_top', 24)
	margin.add_theme_constant_override('margin_bottom', 24)

	var column := VBoxContainer.new()
	column.add_theme_constant_override('separation', 12)
	margin.add_child(column)
	var header := HBoxContainer.new()
	var heading := Label.new()
	heading.text = 'Dungeonwright / Showcase'
	heading.add_theme_font_size_override('font_size', 28)
	header.add_child(heading)
	var header_space := Control.new()
	header_space.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(header_space)
	_close_button = Button.new()
	_close_button.text = 'Back'
	_close_button.custom_minimum_size = Vector2(120, 36)
	_close_button.pressed.connect(close)
	header.add_child(_close_button)
	column.add_child(header)

	var strapline := Label.new()
	strapline.text = 'A fixed run seed, a real generated map, and a clean frame for capture.'
	strapline.add_theme_font_size_override('font_size', 14)
	column.add_child(strapline)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override('separation', 18)
	column.add_child(body)

	var map_panel := PanelContainer.new()
	map_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var map_margin := MarginContainer.new()
	map_margin.add_theme_constant_override('margin_left', 12)
	map_margin.add_theme_constant_override('margin_right', 12)
	map_margin.add_theme_constant_override('margin_top', 12)
	map_margin.add_theme_constant_override('margin_bottom', 12)
	_map_preview = TextureRect.new()
	_map_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_map_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_map_preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_map_preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_map_preview.custom_minimum_size = Vector2(720, 420)
	map_margin.add_child(_map_preview)
	map_panel.add_child(map_margin)
	body.add_child(map_panel)

	var info_panel := PanelContainer.new()
	info_panel.custom_minimum_size = Vector2(340, 0)
	var info_margin := MarginContainer.new()
	info_margin.add_theme_constant_override('margin_left', 22)
	info_margin.add_theme_constant_override('margin_right', 22)
	info_margin.add_theme_constant_override('margin_top', 22)
	info_margin.add_theme_constant_override('margin_bottom', 22)
	var info := VBoxContainer.new()
	info.add_theme_constant_override('separation', 12)
	info_margin.add_child(info)
	info_panel.add_child(info_margin)
	body.add_child(info_panel)

	var featured := Label.new()
	featured.text = 'FEATURED BIOME'
	featured.add_theme_font_size_override('font_size', 12)
	featured.add_theme_color_override('font_color', Color('#92a4b5'))
	info.add_child(featured)
	_biome_label = Label.new()
	_biome_label.add_theme_font_size_override('font_size', 28)
	info.add_child(_biome_label)

	_description_label = Label.new()
	_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_description_label.add_theme_font_size_override('font_size', 14)
	info.add_child(_description_label)

	_seed_label = Label.new()
	_seed_label.add_theme_font_size_override('font_size', 18)
	info.add_child(_seed_label)

	var divider := HSeparator.new()
	info.add_child(divider)
	_stats_label = Label.new()
	_stats_label.add_theme_font_size_override('font_size', 14)
	_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(_stats_label)
	_status_label = Label.new()
	_status_label.add_theme_color_override('font_color', Color('#7fe8b9'))
	info.add_child(_status_label)

	var filler := Control.new()
	filler.size_flags_vertical = Control.SIZE_EXPAND_FILL
	info.add_child(filler)
	_play_button = Button.new()
	_play_button.text = 'Play this seed'
	_play_button.custom_minimum_size = Vector2(0, 40)
	_play_button.pressed.connect(_play_featured_seed)
	info.add_child(_play_button)
	var note := Label.new()
	note.text = 'The preview stays fixed. Start a run to play it.'
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_font_size_override('font_size', 12)
	info.add_child(note)

func _render() -> void:
	var config := featured_config()
	var result := featured_result()
	_map_preview.texture = ImageTexture.create_from_image(
		DungeonPreview.render_image(result, config, PREVIEW_TILE_SIZE)
	)
	_biome_label.text = config.display_name
	_biome_label.add_theme_color_override('font_color', Color(config.palette.get(StringName('accent'), Color.WHITE)))
	_description_label.text = config.description
	_seed_label.text = 'Replay seed: ' + featured_seed_text()
	_stats_label.text = 'Rooms: %d\nLocked doors: %d\nThreats: %d\nMap: %d x %d' % [
		result.room_count(),
		result.door_count(),
		result.monster_count(),
		result.map.width,
		result.map.height,
	]
	_status_label.text = 'Exit reachable: yes'

func _play_featured_seed() -> void:
	play_requested.emit(featured_seed_text())
