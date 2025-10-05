extends AnimatedSprite2D
class_name PlayerBody

## enum reference
const Direction := Enum.Direction

signal death_animation_end()
signal attack_end()

@export_subgroup("Sword")
@export var _sword_hitbox: Hitbox = null
@export var _sword_box_offset := Vector2.ZERO

#@export_subgroup("")

@export_subgroup("Expand Markers")
@export var _up_marker: Marker2D = null
@export var _down_marker: Marker2D = null
@export var _left_marker: Marker2D = null
@export var _right_marker: Marker2D = null

var _is_dead: bool = false
var _has_dealt_damage: bool = false
var _stored_direction: Direction = Direction.NONE

#func is_attacking() -> bool:
#	return _is_attacking


func get_marker_position(facing_dir: Direction) -> Vector2:
	match facing_dir:
		Direction.UP:
			return _up_marker.position
		Direction.DOWN:
			return _down_marker.position
		Direction.LEFT:
			return _left_marker.position
		Direction.RIGHT:
			return _right_marker.position
		_:
			return Vector2.ZERO


func update_animation(delta: float, is_walking: bool, facing_dir : Direction) -> void:
	if _is_dead:
		return

	if facing_dir != _stored_direction:
		_stored_direction = facing_dir
		_change_walk_animation_direction(_stored_direction)
	
	_update_walk_sprite(is_walking)


func reset_animation(facing_dir: Direction) -> void:
	_stored_direction = facing_dir
	_change_walk_animation_direction(_stored_direction)

	
func take_damage(time: float) -> void:
	var full: float = time
	var quarter: float = full * 0.25
	var half: float = full * 0.5

	var tween_a: Tween = create_tween()
	tween_a.tween_property(self, "rotation_degrees", 45, quarter)
	tween_a.tween_property(self, "rotation_degrees", -45, quarter)
	tween_a.tween_property(self, "rotation_degrees", 45, quarter)
	tween_a.tween_property(self, "rotation_degrees", 0, quarter)
	
	var tween_b: Tween = create_tween()
	tween_b.tween_property(self, "modulate", Color.RED, half)
	tween_b.tween_property(self, "modulate", Color.WHITE, half)


func die() -> void:
	_is_dead = true
	# spriteframes
	play(&"dead")

	# tween animation
	var tween: Tween = create_tween()
	tween.tween_property(self, "rotation_degrees", 360.0 * 3.0, 2.0)
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 2.0)
	tween.tween_callback(death_animation_end.emit)

func _change_walk_animation_direction(facing_dir: Direction) -> void:
	match facing_dir:
		Direction.RIGHT:
			play(&"walk_right")
		Direction.LEFT:
			play(&"walk_left")
		Direction.UP:
			play(&"walk_up")
		Direction.DOWN, Direction.NONE, _:
			play(&"walk_down")

func _update_walk_sprite(is_walking: bool) -> void:
	if is_walking:
		speed_scale = 1.0
	else:
		speed_scale = 0.0
		frame = 0


func _get_expand_marker(direction: Direction) -> Marker2D:
	match direction:
		Direction.UP:
			return _up_marker
		Direction.DOWN:
			return _down_marker
		Direction.LEFT:
			return _left_marker
		Direction.RIGHT:
			return _right_marker
		_:
			return null
