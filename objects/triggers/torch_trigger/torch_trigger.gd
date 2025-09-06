extends StaticBody2D

## called when the torch turns on/off and when the torch is initialized
## state is true when the torch turns on and false when it turns off
## this can be reversed using reverse_output
signal define_state(state: bool)

## the state that the torch will start in
@export var initial_state: bool = false

## should we reverse the state_changed output
@export var reverse_output: bool = false

@onready var _sprite: Sprite2D = $Sprite2D

var _timer: float = 0.0

func get_state() -> bool:
	return _sprite.frame == 1

func set_state(state: bool) -> void:
	if get_state() != state:
		_change_state(state)

func _change_state(state: bool) -> void:
	if state:
		_sprite.frame = 1
	else:
		_sprite.frame = 0
	
	define_state.emit(state)

func _ready() -> void:
	_change_state(initial_state)

func _process(delta: float) -> void:
	if not get_state():
		return 

	const frame_rate: float = (5.0 / 60.0)

	if _timer > 0.0:
		_timer -= delta
	else:
		_timer += frame_rate
		_sprite.flip_h = not _sprite.flip_h

func _on_bongo_listener_component_bongo_hit(direction:Vector2) -> void:
	if get_state():
		print("triggered!")
	set_state(false)
