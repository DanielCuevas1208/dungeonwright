class_name TileArt
extends RefCounted
## Generates all game art from small pixel patterns at run time.
##
## Tile art is drawn from 8x8 patterns and scaled to 16x16. The biome
## palette recolors tiles, while entities use fixed colors. This gives
## every biome a distinct look without shipping any image assets.

const SIZE := 16
const SOURCE := 8

const TILE_WALL := &"wall"
const TILE_FLOOR_A := &"floor_a"
const TILE_FLOOR_B := &"floor_b"
const TILE_DOOR_LOCKED := &"door_locked"
const TILE_DOOR_OPEN := &"door_open"
const TILE_START := &"start"
const TILE_EXIT := &"exit"

const ENTITY_KEYS := [
	&"player", &"key", &"potion", &"coin",
	&"skeleton", &"crawler", &"wisp", &"shambler", &"golem",
	&"bonecaster", &"spitter", &"slinger",
	&"bolt", &"spit", &"ember",
]

static var _tile_cache: Dictionary = {}
static var _entity_cache: Dictionary = {}

## Builds the tile textures for a biome palette.
static func build_tile_textures(p_palette: Dictionary) -> Dictionary:
	var key := str(p_palette.hash())
	if _tile_cache.has(key):
		return _tile_cache[key]

	var palette_roles := {
		"w": &"wall_outline", "+": &"wall_highlight", "@": &"wall_fill",
		"=": &"wall_shade", ".": &"floor_base", ":": &"floor_dark",
		"'": &"floor_light", "|": &"door_bar", "o": &"door_lock",
		"g": &"glow", "0": &"rune", "#": &"wall_shade",
	}
	var textures := {
		TILE_WALL: _from_pattern(_WALL, p_palette, palette_roles),
		TILE_FLOOR_A: _from_pattern(_FLOOR_A, p_palette, palette_roles),
		TILE_FLOOR_B: _from_pattern(_FLOOR_B, p_palette, palette_roles),
		TILE_DOOR_LOCKED: _from_pattern(_DOOR_LOCKED, p_palette, palette_roles),
		TILE_DOOR_OPEN: _from_pattern(_DOOR_OPEN, p_palette, palette_roles),
		TILE_START: _from_pattern(_START, p_palette, palette_roles),
		TILE_EXIT: _from_pattern(_EXIT, p_palette, palette_roles),
	}
	_tile_cache[key] = textures
	return textures

## Returns the sprite texture for an entity key.
static func entity_texture(p_key: StringName) -> Texture2D:
	if _entity_cache.has(p_key):
		return _entity_cache[p_key]
	var texture := _from_pattern(_entity_pattern(p_key), _entity_palette(p_key), _ENTITY_ROLES)
	_entity_cache[p_key] = texture
	return texture

## True when the key names a known entity sprite.
static func has_entity(p_key: StringName) -> bool:
	return ENTITY_KEYS.has(p_key)

static func _from_pattern(p_pattern: Array, p_colors: Dictionary, p_roles: Dictionary) -> Texture2D:
	var image := Image.create(SOURCE, SOURCE, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	for y in SOURCE:
		var row := String(p_pattern[y])
		for x in SOURCE:
			var glyph := row[x]
			if glyph == " ":
				continue
			var role: StringName = p_roles.get(glyph, &"wall_fill")
			var color: Color = p_colors.get(role, Color.WHITE)
			image.set_pixel(x, y, color)
	image.resize(SIZE, SIZE, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(image)

static func _entity_pattern(p_key: StringName) -> Array:
	match p_key:
		&"player":
			return _PLAYER
		&"skeleton":
			return _SKELETON
		&"crawler":
			return _CRAWLER
		&"wisp":
			return _WISP
		&"shambler":
			return _SHAMBLER
		&"golem":
			return _GOLEM
		&"bonecaster":
			return _BONECASTER
		&"spitter":
			return _SPITTER
		&"slinger":
			return _SLINGER
		&"bolt":
			return _BOLT
		&"spit":
			return _SPIT
		&"ember":
			return _EMBER
		&"key":
			return _KEY
		&"potion":
			return _POTION
		&"coin":
			return _COIN
		_:
			return _PLAYER

static func _entity_palette(p_key: StringName) -> Dictionary:
	match p_key:
		&"player":
			return {
				&"o": Color("#7a4a2b"), &"@": Color("#3d6bb5"),
				&"#": Color("#2a2a35"), &"*": Color("#e8b48c"),
			}
		&"skeleton":
			return { &"@": Color("#d9d2c0"), &"*": Color("#1a1a1a") }
		&"crawler":
			return { &"@": Color("#b06a3a"), &"*": Color("#2a1408"), &"+": Color("#d08a4a") }
		&"wisp":
			return { &"@": Color("#9fe8ff"), &"*": Color("#e8fbff"), &"+": Color("#6ab8d9") }
		&"shambler":
			return { &"@": Color("#4f7a3f"), &"*": Color("#16240f"), &"+": Color("#6f9a58") }
		&"golem":
			return { &"@": Color("#8a6a52"), &"*": Color("#2a1f18"), &"+": Color("#b09070") }
		&"bonecaster":
			return { &"@": Color("#c9b89a"), &"*": Color("#7a5a3a"), &"+": Color("#e8e0cc") }
		&"spitter":
			return { &"@": Color("#7ab84c"), &"*": Color("#2a4a1a"), &"+": Color("#a8d86a") }
		&"slinger":
			return { &"@": Color("#d86a3a"), &"*": Color("#3a1a10"), &"+": Color("#f09058") }
		&"bolt":
			return { &"@": Color("#9fb4c9"), &"*": Color("#e8f4ff") }
		&"spit":
			return { &"@": Color("#7ab84c"), &"*": Color("#e8ffb0") }
		&"ember":
			return { &"@": Color("#d86a3a"), &"*": Color("#ffe8b0"), &"+": Color("#f0a050") }
		&"key":
			return { &"o": Color("#e8b84c"), &"@": Color("#b8860b"), &"+": Color("#fff0b0") }
		&"potion":
			return { &"@": Color("#c94a4a"), &"+": Color("#e88a7a"), &"o": Color("#3a1a1a") }
		&"coin":
			return { &"@": Color("#e8b84c"), &"+": Color("#fff0b0") }
		_:
			return { &"@": Color.WHITE }

const _ENTITY_ROLES := {
	"o": &"o", "@": &"@", "#": &"#",
	"*": &"*", "+": &"+",
}

const _WALL := [
	"wwwwwwww",
	"w++++++w",
	"w+@@@@+w",
	"w+@@@@+w",
	"w+@@@@+w",
	"w+@@@@+w",
	"w+====+w",
	"wwwwwwww",
]

const _FLOOR_A := [
	"........",
	":..'..:.",
	"...:....",
	"..'..'..",
	":....:..",
	"....'...",
	"..:.....",
	"........",
]

const _FLOOR_B := [
	"........",
	"....:...",
	".'.....'",
	".....:..",
	"........",
	":....'..",
	"..'.....",
	"........",
]

const _DOOR_LOCKED := [
	"wwwwwwww",
	"w||||||w",
	"w|o||o|w",
	"w||||||w",
	"w|o||o|w",
	"w||||||w",
	"w|o||o|w",
	"wwwwwwww",
]

const _DOOR_OPEN := [
	"wwwwwwww",
	"w......w",
	"w......w",
	"w......w",
	"w......w",
	"w......w",
	"w......w",
	"wwwwwwww",
]

const _START := [
	"........",
	"..++++..",
	".+'..'+.",
	".'..0..'",
	".'..0..'",
	".+'..'+.",
	"..++++..",
	"........",
]

const _EXIT := [
	"........",
	"..gggg..",
	".g'00'g.",
	".g0..0g.",
	".g0..0g.",
	".g'00'g.",
	"..gggg..",
	"........",
]

const _PLAYER := [
	"..oo....",
	"..o@o...",
	"...@@...",
	"..@@@...",
	".*@@@@..",
	"..@@@@..",
	"..@##@..",
	"..oo....",
]

const _SKELETON := [
	"..@@@...",
	".@@*@@..",
	".@@*@@..",
	"...@@...",
	"..@@@@..",
	".@@..@@.",
	".@@..@@.",
	"........",
]

const _CRAWLER := [
	"........",
	"..@@@...",
	".@*@*@..",
	".@@@@@..",
	".@@@@@@.",
	".@@..@@.",
	"........",
	"........",
]

const _WISP := [
	"........",
	"..**....",
	".****...",
	".@@@@@..",
	".@@@@@..",
	"..@@@...",
	"...@....",
	"........",
]

const _SHAMBLER := [
	"..@@@...",
	".@@@@@..",
	".@@*@@..",
	".@*@*@..",
	".@@@@@..",
	".@.@.@..",
	"........",
	"........",
]

const _GOLEM := [
	".@@@@...",
	"@@@@@@..",
	"@@@@@@..",
	".@@@@@..",
	".@@@.@@.",
	".@@.@.@.",
	"........",
	"........",
]

const _BONECASTER := [
	"..@@@...",
	".@*+*@..",
	".@@*@@..",
	"...@@...",
	"..@@@@..",
	".@..@@@.",
	".@.@@@@.",
	"........",
]

const _SPITTER := [
	"........",
	"..@@@...",
	".@+@+@..",
	".@@@@@@.",
	".@@*@@@.",
	".@@@@@@.",
	"..@@@@..",
	"........",
]

const _SLINGER := [
	"..@@@...",
	".@+++@..",
	".@@@@@@.",
	".@@*@@@.",
	".@@@@@@.",
	".@@@@@@.",
	"..@@@...",
	"........",
]

const _BOLT := [
	"........",
	"...@@...",
	"..@@@@..",
	".@@@@@@.",
	"..@@@@..",
	"...@@...",
	"........",
	"........",
]

const _SPIT := [
	"........",
	"..@@@...",
	".@@@@@..",
	".@@@@@@.",
	".@@@@@@.",
	".@@@@@@.",
	".@@@@@..",
	"........",
]

const _EMBER := [
	"........",
	"...@@...",
	"..@++@..",
	"..@@@@..",
	".@+@@+@.",
	".@@@@@@.",
	"..@@@@..",
	"........",
]

const _KEY := [
	"........",
	"...oooo.",
	"..ooooo.",
	".ooooo..",
	"ooooo...",
	"..oo....",
	"..oo....",
	"........",
]

const _POTION := [
	"...@@...",
	"...@@...",
	"..@@@@..",
	".+@@@@@.",
	".@@@@@@.",
	".@@@@@@.",
	"..@@@@..",
	"........",
]

const _COIN := [
	"........",
	".@@@@@@.",
	".@@@@@@.",
	".@+@@+@.",
	".@+@@+@.",
	".@@@@@@.",
	".@@@@@@.",
	"........",
]
