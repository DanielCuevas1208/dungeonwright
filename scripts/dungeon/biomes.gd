class_name Biomes
extends RefCounted
## Registry of the game's biomes.
##
## Each biome defines its own generation rules and palette. The dungeon
## generator reads the rules, and the tile renderer reads the palette.

## Returns every biome in a stable order.
static func all() -> Array[DungeonConfig]:
	return [crypt(), drowned_forest(), ember_stronghold()]

## Returns a copy of the biome with the given id.
static func by_id(p_id: StringName) -> DungeonConfig:
	for biome in all():
		if biome.id == p_id:
			return biome
	return crypt()

## Picks a biome using the given RNG.
static func random(p_rng: SeededRng) -> DungeonConfig:
	return all()[p_rng.next_int(all().size())]

static func crypt() -> DungeonConfig:
	var config := DungeonConfig.new()
	config.id = &"crypt"
	config.display_name = "Sunless Crypt"
	config.description = "Cold halls of cut stone. Straight elbows connect many small vaults."
	config.width = 46
	config.height = 30
	config.room_count_min = 8
	config.room_count_max = 11
	config.room_min = 5
	config.room_max = 9
	config.corridor_style = DungeonConfig.CorridorStyle.elbow
	config.loop_chance = 0.25
	config.door_count_min = 2
	config.door_count_max = 3
	config.monster_density = 0.5
	config.monster_cap = 10
	config.monster_table = [
		{ "monster": &"skeleton", "weight": 3.0 },
		{ "monster": &"crawler", "weight": 1.0 },
	]
	config.starting_health = 100
	config.player_damage = 12
	config.palette = _crypt_palette()
	return config

static func drowned_forest() -> DungeonConfig:
	var config := DungeonConfig.new()
	config.id = &"drowned_forest"
	config.display_name = "Drowned Forest"
	config.description = "Root-choked tunnels wind between vast, flooded clearings."
	config.width = 52
	config.height = 34
	config.room_count_min = 7
	config.room_count_max = 9
	config.room_min = 8
	config.room_max = 12
	config.corridor_style = DungeonConfig.CorridorStyle.winding
	config.loop_chance = 0.5
	config.door_count_min = 1
	config.door_count_max = 2
	config.monster_density = 0.4
	config.monster_cap = 9
	config.monster_table = [
		{ "monster": &"wisp", "weight": 2.0 },
		{ "monster": &"shambler", "weight": 2.0 },
		{ "monster": &"crawler", "weight": 1.0 },
	]
	config.starting_health = 100
	config.player_damage = 13
	config.palette = _forest_palette()
	return config

static func ember_stronghold() -> DungeonConfig:
	var config := DungeonConfig.new()
	config.id = &"ember_stronghold"
	config.display_name = "Ember Stronghold"
	config.description = "A fortress of burnt brick. Wide straight halls hold many locked gates."
	config.width = 48
	config.height = 30
	config.room_count_min = 10
	config.room_count_max = 14
	config.room_min = 5
	config.room_max = 8
	config.corridor_style = DungeonConfig.CorridorStyle.straight
	config.loop_chance = 0.15
	config.door_count_min = 3
	config.door_count_max = 4
	config.monster_density = 0.65
	config.monster_cap = 12
	config.monster_table = [
		{ "monster": &"golem", "weight": 2.0 },
		{ "monster": &"skeleton", "weight": 2.0 },
		{ "monster": &"shambler", "weight": 1.0 },
	]
	config.starting_health = 100
	config.player_damage = 14
	config.palette = _ember_palette()
	return config

static func _crypt_palette() -> Dictionary:
	return {
		&"wall_outline": Color("#14161d"),
		&"wall_fill": Color("#2b3040"),
		&"wall_shade": Color("#20242f"),
		&"wall_highlight": Color("#3d4458"),
		&"floor_base": Color("#232736"),
		&"floor_dark": Color("#1c1f2b"),
		&"floor_light": Color("#2d3243"),
		&"door_bar": Color("#4a5268"),
		&"door_lock": Color("#c9a34a"),
		&"door_open": Color("#0a0b10"),
		&"rune": Color("#7fd0d9"),
		&"glow": Color("#7fd0d9"),
		&"accent": Color("#c9a34a"),
	}

static func _forest_palette() -> Dictionary:
	return {
		&"wall_outline": Color("#0f1b17"),
		&"wall_fill": Color("#1e3328"),
		&"wall_shade": Color("#17261e"),
		&"wall_highlight": Color("#2b4a38"),
		&"floor_base": Color("#16251e"),
		&"floor_dark": Color("#121c17"),
		&"floor_light": Color("#1e3027"),
		&"door_bar": Color("#3d5a48"),
		&"door_lock": Color("#c9a34a"),
		&"door_open": Color("#060a08"),
		&"rune": Color("#9fe8b0"),
		&"glow": Color("#7fe8b9"),
		&"accent": Color("#c9a34a"),
	}

static func _ember_palette() -> Dictionary:
	return {
		&"wall_outline": Color("#1c1010"),
		&"wall_fill": Color("#3a2020"),
		&"wall_shade": Color("#2b1616"),
		&"wall_highlight": Color("#4f2c2a"),
		&"floor_base": Color("#2b1716"),
		&"floor_dark": Color("#221110"),
		&"floor_light": Color("#3a211e"),
		&"door_bar": Color("#5a3a30"),
		&"door_lock": Color("#e8b84c"),
		&"door_open": Color("#0c0706"),
		&"rune": Color("#ff8c5a"),
		&"glow": Color("#ffcf6a"),
		&"accent": Color("#e8b84c"),
	}
