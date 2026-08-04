class_name MonsterActor
extends Node2D
## A living monster.
##
## Each monster reads its behaviour from a MonsterSpec. Chasers walk
## toward the hero, stalkers are fast and aggressive, and sentries hold
## their ground and lash out at anyone who comes close. Archers fire
## dodgeable projectiles while they can see the hero. The warden is a
## boss: it slams in melee, fires bolt volleys, and enrages below half
## health. Movement follows a short flood-fill path so monsters rarely
## get stuck on walls.

signal attack_player(damage: int)
signal ranged_fired(monster, direction: Vector2i)
signal hp_changed(current: int, max: int)
signal enraged(monster)
signal died(monster)

const REPATH_INTERVAL := 0.4

var spec: MonsterSpec = null
var stats: CombatStats = null
var grid_pos: Vector2i = Vector2i.ZERO
var view: DungeonView = null
var occupancy: Dictionary = {}
var target: Node2D = null

var _from: Vector2i = Vector2i.ZERO
var _to: Vector2i = Vector2i.ZERO
var _progress := 1.0
var _moving := false
var _path: Array[Vector2i] = []
var _repath_timer := 0.0
var _attack_timer := 0.0
var _sprite: Sprite2D = null
var _hp_bg: ColorRect = null
var _hp_fill: ColorRect = null
var _is_dead := false
var _enraged := false

func setup(
	p_spec: MonsterSpec,
	p_start: Vector2i,
	p_view: DungeonView,
	p_occupancy: Dictionary,
	p_target: Node2D
) -> void:
	spec = p_spec
	stats = CombatStats.make({
		"max_health": p_spec.stats.max_health,
		"health": p_spec.stats.max_health,
		"damage": p_spec.stats.damage,
		"speed": p_spec.stats.speed,
		"attack_range": p_spec.stats.attack_range,
		"attack_cooldown": p_spec.stats.attack_cooldown,
	})
	grid_pos = p_start
	view = p_view
	occupancy = p_occupancy
	target = p_target
	position = view.tile_to_world(grid_pos)
	_build_sprite()
	_build_hp_bar()
	hp_changed.emit(stats.health, stats.max_health)

func _physics_process(p_delta: float) -> void:
	if _is_dead or stats == null or stats.is_dead():
		return
	_attack_timer = maxf(0.0, _attack_timer - p_delta)
	_repath_timer = maxf(0.0, _repath_timer - p_delta)
	if target == null:
		return

	var distance_sq := Vector2(grid_pos).distance_squared_to(Vector2(target.grid_pos))

	if spec.ai == MonsterSpec.AI.boss:
		_act_as_boss(distance_sq, p_delta)
		return

	if spec.ai == MonsterSpec.AI.archer:
		_act_as_archer(distance_sq, p_delta)
		return

	if Combat.within_attack_range(distance_sq, stats.attack_range):
		_try_attack()
		return

	if spec.ai == MonsterSpec.AI.sentry:
		return

	if distance_sq > spec.aggro_range * spec.aggro_range:
		return

	_move_along_path(p_delta)

## Ranged behaviour: fire while the hero is in range and visible.
## Otherwise close the distance until the hero can be shot again.
func _act_as_archer(p_distance_sq: float, p_delta: float) -> void:
	if p_distance_sq > spec.aggro_range * spec.aggro_range:
		return
	var can_see := Combat.has_line_of_sight(view.map, grid_pos, target.grid_pos)
	if can_see and Combat.within_attack_range(p_distance_sq, stats.attack_range):
		_try_ranged_attack()
		_sprite.position.y = 0.0
		return
	_move_along_path(p_delta)

## Boss behaviour: slam in melee, fire a bolt volley at range, and chase
## when the hero is out of reach or hidden behind a wall.
func _act_as_boss(p_distance_sq: float, p_delta: float) -> void:
	if p_distance_sq > spec.aggro_range * spec.aggro_range:
		return
	if Combat.within_attack_range(p_distance_sq, stats.attack_range):
		_try_attack()
		return
	var can_see := Combat.has_line_of_sight(view.map, grid_pos, target.grid_pos)
	if can_see and Combat.within_attack_range(p_distance_sq, float(spec.projectile_range)):
		_try_volley()
		return
	_move_along_path(p_delta)

## Walks the stored path one step toward the target.
func _move_along_path(p_delta: float) -> void:
	if _repath_timer <= 0.0:
		_repath_timer = REPATH_INTERVAL
		_path = Pathfinding.find_path(view.map, grid_pos, target.grid_pos, false)
	if _moving:
		_progress += p_delta * _speed()
		if _progress >= 1.0:
			grid_pos = _to
			position = view.tile_to_world(grid_pos)
			_moving = false
			occupancy.erase(_from)
			occupancy[grid_pos] = self
	else:
		_step_along_path()
	_sprite.position.y = -2.0 if _moving else 0.0

## Applies damage. Returns true when the monster died.
func take_damage(p_amount: int) -> bool:
	if _is_dead or stats == null:
		return false
	stats.take_damage(p_amount)
	hp_changed.emit(stats.health, stats.max_health)
	_flash()
	_update_hp_bar()
	_check_enrage()
	if stats.is_dead():
		_is_dead = true
		died.emit(self)
		return true
	return false

func _try_attack() -> void:
	if _attack_timer > 0.0:
		return
	_attack_timer = _cooldown()
	attack_player.emit(stats.damage)
	_lunge()

## Fires a projectile at the hero and reports the shot direction.
func _try_ranged_attack() -> void:
	if _attack_timer > 0.0:
		return
	_attack_timer = _cooldown()
	ranged_fired.emit(self, Combat.direction_toward(grid_pos, target.grid_pos))
	_lunge()

## A boss fires a fan of bolts at the hero. Each bolt is reported
## separately so the controller can spawn the projectiles.
func _try_volley() -> void:
	if _attack_timer > 0.0:
		return
	_attack_timer = _cooldown()
	var base := Combat.direction_toward(grid_pos, target.grid_pos)
	for direction in Combat.volley_directions(base, spec.projectile_volley):
		ranged_fired.emit(self, direction)
	_lunge()

## The speed a monster moves at, boosted while the boss is enraged.
func _speed() -> float:
	if _enraged:
		return stats.speed * spec.enrage_speed_multiplier
	return stats.speed

## The attack cooldown a monster waits, shortened while the boss is
## enraged.
func _cooldown() -> float:
	if _enraged:
		return stats.attack_cooldown * spec.enrage_cooldown_multiplier
	return stats.attack_cooldown

## A boss turns red and speeds up once its health drops low enough.
func _check_enrage() -> void:
	if _enraged or spec.ai != MonsterSpec.AI.boss:
		return
	if spec.enrage_health_ratio <= 0.0:
		return
	var threshold := maxi(1, roundi(stats.max_health * spec.enrage_health_ratio))
	if stats.health <= threshold:
		_enraged = true
		_sprite.modulate = Color(1.7, 0.45, 0.35)
		_lunge()
		enraged.emit(self)

func _step_along_path() -> void:
	while not _path.is_empty():
		var next_cell := _path[_path.size() - 1]
		_path.remove_at(_path.size() - 1)
		if next_cell == grid_pos:
			continue
		if view.map.get_tile_cell(next_cell) == DungeonMap.Tile.DOOR_LOCKED:
			return
		if occupancy.has(next_cell):
			return
		_from = grid_pos
		_to = next_cell
		_progress = 0.0
		_moving = true
		return

func _build_sprite() -> void:
	_sprite = Sprite2D.new()
	_sprite.texture = TileArt.entity_texture(StringName(spec.sprite_key))
	_sprite.centered = true
	if spec.ai == MonsterSpec.AI.boss:
		_sprite.scale = Vector2(1.5, 1.5)
		_sprite.position.y = -3.0
	add_child(_sprite)

func _build_hp_bar() -> void:
	_hp_bg = ColorRect.new()
	_hp_bg.color = Color(0.1, 0.1, 0.12, 0.8)
	_hp_bg.size = Vector2(14, 2)
	_hp_bg.position = Vector2(-7, -14)
	_hp_fill = ColorRect.new()
	_hp_fill.color = Color(0.8, 0.2, 0.2)
	_hp_fill.size = Vector2(14, 2)
	_hp_fill.position = Vector2(-7, -14)
	add_child(_hp_bg)
	add_child(_hp_fill)

func _update_hp_bar() -> void:
	if _hp_fill == null:
		return
	var ratio := float(stats.health) / float(stats.max_health)
	_hp_fill.size.x = 14.0 * clampf(ratio, 0.0, 1.0)

func _flash() -> void:
	var tween := create_tween()
	tween.tween_property(_sprite, "modulate", Color(3.0, 0.4, 0.4), 0.08)
	tween.tween_property(_sprite, "modulate", _rest_color(), 0.12)

## The colour a monster rests at between flashes. An enraged boss
## keeps its red tint so the phase reads clearly.
func _rest_color() -> Color:
	if _enraged:
		return Color(1.7, 0.45, 0.35)
	return Color.WHITE

func _lunge() -> void:
	if not _moving:
		var tween := create_tween()
		tween.tween_property(_sprite, "position:y", 2.0, 0.08)
		tween.tween_property(_sprite, "position:y", 0.0, 0.1)
