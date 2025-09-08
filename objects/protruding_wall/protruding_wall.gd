extends StaticBody2D

@export var initial_state: bool = false

@onready var _overlapping_solid: Area2D = $"Overlapping Solid"
@onready var _sprite: Sprite2D = $Sprite2D

var _state: bool = false
var _target_state: bool = false


func set_state(state: bool) -> void:
	_target_state = state


func flip_state() -> void:
	_target_state = !_target_state


func _ready() -> void:
	_reset()


func _reset() -> void:
	_force_set_state(initial_state)


func _force_set_state(state: bool) -> void:
	_state = state
	_target_state = state
	if state:
		_sprite.frame = 1
		_overlapping_solid.monitoring = false
		set_collision_layer_value(1, true)
	else:
		_sprite.frame = 0
		_overlapping_solid.monitoring = true
		set_collision_layer_value(1, false)


func _physics_process(delta: float) -> void:
	if _target_state == _state:
		return

	if _target_state == false:
		_force_set_state(_target_state)
		return
	
	if _overlapping_solid.has_overlapping_bodies():
		return
	
	_force_set_state(_target_state)


# called by map
func _room_object_load(object_layer: Node) -> void:
	_reset()


# called by map
func _room_object_unload(object_layer: Node) -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if key_event and key_event.keycode == KEY_D and key_event.pressed:
		set_state(!_target_state)
		
		