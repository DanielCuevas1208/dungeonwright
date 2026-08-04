class_name Descent
extends RefCounted
## Deterministic seed chain for a multi-floor run.
##
## A run starts from one seed. Every floor uses a child seed derived
## from the run seed with a fixed mixer. The chain touches no platform
## state, so a single seed replays every floor in the same order.

## Returns the generation seed for a floor in a run. Floors start at 1.
static func floor_seed(p_run_seed: int, p_floor: int) -> int:
	var value := p_run_seed & SeededRng.SEED_MASK
	for i in maxi(0, p_floor - 1):
		value = _mix(value)
	return value & SeededRng.SEED_MASK

## The number of floors a run covers for the given biome.
static func floor_count(p_config: DungeonConfig) -> int:
	return maxi(1, p_config.max_floors)

## Monster density for a floor. Deeper floors are denser.
static func monster_density(p_config: DungeonConfig, p_floor: int) -> float:
	return clampf(
		p_config.monster_density + 0.04 * float(p_floor - 1),
		0.0, 1.0
	)

## Monster cap for a floor. Deeper floors hold more monsters.
static func monster_cap(p_config: DungeonConfig, p_floor: int) -> int:
	return p_config.monster_cap + (p_floor - 1) * 2

## Mixes one floor seed into the next with a fixed integer hash.
static func _mix(p_value: int) -> int:
	var x := (p_value + 0x9E3779B9) & 0xFFFFFFFF
	x = ((x ^ (x >> 16)) * 0x21F0AAAD) & 0xFFFFFFFF
	x = ((x ^ (x >> 15)) * 0x735A2D97) & 0xFFFFFFFF
	return (x ^ (x >> 15)) & 0xFFFFFFFF
