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

var _facing_direction: Direction = Direction.DOWN

var _is_dead: bool = false
var _is_attacking: bool = false
var _last_position: Vector2 = Vector2.ZERO
#var _current_hitbox: CollisionShape2D = null
var _has_dealt_damage: bool = false

func is_attacking() -> bool:
	return _is_attacking

func get_facing_vector() -> Vector2:
	match _facing_direction:
		Direction.DOWN:
			return Vector2.DOWN
		Direction.LEFT:
			return Vector2.LEFT
		Direction.UP:
			return Vector2.UP
		Direction.RIGHT:
			return Vector2.RIGHT
		Direction.NONE, _:
			return Vector2.ZERO

func update_animation(delta: float, input_dir: Vector2) -> void:
	if _is_dead:
		return

	if _is_attacking:
		pass
		#_update_attack_hitbox()
	else:
		var is_walking: bool = not _last_position.is_equal_approx(global_position)

		if is_walking:
			_update_direction(input_dir)
			
		_update_walk_sprite(is_walking)

		_last_position = global_position

	
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
	
func attack() -> void:
	if _is_attacking or _is_dead:
		return

	_is_attacking = true
	_has_dealt_damage = false

	speed_scale = 1.0
	
	var _expand_marker := _get_expand_marker(_facing_direction)

	match _facing_direction:
		Direction.RIGHT:
			play(&"attack_right")
		Direction.LEFT:
			play(&"attack_left")
		Direction.UP:
			play(&"attack_up")
		Direction.DOWN, Direction.NONE, _:
			play(&"attack_down")
	
	var _offset := Enum.vector_from_direction(_facing_direction) * _sword_box_offset

	_sword_hitbox.monitoring = true
	_sword_hitbox.position = _expand_marker.position + _offset


func die() -> void:
	_is_dead = true
	# spriteframes
	play(&"dead")

	# tween animation
	var tween: Tween = create_tween()
	tween.tween_property(self, "rotation_degrees", 360.0 * 3.0, 2.0)
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 2.0)
	tween.tween_callback(death_animation_end.emit)

func _ready() -> void:
	_last_position = global_position

func _update_direction(input_dir: Vector2) -> void:
	var _facingh: Direction = Direction.NONE
	var _facingv: Direction = Direction.NONE
	
	if abs(input_dir.x) > 0.001:
		if input_dir.x > 0.0:
			_facingh = Direction.RIGHT
		else:
			_facingh = Direction.LEFT
	
	if abs(input_dir.y) > 0.001:
		if input_dir.y > 0.0:
			_facingv = Direction.DOWN
		else:
			_facingv = Direction.UP
	
	var last_facing_direction: Direction = _facing_direction

	if _facing_direction != _facingh && _facing_direction != _facingv:
		if _facingh != Direction.NONE:
			_facing_direction = _facingh
		elif _facingv != Direction.NONE:
			_facing_direction = _facingv
	
	if last_facing_direction != _facing_direction:
		_change_walk_animation_direction()

func _change_walk_animation_direction() -> void:
	match _facing_direction:
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

# func _update_attack_hitbox() -> void:
# 	 if frame == 1 and not _has_dealt_damage:
# 	 	_current_hitbox.trigger()
# 	 	_has_dealt_damage = true
# 	pass
	
func _on_animation_finished() -> void:
	if _is_attacking:
		_sword_hitbox.monitoring = false
		_is_attacking = false
		_change_walk_animation_direction()
		attack_end.emit()
	

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
