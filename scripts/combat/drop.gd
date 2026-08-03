class_name Drop
extends RefCounted
## A single item dropped from a loot roll.

var item: StringName = &""
var count: int = 1

func _init(p_item: StringName = &"", p_count: int = 1) -> void:
	item = p_item
	count = p_count
