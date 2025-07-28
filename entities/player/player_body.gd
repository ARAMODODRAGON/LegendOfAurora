extends Sprite2D
class_name PlayerBody

enum FacingDirection {
	NONE,
	LEFT,
	RIGHT,
	UP,
	DOWN,
}

var _facing_direction : FacingDirection = FacingDirection.DOWN

func update_animation(delta: float, input_dir: Vector2, slow_held: bool) -> void:
	if input_dir.length_squared() > 0.01:
		_update_direction(input_dir)
	
	if !slow_held: _update_idle_sprite()
	else: _update_slow_sprite()
	

func _update_direction(input_dir: Vector2) -> void:
	var _facingh : FacingDirection = FacingDirection.NONE
	var _facingv : FacingDirection = FacingDirection.NONE
	
	if abs(input_dir.x) > 0.001:
		if input_dir.x > 0.0:
			_facingh = FacingDirection.RIGHT
		else:
			_facingh = FacingDirection.LEFT
	
	if abs(input_dir.y) > 0.001:
		if input_dir.y > 0.0:
			_facingv = FacingDirection.DOWN
		else:
			_facingv = FacingDirection.UP
	
	if _facing_direction != _facingh && _facing_direction != _facingv:
		if _facingh != FacingDirection.NONE:
			_facing_direction = _facingh
		elif _facingv != FacingDirection.NONE:
			_facing_direction = _facingv

func _update_idle_sprite() -> void:
	match _facing_direction:
		FacingDirection.LEFT:
			frame = 3
		FacingDirection.RIGHT:
			frame = 2
		FacingDirection.UP:
			frame = 1
		FacingDirection.DOWN:
			frame = 0
		_: pass

func _update_slow_sprite() -> void:
	match _facing_direction:
		FacingDirection.LEFT:
			frame = 11
		FacingDirection.RIGHT:
			frame = 10
		FacingDirection.UP:
			frame = 9
		FacingDirection.DOWN:
			frame = 8
		_: pass
