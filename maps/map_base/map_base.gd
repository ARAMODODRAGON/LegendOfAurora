extends Node
class_name MapBase

@export var player_scene : PackedScene

@export_category("Screen Transitions")
@export var TRANSITION_TIME: float

## base map references
@onready var camera: Camera2D = $Camera
@onready var entities_layer: Node = $"Layers/Entities Layer"
@onready var objects_layer: Node = $"Layers/Objects Layer"
@onready var default_spawn_point: Node2D = $DefaultSpawnPoint

## state
var player: Player = null
var tween: Tween = null
var enemy_list: Array[EnemyBase] = []

func _ready() -> void:
	camera.visible = true
	
	## spawn player (TODO: check if there is a targeted spawn point for this map)
	player = player_scene.instantiate()
	if player == null:
		assert(false, "player scene did not instantiate player")

	objects_layer.add_child(player)
	player.position = default_spawn_point.position

	player.entered_warp.connect(_on_player_warp)
	player.death_animation_end.connect(_on_player_dead)

	## set camera position
	camera.position = (player.position / Util.SCREEN_SIZE).floor() * Util.SCREEN_SIZE

	## load the screen we are on
	var rect: Rect2 = camera.get_viewport_rect()
	rect.position += camera.position
	_load_screen(rect)

func _on_player_dead() -> void:
	Game.load_scene(Game.get_scene_index())

func _on_player_warp(warp: WarpPoint) -> void:
	if warp.target_warp_name == null || warp.target_warp_name == "":
		print("could not load warp as the target name was not valid")
		return
	
	# load target map index
	Game.load_scene(warp.target_map_index)

func warp_player(target_warp: String) -> void:
	var targeted_warp_point: Node2D = null

	## find warp point
	var warp_points: Array[Node] = get_tree().get_nodes_in_group(Groups.WARP_POINT)
	for warp in warp_points:
		if warp.name == target_warp:
			targeted_warp_point = warp as Node2D
			break
	
	## validate
	if targeted_warp_point == null:
		printerr("invalid warp point \"" + target_warp + "\"")
		return

	# set player position
	player.position = targeted_warp_point.global_position

	## set camera position
	camera.position = (player.position / Util.SCREEN_SIZE).floor() * Util.SCREEN_SIZE
	
	## unload any enemies
	for enemy in enemy_list:
		enemy.free()

	## load the screen we are on
	var rect: Rect2 = camera.get_viewport_rect()
	rect.position += camera.position
	_load_screen(rect)


func _process(_delta: float) -> void:
	_check_player_room_change()

func _check_player_room_change() -> void:
	## sanity check
	if player == null: return
	
	## check if there is a screen transition running
	if tween != null: return

	## the screen we are on
	var rect: Rect2 = camera.get_viewport_rect()
	rect.position += camera.position
	
	## we exit early if the player hasnt left this room
	if rect.has_point(player.position): return

	## now if they have we need to check which direction
	var direction: Vector2 = Vector2.ZERO

	if rect.position.x >= player.position.x:
		direction.x = -1.0
	elif rect.end.x <= player.position.x:
		direction.x = 1.0
	
	if rect.position.y >= player.position.y:
		direction.y = -1.0
	elif rect.end.y <= player.position.y:
		direction.y = 1.0
	
	## sanity check (this actually came in handy, there was an edge case which needed =< and => in the check above)
	if direction == Vector2.ZERO:
		printerr("screen position error")
		return
	
	## TODO: check if this screen "exits" and run a seperate function

	## run coroutine
	_move_screens_coroutine(direction, rect)

func _load_screen(screen_rect: Rect2) -> void:
	## get spawners
	var spawners: Array[EnemySpawner] = []
	for node in objects_layer.get_children():
		var spawner: EnemySpawner = node as EnemySpawner
		if spawner != null:
			if screen_rect.has_point(spawner.global_position):
				spawners.push_back(spawner)
	
	## spawn enemies
	for spawner in spawners:
		var enemy: EnemyBase = spawner.spawn()
		if enemy != null:
			entities_layer.add_child(enemy)
			enemy_list.push_back(enemy)

## called to move the camera + player to a new screen while spawning in entities and unloading the last screen
func _move_screens_coroutine(direction: Vector2, screen_rect: Rect2) -> void:
	## determine the camera and player's new position
	var new_camera_position: Vector2 = camera.position + (direction * Util.SCREEN_SIZE)
	var new_player_position: Vector2 = Util.nearest_point_within_rect(player.position, screen_rect) + (direction * Util.TILE_SIZE * 0.5)

	## pre tween functionality
	entities_layer.process_mode = PROCESS_MODE_DISABLED
	
	var previous_enemies: Array[EnemyBase] = enemy_list.duplicate()
	enemy_list.clear()

	screen_rect.position += (direction * Util.SCREEN_SIZE) ## move the screen rect over
	_load_screen(screen_rect)

	#region tween logic

	## now we tween
	tween = create_tween()

	## the camera
	tween.tween_property(camera, "position", new_camera_position, TRANSITION_TIME)

	## the player
	tween.parallel().tween_property(player, "position", new_player_position, TRANSITION_TIME)

	#endregion

	## await this tween as to make this a coroutine
	await tween.finished
	tween = null

	## post tween functionality
	entities_layer.process_mode = PROCESS_MODE_INHERIT

	for enemy in previous_enemies:
		enemy.free()
