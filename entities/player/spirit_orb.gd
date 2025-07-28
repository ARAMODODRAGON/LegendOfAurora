extends Sprite2D
class_name SpiritOrb

@export var ANIMATION_SPEED : float = 1.0
@export var TRANSPARENCY : float = 0.5
@export var CHANGE_TIME : float = 0.1

var _anim_frame_timer : float = 0.0
var _last_slow_held

func update_animation(delta: float, slow_held: bool) -> void:
	
	_anim_frame_timer += delta
	while _anim_frame_timer > ANIMATION_SPEED:
		_anim_frame_timer -= ANIMATION_SPEED
		if frame != 7: frame += 1
		else: frame = 0
	
	if _last_slow_held != slow_held:
		var _final_val : float = TRANSPARENCY if slow_held else 0.0
		
		var _tween : Tween = create_tween()
		_tween.tween_property(self, "self_modulate:a", _final_val, CHANGE_TIME)
		
	
	_last_slow_held = slow_held
	pass
