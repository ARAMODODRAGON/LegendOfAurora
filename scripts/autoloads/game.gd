extends Node

var _main_scene: Main

func get_scene_index() -> int:
	if _main_scene:
		return _main_scene._get_scene_index()
	else:
		return -1

func load_scene(index: int) -> void:
	if _main_scene:
		_main_scene._load_scene_index(index)