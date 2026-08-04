class_name BiomeGallery
extends Control

signal closed

const PREVIEW_SEED_START := 731
const PREVIEW_SEED_STEP := 137
const PREVIEW_TILE_SIZE := 4

var _page := 0
var _title: Label = null
var _description: Label = null
var _details: Label = null
var _page_label: Label = null
var _preview: TextureRect = null
var _swatches: HBoxContainer = null
var _threats: HBoxContainer = null
var _previous_button: Button = null
var _next_button: Button = null
var _close_button: Button = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = false
	_build()

## Opens the gallery on the first biome.
func open() -> void:
	_page = 0
	_render_page()
	visible = true
	_close_button.grab_focus()

## Closes the gallery.
func close() -> void:
	if not visible:
		return
	visible = false
	closed.emit()

## Generates the deterministic preview shown for a biome.
static func preview_result(p_index: int) -> DungeonResult:
	var biomes := Biomes.all()
	var index := clampi(p_index, 0, biomes.size() - 1)
	return DungeonGenerator.new().generate(biomes[index], preview_seed(index))

## Formats the generation rules for the gallery details line.
static func details_text(p_config: DungeonConfig) -> String:
	var style := String(p_config.corridor_style).capitalize()
	return 'Map {width} x {height} / {style} corridors / {rooms} rooms / {loops} percent loops'.format({
		'width': p_config.width,
		'height': p_config.height,
		'style': style,
		'rooms': str(p_config.room_count_min) + '-' + str(p_config.room_count_max),
		'loops': roundi(p_config.loop_chance * 100.0),
	})

## Returns the stable seed used for a biome preview.
static func preview_seed(p_index: int) -> int:
	return PREVIEW_SEED_START + maxi(p_index, 0) * PREVIEW_SEED_STEP

func _unhandled_input(p_event: InputEvent) -> void:
	if not visible:
		return
	if p_event.is_action_pressed('ui_cancel') or p_event.is_action_pressed('pause'):
		close()
		get_viewport().set_input_as_handled()
	elif p_event.is_action_pressed('ui_left'):
		_previous_page()
		get_viewport().set_input_as_handled()
	elif p_event.is_action_pressed('ui_right'):
		_next_page()
		get_viewport().set_input_as_handled()

func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.015, 0.02, 0.03, 0.96)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override('margin_left', 34)
	margin.add_theme_constant_override('margin_right', 34)
	add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override('separation', 10)
	margin.add_child(column)

	var header := HBoxContainer.new()
	var heading := Label.new()
	heading.text = 'Biome gallery'
	header.add_child(heading)
	var header_space := Control.new()
	header_space.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(header_space)
	_close_button = Button.new()
	_close_button.text = 'Back'
	_close_button.custom_minimum_size = Vector2(120, 34)
	_close_button.pressed.connect(close)
	header.add_child(_close_button)
	column.add_child(header)
	var intro := Label.new()
	intro.text = 'Regions and threats'
	intro.add_theme_font_size_override('font_size', 14)
	column.add_child(intro)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_previous_button = _nav_button('Prev')
	_previous_button.pressed.connect(_previous_page)
	body.add_child(_previous_button)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(content)

	var title_bar := HBoxContainer.new()
	_title = Label.new()
	_title.add_theme_font_size_override('font_size', 25)
	title_bar.add_child(_title)
	_page_label = Label.new()
	_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var title_space := Control.new()
	title_space.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_bar.add_child(title_space)
	title_bar.add_child(_page_label)
	content.add_child(title_bar)

	_description = Label.new()
	_description.add_theme_font_size_override('font_size', 14)
	_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_description)

	_preview = TextureRect.new()
	_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_preview.custom_minimum_size = Vector2(520, 270)
	content.add_child(_preview)

	_details = Label.new()
	_details.add_theme_font_size_override('font_size', 14)
	_details.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(_details)

	var palette_label := Label.new()
	palette_label.text = 'Palette'
	content.add_child(palette_label)
	_swatches = HBoxContainer.new()
	_swatches.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_child(_swatches)
	var threats_label := Label.new()
	threats_label.text = 'Common threats'
	content.add_child(threats_label)
	_threats = HBoxContainer.new()
	_threats.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_child(_threats)

	_next_button = _nav_button('Next')
	_next_button.pressed.connect(_next_page)
	body.add_child(_next_button)
	column.add_child(body)

func _render_page() -> void:
	var biomes := Biomes.all()
	if biomes.is_empty():
		return
	_page = clampi(_page, 0, biomes.size() - 1)
	var config: DungeonConfig = biomes[_page]
	var result := preview_result(_page)
	_title.text = config.display_name
	_title.add_theme_color_override('font_color', Color(config.palette.get(StringName('accent'), Color.WHITE)))
	_description.text = config.description
	_details.text = details_text(config)
	_page_label.text = 'Page {page} of {count}'.format({
		'page': _page + 1,
		'count': biomes.size(),
	})
	_preview.texture = ImageTexture.create_from_image(_preview_image(result, config))
	_render_swatches(config)
	_render_threats(config)
	_previous_button.disabled = _page == 0
	_next_button.disabled = _page == biomes.size() - 1

func _render_swatches(p_config: DungeonConfig) -> void:
	_clear_children(_swatches)
	for role in [StringName('wall_fill'), StringName('floor_base'), StringName('accent'), StringName('glow')]:
		var swatch := ColorRect.new()
		swatch.color = Color(p_config.palette.get(role, Color.WHITE))
		swatch.custom_minimum_size = Vector2(52, 10)
		_swatches.add_child(swatch)

func _render_threats(p_config: DungeonConfig) -> void:
	_clear_children(_threats)
	for entry in p_config.monster_table:
		var spec := MonsterSpecs.by_id(entry.monster)
		var item := VBoxContainer.new()
		var icon := TextureRect.new()
		icon.texture = TileArt.entity_texture(StringName(spec.sprite_key))
		icon.custom_minimum_size = Vector2(30, 30)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		item.add_child(icon)
		var label := Label.new()
		label.text = spec.display_name
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		item.add_child(label)
		_threats.add_child(item)

func _preview_image(p_result: DungeonResult, p_config: DungeonConfig) -> Image:
	var image := Image.create(p_result.map.width, p_result.map.height, false, Image.FORMAT_RGBA8)
	var wall := Color(p_config.palette.get(StringName('wall_fill'), Color.BLACK))
	var floor := Color(p_config.palette.get(StringName('floor_base'), Color.WHITE))
	var door := Color(p_config.palette.get(StringName('accent'), Color.WHITE))
	var glow := Color(p_config.palette.get(StringName('glow'), Color.WHITE))
	for x in p_result.map.width:
		for y in p_result.map.height:
			var cell := Vector2i(x, y)
			var color := wall
			match p_result.map.get_tile_cell(cell):
				DungeonMap.Tile.FLOOR:
					color = floor
				DungeonMap.Tile.DOOR_LOCKED, DungeonMap.Tile.DOOR_OPEN:
					color = door
				DungeonMap.Tile.START:
					color = door
				DungeonMap.Tile.EXIT:
					color = glow
			image.set_pixel(x, y, color)
	image.resize(image.get_width() * PREVIEW_TILE_SIZE, image.get_height() * PREVIEW_TILE_SIZE, Image.INTERPOLATE_NEAREST)
	return image

func _previous_page() -> void:
	_page = maxi(_page - 1, 0)
	_render_page()

func _next_page() -> void:
	_page = mini(_page + 1, Biomes.all().size() - 1)
	_render_page()

func _nav_button(p_text: String) -> Button:
	var button := Button.new()
	button.text = p_text
	button.custom_minimum_size = Vector2(54, 0)
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return button

func _clear_children(p_parent: Node) -> void:
	for child in p_parent.get_children():
		child.queue_free()
