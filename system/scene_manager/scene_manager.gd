extends Node

@export var scene_index: Array[PackedScene]

var current_scene: Node = null

## loads the selected index at the begining of the next frame
func load_index(index: int) -> void:
	if index >= scene_index.size() || index < 0: 
		printerr("scene index was out of range")
		return
	
	if scene_index[index] == null ||  scene_index[index].can_instantiate() == false:
		printerr("scene index was null or could not instantiate")
		return
	
	## wait until right before process_frame
	await get_tree().process_frame

	## now we unload the current scene
	remove_child(current_scene)
	current_scene.free()

	## and load the new scene
	#current_scene = scene_index()





