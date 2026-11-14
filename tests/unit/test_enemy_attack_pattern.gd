extends GutTest
## The melee telegraph has fixed windup, attack, and recovery phases.

func test_pattern_starts_in_ready_phase() -> void:
	var pattern := EnemyAttackPattern.new()
	assert_eq(pattern.phase, EnemyAttackPattern.Phase.READY)
	assert_false(pattern.is_active())

func test_start_enters_windup_without_attacking() -> void:
	var pattern := EnemyAttackPattern.new()
	assert_true(pattern.start())
	assert_eq(pattern.phase, EnemyAttackPattern.Phase.WINDUP)
	assert_eq(pattern.time_remaining, EnemyAttackPattern.WINDUP_DURATION)
	assert_true(pattern.is_active())

func test_windup_delays_attack_boundary() -> void:
	var pattern := EnemyAttackPattern.new()
	pattern.start()
	var entered := pattern.advance(EnemyAttackPattern.WINDUP_DURATION - 0.01)
	assert_eq(entered, [])
	assert_eq(pattern.phase, EnemyAttackPattern.Phase.WINDUP)
	assert_almost_eq(pattern.progress(), 0.9777, 0.001)

func test_attack_and_recovery_have_deterministic_boundaries() -> void:
	var pattern := EnemyAttackPattern.new()
	pattern.start()
	var entered_attack := pattern.advance(EnemyAttackPattern.WINDUP_DURATION)
	assert_eq(entered_attack, [EnemyAttackPattern.Phase.ATTACK])
	assert_eq(pattern.phase, EnemyAttackPattern.Phase.ATTACK)
	var entered_recovery := pattern.advance(EnemyAttackPattern.ATTACK_DURATION)
	assert_eq(entered_recovery, [EnemyAttackPattern.Phase.RECOVERY])
	assert_eq(pattern.phase, EnemyAttackPattern.Phase.RECOVERY)
	var entered_ready := pattern.advance(EnemyAttackPattern.RECOVERY_DURATION)
	assert_eq(entered_ready, [EnemyAttackPattern.Phase.READY])
	assert_eq(pattern.phase, EnemyAttackPattern.Phase.READY)
	assert_false(pattern.is_active())

func test_large_step_reports_every_phase_it_crosses() -> void:
	var pattern := EnemyAttackPattern.new()
	pattern.start()
	var entered := pattern.advance(1.0)
	assert_eq(
		entered,
		[
			EnemyAttackPattern.Phase.ATTACK,
			EnemyAttackPattern.Phase.RECOVERY,
			EnemyAttackPattern.Phase.READY,
		]
	)

func test_pattern_cannot_restart_before_recovery() -> void:
	var pattern := EnemyAttackPattern.new()
	pattern.start()
	assert_false(pattern.start())
