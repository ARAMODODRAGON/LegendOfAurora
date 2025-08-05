extends Node
class_name MapBase

@export_category("Screen Transitions")
@export var TRANSITION_TIME : float

@export_category("Other")
# TODO: spawn player manually instead of adding them in the inspector
@export var player: Player = null

## base map references
@onready var game_camera: GameCamera = $GameCamera
@onready var entities_layer: Node = $"Layers/Entities Layer"

## tweens
var _tween: Tween = null

func _ready() -> void:
	game_camera.visible = true

func _process(_delta: float) -> void:
	_check_player_room_change()
	pass

func _check_player_room_change() -> void:
	if player == null: return
	
	var rect: Rect2 = game_camera.get_viewport_rect()
	rect.position += game_camera.position
	
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
	
	## sanity check (it actually came in handy)
	if direction == Vector2.ZERO:
		printerr("screen position error")
		return
	
	## TODO: check if this screen "exits" and run a seperate function

	## run coroutine
	move_screens_coroutine(direction, rect)
	

## called to move the camera + player to a new screen while spawning in entities and unloading the last screen
func move_screens_coroutine(direction: Vector2, screen_rect: Rect2) -> void:
	## determine the camera and player's new position
	var new_camera_position: Vector2 = game_camera.position + (direction * Util.SCREEN_SIZE)
	var new_player_position: Vector2 = Util.nearest_point_within_rect(player.position, screen_rect) + (direction * Util.TILE_SIZE * 0.5)

	## pre tween functionality (TODO: pause entities on screen and load the next set of entities)
	player.process_mode = Node.PROCESS_MODE_DISABLED # pause player

	#region tween logic

	## now we tween
	_tween = create_tween()

	## the camera
	_tween.tween_property(game_camera, "position", new_camera_position, TRANSITION_TIME)

	## the player
	_tween.parallel().tween_property(player, "position", new_player_position, TRANSITION_TIME)

	#endregion

	## await this tween as to make this a coroutine
	await _tween.finished
	_tween = null

	## post tween functionality
	player.process_mode = Node.PROCESS_MODE_INHERIT
