extends GutTest
## Combat math: damage, health, attack ranges, and facing arcs.

func test_damage_is_attack_minus_defence() -> void:
	assert_eq(Combat.compute_damage(15, 4), 11)

func test_damage_never_below_minimum() -> void:
	assert_eq(Combat.compute_damage(3, 50), Combat.MIN_DAMAGE)
	assert_eq(Combat.compute_damage(0, 0), Combat.MIN_DAMAGE)

func test_damage_is_never_negative() -> void:
	for attack in range(0, 30):
		for defence in range(0, 30):
			assert_gte(Combat.compute_damage(attack, defence), 1)

func test_take_damage_clamps_at_zero() -> void:
	var stats := CombatStats.make({ "max_health": 20, "health": 20 })
	var dealt := stats.take_damage(50)
	assert_eq(dealt, 20)
	assert_true(stats.is_dead())
	assert_eq(stats.health, 0)

func test_take_damage_returns_actual_dealt() -> void:
	var stats := CombatStats.make({ "max_health": 20, "health": 20 })
	assert_eq(stats.take_damage(6), 6)
	assert_eq(stats.health, 14)

func test_heal_clamps_at_max() -> void:
	var stats := CombatStats.make({ "max_health": 30, "health": 10 })
	assert_eq(stats.heal(15), 15)
	assert_eq(stats.health, 25)
	assert_eq(stats.heal(100), 5)
	assert_eq(stats.health, 30)

func test_within_attack_range() -> void:
	assert_true(Combat.within_attack_range(1.0, 1.2))
	assert_false(Combat.within_attack_range(4.0, 1.2))

func test_facing_arc_hits_front_and_side() -> void:
	var origin := Vector2i(5, 5)
	assert_true(Combat.in_facing_arc(origin, Vector2i.RIGHT, Vector2i(7, 5)))
	assert_true(Combat.in_facing_arc(origin, Vector2i.RIGHT, Vector2i(6, 4)))
	assert_false(Combat.in_facing_arc(origin, Vector2i.RIGHT, Vector2i(4, 5)))

func test_facing_arc_misses_behind() -> void:
	var origin := Vector2i(5, 5)
	assert_false(Combat.in_facing_arc(origin, Vector2i.UP, Vector2i(6, 7)))

func test_stats_make_copies_values() -> void:
	var first := CombatStats.make({ "max_health": 40, "health": 40, "damage": 9 })
	var second := CombatStats.make({ "max_health": 40, "health": 40, "damage": 9 })
	first.take_damage(10)
	assert_eq(second.health, 40)
	assert_eq(first.health, 30)

func test_can_fire_at_requires_range_and_los() -> void:
	assert_true(Combat.can_fire_at(16.0, 6.0, true))
	assert_false(Combat.can_fire_at(49.0, 6.0, true))
	assert_false(Combat.can_fire_at(16.0, 6.0, false))

func test_should_retreat_when_target_is_close() -> void:
	assert_true(Combat.should_retreat(1.0, 2.0))
	assert_true(Combat.should_retreat(3.9, 2.0))
	assert_false(Combat.should_retreat(5.0, 2.0))

func test_shooter_specs_are_valid() -> void:
	for spec in MonsterSpecs.all():
		if spec.ai != MonsterSpec.AI.shooter:
			continue
		assert_true(spec.is_valid(), "%s is not valid" % spec.id)
		assert_ne(spec.projectile, &"")
		assert_gt(spec.preferred_range, 0.0)
		assert_gte(spec.min_range, 0.0)
		assert_true(ProjectileSpecs.by_id(spec.projectile).is_valid())
