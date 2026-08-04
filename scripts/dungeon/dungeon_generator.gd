class_name DungeonGenerator
extends RefCounted
## Builds a solvable dungeon from a seed and a biome.
##
## The generator follows a fixed pipeline:
##   1. Place rooms without overlaps.
##   2. Connect every room with a spanning tree of corridors.
##   3. Add optional shortcut corridors to create loops.
##   4. Carve the chosen corridor style into the map.
##   5. Choose the start and the farthest room as the exit.
##   6. Place doors on tree corridors and put each key on the
##      start side of its door, so the exit is always reachable.
##   7. Scatter monsters in the rooms.
##
## Every step uses the same SeededRng, so a seed always produces the
## same dungeon.

func generate(p_config: DungeonConfig, p_seed: int) -> DungeonResult:
	var result := DungeonResult.new()
	result.seed_value = p_seed
	result.config = p_config

	var rng := SeededRng.new(p_seed)
	result.rooms = _place_rooms(rng, p_config)
	result.corridors = _build_connections(rng, p_config, result.rooms)

	result.map = DungeonMap.new(p_config.width, p_config.height)
	_carve_rooms(result.map, result.rooms)
	_carve_corridors(rng, p_config, result.map, result.rooms, result.corridors)

	var selection := _choose_start_and_exit(result.rooms, result.corridors)
	result.start_room = selection.x
	result.exit_room = selection.y
	result.start_pos = result.rooms[result.start_room].center()
	result.exit_pos = result.rooms[result.exit_room].center()
	result.boss_spawn = _pick_boss_spawn(result.map, result.exit_pos)
	result.map.set_tile_cell(result.start_pos, DungeonMap.Tile.START)
	result.map.set_tile_cell(result.exit_pos, DungeonMap.Tile.EXIT)

	_place_doors_and_keys(rng, p_config, result)
	_place_monsters(rng, p_config, result)

	result.depth = Pathfinding.flood(result.map, result.start_pos, true).get(result.exit_pos, 0)
	result.solvable = Solvability.verify(result)
	return result

func _place_rooms(p_rng: SeededRng, p_config: DungeonConfig) -> Array[Room]:
	var rooms: Array[Room] = []
	var attempts := p_config.room_count_max * 60
	var target := p_rng.next_int_range(p_config.room_count_min, p_config.room_count_max)
	var guard := 0
	while rooms.size() < target and guard < attempts:
		guard += 1
		var w := p_rng.next_int_range(p_config.room_min, p_config.room_max)
		var h := p_rng.next_int_range(p_config.room_min, p_config.room_max)
		if w >= p_config.width - 4 or h >= p_config.height - 4:
			continue
		var x := p_rng.next_int_range(1, p_config.width - w - 2)
		var y := p_rng.next_int_range(1, p_config.height - h - 2)
		var candidate := Room.new(rooms.size(), Rect2i(x, y, w, h))
		var overlaps := false
		for room in rooms:
			if room.overlaps(candidate):
				overlaps = true
				break
		if not overlaps:
			rooms.append(candidate)
	return rooms

func _build_connections(
	p_rng: SeededRng,
	p_config: DungeonConfig,
	p_rooms: Array[Room]
) -> Array[Corridor]:
	var corridors: Array[Corridor] = []
	if p_rooms.size() < 2:
		return corridors

	var connected := {}
	connected[0] = true
	var pending: Array[int] = []
	for i in range(1, p_rooms.size()):
		pending.append(i)

	while not pending.is_empty():
		var best_room := -1
		var best_dist := INF
		var best_link := -1
		for candidate in pending:
			for hub in connected:
				var distance := p_rooms[candidate].center().distance_squared_to(
					p_rooms[hub].center()
				)
				if distance < best_dist:
					best_dist = distance
					best_room = candidate
					best_link = hub
		corridors.append(Corridor.new(
			Corridor.Kind.TREE, best_link, best_room
		))
		connected[best_room] = true
		pending.erase(best_room)

	_add_shortcuts(p_rng, p_config, p_rooms, corridors)
	return corridors

func _add_shortcuts(
	p_rng: SeededRng,
	p_config: DungeonConfig,
	p_rooms: Array[Room],
	p_corridors: Array[Corridor]
) -> void:
	var tree_count := p_corridors.size()
	var budget := tree_count
	while budget > 0:
		budget -= 1
		if not p_rng.chance(p_config.loop_chance):
			continue
		var a := p_rng.next_int(p_rooms.size())
		var b := p_rng.next_int(p_rooms.size() - 1)
		if b >= a:
			b += 1
		if _pair_connected(p_corridors, a, b):
			continue
		if p_rooms[a].center().distance_squared_to(p_rooms[b].center()) > 26.0 * 26.0:
			continue
		p_corridors.append(Corridor.new(Corridor.Kind.SHORTCUT, a, b))

func _pair_connected(p_corridors: Array[Corridor], p_a: int, p_b: int) -> bool:
	for corridor in p_corridors:
		if (corridor.from_room == p_a and corridor.to_room == p_b) \
				or (corridor.from_room == p_b and corridor.to_room == p_a):
			return true
	return false

func _carve_rooms(p_map: DungeonMap, p_rooms: Array[Room]) -> void:
	for room in p_rooms:
		for x in room.w:
			for y in room.h:
				p_map.set_tile(room.x + x, room.y + y, DungeonMap.Tile.FLOOR)

func _carve_corridors(
	p_rng: SeededRng,
	p_config: DungeonConfig,
	p_map: DungeonMap,
	p_rooms: Array[Room],
	p_corridors: Array[Corridor]
) -> void:
	for corridor in p_corridors:
		var from_center := p_rooms[corridor.from_room].center()
		var to_center := p_rooms[corridor.to_room].center()
		match p_config.corridor_style:
			DungeonConfig.CorridorStyle.winding:
				_carve_winding(p_rng, p_map, corridor, from_center, to_center)
			DungeonConfig.CorridorStyle.straight:
				_carve_straight(p_rng, p_map, corridor, from_center, to_center)
			_:
				_carve_elbow(p_rng, p_map, corridor, from_center, to_center)

func _carve_elbow(
	p_rng: SeededRng,
	p_map: DungeonMap,
	p_corridor: Corridor,
	p_from: Vector2i,
	p_to: Vector2i
) -> void:
	var mid := Vector2i(p_to.x, p_from.y)
	if p_rng.chance(0.5):
		mid = Vector2i(p_from.x, p_to.y)
	_carve_segment(p_map, p_corridor, p_from, mid)
	_carve_segment(p_map, p_corridor, mid, p_to)

func _carve_winding(
	p_rng: SeededRng,
	p_map: DungeonMap,
	p_corridor: Corridor,
	p_from: Vector2i,
	p_to: Vector2i
) -> void:
	var current := p_from
	var guard := 0
	while (current.x != p_to.x or current.y != p_to.y) and guard < 120:
		guard += 1
		var step := p_rng.next_int_range(2, 5)
		if current.x != p_to.x and (p_rng.chance(0.5) or current.y == p_to.y):
			var direction := signi(p_to.x - current.x)
			for i in step:
				current.x += direction
				_carve_cell(p_map, p_corridor, current)
				_carve_cell(p_map, p_corridor, Vector2i(current.x, current.y + p_rng.next_int_range(-1, 1)))
				if current.x == p_to.x:
					break
		elif current.y != p_to.y:
			var direction := signi(p_to.y - current.y)
			for i in step:
				current.y += direction
				_carve_cell(p_map, p_corridor, current)
				_carve_cell(p_map, p_corridor, Vector2i(current.x + p_rng.next_int_range(-1, 1), current.y))
				if current.y == p_to.y:
					break
		else:
			break

func _carve_straight(
	p_rng: SeededRng,
	p_map: DungeonMap,
	p_corridor: Corridor,
	p_from: Vector2i,
	p_to: Vector2i
) -> void:
	var current := p_from
	var guard := 0
	while current != p_to and guard < 200:
		guard += 1
		var dx := p_to.x - current.x
		var dy := p_to.y - current.y
		if absi(dx) >= absi(dy):
			current.x += signi(dx)
			_carve_cell(p_map, p_corridor, current)
			var side := Vector2i(0, p_rng.next_int_range(-1, 1))
			_carve_cell(p_map, p_corridor, current + side)
		else:
			current.y += signi(dy)
			_carve_cell(p_map, p_corridor, current)
			var side := Vector2i(p_rng.next_int_range(-1, 1), 0)
			_carve_cell(p_map, p_corridor, current + side)

func _carve_segment(
	p_map: DungeonMap,
	p_corridor: Corridor,
	p_from: Vector2i,
	p_to: Vector2i
) -> void:
	var cursor := p_from
	while cursor != p_to:
		_carve_cell(p_map, p_corridor, cursor)
		cursor += Vector2i(signi(p_to.x - cursor.x), signi(p_to.y - cursor.y))
	_carve_cell(p_map, p_corridor, p_to)

func _carve_cell(p_map: DungeonMap, p_corridor: Corridor, p_cell: Vector2i) -> void:
	if not p_map.in_bounds_cell(p_cell):
		return
	if p_map.get_tile_cell(p_cell) == DungeonMap.Tile.WALL:
		p_map.set_tile_cell(p_cell, DungeonMap.Tile.FLOOR)
		p_corridor.tiles.append(p_cell)

func _choose_start_and_exit(
	p_rooms: Array[Room],
	p_corridors: Array[Corridor]
) -> Vector2i:
	if p_rooms.size() < 2:
		return Vector2i(0, 0)
	var tree := _tree_adjacency(p_corridors)
	var start_room := 0
	var distances := _room_distances(tree, start_room)
	var exit_room := 0
	var best := -1
	for room_id in distances:
		if distances[room_id] > best:
			best = distances[room_id]
			exit_room = room_id
	return Vector2i(start_room, exit_room)

func _tree_adjacency(p_corridors: Array[Corridor]) -> Dictionary:
	var tree := {}
	for corridor in p_corridors:
		if corridor.kind != Corridor.Kind.TREE:
			continue
		if not tree.has(corridor.from_room):
			tree[corridor.from_room] = []
		if not tree.has(corridor.to_room):
			tree[corridor.to_room] = []
		tree[corridor.from_room].append(corridor.to_room)
		tree[corridor.to_room].append(corridor.from_room)
	return tree

func _room_distances(p_tree: Dictionary, p_start: int) -> Dictionary:
	var distances := {}
	distances[p_start] = 0
	var frontier: Array[int] = [p_start]
	var head := 0
	while head < frontier.size():
		var room_id := frontier[head]
		head += 1
		for next_room in p_tree.get(room_id, []):
			if distances.has(next_room):
				continue
			distances[next_room] = distances[room_id] + 1
			frontier.append(next_room)
	return distances

func _place_doors_and_keys(
	p_rng: SeededRng,
	p_config: DungeonConfig,
	p_result: DungeonResult
) -> void:
	var tree_corridors: Array[Corridor] = []
	for corridor in p_result.corridors:
		if corridor.kind == Corridor.Kind.TREE:
			tree_corridors.append(corridor)
	if tree_corridors.is_empty():
		return

	var target := p_rng.next_int_range(
		p_config.door_count_min, p_config.door_count_max
	)
	target = mini(target, tree_corridors.size())

	var chosen: Array[Corridor] = []
	var order := []
	for i in tree_corridors.size():
		order.append(i)
	p_rng.shuffle(order)
	for corridor_index in order:
		if chosen.size() >= target:
			break
		var corridor := tree_corridors[corridor_index]
		var door_pos := _pick_door_tile(p_rng, p_result.map, corridor)
		if door_pos == Vector2i(-1, -1):
			continue
		corridor.has_door = true
		corridor.door_tile = door_pos
		p_result.map.set_tile_cell(door_pos, DungeonMap.Tile.DOOR_LOCKED)
		chosen.append(corridor)

	# Simulate opening the doors. Every key is placed in a cell that is
	# reachable before its own door opens, so the dungeon is solvable by
	# construction. Corridors can cross, so the reachable region is
	# recomputed on the map rather than trusted from the room tree.
	var working := DungeonMap.new(p_result.map.width, p_result.map.height)
	for x in p_result.map.width:
		for y in p_result.map.height:
			working.set_tile(x, y, p_result.map.get_tile(x, y))

	var tree := _tree_adjacency(tree_corridors)
	var blocked := {}
	blocked[p_result.start_pos] = true
	blocked[p_result.exit_pos] = true

	for corridor in chosen:
		var region := Pathfinding.flood(working, p_result.start_pos, false)
		var key_pos := _pick_key_cell_in_region(
			p_rng, working, region, corridor, tree,
			p_result.start_room, p_result.rooms, blocked
		)
		blocked[key_pos] = true
		var door_index := p_result.doors.size()
		p_result.doors.append({
			"position": corridor.door_tile,
			"corridor": corridor,
			"key_pos": key_pos,
			"room": _room_at(p_result.rooms, key_pos),
		})
		p_result.keys.append({
			"position": key_pos,
			"door": door_index,
		})
		working.set_tile_cell(corridor.door_tile, DungeonMap.Tile.DOOR_OPEN)

## Picks a door tile for a corridor, preferring its middle cells.
func _pick_door_tile(
	p_rng: SeededRng,
	p_map: DungeonMap,
	p_corridor: Corridor
) -> Vector2i:
	if p_corridor.tiles.is_empty():
		return Vector2i(-1, -1)
	var middle := p_corridor.tiles.size() / 2
	var search_order: Array[int] = [middle]
	for offset in range(1, middle + 1):
		if middle - offset >= 0:
			search_order.append(middle - offset)
		if middle + offset < p_corridor.tiles.size():
			search_order.append(middle + offset)
	for index in search_order:
		var tile := p_corridor.tiles[index]
		if p_map.get_tile_cell(tile) == DungeonMap.Tile.FLOOR:
			return tile
	return Vector2i(-1, -1)

## Picks a key cell inside the current reachable region.
## Prefers rooms on the start side of the door, then any reachable cell.
func _pick_key_cell_in_region(
	p_rng: SeededRng,
	p_working: DungeonMap,
	p_region: Dictionary,
	p_corridor: Corridor,
	p_tree: Dictionary,
	p_start_room: int,
	p_rooms: Array[Room],
	p_blocked: Dictionary
) -> Vector2i:
	var start_side := {}
	for room_id in _rooms_on_start_side(
		p_tree, p_corridor.from_room, p_corridor.to_room, p_start_room
	):
		if room_id != p_start_room:
			start_side[room_id] = true

	var preferred: Array[Vector2i] = []
	var fallback: Array[Vector2i] = []
	for cell: Vector2i in p_region:
		if p_blocked.has(cell):
			continue
		if p_working.get_tile_cell(cell) != DungeonMap.Tile.FLOOR:
			continue
		var room_id := _room_at(p_rooms, cell)
		if start_side.has(room_id):
			preferred.append(cell)
		elif room_id != p_start_room:
			fallback.append(cell)
	if preferred.is_empty() and not fallback.is_empty():
		preferred = fallback
	if preferred.is_empty():
		for cell: Vector2i in p_region:
			if p_blocked.has(cell) \
					or p_working.get_tile_cell(cell) != DungeonMap.Tile.FLOOR:
				continue
			preferred.append(cell)
	if preferred.is_empty():
		push_warning("No key cell found; door will be unguarded.")
		return p_region.keys()[0]
	return preferred[p_rng.next_int(preferred.size())]

## Returns the id of the room that contains the cell, or -1.
func _room_at(p_rooms: Array[Room], p_cell: Vector2i) -> int:
	for room in p_rooms:
		if room.rect().has_point(p_cell):
			return room.id
	return -1

## Picks the tile where the final-floor boss stands guard.
## It is the nearest walkable neighbor of the exit, found by a spiral
## search that never returns the exit tile itself.
func _pick_boss_spawn(p_map: DungeonMap, p_exit: Vector2i) -> Vector2i:
	var radius := 1
	var max_radius := maxi(p_map.width, p_map.height)
	while radius < max_radius:
		for x in range(p_exit.x - radius, p_exit.x + radius + 1):
			for y in range(p_exit.y - radius, p_exit.y + radius + 1):
				var candidate := Vector2i(x, y)
				if candidate == p_exit:
					continue
				if p_map.in_bounds_cell(candidate) and p_map.is_walkable_cell(candidate):
					return candidate
		radius += 1
	return p_exit

## Floods the room graph without crossing the given tree edge.
func _rooms_on_start_side(
	p_tree: Dictionary,
	p_a: int,
	p_b: int,
	p_start_room: int
) -> Array[int]:
	var seen := {}
	seen[p_start_room] = true
	var frontier: Array[int] = [p_start_room]
	var head := 0
	while head < frontier.size():
		var room_id := frontier[head]
		head += 1
		for next_room in p_tree.get(room_id, []):
			if next_room in seen:
				continue
			if (room_id == p_a and next_room == p_b) \
					or (room_id == p_b and next_room == p_a):
				continue
			seen[next_room] = true
			frontier.append(next_room)
	return frontier

func _place_monsters(
	p_rng: SeededRng,
	p_config: DungeonConfig,
	p_result: DungeonResult
) -> void:
	var monster_ids: Array = []
	var weights: Array = []
	for entry in p_config.monster_table:
		monster_ids.append(entry.monster)
		weights.append(entry.weight)

	var monster_rooms: Array[int] = []
	for room in p_result.rooms:
		if room.id == p_result.start_room or room.id == p_result.exit_room:
			continue
		monster_rooms.append(room.id)

	for room_id in monster_rooms:
		if p_result.monster_spawns.size() >= p_config.monster_cap:
			break
		var room := p_result.rooms[room_id]
		var density := p_config.monster_density
		if room.area() >= 56:
			density += 0.2
		if not p_rng.chance(density):
			continue
		var monster_id: StringName = monster_ids[p_rng.weighted_index(weights)]
		p_result.monster_spawns.append({
			"position": room.random_cell(p_rng),
			"monster": monster_id,
		})
