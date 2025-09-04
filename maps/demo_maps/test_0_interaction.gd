extends InteractableComponent

@export var quest_condition: QuestCondition

@export var false_string: String
@export var true_string: String

func _on_interact() -> void: 
	if quest_condition.validate():
		print(true_string)
	else:
		print(false_string)