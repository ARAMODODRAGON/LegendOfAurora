extends Node

@export var flip_time: float = 0.5

var timer: float = 0.0

func _process(delta: float) -> void:
	timer += delta
	if timer < flip_time:
		return
	
	timer -= flip_time
	for child in get_children():
		if child.has_method("flip_state"):
			child.call("flip_state")

	