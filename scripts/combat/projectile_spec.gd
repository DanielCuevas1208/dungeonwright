class_name ProjectileSpec
extends RefCounted
## Static definition of a projectile type.
##
## A spec carries the flight speed, the hit damage, the maximum range in
## tiles, and the sprite key. Every ranged monster fires one of these.

var id: StringName = &""
var display_name: String = ""
var sprite_key: String = ""
var speed: float = 0.0
var damage: int = 0
var range: float = 0.0

## True when this spec is valid for spawning.
func is_valid() -> bool:
	return id != &"" and speed > 0.0 and damage > 0 and range > 0.0
