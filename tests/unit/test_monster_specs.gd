extends GutTest
## Scaled monster specs must keep valid stats and grow with depth.

func test_scaled_returns_source_for_first_floor() -> void:
	var spec := MonsterSpecs.skeleton()
	assert_eq(MonsterSpecs.scaled(spec, 0), spec)

func test_scaled_boosts_health_and_damage() -> void:
	var spec := MonsterSpecs.skeleton()
	var deep := MonsterSpecs.scaled(spec, 3)
	assert_gt(deep.stats.max_health, spec.stats.max_health)
	assert_gt(deep.stats.damage, spec.stats.damage)

func test_scaled_health_matches_max_at_spawn() -> void:
	var spec := MonsterSpecs.golem()
	var deep := MonsterSpecs.scaled(spec, 2)
	assert_eq(deep.stats.health, deep.stats.max_health)

func test_scaled_preserves_identity() -> void:
	var spec := MonsterSpecs.golem()
	var deep := MonsterSpecs.scaled(spec, 2)
	assert_eq(deep.id, spec.id)
	assert_eq(deep.ai, spec.ai)
	assert_eq(deep.sprite_key, spec.sprite_key)
	assert_eq(deep.drop_table, spec.drop_table)
	assert_true(deep.is_valid())

func test_scaled_does_not_mutate_source() -> void:
	var spec := MonsterSpecs.wisp()
	var before := spec.stats.max_health
	var deep := MonsterSpecs.scaled(spec, 4)
	assert_eq(spec.stats.max_health, before)
	assert_ne(deep.stats.max_health, before)
