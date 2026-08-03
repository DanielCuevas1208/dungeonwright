class_name Player
extends Node2D
## The playable hero.
##
## Movement is tile based with smooth interpolation. The hero walks
## along walkable tiles, carries keys, and attacks the tile in front of
## it. All effects are delivered as signals so the scene controller can
## react without coupling the hero to the world.

signal hp_changed(current: int, max: int)
signal coins_changed(count: int)
signal shards_changed(count: int)
signal keys_changed(count: int)
signal upgrades_changed(bonus_damage: int, bonus_max_health: int)
signal attacked(origin: Vector2i, facing: Vector2i, range: float, damage: int)
signal moved(grid: Vector2i)
signal died

const MOVE_SPEED := 5.0
const ATTACK_COOLDOWN := 0.35
const ATTACK_RANGE := 1.5
const POTION_HEAL := 25

var stats: CombatStats = null
var grid_pos: Vector2i = Vector2i.ZERO
var facing: Vector2i = Vector2i.DOWN
var coins := 0
var shards := 0
var keys_held := 0
## Permanent damage bonus from picked-up upgrades.
var damage_bonus := 0
## Permanent max-health bonus from picked-up upgrades.
var max_health_bonus := 0

var view: DungeonView = null
var occupancy: Dictionary = {}
## Optional gate set by the controller. Called before entering a cell.
## A locked door without a key blocks the hero.
var can_enter: Callable = Callable()

var _from: Vector2i = Vector2i.ZERO
var _to: Vector2i = Vector2i.ZERO
var _progress := 1.0
var _moving := false
var _attack_timer := 0.0
var _sprite: Sprite2D = null

func setup(
	p_stats: CombatStats,
	p_start: Vector2i,
	p_view: DungeonView,
	p_occupancy: Dictionary
) -> void:
	stats = p_stats
	grid_pos = p_start
	view = p_view
	occupancy = p_occupancy
	position = view.tile_to_world(grid_pos)
	_sprite = Sprite2D.new()
	_sprite.texture = TileArt.entity_texture(&"player")
	_sprite.centered = true
	add_child(_sprite)
	_add_light()
	emit_hud()

func _physics_process(p_delta: float) -> void:
	if view == null or stats == null:
		return
	_attack_timer = maxf(0.0, _attack_timer - p_delta)
	_sprite.position.y = -2.0 if _moving else 0.0
	if _moving:
		_advance_move(p_delta)
	else:
		_wait_for_input()
	_handle_attack()

func _wait_for_input() -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input == Vector2.ZERO:
		return
	facing = _dominant_axis(input)
	var target := grid_pos + facing
	if not view.is_walkable(target):
		return
	if occupancy.has(target):
		return
	if not can_enter.is_null() and not can_enter.call(target):
		return
	_from = grid_pos
	_to = target
	_progress = 0.0
	_moving = true

func _advance_move(p_delta: float) -> void:
	_progress += p_delta * MOVE_SPEED
	if _progress >= 1.0:
		grid_pos = _to
		position = view.tile_to_world(grid_pos)
		_moving = false
		occupancy.erase(_from)
		occupancy[grid_pos] = self
		moved.emit(grid_pos)
		return
	position = view.tile_to_world(_from).lerp(view.tile_to_world(_to), _progress)

func _handle_attack() -> void:
	if not Input.is_action_just_pressed("attack"):
		return
	if _attack_timer > 0.0:
		return
	_attack_timer = ATTACK_COOLDOWN
	attacked.emit(grid_pos, facing, ATTACK_RANGE, stats.damage)

func _dominant_axis(p_input: Vector2) -> Vector2i:
	if absf(p_input.x) >= absf(p_input.y):
		return Vector2i(signi(p_input.x), 0)
	return Vector2i(0, signi(p_input.y))

## Applies damage and reports the result. Returns true when the hero died.
func take_damage(p_amount: int) -> bool:
	if stats == null or stats.is_dead():
		return false
	stats.take_damage(p_amount)
	hp_changed.emit(stats.health, stats.max_health)
	_flash()
	if stats.is_dead():
		died.emit()
		return true
	return false

func apply_pickup(p_item: StringName, p_count: int) -> void:
	match p_item:
		&"coin":
			coins += p_count
			coins_changed.emit(coins)
		&"shard":
			shards += p_count
			shards_changed.emit(shards)
		&"potion":
			stats.heal(POTION_HEAL * p_count)
			hp_changed.emit(stats.health, stats.max_health)
		&"key":
			keys_held += p_count
			keys_changed.emit(keys_held)
		&"whetstone", &"relic":
			for i in p_count:
				var change := Items.apply_upgrade(p_item, stats)
				damage_bonus += int(change.get("damage", 0))
				max_health_bonus += int(change.get("max_health", 0))
			hp_changed.emit(stats.health, stats.max_health)
			upgrades_changed.emit(damage_bonus, max_health_bonus)

## Consumes one key, used when the hero opens a locked door.
func spend_key() -> void:
	if keys_held <= 0:
		return
	keys_held -= 1
	keys_changed.emit(keys_held)

func add_key() -> void:
	apply_pickup(&"key", 1)

func emit_hud() -> void:
	hp_changed.emit(stats.health, stats.max_health)
	coins_changed.emit(coins)
	shards_changed.emit(shards)
	keys_changed.emit(keys_held)
	upgrades_changed.emit(damage_bonus, max_health_bonus)

func _flash() -> void:
	var tween := create_tween()
	tween.tween_property(_sprite, "modulate", Color(3.0, 0.4, 0.4), 0.08)
	tween.tween_property(_sprite, "modulate", Color.WHITE, 0.12)

func _add_light() -> void:
	var light := PointLight2D.new()
	light.texture = _soft_light_texture()
	light.energy = 1.5
	light.texture_scale = 8.0
	light.color = Color(1.0, 0.94, 0.8)
	light.shadow_enabled = false
	add_child(light)

func _soft_light_texture() -> Texture2D:
	var size := 64
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center := Vector2(size / 2.0, size / 2.0)
	for x in size:
		for y in size:
			var distance := Vector2(x, y).distance_to(center) / (size / 2.0)
			var alpha := clampf(1.0 - distance, 0.0, 1.0)
			alpha = pow(alpha, 2.0)
			image.set_pixel(x, y, Color(1, 1, 1, alpha))
	return ImageTexture.create_from_image(image)
