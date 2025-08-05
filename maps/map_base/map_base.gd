extends Node
class_name MapBase

@export_category("Screen Transitions")
@export var TRANSITION_TIME: float

@export_category("Other")
# TODO: spawn player manually instead of adding them in the inspector
@export var player: Player = null

## base map references
@onready var camera: Camera2D = $Camera
@onready var entities_layer: Node = $"Layers/Entities Layer"

## tweens
var tween: Tween = null

func _ready() -> void:
	camera.visible = true

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
	var new_camera_position: Vector2 = camera.position + (direction * Util.SCREEN_SIZE)
	var new_player_position: Vector2 = Util.nearest_point_within_rect(player.position, screen_rect) + (direction * Util.TILE_SIZE * 0.5)

	## pre tween functionality (TODO: pause entities on screen and load the next set of entities)
	player.process_mode = Node.PROCESS_MODE_DISABLED # pause player

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

	var rect: Rect2 = camera.get_viewport_rect()
	rect.position += camera.position
	print(rect)

	## post tween functionality
	player.process_mode = Node.PROCESS_MODE_INHERIT
