extends Node2D
class_name EnemySpawner

@export var enemy_scene : PackedScene

## spawns an enemy at this nodes position
func spawn() -> EnemyBase:
	var enemy : EnemyBase = enemy_scene.instantiate()

	if enemy is EnemyBase:
		enemy.position = global_position
		return enemy

	enemy.free()
	return null