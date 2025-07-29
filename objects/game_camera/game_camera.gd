extends Camera2D
class_name GameCamera

var _tween : Tween = null

@onready var _screen_space: Control = $ScreenSpace
@onready var _right_border: ColorRect = $RightBorder
@onready var _left_border: ColorRect = $LeftBorder

func _ready() -> void:
	_right_border.visible = true
	_left_border.visible = true
	pass

## goes to the defined room
## stores the 'screen_space' for later use
func goto_room(screen_space: Rect2) -> void:
	
	pass

## similar to 'goto_room' but does not transition
## useful for loading into a level and needing the camera to be at a specific room
func set_room(screen_space: Rect2) -> void:
	
	pass

#
#func _end_screen_movement() -> void:
	#unpause.emit()
	#_tween = null
#
#func _update_screen(delta: float) -> void:
	#var _screen_rect : Rect2 = _screen_space.get_rect()
	#_screen_rect.position += position
	#
	### check if player is within bounds
	#if _screen_rect.has_point(follow_node.position):
		#return
	#
	### we are out of bounds, now get the direction the camera must move in 
	#var _min : Vector2 = _screen_rect.position
	#var _max : Vector2 = _screen_rect.position + _screen_rect.size
	#
	#var _direction : Vector2 = Vector2.ZERO
	#if follow_node.position.x < _min.x:
		#_direction.x = -1.0
	#elif follow_node.position.x > _max.x:
		#_direction.x = 1.0
	#elif follow_node.position.y < _min.y:
		#_direction.y = -1.0
	#elif follow_node.position.y > _max.y:
		#_direction.y = 1.0
	#else:
		### failed for some reason??
		#return
	#
	### emit this signal so that things like the player can be *paused*
	#begin_screen_movement.emit(Vector2i(_direction))
	#
	### now we must move
	#_tween = create_tween()
	#_tween.set_ease(Tween.EASE_IN_OUT)
	#_tween.tween_property(self, "position", position + (_direction * _GRID_SIZE), 1.0)
	## 'parallel' just means that we run both this tween_property and the previous one at the same time
	#_tween.parallel().tween_property( 
		#follow_node, 
		#"position", 
		#follow_node.position + (_direction * _TILE_SIZE * 0.5), 
		#1.0
	#)
	#_tween.tween_callback(_end_screen_movement)
	#
