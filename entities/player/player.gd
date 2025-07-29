extends CharacterBody2D
class_name Player

@export var WALK_SPEED: float
@export var SLOW_SPEED: float

@onready var _player_body_sprite: PlayerBody = $BodySprite
@onready var spirit_orb: SpiritOrb = $SpiritOrb

## goes to the defined room
func goto_room(screen_space: Rect2) -> void:
	
	pass

func _get_input_dir() -> Vector2:
	var _input_dir: Vector2 = Input.get_vector("LEFT", "RIGHT", "UP", "DOWN").normalized()
	return _input_dir

func _process(delta: float) -> void:
	var _slow_held: bool = Input.is_action_pressed("SLOW")
	
	_player_body_sprite.update_animation(delta, _get_input_dir(), _slow_held)
	spirit_orb.update_animation(delta, _slow_held)

func _physics_process(delta: float) -> void:
	var _input_dir: Vector2 = _get_input_dir()
	var _slow_held: bool = Input.is_action_pressed("SLOW")
	
	## determine the movement speed and apply it to velocity
	var _speed: float = WALK_SPEED if !_slow_held else SLOW_SPEED
	velocity = _input_dir * _speed
	
	move_and_slide()
	
