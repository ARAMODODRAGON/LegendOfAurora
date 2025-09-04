extends EnemyBase
#class_name TestEnemy0

func _process(delta: float) -> void:
	rotate(delta * deg_to_rad(45))


func _on_die() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	

func _on_take_damage(damage: int, direction: Vector2) -> void:
	print("YEOUCH")