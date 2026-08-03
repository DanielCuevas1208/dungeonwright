class_name Corridor
extends RefCounted
## A corridor that connects two rooms.
##
## Tree corridors form the minimum spanning tree that keeps every room
## connected. Shortcut corridors are optional loops that give players
## more than one path through the dungeon.

enum Kind { TREE, SHORTCUT }

var kind: Kind = Kind.TREE
var from_room: int = -1
var to_room: int = -1
var tiles: Array[Vector2i] = []
var door_tile: Vector2i = Vector2i(-1, -1)
var has_door: bool = false

func _init(
	p_kind: Kind = Kind.TREE,
	p_from: int = -1,
	p_to: int = -1,
	p_tiles: Array[Vector2i] = []
) -> void:
	kind = p_kind
	from_room = p_from
	to_room = p_to
	tiles = p_tiles

## True when the corridor tiles contain the given cell.
func contains(p_cell: Vector2i) -> bool:
	return tiles.has(p_cell)
