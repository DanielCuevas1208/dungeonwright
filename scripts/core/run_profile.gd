class_name RunProfile
extends RefCounted
## Defines the shape of a full run.
##
## A run spans several floors. Each floor is a fresh dungeon built from
## a seed derived from the run seed. The profile scales the biome rules
## so deeper floors carry more monsters and tougher hero stats. All the
## math is deterministic, so a run seed replays every floor exactly.

const TOTAL_FLOORS := 3

const FLOOR_SEED_TWEAK := 0x9E3779B1

## Extra monster density per floor beyond the first.
const MONSTER_DENSITY_STEP := 0.12
## Extra monster slots per floor beyond the first.
const MONSTER_CAP_STEP := 3
## Extra hero max health per floor beyond the first.
const HEALTH_STEP := 20
## Extra hero damage per floor beyond the first.
const DAMAGE_STEP := 2
## Extra doors per floor beyond the first.
const DOOR_STEP := 1
## Door count never rises above this bound.
const MAX_DOOR_COUNT := 5

## The number of floors in one run.
static func total_floors() -> int:
	return TOTAL_FLOORS

## True when the given floor is the deepest floor of the run.
static func is_final_floor(p_floor: int) -> bool:
	return p_floor >= TOTAL_FLOORS

## Returns the deterministic seed for one floor of a run.
static func floor_seed(p_run_seed: int, p_floor: int) -> int:
	return (p_run_seed ^ (p_floor * FLOOR_SEED_TWEAK)) & SeededRng.SEED_MASK

## Returns a copy of the biome scaled for the given floor.
static func config_for(p_biome: DungeonConfig, p_floor: int) -> DungeonConfig:
	var steps := maxi(p_floor, 1) - 1
	var config := p_biome.clone()
	config.monster_density = minf(0.9, config.monster_density + MONSTER_DENSITY_STEP * steps)
	config.monster_cap += MONSTER_CAP_STEP * steps
	config.starting_health += HEALTH_STEP * steps
	config.player_damage += DAMAGE_STEP * steps
	config.door_count_min = mini(config.door_count_min + DOOR_STEP * steps, MAX_DOOR_COUNT)
	config.door_count_max = mini(config.door_count_max + DOOR_STEP * steps, MAX_DOOR_COUNT)
	return config
