class_name GroupTrigger
extends TriggerBase

enum TriggerType {
	ON_EMPTY,
	ON_NOT_EMPTY
}


@export var group_name: StringName
@export var trigger_type: TriggerType = TriggerType.ON_EMPTY
@export var one_shot: bool = true


var was_triggered: bool = false


func _process(delta: float) -> void:
	if not was_triggered:
		_check()


func _check() -> void:
	match trigger_type:
		TriggerType.ON_EMPTY:
			if get_tree().get_node_count_in_group(group_name) == 0:
				_trigger()
				print("reached 0")

		TriggerType.ON_NOT_EMPTY:
			if get_tree().get_node_count_in_group(group_name) != 0:
				_trigger()
				print("reached not 0")


func _trigger() -> void:
	if one_shot:
		was_triggered = true

	update_state(TriggerState.ON)
	
