## scorpion behaviour
extends EnemyBase

## enums
const Direction := Enum.Direction

enum Type {
	SAND,
	POISONED,
}

enum ActionState {
	DEFAULT,
	KNOCKBACK,
	DYING,
}

## defaults
@export var scorpion_type: Type = Type.SAND:
	set(value):
		scorpion_type = value
		_update_type()
	get:
		return scorpion_type
@export var move_speed: float = 10.0
@export var animation_fps: float = 5.0
@export var knockback_speed: float = 30.0
@export var knockback_time: float = 0.5

## alternate textures
@export var _sand_scorpion_texture: Texture2D
@export var _poisoned_scorpion_texture: Texture2D


## references
@onready var health_component: HealthComponent = $HealthComponent


## state
var _action_state := ActionState.DEFAULT
var _facing_state := Direction.DOWN
var _first_frame: int = 0
var _frame_timer: float = 0.0
var _is_knocked_back: bool = true

var _tween: Tween = null

## methods

func _ready() -> void:
	_update_type()


func _update_type() -> void:
	match scorpion_type:
		Type.POISONED:
			body_sprite.texture = _sand_scorpion_texture
		Type.SAND, _: # default
			body_sprite.texture = _sand_scorpion_texture
	
	body_sprite.hframes = 2
	body_sprite.vframes = 4


func _process(delta: float) -> void:
	match _facing_state:
		Direction.LEFT:
			_first_frame = 4
		Direction.DOWN:
			_first_frame = 0
		Direction.RIGHT:
			_first_frame = 2
		Direction.UP:
			_first_frame = 6
	
	if velocity.length() > Util.VERY_SMALL:
		var anim_delta := (1.0 / animation_fps)
		_frame_timer += delta

		if _frame_timer > anim_delta:
			_frame_timer -= anim_delta

			if body_sprite.frame == _first_frame:
				body_sprite.frame = _first_frame + 1
			else:
				body_sprite.frame = _first_frame
	else:
		body_sprite.frame = _first_frame


func _physics_process(delta: float) -> void:
	
	match _action_state:
		ActionState.DEFAULT:
			var direction := Enum.vector_from_direction(_facing_state)

			velocity = direction * move_speed

			if test_move(get_transform(), velocity * delta):
				_change_direction((randi() % 2) == 1)
				return
		
		ActionState.KNOCKBACK, ActionState.DYING, _:
			pass
	
	move_and_slide()


func _change_direction(turn_left: bool) -> void:
	if turn_left:
		match _facing_state:
			Direction.LEFT:
				_facing_state = Direction.DOWN
			Direction.DOWN:
				_facing_state = Direction.RIGHT
			Direction.RIGHT:
				_facing_state = Direction.UP
			Direction.UP:
				_facing_state = Direction.LEFT
	else:
		match _facing_state:
			Direction.LEFT:
				_facing_state = Direction.UP
			Direction.DOWN:
				_facing_state = Direction.LEFT
			Direction.RIGHT:
				_facing_state = Direction.DOWN
			Direction.UP:
				_facing_state = Direction.RIGHT


func _on_die() -> void:
	if _action_state == ActionState.DYING:
		return
	
	_action_state = ActionState.DYING

	_tween = create_tween()
	_tween.tween_property(body_sprite, "modulate", Color.RED, knockback_time * 0.5)

	await _tween.finished

	queue_free()

	



func _on_take_damage(damage: int, direction: Vector2) -> void:
	if health_component.health == 0:
		velocity = direction * knockback_speed

	if _action_state != ActionState.DEFAULT or health_component.health == 0 or _tween != null:
		return
	
	_action_state = ActionState.KNOCKBACK
	velocity = direction * knockback_speed
	
	_tween = create_tween()

	_tween.tween_property(body_sprite, "modulate", Color.RED, knockback_time * 0.5)
	_tween.tween_property(body_sprite, "modulate", Color.WHITE, knockback_time * 0.5)
	
	await _tween.finished
	_tween = null

	_action_state = ActionState.DEFAULT

	_facing_state = Enum.flip_direction(Enum.direction_from_vector(direction))
