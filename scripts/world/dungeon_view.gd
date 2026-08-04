class_name DungeonView
extends Node2D
## Renders a DungeonMap into a TileMapLayer and converts between
## tile coordinates and world coordinates.

const TILE_SIZE := 16

var map: DungeonMap = null
var config: DungeonConfig = null

var _layer: TileMapLayer = null
var _tile_atlas: Dictionary = {}

## The atlas coordinates for each tile type.
const ATLAS_ORDER: Array = [
	[0, 0], [1, 0], [2, 0], [3, 0],
	[0, 1], [1, 1], [2, 1], [3, 1],
]

func _ready() -> void:
	_layer = TileMapLayer.new()
	_layer.name = "FloorTiles"
	add_child(_layer)

## Renders the given map using the biome palette.
func configure(p_map: DungeonMap, p_config: DungeonConfig) -> void:
	map = p_map
	config = p_config
	_build_tileset(p_config.palette)
	_layer.clear()
	for x in map.width:
		for y in map.height:
			_set_cell(Vector2i(x, y))
	_center_and_scale()

## Re-renders a single cell after the map changes.
func refresh_cell(p_cell: Vector2i) -> void:
	_set_cell(p_cell)

func tile_to_world(p_cell: Vector2i) -> Vector2:
	return Vector2(p_cell.x * TILE_SIZE + TILE_SIZE / 2.0, p_cell.y * TILE_SIZE + TILE_SIZE / 2.0)

func world_to_tile(p_world: Vector2) -> Vector2i:
	return Vector2i(floori(p_world.x / TILE_SIZE), floori(p_world.y / TILE_SIZE))

func is_walkable(p_cell: Vector2i) -> bool:
	return map != null and map.is_walkable_cell(p_cell)

## Returns the world-space rectangle the map occupies.
func map_rect() -> Rect2:
	if map == null:
		return Rect2()
	return Rect2(0, 0, map.width * TILE_SIZE, map.height * TILE_SIZE)

## Builds a minimap image of the whole map.
func build_minimap_image() -> Image:
	var palette := config.palette
	var image := Image.create(map.width * 2, map.height * 2, false, Image.FORMAT_RGBA8)
	var wall_color: Color = palette.get(&"wall_outline", Color.DARK_GRAY)
	var floor_color: Color = palette.get(&"floor_base", Color.GRAY)
	var door_color: Color = palette.get(&"door_lock", Color.GOLD)
	var start_color: Color = palette.get(&"rune", Color.CYAN)
	var exit_color: Color = palette.get(&"glow", Color.GREEN)
	for x in map.width:
		for y in map.height:
			var color := floor_color
			match map.get_tile(x, y):
				DungeonMap.Tile.WALL:
					color = wall_color
				DungeonMap.Tile.DOOR_LOCKED, DungeonMap.Tile.DOOR_OPEN:
					color = door_color
				DungeonMap.Tile.START:
					color = start_color
				DungeonMap.Tile.EXIT, DungeonMap.Tile.STAIRS:
					color = exit_color
			for dx in 2:
				for dy in 2:
					image.set_pixel(x * 2 + dx, y * 2 + dy, color)
	return image

func _build_tileset(p_palette: Dictionary) -> void:
	var textures := TileArt.build_tile_textures(p_palette)
	_tile_atlas = {}
	var atlas_image := Image.create(4 * TILE_SIZE, 2 * TILE_SIZE, false, Image.FORMAT_RGBA8)
	atlas_image.fill(Color(0, 0, 0, 0))
	var keys: Array = [
		TileArt.TILE_WALL, TileArt.TILE_FLOOR_A, TileArt.TILE_FLOOR_B,
		TileArt.TILE_DOOR_LOCKED, TileArt.TILE_DOOR_OPEN,
		TileArt.TILE_START, TileArt.TILE_EXIT, TileArt.TILE_STAIRS,
	]
	for i in keys.size():
		var tile_texture: Texture2D = textures[keys[i]]
		var position := Vector2i(ATLAS_ORDER[i][0] * TILE_SIZE, ATLAS_ORDER[i][1] * TILE_SIZE)
		atlas_image.blit_rect(tile_texture.get_image(), Rect2i(Vector2i.ZERO, Vector2i(TILE_SIZE, TILE_SIZE)), position)
		_tile_atlas[keys[i]] = Vector2i(ATLAS_ORDER[i][0], ATLAS_ORDER[i][1])

	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	var source := TileSetAtlasSource.new()
	source.texture = ImageTexture.create_from_image(atlas_image)
	source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	for atlas_coords in ATLAS_ORDER:
		source.create_tile(Vector2i(atlas_coords[0], atlas_coords[1]))
	tile_set.add_source(source, 0)
	_layer.tile_set = tile_set

func _set_cell(p_cell: Vector2i) -> void:
	var tile := map.get_tile_cell(p_cell)
	var atlas_coords: Vector2i = _atlas_for(tile)
	if tile == DungeonMap.Tile.FLOOR and (p_cell.x + p_cell.y) % 2 == 1:
		atlas_coords = _tile_atlas[TileArt.TILE_FLOOR_B]
	_layer.set_cell(p_cell, 0, atlas_coords)

func _atlas_for(p_tile: int) -> Vector2i:
	match p_tile:
		DungeonMap.Tile.WALL:
			return Vector2i(0, 0)
		DungeonMap.Tile.DOOR_LOCKED:
			return Vector2i(3, 0)
		DungeonMap.Tile.DOOR_OPEN:
			return Vector2i(0, 1)
		DungeonMap.Tile.START:
			return Vector2i(1, 1)
		DungeonMap.Tile.EXIT:
			return Vector2i(2, 1)
		DungeonMap.Tile.STAIRS:
			return Vector2i(3, 1)
		_:
			return Vector2i(1, 0)

func _center_and_scale() -> void:
	var bounds := map_rect()
	position = bounds.position
