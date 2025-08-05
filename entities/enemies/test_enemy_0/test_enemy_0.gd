extends EnemyBase
#class_name TestEnemy0

func _process(delta: float) -> void:
	rotate(delta * deg_to_rad(45))