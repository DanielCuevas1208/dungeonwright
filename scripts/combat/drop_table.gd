class_name DropTable
extends RefCounted
## A weighted loot table.
##
## A table has a list of entries. Each entry names an item, a weight, and
## a count range. Rolls are deterministic when the table uses a seeded
## RNG, so tests can assert exact results.

var entries: Array = []
var rng: SeededRng = null

## Creates a table from a list of entry dictionaries and an RNG.
static func from_entries(p_entries: Array, p_rng: SeededRng) -> DropTable:
	var table := DropTable.new()
	table.entries = p_entries
	table.rng = p_rng
	return table

## Rolls once and returns the dropped item, or null for a miss.
func roll(p_rng: SeededRng = null) -> Drop:
	if entries.is_empty():
		return null
	var active_rng := p_rng if p_rng != null else rng
	if active_rng == null:
		return null
	var weights: Array = []
	for entry in entries:
		weights.append(entry.weight)
	var index := active_rng.weighted_index(weights)
	var entry: Dictionary = entries[index]
	return Drop.new(entry.item, active_rng.next_int_range(entry.min, entry.max))

## Rolls up to p_times times and returns every drop.
func roll_many(p_times: int, p_rng: SeededRng = null) -> Array[Drop]:
	var drops: Array[Drop] = []
	for i in p_times:
		var drop := roll(p_rng)
		if drop != null:
			drops.append(drop)
	return drops

## The sum of all weights. Useful for balance checks.
func total_weight() -> float:
	var total := 0.0
	for entry in entries:
		total += entry.weight
	return total

## The probability that one roll returns a specific item.
func probability_of(p_item: StringName) -> float:
	if total_weight() <= 0.0:
		return 0.0
	var weight := 0.0
	for entry in entries:
		if entry.item == p_item:
			weight += entry.weight
	return weight / total_weight()
