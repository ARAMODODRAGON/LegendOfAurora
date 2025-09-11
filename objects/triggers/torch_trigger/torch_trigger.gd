extends TriggerBase

@onready var _sprite: Sprite2D = $Sprite2D

var _timer: float = 0.0


## virtual functions

func _on_triggered_on() -> void: 
	_sprite.frame = 1


func _on_triggered_off() -> void: 
	_sprite.frame = 0


func _reset() -> void:
	super._reset()
	_sprite.flip_h = (randi() % 2) == 1


## methods


func _process(delta: float) -> void:
	if not get_state():
		return

	if _timer > 0.0:
		_timer -= delta
	else:
		var frame_rate: float = (randf_range(3.0, 7.0) / 60.0)
		_timer += frame_rate
		_sprite.flip_h = not _sprite.flip_h


## signal connections

func _on_bongo_listener_component_bongo_hit(direction:Vector2) -> void:
	update_state.call_deferred(TriggerState.OFF)
