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
	"archer": &"archer",
	"boss": &"boss",
}

var id: StringName = &""
var display_name: String = ""
var ai: StringName = AI.chaser
var sprite_key: String = ""
var aggro_range: float = 8.0
var stats: CombatStats = null
var drop_table: DropTable = null
## Projectile travel speed in tiles per second. Zero means melee only.
var projectile_speed: float = 0.0
## Maximum travel distance of a fired projectile, in tiles.
var projectile_range: int = 0
## How many bolts a ranged attack fires in a fan. One for archers.
var projectile_volley: int = 1
## The health fraction that triggers an enrage. Zero disables enrage.
var enrage_health_ratio: float = 0.0
## Movement speed multiplier while enraged.
var enrage_speed_multiplier: float = 1.0
## Attack cooldown multiplier while enraged.
var enrage_cooldown_multiplier: float = 1.0

## True when this spec is valid for spawning.
func is_valid() -> bool:
	return id != &"" and stats != null and drop_table != null

## Returns a copy of this spec with scaled health and damage.
## Deeper floors use the result so monsters grow stronger.
## A scale at or below 1.0 returns this spec unchanged.
func scaled(p_scale: float) -> MonsterSpec:
	if p_scale <= 1.0:
		return self
	var copy := MonsterSpec.new()
	copy.id = id
	copy.display_name = display_name
	copy.ai = ai
	copy.sprite_key = sprite_key
	copy.aggro_range = aggro_range
	copy.stats = CombatStats.make({
		"max_health": maxi(1, roundi(stats.max_health * p_scale)),
		"health": maxi(1, roundi(stats.max_health * p_scale)),
		"damage": maxi(1, roundi(stats.damage * p_scale)),
		"speed": stats.speed,
		"attack_range": stats.attack_range,
		"attack_cooldown": stats.attack_cooldown,
	})
	copy.drop_table = drop_table
	copy.projectile_speed = projectile_speed
	copy.projectile_range = projectile_range
	copy.projectile_volley = projectile_volley
	copy.enrage_health_ratio = enrage_health_ratio
	copy.enrage_speed_multiplier = enrage_speed_multiplier
	copy.enrage_cooldown_multiplier = enrage_cooldown_multiplier
	return copy
