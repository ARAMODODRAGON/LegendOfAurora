class_name TriggerEnableTriggerRule
extends TriggerRule

@export var target_triggers: Array[TriggerBase] = []
@export var enables_trigger: bool = true

func _on_triggered_on() -> void: 
	_change_triggers_enabled_state(enables_trigger)


func _on_triggered_off() -> void: 
	_change_triggers_enabled_state(!enables_trigger)


func _change_triggers_enabled_state(enable: bool) -> void:
	for trigger in target_triggers:
		trigger.enabled = enable