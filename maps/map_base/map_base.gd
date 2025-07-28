extends Node
class_name MapBase

@export var player : Player = null

@onready var game_camera: GameCamera = $GameCamera

func _ready() -> void:
	game_camera.visible = true
	game_camera.follow_node = player


func _on_game_camera_begin_screen_movement(direction: Vector2i) -> void:
	player.process_mode = Node.PROCESS_MODE_DISABLED


func _on_game_camera_unpause() -> void:
	player.process_mode = Node.PROCESS_MODE_INHERIT
