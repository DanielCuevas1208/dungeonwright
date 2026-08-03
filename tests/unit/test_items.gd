extends GutTest
## The item registry and the permanent upgrade effects.

const KNOWN_IDS := [
	&"coin", &"shard", &"potion", &"key", &"whetstone", &"relic",
]

func test_registry_holds_every_item_kind() -> void:
	var ids := []
	for item in Items.all():
		ids.append(item.id)
	for expected in KNOWN_IDS:
		assert_true(ids.has(expected), "%s is missing from the registry" % expected)

func test_every_item_has_a_name_description_and_art() -> void:
	for item in Items.all():
		assert_false(item.display_name.is_empty(), item.id)
		assert_false(item.description.is_empty(), item.id)
		assert_true(TileArt.has_entity(item.sprite_key), "%s has no sprite" % item.id)

func test_by_id_falls_back_to_coins() -> void:
	assert_true(Items.has(&"relic"))
	assert_eq(Items.by_id(&"not_an_item").id, &"coin")

func test_upgrade_category_detection() -> void:
	assert_true(Items.is_upgrade(&"whetstone"))
	assert_true(Items.is_upgrade(&"relic"))
	assert_false(Items.is_upgrade(&"coin"))
	assert_false(Items.is_upgrade(&"potion"))

func test_whetstone_raises_damage() -> void:
	var stats := CombatStats.make({ "max_health": 50, "health": 50, "damage": 10 })
	var change := Items.apply_upgrade(&"whetstone", stats)
	assert_eq(change.get("damage", 0), 2)
	assert_eq(stats.damage, 12)
	assert_eq(stats.max_health, 50)

func test_relic_raises_max_health() -> void:
	var stats := CombatStats.make({ "max_health": 50, "health": 50 })
	var change := Items.apply_upgrade(&"relic", stats)
	assert_eq(change.get("max_health", 0), 10)
	assert_eq(stats.max_health, 60)
	assert_eq(stats.health, 60)

func test_relic_heals_part_of_the_gap() -> void:
	var stats := CombatStats.make({ "max_health": 50, "health": 20 })
	var change := Items.apply_upgrade(&"relic", stats)
	assert_eq(stats.max_health, 60)
	assert_eq(stats.health, 30)
	assert_eq(change.get("health", 0), 10)

func test_unknown_item_changes_nothing() -> void:
	var stats := CombatStats.make({ "max_health": 50, "health": 50, "damage": 10 })
	var change := Items.apply_upgrade(&"nope", stats)
	assert_eq(change.size(), 0)
	assert_eq(stats.damage, 10)
	assert_eq(stats.max_health, 50)
