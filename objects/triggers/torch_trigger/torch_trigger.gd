extends TriggerBase

## the state that the torch will start in
@export var initial_state: bool = false

@onready var _sprite: Sprite2D = $Sprite2D

var _timer: float = 0.0


func get_state() -> bool:
	return _sprite.frame == 1


func set_state(state: bool) -> void:
	_change_state(state)


func _change_state(state: bool) -> void:
	if get_state() == state:
		return

	if state:
		_sprite.frame = 1
	else:
		_sprite.frame = 0
	
	on_state_change.emit(TriggerState.ON if state else TriggerState.OFF)


func _ready() -> void:
	_reset()


## called to reset the torch
func _reset() -> void:
	_change_state(initial_state)
	_sprite.flip_h = (randi() % 2) == 1


func _process(delta: float) -> void:
	if not get_state():
		return

	if _timer > 0.0:
		_timer -= delta
	else:
		var frame_rate: float = (randf_range(3.0, 7.0) / 60.0)
		_timer += frame_rate
		_sprite.flip_h = not _sprite.flip_h


func _on_bongo_listener_component_bongo_hit(direction:Vector2) -> void:
	if get_state():
		print("triggered!")
	set_state(false)


## called by map
func _room_object_load(object_layer: Node) -> void:
	_reset()


## called by map
func _room_object_unload(object_layer: Node) -> void:
	pass
