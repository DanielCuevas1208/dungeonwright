class_name RunStats
extends RefCounted
## Counters shown when a run ends.

var damage_dealt := 0
var damage_blocked := 0
var bombs_thrown := 0

## Clears all counters for a new run.
func reset() -> void:
	damage_dealt = 0
	damage_blocked = 0
	bombs_thrown = 0

## Records health removed from an enemy.
func record_damage_dealt(p_amount: int) -> void:
	damage_dealt += maxi(0, p_amount)

## Records damage absorbed by the hero's defence.
func record_damage_blocked(p_amount: int) -> void:
	damage_blocked += maxi(0, p_amount)

## Records a bomb that the hero throws.
func record_bomb_thrown() -> void:
	bombs_thrown += 1

## Returns a copy of the counters for a completed-run record.
func snapshot() -> Dictionary:
	return {
		"damage_dealt": damage_dealt,
		"damage_blocked": damage_blocked,
		"bombs_thrown": bombs_thrown,
	}
