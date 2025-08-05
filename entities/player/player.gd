extends CharacterBody2D
class_name Player

@export var WALK_SPEED: float
@export var SLOW_SPEED: float

@onready var body_sprite: PlayerBody = $BodySprite
@onready var spirit_orb: SpiritOrb = $SpiritOrb

func _get_input_dir() -> Vector2:
	var input_dir: Vector2 = Input.get_vector("LEFT", "RIGHT", "UP", "DOWN").normalized()
	return input_dir

func _process(delta: float) -> void:
	var slow_held: bool = Input.is_action_pressed("SLOW")
	
	body_sprite.update_animation(delta, _get_input_dir(), slow_held)
	spirit_orb.update_animation(delta, slow_held)

func _physics_process(_delta: float) -> void:
	var input_dir: Vector2 = _get_input_dir()
	var slow_held: bool = Input.is_action_pressed("SLOW")
	
	## determine the movement speed and apply it to velocity
	var speed: float = WALK_SPEED if !slow_held else SLOW_SPEED
	velocity = input_dir * speed
	
	move_and_slide()
	
