class_name Shrine
extends RefCounted
## A generated shrine placed inside one dungeon room.
##
## The generator owns position and offer selection. The live actor owns the
## used state after the scene controller turns this record into a shrine.

var id: int = -1
var position: Vector2i = Vector2i.ZERO
var offer_id: StringName = ShrineOffer.MIGHT

func _init(
	p_id: int = -1,
	p_position: Vector2i = Vector2i.ZERO,
	p_offer_id: StringName = ShrineOffer.MIGHT
) -> void:
	id = p_id
	position = p_position
	offer_id = p_offer_id

## Returns the interaction copy for this shrine.
func prompt_text() -> String:
	return ShrineOffer.prompt_text(offer_id)
