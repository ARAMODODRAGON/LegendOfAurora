extends Node
class_name MapBase

@export var player: Player = null

@onready var game_camera: GameCamera = $GameCamera

class RoomData:
	var room: RoomBase
	var screen_space: Rect2
	var position: Vector2i
	var size: Vector2i

## store rooms based on their position
var _rooms: Dictionary[Vector2i, RoomData]
var _current_room: Vector2i = Vector2i.MAX

func get_current_room_data() -> RoomData:
	return _rooms[_current_room]

func _ready() -> void:
	_build_room_dict()
	
	if player:
		_current_room = _get_room_from_position(player.position)
	
	game_camera.visible = true

func _process(delta: float) -> void:
	## run only if we have a reference to the player
	if player: _check_player_change_room()

func _build_room_dict() -> void:
	var _children: Array[Node] = get_children()
	
	for _child in _children:
		if _child is RoomBase:
			_add_room(_child as RoomBase)

func _add_room(child: RoomBase) -> void:
	const _SCREEN_INVERSE: Vector2 = Vector2.ONE / Util.SCREEN_SIZE
	
	var _roomdat : RoomData = RoomData.new()
	_roomdat.room = child
	_roomdat.screen_space = child.get_rect()
	_roomdat.position = (child.position * _SCREEN_INVERSE).floor()
	_roomdat.size = (_roomdat.screen_space.size * _SCREEN_INVERSE).floor()
	
	if _roomdat.size.x <= 0 || _roomdat.size.y <= 0: 
		printerr("Could not add room \"" + child.name + "\" at position [" + str(_roomdat.position))
		return
	
	## assign
	_rooms[_roomdat.position] = _roomdat

func _get_room_from_position(position: Vector2) -> Vector2i:
	for _key: Vector2i in _rooms:
		var _roomdat: RoomData = _rooms[_key]
		if _roomdat.screen_space.has_point(position):
			return _key
	return Vector2i.MAX

func _check_player_change_room() -> void:
	if _rooms[_current_room].screen_space.has_point(player.position):
		return # no need to check we are still in same room
	
	var _new_room: Vector2i = _get_room_from_position(player.position)
	if _new_room == _current_room:
		printerr("This technically shouldnt happen")
		return
	
	_current_room = _new_room
	var _roomdat: RoomData = _rooms[_current_room]
	
	game_camera.goto_room(_roomdat.screen_space)
	player.goto_room(_roomdat.screen_space)
	
	## TODO: load/unload room data
