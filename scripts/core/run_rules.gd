class_name RunRules
extends RefCounted
## Rules that shape a complete dungeon run.
##
## A run descends through a fixed number of floors. Every floor is a new
## solvable dungeon of the same biome. The hero keeps health and loot
## between floors. Monsters grow stronger on each descent.

const DEFAULT_FLOORS := 3
const FLOOR_MIX := 0x9E3779B9

var floor_count: int = DEFAULT_FLOORS
## Fraction of missing health restored when the hero descends.
var heal_between_floors: float = 0.5
## Extra monster health and damage per floor, as a fraction of the base.
var difficulty_per_floor: float = 0.25

## The dungeon seed for a floor. Floor 0 uses the run seed unchanged.
static func floor_seed(p_run_seed: int, p_floor: int) -> int:
	if p_floor <= 0:
		return p_run_seed & SeededRng.SEED_MASK
	return (p_run_seed ^ (p_floor * FLOOR_MIX)) & SeededRng.SEED_MASK

## True when reaching the exit on this floor wins the run.
func is_final_floor(p_floor: int) -> bool:
	return p_floor >= floor_count - 1

## True when this floor holds the boss that guards the exit.
## The final floor is always a boss floor.
func is_boss_floor(p_floor: int) -> bool:
	return is_final_floor(p_floor)

## The monster strength multiplier for a floor. Floor 0 is 1.0.
func monster_scale(p_floor: int) -> float:
	return 1.0 + float(p_floor) * difficulty_per_floor

## Restores a fraction of the hero's missing health on a descent.
## Returns the health actually restored.
func heal_between(p_stats: CombatStats) -> int:
	var missing := p_stats.max_health - p_stats.health
	if missing <= 0:
		return 0
	return p_stats.heal(maxi(1, roundi(missing * heal_between_floors)))
