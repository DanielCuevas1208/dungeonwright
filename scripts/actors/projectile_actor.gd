class_name ProjectileActor
extends Node2D
## A flying projectile.
##
## The actor reads a pure Projectile model each frame and moves a sprite
## to match. It stops on walls, expires at the end of its range, and asks
## the scene controller to damage the hero on contact.

signal hit_player(damage: int)

const HIT_RADIUS := 10.0

var model: Projectile = null
var view: DungeonView = null
var target: Node2D = null
var _sprite: Sprite2D = null
var _ended := false

func setup(
	p_spec: ProjectileSpec,
	p_from: Vector2i,
	p_to: Vector2i,
	p_view: DungeonView,
	p_target: Node2D
) -> void:
	view = p_view
	target = p_target
	model = Projectile.aimed(p_spec, p_from, p_to)
	position = model.position()
	_build_visual(p_spec)

func _physics_process(p_delta: float) -> void:
	if _ended or model == null or view == null:
		return
	if model.advance(p_delta):
		_end(false)
		return
	position = model.position()
	if model.blocked_by(view.map):
		_end(false)
		return
	_check_player_hit()

func _check_player_hit() -> void:
	if target == null or not is_instance_valid(target):
		return
	var distance_sq := position.distance_squared_to(target.position)
	if distance_sq <= HIT_RADIUS * HIT_RADIUS:
		_end(true)

func _end(p_hit: bool) -> void:
	if _ended:
		return
	_ended = true
	if p_hit:
		hit_player.emit(model.damage)
	queue_free()

func _build_visual(p_spec: ProjectileSpec) -> void:
	_sprite = Sprite2D.new()
	_sprite.texture = TileArt.entity_texture(StringName(p_spec.sprite_key))
	_sprite.centered = true
	_sprite.rotation = model.direction.angle()
	add_child(_sprite)
