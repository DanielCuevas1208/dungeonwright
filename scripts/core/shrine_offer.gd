class_name ShrineOffer
extends RefCounted
## Pure data for the two deterministic shrine upgrades.
##
## A shrine consumes shards and grants one floor-only combat bonus. Keeping
## the offer table separate from scene nodes makes balance easy to test.

const COST := 3
const MIGHT: StringName = &"might"
const WARD: StringName = &"ward"
const MIGHT_BONUS := 4
const WARD_BONUS := 2

## Returns the stable order used when a generator chooses an offer.
static func ids() -> Array[StringName]:
	return [MIGHT, WARD]

## Returns a valid offer id for an index from a seeded RNG.
static func id_for_index(p_index: int) -> StringName:
	var offer_ids := ids()
	return offer_ids[posmod(p_index, offer_ids.size())]

## Chooses one offer without using global randomness.
static func from_rng(p_rng: SeededRng) -> StringName:
	return id_for_index(p_rng.next_int(ids().size()))

## Returns the user-facing name of an offer.
static func title(p_offer_id: StringName) -> String:
	match p_offer_id:
		MIGHT:
			return "Shrine of Might"
		WARD:
			return "Shrine of Ward"
	return "Dormant shrine"

## Returns the effect that lasts until the current floor ends.
static func effect_text(p_offer_id: StringName) -> String:
	match p_offer_id:
		MIGHT:
			return "Sword damage +%d this floor" % MIGHT_BONUS
		WARD:
			return "Defence +%d this floor" % WARD_BONUS
	return "No effect"

## Returns the damage bonus for an offer.
static func damage_bonus(p_offer_id: StringName) -> int:
	return MIGHT_BONUS if p_offer_id == MIGHT else 0

## Returns the defence bonus for an offer.
static func defence_bonus(p_offer_id: StringName) -> int:
	return WARD_BONUS if p_offer_id == WARD else 0

## Returns the concise interaction copy used by the shrine prompt.
static func prompt_text(p_offer_id: StringName) -> String:
	return "%s: %s | %d shards" % [title(p_offer_id), effect_text(p_offer_id), COST]

## True when the offer id names a supported shrine upgrade.
static func is_valid(p_offer_id: StringName) -> bool:
	return ids().has(p_offer_id)
