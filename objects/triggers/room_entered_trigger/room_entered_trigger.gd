## overrides trigger base functionality to only trigger ON/OFF upon loading/unloading room
class_name RoomEnteredTrigger
extends TriggerBase

func _init() -> void:
	add_to_group("room_objects")

func _room_object_load(object_layer: Node) -> void:
	if not enabled:
		return
	update_state(TriggerState.ON)


func _room_object_unload(object_layer: Node) -> void:
	if not enabled:
		return
	update_state(TriggerState.OFF)
