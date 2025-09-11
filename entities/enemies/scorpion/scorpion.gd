## scorpion behaviour
extends EnemyBase

## enums
const Direction := Enum.Direction

enum ActionState {
	DEFAULT,
	KNOCKBACK,
	DYING,
}

## defaults
@export var move_speed: float = 10.0
@export var animation_fps: float = 5.0
@export var knockback_speed: float = 30.0
@export var knockback_time: float = 0.5


## references
@onready var health_component: HealthComponent = $HealthComponent


## state
var _action_state := ActionState.DEFAULT
var _facing_state := Direction.DOWN
var _first_frame: int = 0
var _frame_timer: float = 0.0
var _is_knocked_back: bool = true
var _screen: Rect2 

var _tween: Tween = null

## methods

func _ready() -> void:
	_facing_state = (randi() % 4) as Direction
	_screen = Util.screen_from_position(global_position)


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
			_detect_player()

			var direction := Enum.vector_from_direction(_facing_state)

			velocity = direction * move_speed

			if test_move(get_transform(), velocity * delta):
				_change_direction((randi() % 2) == 1)
				return
		
		ActionState.KNOCKBACK, ActionState.DYING, _:
			pass
	
	move_and_slide()

	## clamp and turn around
	if not _screen.has_point(global_position) and (randi() % 7 == 1):
		_facing_state = Enum.flip_direction(_facing_state)
	
	global_position.clamp(_screen.position, _screen.end)


func _detect_player() -> void:
	var player := Game.get_player()
	if player == null:
		return

	var distance: float = (player.global_position - global_position).length()

	if distance > 32.0:
		return

	var direction: Vector2 = (player.global_position - global_position).normalized()
	var restricted_direction: Vector2 = Util.restrict_vector_four_directional(direction)

	## cannot turn around
	if Enum.direction_from_vector(restricted_direction) == Enum.flip_direction(_facing_state):
		return

	if (direction - restricted_direction).length() < 7.0:
		_facing_state = Enum.direction_from_vector(restricted_direction)
	


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
