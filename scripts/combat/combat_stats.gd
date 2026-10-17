class_name CombatStats
extends RefCounted
## A named set of combat numbers.
##
## Both the player and every monster carry one of these. Values are
## clamped so tests and game logic never see invalid stats.

var max_health: int = 1
var health: int = 1
var damage: int = 1
var defence: int = 0
var speed: float = 1.0
var attack_range: float = 1.0
var attack_cooldown: float = 1.0

## Creates a stat block from a dictionary of overrides.
static func make(p_base: Dictionary) -> CombatStats:
	var stats := CombatStats.new()
	for key in p_base:
		stats.set(key, p_base[key])
	return stats

## True when the actor is dead.
func is_dead() -> bool:
	return health <= 0

## Applies damage and returns the damage actually dealt.
func take_damage(p_amount: int) -> int:
	var dealt := maxi(0, mini(p_amount, health))
	health -= dealt
	return dealt

## Restores health and returns the amount actually restored.
func heal(p_amount: int) -> int:
	var gained := mini(p_amount, max_health - health)
	health += gained
	return gained
