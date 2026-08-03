class_name Combat
extends RefCounted
## Pure damage math used by the player and the monsters.
##
## Keeping the formulas here makes combat deterministic and testable.

const MIN_DAMAGE := 1

## Computes the damage an attacker deals to a defender.
## A high defence never reduces damage below the minimum.
static func compute_damage(p_attack: int, p_defence: int) -> int:
	return maxi(MIN_DAMAGE, p_attack - p_defence)

## True when the attacker can reach the target from its position.
static func within_attack_range(p_distance_sq: float, p_range: float) -> bool:
	return p_distance_sq <= p_range * p_range

## True when the target lies inside the facing wedge of the attacker.
## The wedge is the tile in front of the attacker plus the two side tiles.
static func in_facing_arc(p_origin: Vector2i, p_facing: Vector2i, p_target: Vector2i) -> bool:
	if p_origin == p_target:
		return false
	var delta := p_target - p_origin
	var forward := p_facing
	if forward == Vector2i.LEFT or forward == Vector2i.RIGHT:
		return absi(delta.y) <= 1 and signi(delta.x) == forward.x
	return absi(delta.x) <= 1 and signi(delta.y) == forward.y

## True when a ranged attacker can fire at the target.
## The attacker needs line of sight and the target must sit in range.
static func can_fire_at(
	p_distance_sq: float,
	p_range: float,
	p_has_los: bool
) -> bool:
	return p_has_los and within_attack_range(p_distance_sq, p_range)

## True when the attacker should fall back from a target this close.
static func should_retreat(p_distance_sq: float, p_min_range: float) -> bool:
	return p_distance_sq < p_min_range * p_min_range
