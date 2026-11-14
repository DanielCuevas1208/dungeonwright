class_name EnemyAttackPattern
extends RefCounted
## A deterministic melee attack cycle.
##
## The cycle gives the player time to react before damage lands. The actor
## owns the damage decision, so leaving the attack range cancels the hit.

enum Phase { READY, WINDUP, ATTACK, RECOVERY }

const MELEE_SLAM := &"melee_slam"
const WINDUP_DURATION := 0.45
const ATTACK_DURATION := 0.12
const RECOVERY_DURATION := 0.28

var phase: Phase = Phase.READY
var time_remaining := 0.0

## Starts a new cycle when the previous cycle is ready.
func start() -> bool:
	if phase != Phase.READY:
		return false
	phase = Phase.WINDUP
	time_remaining = WINDUP_DURATION
	return true

## Advances the cycle and returns every phase entered during this step.
func advance(p_delta: float) -> Array[int]:
	var entered: Array[int] = []
	var remaining_delta := maxf(0.0, p_delta)
	while remaining_delta > 0.0 and phase != Phase.READY:
		var consumed := minf(remaining_delta, time_remaining)
		time_remaining -= consumed
		remaining_delta -= consumed
		if time_remaining > 0.000001:
			continue
		match phase:
			Phase.WINDUP:
				phase = Phase.ATTACK
				time_remaining = ATTACK_DURATION
				entered.append(Phase.ATTACK)
			Phase.ATTACK:
				phase = Phase.RECOVERY
				time_remaining = RECOVERY_DURATION
				entered.append(Phase.RECOVERY)
			Phase.RECOVERY:
				phase = Phase.READY
				time_remaining = 0.0
				entered.append(Phase.READY)
	return entered

## True while the attack has started but has not recovered.
func is_active() -> bool:
	return phase != Phase.READY

## Returns the progress of the current phase from zero to one.
func progress() -> float:
	match phase:
		Phase.WINDUP:
			return 1.0 - time_remaining / WINDUP_DURATION
		Phase.ATTACK:
			return 1.0
		Phase.RECOVERY:
			return 1.0 - time_remaining / RECOVERY_DURATION
	return 0.0
