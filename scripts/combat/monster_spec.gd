class_name MonsterSpec
extends RefCounted
## Static definition of a monster type.
##
## A spec carries the combat stats, the behaviour name, the art key, and
## the loot table. All monsters of one type share a spec, while each
## living monster has its own instance of the stats.

const AI := {
	"chaser": &"chaser",
	"stalker": &"stalker",
	"sentry": &"sentry",
	"shooter": &"shooter",
}

var id: StringName = &""
var display_name: String = ""
var ai: StringName = AI.chaser
var sprite_key: String = ""
var aggro_range: float = 8.0
var stats: CombatStats = null
var drop_table: DropTable = null
## The projectile id fired by shooter monsters.
var projectile: StringName = &""
## The distance in tiles at which shooters prefer to fire.
var preferred_range: float = 5.0
## The distance in tiles at which shooters start to retreat.
var min_range: float = 2.0

## True when this spec is valid for spawning.
func is_valid() -> bool:
	if id == &"" or stats == null or drop_table == null:
		return false
	if ai == AI.shooter and (projectile == &"" or preferred_range <= 0.0):
		return false
	return true
