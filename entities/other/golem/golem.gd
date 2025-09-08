extends CharacterBody2D

## enum reference
const Direction := Enum.Direction

## exports
@export var move_time: float = 0.3
@export var initial_facing_direction: Direction = Direction.DOWN

@onready var _sprite: Sprite2D = $Sprite2D

## other variables that store the initial state
var _initial_position: Vector2
var _facing_direction: Direction
var _tween: Tween = null


func _ready() -> void:
	_initial_position = position
	_reset()


## resets the golem to its initial position
func _reset() -> void:

	position = _initial_position

	# since the object may be paused we have to tell the physics server to move the golem
	#PhysicsServer2D.body_set_state(
	#	get_rid(),
	#	PhysicsServer2D.BODY_STATE_TRANSFORM,
	#	get_transform().translated(_initial_position - position)
	#)

	_set_facing_direction(initial_facing_direction)


## set the facing direction
func _set_facing_direction(direction: Enum.Direction) -> void:
	_facing_direction = direction
	match direction:
		Direction.LEFT:
			_sprite.frame = 2
		Direction.RIGHT:
			_sprite.frame = 1
		Direction.UP:
			_sprite.frame = 3
		Direction.DOWN:
			_sprite.frame = 0
		Direction.NONE, _:
			pass


## called to turn around the golem
func _turn_around() -> void:
	_set_facing_direction(Enum.flip_direction(_facing_direction))


## called by map
func _room_object_load(object_layer: Node) -> void:
	_reset()


## called by map
func _room_object_unload(object_layer: Node) -> void:
	_reset()


## called to move the golem
func _try_move_golem(direction: Direction, should_try_flip: bool = true) -> void:

	var move_vector: Vector2 = Enum.vector_from_direction(_facing_direction)
	move_vector *= Util.TILE_SIZE

	# if the movement can be blocked
	if test_move(get_transform(), move_vector):
		if should_try_flip:
			_turn_around()
			_try_move_golem(Enum.flip_direction(_facing_direction), false)

		return
	
	# tween movement
	_tween = create_tween()
	_tween.tween_property(self, "position", position + move_vector, move_time)
	_tween.tween_callback(
		func() -> void: 
			_tween = null
	)


## when in range of the bongo shockwave
func _on_bongo_hit(direction: Vector2) -> void:
	# check if we are currently moving
	if _tween:
		return
	
	_try_move_golem(_facing_direction)

	



	

