extends Node

@export var DEFAULT_SCENE_INDEX: int
@export var BUILD_INDEX: Array[PackedScene]

var _current_scene: Node = null

func _ready() -> void:
	# bind our load scene function
	Game._load_scene_callable = _load_scene_index
	# default load scene
	_load_scene_index(DEFAULT_SCENE_INDEX)

func _load_scene_index(index: int) -> void:
	_load_scene(BUILD_INDEX[index])

# coroutine to load a packed scene
func _load_scene(packed_scene: PackedScene) -> void:
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
	
	# load new scene
	_current_scene = packed_scene.instantiate()

	# attach and call _ready
	add_child(_current_scene)
	
