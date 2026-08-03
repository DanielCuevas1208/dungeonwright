class_name Pickup
extends Node2D
## A collectible item on the dungeon floor.
##
## Keys, potions, coins, and shards are all pickups. The scene controller
## checks overlap each frame and hands the pickup to the hero.

signal picked_up(pickup)

var kind: StringName = &"coin"
var count: int = 1
var grid_pos: Vector2i = Vector2i.ZERO
var view: DungeonView = null
var taken: bool = false

var _sprite: Sprite2D = null
var _phase := 0.0

func setup(p_kind: StringName, p_count: int, p_grid: Vector2i, p_view: DungeonView) -> void:
	kind = p_kind
	count = p_count
	grid_pos = p_grid
	view = p_view
	position = view.tile_to_world(grid_pos)
	_sprite = Sprite2D.new()
	_sprite.texture = TileArt.entity_texture(kind)
	_sprite.centered = true
	_sprite.position.y = -2.0
	add_child(_sprite)

func _process(p_delta: float) -> void:
	if taken:
		return
	_phase += p_delta * 3.0
	_sprite.position.y = -2.0 + sin(_phase) * 1.5

## True when the hero stands on this pickup.
func covers_hero(p_hero_grid: Vector2i) -> bool:
	return grid_pos == p_hero_grid

func take() -> void:
	if taken:
		return
	taken = true
	picked_up.emit(self)
