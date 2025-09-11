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

func load_scene_with_warp_coroutine(index: int, warp_point: String) -> void:
	if _main_scene == null:
		return

	await _main_scene._load_scene_index_corountine(index)
	
	var map := _main_scene._current_scene as MapBase
	if map:
		map.warp_player(warp_point)

