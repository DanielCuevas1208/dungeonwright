class_name Room
extends RefCounted
## A rectangular room in the dungeon.
##
## Rooms are pure data. The generator creates them and the map carves them.

var id: int = -1
var x: int = 0
var y: int = 0
var w: int = 0
var h: int = 0

func _init(p_id: int = -1, p_rect: Rect2i = Rect2i()) -> void:
	id = p_id
	x = p_rect.position.x
	y = p_rect.position.y
	w = p_rect.size.x
	h = p_rect.size.y

func rect() -> Rect2i:
	return Rect2i(x, y, w, h)

func center() -> Vector2i:
	return Vector2i(x + w / 2, y + h / 2)

func area() -> int:
	return w * h

## True when this room overlaps another room, expanded by the padding.
func overlaps(p_other: Room, p_padding: int = 1) -> bool:
	var a := rect()
	var b := p_other.rect()
	return a.grow(p_padding).intersects(b)

## Returns a random walkable cell inside the room.
func random_cell(p_rng: SeededRng) -> Vector2i:
	return Vector2i(
		p_rng.next_int_range(x + 1, x + w - 2),
		p_rng.next_int_range(y + 1, y + h - 2)
	)
