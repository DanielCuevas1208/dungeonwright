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
		archer(),
		sporecaster(),
		hellion(),
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

static func archer() -> MonsterSpec:
	var spec := _base(&"archer", "Bone Archer", MonsterSpec.AI.shooter, "archer", 10.0)
	spec.projectile = &"bone_spike"
	spec.preferred_range = 6.0
	spec.min_range = 2.0
	spec.stats = CombatStats.make({
		"max_health": 20, "health": 20, "damage": 8,
		"speed": 2.4, "attack_range": 1.0, "attack_cooldown": 1.6,
	})
	spec.drop_table = DropTable.from_entries(_entries([6.0, 2.0, 0.5]), null)
	return spec

static func sporecaster() -> MonsterSpec:
	var spec := _base(&"sporecaster", "Sporecaster", MonsterSpec.AI.shooter, "sporecaster", 9.0)
	spec.projectile = &"spore_bolt"
	spec.preferred_range = 5.0
	spec.min_range = 2.0
	spec.stats = CombatStats.make({
		"max_health": 16, "health": 16, "damage": 6,
		"speed": 2.0, "attack_range": 1.0, "attack_cooldown": 2.0,
	})
	spec.drop_table = DropTable.from_entries(_entries([3.0, 3.0, 1.0]), null)
	return spec

static func hellion() -> MonsterSpec:
	var spec := _base(&"hellion", "Ember Hellion", MonsterSpec.AI.shooter, "hellion", 9.0)
	spec.projectile = &"ember_bolt"
	spec.preferred_range = 5.0
	spec.min_range = 2.5
	spec.stats = CombatStats.make({
		"max_health": 26, "health": 26, "damage": 10,
		"speed": 2.2, "attack_range": 1.0, "attack_cooldown": 1.8,
	})
	spec.drop_table = DropTable.from_entries(_entries([5.0, 3.0, 1.5]), null)
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
