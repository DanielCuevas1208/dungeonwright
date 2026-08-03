class_name ProjectileSpecs
extends RefCounted
## Registry of the game's projectile types.
##
## Each biome has one projectile with its own feel. Bone spikes fly fast
## and hit hard. Spore bolts are slow but plentiful. Ember bolts strike
## from the strongest range.

static func all() -> Array[ProjectileSpec]:
	return [
		bone_spike(),
		spore_bolt(),
		ember_bolt(),
	]

static func by_id(p_id: StringName) -> ProjectileSpec:
	for spec in all():
		if spec.id == p_id:
			return spec
	return bone_spike()

static func bone_spike() -> ProjectileSpec:
	var spec := ProjectileSpec.new()
	spec.id = &"bone_spike"
	spec.display_name = "Bone Spike"
	spec.sprite_key = "bone_spike"
	spec.speed = 8.0
	spec.damage = 8
	spec.range = 8.0
	return spec

static func spore_bolt() -> ProjectileSpec:
	var spec := ProjectileSpec.new()
	spec.id = &"spore_bolt"
	spec.display_name = "Spore Bolt"
	spec.sprite_key = "spore_bolt"
	spec.speed = 6.0
	spec.damage = 6
	spec.range = 7.0
	return spec

static func ember_bolt() -> ProjectileSpec:
	var spec := ProjectileSpec.new()
	spec.id = &"ember_bolt"
	spec.display_name = "Ember Bolt"
	spec.sprite_key = "ember_bolt"
	spec.speed = 7.0
	spec.damage = 10
	spec.range = 8.0
	return spec
