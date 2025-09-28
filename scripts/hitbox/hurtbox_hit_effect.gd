class_name HurtboxHitEffect
extends HitEffect

## called when this hurtbox takes damage
## direction may be Vector2.ZERO
signal damage_taken(damage: int, direction: Vector2)


@export var health_component : HealthComponent = null


func take_damage(damage: int, direction: Vector2) -> void:
	if health_component:
		health_component._take_damage(damage)
	
	damage_taken.emit(damage, direction)


## do nothing as all interaction logic is in other classes
func _trigger(parent: Hitbox, target: Hitbox) -> void: pass