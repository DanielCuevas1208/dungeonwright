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
	&"player", &"key", &"potion", &"coin", &"shard", &"bomb",
	&"skeleton", &"crawler", &"wisp", &"shambler", &"golem",
	&"archer", &"wraith", &"warden", &"bolt", &"relic", &"emblem",
	&"aegis",
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
		&"archer":
			return _ARCHER
		&"wraith":
			return _WRAITH
		&"warden":
			return _WARDEN
		&"bolt":
			return _BOLT
		&"relic":
			return _RELIC
		&"emblem":
			return _EMBLEM
		&"aegis":
			return _AEGIS
		&"key":
			return _KEY
		&"shard":
			return _SHARD
		&"bomb":
			return _BOMB
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
		&"archer":
			return { &"@": Color("#d9d2c0"), &"*": Color("#1a1a1a"), &"+": Color("#5a3a20") }
		&"wraith":
			return { &"@": Color("#9fd8ef"), &"*": Color("#dffaff"), &"+": Color("#5a8aa0") }
		&"warden":
			return { &"@": Color("#5a2a2a"), &"*": Color("#e8d8b0"), &"o": Color("#e8b84c"), &"+": Color("#8a4a3a") }
		&"bolt":
			return { &"@": Color("#e8b84c"), &"+": Color("#fff0b0") }
		&"relic":
			return { &"@": Color("#8a6ad9"), &"*": Color("#f0e8ff"), &"o": Color("#e8b84c"), &"+": Color("#b49ae8") }
		&"emblem":
			return { &"@": Color("#4a7ab5"), &"o": Color("#e8b84c"), &"+": Color("#dff0ff") }
		&"aegis":
			return { &"@": Color("#208060"), &"o": Color("#e8b84c"), &"+": Color("#7fffd4"), &"*": Color("#ffffff") }
		&"key":
			return { &"o": Color("#e8b84c"), &"@": Color("#b8860b"), &"+": Color("#fff0b0") }
		&"shard":
			return { &"@": Color("#6ac8ff"), &"+": Color("#dff4ff"), &"*": Color("#2a6a9a") }
		&"potion":
			return { &"@": Color("#c94a4a"), &"+": Color("#e88a7a"), &"o": Color("#3a1a1a") }
		&"bomb":
			return { &"@": Color("#3a3a44"), &"+": Color("#8a8a94"), &"o": Color("#e8b84c") }
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

const _ARCHER := [
	"..@@@@..",
	".@@*@@..",
	"..@@@@..",
	"...@....",
	"..@@@@..",
	".@@..@@.",
	".@@...+.",
	"..@....+",
]

const _WRAITH := [
	"........",
	"..@@@@..",
	".@@*@@..",
	".@***@..",
	".@@@@@..",
	".@@.@@..",
	".@.@.@..",
	"........",
]

const _WARDEN := [
	"..*.....",
	"..*@@@..",
	".@@@@@@.",
	"@@o@@o@@",
	"@@@@@@@@",
	".@@@@@@.",
	".@@..@@.",
	"..@..@..",
]

const _BOLT := [
	"........",
	"........",
	"........",
	"......+.",
	".....@+.",
	"....@+..",
	".....@+.",
	"......+.",
]

const _RELIC := [
	"........",
	"..oooo..",
	".o@@@@o.",
	".o@++@o.",
	".o@**@o.",
	"..@@@@..",
	"...@@...",
	"........",
]

const _EMBLEM := [
	"..@@@@..",
	".@o++o@.",
	".@o++o@.",
	".@@@@@@.",
	".@+@@+@.",
	"..@@@@..",
	"...@@...",
	"........",
]

const _AEGIS := [
	".oooooo.",
	"o@@++@@o",
	"o@+**+@o",
	"o@+**+@o",
	".o@++@o.",
	"..o@@o..",
	"...oo...",
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

const _SHARD := [
	"........",
	"...@@...",
	"..@@@...",
	".+@@@+..",
	"..@@+...",
	"..@@....",
	"..@@....",
	"........",
]

const _BOMB := [
	"........",
	"...oo...",
	"..oooo..",
	".o@@@@o.",
	".o@@@@o.",
	".o@@o@o.",
	"..oooo..",
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
