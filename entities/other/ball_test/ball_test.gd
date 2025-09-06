extends CharacterBody2D

const DECELERATION: float = 100.0

func _physics_process(delta: float) -> void:
	velocity = velocity.normalized() * move_toward(velocity.length(), 0.0, DECELERATION * delta)

	move_and_slide()

func _on_bongo_listener_component_bongo_hit(direction: Vector2) -> void:
	velocity = direction.normalized() * 100.0
