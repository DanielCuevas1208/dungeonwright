extends GutTest
## The warden boss: registration, enrage profile, and loot items.

func test_warden_is_registered_and_is_a_boss() -> void:
	var spec := MonsterSpecs.warden()
	assert_eq(spec.id, &"warden")
	assert_eq(spec.ai, MonsterSpec.AI.boss)
	assert_eq(spec.display_name, "The Warden")

func test_warden_is_part_of_the_registry() -> void:
	var ids: Array[StringName] = []
	for spec in MonsterSpecs.all():
		ids.append(spec.id)
	assert_true(ids.has(&"warden"))

func test_warden_spec_is_valid() -> void:
	assert_true(MonsterSpecs.warden().is_valid())

func test_warden_is_the_tankiest_monster() -> void:
	for spec in MonsterSpecs.all():
		if spec.id == &"warden":
			continue
		assert_lt(spec.stats.max_health, MonsterSpecs.warden().stats.max_health, spec.id)

func test_warden_fires_a_three_bolt_volley() -> void:
	var spec := MonsterSpecs.warden()
	assert_eq(spec.projectile_volley, 3)
	assert_gt(spec.projectile_range, 0)
	assert_gt(spec.projectile_speed, 0.0)

func test_warden_enrages_below_half_health() -> void:
	var spec := MonsterSpecs.warden()
	assert_gt(spec.enrage_health_ratio, 0.0)
	assert_gt(spec.enrage_speed_multiplier, 1.0)
	assert_lt(spec.enrage_cooldown_multiplier, 1.0)

func test_scaled_warden_keeps_its_boss_profile() -> void:
	var scaled := MonsterSpecs.warden().scaled(1.5)
	assert_eq(scaled.ai, MonsterSpec.AI.boss)
	assert_eq(scaled.projectile_volley, 3)
	assert_eq(scaled.enrage_health_ratio, 0.5)
	assert_true(scaled.is_valid())

func test_scaled_warden_has_bigger_stats() -> void:
	var base := MonsterSpecs.warden()
	var scaled := base.scaled(1.5)
	assert_gt(scaled.stats.max_health, base.stats.max_health)
	assert_gt(scaled.stats.damage, base.stats.damage)

func test_every_emblem_adds_the_same_power() -> void:
	assert_eq(Player.EMBLEM_POWER, 2)
	var stats := CombatStats.make({ "max_health": 100, "health": 100, "damage": 10 })
	stats.damage += Player.EMBLEM_POWER * 3
	assert_eq(stats.damage, 16)

func test_relic_and_emblem_have_art() -> void:
	assert_true(TileArt.has_entity(&"relic"))
	assert_true(TileArt.has_entity(&"emblem"))
	assert_true(TileArt.has_entity(&"warden"))

func test_boss_theme_builds_a_loop() -> void:
	var stream := MusicTheme.theme(&"boss")
	assert_not_null(stream)
	assert_eq(stream.loop_mode, AudioStreamWAV.LOOP_FORWARD)
	assert_gt(stream.data.size(), 0)

func test_boss_cues_exist_and_sound_distinct() -> void:
	for cue in [&"roar", &"pickup_relic", &"pickup_emblem"]:
		assert_true(SoundBank.has(cue), cue)
		assert_gt(SoundBank.cue(cue).data.size(), 0, cue)
	assert_ne(SoundBank.cue(&"roar").data, SoundBank.cue(&"pickup_relic").data)
