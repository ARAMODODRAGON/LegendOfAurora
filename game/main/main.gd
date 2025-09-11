extends Node
class_name Main

@export var DEFAULT_SCENE_INDEX: int
@export var BUILD_INDEX: Array[PackedScene]

var _current_scene: Node = null
var _current_scene_index: int = -1

func _get_scene_index() -> int:
	return _current_scene_index

func _ready() -> void:
	# bind our load scene function
	Game._main_scene = self
	# default load scene
	_load_scene_index(DEFAULT_SCENE_INDEX)

func _load_scene_index(index: int) -> void:
	_load_scene_coroutine(BUILD_INDEX[index], index)

func _load_scene_index_corountine(index: int) -> void:
	await _load_scene_coroutine(BUILD_INDEX[index], index)

# coroutine to load a packed scene
func _load_scene_coroutine(packed_scene: PackedScene, index: int) -> void:
	# check if we can instance the packed scene
	if !packed_scene.can_instantiate():
		printerr("Could not load scene: " + str(packed_scene))
		return
	
	# wait until right before process is called
	await get_tree().process_frame

	# unload existing scene
	if _current_scene: 
		remove_child(_current_scene)
		_current_scene.free()
		_current_scene = null
		_current_scene_index = -1
	
	# load new scene
	_current_scene = packed_scene.instantiate()
	_current_scene_index = index

	# attach and call _ready
	add_child(_current_scene)
	
