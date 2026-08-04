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

func test_blast_radius_hits_the_center_cell() -> void:
	assert_true(Combat.in_blast_radius(Vector2i(5, 5), Vector2i(5, 5), 2))

func test_blast_radius_covers_the_square_ring() -> void:
	var center := Vector2i(5, 5)
	assert_true(Combat.in_blast_radius(center, Vector2i(7, 5), 2))
	assert_true(Combat.in_blast_radius(center, Vector2i(7, 7), 2))
	assert_true(Combat.in_blast_radius(center, Vector2i(3, 5), 2))
	assert_true(Combat.in_blast_radius(center, Vector2i(5, 3), 2))

func test_blast_radius_misses_cells_outside() -> void:
	var center := Vector2i(5, 5)
	assert_false(Combat.in_blast_radius(center, Vector2i(8, 5), 2))
	assert_false(Combat.in_blast_radius(center, Vector2i(8, 8), 2))
	assert_false(Combat.in_blast_radius(center, Vector2i(2, 2), 2))

func test_zero_blast_radius_only_hits_the_center() -> void:
	assert_true(Combat.in_blast_radius(Vector2i(3, 3), Vector2i(3, 3), 0))
	assert_false(Combat.in_blast_radius(Vector2i(3, 3), Vector2i(4, 3), 0))

func test_stats_make_copies_values() -> void:
	var first := CombatStats.make({ "max_health": 40, "health": 40, "damage": 9 })
	var second := CombatStats.make({ "max_health": 40, "health": 40, "damage": 9 })
	first.take_damage(10)
	assert_eq(second.health, 40)
	assert_eq(first.health, 30)
