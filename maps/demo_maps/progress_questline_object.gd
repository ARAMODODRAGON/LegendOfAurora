extends InteractableComponent

@export var quest_line : QuestLine
@export var quest_events : Array[StringName]

var last_index: int = -1

func _on_interact() -> void: 
	if last_index < (quest_events.size() - 1):
		last_index += 1

		var target: StringName = quest_events[last_index]
		if quest_line:
			print("completed event: " + target)
			quest_line.complete_event(target)
