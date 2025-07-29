extends Node2D
class_name RoomBase

## !! Very important: All scenes inheriting RoomBase must 
## use a ScreenSpace rect thats a multiple of Util.SCREEN_SIZE

@onready var _screen_space: ReferenceRect = $ScreenSpace

func get_rect() -> Rect2:
	var _rect: Rect2 = _screen_space.get_rect()
	#_rect.position += global_position
	return _rect
