class_name Projectile
extends Node2D
## A bolt fired by a ranged monster.
##
## The projectile flies in a straight line toward the hero. It stops at
## walls and locked doors, and it despawns after its range. The static
## helpers hold the core rules so the test suite can check them without
## running the scene tree.

signal hit_player(damage: int)

const TILE_SIZE := 16.0
const HIT_RADIUS := 8.0

var damage: int = 1
var speed: float = 7.0
var max_range: float = 7.0
var view: DungeonView = null
var target: Node2D = null

var _direction := Vector2.RIGHT
var _traveled := 0.0
var _sprite: Sprite2D = null

## Arms the projectile from a monster spec and launches it toward a tile.
func setup(
	p_spec: MonsterSpec,
	p_origin: Vector2i,
	p_target_grid: Vector2i,
	p_view: DungeonView,
	p_target: Node2D
) -> void:
	damage = p_spec.projectile_damage
	speed = p_spec.projectile_speed
	max_range = p_spec.projectile_range
	view = p_view
	target = p_target
	position = view.tile_to_world(p_origin)
	_direction = aim(view.tile_to_world(p_origin), view.tile_to_world(p_target_grid))
	_sprite = Sprite2D.new()
	_sprite.texture = TileArt.entity_texture(p_spec.projectile_key)
	_sprite.centered = true
	_sprite.modulate = p_spec.projectile_tint
	add_child(_sprite)

func _physics_process(p_delta: float) -> void:
	if view == null or _sprite == null:
		return
	position += _direction * speed * TILE_SIZE * p_delta
	_traveled += speed * p_delta
	if _traveled >= max_range:
		queue_free()
		return
	if _hits_target():
		hit_player.emit(damage)
		queue_free()
		return
	if blocks(view.map.get_tile_cell(view.world_to_tile(position))):
		queue_free()

## The unit direction from one world position to another.
static func aim(p_from: Vector2, p_to: Vector2) -> Vector2:
	var delta := p_to - p_from
	if delta.length_squared() <= 0.0001:
		return Vector2.RIGHT
	return delta.normalized()

## True when a tile stops a projectile.
static func blocks(p_tile: int) -> bool:
	return p_tile == DungeonMap.Tile.WALL or p_tile == DungeonMap.Tile.DOOR_LOCKED

## True when no blocking tile lies between the two cells.
## Uses a Bresenham walk, so walls cut the line at the exact cell.
static func los_clear(p_map: DungeonMap, p_from: Vector2i, p_to: Vector2i) -> bool:
	var x := p_from.x
	var y := p_from.y
	var dx := absi(p_to.x - p_from.x)
	var dy := -absi(p_to.y - p_from.y)
	var step_x := 1 if p_from.x < p_to.x else -1
	var step_y := 1 if p_from.y < p_to.y else -1
	var error := dx + dy
	while true:
		if x == p_to.x and y == p_to.y:
			return true
		if blocks(p_map.get_tile_cell(Vector2i(x, y))):
			return false
		var twice_error := 2 * error
		if twice_error >= dy:
			error += dy
			x += step_x
		if twice_error <= dx:
			error += dx
			y += step_y
	return true

func _hits_target() -> bool:
	if target == null or not is_instance_valid(target):
		return false
	return position.distance_to(target.position) <= HIT_RADIUS
