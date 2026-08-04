class_name Projectile
extends Node2D
## A flying projectile fired by a ranged monster.
##
## A projectile travels one tile at a time in a fixed direction. Walls
## and locked doors stop it, and a maximum range makes every bolt expire.
## When a bolt lands on the hero's tile, the on_hit callable runs and the
## bolt fades out. All movement lives in tick(), so tests can drive a
## bolt deterministically without waiting on engine frames.

signal expired(projectile)

var damage: int = 1
var speed: float = 6.0
var max_range: int = 8
var direction: Vector2i = Vector2i.RIGHT
var view: DungeonView = null
## The tile the hero occupies. The controller refreshes it each frame.
var target_grid: Vector2i = Vector2i(-1, -1)
## Runs when the bolt lands on the hero's tile. Set by the controller.
var on_hit: Callable = Callable()

var grid_pos: Vector2i = Vector2i.ZERO
## True once the bolt lands on the hero's tile.
var hit: bool = false

var _from: Vector2i = Vector2i.ZERO
var _to: Vector2i = Vector2i.ZERO
var _progress := 1.0
var _range_left := 0
var _expired := false
var _sprite: Sprite2D = null

func setup(
	p_damage: int,
	p_speed: float,
	p_direction: Vector2i,
	p_start: Vector2i,
	p_view: DungeonView,
	p_range: int
) -> void:
	damage = p_damage
	speed = p_speed
	direction = p_direction
	view = p_view
	max_range = p_range
	grid_pos = p_start
	_from = p_start
	_to = p_start
	_range_left = p_range
	position = view.tile_to_world(p_start)
	_build_sprite()

## True once the bolt is spent, for any reason.
func is_expired() -> bool:
	return _expired

## Advances the bolt by p_delta seconds.
func tick(p_delta: float) -> void:
	if _expired or view == null:
		return
	_progress += p_delta * speed
	while _progress >= 1.0 and not _expired:
		_progress -= 1.0
		_advance_tile()
	if _expired:
		return
	position = view.tile_to_world(_from).lerp(
		view.tile_to_world(_to), clampf(_progress, 0.0, 1.0)
	)

## Moves one tile, checks the target, and stops on solid cells.
func _advance_tile() -> void:
	_from = _to
	grid_pos = _from
	if _lands_on_target():
		return
	var next_cell := _from + direction
	if not _is_open(next_cell):
		_expire()
		return
	_range_left -= 1
	if _range_left < 0:
		_expire()
		return
	_to = next_cell

## True when the bolt arrived on the hero's tile.
func _lands_on_target() -> bool:
	if target_grid != grid_pos:
		return false
	hit = true
	if on_hit.is_valid():
		on_hit.call()
	_expire()
	return true

## Walls and locked doors are solid. Opened doors let a bolt pass.
func _is_open(p_cell: Vector2i) -> bool:
	if not view.map.in_bounds_cell(p_cell):
		return false
	var tile := view.map.get_tile_cell(p_cell)
	return tile != DungeonMap.Tile.WALL and tile != DungeonMap.Tile.DOOR_LOCKED

func _expire() -> void:
	_expired = true
	expired.emit(self)

func _build_sprite() -> void:
	_sprite = Sprite2D.new()
	_sprite.texture = TileArt.entity_texture(&"bolt")
	_sprite.centered = true
	_sprite.rotation = atan2(float(direction.y), float(direction.x))
	add_child(_sprite)
