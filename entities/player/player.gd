extends CharacterBody2D
class_name Player

signal entered_warp(warp: WarpPoint)

@export var WALK_SPEED: float

@onready var body_sprite: PlayerBody = $BodySprite
@onready var timer: Timer = $Timer

func _get_input_dir() -> Vector2:
	var input_dir: Vector2 = Input.get_vector("LEFT", "RIGHT", "UP", "DOWN").normalized()
	return input_dir

func _process(delta: float) -> void:
	body_sprite.update_animation(delta, _get_input_dir())

func _physics_process(_delta: float) -> void:
	var input_dir: Vector2 = _get_input_dir()
	
	## determine the movement speed and apply it to velocity
	var speed: float = WALK_SPEED
	velocity = input_dir * speed
	
	move_and_slide()
	
func _on_warp_entered(area: Area2D) -> void:
	if timer.is_stopped() == false: return

	var warp: WarpPoint = area as WarpPoint
	if warp == null: return
	entered_warp.emit(warp)
