extends Area2D
class_name HurtboxComponent

## called when this hurtbox touches a hitbox
signal take_damage(damage: int, direction: Vector2)

## can be null
@export var root_node: Node2D = null

## can be set to handle health reduction
@export var health_component: HealthComponent

func _take_damage(damage: int, direction: Vector2) -> void:
	if health_component:
		health_component._take_damage(damage)
	
	take_damage.emit(damage, direction)