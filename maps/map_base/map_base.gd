extends Node
class_name MapBase

@export var player_scene : PackedScene

@export_category("Screen Transitions")
@export var TRANSITION_TIME: float

## base map references
@onready var camera: GameCamera = $GameCamera
#@onready var entities_layer: Node = $"Layers/Entities Layer"
@onready var objects_layer: Node = $"Layers/Objects Layer"
@onready var default_spawn_point: Node2D = $DefaultSpawnPoint

## state
var player: Player = null
var tween: Tween = null

var _room_objects: Array[Node2D]


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
	player.shake_screen.connect(camera.shake_screen)

	## set camera position
	camera.position = (player.position / Util.SCREEN_SIZE).floor() * Util.SCREEN_SIZE

	## pause all room objects so they dont process
	var all_room_objects: Array[Node] = Util.get_room_objects()
	for node in all_room_objects:
		node.process_mode = Node.PROCESS_MODE_DISABLED

	## load the screen we are on
	var rect: Rect2 = camera.get_viewport_rect()
	rect.position += camera.position
	_goto_screen(rect)

	## now we start by fading in
	_warp_transition_coroutine(false)


func _on_player_dead() -> void:
	Game.load_scene(Game.get_scene_index())


func _on_player_warp(warp: WarpPoint) -> void:
	if not warp.target_warp_name:
		#print("could not load warp as the target name was not valid")
		return

	# we have to wait so that when we pause the game there are no side effects
	await get_tree().process_frame
	
	if warp.target_map_index == -1 and warp.target_warp_name.length() != 0:
		await _warp_transition_coroutine(true)
		#print("loading warp \"" + warp.target_warp_name)

		warp_player(warp.target_warp_name)
		await _warp_transition_coroutine(false)
		player.trigger_spawn_timer()

	elif warp.target_warp_name.length() != 0:
		await _warp_transition_coroutine(true)
		#print("loading scene at index [" + str(warp.target_map_index) + "] with warp \"" + warp.target_warp_name)
		Game.load_scene_with_warp_coroutine(warp.target_map_index, warp.target_warp_name)

	elif warp.target_map_index != -1:
		await _warp_transition_coroutine(true)
		#print("loading scene at index [" + str(warp.target_map_index) + "] with default spawn point")
		Game.load_scene(warp.target_map_index)

func _warp_transition_coroutine(fade_to_black: bool) -> void:
	objects_layer.process_mode = Node.PROCESS_MODE_DISABLED
	await camera.transition_fade_coroutine(TRANSITION_TIME, fade_to_black)
	objects_layer.process_mode = Node.PROCESS_MODE_INHERIT

func warp_player(target_warp: String) -> void:
	var targeted_warp_point: Node2D = null

	## find warp point
	var warp_points: Array[Node] = Util.get_warp_points()
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

	## set screen position
	var rect: Rect2 = camera.get_viewport_rect()
	rect.position = (player.position / Util.SCREEN_SIZE).floor() * Util.SCREEN_SIZE
	
	## load the screen we are on
	_goto_screen(rect)


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


## call to load a new screen
## returns a callable that must be called to unload the previous screen
func _load_screen_unload_deferred(screen_rect: Rect2) -> Callable:

	# filter used on the array to get only the room objects within the new screen
	var room_object_filter: Callable = func(node: Node) -> bool:
		var room_object: Node2D = node as Node2D
		if room_object and screen_rect.has_point(room_object.global_position):
			return true
		return false

	# store the current room objects in a new array to unload later
	var objects_to_unload: Array[Node2D] = _room_objects.duplicate(true)
	_room_objects.clear()

	# get all nodes from room_objects group that are of type Node2D and 
	# assign them to the _room_objects array
	_room_objects.assign(Util.get_room_objects().filter(room_object_filter))

	for node in _room_objects:
		if objects_to_unload.has(node):
			objects_to_unload.erase(node)
			continue
		
		node.process_mode = Node.PROCESS_MODE_INHERIT
		node.call(Util.ROOM_OBJECTS_LOAD_FUNC, objects_layer)
		#print("load called on " + node.name)

	# exit early if there are no nodes to unload
	if objects_to_unload.size() == 0: 
		return func() -> void: pass

	# enter
	return func() -> void:
		for node in objects_to_unload:
			#print("unload called on " + node.name)
			node.call(Util.ROOM_OBJECTS_UNLOAD_FUNC, objects_layer)
			node.process_mode = Node.PROCESS_MODE_DISABLED


## called to teleport camera to another screen while immediately loading/unloading rooms
func _goto_screen(screen_rect: Rect2) -> void:
	# move camera to position
	camera.position = screen_rect.position

	# load new screen and immediately call to unload the previous one
	_load_screen_unload_deferred(screen_rect).call()


## called to move the camera + player to a new screen while spawning in entities and unloading the last screen
func _move_screens_coroutine(direction: Vector2, screen_rect: Rect2) -> void:
	# determine the camera and player's new position
	var new_camera_position: Vector2 = camera.position + (direction * Util.SCREEN_SIZE)
	var new_player_position: Vector2 = Util.nearest_point_within_rect(player.position, screen_rect) + (direction * Util.TILE_SIZE * 0.5)

	# pre tween functionality
	objects_layer.process_mode = PROCESS_MODE_DISABLED
	
	screen_rect.position += (direction * Util.SCREEN_SIZE) ## move the screen rect over
	var unload_objects: Callable = _load_screen_unload_deferred(screen_rect)

	#region tween logic

	## now we tween
	tween = create_tween()

	## the camera
	tween.tween_property(camera, "position", new_camera_position, TRANSITION_TIME)

	## the player
	tween.parallel().tween_property(player, "position", new_player_position, TRANSITION_TIME)

	#endregion

	# await this tween as to make this a coroutine
	await tween.finished
	tween = null

	# post tween functionality
	objects_layer.process_mode = PROCESS_MODE_INHERIT

	# unload anything from the previous screen
	
	unload_objects.call()
