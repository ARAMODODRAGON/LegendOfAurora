extends Node

var current_scene: Node = null

var _changing_scenes: bool = false

func load_scene(scene: PackedScene) -> Node:
	if _changing_scenes || scene == null || scene.can_instantiate() == false:
		return null

	get_tree().change_scene_to_packed(scene)
	current_scene = null

	_changing_scenes = true
	await get_tree().node_added
	current_scene = get_tree().current_scene
	await current_scene.ready

	_changing_scenes = false

	current_scene = get_tree().current_scene
	return current_scene

func load_map(map: PackedScene, target_warp: String) -> MapBase:
	if _changing_scenes || map == null || map.can_instantiate() == false:
		return null

	get_tree().change_scene_to_packed(map)
	current_scene = null

	_changing_scenes = true
	await get_tree().node_added
	current_scene = get_tree().current_scene
	await current_scene.ready

	_changing_scenes = false
	
	var mapbase : MapBase = current_scene as MapBase
	mapbase.warp_player(target_warp)
	
	return mapbase

func _ready() -> void:
	current_scene = get_tree().current_scene
