class_name RunHistory
extends RefCounted
## Bounded in-session records of completed runs.

const MAX_ENTRIES := 5

var _records: Array[Dictionary] = []

## Adds one completed run and keeps the newest records first.
func add_result(
	p_won: bool,
	p_seed: String,
	p_floor_reached: int,
	p_floor_count: int,
	p_coins: int,
	p_time: float,
	p_stats: RunStats = null
) -> void:
	var record := {
		"won": p_won,
		"seed": p_seed,
		"floor_reached": maxi(0, p_floor_reached),
		"floor_count": maxi(0, p_floor_count),
		"coins": maxi(0, p_coins),
		"time": maxf(0.0, p_time),
		"damage_dealt": 0,
		"damage_blocked": 0,
		"bombs_thrown": 0,
	}
	if p_stats != null:
		record.merge(p_stats.snapshot(), true)
	_records.push_front(record)
	if _records.size() > MAX_ENTRIES:
		_records.resize(MAX_ENTRIES)

## Returns copied records so callers cannot change the history.
func records() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for record in _records:
		result.append(record.duplicate(true))
	return result

## Returns the number of completed runs in the session.
func size() -> int:
	return _records.size()

## Returns true when no completed run is available.
func is_empty() -> bool:
	return _records.is_empty()

## Clears the current session history.
func clear() -> void:
	_records.clear()

## Formats the history for the result screen.
func format_records() -> String:
	if _records.is_empty():
		return "No completed runs this session."
	var lines: Array[String] = []
	for index in _records.size():
		lines.append(_format_record(_records[index], index + 1))
	return "\n".join(lines)

func _format_record(p_record: Dictionary, p_number: int) -> String:
	var outcome := "WON" if p_record.get("won", false) else "LOST"
	var time := maxf(0.0, float(p_record.get("time", 0.0)))
	var minutes := int(time) / 60
	var seconds := int(time) % 60
	return "%d. %s | %s | F%d/%d | %dc | %d:%02d" % [
		p_number,
		outcome,
		p_record.get("seed", "------"),
		p_record.get("floor_reached", 0),
		p_record.get("floor_count", 0),
		p_record.get("coins", 0),
		minutes,
		seconds,
	]
