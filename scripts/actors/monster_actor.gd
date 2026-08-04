class_name MonsterActor
extends Node2D
## A living monster.
##
## Each monster reads its behaviour from a MonsterSpec. Chasers walk
## toward the hero, stalkers are fast and aggressive, sentries hold
## their ground, and ranged monsters fire bolts while keeping distance.
## Movement follows a short flood-fill path so monsters rarely get
## stuck on walls.

signal attack_player(damage: int)
signal shoot_requested(origin: Vector2i, target: Vector2i, spec: MonsterSpec)
signal hp_changed(current: int, max: int)
signal died(monster)

const REPATH_INTERVAL := 0.4

var spec: MonsterSpec = null
var stats: CombatStats = null
var grid_pos: Vector2i = Vector2i.ZERO
var view: DungeonView = null
var occupancy: Dictionary = {}
var target: Node2D = null

var _from: Vector2i = Vector2i.ZERO
var _to: Vector2i = Vector2i.ZERO
var _progress := 1.0
var _moving := false
var _path: Array[Vector2i] = []
var _repath_timer := 0.0
var _attack_timer := 0.0
var _sprite: Sprite2D = null
var _hp_bg: ColorRect = null
var _hp_fill: ColorRect = null
var _is_dead := false

func setup(
	p_spec: MonsterSpec,
	p_start: Vector2i,
	p_view: DungeonView,
	p_occupancy: Dictionary,
	p_target: Node2D
) -> void:
	spec = p_spec
	stats = CombatStats.make({
		"max_health": p_spec.stats.max_health,
		"health": p_spec.stats.max_health,
		"damage": p_spec.stats.damage,
		"speed": p_spec.stats.speed,
		"attack_range": p_spec.stats.attack_range,
		"attack_cooldown": p_spec.stats.attack_cooldown,
	})
	grid_pos = p_start
	view = p_view
	occupancy = p_occupancy
	target = p_target
	position = view.tile_to_world(grid_pos)
	_build_sprite()
	_build_hp_bar()
	hp_changed.emit(stats.health, stats.max_health)

func _physics_process(p_delta: float) -> void:
	if _is_dead or stats == null or stats.is_dead():
		return
	_attack_timer = maxf(0.0, _attack_timer - p_delta)
	_repath_timer = maxf(0.0, _repath_timer - p_delta)
	if target == null:
		return
	if _moving:
		_advance_movement(p_delta)
		_sprite.position.y = -2.0
		return

	var distance_sq := Vector2(grid_pos).distance_squared_to(Vector2(target.grid_pos))
	if spec.ranged:
		_ranged_think(distance_sq)
	else:
		_melee_think(distance_sq)
	_sprite.position.y = -2.0 if _moving else 0.0

## Applies damage. Returns true when the monster died.
func take_damage(p_amount: int) -> bool:
	if _is_dead or stats == null:
		return false
	stats.take_damage(p_amount)
	hp_changed.emit(stats.health, stats.max_health)
	_flash()
	_update_hp_bar()
	if stats.is_dead():
		_is_dead = true
		died.emit(self)
		return true
	return false

func _try_attack() -> void:
	if _attack_timer > 0.0:
		return
	_attack_timer = stats.attack_cooldown
	attack_player.emit(stats.damage)
	_lunge()

## Melee behaviour: attack in range, hold ground as a sentry, else chase.
func _melee_think(p_distance_sq: float) -> void:
	if Combat.within_attack_range(p_distance_sq, stats.attack_range):
		_try_attack()
		return
	if spec.ai == MonsterSpec.AI.sentry:
		return
	_approach_target(p_distance_sq)

## Ranged behaviour: flee a close hero, fire with line of sight,
## and advance until the hero is in range.
func _ranged_think(p_distance_sq: float) -> void:
	if Combat.within_attack_range(p_distance_sq, spec.min_range):
		_flee_from_target()
		return
	var in_fire_range := p_distance_sq <= spec.projectile_range * spec.projectile_range
	var has_los := Projectile.los_clear(view.map, grid_pos, target.grid_pos)
	if in_fire_range and has_los:
		_try_fire()
		return
	_approach_target(p_distance_sq)

## Walks toward the hero along a short flood-fill path.
func _approach_target(p_distance_sq: float) -> void:
	if p_distance_sq > spec.aggro_range * spec.aggro_range:
		return
	if _repath_timer <= 0.0:
		_repath_timer = REPATH_INTERVAL
		_path = Pathfinding.find_path(view.map, grid_pos, target.grid_pos, false)
	_step_along_path()

## Steps one cell away from the hero, choosing the open neighbour that
## increases the distance the most.
func _flee_from_target() -> void:
	var best := Vector2i(-1, -1)
	var best_distance := -1.0
	for offset: Vector2i in Pathfinding.ORTHO:
		var candidate := grid_pos + offset
		if not _can_step(candidate):
			continue
		var distance := Vector2(candidate).distance_squared_to(Vector2(target.grid_pos))
		if distance > best_distance:
			best_distance = distance
			best = candidate
	if best == Vector2i(-1, -1):
		return
	_from = grid_pos
	_to = best
	_progress = 0.0
	_moving = true

## Fires a projectile when the attack cooldown is ready.
func _try_fire() -> void:
	if _attack_timer > 0.0:
		return
	_attack_timer = stats.attack_cooldown
	shoot_requested.emit(grid_pos, target.grid_pos, spec)
	_lunge()

## Finishes the current tile step and claims the new cell.
func _advance_movement(p_delta: float) -> void:
	_progress += p_delta * stats.speed
	if _progress < 1.0:
		return
	grid_pos = _to
	position = view.tile_to_world(grid_pos)
	_moving = false
	occupancy.erase(_from)
	occupancy[grid_pos] = self

func _step_along_path() -> void:
	while not _path.is_empty():
		var next_cell := _path[_path.size() - 1]
		_path.remove_at(_path.size() - 1)
		if next_cell == grid_pos:
			continue
		if not _can_step(next_cell):
			return
		_from = grid_pos
		_to = next_cell
		_progress = 0.0
		_moving = true
		return

## True when a monster may step onto the cell.
func _can_step(p_cell: Vector2i) -> bool:
	if not view.map.in_bounds_cell(p_cell):
		return false
	if view.map.get_tile_cell(p_cell) == DungeonMap.Tile.DOOR_LOCKED:
		return false
	if not view.map.is_walkable_cell(p_cell):
		return false
	if occupancy.has(p_cell):
		return false
	return true

func _build_sprite() -> void:
	_sprite = Sprite2D.new()
	_sprite.texture = TileArt.entity_texture(StringName(spec.sprite_key))
	_sprite.centered = true
	add_child(_sprite)

func _build_hp_bar() -> void:
	_hp_bg = ColorRect.new()
	_hp_bg.color = Color(0.1, 0.1, 0.12, 0.8)
	_hp_bg.size = Vector2(14, 2)
	_hp_bg.position = Vector2(-7, -14)
	_hp_fill = ColorRect.new()
	_hp_fill.color = Color(0.8, 0.2, 0.2)
	_hp_fill.size = Vector2(14, 2)
	_hp_fill.position = Vector2(-7, -14)
	add_child(_hp_bg)
	add_child(_hp_fill)

func _update_hp_bar() -> void:
	if _hp_fill == null:
		return
	var ratio := float(stats.health) / float(stats.max_health)
	_hp_fill.size.x = 14.0 * clampf(ratio, 0.0, 1.0)

func _flash() -> void:
	var tween := create_tween()
	tween.tween_property(_sprite, "modulate", Color(3.0, 0.4, 0.4), 0.08)
	tween.tween_property(_sprite, "modulate", Color.WHITE, 0.12)

func _lunge() -> void:
	if not _moving:
		var tween := create_tween()
		tween.tween_property(_sprite, "position:y", 2.0, 0.08)
		tween.tween_property(_sprite, "position:y", 0.0, 0.1)
