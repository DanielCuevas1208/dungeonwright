class_name MonsterSpecs
extends RefCounted
## Registry of the game's monster types.
##
## Drop weights follow a balance rule: every monster drops coins most
## often, shards sometimes, and potions rarely. The drop table tests
## check these probabilities.

static func all() -> Array[MonsterSpec]:
	return [
		skeleton(),
		crawler(),
		wisp(),
		shambler(),
		golem(),
		bonecaster(),
		spitter(),
		slinger(),
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
	spec.drop_table = DropTable.from_entries(_entries([6.0, 2.0, 1.0]), null)
	return spec

static func crawler() -> MonsterSpec:
	var spec := _base(&"crawler", "Skitter", MonsterSpec.AI.stalker, "crawler", 6.0)
	spec.stats = CombatStats.make({
		"max_health": 14, "health": 14, "damage": 5,
		"speed": 3.4, "attack_range": 1.0, "attack_cooldown": 0.7,
	})
	spec.drop_table = DropTable.from_entries(_entries([4.0, 1.0, 0.5]), null)
	return spec

static func wisp() -> MonsterSpec:
	var spec := _base(&"wisp", "Gloom Wisp", MonsterSpec.AI.sentry, "wisp", 0.0)
	spec.stats = CombatStats.make({
		"max_health": 20, "health": 20, "damage": 10,
		"speed": 0.0, "attack_range": 1.2, "attack_cooldown": 1.2,
	})
	spec.drop_table = DropTable.from_entries(_entries([2.0, 4.0, 1.0]), null)
	return spec

static func shambler() -> MonsterSpec:
	var spec := _base(&"shambler", "Root Shambler", MonsterSpec.AI.chaser, "shambler", 9.0)
	spec.stats = CombatStats.make({
		"max_health": 38, "health": 38, "damage": 12,
		"speed": 1.5, "attack_range": 1.4, "attack_cooldown": 1.4,
	})
	spec.drop_table = DropTable.from_entries(_entries([5.0, 1.0, 2.0]), null)
	return spec

static func golem() -> MonsterSpec:
	var spec := _base(&"golem", "Cinder Golem", MonsterSpec.AI.chaser, "golem", 7.0)
	spec.stats = CombatStats.make({
		"max_health": 60, "health": 60, "damage": 15,
		"speed": 1.2, "attack_range": 1.4, "attack_cooldown": 1.6,
	})
	spec.drop_table = DropTable.from_entries(_entries([4.0, 3.0, 2.0]), null)
	return spec

static func bonecaster() -> MonsterSpec:
	var spec := _base(&"bonecaster", "Bone Caster", MonsterSpec.AI.ranged, "bonecaster", 9.0)
	spec.stats = CombatStats.make({
		"max_health": 24, "health": 24, "damage": 9,
		"speed": 1.4, "attack_range": 1.5, "attack_cooldown": 1.4,
	})
	spec.ranged = true
	spec.min_range = 2.5
	spec.projectile_range = 7.0
	spec.projectile_speed = 6.0
	spec.projectile_damage = 9
	spec.projectile_key = &"bolt"
	spec.drop_table = DropTable.from_entries(_entries([5.0, 2.0, 1.0]), null)
	return spec

static func spitter() -> MonsterSpec:
	var spec := _base(&"spitter", "Root Spitter", MonsterSpec.AI.ranged, "spitter", 8.0)
	spec.stats = CombatStats.make({
		"max_health": 16, "health": 16, "damage": 7,
		"speed": 2.6, "attack_range": 1.5, "attack_cooldown": 1.1,
	})
	spec.ranged = true
	spec.min_range = 2.0
	spec.projectile_range = 6.0
	spec.projectile_speed = 7.0
	spec.projectile_damage = 7
	spec.projectile_key = &"spit"
	spec.drop_table = DropTable.from_entries(_entries([4.0, 2.0, 0.5]), null)
	return spec

static func slinger() -> MonsterSpec:
	var spec := _base(&"slinger", "Cinder Slinger", MonsterSpec.AI.ranged, "slinger", 8.0)
	spec.stats = CombatStats.make({
		"max_health": 34, "health": 34, "damage": 11,
		"speed": 1.6, "attack_range": 1.5, "attack_cooldown": 1.6,
	})
	spec.ranged = true
	spec.min_range = 3.0
	spec.projectile_range = 8.0
	spec.projectile_speed = 6.0
	spec.projectile_damage = 11
	spec.projectile_key = &"ember"
	spec.drop_table = DropTable.from_entries(_entries([4.0, 2.0, 1.5]), null)
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

## Builds the three drop entries. Order: coins, shards, potions.
static func _entries(p_weights: Array) -> Array:
	return [
		{ "item": &"coin", "weight": p_weights[0], "min": 1, "max": 3 },
		{ "item": &"shard", "weight": p_weights[1], "min": 1, "max": 2 },
		{ "item": &"potion", "weight": p_weights[2], "min": 1, "max": 1 },
	]

## Rolls a monster's drop table with a deterministic RNG.
static func roll_drops(p_spec: MonsterSpec, p_rng: SeededRng, p_times: int = 1) -> Array[Drop]:
	return p_spec.drop_table.roll_many(p_times, p_rng)
