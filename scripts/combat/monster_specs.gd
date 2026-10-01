class_name MonsterSpecs
extends RefCounted
## Registry of the game's monster types.
##
## Drop weights follow a balance rule: every monster drops coins most
## often, shards sometimes, potions rarely, bombs, emblems, and aegis
## crests rarest. The drop table tests check these probabilities. The
## warden is the final-floor boss and shares the rule with regular monsters.

static func all() -> Array[MonsterSpec]:
	return [
		skeleton(),
		crawler(),
		wisp(),
		shambler(),
		golem(),
		archer(),
		wraith(),
		warden(),
	]

static func by_id(p_id: StringName) -> MonsterSpec:
	for spec in all():
		if spec.id == p_id:
			return spec
	return skeleton()

static func skeleton() -> MonsterSpec:
	var spec := _base(&"skeleton", "Bonewalker", MonsterSpec.AI.chaser, "skeleton", 8.0)
	spec.stats = CombatStats.make({
		"max_health": 26, "health": 26, "damage": 8,
		"speed": 2.0, "attack_range": 1.2, "attack_cooldown": 1.0,
	})
	spec.drop_table = DropTable.from_entries(_entries([6.0, 2.0, 1.0, 0.5, 0.2, 0.15]), null)
	return spec

static func crawler() -> MonsterSpec:
	var spec := _base(&"crawler", "Skitter", MonsterSpec.AI.stalker, "crawler", 6.0)
	spec.stats = CombatStats.make({
		"max_health": 14, "health": 14, "damage": 5,
		"speed": 3.4, "attack_range": 1.0, "attack_cooldown": 0.7,
	})
	spec.drop_table = DropTable.from_entries(_entries([4.0, 1.0, 0.5, 0.4, 0.15, 0.1]), null)
	return spec

static func wisp() -> MonsterSpec:
	var spec := _base(&"wisp", "Gloom Wisp", MonsterSpec.AI.sentry, "wisp", 0.0)
	spec.stats = CombatStats.make({
		"max_health": 20, "health": 20, "damage": 10,
		"speed": 0.0, "attack_range": 1.2, "attack_cooldown": 1.2,
	})
	spec.drop_table = DropTable.from_entries(_entries([2.0, 4.0, 1.0, 0.5, 0.2, 0.15]), null)
	return spec

static func shambler() -> MonsterSpec:
	var spec := _base(&"shambler", "Root Shambler", MonsterSpec.AI.chaser, "shambler", 9.0)
	spec.stats = CombatStats.make({
		"max_health": 38, "health": 38, "damage": 12,
		"speed": 1.5, "attack_range": 1.4, "attack_cooldown": 1.4,
	})
	spec.drop_table = DropTable.from_entries(_entries([5.0, 1.0, 2.0, 0.7, 0.25, 0.2]), null)
	return spec

static func golem() -> MonsterSpec:
	var spec := _base(&"golem", "Cinder Golem", MonsterSpec.AI.chaser, "golem", 7.0)
	spec.stats = CombatStats.make({
		"max_health": 60, "health": 60, "damage": 15,
		"speed": 1.2, "attack_range": 1.4, "attack_cooldown": 1.6,
	})
	spec.drop_table = DropTable.from_entries(_entries([4.0, 3.0, 2.0, 1.0, 0.3, 0.25]), null)
	return spec

## A ranged monster that fires dodgeable bolts at the hero.
## It holds its ground and shoots while it has line of sight.
static func archer() -> MonsterSpec:
	var spec := _base(&"archer", "Bone Archer", MonsterSpec.AI.archer, "archer", 10.0)
	spec.stats = CombatStats.make({
		"max_health": 24, "health": 24, "damage": 7,
		"speed": 2.2, "attack_range": 7.0, "attack_cooldown": 1.6,
	})
	spec.projectile_speed = 7.0
	spec.projectile_range = 9
	spec.drop_table = DropTable.from_entries(_entries([5.0, 2.0, 1.0, 0.5, 0.2, 0.15]), null)
	return spec

## A fast, frail ghost that rushes the hero in the cold halls.
## It deals steady damage and falls quickly once cornered.
static func wraith() -> MonsterSpec:
	var spec := _base(&"wraith", "Hollow Wraith", MonsterSpec.AI.stalker, "wraith", 7.0)
	spec.stats = CombatStats.make({
		"max_health": 18, "health": 18, "damage": 7,
		"speed": 3.2, "attack_range": 1.0, "attack_cooldown": 0.7,
	})
	spec.drop_table = DropTable.from_entries(_entries([4.0, 2.0, 1.0, 0.8, 0.2, 0.15]), null)
	return spec

## The final-floor boss. It slams in melee, fires bolt volleys, and
## enrages below half health. It guards the exit of the last floor.
static func warden() -> MonsterSpec:
	var spec := _base(&"warden", "The Warden", MonsterSpec.AI.boss, "warden", 14.0)
	spec.stats = CombatStats.make({
		"max_health": 200, "health": 200, "damage": 16,
		"speed": 1.5, "attack_range": 1.6, "attack_cooldown": 1.4,
	})
	spec.projectile_speed = 7.0
	spec.projectile_range = 9
	spec.projectile_volley = 3
	spec.enrage_health_ratio = 0.5
	spec.enrage_speed_multiplier = 1.5
	spec.enrage_cooldown_multiplier = 0.6
	spec.drop_table = DropTable.from_entries(_entries([6.0, 3.0, 1.0, 0.5, 0.2, 0.2]), null)
	return spec

static func _base(
	p_id: StringName,
	p_name: String,
	p_ai: StringName,
	p_sprite: String,
	p_aggro: float
) -> MonsterSpec:
	var spec := MonsterSpec.new()
	spec.id = p_id
	spec.display_name = p_name
	spec.ai = p_ai
	spec.sprite_key = p_sprite
	spec.aggro_range = p_aggro
	return spec

## Builds the six drop entries. Order: coins, shards, potions, bombs,
## emblems, aegis. Coins drop most often, shards sometimes, potions rarely,
## bombs, emblems, and aegis crests rarest.
static func _entries(p_weights: Array) -> Array:
	return [
		{ "item": &"coin", "weight": p_weights[0], "min": 1, "max": 3 },
		{ "item": &"shard", "weight": p_weights[1], "min": 1, "max": 2 },
		{ "item": &"potion", "weight": p_weights[2], "min": 1, "max": 1 },
		{ "item": &"bomb", "weight": p_weights[3], "min": 1, "max": 1 },
		{ "item": &"emblem", "weight": p_weights[4], "min": 1, "max": 1 },
		{ "item": &"aegis", "weight": p_weights[5], "min": 1, "max": 1 },
	]

## Rolls a monster's drop table with a deterministic RNG.
static func roll_drops(p_spec: MonsterSpec, p_rng: SeededRng, p_times: int = 1) -> Array[Drop]:
	return p_spec.drop_table.roll_many(p_times, p_rng)
