class_name ItemSpec
extends RefCounted
## Static definition of a collectible item.
##
## An item has an id, a display name, a description, a category, and the
## art key used to draw its sprite. The registry is the single source of
## truth for item ids, so the player, the loot tables, and the renderer
## all agree on what exists.

enum Category {
	TREASURE,
	CONSUMABLE,
	UPGRADE,
}

var id: StringName = &""
var display_name: String = ""
var description: String = ""
var category: Category = Category.TREASURE
var sprite_key: StringName = &""
