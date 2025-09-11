class_name SpawnTriggerRule
extends TriggerRule

## exports

@export var enemy_scene: PackedScene
@export var respawn_if_dead: bool = false
@export var position_override: Node2D = null

## state

var _enemy_ref: EnemyBase = null
var _parent: Node2D = null
var _was_killed: bool = false


## virtual functions

func _on_triggered_on() -> void: 
	if _was_killed and not respawn_if_dead:
		return
	
	_enemy_ref = _spawn()
	
	if position_override:
		_enemy_ref.position = position_override.global_position
	elif _parent:
		_enemy_ref.position = _parent.global_position
	else:
		print("failed to spawn enemy because parent was not valid")
		_enemy_ref.free()
		return
	
	_parent.add_sibling(_enemy_ref) # _ready is called
	_enemy_ref.health_component.die.connect(
		func() -> void:
			_was_killed = true
	)


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
