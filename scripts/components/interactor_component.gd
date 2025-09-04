extends Area2D
class_name InteractorComponent

@export var MAX_INTERACTION_ANGLE: float = 30.0

## checks for interactables in the area
func trigger_interaction(facing: Vector2, callback: Callable = Callable()) -> bool:
	if callback == null:
		return false

	if !has_overlapping_areas():
		return false

	var areas: Array[Area2D] = get_overlapping_areas()
	var count: int = 0
	for area in areas:
		# check type
		var interactable: InteractableComponent = area as InteractableComponent
		if interactable:
			# check if facing interactable
			var direction: Vector2 = (interactable.global_position - global_position).normalized()
			var angle: float = rad_to_deg(direction.angle_to(facing))

			if absf(angle) < MAX_INTERACTION_ANGLE:
				# count and invoke interaction
				count += 1
				interactable._on_interact()
				if callback.is_valid():
					callback.call(interactable)
	
	return count > 0