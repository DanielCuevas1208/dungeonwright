class_name ShrineActor
extends Node2D
## Live presentation of one generated shrine.
##
## The controller checks interaction range. This node only presents focus,
## the offer, and the spent state on the dungeon map.

var shrine: Shrine = null
var grid_pos: Vector2i = Vector2i.ZERO
var view: DungeonView = null
var used := false

var _sprite: Sprite2D = null
var _focused := false
var _phase := 0.0

## Places and styles the actor from one generated shrine record.
func setup(
	p_shrine: Shrine,
	p_view: DungeonView,
	p_accent: Color
) -> void:
	shrine = p_shrine
	grid_pos = p_shrine.position
	view = p_view
	position = view.tile_to_world(grid_pos)
	_sprite = Sprite2D.new()
	_sprite.texture = TileArt.entity_texture(&"shrine")
	_sprite.centered = true
	_sprite.modulate = p_accent.lightened(0.35)
	_sprite.position.y = -2.0
	add_child(_sprite)

## Updates the visual focus state while the hero stands on the shrine.
func set_focused(p_focused: bool) -> void:
	_focused = p_focused
	if _sprite == null or used:
		return
	_sprite.scale = Vector2.ONE * (1.18 if _focused else 1.0)

## Returns true when this shrine can still grant its offer.
func is_available() -> bool:
	return not used

## Returns the short prompt shown while the hero is on this shrine.
func prompt_text() -> String:
	if used:
		return "Shrine spent"
	return shrine.prompt_text()

## Marks the shrine as spent and dims its inactive art.
func consume() -> void:
	used = true
	_focused = false
	if _sprite != null:
		_sprite.scale = Vector2.ONE
		_sprite.modulate = Color(0.35, 0.4, 0.45, 0.75)

func _process(p_delta: float) -> void:
	if used or _sprite == null:
		return
	_phase += p_delta * (3.2 if _focused else 2.0)
	_sprite.position.y = -2.0 + sin(_phase) * (2.0 if _focused else 1.0)
