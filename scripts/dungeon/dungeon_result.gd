class_name DungeonResult
extends RefCounted
## The complete output of the dungeon generator.
##
## Contains the map, the rooms, the corridors, and every placed feature:
## the start, the exit, keys, doors, and monster spawns.

var seed_value: int = 0
var config: DungeonConfig = null
var map: DungeonMap = null
var rooms: Array[Room] = []
var corridors: Array[Corridor] = []
var start_room: int = -1
var exit_room: int = -1
var start_pos: Vector2i = Vector2i.ZERO
var exit_pos: Vector2i = Vector2i.ZERO
var doors: Array = []
## One entry per placed door: { position, corridor, key_pos, room }
var keys: Array = []
## One entry per spawn: { position, monster }
var monster_spawns: Array = []
## BFS distance in tiles from start to exit.
var depth: int = 0
## True when the exit is reachable by collecting keys in order.
var solvable: bool = true

## The number of rooms in the dungeon.
func room_count() -> int:
	return rooms.size()

## The number of placed doors.
func door_count() -> int:
	return doors.size()

## The number of placed keys.
func key_count() -> int:
	return keys.size()

## The number of monster spawns.
func monster_count() -> int:
	return monster_spawns.size()
