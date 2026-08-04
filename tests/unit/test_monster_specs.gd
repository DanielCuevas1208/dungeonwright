extends GutTest
## Scaled monster specs power the deeper floors.

func test_scale_one_returns_the_same_spec() -> void:
	var spec := MonsterSpecs.skeleton()
	assert_true(spec.scaled(1.0) == spec)

func test_scale_below_one_returns_the_same_spec() -> void:
	var spec := MonsterSpecs.crawler()
	assert_true(spec.scaled(0.5) == spec)

func test_scaled_stats_round_to_integers() -> void:
	var spec := MonsterSpecs.skeleton()
	var scaled := spec.scaled(1.5)
	assert_eq(scaled.stats.max_health, roundi(spec.stats.max_health * 1.5))
	assert_eq(scaled.stats.damage, roundi(spec.stats.damage * 1.5))

func test_scaled_health_and_damage_increase() -> void:
	var spec := MonsterSpecs.skeleton()
	var scaled := spec.scaled(2.0)
	assert_gt(scaled.stats.max_health, spec.stats.max_health)
	assert_gt(scaled.stats.damage, spec.stats.damage)

func test_scaled_keeps_behaviour_and_loot() -> void:
	var spec := MonsterSpecs.shambler()
	var scaled := spec.scaled(1.5)
	assert_eq(scaled.ai, spec.ai)
	assert_eq(scaled.sprite_key, spec.sprite_key)
	assert_eq(scaled.drop_table, spec.drop_table)

func test_scaled_keeps_speed_and_cooldown() -> void:
	var spec := MonsterSpecs.crawler()
	var scaled := spec.scaled(2.0)
	assert_eq(scaled.stats.speed, spec.stats.speed)
	assert_eq(scaled.stats.attack_cooldown, spec.stats.attack_cooldown)

func test_every_monster_can_scale() -> void:
	for spec in MonsterSpecs.all():
		var scaled := spec.scaled(1.5)
		assert_true(scaled.is_valid(), "scaled %s is invalid" % spec.id)
