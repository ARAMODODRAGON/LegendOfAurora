extends Node
class_name MapBase

## base map references
@onready var game_camera: GameCamera = $GameCamera
@onready var entities_layer: Node = $"Layers/Entities Layer"

# TODO: spawn player manually instead of adding them in the inspector
@export var player: Player = null

func _ready() -> void:
	game_camera.visible = true

func _process(delta: float) -> void:
	_check_player_room_change()
	pass

func _check_player_room_change() -> void:
	if player == null: return
	
	var rect : Variant

#func _check_player_change_room() -> void:
	#if _rooms[_current_room].screen_space.has_point(player.position):
		#return # no need to check we are still in same room
	#
	#var _new_room: Vector2i = _get_room_from_position(player.position)
	#if _new_room == _current_room:
		#printerr("This technically shouldnt happen")
		#return
	#
	#_current_room = _new_room
	#var _roomdat: RoomData = _rooms[_current_room]
	#
	#game_camera.goto_room(_roomdat.screen_space)
	#player.goto_room(_roomdat.screen_space)
	#
	### TODO: load/unload room data
