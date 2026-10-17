extends GutTest
## Shrines are deterministic, optional, and useful for one floor.

func test_offer_table_has_two_valid_floor_buffs() -> void:
	assert_eq(ShrineOffer.ids().size(), 2)
	for offer_id in ShrineOffer.ids():
		assert_true(ShrineOffer.is_valid(offer_id))
		assert_false(ShrineOffer.effect_text(offer_id).is_empty())
		assert_true(ShrineOffer.prompt_text(offer_id).contains("3 shards"))

func test_offer_selection_is_seeded() -> void:
	var first := []
	var second := []
	var first_rng := SeededRng.new(8080)
	var second_rng := SeededRng.new(8080)
	for i in 20:
		first.append(ShrineOffer.from_rng(first_rng))
		second.append(ShrineOffer.from_rng(second_rng))
	assert_eq(first, second)

func test_shrines_are_in_room_interiors_and_avoid_features() -> void:
	for biome in Biomes.all():
		var result := DungeonGenerator.new().generate(biome, 1212)
		assert_between(result.shrine_count(), biome.shrine_count_min, biome.shrine_count_max)
		for shrine in result.shrines:
			assert_true(ShrineOffer.is_valid(shrine.offer_id))
			assert_true(_is_room_interior(result, shrine.position))
			assert_ne(shrine.position, result.start_pos)
			assert_ne(shrine.position, result.exit_pos)
			assert_ne(shrine.position, result.boss_spawn)
			assert_false(_positions(result.doors).has(shrine.position))
			assert_false(_positions(result.keys).has(shrine.position))
			assert_false(_positions(result.monster_spawns).has(shrine.position))

func test_shrine_records_replay_identically() -> void:
	var first := DungeonGenerator.new().generate(Biomes.tidebound_archive(), 5150)
	var second := DungeonGenerator.new().generate(Biomes.tidebound_archive(), 5150)
	assert_eq(first.shrine_count(), second.shrine_count())
	for i in first.shrine_count():
		assert_eq(first.shrines[i].position, second.shrines[i].position)
		assert_eq(first.shrines[i].offer_id, second.shrines[i].offer_id)

func test_shrine_generation_can_be_disabled() -> void:
	var config := Biomes.crypt()
	config.shrine_count_min = 0
	config.shrine_count_max = 0
	var result := DungeonGenerator.new().generate(config, 77)
	assert_eq(result.shrine_count(), 0)

func test_might_costs_shards_and_updates_damage() -> void:
	var player := _player_with_stats(20, 8, 0, 3)
	assert_true(player.apply_shrine_offer(ShrineOffer.MIGHT))
	assert_eq(player.shards, 0)
	assert_eq(player.stats.damage, 12)
	assert_eq(player.floor_damage_bonus, ShrineOffer.MIGHT_BONUS)

func test_ward_costs_shards_and_updates_defence() -> void:
	var player := _player_with_stats(20, 8, 0, 3)
	assert_true(player.apply_shrine_offer(ShrineOffer.WARD))
	assert_eq(player.shards, 0)
	assert_eq(player.stats.defence, ShrineOffer.WARD_BONUS)
	assert_eq(player.floor_defence_bonus, ShrineOffer.WARD_BONUS)

func test_shrine_purchase_requires_full_cost() -> void:
	var player := _player_with_stats(20, 8, 0, ShrineOffer.COST - 1)
	assert_false(player.apply_shrine_offer(ShrineOffer.MIGHT))
	assert_eq(player.shards, ShrineOffer.COST - 1)
	assert_eq(player.stats.damage, 8)

func test_floor_buffs_clear_without_removing_permanent_power() -> void:
	var player := _player_with_stats(20, 8, 1, ShrineOffer.COST)
	assert_true(player.apply_shrine_offer(ShrineOffer.MIGHT))
	player.clear_floor_buffs()
	assert_eq(player.stats.damage, 8)
	assert_eq(player.stats.defence, 1)
	assert_eq(player.floor_damage_bonus, 0)

func _player_with_stats(
	p_max_health: int,
	p_damage: int,
	p_defence: int,
	p_shards: int
) -> Player:
	var player := Player.new()
	autofree(player)
	add_child(player)
	player.stats = CombatStats.make({
		"max_health": p_max_health,
		"health": p_max_health,
		"damage": p_damage,
		"defence": p_defence,
	})
	player.shards = p_shards
	return player

func _positions(p_records: Array) -> Dictionary:
	var positions := {}
	for record in p_records:
		positions[record.position] = true
	return positions

func _is_room_interior(p_result: DungeonResult, p_cell: Vector2i) -> bool:
	for room in p_result.rooms:
		if room.id == p_result.start_room or room.id == p_result.exit_room:
			continue
		if room.rect().has_point(p_cell):
			return p_cell.x > room.x and p_cell.x < room.x + room.w - 1 \
				and p_cell.y > room.y and p_cell.y < room.y + room.h - 1
	return false
