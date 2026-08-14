extends GutTest
## Integration test for aegis defense scaling across combat.

func test_hero_with_aegis_survives_heavy_blows() -> void:
	var player := Player.new()
	autofree(player)
	var stats := CombatStats.make({
		"max_health": 50,
		"health": 50,
		"damage": 10,
		"defence": 0,
	})
	player.stats = stats

	# Baseline: 5 hits at 8 damage with 0 aegis deals 40 damage, leaving 10 hp
	for i in 5:
		player.take_damage(8)
	assert_eq(player.stats.health, 10)

	# Reset and apply 3 aegis crests (+3 defence)
	player.stats.health = 50
	player.apply_pickup(&"aegis", 3)
	assert_eq(player.stats.defence, 3)

	# 5 hits at 8 damage with 3 defence deals (8 - 3) * 5 = 25 damage, leaving 25 hp
	for i in 5:
		player.take_damage(8)
	assert_eq(player.stats.health, 25)

func test_aegis_defence_never_nullifies_damage_entirely() -> void:
	var player := Player.new()
	autofree(player)
	var stats := CombatStats.make({
		"max_health": 20,
		"health": 20,
		"damage": 10,
		"defence": 0,
	})
	player.stats = stats
	player.apply_pickup(&"aegis", 20)
	assert_eq(player.stats.defence, 20)

	# A 5 damage hit against 20 defence still deals minimum 1 damage
	player.take_damage(5)
	assert_eq(player.stats.health, 19)
