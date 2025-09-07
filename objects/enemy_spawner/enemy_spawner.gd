extends Node2D
class_name EnemySpawner

@export var enemy_scene : PackedScene

var _enemy_ref: EnemyBase = null


## called by map
func _room_object_load(object_layer: Node) -> void:
	_enemy_ref = _spawn()
	object_layer.add_child(_enemy_ref)
	print("Spawned")


## called by map
func _room_object_unload(object_layer: Node) -> void:
	if _enemy_ref:
		_enemy_ref.free()
	_enemy_ref = null
	print("Despawned")
	

## spawns an enemy at this nodes position
func _spawn() -> EnemyBase:
	var enemy : EnemyBase = enemy_scene.instantiate()

	if enemy is EnemyBase:
		enemy.position = global_position
		return enemy

	enemy.free()
	return null