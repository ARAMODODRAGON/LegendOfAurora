extends Area2D
class_name HitboxComponent

## can be null
@export var root_node: Node2D = null

## can be 0
@export var damage: int = 1

func _ready() -> void:
	area_entered.connect(_on_area_entered)

#func _make_4_directional(direction: Vector2) -> Vector2:
#	var angle : float = rad_to_deg(direction.angle())
#	if angle < 45.0 and angle >= 315.0:
#		return Vector2.RIGHT
#	elif angle < 0 and angle >= 45.0:
#		return Vector2.DOWN

func _on_area_entered(area: Area2D) -> void:
	var hurtbox: HurtboxComponent = area as HurtboxComponent
	if hurtbox:
		if hurtbox.root_node and root_node:
			var direction: Vector2 = hurtbox.root_node.global_position - root_node.global_position
			hurtbox._take_damage(damage, direction.normalized())
		else:
			hurtbox._take_damage(damage, Vector2.ZERO)