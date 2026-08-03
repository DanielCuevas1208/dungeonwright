class_name Items
extends RefCounted
## Registry of every item in the game.
##
## Treasure items add to the score. Consumables heal the hero. Upgrades
## change the hero stats for the rest of the run. The registry is the
## single source of truth for ids, names, categories, and upgrade math,
## which keeps loot logic testable and consistent.

## Returns every item in a stable order.
static func all() -> Array[ItemSpec]:
	return [coin(), shard(), potion(), key(), whetstone(), relic()]

## Returns the item with the given id, or coins for an unknown id.
static func by_id(p_id: StringName) -> ItemSpec:
	for item in all():
		if item.id == p_id:
			return item
	return coin()

## True when the registry knows the given item id.
static func has(p_id: StringName) -> bool:
	return by_id(p_id).id == p_id

## True when the item is a permanent upgrade.
static func is_upgrade(p_id: StringName) -> bool:
	return by_id(p_id).category == ItemSpec.Category.UPGRADE

## Applies an upgrade to the given stats.
##
## Mutates the stats and returns the change as a dictionary. Optional
## keys are "damage", "max_health", and "health". Unknown items change
## nothing and return an empty dictionary.
static func apply_upgrade(p_id: StringName, p_stats: CombatStats) -> Dictionary:
	match p_id:
		&"whetstone":
			p_stats.damage += 2
			return { "damage": 2 }
		&"relic":
			var old_max := p_stats.max_health
			p_stats.max_health += 10
			var health_gain := mini(10, p_stats.max_health - p_stats.health)
			p_stats.health += health_gain
			return { "max_health": p_stats.max_health - old_max, "health": health_gain }
		_:
			return {}

static func coin() -> ItemSpec:
	var item := ItemSpec.new()
	item.id = &"coin"
	item.display_name = "Coin"
	item.description = "Shiny treasure from a fallen monster."
	item.category = ItemSpec.Category.TREASURE
	item.sprite_key = &"coin"
	return item

static func shard() -> ItemSpec:
	var item := ItemSpec.new()
	item.id = &"shard"
	item.display_name = "Shard"
	item.description = "A fragment of a shattered relic."
	item.category = ItemSpec.Category.TREASURE
	item.sprite_key = &"shard"
	return item

static func potion() -> ItemSpec:
	var item := ItemSpec.new()
	item.id = &"potion"
	item.display_name = "Potion"
	item.description = "Restores 25 health when picked up."
	item.category = ItemSpec.Category.CONSUMABLE
	item.sprite_key = &"potion"
	return item

static func key() -> ItemSpec:
	var item := ItemSpec.new()
	item.id = &"key"
	item.display_name = "Key"
	item.description = "Opens one locked door."
	item.category = ItemSpec.Category.CONSUMABLE
	item.sprite_key = &"key"
	return item

static func whetstone() -> ItemSpec:
	var item := ItemSpec.new()
	item.id = &"whetstone"
	item.display_name = "Whetstone"
	item.description = "Raises attack damage by 2 for this run."
	item.category = ItemSpec.Category.UPGRADE
	item.sprite_key = &"whetstone"
	return item

static func relic() -> ItemSpec:
	var item := ItemSpec.new()
	item.id = &"relic"
	item.display_name = "Relic"
	item.description = "Raises max health by 10 and heals for this run."
	item.category = ItemSpec.Category.UPGRADE
	item.sprite_key = &"relic"
	return item
