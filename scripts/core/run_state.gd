class_name RunState
extends RefCounted
## Shared state of the current dungeon run.
##
## Kept as static values so the scene controller can read and write the
## run summary without coupling the overlays to the world scene.

enum RunStatus { IDLE, ACTIVE, WON, LOST }

static var seed_value: int = 0
static var seed_string: String = ""
static var biome_id: StringName = &""
static var status: RunStatus = RunStatus.IDLE
static var started_at: float = 0.0
static var finished_at: float = 0.0
static var floor: int = 1
static var floors_total: int = 1

## Elapsed play time in seconds for the current run.
static func elapsed() -> float:
	if status == RunStatus.ACTIVE:
		return Time.get_ticks_msec() / 1000.0 - started_at
	if started_at > 0.0:
		return finished_at - started_at
	return 0.0
