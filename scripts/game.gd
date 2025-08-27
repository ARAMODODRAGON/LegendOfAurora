extends Node

var _load_scene_callable: Callable 

func load_scene(index: int) -> void:
	if _load_scene_callable:
		_load_scene_callable.call(index)