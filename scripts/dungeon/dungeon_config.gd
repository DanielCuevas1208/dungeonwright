class_name DungeonConfig
extends RefCounted
## Generation parameters for a biome.
##
## A biome is a set of rules. Changing these values changes the shape of
## the dungeon: room count, room size, corridor style, loops, doors,
## and monster pressure.

const CorridorStyle := {
	"elbow": &"elbow",
	"winding": &"winding",
	"straight": &"straight",
}

var id: StringName = &""
var display_name: String = ""
var description: String = ""
var width: int = 48
var height: int = 30
var room_count_min: int = 8
var room_count_max: int = 11
var room_min: int = 5
var room_max: int = 9
var corridor_style: StringName = CorridorStyle.elbow
var loop_chance: float = 0.25
var door_count_min: int = 2
var door_count_max: int = 3
var monster_density: float = 0.5
var monster_cap: int = 10
var monster_table: Array = []
var starting_health: int = 100
var player_damage: int = 12
var palette: Dictionary = {}

## Validates the config and returns a list of problems, empty when sound.
func validate() -> Array[String]:
	var problems: Array[String] = []
	if width < 24 or height < 20:
		problems.append("map is too small")
	if room_count_min < 2 or room_count_min > room_count_max:
		problems.append("room count range is invalid")
	if room_min < 3 or room_min > room_max:
		problems.append("room size range is invalid")
	if door_count_min < 0:
		problems.append("door count is negative")
	if monster_density < 0.0 or monster_density > 1.0:
		problems.append("monster density must be between 0 and 1")
	if loop_chance < 0.0 or loop_chance > 1.0:
		problems.append("loop chance must be between 0 and 1")
	if monster_table.is_empty():
		problems.append("monster table is empty")
	if palette.is_empty():
		problems.append("palette is empty")
	return problems

## True when the config can generate a valid dungeon.
func is_valid() -> bool:
	return validate().is_empty()

## Returns an independent copy of this config.
func clone() -> DungeonConfig:
	var copy := DungeonConfig.new()
	copy.id = id
	copy.display_name = display_name
	copy.description = description
	copy.width = width
	copy.height = height
	copy.room_count_min = room_count_min
	copy.room_count_max = room_count_max
	copy.room_min = room_min
	copy.room_max = room_max
	copy.corridor_style = corridor_style
	copy.loop_chance = loop_chance
	copy.door_count_min = door_count_min
	copy.door_count_max = door_count_max
	copy.monster_density = monster_density
	copy.monster_cap = monster_cap
	copy.monster_table = monster_table.duplicate(true)
	copy.starting_health = starting_health
	copy.player_damage = player_damage
	copy.palette = palette.duplicate(true)
	return copy
