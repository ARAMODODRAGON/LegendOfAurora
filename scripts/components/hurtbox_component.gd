extends Area2D
class_name HurtboxComponent

signal take_damage(damage: int)

@export var health_component: HealthComponent

func _take_damage(damage: int) -> void:
	if health_component:
		health_component._take_damage(damage)
	
	take_damage.emit(damage)