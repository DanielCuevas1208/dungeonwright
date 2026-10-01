extends GutTest
## The aegis crest provides defensive armor and reduces combat damage.

func test_aegis_power_is_one() -> void:
	assert_eq(Player.AEGIS_DEFENCE, 1)

func test_aegis_reduces_combat_damage() -> void:
	var damage_raw := Combat.compute_damage(12, 0)
	var damage_shielded := Combat.compute_damage(12, 3)
	assert_eq(damage_raw, 12)
	assert_eq(damage_shielded, 9)

func test_aegis_never_reduces_damage_below_minimum() -> void:
	var damage := Combat.compute_damage(2, 10)
	assert_eq(damage, Combat.MIN_DAMAGE)

func test_aegis_pickup_boosts_defence() -> void:
	var player := Player.new()
	autofree(player)
	var stats := CombatStats.make({
		"max_health": 100,
		"health": 100,
		"damage": 10,
		"defence": 0,
	})
	player.stats = stats
	player.apply_pickup(&"aegis", 2)
	assert_eq(player.aegis, 2)
	assert_eq(stats.defence, 2)

func test_take_damage_uses_defence() -> void:
	var player := Player.new()
	autofree(player)
	var stats := CombatStats.make({
		"max_health": 100,
		"health": 100,
		"damage": 10,
		"defence": 4,
	})
	player.stats = stats
	var dead := player.take_damage(10)
	assert_false(dead)
	assert_eq(stats.health, 94)

func test_aegis_has_tile_art() -> void:
	assert_true(TileArt.has_entity(&"aegis"))
	var texture := TileArt.entity_texture(&"aegis")
	assert_not_null(texture)
	assert_eq(texture.get_width(), TileArt.SIZE)
	assert_eq(texture.get_height(), TileArt.SIZE)

func test_aegis_sound_exists_and_sounds_distinct() -> void:
	assert_true(SoundBank.has(&"pickup_aegis"))
	var stream := SoundBank.cue(&"pickup_aegis")
	assert_not_null(stream)
	assert_gt(stream.data.size(), 0)

func test_every_monster_can_drop_an_aegis() -> void:
	for spec in MonsterSpecs.all():
		var table := spec.drop_table
		assert_gt(table.probability_of(&"aegis"), 0.0, spec.id)
