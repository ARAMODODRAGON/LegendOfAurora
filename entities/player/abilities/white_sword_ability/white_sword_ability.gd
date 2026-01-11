class_name WhiteSwordAbility
extends Ability


## private variables


var _hitbox: Hitbox = null
var _shape: RectangleShape2D = null
var _running: bool = false
var _sprite: AnimatedSprite2D = null

## methods


func setup(sprite_root: Node2D) -> void:
	## node should already exist
	_hitbox = sprite_root.get_node("SwordHitbox") as Hitbox
	_shape = (_hitbox.get_node("CollisionShape2D") as CollisionShape2D).shape as RectangleShape2D


func commanded(facing: Direction, root: Node2D, sprite: AnimatedSprite2D, extent_offset: Vector2) -> void:
	_hitbox.position = sprite.position + extent_offset
	_hitbox.position += Enum.vector_from_direction(facing) * _shape.size * 0.5
	_hitbox.monitoring = true
	_sprite = sprite

	_sprite.speed_scale = 1.0

	match facing:
		Direction.RIGHT:
			_sprite.play(&"attack_right")
		Direction.LEFT:
			_sprite.play(&"attack_left")
		Direction.UP:
			_sprite.play(&"attack_up")
		Direction.DOWN, Direction.NONE, _:
			_sprite.play(&"attack_down")

	_sprite.animation_finished.connect(_sword_strike_end, Object.CONNECT_ONE_SHOT)
	_running = true


func _sword_strike_end() -> void:
	_hitbox.monitoring = false
	_running = false


func process(delta: float, facing: Direction) -> void:
	pass


func interrupt() -> void:
	_sprite.animation_finished.disconnect(_sword_strike_end)
	_sword_strike_end()


func is_done() -> bool:
	return _running == false
