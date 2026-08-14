class_name Hud
extends Control
## Heads-up display built at run time.
##
## Shows the biome, the seed, the exit depth, the health bar, the loot,
## and a minimap with the hero position.

var biome_label: Label = null
var seed_label: Label = null
var floor_label: Label = null
var hp_fill: ColorRect = null
var hp_label: Label = null
var coin_label: Label = null
var shard_label: Label = null
var bomb_label: Label = null
var key_label: Label = null
var emblem_label: Label = null
var aegis_label: Label = null
var minimap_texture: TextureRect = null
var minimap_marker: ColorRect = null
var _minimap_frame: PanelContainer = null
var _minimap_visible := true

var boss_fill: ColorRect = null
var boss_label: Label = null
var _boss_frame: Control = null
var _boss_name: String = ""

var _map_width := 1
var _map_height := 1
const MARKER_SCALE := 2.0
const BOSS_BAR_WIDTH := 360.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_top_panel()
	_build_bottom_panel()
	_build_boss_panel()
	_build_minimap()

## Shows the run context. The floor is a one-based counter.
func set_run(p_biome: String, p_seed: String, p_floor: int, p_floors: int) -> void:
	biome_label.text = "Biome: " + p_biome
	seed_label.text = "Seed: " + p_seed
	floor_label.text = "Floor %d of %d" % [p_floor + 1, p_floors]

func set_hp(p_current: int, p_max: int) -> void:
	if hp_fill == null:
		return
	var ratio := float(p_current) / float(maxi(p_max, 1))
	hp_fill.size.x = 200.0 * clampf(ratio, 0.0, 1.0)
	hp_label.text = "%d / %d" % [p_current, p_max]

func set_coins(p_count: int) -> void:
	coin_label.text = "x " + str(p_count)

func set_shards(p_count: int) -> void:
	shard_label.text = "x " + str(p_count)

func set_bombs(p_count: int) -> void:
	bomb_label.text = "x " + str(p_count)

func set_keys(p_count: int) -> void:
	key_label.text = "x " + str(p_count)

func set_emblems(p_count: int) -> void:
	emblem_label.text = "x " + str(p_count)

func set_aegis(p_count: int) -> void:
	aegis_label.text = "x " + str(p_count)

## Shows the boss bar and names the boss.
func show_boss(p_name: String) -> void:
	_boss_name = p_name
	_boss_frame.visible = true
	set_boss_hp(1, 1)

## Hides the boss bar, used when a boss floor ends.
func hide_boss() -> void:
	_boss_frame.visible = false

## Fills the boss bar for the current boss health.
func set_boss_hp(p_current: int, p_max: int) -> void:
	if boss_fill == null:
		return
	var ratio := float(p_current) / float(maxi(p_max, 1))
	boss_fill.size.x = BOSS_BAR_WIDTH * clampf(ratio, 0.0, 1.0)
	boss_label.text = "%s  %d / %d" % [_boss_name, p_current, p_max]

func set_minimap(p_image: Image, p_width: int, p_height: int) -> void:
	_map_width = p_width
	_map_height = p_height
	var texture := ImageTexture.create_from_image(p_image)
	minimap_texture.texture = texture
	minimap_texture.custom_minimum_size = Vector2(p_width * MARKER_SCALE, p_height * MARKER_SCALE)
	minimap_texture.size = minimap_texture.custom_minimum_size
	minimap_marker.position = Vector2(0, 0)

func update_marker(p_grid: Vector2i) -> void:
	minimap_marker.position = Vector2(p_grid.x * MARKER_SCALE, p_grid.y * MARKER_SCALE)

## Shows or hides the minimap.
func toggle_minimap() -> void:
	_minimap_visible = not _minimap_visible
	_minimap_frame.visible = _minimap_visible

func _build_top_panel() -> void:
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.position = Vector2(10, 10)
	panel.modulate = Color(1, 1, 1, 0.9)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	panel.add_child(box)
	biome_label = _label("", 15)
	seed_label = _label("", 15)
	floor_label = _label("", 15)
	box.add_child(biome_label)
	box.add_child(seed_label)
	box.add_child(floor_label)
	add_child(panel)

func _build_bottom_panel() -> void:
	var hp_panel := PanelContainer.new()
	hp_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	hp_panel.position = Vector2(10, -40)
	var hp_box := VBoxContainer.new()
	hp_panel.add_child(hp_box)

	var bar := Control.new()
	bar.custom_minimum_size = Vector2(200, 18)
	var bg := ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.12, 0.9)
	bg.size = Vector2(200, 18)
	hp_fill = ColorRect.new()
	hp_fill.color = Color(0.75, 0.2, 0.2)
	hp_fill.size = Vector2(200, 18)
	hp_label = Label.new()
	hp_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_label.add_theme_font_size_override("font_size", 12)
	bar.add_child(bg)
	bar.add_child(hp_fill)
	bar.add_child(hp_label)
	hp_box.add_child(bar)

	var loot_row := HBoxContainer.new()
	loot_row.add_theme_constant_override("separation", 18)
	loot_row.add_child(_icon_counter(&"coin"))
	loot_row.add_child(_icon_counter(&"shard"))
	loot_row.add_child(_icon_counter(&"bomb"))
	loot_row.add_child(_icon_counter(&"emblem"))
	loot_row.add_child(_icon_counter(&"aegis"))
	loot_row.add_child(_icon_counter(&"key"))
	hp_box.add_child(loot_row)
	add_child(hp_panel)

## A wide bar at the top of the screen that shows the boss health.
func _build_boss_panel() -> void:
	_boss_frame = Control.new()
	_boss_frame.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_boss_frame.offset_top = 10
	_boss_frame.offset_bottom = 52
	_boss_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_boss_frame.visible = false
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_boss_frame.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(BOSS_BAR_WIDTH, 0)
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	panel.add_child(box)

	var bar := Control.new()
	bar.custom_minimum_size = Vector2(BOSS_BAR_WIDTH, 16)
	var bg := ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.12, 0.9)
	bg.size = Vector2(BOSS_BAR_WIDTH, 16)
	boss_fill = ColorRect.new()
	boss_fill.color = Color(0.8, 0.3, 0.2)
	boss_fill.size = Vector2(BOSS_BAR_WIDTH, 16)
	boss_label = Label.new()
	boss_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_label.add_theme_font_size_override("font_size", 12)
	boss_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	boss_label.add_theme_constant_override("outline_size", 3)
	bar.add_child(bg)
	bar.add_child(boss_fill)
	bar.add_child(boss_label)
	box.add_child(bar)
	add_child(_boss_frame)

func _build_minimap() -> void:
	_minimap_frame = PanelContainer.new()
	_minimap_frame.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_minimap_frame.position = Vector2(-10, 10)
	_minimap_frame.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	minimap_texture = TextureRect.new()
	minimap_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	minimap_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	minimap_marker = ColorRect.new()
	minimap_marker.color = Color(1.0, 1.0, 1.0)
	minimap_marker.size = Vector2(MARKER_SCALE, MARKER_SCALE)
	minimap_texture.add_child(minimap_marker)
	_minimap_frame.add_child(minimap_texture)
	add_child(_minimap_frame)

func _icon_counter(p_icon: StringName) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	var icon := TextureRect.new()
	icon.texture = TileArt.entity_texture(p_icon)
	icon.custom_minimum_size = Vector2(16, 16)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var label := Label.new()
	label.add_theme_font_size_override("font_size", 15)
	row.add_child(icon)
	row.add_child(label)
	match p_icon:
		&"coin":
			coin_label = label
		&"shard":
			shard_label = label
		&"bomb":
			bomb_label = label
		&"emblem":
			emblem_label = label
		&"aegis":
			aegis_label = label
		&"key":
			key_label = label
	return row

func _label(p_text: String, p_size: int) -> Label:
	var label := Label.new()
	label.text = p_text
	label.add_theme_font_size_override("font_size", p_size)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("outline_size", 3)
	return label
