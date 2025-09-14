class_name ObjectActivationTriggerRule
extends TriggerRule

## exports

@export var activation_object_references: Array[ActivationObject] = []


## virtual functions

## override _update_state to allow slightly different logic
func _update_state(state: TriggerState) -> void:
	# dont call super
	#super._update_state(state) 
	if _state != state:
		_state = state

		# DIFF
		for obj in activation_object_references:
			if obj:
				obj._update_state(state)
		# DIFF END

		if _state:
			_on_triggered_on()
		else:
			_on_triggered_off()
		
		on_state_change.emit(state)