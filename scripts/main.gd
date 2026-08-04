class_name Main
extends Node2D
## The game controller.
##
## Owns the dungeon view, the hero, the monsters, and the pickups.
## It starts runs, forwards combat, opens doors, and handles victory
## and defeat. The generator stays a pure data module and this node
## turns its output into a live scene.

signal run_started(seed_value: int)

@onready var dungeon_view: DungeonView = $World/DungeonView
@onready var monsters_root: Node2D = $World/Monsters
@onready var pickups_root: Node2D = $World/Pickups
@onready var projectiles_root: Node2D = $World/Projectiles
@onready var bombs_root: Node2D = $World/Bombs
@onready var effects_root: Node2D = $World/Effects
@onready var player: Player = $World/Player
@onready var camera: Camera2D = $Camera
@onready var hud: Hud = $UI/HUD
@onready var menu_overlay: MenuOverlay = $UI/MenuOverlay
@onready var result_overlay: ResultOverlay = $UI/ResultOverlay
@onready var ambient: CanvasModulate = $Ambient

const MONSTER_SCENE := preload("res://scenes/actors/monster.tscn")
const PICKUP_SCENE := preload("res://scenes/actors/pickup.tscn")
const PROJECTILE_SCENE := preload("res://scenes/actors/projectile.tscn")
const BOMB_SCENE := preload("res://scenes/actors/bomb.tscn")

var run: DungeonResult = null
var run_rules: RunRules = null
var biome: DungeonConfig = null
var occupancy: Dictionary = {}
var run_seed: int = 0
var floor_index := 0
var monster_index := 0
var _ended := false
var _beacon_phase := 0.0
var _beacon: Sprite2D = null

func _ready() -> void:
	_wire_signals()
	get_tree().paused = true
	menu_overlay.show_menu(false)

func _wire_signals() -> void:
	player.hp_changed.connect(hud.set_hp)
	player.coins_changed.connect(hud.set_coins)
	player.shards_changed.connect(hud.set_shards)
	player.bombs_changed.connect(hud.set_bombs)
	player.keys_changed.connect(hud.set_keys)
	player.attacked.connect(_on_player_attack)
	player.bomb_thrown.connect(_on_bomb_thrown)
	player.died.connect(_on_player_died)
	player.moved.connect(_on_player_moved)
	menu_overlay.start_requested.connect(_on_start_requested)
	menu_overlay.continue_requested.connect(_resume)
	result_overlay.new_run_requested.connect(_on_new_run_requested)

func _unhandled_input(p_event: InputEvent) -> void:
	if p_event.is_action_pressed("new_run") and run != null:
		_on_new_run_requested(false)
		return
	if p_event.is_action_pressed("toggle_minimap") and run != null:
		hud.toggle_minimap()
		return
	if p_event.is_action_pressed("pause") and run != null and not result_overlay.visible:
		_toggle_pause()

func _physics_process(p_delta: float) -> void:
	if run == null:
		return
	camera.position = player.position
	hud.update_marker(player.grid_pos)
	_collect_pickups()
	_update_projectiles(p_delta)
	_update_bombs(p_delta)
	_pulse_beacon(p_delta)
	if not _ended and player.grid_pos == run.exit_pos:
		_on_exit_reached()

## Moves every live projectile and refreshes its target tile.
func _update_projectiles(p_delta: float) -> void:
	for projectile: Projectile in projectiles_root.get_children():
		projectile.target_grid = player.grid_pos
		projectile.tick(p_delta)

## Advances every live bomb.
func _update_bombs(p_delta: float) -> void:
	for bomb: Bomb in bombs_root.get_children():
		bomb.tick(p_delta)

func _on_start_requested(p_seed_text: String) -> void:
	var text := p_seed_text.strip_edges()
	var seed_value := 0
	if text.is_empty():
		seed_value = randi()
	else:
		seed_value = SeededRng.decode_seed(text)
		if seed_value < 0:
			menu_overlay.show_error("Invalid seed. Use letters A-Z and digits, up to 6.")
			return
	_start_run(seed_value)

func _on_new_run_requested(p_same_seed: bool) -> void:
	if p_same_seed:
		_start_run(run_seed)
	else:
		_start_run(randi())

## Starts a run with a chosen seed. Public entry point for tooling.
func start_run(p_seed_value: int) -> void:
	_start_run(p_seed_value)

func _start_run(p_seed_value: int) -> void:
	run_seed = p_seed_value
	run_rules = RunRules.new()
	biome = Biomes.random(SeededRng.new(p_seed_value ^ 0x5EED))
	floor_index = 0
	player.start_run()

	RunState.seed_value = p_seed_value
	RunState.seed_string = SeededRng.encode_seed(p_seed_value)
	RunState.biome_id = biome.id
	RunState.status = RunState.RunStatus.ACTIVE
	RunState.started_at = Time.get_ticks_msec() / 1000.0

	_begin_floor()
	run_started.emit(p_seed_value)

## Builds the world for the current floor. Keeps hero health and loot
## from the previous floor when the hero descends.
func _begin_floor() -> void:
	var floor_seed := RunRules.floor_seed(run_seed, floor_index)
	run = DungeonGenerator.new().generate(biome, floor_seed)

	_clear_world()
	occupancy.clear()
	_ended = false

	dungeon_view.configure(run.map, biome)
	player.setup(_player_stats(), run.start_pos, dungeon_view, occupancy)
	if floor_index > 0:
		run_rules.heal_between(player.stats)
		player.reset_keys()
	occupancy[run.start_pos] = player
	player.can_enter = _hero_can_enter

	monster_index = 0
	var scale := run_rules.monster_scale(floor_index)
	for spawn in run.monster_spawns:
		_spawn_monster(spawn.position, spawn.monster, scale)

	for key in run.keys:
		_spawn_pickup(&"key", 1, key.position)

	_spawn_exit_beacon()

	camera.enabled = true
	camera.position = player.position
	_apply_camera_limits()
	ambient.color = Color(biome.palette.get(&"accent", Color.WHITE)).darkened(0.55)

	hud.set_run(biome.display_name, SeededRng.encode_seed(run_seed), floor_index, run_rules.floor_count)
	hud.set_minimap(dungeon_view.build_minimap_image(), run.map.width, run.map.height)

	RunState.floor_index = floor_index
	RunState.floor_count = run_rules.floor_count

	menu_overlay.hide_menu()
	result_overlay.hide_result()
	get_tree().paused = false

## Builds the hero stats for this floor.
func _player_stats() -> CombatStats:
	var max_health := biome.starting_health
	var health := max_health
	if floor_index > 0 and player.stats != null:
		max_health = player.stats.max_health
		health = player.stats.health
	return CombatStats.make({
		"max_health": max_health,
		"health": health,
		"damage": biome.player_damage,
	})

## The hero reached the exit. Descend, or win on the final floor.
func _on_exit_reached() -> void:
	if _ended:
		return
	if not run_rules.is_final_floor(floor_index):
		_descend()
		return
	_on_victory()

func _descend() -> void:
	floor_index += 1
	_begin_floor()

func _spawn_monster(p_position: Vector2i, p_monster_id: StringName, p_scale: float = 1.0) -> void:
	var spec := MonsterSpecs.by_id(p_monster_id).scaled(p_scale)
	var monster: MonsterActor = MONSTER_SCENE.instantiate()
	monsters_root.add_child(monster)
	monster.setup(spec, p_position, dungeon_view, occupancy, player)
	occupancy[p_position] = monster
	monster.attack_player.connect(_on_monster_attack)
	monster.ranged_fired.connect(_on_ranged_fired)
	monster.died.connect(_on_monster_died)
	monster_index += 1

func _spawn_pickup(p_kind: StringName, p_count: int, p_position: Vector2i) -> void:
	var pickup: Pickup = PICKUP_SCENE.instantiate()
	pickups_root.add_child(pickup)
	pickup.setup(p_kind, p_count, p_position, dungeon_view)
	pickup.picked_up.connect(_on_pickup_taken)

func _on_player_moved(p_grid: Vector2i) -> void:
	if run.map.get_tile_cell(p_grid) == DungeonMap.Tile.DOOR_LOCKED:
		run.map.set_tile_cell(p_grid, DungeonMap.Tile.DOOR_OPEN)
		dungeon_view.refresh_cell(p_grid)
		player.spend_key()

func _collect_pickups() -> void:
	for pickup: Pickup in pickups_root.get_children():
		if pickup.taken:
			continue
		if pickup.covers_hero(player.grid_pos):
			pickup.take()

## The hero cannot step on a locked door without a key.
func _hero_can_enter(p_cell: Vector2i) -> bool:
	if run.map.get_tile_cell(p_cell) != DungeonMap.Tile.DOOR_LOCKED:
		return true
	return player.keys_held > 0

func _on_pickup_taken(p_pickup: Pickup) -> void:
	player.apply_pickup(p_pickup.kind, p_pickup.count)
	p_pickup.queue_free()

func _on_player_attack(p_origin: Vector2i, p_facing: Vector2i, p_range: float, p_damage: int) -> void:
	for monster: MonsterActor in monsters_root.get_children():
		var distance_sq := Vector2(p_origin).distance_squared_to(Vector2(monster.grid_pos))
		if not Combat.within_attack_range(distance_sq, p_range):
			continue
		if not Combat.in_facing_arc(p_origin, p_facing, monster.grid_pos):
			continue
		monster.take_damage(p_damage)
		_spawn_slash(monster.grid_pos)

func _on_monster_attack(p_damage: int) -> void:
	player.take_damage(p_damage)

## A ranged monster reported a shot. Spawn the bolt for the hero to dodge.
func _on_ranged_fired(p_monster: MonsterActor, p_direction: Vector2i) -> void:
	spawn_projectile(
		p_monster.stats.damage,
		p_monster.spec.projectile_speed,
		p_direction,
		p_monster.grid_pos,
		p_monster.spec.projectile_range
	)

## Spawns a projectile and returns it. Public entry point for tooling.
func spawn_projectile(
	p_damage: int,
	p_speed: float,
	p_direction: Vector2i,
	p_origin: Vector2i,
	p_range: int
) -> Projectile:
	var projectile: Projectile = PROJECTILE_SCENE.instantiate()
	projectiles_root.add_child(projectile)
	projectile.setup(p_damage, p_speed, p_direction, p_origin, dungeon_view, p_range)
	projectile.target_grid = player.grid_pos
	projectile.on_hit = func() -> void:
		player.take_damage(projectile.damage)
		_spawn_impact(projectile.grid_pos)
	projectile.expired.connect(_on_projectile_expired)
	return projectile

func _on_projectile_expired(p_projectile: Projectile) -> void:
	if not p_projectile.is_queued_for_deletion():
		p_projectile.queue_free()

## The hero threw a bomb. Spawn it in front of the hero.
func _on_bomb_thrown(p_origin: Vector2i, p_facing: Vector2i) -> void:
	spawn_bomb(p_origin, p_facing)

## Spawns a thrown bomb and returns it. Public entry point for tooling.
func spawn_bomb(p_origin: Vector2i, p_facing: Vector2i) -> Bomb:
	var bomb: Bomb = BOMB_SCENE.instantiate()
	bombs_root.add_child(bomb)
	var damage := maxi(10, player.stats.damage * 2)
	bomb.setup(damage, 5.0, p_facing, p_origin, dungeon_view, 2, 0.8, 2)
	bomb.on_explode = func() -> void:
		_explode_bomb(bomb)
	bomb.expired.connect(_on_bomb_expired)
	return bomb

## A bomb detonated. Damage every monster inside the blast radius.
func _explode_bomb(p_bomb: Bomb) -> void:
	for monster: MonsterActor in monsters_root.get_children():
		if Combat.in_blast_radius(p_bomb.grid_pos, monster.grid_pos, p_bomb.blast_radius):
			monster.take_damage(p_bomb.damage)
	_spawn_explosion(p_bomb.grid_pos)

func _on_bomb_expired(p_bomb: Bomb) -> void:
	if not p_bomb.is_queued_for_deletion():
		p_bomb.queue_free()

## A brief flash where a bolt lands, so hits read clearly.
func _spawn_impact(p_cell: Vector2i) -> void:
	var impact := ColorRect.new()
	impact.color = Color(biome.palette.get(&"glow", Color.WHITE))
	impact.size = Vector2(10, 10)
	impact.position = Vector2(-5, -5)
	var wrapper := Node2D.new()
	wrapper.position = dungeon_view.tile_to_world(p_cell)
	wrapper.add_child(impact)
	effects_root.add_child(wrapper)
	var tween := wrapper.create_tween()
	tween.tween_property(impact, "scale", Vector2(1.8, 1.8), 0.1)
	tween.parallel().tween_property(impact, "modulate:a", 0.0, 0.1)
	tween.tween_callback(wrapper.queue_free)

## A wide ring where a bomb goes off, so the blast reads clearly.
func _spawn_explosion(p_cell: Vector2i) -> void:
	var burst := ColorRect.new()
	burst.color = Color(biome.palette.get(&"glow", Color.WHITE))
	burst.size = Vector2(16, 16)
	burst.position = Vector2(-8, -8)
	var wrapper := Node2D.new()
	wrapper.position = dungeon_view.tile_to_world(p_cell)
	wrapper.add_child(burst)
	effects_root.add_child(wrapper)
	var tween := wrapper.create_tween()
	tween.tween_property(burst, "scale", Vector2(5.0, 5.0), 0.22)
	tween.parallel().tween_property(burst, "modulate:a", 0.0, 0.22)
	tween.tween_callback(wrapper.queue_free)

func _on_monster_died(p_monster: MonsterActor) -> void:
	occupancy.erase(p_monster.grid_pos)
	var drop_rng := SeededRng.new(run_seed ^ (monster_index * 0x9E37))
	var drops := MonsterSpecs.roll_drops(p_monster.spec, drop_rng)
	for drop in drops:
		_spawn_pickup(drop.item, drop.count, p_monster.grid_pos)
	p_monster.queue_free()

func _on_player_died() -> void:
	if _ended:
		return
	_ended = true
	RunState.status = RunState.RunStatus.LOST
	RunState.finished_at = Time.get_ticks_msec() / 1000.0
	result_overlay.show_result(
		false,
		SeededRng.encode_seed(run_seed),
		floor_index + 1,
		run_rules.floor_count,
		player.coins,
		RunState.elapsed()
	)
	get_tree().paused = true

func _on_victory() -> void:
	if _ended:
		return
	_ended = true
	RunState.status = RunState.RunStatus.WON
	RunState.finished_at = Time.get_ticks_msec() / 1000.0
	result_overlay.show_result(
		true,
		SeededRng.encode_seed(run_seed),
		floor_index + 1,
		run_rules.floor_count,
		player.coins,
		RunState.elapsed()
	)
	get_tree().paused = true

func _toggle_pause() -> void:
	if get_tree().paused:
		_resume()
	else:
		get_tree().paused = true
		menu_overlay.show_menu(true)

func _resume() -> void:
	menu_overlay.hide_menu()
	get_tree().paused = false

func _apply_camera_limits() -> void:
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = run.map.width * 16
	camera.limit_bottom = run.map.height * 16

func _spawn_exit_beacon() -> void:
	_beacon = Sprite2D.new()
	_beacon.texture = _beacon_texture()
	_beacon.modulate = Color(biome.palette.get(&"glow", Color.WHITE))
	_beacon.scale = Vector2(0.5, 0.5)
	_beacon.position = dungeon_view.tile_to_world(run.exit_pos)
	effects_root.add_child(_beacon)

func _pulse_beacon(p_delta: float) -> void:
	if _beacon == null:
		return
	_beacon_phase += p_delta
	_beacon.scale = Vector2.ONE * (0.55 + sin(_beacon_phase * 2.0) * 0.12)

func _beacon_texture() -> Texture2D:
	var size := 32
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center := Vector2(size / 2.0, size / 2.0)
	for x in size:
		for y in size:
			var distance := Vector2(x, y).distance_to(center) / (size / 2.0)
			var alpha := clampf(1.0 - distance, 0.0, 1.0)
			image.set_pixel(x, y, Color(1, 1, 1, alpha * alpha))
	return ImageTexture.create_from_image(image)

func _spawn_slash(p_cell: Vector2i) -> void:
	var slash := Node2D.new()
	slash.position = dungeon_view.tile_to_world(p_cell)
	var flash := ColorRect.new()
	flash.color = Color(biome.palette.get(&"accent", Color.WHITE))
	flash.size = Vector2(16, 16)
	flash.position = Vector2(-8, -8)
	slash.add_child(flash)
	effects_root.add_child(slash)
	var tween := slash.create_tween()
	tween.tween_property(slash, "scale", Vector2(1.6, 1.6), 0.12)
	tween.parallel().tween_property(flash, "modulate:a", 0.0, 0.12)
	tween.tween_callback(slash.queue_free)

func _clear_world() -> void:
	for child in monsters_root.get_children():
		child.queue_free()
	for child in pickups_root.get_children():
		child.queue_free()
	for child in projectiles_root.get_children():
		child.queue_free()
	for child in bombs_root.get_children():
		child.queue_free()
	for child in effects_root.get_children():
		child.queue_free()
	_beacon = null
