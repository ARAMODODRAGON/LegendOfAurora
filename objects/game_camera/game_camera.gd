extends Camera2D
class_name GameCamera

var _shake_scale: float = 0.0
var _shake_duration: float = 0.0
var _offset: Vector2

func shake_screen(scale_: float, duration: float) -> void:
	_shake_scale = scale_
	_shake_duration = duration

func _ready() -> void:
	_offset = offset

func _process(delta: float) -> void:
	if _shake_duration <= 0.0:
		_shake_duration = 0.0
		offset = _offset
		return
	
	offset = _offset + Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized() * _shake_scale

	_shake_duration -= delta