class_name RunProgression
extends RefCounted
## Run-level rules for the multi-floor descent.
##
## A run is a descent through a fixed number of floors. Every floor gets
## its own map, its own biome, and a seed derived from the run seed.
## The class holds the pure math that makes the descent deterministic
## and testable without touching the scene tree.

## How many floors a run covers. The exit of the last floor is the goal.
const TOTAL_FLOORS := 3

## Health restored to the hero when they descend to the next floor.
const DESCEND_HEAL := 25

## Returns the seed used to generate a specific floor of a run.
static func floor_seed(p_run_seed: int, p_floor: int) -> int:
	return (p_run_seed ^ (p_floor * 0x5EED4F2)) & SeededRng.SEED_MASK

## Returns the biome that governs a floor.
## The choice depends only on the run seed and the floor number.
static func biome_for_floor(p_run_seed: int, p_floor: int) -> DungeonConfig:
	return Biomes.random(SeededRng.new(floor_seed(p_run_seed, p_floor)))

## True when the floor is the last floor of a run.
static func is_final_floor(p_floor: int) -> bool:
	return p_floor >= TOTAL_FLOORS - 1

## Multiplier for monster hit points on a floor.
static func monster_health_scale(p_floor: int) -> float:
	return 1.0 + float(p_floor) * 0.3

## Multiplier for monster damage on a floor.
static func monster_damage_scale(p_floor: int) -> float:
	return 1.0 + float(p_floor) * 0.2

## Multiplier for the share of rooms that hold monsters.
static func density_multiplier(p_floor: int) -> float:
	return 1.0 + float(p_floor) * 0.15

## Extra monsters the generator may place on a floor.
static func cap_bonus(p_floor: int) -> int:
	return p_floor * 2
