extends CharacterBody2D

## enum reference
const Direction := Enum.Direction

## the initial state of the golem
@export var initial_facing_direction: Direction


var _facing_direction: Direction

func _ready() -> void:
	_set_facing_direction(initial_facing_direction)


## set the facing direction
func _set_facing_direction(direction: Enum.Direction) -> void:
	_facing_direction = initial_facing_direction
	pass


## called to turn around the golem
func _turn_around() -> void:
	match _facing_direction:
		Direction.LEFT:
			_set_facing_direction(Direction.RIGHT)
		Direction.RIGHT:
			_set_facing_direction(Direction.RIGHT)
		Direction.UP:
			_set_facing_direction(Direction.RIGHT)
		Direction.DOWN:
			_set_facing_direction(Direction.RIGHT)
		Direction.NONE, _:
			_set_facing_direction(Direction.RIGHT)



## called by map
func _room_object_load(object_layer: Node) -> void:
	pass


## called by map
func _room_object_unload(object_layer: Node) -> void:
	pass


## when in range of the bongo shockwave
func _on_bongo_hit(direction: Vector2) -> void:
	var move_vector: Vector2 = Enum.vector_from_direction(facing_direction)
	move_vector *= Util.TILE_SIZE

