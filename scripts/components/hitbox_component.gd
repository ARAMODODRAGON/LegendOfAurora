extends Area2D
class_name HitboxComponent

@export var damage: int = 1

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	var hurtbox: HurtboxComponent = area as HurtboxComponent
	if hurtbox:
		hurtbox._take_damage(damage)