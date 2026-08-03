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
}

var id: StringName = &""
var display_name: String = ""
var ai: StringName = AI.chaser
var sprite_key: String = ""
var aggro_range: float = 8.0
var stats: CombatStats = null
var drop_table: DropTable = null

## True when this spec is valid for spawning.
func is_valid() -> bool:
	return id != &"" and stats != null and drop_table != null
