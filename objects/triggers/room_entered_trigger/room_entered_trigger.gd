## overrides trigger base functionality to only trigger ON/OFF upon loading/unloading room
extends TriggerBase


func _room_object_load(object_layer: Node) -> void:
	update_state(TriggerState.ON)


func _room_object_unload(object_layer: Node) -> void:
	update_state(TriggerState.OFF)
