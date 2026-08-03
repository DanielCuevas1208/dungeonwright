class_name RunPlan
extends RefCounted
## The floor plan of a dungeon run.
##
## A run descends through a fixed number of floors. Every floor keeps the
## same base seed, so the whole run repeats exactly from one seed. The
## floor index mixes into the generator seed, so each floor builds a
## different dungeon. The biome changes as the hero goes deeper.
## The plan is pure data and deterministic, so tests can assert it.

const FLOOR_MIX := 0x9E3779B9
const DEFAULT_FLOORS := 3

var base_seed: int = 0
var floors_total: int = DEFAULT_FLOORS

## Creates a plan for a run. P floors the run has, at least one.
static func make(p_base_seed: int, p_floors: int = DEFAULT_FLOORS) -> RunPlan:
	var plan := RunPlan.new()
	plan.base_seed = p_base_seed & SeededRng.SEED_MASK
	plan.floors_total = maxi(1, p_floors)
	return plan

## The generator seed for a zero-based floor index.
func floor_seed(p_floor_index: int) -> int:
	return (base_seed ^ (p_floor_index * FLOOR_MIX)) & SeededRng.SEED_MASK

## The biome for a zero-based floor index.
func biome_for(p_floor_index: int) -> DungeonConfig:
	return Biomes.random(SeededRng.new(floor_seed(p_floor_index) ^ 0x5EED))
