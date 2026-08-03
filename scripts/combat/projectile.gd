class_name Projectile
extends RefCounted
## Pure flight model for a single projectile.
##
## The model stores tile-space floats so the flight path is exact and
## deterministic. The actor reads this model each frame and renders it.
## Keeping the math here makes flight logic testable without a scene.

const TILE_SIZE := 16.0

var spec: ProjectileSpec = null
var origin: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.RIGHT
var travelled := 0.0
var speed := 0.0
var damage := 0
var max_range := 0.0

func _init(p_spec: ProjectileSpec, p_origin: Vector2, p_direction: Vector2) -> void:
	spec = p_spec
	origin = p_origin
	speed = p_spec.speed * TILE_SIZE
	damage = p_spec.damage
	max_range = p_spec.range * TILE_SIZE
	if p_direction != Vector2.ZERO:
		direction = p_direction.normalized()

## Aims a projectile from one tile center toward another tile center.
static func aimed(p_spec: ProjectileSpec, p_from: Vector2i, p_to: Vector2i) -> Projectile:
	var origin := Vector2(p_from) * TILE_SIZE + Vector2(TILE_SIZE / 2.0, TILE_SIZE / 2.0)
	var target := Vector2(p_to) * TILE_SIZE + Vector2(TILE_SIZE / 2.0, TILE_SIZE / 2.0)
	return Projectile.new(p_spec, origin, target - origin)

## Advances the flight by p_delta seconds. Returns true when the flight ends.
func advance(p_delta: float) -> bool:
	if is_expired():
		return true
	var step := speed * p_delta
	travelled += step
	if travelled >= max_range:
		travelled = max_range
		return true
	return false

## The world position of the projectile.
func position() -> Vector2:
	return origin + direction * travelled

## The tile that the projectile currently occupies.
func current_tile() -> Vector2i:
	var pos := position()
	return Vector2i(floori(pos.x / TILE_SIZE), floori(pos.y / TILE_SIZE))

## True when the projectile has flown its full range.
func is_expired() -> bool:
	return travelled >= max_range

## True when the projectile would sit inside a solid tile on this map.
func blocked_by(p_map: DungeonMap) -> bool:
	var tile := p_map.get_tile_cell(current_tile())
	return tile == DungeonMap.Tile.WALL or tile == DungeonMap.Tile.DOOR_LOCKED

## The distance in tiles already flown.
func distance_travelled() -> float:
	return travelled / TILE_SIZE
