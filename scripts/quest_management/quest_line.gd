class_name QuestLine
extends Resource

@export var _events: Array[QuestEvent] = []

func get_event(name: StringName) -> QuestEvent:
	var index: int = _get_event_index(name)
	return _events[index] if (index != -1) else null

func check_event(name: StringName) -> bool: return false

## attempts to mark the event as complete
## confirms that the previous event has been completed
func complete_event(name: StringName) -> bool:
	var index: int = _get_event_index(name)

	if index == -1:
		printerr("Could not find event: " + name)
		return false
	
	if index > 0:
		if _events[index - 1].complete == false:
			printerr("Could not complete event: " + name + " as the previous event was not complete")
			return false

	_events[index].complete = true
	return true

func _get_event_index(name: StringName) -> int:
	return _events.find_custom(
		func(event: QuestEvent) -> bool:
			return event.name == name
	)
