class_name Bomb
extends Node2D
## A thrown explosive that the hero lobs into a crowd of monsters.
##
## A bomb travels forward until it hits a wall or its throw range runs
## out. It then sits on that tile while a fuse counts down. When the
## fuse ends, the blast runs the on_explode callable and the bomb
## expires. All timing lives in tick(), so tests can detonate a bomb
## without waiting on engine frames.

signal expired(bomb)

var damage: int = 25
var speed: float = 5.0
var throw_range: int = 2
var fuse: float = 0.8
var blast_radius: int = 2
var direction: Vector2i = Vector2i.RIGHT
var view: DungeonView = null
## Runs when the blast goes off. Set by the scene controller.
var on_explode: Callable = Callable()

var grid_pos: Vector2i = Vector2i.ZERO
## True once the bomb has stopped moving and is counting down.
var landed: bool = false
## True once the blast has gone off.
var exploded: bool = false

var _from: Vector2i = Vector2i.ZERO
var _to: Vector2i = Vector2i.ZERO
var _progress := 1.0
var _range_left := 0
var _fuse_left := 0.0
var _sprite: Sprite2D = null

func setup(
	p_damage: int,
	p_speed: float,
	p_direction: Vector2i,
	p_origin: Vector2i,
	p_view: DungeonView,
	p_range: int,
	p_fuse: float,
	p_radius: int
) -> void:
	damage = p_damage
	speed = p_speed
	direction = p_direction
	view = p_view
	throw_range = p_range
	fuse = p_fuse
	blast_radius = p_radius
	grid_pos = p_origin
	_from = p_origin
	_to = p_origin
	_range_left = p_range
	_fuse_left = p_fuse
	position = view.tile_to_world(p_origin)
	_build_sprite()

## True once the bomb is spent, for any reason.
func is_expired() -> bool:
	return exploded

## Advances the bomb by p_delta seconds.
func tick(p_delta: float) -> void:
	if exploded or view == null:
		return
	if not landed:
		_advance_throw(p_delta)
		if exploded or not landed:
			return
	_fuse_left -= p_delta
	_pulse_sprite()
	if _fuse_left <= 0.0:
		_detonate()

## Moves the bomb forward until it lands.
func _advance_throw(p_delta: float) -> void:
	_progress += p_delta * speed
	while _progress >= 1.0 and not landed:
		_progress -= 1.0
		_step()
		if exploded:
			return
	if not landed:
		position = view.tile_to_world(_from).lerp(
			view.tile_to_world(_to), clampf(_progress, 0.0, 1.0)
		)

## Steps one tile, then lands on a wall or when the range runs out.
func _step() -> void:
	_from = _to
	grid_pos = _from
	var next_cell := _from + direction
	if not _is_open(next_cell):
		_land()
		return
	_range_left -= 1
	if _range_left < 0:
		_land()
		return
	_to = next_cell

## Walls and locked doors stop a thrown bomb.
func _is_open(p_cell: Vector2i) -> bool:
	if not view.map.in_bounds_cell(p_cell):
		return false
	var tile := view.map.get_tile_cell(p_cell)
	return tile != DungeonMap.Tile.WALL and tile != DungeonMap.Tile.DOOR_LOCKED

func _land() -> void:
	landed = true
	_progress = 1.0
	position = view.tile_to_world(grid_pos)

## Starts the blast and reports the spent bomb.
func _detonate() -> void:
	exploded = true
	if on_explode.is_valid():
		on_explode.call()
	expired.emit(self)

func _pulse_sprite() -> void:
	var phase := clampf(_fuse_left / maxf(fuse, 0.001), 0.0, 1.0)
	_sprite.scale = Vector2.ONE * (1.0 + (1.0 - phase) * 0.25)

func _build_sprite() -> void:
	_sprite = Sprite2D.new()
	_sprite.texture = TileArt.entity_texture(&"bomb")
	_sprite.centered = true
	add_child(_sprite)
