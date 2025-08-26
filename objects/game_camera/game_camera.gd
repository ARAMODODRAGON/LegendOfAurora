extends Camera2D
class_name GameCamera

@export var player_reference: Player

func _process(delta: float) -> void:
	if player_reference: _follow_player(delta)


func _follow_player(delta: float) -> void:
	
	position = player_reference.position