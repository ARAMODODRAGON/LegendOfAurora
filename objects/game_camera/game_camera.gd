extends Camera2D
class_name GameCamera

@onready var _fade_rect: ColorRect = $CanvasLayer/FadeRect
@onready var _fade_delay: float = 0.5

var _shake_scale: float = 0.0
var _shake_duration: float = 0.0
var _offset: Vector2


func shake_screen(scale_: float, duration: float) -> void:
	_shake_scale = scale_
	_shake_duration = duration


## call to fade, false to fade out or true to fade in
func transition_fade_coroutine(time: float, fade_to_black: bool) -> void:
	const BLACK := Color(0.0, 0.0, 0.0, 1.0)
	const TRANSPARENT := Color(0.0, 0.0, 0.0, 0.0)
	
	_fade_rect.color = TRANSPARENT if fade_to_black else BLACK
	var final_color: Color = BLACK if fade_to_black else TRANSPARENT

	var tween := create_tween()

	if not fade_to_black:
		tween.tween_interval(_fade_delay)

	tween.tween_property(_fade_rect, "color", final_color, time)

	if fade_to_black:
		tween.tween_interval(_fade_delay)
		
	await tween.finished


func _ready() -> void:
	_offset = offset


func _process(delta: float) -> void:
	if _shake_duration <= 0.0:
		_shake_duration = 0.0
		offset = _offset
		return
	
	offset = _offset + Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized() * _shake_scale

	_shake_duration -= delta
