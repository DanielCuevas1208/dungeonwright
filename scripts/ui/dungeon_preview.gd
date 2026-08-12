class_name DungeonPreview
extends RefCounted
## Builds a small, deterministic image of a generated dungeon.
##
## The gallery and showcase use this renderer so preview colors stay aligned
## with the live biome palette.

const DEFAULT_TILE_SIZE := 4

static func render_image(
	p_result: DungeonResult,
	p_config: DungeonConfig,
	p_tile_size: int = DEFAULT_TILE_SIZE
) -> Image:
	var image := Image.create(p_result.map.width, p_result.map.height, false, Image.FORMAT_RGBA8)
	var wall := Color(p_config.palette.get(StringName('wall_fill'), Color.BLACK))
	var floor := Color(p_config.palette.get(StringName('floor_base'), Color.WHITE))
	var door := Color(p_config.palette.get(StringName('accent'), Color.WHITE))
	var glow := Color(p_config.palette.get(StringName('glow'), Color.WHITE))
	for x in p_result.map.width:
		for y in p_result.map.height:
			var color := wall
			match p_result.map.get_tile_cell(Vector2i(x, y)):
				DungeonMap.Tile.FLOOR:
					color = floor
				DungeonMap.Tile.DOOR_LOCKED, DungeonMap.Tile.DOOR_OPEN, DungeonMap.Tile.START:
					color = door
				DungeonMap.Tile.EXIT:
					color = glow
			image.set_pixel(x, y, color)
	var scale := maxi(p_tile_size, 1)
	image.resize(image.get_width() * scale, image.get_height() * scale, Image.INTERPOLATE_NEAREST)
	return image
