extends Camera2D
class_name GameCamera

@onready var _fade_rect: ColorRect = $CanvasLayer/FadeRect
@onready var _fade_delay: float = 0.5

var _shake_scale: float = 0.0
var _shake_duration: float = 0.0
var _offset: Vector2

var _tween : Tween = null

func shake_screen(scale_: float, duration: float) -> void:
	_shake_scale = scale_
	_shake_duration = duration


## call to fade, false to fade out or true to fade in
func transition_fade_coroutine(time: float, fade_to_black: bool) -> void:
	if _tween:
		printerr("Could not transition as there was already a transition running")
		return

	_fade_rect.color.a = 0.0 if fade_to_black else 1.0
	var final_alpha : float = 1.0 if fade_to_black else 0.0

	_tween = create_tween()

	if not fade_to_black:
		_tween.tween_interval(_fade_delay)

	_tween.tween_property(_fade_rect, "color:a", final_alpha, time)

	if fade_to_black:
		_tween.tween_interval(_fade_delay)
		
	await _tween.finished

	_tween = null


func _ready() -> void:
	_offset = offset


func _process(delta: float) -> void:
	if _shake_duration <= 0.0:
		_shake_duration = 0.0
		offset = _offset
		return
	
	offset = _offset + Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized() * _shake_scale

	_shake_duration -= delta
