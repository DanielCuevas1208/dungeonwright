class_name Solvability
extends RefCounted
## Verifies that a dungeon can be solved.
##
## The solver explores the map from the start. Locked doors block the
## hero until the matching key is found. When a key is collected, the
## solver re-expands from the cells around the unlocked door. The
## explorer repeats until it cannot expand, then checks whether the exit
## is reachable. This turns the "exit always reachable" guarantee into
## a testable property.

const ORTHO := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

## True when the hero can reach the exit by collecting every key first.
static func verify(p_result: DungeonResult) -> bool:
	if p_result.map == null:
		return false
	var map: DungeonMap = p_result.map

	var door_by_pos := {}
	for i in p_result.doors.size():
		door_by_pos[p_result.doors[i].position] = i

	var key_by_door := {}
	for key in p_result.keys:
		key_by_door[key.door] = key.position

	var collected := {}
	var reachable := {}
	reachable[p_result.start_pos] = true
	var frontier: Array[Vector2i] = [p_result.start_pos]
	var head := 0
	var changed := true

	while changed:
		changed = false
		while head < frontier.size():
			var cell := frontier[head]
			head += 1
			for offset: Vector2i in ORTHO:
				var next_cell := cell + offset
				if reachable.has(next_cell) or not map.in_bounds_cell(next_cell):
					continue
				var tile := map.get_tile_cell(next_cell)
				if tile == DungeonMap.Tile.WALL:
					continue
				if tile == DungeonMap.Tile.DOOR_LOCKED:
					var door_index: int = door_by_pos.get(next_cell, -1)
					if door_index < 0 or not collected.has(door_index):
						continue
				reachable[next_cell] = true
				frontier.append(next_cell)
				changed = true
		var unlocked := false
		for door_index in key_by_door:
			if collected.has(door_index):
				continue
			if not reachable.has(key_by_door[door_index]):
				continue
			collected[door_index] = true
			unlocked = true
			var door_cell: Vector2i = p_result.doors[door_index].position
			for offset: Vector2i in ORTHO:
				var neighbour := door_cell + offset
				if reachable.has(neighbour):
					frontier.append(neighbour)
		if unlocked:
			changed = true

	return reachable.has(p_result.exit_pos)
