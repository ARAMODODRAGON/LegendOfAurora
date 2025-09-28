class_name LockedDungeonDoor
extends CharacterBody2D


@export var _linked_door: LockedDungeonDoor = null


var _is_open: bool = false


func _on_interactable_component_interact() -> void:
	_unlock()

func _unlock() -> void:
	if GameState.level_state().get_key_count() == 0 or _is_open:
		return
	
	GameState.level_state().use_key()
	_is_open = true

	visible = false
	set_collision_layer_value(1, false)

	if _linked_door and not _linked_door._is_open:
		_linked_door._unlock()