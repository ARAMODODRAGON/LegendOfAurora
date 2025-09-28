class_name DamageHitEffect
extends HitEffect


@export var damage : int = 1


func _trigger(parent: Hitbox, target: Hitbox) -> void:
	var direction := Vector2.ZERO

	if parent.owner is Node2D and target.owner is Node2D:
		direction = (target.owner as Node2D).global_position - (parent.owner as Node2D).global_position
		direction = Util.restrict_vector_four_directional(direction.normalized())
	
	for effect in target._effects:
		var hurtbox := effect as HurtboxHitEffect
		if hurtbox:
			hurtbox.take_damage(damage, direction)