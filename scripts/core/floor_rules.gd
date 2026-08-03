class_name FloorRules
extends RefCounted
## Defines the floor progression of a run.
##
## A run spans a fixed number of floors. Every floor derives a fresh seed
## from the run seed, so the whole descent repeats from one seed. Deeper
## floors scale the monster pressure, so the run grows harder as you go.

const FLOOR_COUNT := 5
const SEED_MASK := 0xFFFFFF
const SEED_MIX := 2654435761

## Returns the deterministic seed of the given floor inside a run.
static func seed_for(p_run_seed: int, p_floor: int) -> int:
	return (p_run_seed + p_floor * SEED_MIX) & SEED_MASK

## True when the floor is the last one of a run.
static func is_final(p_floor: int) -> bool:
	return p_floor >= FLOOR_COUNT

## Returns a copy of a biome scaled for the given floor.
## Monsters grow stronger and denser with every descent.
static func scaled(p_biome: DungeonConfig, p_floor: int) -> DungeonConfig:
	var config := DungeonConfig.new()
	config.id = p_biome.id
	config.display_name = p_biome.display_name
	config.description = p_biome.description
	config.width = p_biome.width
	config.height = p_biome.height
	config.room_count_min = p_biome.room_count_min
	config.room_count_max = p_biome.room_count_max
	config.room_min = p_biome.room_min
	config.room_max = p_biome.room_max
	config.corridor_style = p_biome.corridor_style
	config.loop_chance = p_biome.loop_chance
	config.door_count_min = p_biome.door_count_min
	config.door_count_max = mini(6, p_biome.door_count_max + (p_floor - 1) / 2)
	config.monster_density = minf(0.9, p_biome.monster_density + 0.05 * (p_floor - 1))
	config.monster_cap = p_biome.monster_cap + (p_floor - 1) / 2
	config.monster_table = p_biome.monster_table
	config.starting_health = p_biome.starting_health
	config.player_damage = p_biome.player_damage
	config.palette = p_biome.palette
	config.monster_health_scale = 1.0 + 0.15 * (p_floor - 1)
	config.monster_damage_scale = 1.0 + 0.1 * (p_floor - 1)
	return config
