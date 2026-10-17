class_name RunHistory
extends RefCounted
## Bounded records of completed runs.

const MAX_ENTRIES := 5
const STORAGE_VERSION := 1
const STORAGE_PATH := "user://dungeonwright_run_history.json"

var _records: Array[Dictionary] = []
var storage_path := STORAGE_PATH

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

## Loads records from a versioned JSON file.
##
## A missing file is a valid empty history. Invalid data leaves the current
## records unchanged and returns false.
func load_from_disk(p_path: String = STORAGE_PATH) -> bool:
	storage_path = p_path
	if not FileAccess.file_exists(p_path):
		_records.clear()
		return true
	var file := FileAccess.open(p_path, FileAccess.READ)
	if file == null:
		return false
	var payload_text := file.get_as_text()
	file.close()
	var payload: Variant = JSON.parse_string(payload_text)
	if not payload is Dictionary:
		return false
	if int(payload.get("version", -1)) != STORAGE_VERSION:
		return false
	var raw_records: Variant = payload.get("records", null)
	if not raw_records is Array:
		return false
	var loaded_records: Array[Dictionary] = []
	for raw_record: Variant in raw_records:
		if not raw_record is Dictionary:
			continue
		var normalized := _normalize_record(raw_record)
		if normalized.is_empty():
			continue
		loaded_records.append(normalized)
		if loaded_records.size() == MAX_ENTRIES:
			break
	_records = loaded_records
	return true

## Saves the current records as versioned JSON.
##
## The in-memory history remains available when the file cannot be written.
func save_to_disk(p_path: String = "") -> bool:
	if not p_path.is_empty():
		storage_path = p_path
	var file := FileAccess.open(storage_path, FileAccess.WRITE)
	if file == null:
		return false
	var payload := {
		"version": STORAGE_VERSION,
		"records": records(),
	}
	file.store_string(JSON.stringify(payload))
	var write_error := file.get_error()
	file.close()
	return write_error == OK

## Returns copied records so callers cannot change the history.
func records() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for record in _records:
		result.append(record.duplicate(true))
	return result

## Returns the number of completed runs in the history.
func size() -> int:
	return _records.size()

## Returns true when no completed run is available.
func is_empty() -> bool:
	return _records.is_empty()

## Clears the current in-memory history.
func clear() -> void:
	_records.clear()

## Clears the in-memory history and persists the empty state.
##
## A failed write restores the records so the caller does not lose them.
func clear_saved() -> bool:
	var previous_records := _records.duplicate(true)
	_records.clear()
	if save_to_disk():
		return true
	_records = previous_records
	return false

## Formats the history for the result screen.
func format_records() -> String:
	if _records.is_empty():
		return "No completed runs saved."
	var lines: Array[String] = []
	for index in _records.size():
		lines.append(_format_record(_records[index], index + 1))
	return "\n".join(lines)

func _format_record(p_record: Dictionary, p_number: int) -> String:
	var outcome := "WON" if p_record.get("won", false) else "LOST"
	var time := maxf(0.0, float(p_record.get("time", 0.0)))
	var minutes := int(time) / 60
	var seconds := int(time) % 60
	return "%d. %s | %s | F%d/%d | %dc | %d:%02d | dmg %d blk %d bomb %d" % [
		p_number,
		outcome,
		p_record.get("seed", "------"),
		p_record.get("floor_reached", 0),
		p_record.get("floor_count", 0),
		p_record.get("coins", 0),
		minutes,
		seconds,
		p_record.get("damage_dealt", 0),
		p_record.get("damage_blocked", 0),
		p_record.get("bombs_thrown", 0),
	]

func _normalize_record(p_record: Dictionary) -> Dictionary:
	var won_value: Variant = p_record.get("won", null)
	var seed_value: Variant = p_record.get("seed", null)
	if typeof(won_value) != TYPE_BOOL or typeof(seed_value) != TYPE_STRING:
		return {}
	var floor_reached := _non_negative_int(p_record.get("floor_reached", null))
	var floor_count := _non_negative_int(p_record.get("floor_count", null))
	var coins := _non_negative_int(p_record.get("coins", null))
	var time := _non_negative_float(p_record.get("time", null))
	var damage_dealt := _non_negative_int(p_record.get("damage_dealt", 0))
	var damage_blocked := _non_negative_int(p_record.get("damage_blocked", 0))
	var bombs_thrown := _non_negative_int(p_record.get("bombs_thrown", 0))
	if floor_reached < 0 or floor_count < 0 or coins < 0 or time < 0.0:
		return {}
	if damage_dealt < 0 or damage_blocked < 0 or bombs_thrown < 0:
		return {}
	return {
		"won": won_value,
		"seed": seed_value,
		"floor_reached": floor_reached,
		"floor_count": floor_count,
		"coins": coins,
		"time": time,
		"damage_dealt": damage_dealt,
		"damage_blocked": damage_blocked,
		"bombs_thrown": bombs_thrown,
	}

func _non_negative_int(p_value: Variant) -> int:
	if typeof(p_value) != TYPE_INT and typeof(p_value) != TYPE_FLOAT:
		return -1
	var value := int(p_value)
	return value if value >= 0 else -1

func _non_negative_float(p_value: Variant) -> float:
	if typeof(p_value) != TYPE_INT and typeof(p_value) != TYPE_FLOAT:
		return -1.0
	var value := float(p_value)
	return value if value >= 0.0 else -1.0
