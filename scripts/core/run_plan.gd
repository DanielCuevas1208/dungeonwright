class_name RunPlan
extends RefCounted
## The floor sequence of a single run.
##
## A run has a fixed number of floors. Every floor gets its own seed,
## derived from the run seed, and a biome chosen in a stable cycle.
## Deeper floors scale the biome, so each descent is harder than the
## last. The plan is pure data, so tests can assert determinism.

const DEFAULT_FLOOR_COUNT := 4

var floor_count: int = DEFAULT_FLOOR_COUNT

func _init(p_floor_count: int = DEFAULT_FLOOR_COUNT) -> void:
	floor_count = maxi(1, p_floor_count)

## Returns one entry per floor: { index, seed, biome }.
func floors(p_run_seed: int) -> Array[Dictionary]:
	var biomes := Biomes.all()
	var plan: Array[Dictionary] = []
	for index in floor_count:
		var floor_seed := p_run_seed if index == 0 else SeededRng.derive(p_run_seed, index)
		var biome := Biomes.scaled(biomes[index % biomes.size()], index)
		plan.append({
			"index": index,
			"seed": floor_seed & SeededRng.SEED_MASK,
			"biome": biome,
		})
	return plan

## True when the floor index is the last floor of the run.
func is_final(p_floor_index: int) -> bool:
	return p_floor_index >= floor_count - 1
