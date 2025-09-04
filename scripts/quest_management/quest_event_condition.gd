class_name QuestEventCondition
extends QuestCondition


## the quest line
@export var quest_line: QuestLine 
## the event to check for
@export var event_name: StringName

## if true checks if the quest is complete, if false checks if the quest has not been completed
@export var completion: bool = true

## checks the quest line
func validate() -> bool:
	if quest_line == null: return false
	return quest_line.check_event(event_name) == completion
