extends CharacterBody2D
class_name Player

signal entered_warp(warp: WarpPoint)
signal death_animation_end()

@export var WALK_SPEED: float

@onready var body_sprite: PlayerBody = $BodySprite
@onready var timer: Timer = $Timer
@onready var health_component: HealthComponent = $Components/HealthComponent

var _is_dead: bool = false

func is_dead() -> bool:
	return _is_dead

func _ready() -> void:
	body_sprite.death_animation_end.connect(death_animation_end.emit)

func _get_input_dir() -> Vector2:
	if _is_dead:
		return Vector2.ZERO
	else:
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

func _on_take_damage(damage: int) -> void:
	if health_component.health > 0:
		body_sprite.take_damage()

func _on_die() -> void:
	_is_dead = true
	body_sprite.die()