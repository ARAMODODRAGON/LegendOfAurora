extends AnimatedSprite2D
class_name PlayerBody

signal death_animation_end()
signal attack_end()

@onready var sword_right_hitbox: HitboxComponent = $SwordRightHitbox
@onready var sword_down_hitbox: HitboxComponent = $SwordDownHitbox
@onready var sword_left_hitbox: HitboxComponent = $SwordLeftHitbox
@onready var sword_up_hitbox: HitboxComponent = $SwordUpHitbox

var _facing_direction: Enum.Direction = Enum.Direction.DOWN

var _is_dead: bool = false
var _is_attacking: bool = false
var _last_position: Vector2 = Vector2.ZERO
var _current_hitbox: HitboxComponent = null

func is_attacking() -> bool:
	return _is_attacking

func get_facing_vector() -> Vector2:
	match _facing_direction:
		Enum.Direction.DOWN:
			return Vector2.DOWN
		Enum.Direction.LEFT:
			return Vector2.LEFT
		Enum.Direction.UP:
			return Vector2.UP
		Enum.Direction.RIGHT:
			return Vector2.RIGHT
		Enum.Direction.NONE, _:
			return Vector2.ZERO

func update_animation(delta: float, input_dir: Vector2) -> void:
	if _is_dead:
		return

	if _is_attacking:
		_update_attack_hitbox()
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

	speed_scale = 1.0
	
	match _facing_direction:
		Enum.Direction.RIGHT:
			play(&"attack_right")
			_current_hitbox = sword_right_hitbox

		Enum.Direction.LEFT:
			play(&"attack_left")
			_current_hitbox = sword_left_hitbox

		Enum.Direction.UP:
			play(&"attack_up")
			_current_hitbox = sword_up_hitbox

		Enum.Direction.DOWN, Enum.Direction.NONE, _:
			play(&"attack_down")
			_current_hitbox = sword_down_hitbox


func die() -> void:
	_is_dead = true
	# spriteframes
	animation = &"dead"

	# tween animation
	var tween: Tween = create_tween()
	tween.tween_property(self, "rotation_degrees", 360.0 * 3.0, 2.0)
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 2.0)
	tween.tween_callback(death_animation_end.emit)

func _ready() -> void:
	_last_position = global_position

func _update_direction(input_dir: Vector2) -> void:
	var _facingh: Enum.Direction = Enum.Direction.NONE
	var _facingv: Enum.Direction = Enum.Direction.NONE
	
	if abs(input_dir.x) > 0.001:
		if input_dir.x > 0.0:
			_facingh = Enum.Direction.RIGHT
		else:
			_facingh = Enum.Direction.LEFT
	
	if abs(input_dir.y) > 0.001:
		if input_dir.y > 0.0:
			_facingv = Enum.Direction.DOWN
		else:
			_facingv = Enum.Direction.UP
	
	var last_facing_direction: Enum.Direction = _facing_direction

	if _facing_direction != _facingh && _facing_direction != _facingv:
		if _facingh != Enum.Direction.NONE:
			_facing_direction = _facingh
		elif _facingv != Enum.Direction.NONE:
			_facing_direction = _facingv
	
	if last_facing_direction != _facing_direction:
		_change_walk_animation_direction()

func _change_walk_animation_direction() -> void:
	match _facing_direction:
		Enum.Direction.RIGHT:
			animation = &"walk_right"
		Enum.Direction.LEFT:
			animation = &"walk_left"
		Enum.Direction.UP:
			animation = &"walk_up"
		Enum.Direction.DOWN, Enum.Direction.NONE, _:
			animation = &"walk_down"

func _update_walk_sprite(is_walking: bool) -> void:
	if is_walking:
		speed_scale = 1.0
	else:
		speed_scale = 0.0
		frame = 0

func _update_attack_hitbox() -> void:
	if frame == 2:
		_current_hitbox.visible = true
	
func _on_animation_finished() -> void:
	if _is_attacking and _current_hitbox:
		_current_hitbox.visible = false
		_is_attacking = false
		_change_walk_animation_direction()
		attack_end.emit()

