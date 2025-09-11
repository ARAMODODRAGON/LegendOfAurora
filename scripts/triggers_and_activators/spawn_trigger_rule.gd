class_name SpawnTriggerRule
extends TriggerRule

@export var enemy_scene: PackedScene

var _enemy_ref: EnemyBase = null
var _parent: Node2D = null


## virtual functions

func _on_triggered_on() -> void: 
	var enemy := _spawn()
	enemy.position = _parent.global_position
	_parent.add_sibling(enemy)


func _on_triggered_off() -> void: 
	if _enemy_ref:
		_enemy_ref.free()
	_enemy_ref = null


## methods

func _ready() -> void:
	_parent = get_parent() as Node2D


func _spawn() -> EnemyBase:
	var enemy: Node = enemy_scene.instantiate()

	if enemy is EnemyBase:
		return enemy as EnemyBase

	enemy.free()
	return null
