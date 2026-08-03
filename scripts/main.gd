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
@onready var effects_root: Node2D = $World/Effects
@onready var player: Player = $World/Player
@onready var camera: Camera2D = $Camera
@onready var hud: Hud = $UI/HUD
@onready var menu_overlay: MenuOverlay = $UI/MenuOverlay
@onready var descend_overlay: DescendOverlay = $UI/DescendOverlay
@onready var result_overlay: ResultOverlay = $UI/ResultOverlay
@onready var ambient: CanvasModulate = $Ambient

const MONSTER_SCENE := preload("res://scenes/actors/monster.tscn")
const PICKUP_SCENE := preload("res://scenes/actors/pickup.tscn")

var run: DungeonResult = null
var biome: DungeonConfig = null
var occupancy: Dictionary = {}
var run_seed: int = 0
var current_floor: int = 0
var monster_index := 0
var _ended := false
var _at_exit := false
var _beacon_phase := 0.0
var _beacon: Sprite2D = null

func _ready() -> void:
	_wire_signals()
	get_tree().paused = true
	menu_overlay.show_menu(false)

func _wire_signals() -> void:
	player.hp_changed.connect(hud.set_hp)
	player.coins_changed.connect(hud.set_coins)
	player.keys_changed.connect(hud.set_keys)
	player.attacked.connect(_on_player_attack)
	player.died.connect(_on_player_died)
	player.moved.connect(_on_player_moved)
	menu_overlay.start_requested.connect(_on_start_requested)
	menu_overlay.continue_requested.connect(_resume)
	descend_overlay.descend_requested.connect(_on_descend_requested)
	descend_overlay.stay_requested.connect(_on_stay_requested)
	result_overlay.new_run_requested.connect(_on_new_run_requested)

func _unhandled_input(p_event: InputEvent) -> void:
	if p_event.is_action_pressed("new_run") and run != null:
		_on_new_run_requested(false)
		return
	if p_event.is_action_pressed("toggle_minimap") and run != null:
		hud.toggle_minimap()
		return
	if p_event.is_action_pressed("pause") and run != null \
			and not result_overlay.visible and not descend_overlay.visible:
		_toggle_pause()

func _physics_process(p_delta: float) -> void:
	if run == null:
		return
	camera.position = player.position
	hud.update_marker(player.grid_pos)
	_collect_pickups()
	_pulse_beacon(p_delta)
	if _at_exit:
		if player.grid_pos != run.exit_pos:
			_at_exit = false
	elif player.grid_pos == run.exit_pos:
		_at_exit = true
		_on_reach_exit()

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
	current_floor = 0
	descend_overlay.hide_descend()
	result_overlay.hide_result()
	_begin_floor(false)

## Descends to the next floor. Public entry point for tooling.
func descend() -> void:
	if _ended or current_floor >= RunProgression.TOTAL_FLOORS - 1:
		return
	descend_overlay.hide_descend()
	current_floor += 1
	_begin_floor(true)

## Builds the world for the current floor. Keeps the hero's progress
## when p_keep_progress is true, otherwise starts a fresh hero.
func _begin_floor(p_keep_progress: bool) -> void:
	biome = RunProgression.biome_for_floor(run_seed, current_floor)
	var floor_seed := RunProgression.floor_seed(run_seed, current_floor)
	run = DungeonGenerator.new().generate(biome, floor_seed, current_floor)

	_clear_world()
	occupancy.clear()
	_ended = false
	_at_exit = false

	dungeon_view.configure(run.map, biome)
	if p_keep_progress and player.stats != null:
		player.stats.heal(RunProgression.DESCEND_HEAL)
		player.reset_keys()
		player.setup(player.stats, run.start_pos, dungeon_view, occupancy)
	else:
		var stats := CombatStats.make({
			"max_health": biome.starting_health,
			"health": biome.starting_health,
			"damage": biome.player_damage,
		})
		player.setup(stats, run.start_pos, dungeon_view, occupancy)
	occupancy[run.start_pos] = player
	player.can_enter = _hero_can_enter

	monster_index = 0
	for spawn in run.monster_spawns:
		_spawn_monster(spawn.position, spawn.monster)

	for key in run.keys:
		_spawn_pickup(&"key", 1, key.position)

	_spawn_exit_beacon()

	camera.enabled = true
	camera.position = player.position
	_apply_camera_limits()
	ambient.color = Color(biome.palette.get(&"accent", Color.WHITE)).darkened(0.55)

	var exit_is_goal := RunProgression.is_final_floor(current_floor)
	hud.set_run(
		current_floor,
		RunProgression.TOTAL_FLOORS,
		biome.display_name,
		SeededRng.encode_seed(run_seed),
		run.depth,
		exit_is_goal
	)
	hud.set_minimap(dungeon_view.build_minimap_image(), run.map.width, run.map.height)

	RunState.seed_value = run_seed
	RunState.seed_string = SeededRng.encode_seed(run_seed)
	RunState.biome_id = biome.id
	RunState.floor = current_floor
	RunState.total_floors = RunProgression.TOTAL_FLOORS
	RunState.status = RunState.RunStatus.ACTIVE
	if not p_keep_progress:
		RunState.started_at = Time.get_ticks_msec() / 1000.0

	menu_overlay.hide_menu()
	descend_overlay.hide_descend()
	get_tree().paused = false
	run_started.emit(run_seed)

func _spawn_monster(p_position: Vector2i, p_monster_id: StringName) -> void:
	var spec := MonsterSpecs.by_id(p_monster_id)
	var monster: MonsterActor = MONSTER_SCENE.instantiate()
	monsters_root.add_child(monster)
	monster.setup(
		spec,
		p_position,
		dungeon_view,
		occupancy,
		player,
		RunProgression.monster_health_scale(current_floor),
		RunProgression.monster_damage_scale(current_floor)
	)
	occupancy[p_position] = monster
	monster.attack_player.connect(_on_monster_attack)
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
	_at_exit = false
	RunState.status = RunState.RunStatus.LOST
	RunState.finished_at = Time.get_ticks_msec() / 1000.0
	result_overlay.show_result(
		false,
		SeededRng.encode_seed(run_seed),
		current_floor,
		RunProgression.TOTAL_FLOORS,
		run.depth,
		player.coins,
		RunState.elapsed()
	)
	get_tree().paused = true

## Called when the hero steps on the exit tile of a floor.
func _on_reach_exit() -> void:
	if _ended:
		return
	if RunProgression.is_final_floor(current_floor):
		_on_victory()
		return
	get_tree().paused = true
	descend_overlay.show_descend(current_floor, RunProgression.TOTAL_FLOORS, RunProgression.DESCEND_HEAL)

func _on_descend_requested() -> void:
	descend()

## The hero chooses to stay. Let them step off and return later.
func _on_stay_requested() -> void:
	descend_overlay.hide_descend()
	get_tree().paused = false

func _on_victory() -> void:
	if _ended:
		return
	_ended = true
	_at_exit = false
	RunState.status = RunState.RunStatus.WON
	RunState.finished_at = Time.get_ticks_msec() / 1000.0
	result_overlay.show_result(
		true,
		SeededRng.encode_seed(run_seed),
		current_floor,
		RunProgression.TOTAL_FLOORS,
		run.depth,
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
	var key: StringName = &"glow" if RunProgression.is_final_floor(current_floor) else &"rune"
	_beacon.modulate = Color(biome.palette.get(key, Color.WHITE))
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
	for child in effects_root.get_children():
		child.queue_free()
	_beacon = null
